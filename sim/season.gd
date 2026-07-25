class_name Season
extends RefCounted
## One run: one scribe, one road, one finite budget of daylight.
##
## All numbers here are first-pass and marked as such. The season never writes
## prose — it emits ChronicleEvents and lets renderers tell the story.

enum Result { UNRESOLVED, RETURNED, FELL, STRANDED }

# --- First-pass tuning. Argue with these in playtests, not in code review. ---
# Starting stocks live in Outfit now; daylight stays here — it is the clock,
# not something the guild hall sells.
const STARTING_DAYLIGHT := 40
const TRAVEL_COST := 2
const DELAY_COST := 2
const MISHAP_COST := 3
const PERIL_COST := 4
const PERIL_DEATH_CHANCE := 0.35
const COURIER_MEDIA_COST := 4
const SEAL_ROAD_PRICE := 5
const CONTRACT_MEDIA_COST := 1
const HEAVY_PACK_THRESHOLD := 12
const HEAVY_PACK_SURCHARGE := 1

var house: House
var route: Route
var rng: SimRng
var chronicle: Chronicle
var scribe: String
var number: int

var day := 1
var daylight := STARTING_DAYLIGHT
var clay: int
var papyrus: int
var seals: int
var position := 0
var heading_home := false
var max_leg_reached := 0
var result := Result.UNRESOLVED
var entries: Array[Dictionary] = []
var surveys: Array[int] = []
var sent_entries: Array[Dictionary] = []
var silver := 0  # The road purse: contract income in, call-ins and seals out.
var contracts: Array[ContractCatalog.ContractTemplate] = []
var _voided_ids: Array[String] = []
var _last_outcome: StringName = &"arrived"
var _heavy_going_reported := false
var _stock_spent_reported := false

## Where the light has gone since the last event was emitted. Every spend names
## the bucket it belongs to and the next event carries the tally away, so the
## log records not just that daylight went but what it went to. Attribution
## happens at the point of spending and therefore cannot drift; measurement
## reads the log (`measure/`) rather than re-deriving the arithmetic. This is a
## record of a spend, not a meter — nothing in the sim ever reads it back.
var _light_pending: Dictionary[StringName, int] = {}


func _init(p_house: House, p_route: Route, p_rng: SimRng, p_chronicle: Chronicle, p_scribe: String, p_number: int, p_outfit: Outfit) -> void:
	house = p_house
	route = p_route
	rng = p_rng
	chronicle = p_chronicle
	scribe = p_scribe
	number = p_number
	clay = p_outfit.clay
	papyrus = p_outfit.papyrus
	seals = p_outfit.seals


func begin() -> void:
	_emit(&"departed", route.nodes[0].display_name, {"daylight": str(daylight)})


func is_over() -> bool:
	return result != Result.UNRESOLVED


func media_total() -> int:
	return clay + papyrus


## What the caravan is actually hauling: blank stock and seals. Written work
## rides in the document chest, weightless by deliberate abstraction —
## writing converts a heavy liability into the point of the game.
func carried_bulk() -> int:
	return clay * Outfit.CLAY_BULK + papyrus * Outfit.PAPYRUS_BULK \
		+ seals * Outfit.SEAL_BULK


## Clay slows the caravan (systems.md §1): a pack over the threshold costs
## an extra day of light per node. Pure arithmetic — no draws.
func travel_cost() -> int:
	if carried_bulk() > HEAVY_PACK_THRESHOLD:
		return TRAVEL_COST + HEAVY_PACK_SURCHARGE
	return TRAVEL_COST


## Move one node along the road, resolving whatever the road does about it.
func travel_next() -> void:
	if is_over():
		return
	if heading_home:
		position -= 1
	else:
		position += 1
	var step_cost := travel_cost()
	if step_cost > TRAVEL_COST and not _heavy_going_reported:
		_heavy_going_reported = true
		_emit(&"heavy_going", route.nodes[position].display_name,
			{"cost": str(HEAVY_PACK_SURCHARGE)})
	_spend_daylight(step_cost, &"travel")
	if is_over():
		return
	day += 1
	var node: Route.RouteNode = route.nodes[position]
	max_leg_reached = maxi(max_leg_reached, node.leg)
	_arrive(node)
	if is_over():
		return
	for c: ContractCatalog.ContractTemplate in contracts:
		silver += c.income_per_leg
	if not heading_home and position == route.last_index():
		heading_home = true
		_emit(&"turned_home", node.display_name, {})
		_resolve_call_ins(_last_outcome)
		if not is_over():
			_resolve_call_ins(&"turned_home")
	elif heading_home and position == 0:
		result = Result.RETURNED
		_emit(&"returned", node.display_name,
			{"entries": str(entries.size()), "light": str(daylight)})
	else:
		_resolve_call_ins(_last_outcome)


## Why this entry would not get written, as a code (&"" means it will be).
##
## The sim owns the reason; whoever is presenting it owns the words — the same
## split `Outfit.invalid_reason` uses at the guild hall. Every gate in
## `write_entry` lives here and nowhere else, so a refusal reported to a player
## is the refusal that actually happened rather than a list of everything that
## might have. Pure: it draws nothing and changes nothing.
##
## Order is by usefulness, not by the order the sim happens to check: a scribe
## with an empty pack is told about the pack, not about the seal they also lack.
func preview_write_reason(type: Ledger.EntryType, leg: int = -1, use_seal: bool = false) -> StringName:
	if is_over():
		return &"season_over"
	if daylight <= Ledger.daylight_cost(type):
		return &"no_light"
	if media_total() < Ledger.media_cost(type):
		return &"no_media"
	if use_seal and seals < 1:
		return &"no_seal"
	if type == Ledger.EntryType.SURVEY:
		if leg < 1 or leg > route.leg_count():
			return &"nothing_behind"
		if max_leg_reached < leg:
			return &"leg_unreached"
		if surveys.has(leg):
			return &"leg_written"
		if house.surveyed_legs.has(leg):
			return &"leg_documented"
		if house.rumoured_legs.has(leg) and not use_seal:
			return &"rumour_unsealed"  # A rumour cannot confirm a rumour.
	return &""


## Stop and write. Costs daylight and media; the only way anything survives you.
## Sealing the entry spends a seal and makes it authoritative — an unsealed
## entry merges into the archive as a rumour at reduced value
## (docs/design/systems.md §3). A sealed survey may confirm a leg the House
## holds only as rumour; an unsealed one may not.
func write_entry(type: Ledger.EntryType, subject: String, leg: int = -1, use_seal: bool = false) -> bool:
	if preview_write_reason(type, leg, use_seal) != &"":
		return false
	var d_cost := Ledger.daylight_cost(type)
	var m_cost := Ledger.media_cost(type)
	if type == Ledger.EntryType.SURVEY:
		surveys.append(leg)
	if use_seal:
		seals -= 1
	_spend_media(m_cost)
	_spend_daylight(d_cost, &"writing")
	if is_over():
		return false
	var entry := {"season": number, "type": Ledger.type_name(type), "subject": subject, "leg": leg, "sealed": use_seal}
	entries.append(entry)
	# The light this cost rides on the event as {light_writing}, injected by
	# _emit. What the event adds is the decision: which leg, under seal or not.
	_emit(&"entry_written", route.nodes[position].display_name, {
		"entry_type": Ledger.type_name(type),
		"subject": subject,
		"leg": str(leg),
		"sealed": "yes" if use_seal else "no",
	})
	return true


## Why this contract would not be signed, as a code (&"" means it will be).
## See `preview_write_reason` for the split this follows.
func preview_contract_reason(template: ContractCatalog.ContractTemplate) -> StringName:
	if is_over():
		return &"season_over"
	var node: Route.RouteNode = route.nodes[position]
	if node.kind != "settlement":
		return &"not_settlement"
	if not template.sign_at.has(node.id):
		return &"not_offered_here"
	if _voided_ids.has(template.id):
		return &"voided"
	for c: ContractCatalog.ContractTemplate in contracts:
		if c.id == template.id:
			return &"already_signed"
	if media_total() < CONTRACT_MEDIA_COST:
		return &"no_media"
	return &""


## Sign a standing contract at a settlement that offers it. A contract is a
## written thing: signing consumes media, so every deal in force is writing
## capacity spent. Refuses duplicates and deals already voided this season —
## word travels.
func sign_contract(template: ContractCatalog.ContractTemplate) -> bool:
	if preview_contract_reason(template) != &"":
		return false
	var node: Route.RouteNode = route.nodes[position]
	_spend_media(CONTRACT_MEDIA_COST)
	contracts.append(template)
	_emit(&"contract_signed", node.display_name, {
		"holder": template.holder,
		"contract": template.display_name,
		"terms": template.terms,
	})
	return true


## Why no seal would change hands here, as a code (&"" means one will).
## See `preview_write_reason` for the split this follows.
func preview_seal_reason() -> StringName:
	if is_over():
		return &"season_over"
	var node: Route.RouteNode = route.nodes[position]
	if node.kind != "settlement":
		return &"not_settlement"
	if position == 0:
		return &"home_hall"
	var access := false
	for c: ContractCatalog.ContractTemplate in contracts:
		if c.grants_seal_access:
			access = true
	if not access:
		return &"no_standing"
	if silver < SEAL_ROAD_PRICE:
		return &"no_silver"
	if carried_bulk() + Outfit.SEAL_BULK > Outfit.PACK_CAPACITY:
		return &"no_room"
	return &""


## Buy one seal at a foreign guild hall. Access is contractual, the price
## comes out of the road purse, and the pack must have room. Room means
## carried_bulk(): blank stock and seals — written work rides weightless
## in the document chest, by the same abstraction travel_cost() uses.
func buy_seal() -> bool:
	if preview_seal_reason() != &"":
		return false
	var node: Route.RouteNode = route.nodes[position]
	silver -= SEAL_ROAD_PRICE
	seals += 1
	_emit(&"seal_bought", node.display_name, {"price": str(SEAL_ROAD_PRICE)})
	return true


## The other half of every contract: the holder calls it in when the road
## makes it expensive (systems.md §3). A daylight demand is always honoured —
## the pledge that saves you can strand you. A silver demand defaults when
## the purse is short: the penalty is taken in media and the deal may void.
func _resolve_call_ins(outcome: StringName) -> void:
	for c: ContractCatalog.ContractTemplate in contracts.duplicate():
		if is_over():
			return
		if c.trigger != outcome:
			continue
		_emit(&"contract_called", route.nodes[position].display_name, {
			"holder": c.holder, "contract": c.display_name, "demand": c.demand})
		if c.demand_daylight > 0:
			_spend_daylight(c.demand_daylight, &"obligation")
			if not is_over():
				_emit(&"contract_honoured", route.nodes[position].display_name, {
					"holder": c.holder, "contract": c.display_name, "demand": c.demand})
		elif silver >= c.demand_silver:
			silver -= c.demand_silver
			_emit(&"contract_honoured", route.nodes[position].display_name, {
				"holder": c.holder, "contract": c.display_name, "demand": c.demand})
		else:
			silver = 0  # The holder empties the purse before taking the penalty.
			if c.default_media_penalty > 0:
				_lose_media(c.default_media_penalty)
			if c.voids_on_default:
				contracts.erase(c)
				_voided_ids.append(c.id)
			_emit(&"contract_defaulted", route.nodes[position].display_name, {
				"holder": c.holder, "contract": c.display_name, "penalty": c.penalty})


## Spend a seal and a portion of media to send a copy of the ledger home
## (docs/design/systems.md §3). What is sent survives the scribe; what is
## written afterwards does not. Sending again re-copies the whole ledger,
## so the House can never receive the same entry twice. The snapshot carries
## each entry's leg and seal status, so a couriered survey folds exactly as
## a carried one would.
## Why no courier would go, as a code (&"" means one will). Ordered so the
## scribe hears about the empty pack first: the courier copies the ledger, and
## a copy needs something to be copied onto. See `preview_write_reason`.
func preview_courier_reason() -> StringName:
	if is_over():
		return &"season_over"
	if entries.is_empty():
		return &"nothing_written"
	if media_total() < COURIER_MEDIA_COST:
		return &"no_media"
	if seals < 1:
		return &"no_seal"
	return &""


func send_courier() -> bool:
	if preview_courier_reason() != &"":
		return false
	seals -= 1
	_spend_media(COURIER_MEDIA_COST)
	sent_entries = entries.duplicate(true)
	_emit(&"courier_sent", route.nodes[position].display_name, {
		"entries": str(entries.size()),
		"media": str(COURIER_MEDIA_COST),
	})
	return true


func _arrive(node: Route.RouteNode) -> void:
	_last_outcome = &"arrived"
	if node.kind == "settlement":
		if position != 0:
			_emit(&"arrived", node.display_name, {"kind": node.kind})
		return
	var roll := rng.stream(&"road").randf()
	if roll < 0.45:
		_emit(&"arrived", node.display_name, {"kind": node.kind})
	elif roll < 0.75:
		_spend_daylight(DELAY_COST, &"road")
		if not is_over():
			_last_outcome = &"delayed"
			_emit(&"delayed", node.display_name, {"kind": node.kind})
	elif roll < 0.93:
		var lost := _lose_media(1, node.flavor)
		_spend_daylight(MISHAP_COST, &"road")
		if not is_over():
			_last_outcome = &"mishap"
			_emit(&"mishap", node.display_name, {"kind": node.kind,
				"lost_clay": str(lost["clay"]), "lost_papyrus": str(lost["papyrus"])})
	else:
		_peril(node)


func _peril(node: Route.RouteNode) -> void:
	match node.kind:
		"hazard":
			if rng.stream(&"fate").randf() < _peril_death_chance():
				result = Result.FELL
				_last_outcome = &"fell"
				_emit(&"fell", node.display_name,
					{"kind": node.kind, "light": str(daylight)})
				return
			_spend_daylight(PERIL_COST, &"road")
			if not is_over():
				_last_outcome = &"peril_survived"
				_emit(&"peril_survived", node.display_name, {"kind": node.kind})
				# Surviving a water peril is not surviving dry: every sheet of
				# papyrus is pulp. The clay comes out streaked but legible.
				if node.flavor == "water" and papyrus > 0:
					var soaked := papyrus
					papyrus = 0
					_emit(&"soaked", node.display_name, {"lost_papyrus": str(soaked)})
		"rival":
			var lost := _lose_media(2)
			_spend_daylight(DELAY_COST, &"road")
			if not is_over():
				_last_outcome = &"shaken_down"
				_emit(&"shaken_down", node.display_name, {
					"lost_clay": str(lost["clay"]), "lost_papyrus": str(lost["papyrus"])})
		"ruin":
			_last_outcome = &"found_relic"
			_emit(&"found_relic", node.display_name, {})
		_:
			_emit(&"arrived", node.display_name, {"kind": node.kind})


## Protection contracts lower the death threshold the SAME fate draw is
## compared against — no extra draws, so seeded road sequences are untouched.
func _peril_death_chance() -> float:
	var chance := PERIL_DEATH_CHANCE
	for c: ContractCatalog.ContractTemplate in contracts:
		if c.peril_death_chance >= 0.0:
			chance = minf(chance, c.peril_death_chance)
	return chance


## Spend light, naming what it bought. The bucket is one of &"travel",
## &"writing", &"road" (what the road takes regardless of choice) or
## &"obligation" (a contract called in). A spend larger than what is left is
## honoured in full and the light clamps to zero — the overshoot is how far
## short the season fell, and the log keeps it.
func _spend_daylight(amount: int, bucket: StringName) -> void:
	var already: int = _light_pending.get(bucket, 0)
	_light_pending[bucket] = already + amount
	daylight -= amount
	if daylight <= 0:
		daylight = 0
		if position == 0 and heading_home:
			return  # Staggered through the gate on the last of the light.
		result = Result.STRANDED
		_emit(&"stranded", route.nodes[position].display_name, {"light": "0"})


## Lose media to the road. Neutral losses take papyrus first, then clay.
## Water losses take papyrus ONLY — clay survives the shipwreck (systems.md
## §1), so a clay-forward pack can walk out of a marsh with its stock
## intact. Returns what was actually lost; the renderer writes the words.
func _lose_media(amount: int, flavor: String = "") -> Dictionary:
	var lost_papyrus := mini(amount, papyrus)
	papyrus -= lost_papyrus
	var lost_clay := 0
	if flavor != "water":
		lost_clay = mini(amount - lost_papyrus, clay)
		clay -= lost_clay
	return {"clay": lost_clay, "papyrus": lost_papyrus}


func _spend_media(amount: int) -> void:
	var from_papyrus := mini(amount, papyrus)
	papyrus -= from_papyrus
	clay -= amount - from_papyrus


## Record an event, and hand it whatever light has been spent since the last
## one. Every spend therefore lands on exactly one event: the season's whole
## budget is readable off the log without the sim keeping a single total.
##
## An emptied pack is announced immediately after whatever emptied it, whether
## that was the scribe's pen or the road's weather — which is why the check
## hangs here rather than at seven call sites that would each have to remember.
func _emit(type: StringName, place: String, data: Dictionary) -> void:
	for bucket: StringName in _light_pending:
		data["light_" + String(bucket)] = str(_light_pending[bucket])
	_light_pending.clear()
	chronicle.record(ChronicleEvent.make(number, day, type, place, scribe, data))
	if type != &"stock_spent":
		_note_stock_spent()


## The last of the stock is gone. Until now this was the game's one wholly
## silent state change: nothing announced it, nothing refuses until you try,
## and a player who has run out cannot tell an empty pack from a button they
## have misunderstood. The season is not over — but from here it is walking,
## and the book should say so. Announced once. Carries no light: `_emit` has
## just drained the tally onto the event that caused this.
func _note_stock_spent() -> void:
	if _stock_spent_reported or is_over() or media_total() > 0:
		return
	_stock_spent_reported = true
	_emit(&"stock_spent", route.nodes[position].display_name,
		{"seals": str(seals), "entries": str(entries.size())})
