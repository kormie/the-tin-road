class_name SeasonRecord
extends RefCounted
## One season, counted rather than narrated.
##
## The chronicle is the only input. `chronicle/renderer.gd` reads the log for
## prose; this reads the same log for numbers; neither is allowed to know
## anything the other cannot see. Nothing here belongs in `sim/` — measurement
## is a reader, not a system, and a season nobody measures plays identically.
##
## This is also the record the playable layer emits (`game/session.gd`), so a
## human playtest and the reference brain produce the same shape and can be
## compared line for line. What each field feeds, and what a healthy value
## looks like: `docs/design/measurement.md`.

var season: int
var scribe: String
var outcome: String = "unresolved"  # returned | fell | stranded | unresolved
var days: int

# --- Daylight, in the four buckets sim/season.gd names at the point of spend.
var light_travel: int
var light_writing: int
var light_road: int        # what the road takes regardless of any choice made
var light_obligation: int  # contracts called in
var light_unspent: int
var heavy_surcharge: int   # of light_travel, how much an overloaded pack cost

# --- The Ledger
var entries_written: int
var entries_by_type: Dictionary[String, int] = {}
var surveys_written: int
var surveys_sealed: int
var entries_merged: int  # what actually reached the archive
var surveys_landed: int

# --- The road, as the archive holds it
var legs_sealed_start: int
var legs_rumoured_start: int
var legs_sealed_end: int
var legs_rumoured_end: int
var route_documented: bool  # became documented THIS season

# --- The Courier
var courier_sent: bool
var courier_day: int
var courier_entries: int
var courier_delivered: bool

# --- Automation
var order_posted: bool
var order_price: int
var caravan_returned: bool
var caravan_income: int
var caravan_fee: int

# --- Silver and stock
var advance: int
var outfit_spent: int
var kit_clay: int
var kit_papyrus: int
var kit_seals: int
var seals_bought: int
var purse_banked: int
var treasury_start: int
var treasury_end: int
var archive_start: int
var archive_end: int

# --- Standing contracts
var contracts_signed: int
var contracts_called: int
var contracts_defaulted: int


## Everything the season spent light on, attributed. Excludes what was never
## spent — see `light_unspent`.
func light_attributed() -> int:
	return light_travel + light_writing + light_road + light_obligation


## By how much the season overdrew its light. The road bills in full even when
## the purse is empty, so a spend can exceed what is left; the excess is exactly
## how many more days the season needed and did not have. Zero on a season that
## came home with light to spare.
func light_short() -> int:
	return maxi(0, light_attributed() + light_unspent - Season.STARTING_DAYLIGHT)


## Written and never delivered: the entries the road kept. The Courier signal
## lives here — a steep courier shows up as a rising pile of lost writing.
func entries_lost() -> int:
	return maxi(0, entries_written - entries_merged)


func surveys_lost() -> int:
	return maxi(0, surveys_written - surveys_landed)


func legs_known_start() -> int:
	return legs_sealed_start + legs_rumoured_start


func legs_known_end() -> int:
	return legs_sealed_end + legs_rumoured_end


## Build the record for one season from that season's slice of the log.
## `previous` carries the standing facts a season inherits — what the House
## knew, held, and owned when the scribe walked out of the gate. Pass null for
## the first season.
static func from_events(p_season: int, events: Array[ChronicleEvent], previous: SeasonRecord = null) -> SeasonRecord:
	var r := SeasonRecord.new()
	r.season = p_season
	if previous != null:
		r.legs_sealed_start = previous.legs_sealed_end
		r.legs_rumoured_start = previous.legs_rumoured_end
		r.treasury_start = previous.treasury_end
		r.archive_start = previous.archive_end
	r.legs_sealed_end = r.legs_sealed_start
	r.legs_rumoured_end = r.legs_rumoured_start
	for ev: ChronicleEvent in events:
		r.days = maxi(r.days, ev.day)
		r._take_light(ev)
		r._take_fact(ev)
	r.treasury_end = r.treasury_start + r.advance + maxi(0, r.caravan_income - r.caravan_fee) \
		- r.outfit_spent - (r.seals_bought * Season.SEAL_ROAD_PRICE) \
		+ r.purse_banked - r.order_price
	r.archive_end = r.archive_start + r.entries_merged + (1 if r.order_posted else 0)
	return r


## Daylight, from whichever event the spend was handed to. A travelling step
## costs more than the base fare only when the pack is over the threshold, so
## the surcharge is the excess, per step — media that matters, in days.
func _take_light(ev: ChronicleEvent) -> void:
	var travel := _int(ev.data, "light_travel")
	if travel > 0:
		light_travel += travel
		heavy_surcharge += maxi(0, travel - Season.TRAVEL_COST)
	light_writing += _int(ev.data, "light_writing")
	light_road += _int(ev.data, "light_road")
	light_obligation += _int(ev.data, "light_obligation")


func _take_fact(ev: ChronicleEvent) -> void:
	match ev.type:
		&"season_began", &"succession":
			scribe = ev.actor
		&"commissioned":
			advance = _int(ev.data, "advance")
		&"outfitted":
			outfit_spent = _int(ev.data, "spent")
			kit_clay = _int(ev.data, "clay")
			kit_papyrus = _int(ev.data, "papyrus")
			kit_seals = _int(ev.data, "seals")
		&"caravan_returned":
			caravan_returned = true
			caravan_income = _int(ev.data, "income")
			caravan_fee = _int(ev.data, "fee")
		&"caravan_assigned":
			order_posted = true
			order_price = _int(ev.data, "price")
		&"entry_written":
			entries_written += 1
			var type_name := str(ev.data.get("entry_type", "unknown"))
			var seen: int = entries_by_type.get(type_name, 0)
			entries_by_type[type_name] = seen + 1
			if type_name == Ledger.type_name(Ledger.EntryType.SURVEY):
				surveys_written += 1
				if str(ev.data.get("sealed", "no")) == "yes":
					surveys_sealed += 1
		&"seal_bought":
			seals_bought += 1
		&"contract_signed":
			contracts_signed += 1
		&"contract_called":
			contracts_called += 1
		&"contract_defaulted":
			contracts_defaulted += 1
		&"courier_sent":
			courier_sent = true
			courier_day = ev.day
			courier_entries = _int(ev.data, "entries")
		&"courier_delivered":
			courier_delivered = true
			entries_merged = _int(ev.data, "entries")
		&"ledger_merged":
			entries_merged = _int(ev.data, "entries")
		&"purse_banked":
			purse_banked = _int(ev.data, "silver")
		&"leg_surveyed":
			legs_sealed_end += 1
			surveys_landed += 1
		&"rumour_confirmed":
			legs_sealed_end += 1
			legs_rumoured_end = maxi(0, legs_rumoured_end - 1)
			surveys_landed += 1
		&"leg_rumoured":
			legs_rumoured_end += 1
			surveys_landed += 1
		&"route_documented":
			route_documented = true
		&"returned":
			outcome = "returned"
			light_unspent = _int(ev.data, "light")
		&"fell":
			outcome = "fell"
			light_unspent = _int(ev.data, "light")
		&"stranded":
			outcome = "stranded"
			light_unspent = 0


## Event data is stringly typed on the wire, because it is prose fuel first.
static func _int(data: Dictionary, key: String) -> int:
	return int(str(data.get(key, "0")))


## One line a facilitator can read off a screen mid-playtest without stopping
## the session to parse JSON.
func headline() -> String:
	return "s%d %s %s — day %d — light T%d/W%d/R%d/O%d, %d left — %d entries (%d lost) — legs %d→%d — courier %s" % [
		season, scribe, outcome, days,
		light_travel, light_writing, light_road, light_obligation, light_unspent,
		entries_written, entries_lost(), legs_known_start(), legs_known_end(),
		"sent" if courier_sent else "no",
	]


func to_dict() -> Dictionary:
	return {
		"season": season,
		"scribe": scribe,
		"outcome": outcome,
		"days": days,
		"light_travel": light_travel,
		"light_writing": light_writing,
		"light_road": light_road,
		"light_obligation": light_obligation,
		"light_unspent": light_unspent,
		"light_attributed": light_attributed(),
		"light_short": light_short(),
		"heavy_surcharge": heavy_surcharge,
		"entries_written": entries_written,
		"entries_by_type": entries_by_type,
		"entries_merged": entries_merged,
		"entries_lost": entries_lost(),
		"surveys_written": surveys_written,
		"surveys_sealed": surveys_sealed,
		"surveys_landed": surveys_landed,
		"surveys_lost": surveys_lost(),
		"legs_sealed_start": legs_sealed_start,
		"legs_rumoured_start": legs_rumoured_start,
		"legs_sealed_end": legs_sealed_end,
		"legs_rumoured_end": legs_rumoured_end,
		"route_documented": route_documented,
		"courier_sent": courier_sent,
		"courier_day": courier_day,
		"courier_entries": courier_entries,
		"courier_delivered": courier_delivered,
		"order_posted": order_posted,
		"order_price": order_price,
		"caravan_returned": caravan_returned,
		"caravan_income": caravan_income,
		"caravan_fee": caravan_fee,
		"advance": advance,
		"outfit_spent": outfit_spent,
		"kit_clay": kit_clay,
		"kit_papyrus": kit_papyrus,
		"kit_seals": kit_seals,
		"seals_bought": seals_bought,
		"purse_banked": purse_banked,
		"treasury_start": treasury_start,
		"treasury_end": treasury_end,
		"archive_start": archive_start,
		"archive_end": archive_end,
		"contracts_signed": contracts_signed,
		"contracts_called": contracts_called,
		"contracts_defaulted": contracts_defaulted,
	}
