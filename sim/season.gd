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


## Move one node along the road, resolving whatever the road does about it.
func travel_next() -> void:
	if is_over():
		return
	if heading_home:
		position -= 1
	else:
		position += 1
	_spend_daylight(TRAVEL_COST)
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
		_emit(&"returned", node.display_name, {"entries": str(entries.size())})
	else:
		_resolve_call_ins(_last_outcome)


## Stop and write. Costs daylight and media; the only way anything survives you.
## Sealing the entry spends a seal and makes it authoritative — an unsealed
## entry merges into the archive as a rumour at reduced value
## (docs/design/systems.md §3). A sealed survey may confirm a leg the House
## holds only as rumour; an unsealed one may not.
func write_entry(type: Ledger.EntryType, subject: String, leg: int = -1, use_seal: bool = false) -> bool:
	if is_over():
		return false
	if use_seal and seals < 1:
		return false
	var d_cost := Ledger.daylight_cost(type)
	var m_cost := Ledger.media_cost(type)
	if daylight <= d_cost or media_total() < m_cost:
		return false
	if type == Ledger.EntryType.SURVEY:
		if leg < 1 or leg > route.leg_count() or max_leg_reached < leg:
			return false
		if surveys.has(leg) or house.surveyed_legs.has(leg):
			return false
		if house.rumoured_legs.has(leg) and not use_seal:
			return false  # A rumour cannot confirm a rumour.
		surveys.append(leg)
	if use_seal:
		seals -= 1
	_spend_media(m_cost)
	_spend_daylight(d_cost)
	if is_over():
		return false
	var entry := {"season": number, "type": Ledger.type_name(type), "subject": subject, "leg": leg, "sealed": use_seal}
	entries.append(entry)
	_emit(&"entry_written", route.nodes[position].display_name, {
		"entry_type": Ledger.type_name(type),
		"subject": subject,
		"cost": str(d_cost),
	})
	return true


## Sign a standing contract at a settlement that offers it. A contract is a
## written thing: signing consumes media, so every deal in force is writing
## capacity spent. Refuses duplicates and deals already voided this season —
## word travels.
func sign_contract(template: ContractCatalog.ContractTemplate) -> bool:
	if is_over():
		return false
	var node: Route.RouteNode = route.nodes[position]
	if node.kind != "settlement" or not template.sign_at.has(node.id):
		return false
	if _voided_ids.has(template.id):
		return false
	if media_total() < CONTRACT_MEDIA_COST:
		return false
	for c: ContractCatalog.ContractTemplate in contracts:
		if c.id == template.id:
			return false
	_spend_media(CONTRACT_MEDIA_COST)
	contracts.append(template)
	_emit(&"contract_signed", node.display_name, {
		"holder": template.holder,
		"contract": template.display_name,
		"terms": template.terms,
	})
	return true


## Buy one seal at a foreign guild hall. Access is contractual, the price
## comes out of the road purse, and the pack must have room. Bulk is checked
## against current stock — written tablets leave the counters; the
## media-weight task owns that seam.
func buy_seal() -> bool:
	if is_over():
		return false
	var node: Route.RouteNode = route.nodes[position]
	if node.kind != "settlement" or position == 0:
		return false
	var access := false
	for c: ContractCatalog.ContractTemplate in contracts:
		if c.grants_seal_access:
			access = true
	if not access or silver < SEAL_ROAD_PRICE:
		return false
	var bulk := clay * Outfit.CLAY_BULK + papyrus * Outfit.PAPYRUS_BULK \
		+ (seals + 1) * Outfit.SEAL_BULK
	if bulk > Outfit.PACK_CAPACITY:
		return false
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
			_spend_daylight(c.demand_daylight)
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
func send_courier() -> bool:
	if is_over():
		return false
	if seals < 1 or entries.is_empty() or media_total() < COURIER_MEDIA_COST:
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
		_spend_daylight(DELAY_COST)
		if not is_over():
			_last_outcome = &"delayed"
			_emit(&"delayed", node.display_name, {"kind": node.kind, "cost": str(DELAY_COST)})
	elif roll < 0.93:
		var lost := _lose_media(1)
		_spend_daylight(MISHAP_COST)
		if not is_over():
			_last_outcome = &"mishap"
			_emit(&"mishap", node.display_name, {"kind": node.kind, "lost": lost})
	else:
		_peril(node)


func _peril(node: Route.RouteNode) -> void:
	match node.kind:
		"hazard":
			if rng.stream(&"fate").randf() < _peril_death_chance():
				result = Result.FELL
				_last_outcome = &"fell"
				_emit(&"fell", node.display_name, {"kind": node.kind})
				return
			_spend_daylight(PERIL_COST)
			if not is_over():
				_last_outcome = &"peril_survived"
				_emit(&"peril_survived", node.display_name, {"kind": node.kind})
		"rival":
			var lost := _lose_media(2)
			_spend_daylight(DELAY_COST)
			if not is_over():
				_last_outcome = &"shaken_down"
				_emit(&"shaken_down", node.display_name, {"lost": lost})
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


func _spend_daylight(amount: int) -> void:
	daylight -= amount
	if daylight <= 0:
		daylight = 0
		if position == 0 and heading_home:
			return  # Staggered through the gate on the last of the light.
		result = Result.STRANDED
		_emit(&"stranded", route.nodes[position].display_name, {})


func _lose_media(amount: int) -> String:
	var lost_papyrus := mini(amount, papyrus)
	papyrus -= lost_papyrus
	var lost_clay := mini(amount - lost_papyrus, clay)
	clay -= lost_clay
	if lost_papyrus > 0 and lost_clay > 0:
		return "papyrus and clay"
	if lost_papyrus > 0:
		return "papyrus"
	if lost_clay > 0:
		return "a clay tablet"
	return "nothing worth keeping"


func _spend_media(amount: int) -> void:
	var from_papyrus := mini(amount, papyrus)
	papyrus -= from_papyrus
	clay -= amount - from_papyrus


func _emit(type: StringName, place: String, data: Dictionary) -> void:
	chronicle.record(ChronicleEvent.make(number, day, type, place, scribe, data))
