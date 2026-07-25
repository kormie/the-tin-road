extends GdUnitTestSuite
## Seals authenticate. What merges without one is a rumour: it still counts
## toward documentation, but the caravan pays it at half until a sealed
## survey confirms it. Merge semantics force Season.result directly, per the
## test_courier convention.


func _fixture() -> Dictionary:
	var route := Route.load_from_file("res://data/routes/tin_road_slice.json")
	var naming := Naming.load_from_file("res://data/names/scribes.json")
	var house := House.new("House Test", 1, route, naming)
	var season := house.start_season()
	season.begin()
	return {"route": route, "house": house, "season": season}


func _income_of(house: House) -> int:
	for ev: ChronicleEvent in house.chronicle.events:
		if ev.type == &"caravan_returned":
			return int(str(ev.data["income"]))
	return -1


func test_sealed_write_spends_seal_and_marks_entry() -> void:
	var f := _fixture()
	var season: Season = f["season"]
	assert_bool(season.write_entry(Ledger.EntryType.NOTE, "a vouched fact", -1, true)).is_true()
	assert_int(season.seals).is_equal(Outfit.DEFAULT_SEALS - 1)
	assert_bool(bool(season.entries[0]["sealed"])).is_true()


func test_seal_request_refused_with_empty_pouch() -> void:
	var f := _fixture()
	var season: Season = f["season"]
	season.seals = 0
	var daylight_before := season.daylight
	var media_before := season.media_total()
	assert_bool(season.write_entry(Ledger.EntryType.NOTE, "unvouchable", -1, true)).is_false()
	assert_int(season.daylight).is_equal(daylight_before)
	assert_int(season.media_total()).is_equal(media_before)
	assert_bool(season.write_entry(Ledger.EntryType.NOTE, "hearsay then")).is_true()
	assert_bool(bool(season.entries[0]["sealed"])).is_false()


func test_unsealed_survey_merges_as_rumour() -> void:
	var f := _fixture()
	var season: Season = f["season"]
	var house: House = f["house"]
	house.surveyed_legs.append(1)
	house.surveyed_legs.append(2)
	season.max_leg_reached = 3
	assert_bool(season.write_entry(Ledger.EntryType.SURVEY, "the last leg, unvouched", 3)).is_true()
	season.result = Season.Result.RETURNED
	house.merge(season)
	assert_bool(house.rumoured_legs.has(3)).is_true()
	assert_bool(house.surveyed_legs.has(3)).is_false()
	assert_bool(house.route_documented()).is_true()
	assert_int(house.chronicle.count_of(&"leg_rumoured")).is_equal(1)
	assert_int(house.chronicle.count_of(&"route_documented")).is_equal(1)


func test_rumoured_leg_pays_half() -> void:
	var route := Route.load_from_file("res://data/routes/tin_road_slice.json")
	var naming := Naming.load_from_file("res://data/names/scribes.json")
	var sealed_house := House.new("House Sealed", 5, route, naming)
	var rumour_house := House.new("House Rumour", 5, route, naming)
	for leg: int in [1, 2, 3]:
		sealed_house.surveyed_legs.append(leg)
	rumour_house.surveyed_legs.append(1)
	rumour_house.surveyed_legs.append(2)
	rumour_house.rumoured_legs.append(3)
	sealed_house.silver = House.STANDING_ORDER_COST
	rumour_house.silver = House.STANDING_ORDER_COST
	assert_bool(sealed_house.post_standing_order()).is_true()
	assert_bool(rumour_house.post_standing_order()).is_true()
	sealed_house.start_season()
	rumour_house.start_season()
	var full := _income_of(sealed_house)
	var reduced := _income_of(rumour_house)
	assert_bool(full > 0).is_true()
	@warning_ignore("integer_division")
	assert_int(reduced).is_equal(full * 5 / 6)
	assert_bool(reduced < full).is_true()


func test_sealed_resurvey_confirms_a_rumour() -> void:
	var f := _fixture()
	var season: Season = f["season"]
	var house: House = f["house"]
	house.surveyed_legs.append(1)
	house.surveyed_legs.append(2)
	house.rumoured_legs.append(3)
	season.max_leg_reached = 3
	assert_bool(season.write_entry(Ledger.EntryType.SURVEY, "hearsay resurveyed", 3)).is_false()
	assert_bool(season.write_entry(Ledger.EntryType.SURVEY, "the last leg, vouched", 3, true)).is_true()
	season.result = Season.Result.RETURNED
	house.merge(season)
	assert_bool(house.surveyed_legs.has(3)).is_true()
	assert_bool(house.rumoured_legs.is_empty()).is_true()
	assert_int(house.chronicle.count_of(&"rumour_confirmed")).is_equal(1)
	assert_int(house.chronicle.count_of(&"route_documented")).is_equal(0)


func test_sealing_competes_with_the_courier() -> void:
	var f := _fixture()
	var season: Season = f["season"]
	season.max_leg_reached = 1
	assert_bool(season.write_entry(Ledger.EntryType.SURVEY, "leg one, vouched", 1, true)).is_true()
	assert_int(season.seals).is_equal(1)
	assert_bool(season.send_courier()).is_true()
	assert_int(season.seals).is_equal(0)
	season.clay = 4
	season.papyrus = 6
	assert_bool(season.write_entry(Ledger.EntryType.NOTE, "no seal left", -1, true)).is_false()
	assert_bool(season.send_courier()).is_false()


func test_demo_reaches_the_rumour_pipeline() -> void:
	var result: Dictionary = DemoRunner.run(1259, 6)
	var house: House = result["house"]
	assert_bool(house.chronicle.count_of(&"leg_rumoured") >= 1).is_true()
	assert_bool(house.chronicle.count_of(&"rumour_confirmed") >= 1).is_true()


func test_renderer_has_words_for_outfit_and_seal_events() -> void:
	var f := _fixture()
	var house: House = f["house"]
	var rng := SimRng.new(7)
	var renderer := ChronicleRenderer.load_default(rng.stream(&"prose"))
	var events: Array[ChronicleEvent] = [
		ChronicleEvent.make(1, 0, &"commissioned", "Ugarit", "Danel",
			{"patron": "House Yabninu", "advance": "30"}),
		ChronicleEvent.make(1, 0, &"outfitted", "Ugarit", "Danel",
			{"clay": "4", "papyrus": "6", "seals": "2", "spent": "26"}),
		ChronicleEvent.make(1, 14, &"leg_rumoured", "Ugarit", "Danel", {"leg": "3"}),
		ChronicleEvent.make(2, 14, &"rumour_confirmed", "Ugarit", "Anat",
			{"leg": "3"}),
	]
	for ev: ChronicleEvent in events:
		assert_bool(renderer.render_event(ev, house).contains("no words yet for")).is_false()
