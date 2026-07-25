extends GdUnitTestSuite
## The Courier: snapshot dispatch, and what the archive keeps when the road
## wins. Merge semantics are tested by forcing Season.result directly — the
## road's own randomness is exercised elsewhere.


func _fixture() -> Dictionary:
	var route := Route.load_from_file("res://data/routes/tin_road_slice.json")
	var naming := Naming.load_from_file("res://data/names/scribes.json")
	var house := House.new("House Test", 1, route, naming)
	var season := house.start_season()
	season.begin()
	return {"route": route, "house": house, "season": season}


func test_courier_spends_seal_and_media() -> void:
	var f := _fixture()
	var season: Season = f["season"]
	var house: House = f["house"]
	assert_bool(season.write_entry(Ledger.EntryType.NOTE, "a fact worth saving")).is_true()
	var media_before := season.media_total()
	assert_bool(season.send_courier()).is_true()
	assert_int(season.seals).is_equal(Season.STARTING_SEALS - 1)
	assert_int(season.media_total()).is_equal(media_before - Season.COURIER_MEDIA_COST)
	assert_int(season.sent_entries.size()).is_equal(1)
	assert_int(house.chronicle.count_of(&"courier_sent")).is_equal(1)


func test_courier_gates() -> void:
	var f := _fixture()
	var season: Season = f["season"]
	var house: House = f["house"]
	# Nothing written yet: nothing to send.
	assert_bool(season.send_courier()).is_false()
	assert_bool(season.write_entry(Ledger.EntryType.NOTE, "a fact")).is_true()
	# No seal, no courier.
	season.seals = 0
	assert_bool(season.send_courier()).is_false()
	season.seals = 1
	# Not enough media for the copy.
	var clay_before := season.clay
	var papyrus_before := season.papyrus
	season.clay = 0
	season.papyrus = Season.COURIER_MEDIA_COST - 1
	assert_bool(season.send_courier()).is_false()
	season.clay = clay_before
	season.papyrus = papyrus_before
	# The dead dispatch nothing.
	season.result = Season.Result.FELL
	assert_bool(season.send_courier()).is_false()
	assert_int(season.seals).is_equal(1)
	assert_int(house.chronicle.count_of(&"courier_sent")).is_equal(0)


func test_partial_merge_on_death_preserves_snapshot_only() -> void:
	var f := _fixture()
	var season: Season = f["season"]
	var house: House = f["house"]
	assert_bool(season.write_entry(Ledger.EntryType.NOTE, "sent ahead")).is_true()
	assert_bool(season.send_courier()).is_true()
	assert_bool(season.write_entry(Ledger.EntryType.NOTE, "died with the scribe")).is_true()
	season.result = Season.Result.FELL
	house.merge(season)
	assert_int(house.archive.size()).is_equal(1)
	assert_str(str(house.archive[0]["subject"])).is_equal("sent ahead")
	assert_int(house.chronicle.count_of(&"courier_delivered")).is_equal(1)
	assert_int(house.chronicle.count_of(&"ledger_merged")).is_equal(0)


func test_return_does_not_double_merge() -> void:
	var f := _fixture()
	var season: Season = f["season"]
	var house: House = f["house"]
	assert_bool(season.write_entry(Ledger.EntryType.NOTE, "first")).is_true()
	assert_bool(season.send_courier()).is_true()
	assert_bool(season.write_entry(Ledger.EntryType.NOTE, "second")).is_true()
	season.result = Season.Result.RETURNED
	house.merge(season)
	assert_int(house.archive.size()).is_equal(2)
	assert_int(house.chronicle.count_of(&"ledger_merged")).is_equal(1)
	assert_int(house.chronicle.count_of(&"courier_delivered")).is_equal(0)


func test_second_send_replaces_the_first_snapshot() -> void:
	var f := _fixture()
	var season: Season = f["season"]
	var house: House = f["house"]
	assert_bool(season.write_entry(Ledger.EntryType.NOTE, "first")).is_true()
	assert_bool(season.send_courier()).is_true()
	assert_bool(season.write_entry(Ledger.EntryType.NOTE, "second")).is_true()
	assert_bool(season.send_courier()).is_true()
	assert_int(season.seals).is_equal(Season.STARTING_SEALS - 2)
	assert_int(season.sent_entries.size()).is_equal(2)
	season.result = Season.Result.FELL
	house.merge(season)
	assert_int(house.archive.size()).is_equal(2)
	assert_int(house.chronicle.count_of(&"courier_delivered")).is_equal(1)


func test_unresolved_season_never_partial_merges() -> void:
	var f := _fixture()
	var season: Season = f["season"]
	var house: House = f["house"]
	assert_bool(season.write_entry(Ledger.EntryType.NOTE, "in flight")).is_true()
	assert_bool(season.send_courier()).is_true()
	house.merge(season)
	assert_int(house.archive.size()).is_equal(0)
	assert_int(house.chronicle.count_of(&"courier_delivered")).is_equal(0)


func test_dead_scribes_courier_completes_route_and_pays_the_successor() -> void:
	var f := _fixture()
	var season: Season = f["season"]
	var house: House = f["house"]
	house.surveyed_legs.append(1)
	house.surveyed_legs.append(2)
	season.max_leg_reached = 3
	assert_bool(season.write_entry(Ledger.EntryType.SURVEY, "the last leg", 3)).is_true()
	assert_bool(season.send_courier()).is_true()
	season.result = Season.Result.FELL
	house.merge(season)
	assert_bool(house.surveyed_legs.has(3)).is_true()
	assert_bool(house.route_documented()).is_true()
	assert_int(house.chronicle.count_of(&"route_documented")).is_equal(1)
	house.start_season()
	assert_int(house.chronicle.count_of(&"succession")).is_equal(1)
	assert_int(house.chronicle.count_of(&"caravan_returned")).is_equal(1)
	assert_bool(house.silver > 0).is_true()


func test_stranded_courier_also_delivers() -> void:
	var f := _fixture()
	var season: Season = f["season"]
	var house: House = f["house"]
	assert_bool(season.write_entry(Ledger.EntryType.NOTE, "sent ahead")).is_true()
	assert_bool(season.send_courier()).is_true()
	season.result = Season.Result.STRANDED
	house.merge(season)
	assert_int(house.archive.size()).is_equal(1)
	assert_int(house.chronicle.count_of(&"courier_delivered")).is_equal(1)


func test_returned_survey_still_documents_route() -> void:
	var f := _fixture()
	var season: Season = f["season"]
	var house: House = f["house"]
	house.surveyed_legs.append(1)
	house.surveyed_legs.append(2)
	season.max_leg_reached = 3
	assert_bool(season.write_entry(Ledger.EntryType.SURVEY, "the last leg", 3)).is_true()
	season.result = Season.Result.RETURNED
	house.merge(season)
	assert_bool(house.surveyed_legs.has(3)).is_true()
	assert_bool(house.route_documented()).is_true()
	assert_int(house.chronicle.count_of(&"route_documented")).is_equal(1)
	assert_int(house.chronicle.count_of(&"ledger_merged")).is_equal(1)


func test_renderer_has_words_for_courier_events() -> void:
	var f := _fixture()
	var house: House = f["house"]
	var rng := SimRng.new(7)
	var renderer := ChronicleRenderer.load_default(rng.stream(&"prose"))
	var sent := ChronicleEvent.make(1, 9, &"courier_sent", "Alashiya", "Danel",
		{"entries": "2", "media": "4"})
	var delivered := ChronicleEvent.make(1, 12, &"courier_delivered", "Ugarit", "Danel",
		{"entries": "2", "house": "House Test"})
	assert_bool(renderer.render_event(sent, house).contains("no words yet for")).is_false()
	assert_bool(renderer.render_event(delivered, house).contains("no words yet for")).is_false()
