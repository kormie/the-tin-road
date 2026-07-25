class_name House
extends RefCounted
## The thing that persists. Scribes are per-run; the House and its archive are
## forever — or at least until somebody poisons the archive, which is a later
## milestone (docs/design/systems.md §2, on probation).

const AUTOMATED_INCOME_BASE := 260  # shekels, weighed. First-pass.
const AUTOMATED_INCOME_SPREAD := 120
const STANDING_ORDER_COST := 100  # shekels: the order, the caravan's first outfitting, the guild bond. Steep so posting is a decision, not a formality. First-pass.
const CARAVAN_FEE := 60  # shekels per circuit: drovers, beasts, guards. First-pass.
const YABNINU_ADVANCE := 30  # shekels per season. First-pass.
# The slice's one commissioning faction (docs/design/vertical-slice.md).
# A const until factions become commission data at milestone 5.
const PATRON_NAME := "House Yabninu"

var display_name: String
var rng: SimRng
var chronicle: Chronicle
var naming: Naming
var route: Route

var generation := 0
var past_scribes: Array[String] = []
var archive: Array[Dictionary] = []
var surveyed_legs: Array[int] = []
var rumoured_legs: Array[int] = []
var silver := 0


func _init(p_name: String, p_seed: int, p_route: Route, p_naming: Naming) -> void:
	display_name = p_name
	rng = SimRng.new(p_seed)
	chronicle = Chronicle.new()
	naming = p_naming
	route = p_route


## A leg counts toward documentation whether surveyed under seal or held as
## rumour — but the caravan pays rumoured legs at half (see _archive_income).
func route_documented() -> bool:
	return surveyed_legs.size() + rumoured_legs.size() >= route.leg_count()


## Begin the next generation's season: succession, any automated caravan the
## archive can already run, the patron's advance, and the outfit purchase.
## A null or invalid outfit falls back to the default kit, which the advance
## always covers (YABNINU_ADVANCE >= the default kit's cost).
func start_season(outfit: Outfit = null) -> Season:
	generation += 1
	var scribe := naming.pick(rng.stream(&"names"), past_scribes)
	past_scribes.append(scribe)
	if generation > 1:
		chronicle.record(ChronicleEvent.make(generation, 0, &"succession",
			route.nodes[0].display_name, scribe,
			{"predecessor": past_scribes[past_scribes.size() - 2], "house": display_name}))
	else:
		# The book opens with the house and its first scribe, not with money.
		chronicle.record(ChronicleEvent.make(generation, 0, &"season_began",
			route.nodes[0].display_name, scribe, {}))
	if has_standing_order():
		var raw := AUTOMATED_INCOME_BASE + rng.stream(&"trade").randi_range(0, AUTOMATED_INCOME_SPREAD)
		var income := _archive_income(raw)
		silver += maxi(0, income - CARAVAN_FEE)
		chronicle.record(ChronicleEvent.make(generation, 0, &"caravan_returned",
			route.nodes[0].display_name, scribe,
			{"income": str(income), "fee": str(CARAVAN_FEE), "route": route.display_name}))
	silver += YABNINU_ADVANCE
	chronicle.record(ChronicleEvent.make(generation, 0, &"commissioned",
		route.nodes[0].display_name, scribe,
		{"patron": PATRON_NAME, "advance": str(YABNINU_ADVANCE)}))
	if outfit == null or not outfit.is_valid(silver):
		outfit = Outfit.default_kit()
	silver -= outfit.total_cost()
	chronicle.record(ChronicleEvent.make(generation, 0, &"outfitted",
		route.nodes[0].display_name, scribe,
		{"clay": str(outfit.clay), "papyrus": str(outfit.papyrus),
			"seals": str(outfit.seals), "spent": str(outfit.total_cost())}))
	return Season.new(self, route, rng, chronicle, scribe, generation, outfit)


## Commit a caravan to the documented route by posting a standing order —
## a sealed document appended to the archive. The order IS the assignment:
## it persists across successions because writing persists, and erasing it
## from the archive erases the automation (the corruption milestone's seam).
## Costs treasury silver; refuses while undocumented, unaffordable, or
## already standing. Revocation waits until there is a second road to
## prefer.
func post_standing_order() -> bool:
	if has_standing_order() or not route_documented():
		return false
	if silver < STANDING_ORDER_COST:
		return false
	silver -= STANDING_ORDER_COST
	archive.append({"season": generation, "type": "order",
		"subject": route.display_name, "leg": -1, "sealed": true})
	chronicle.record(ChronicleEvent.make(generation, 0, &"caravan_assigned",
		route.nodes[0].display_name, display_name,
		{"route": route.display_name, "price": str(STANDING_ORDER_COST)}))
	return true


## The assignment is a document, not a flag: a standing order exists exactly
## when the archive holds one for this route.
func has_standing_order() -> bool:
	for entry: Dictionary in archive:
		if str(entry.get("type", "")) == "order" and str(entry.get("subject", "")) == route.display_name:
			return true
	return false


## What the caravan actually pays: full share per sealed leg, half per
## rumoured leg — "merges at reduced value" in shekels (systems.md §3).
func _archive_income(raw: int) -> int:
	var legs := route.leg_count()
	if legs < 1:
		return raw  # A route with no legs has nothing to discount.
	var sealed_count := 0
	var rumoured_count := 0
	for leg: int in range(1, legs + 1):
		if surveyed_legs.has(leg):
			sealed_count += 1
		elif rumoured_legs.has(leg):
			rumoured_count += 1
	@warning_ignore("integer_division")
	return raw * (2 * sealed_count + rumoured_count) / (2 * legs)


## Fold a finished season back into the House. A scribe who came home merges
## everything; a scribe the road kept merges only what the courier already
## carried (docs/design/systems.md §2: partial merge on courier delivery).
func merge(season: Season) -> void:
	if not season.is_over():
		return
	if season.result == Season.Result.RETURNED:
		for entry: Dictionary in season.entries:
			archive.append(entry)
		if not season.entries.is_empty():
			chronicle.record(ChronicleEvent.make(season.number, season.day, &"ledger_merged",
				route.nodes[0].display_name, season.scribe,
				{"entries": str(season.entries.size()), "house": display_name}))
		if season.silver > 0:
			silver += season.silver
			chronicle.record(ChronicleEvent.make(season.number, season.day, &"purse_banked",
				route.nodes[0].display_name, season.scribe,
				{"silver": str(season.silver)}))
			season.silver = 0  # Bank once; a second merge must not double-count.
		_fold_surveys(season.entries, season)
		return
	if season.sent_entries.is_empty():
		return
	for entry: Dictionary in season.sent_entries:
		archive.append(entry)
	chronicle.record(ChronicleEvent.make(season.number, season.day, &"courier_delivered",
		route.nodes[0].display_name, season.scribe,
		{"entries": str(season.sent_entries.size()), "house": display_name}))
	_fold_surveys(season.sent_entries, season)


## Fold surveyed legs out of merged entries into the House's knowledge of the
## road. A sealed survey documents its leg (confirming any standing rumour);
## an unsealed one enters as rumour. The route-documented moment is announced
## exactly once, on the transition.
func _fold_surveys(merged: Array[Dictionary], season: Season) -> void:
	var was_documented := route_documented()
	for entry: Dictionary in merged:
		if str(entry.get("type", "")) != Ledger.type_name(Ledger.EntryType.SURVEY):
			continue
		var leg := int(entry.get("leg", -1))
		if leg < 1 or surveyed_legs.has(leg):
			continue
		if bool(entry.get("sealed", false)):
			surveyed_legs.append(leg)
			if rumoured_legs.has(leg):
				rumoured_legs.erase(leg)
				chronicle.record(ChronicleEvent.make(season.number, season.day, &"rumour_confirmed",
					route.nodes[0].display_name, season.scribe, {"leg": str(leg)}))
		elif not rumoured_legs.has(leg):
			rumoured_legs.append(leg)
			chronicle.record(ChronicleEvent.make(season.number, season.day, &"leg_rumoured",
				route.nodes[0].display_name, season.scribe, {"leg": str(leg)}))
	if not was_documented and route_documented():
		chronicle.record(ChronicleEvent.make(season.number, season.day, &"route_documented",
			route.nodes[0].display_name, season.scribe, {"route": route.display_name}))
