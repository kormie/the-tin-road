class_name Measurement
extends RefCounted
## One run, measured: the season records of a single House, and the run-level
## facts the vertical slice's five signals are computed from.
##
## Reads `Chronicle` and nothing else. The sim does not know this file exists
## and must not — see `docs/design/measurement.md` for what each signal is
## computed from, and `data/measure/bands.json` for what a healthy value is.
##
## Signal three (the reaction at the first automated return) is deliberately
## absent from the arithmetic here. It is not telemetry and no proxy for it is
## offered; what this file can do is point at the exact moment to watch, which
## it does, and hand the rest to `docs/design/playtest-script.md`.

var seed_value: int
var records: Array[SeasonRecord] = []


## Fold a House's whole chronicle into one record per season, in order, each
## carrying forward what the next season inherits.
static func of_chronicle(chronicle: Chronicle, p_seed: int = 0) -> Measurement:
	var m := Measurement.new()
	m.seed_value = p_seed
	var last_season := 0
	for ev: ChronicleEvent in chronicle.events:
		last_season = maxi(last_season, ev.season)
	var previous: SeasonRecord = null
	for n: int in range(1, last_season + 1):
		var events := chronicle.for_season(n)
		if events.is_empty():
			continue
		var record := SeasonRecord.from_events(n, events, previous)
		m.records.append(record)
		previous = record
	return m


## The season in which the road became documented whole, or -1 if it never did.
func documented_in_season() -> int:
	for r: SeasonRecord in records:
		if r.route_documented:
			return r.season
	return -1


## The season a caravan first walked the road unattended, or -1. This is the
## cue for signal three, not a measurement of it: it says where to look.
func first_automated_return() -> int:
	for r: SeasonRecord in records:
		if r.caravan_returned:
			return r.season
	return -1


## What the second scribe inherited, in legs of road. The whole generational
## premise, reduced to the one number that can falsify it.
func legs_inherited_at_second_season() -> int:
	for r: SeasonRecord in records:
		if r.season == 2:
			return r.legs_known_start()
	return -1


func record_for(season: int) -> SeasonRecord:
	for r: SeasonRecord in records:
		if r.season == season:
			return r
	return null


# --- The five signals, computed across every run in the pass. --------------

## Load the bands a signal is judged against. Bands are data so that arguing
## with a number means editing a file, not a build.
static func load_bands(path: String = "res://data/measure/bands.json") -> Dictionary:
	var text := FileAccess.get_file_as_string(path)
	assert(text != "", "Band file missing or empty: " + path)
	var parsed: Variant = JSON.parse_string(text)
	assert(parsed is Dictionary, "Band file is not valid JSON: " + path)
	var root := parsed as Dictionary
	var signals_raw: Variant = root.get("signals", {})
	assert(signals_raw is Dictionary, "Band file needs a signals object")
	return signals_raw as Dictionary


## Compute every signal across a pass of runs, each keyed by its band id and
## carrying its value, its verdict against the band, and the lines a human
## needs to act on it rather than merely read it.
static func signals(runs: Array[Measurement], bands: Dictionary) -> Dictionary:
	var out := {}
	out["daylight_split"] = _signal_daylight(runs, bands)
	out["route_surveyed"] = _signal_route(runs, bands)
	out["first_automated_return"] = _signal_automation(runs, bands)
	out["courier_use"] = _signal_courier(runs, bands)
	out["season_two_delta"] = _signal_inheritance(runs, bands)
	return out


static func _signal_daylight(runs: Array[Measurement], bands: Dictionary) -> Dictionary:
	var travel := 0
	var writing := 0
	var road := 0
	var obligation := 0
	var unspent := 0
	var surcharge := 0
	var short_total := 0
	var short_seasons := 0
	for m: Measurement in runs:
		for r: SeasonRecord in m.records:
			travel += r.light_travel
			writing += r.light_writing
			road += r.light_road
			obligation += r.light_obligation
			unspent += r.light_unspent
			surcharge += r.heavy_surcharge
			if r.light_short() > 0:
				short_total += r.light_short()
				short_seasons += 1
	var spent := travel + writing + road + obligation
	var value := 0.0 if spent == 0 else 100.0 * float(writing) / float(spent)
	var detail: Array[String] = [
		"of %d days spent: travelling %d (%s), writing %d (%s), the road's own toll %d (%s), obligations %d (%s)" % [
			spent, travel, _pct(travel, spent), writing, _pct(writing, spent),
			road, _pct(road, spent), obligation, _pct(obligation, spent)],
		"%d days never spent at all; %d days lost to an overloaded pack" % [unspent, surcharge],
	]
	if short_seasons > 0:
		detail.append("%d season(s) overdrew the light, by %.1f days on average — how far the road's bill ran past what was left" % [
			short_seasons, float(short_total) / float(short_seasons)])
	return _assemble("daylight_split", bands, value, "%", detail)


static func _signal_route(runs: Array[Measurement], bands: Dictionary) -> Dictionary:
	var seasons: Array[int] = []
	var never: Array[int] = []
	for m: Measurement in runs:
		var s := m.documented_in_season()
		if s > 0:
			seasons.append(s)
		else:
			never.append(m.seed_value)
	var value := float(_median(seasons)) if not seasons.is_empty() else -1.0
	var detail: Array[String] = [
		"%d of %d runs documented the road whole%s" % [seasons.size(), runs.size(),
			"" if seasons.is_empty() else "; seasons taken: " + _join_ints(seasons)],
	]
	if not never.is_empty():
		detail.append("never documented on seed(s) %s — a run that never gets there has failed the slice's question" % _join_ints(never))
	detail.append("whether it was reached UNPROMPTED is not in this number: the facilitator records hints given (playtest-script.md §2)")
	var result := _assemble("route_surveyed", bands, value, " seasons", detail)
	if seasons.is_empty() or not never.is_empty():
		result["verdict"] = "WATCH"
	return result


## Signal three. The build locates the moment and refuses to score it.
static func _signal_automation(runs: Array[Measurement], bands: Dictionary) -> Dictionary:
	var detail: Array[String] = []
	for m: Measurement in runs:
		var s := m.first_automated_return()
		if s > 0:
			detail.append("seed %d: first caravan_returned lands at the head of season %d, after %d played season(s)" % [
				m.seed_value, s, s - 1])
		else:
			detail.append("seed %d: no automated return in this pass — nothing to watch a face for" % m.seed_value)
	detail.append("watch the player, not the log: docs/design/playtest-script.md §3")
	var result := _assemble("first_automated_return", bands, -1.0, "", detail)
	result["verdict"] = "NOT MEASURED"
	result["measurable"] = false
	return result


static func _signal_courier(runs: Array[Measurement], bands: Dictionary) -> Dictionary:
	var seasons := 0
	var sent := 0
	var fatal := 0
	var fatal_with_courier := 0
	var entries_lost := 0
	var surveys_lost := 0
	for m: Measurement in runs:
		for r: SeasonRecord in m.records:
			seasons += 1
			if r.courier_sent:
				sent += 1
			if r.outcome == "fell" or r.outcome == "stranded":
				fatal += 1
				if r.courier_sent:
					fatal_with_courier += 1
			entries_lost += r.entries_lost()
			surveys_lost += r.surveys_lost()
	var value := 0.0 if seasons == 0 else 100.0 * float(sent) / float(seasons)
	var detail: Array[String] = [
		"sent in %d of %d seasons" % [sent, seasons],
		"%d season(s) ended on the road; %d of those had already couriered, so the ledger survived" % [fatal, fatal_with_courier],
		"%d entries never reached the archive, %d of them surveys — the price of the Courier, paid in the other direction" % [
			entries_lost, surveys_lost],
	]
	return _assemble("courier_use", bands, value, "%", detail)


static func _signal_inheritance(runs: Array[Measurement], bands: Dictionary) -> Dictionary:
	var legs: Array[int] = []
	var detail: Array[String] = []
	for m: Measurement in runs:
		var first := m.record_for(1)
		var second := m.record_for(2)
		if first == null or second == null:
			continue
		legs.append(second.legs_known_start())
		detail.append("seed %d: season two opens on %d leg(s) of known road, %d archived entr(ies), %d shekels (season one opened on 0, 0, %d)" % [
			m.seed_value, second.legs_known_start(), second.archive_start,
			second.treasury_start, first.treasury_start])
	var value := float(_median(legs)) if not legs.is_empty() else -1.0
	detail.append("whether that READS as progress rather than a reset is a human question (playtest-script.md §5)")
	return _assemble("season_two_delta", bands, value, " legs", detail)


## What the pass never saw happen. A signal computed over zero observations is
## not a finding, it is an absence, and the two are easy to confuse at a
## glance — a Courier used in 0% of seasons reads as damning until you notice
## nothing in the pass ever tried to use one. Everything here is usually a fact
## about the reference brain's policy rather than about the tuning.
static func coverage_gaps(runs: Array[Measurement]) -> Array[String]:
	var seasons := 0
	var couriered := 0
	var obligation_light := 0
	var surcharge := 0
	var fell := 0
	var stranded := 0
	var rumours := 0
	var seals_bought := 0
	var orders := 0
	var types_seen: Dictionary[String, bool] = {}
	for m: Measurement in runs:
		for r: SeasonRecord in m.records:
			seasons += 1
			couriered += 1 if r.courier_sent else 0
			obligation_light += r.light_obligation
			surcharge += r.heavy_surcharge
			fell += 1 if r.outcome == "fell" else 0
			stranded += 1 if r.outcome == "stranded" else 0
			rumours += r.legs_rumoured_end
			seals_bought += r.seals_bought
			orders += 1 if r.order_posted else 0
			for type_name: String in r.entries_by_type:
				types_seen[type_name] = true
	var gaps: Array[String] = []
	if seasons == 0:
		return ["nothing was played at all"]
	if couriered == 0:
		gaps.append("the Courier was never sent — signal four is an absence, not a reading")
	if obligation_light == 0:
		gaps.append("no contract was ever called in for daylight, so the obligation bucket is untested")
	if surcharge == 0:
		gaps.append("no season carried an overloaded pack, so clay's weight penalty never bit")
	if fell == 0:
		gaps.append("no scribe was killed by peril in this pass")
	if stranded == 0:
		gaps.append("no season ran out of light on the road")
	if rumours == 0:
		gaps.append("no unsealed survey ever stood as a rumour, so the half-value economy is untested")
	if seals_bought == 0:
		gaps.append("no seal was bought on the road")
	if orders == 0:
		gaps.append("no standing order was posted, so nothing here touches automation at all")
	for type_name: String in [Ledger.type_name(Ledger.EntryType.NOTE),
			Ledger.type_name(Ledger.EntryType.RECORD),
			Ledger.type_name(Ledger.EntryType.SURVEY),
			Ledger.type_name(Ledger.EntryType.TREATISE)]:
		if not types_seen.has(type_name):
			gaps.append("no %s was ever written" % type_name)
	return gaps


# --- Plumbing -------------------------------------------------------------

static func _assemble(id: String, bands: Dictionary, value: float, unit: String, detail: Array[String]) -> Dictionary:
	var band_raw: Variant = bands.get(id, {})
	var band: Dictionary = {}
	if band_raw is Dictionary:
		band = band_raw as Dictionary
	return {
		"id": id,
		"title": str(band.get("title", id)),
		"tells": str(band.get("tells", "")),
		"metric": str(band.get("metric", "")),
		"value": value,
		"unit": unit,
		"band": _band_text(band),
		"verdict": _verdict(value, band),
		"measurable": bool(band.get("measurable", true)),
		"detail": detail,
	}


static func _verdict(value: float, band: Dictionary) -> String:
	if not bool(band.get("measurable", true)):
		return "NOT MEASURED"
	if value < 0.0:
		return "WATCH"
	if band.has("low") and value < float(band["low"]):
		return "WATCH"
	if band.has("high") and value > float(band["high"]):
		return "WATCH"
	return "OK"


static func _band_text(band: Dictionary) -> String:
	if not bool(band.get("measurable", true)):
		return "not a number"
	if band.has("low") and band.has("high"):
		return "healthy %s-%s" % [str(band["low"]), str(band["high"])]
	if band.has("low"):
		return "healthy >= %s" % str(band["low"])
	if band.has("high"):
		return "healthy <= %s" % str(band["high"])
	return "no band set"


static func _pct(part: int, whole: int) -> String:
	if whole == 0:
		return "0%"
	return "%.0f%%" % (100.0 * float(part) / float(whole))


static func _median(values: Array[int]) -> int:
	if values.is_empty():
		return -1
	var sorted := values.duplicate()
	sorted.sort()
	@warning_ignore("integer_division")
	return sorted[sorted.size() / 2]


static func _join_ints(values: Array[int]) -> String:
	var parts: Array[String] = []
	for v: int in values:
		parts.append(str(v))
	return ", ".join(parts)
