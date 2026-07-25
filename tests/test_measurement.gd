extends GdUnitTestSuite
## The measurement pass: what the chronicle can be made to give up, and the
## one signal it cannot. Fixed seeds throughout — the road kills scribes, and
## every invariant here is written to hold whether it does or not.

const SEEDS: Array[int] = [1259, 735, 90]
const SEASONS := 6


func _runs(seasons: int = SEASONS) -> Array[Measurement]:
	var out: Array[Measurement] = []
	for seed_value: int in SEEDS:
		var result: Dictionary = DemoRunner.run(seed_value, seasons)
		var house: House = result["house"]
		out.append(Measurement.of_chronicle(house.chronicle, seed_value))
	return out


# --- The instrumentation's central invariant ------------------------------

func test_every_day_of_light_is_attributed_to_exactly_one_bucket() -> void:
	# The sim hands each spend to the next event emitted. If a spend were ever
	# dropped or counted twice, this identity is where it would show: the four
	# buckets plus what was never spent must account for the whole season.
	# A season may overdraw — the road bills in full on an empty purse — so
	# equality is asserted only where light was actually left over.
	for m: Measurement in _runs():
		for r: SeasonRecord in m.records:
			var total := r.light_attributed() + r.light_unspent
			assert_int(total)\
				.override_failure_message("seed %d season %d: %d attributed + %d left" % [
					m.seed_value, r.season, r.light_attributed(), r.light_unspent])\
				.is_greater_equal(Season.STARTING_DAYLIGHT)
			if r.light_unspent > 0:
				assert_int(total).is_equal(Season.STARTING_DAYLIGHT)
				assert_int(r.light_short()).is_equal(0)
			assert_int(r.light_short()).is_greater_equal(0)


func test_a_season_that_writes_nothing_spends_no_writing_light() -> void:
	for m: Measurement in _runs():
		for r: SeasonRecord in m.records:
			if r.entries_written == 0:
				assert_int(r.light_writing).is_equal(0)
			else:
				assert_int(r.light_writing).is_greater(0)


func test_travel_light_is_never_below_the_base_fare_per_step() -> void:
	# The surcharge is read as the excess over the base fare, so it can only be
	# meaningful if no step ever costs less than the fare.
	for m: Measurement in _runs():
		for r: SeasonRecord in m.records:
			assert_int(r.heavy_surcharge).is_greater_equal(0)
			assert_int(r.light_travel).is_greater_equal(r.heavy_surcharge)


# --- Reading a log the sim did not write ----------------------------------

func _synthetic_season() -> Chronicle:
	# Hand-built so the expected numbers are visible rather than derived: one
	# survey written under seal, two travelling steps, one delay, home with
	# light to spare. 2 + 2 + 2 travel, 8 writing, 2 road, 24 left = 40.
	var c := Chronicle.new()
	c.record(ChronicleEvent.make(1, 0, &"season_began", "Ugarit", "Danel", {}))
	c.record(ChronicleEvent.make(1, 0, &"commissioned", "Ugarit", "Danel",
		{"patron": "House Yabninu", "advance": "30"}))
	c.record(ChronicleEvent.make(1, 0, &"outfitted", "Ugarit", "Danel",
		{"clay": "4", "papyrus": "6", "seals": "2", "spent": "26"}))
	c.record(ChronicleEvent.make(1, 2, &"arrived", "the Salt Marsh", "Danel",
		{"kind": "hazard", "light_travel": "2"}))
	c.record(ChronicleEvent.make(1, 2, &"entry_written", "the Salt Marsh", "Danel",
		{"entry_type": "survey", "subject": "the first leg", "leg": "1",
			"sealed": "yes", "light_writing": "8"}))
	c.record(ChronicleEvent.make(1, 3, &"delayed", "the Rival Sail", "Danel",
		{"kind": "rival", "light_travel": "2", "light_road": "2"}))
	c.record(ChronicleEvent.make(1, 11, &"returned", "Ugarit", "Danel",
		{"entries": "1", "light": "24", "light_travel": "2"}))
	c.record(ChronicleEvent.make(1, 11, &"ledger_merged", "Ugarit", "Danel",
		{"entries": "1", "house": "House Test"}))
	c.record(ChronicleEvent.make(1, 11, &"leg_surveyed", "Ugarit", "Danel", {"leg": "1"}))
	return c


func test_the_record_is_computed_from_the_log_alone() -> void:
	var m := Measurement.of_chronicle(_synthetic_season(), 7)
	assert_int(m.records.size()).is_equal(1)
	var r: SeasonRecord = m.records[0]
	assert_str(r.scribe).is_equal("Danel")
	assert_str(r.outcome).is_equal("returned")
	assert_int(r.days).is_equal(11)
	assert_int(r.light_travel).is_equal(6)
	assert_int(r.light_writing).is_equal(8)
	assert_int(r.light_road).is_equal(2)
	assert_int(r.light_obligation).is_equal(0)
	assert_int(r.light_unspent).is_equal(24)
	assert_int(r.light_attributed()).is_equal(16)
	assert_int(r.light_short()).is_equal(0)
	assert_int(r.heavy_surcharge).is_equal(0)
	assert_int(r.entries_written).is_equal(1)
	assert_int(r.surveys_written).is_equal(1)
	assert_int(r.surveys_sealed).is_equal(1)
	assert_int(r.entries_merged).is_equal(1)
	assert_int(r.entries_lost()).is_equal(0)
	assert_int(r.legs_sealed_end).is_equal(1)
	assert_int(r.legs_known_end()).is_equal(1)
	assert_int(r.treasury_end).is_equal(30 - 26)


func test_a_heavy_pack_shows_up_as_surcharge_not_as_travel() -> void:
	var c := Chronicle.new()
	c.record(ChronicleEvent.make(1, 0, &"season_began", "Ugarit", "Danel", {}))
	c.record(ChronicleEvent.make(1, 2, &"arrived", "the Salt Marsh", "Danel",
		{"kind": "hazard", "light_travel": str(Season.TRAVEL_COST + Season.HEAVY_PACK_SURCHARGE)}))
	c.record(ChronicleEvent.make(1, 3, &"arrived", "the Rival Sail", "Danel",
		{"kind": "rival", "light_travel": str(Season.TRAVEL_COST)}))
	var r: SeasonRecord = Measurement.of_chronicle(c, 7).records[0]
	assert_int(r.light_travel).is_equal(Season.TRAVEL_COST * 2 + Season.HEAVY_PACK_SURCHARGE)
	assert_int(r.heavy_surcharge).is_equal(Season.HEAVY_PACK_SURCHARGE)


func test_what_the_road_kept_counts_as_lost() -> void:
	var c := Chronicle.new()
	c.record(ChronicleEvent.make(1, 0, &"season_began", "Ugarit", "Danel", {}))
	for i: int in range(2):
		c.record(ChronicleEvent.make(1, 2 + i, &"entry_written", "the Salt Marsh", "Danel",
			{"entry_type": "survey", "subject": "a leg", "leg": str(i + 1),
				"sealed": "no", "light_writing": "8"}))
	c.record(ChronicleEvent.make(1, 4, &"courier_sent", "Open Water", "Danel",
		{"entries": "1", "media": "4"}))
	c.record(ChronicleEvent.make(1, 5, &"stranded", "Open Water", "Danel", {"light": "0"}))
	c.record(ChronicleEvent.make(1, 5, &"courier_delivered", "Ugarit", "Danel",
		{"entries": "1", "house": "House Test"}))
	c.record(ChronicleEvent.make(1, 5, &"leg_rumoured", "Ugarit", "Danel", {"leg": "1"}))
	var r: SeasonRecord = Measurement.of_chronicle(c, 7).records[0]
	assert_str(r.outcome).is_equal("stranded")
	assert_bool(r.courier_sent).is_true()
	assert_bool(r.courier_delivered).is_true()
	assert_int(r.entries_written).is_equal(2)
	assert_int(r.entries_merged).is_equal(1)
	assert_int(r.entries_lost()).is_equal(1)
	assert_int(r.surveys_lost()).is_equal(1)
	assert_int(r.legs_rumoured_end).is_equal(1)
	assert_int(r.legs_sealed_end).is_equal(0)


func test_a_season_inherits_the_one_before_it() -> void:
	var c := _synthetic_season()
	c.record(ChronicleEvent.make(2, 0, &"succession", "Ugarit", "Yabninu",
		{"predecessor": "Danel", "house": "House Test"}))
	c.record(ChronicleEvent.make(2, 0, &"commissioned", "Ugarit", "Yabninu",
		{"patron": "House Yabninu", "advance": "30"}))
	var m := Measurement.of_chronicle(c, 7)
	assert_int(m.records.size()).is_equal(2)
	var second: SeasonRecord = m.records[1]
	assert_int(second.legs_sealed_start).is_equal(1)
	assert_int(second.legs_known_start()).is_equal(1)
	assert_int(second.archive_start).is_equal(1)
	assert_int(second.treasury_start).is_equal(4)
	assert_int(m.legs_inherited_at_second_season()).is_equal(1)


# --- A leg documented under seal must say so on the log -------------------

func test_the_three_ways_a_leg_enters_the_archive_each_leave_a_mark() -> void:
	var route := Route.load_from_file("res://data/routes/tin_road_slice.json")
	var naming := Naming.load_from_file("res://data/names/scribes.json")
	var house := House.new("House Test", 1, route, naming)
	var season := house.start_season()
	season.begin()
	season.max_leg_reached = 3
	# Sealed and fresh: the House now knows leg 1.
	assert_bool(season.write_entry(Ledger.EntryType.SURVEY, "leg one", 1, true)).is_true()
	# Unsealed and fresh: leg 2 enters as hearsay.
	assert_bool(season.write_entry(Ledger.EntryType.SURVEY, "leg two", 2, false)).is_true()
	season.result = Season.Result.RETURNED
	house.merge(season)
	assert_int(house.chronicle.count_of(&"leg_surveyed")).is_equal(1)
	assert_int(house.chronicle.count_of(&"leg_rumoured")).is_equal(1)
	assert_int(house.chronicle.count_of(&"rumour_confirmed")).is_equal(0)
	# A later sealed survey settles the rumour, and says which of the three
	# things happened — the archive's state is readable from the log alone.
	var next_season := house.start_season()
	next_season.begin()
	next_season.max_leg_reached = 3
	assert_bool(next_season.write_entry(Ledger.EntryType.SURVEY, "leg two again", 2, true)).is_true()
	next_season.result = Season.Result.RETURNED
	house.merge(next_season)
	assert_int(house.chronicle.count_of(&"rumour_confirmed")).is_equal(1)
	assert_int(house.chronicle.count_of(&"leg_surveyed")).is_equal(1)
	var m := Measurement.of_chronicle(house.chronicle, 1)
	var second: SeasonRecord = m.records[1]
	assert_int(second.legs_sealed_end).is_equal(2)
	assert_int(second.legs_rumoured_end).is_equal(0)


func test_renderer_has_words_for_a_sealed_leg() -> void:
	var route := Route.load_from_file("res://data/routes/tin_road_slice.json")
	var naming := Naming.load_from_file("res://data/names/scribes.json")
	var house := House.new("House Test", 1, route, naming)
	var renderer := ChronicleRenderer.load_default(SimRng.new(7).stream(&"prose"))
	var ev := ChronicleEvent.make(1, 11, &"leg_surveyed", "Ugarit", "Danel", {"leg": "2"})
	assert_str(renderer.render_event(ev, house)).not_contains("no words yet for")


func test_the_book_quotes_the_true_cost_of_writing() -> void:
	# Prose reads the same attributed spend the measurement does, so a tuning
	# change cannot leave a hardcoded number behind in the book.
	var route := Route.load_from_file("res://data/routes/tin_road_slice.json")
	var naming := Naming.load_from_file("res://data/names/scribes.json")
	var house := House.new("House Test", 1, route, naming)
	var renderer := ChronicleRenderer.load_default(SimRng.new(3).stream(&"prose"))
	var ev := ChronicleEvent.make(1, 2, &"entry_written", "the Salt Marsh", "Danel",
		{"entry_type": "survey", "subject": "the road", "leg": "1", "sealed": "yes",
			"light_writing": str(Ledger.daylight_cost(Ledger.EntryType.SURVEY))})
	var seen := false
	for _i: int in range(12):
		var line := renderer.render_event(ev, house)
		assert_str(line).not_contains("{")
		if line.contains("%d days" % Ledger.daylight_cost(Ledger.EntryType.SURVEY)):
			seen = true
	assert_bool(seen)\
		.override_failure_message("no entry_written variant quoted the survey's real cost")\
		.is_true()


# --- The five signals -----------------------------------------------------

func test_the_pass_reports_all_five_signals_over_several_seeds() -> void:
	var runs := _runs()
	assert_int(runs.size()).is_greater_equal(2)
	var signals := Measurement.signals(runs, Measurement.load_bands())
	for id: String in ["daylight_split", "route_surveyed", "first_automated_return",
			"courier_use", "season_two_delta"]:
		assert_bool(signals.has(id))\
			.override_failure_message("signal %s missing from the pass" % id).is_true()
		var s := signals[id] as Dictionary
		assert_str(str(s["verdict"])).is_not_empty()
		assert_str(str(s["title"])).is_not_empty()


func test_the_reaction_signal_refuses_to_be_a_number() -> void:
	# "Watch faces, not surveys." The pass may point at the moment; it may not
	# score it, and no proxy metric is allowed to stand in for it.
	var signals := Measurement.signals(_runs(), Measurement.load_bands())
	var s := signals["first_automated_return"] as Dictionary
	assert_bool(bool(s["measurable"])).is_false()
	assert_str(str(s["verdict"])).is_equal("NOT MEASURED")


func test_verdicts_track_the_bands() -> void:
	var bands := Measurement.load_bands()
	var courier := bands["courier_use"] as Dictionary
	assert_bool(courier.has("low")).is_true()
	assert_bool(courier.has("high")).is_true()
	# A pass in which no courier is ever sent scores zero, and zero is outside
	# any healthy band for a mechanic the slice exists partly to calibrate.
	var never := Measurement.of_chronicle(_synthetic_season(), 7)
	var runs: Array[Measurement] = [never]
	var signals := Measurement.signals(runs, bands)
	var s := signals["courier_use"] as Dictionary
	assert_float(float(s["value"])).is_equal_approx(0.0, 0.001)
	assert_str(str(s["verdict"])).is_equal("WATCH")


func test_an_absence_is_reported_as_an_absence() -> void:
	# A signal computed over nothing that happened is not a finding. The pass
	# has to say which mechanics it never touched, or its verdicts mislead.
	var runs: Array[Measurement] = [Measurement.of_chronicle(_synthetic_season(), 7)]
	var gaps := Measurement.coverage_gaps(runs)
	var joined := "\n".join(gaps)
	assert_str(joined).contains("Courier was never sent")
	assert_str(joined).contains("no standing order was posted")


func test_the_pass_is_deterministic() -> void:
	# Same seeds, same story, same numbers — a measurement that drifted would
	# be worse than none, because it would look like a tuning change landed.
	var bands := Measurement.load_bands()
	var first := MeasureReport.render(_runs(3), Measurement.signals(_runs(3), bands), 3)
	var second := MeasureReport.render(_runs(3), Measurement.signals(_runs(3), bands), 3)
	assert_str(first).is_equal(second)
	assert_str(first).contains("BOT numbers")


func test_records_survive_the_round_trip_to_json() -> void:
	# The playable layer emits these as JSON lines during a playtest; a field
	# that cannot be stringified is a field that quietly never arrives.
	var r: SeasonRecord = Measurement.of_chronicle(_synthetic_season(), 7).records[0]
	var parsed: Variant = JSON.parse_string(JSON.stringify(r.to_dict()))
	assert_bool(parsed is Dictionary).is_true()
	var d := parsed as Dictionary
	assert_int(int(d["light_writing"])).is_equal(8)
	assert_int(int(d["entries_written"])).is_equal(1)
	assert_str(str(d["outcome"])).is_equal("returned")
