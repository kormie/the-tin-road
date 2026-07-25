extends GdUnitTestSuite
## Media types on the road: water ruins papyrus and spares clay; a heavy
## pack pays for itself in daylight. The seed-1 fixture's first fate draw
## (~0.78) survives the default peril threshold, so water perils resolve
## deterministically here without seed-hunting.


func _fixture() -> Dictionary:
	var route := Route.load_from_file("res://data/routes/tin_road_slice.json")
	var naming := Naming.load_from_file("res://data/names/scribes.json")
	var house := House.new("House Test", 1, route, naming)
	var season := house.start_season()
	season.begin()
	return {"route": route, "house": house, "season": season}


func test_route_nodes_carry_flavor() -> void:
	var route := Route.load_from_file("res://data/routes/tin_road_slice.json")
	assert_str(route.nodes[1].flavor).is_equal("water")
	assert_str(route.nodes[3].flavor).is_equal("water")
	assert_str(route.nodes[2].flavor).is_equal("")


func test_neutral_loss_takes_papyrus_first() -> void:
	var f := _fixture()
	var season: Season = f["season"]
	season.papyrus = 1
	var lost: Dictionary = season._lose_media(2)
	assert_int(int(lost["papyrus"])).is_equal(1)
	assert_int(int(lost["clay"])).is_equal(1)
	assert_int(season.papyrus).is_equal(0)
	assert_int(season.clay).is_equal(3)


func test_water_loss_spares_clay() -> void:
	var f := _fixture()
	var season: Season = f["season"]
	season.papyrus = 1
	var lost: Dictionary = season._lose_media(2, "water")
	assert_int(int(lost["papyrus"])).is_equal(1)
	assert_int(int(lost["clay"])).is_equal(0)
	assert_int(season.clay).is_equal(4)
	var nothing: Dictionary = season._lose_media(2, "water")
	assert_int(int(nothing["papyrus"])).is_equal(0)
	assert_int(int(nothing["clay"])).is_equal(0)


func test_water_peril_soaks_all_papyrus() -> void:
	var f := _fixture()
	var season: Season = f["season"]
	var house: House = f["house"]
	var route: Route = f["route"]
	season.position = 1
	season._peril(route.nodes[1])
	assert_bool(season.is_over()).is_false()
	assert_int(house.chronicle.count_of(&"peril_survived")).is_equal(1)
	assert_int(house.chronicle.count_of(&"soaked")).is_equal(1)
	assert_int(season.papyrus).is_equal(0)
	assert_int(season.clay).is_equal(Outfit.DEFAULT_CLAY)


func test_soak_with_dry_pack_is_silent() -> void:
	var f := _fixture()
	var season: Season = f["season"]
	var house: House = f["house"]
	var route: Route = f["route"]
	season.papyrus = 0
	season.position = 1
	season._peril(route.nodes[1])
	assert_bool(season.is_over()).is_false()
	assert_int(house.chronicle.count_of(&"soaked")).is_equal(0)


func test_heavy_pack_costs_extra_daylight() -> void:
	var f := _fixture()
	var season: Season = f["season"]
	assert_int(season._carried_bulk()).is_equal(Outfit.PACK_CAPACITY)
	assert_int(season.travel_cost()).is_equal(Season.TRAVEL_COST + Season.HEAVY_PACK_SURCHARGE)
	season.papyrus = 1
	assert_int(season.travel_cost()).is_equal(Season.TRAVEL_COST)


func test_heavy_going_is_reported_once() -> void:
	var f := _fixture()
	var season: Season = f["season"]
	var house: House = f["house"]
	var daylight_before := season.daylight
	season.travel_next()
	assert_int(house.chronicle.count_of(&"heavy_going")).is_equal(1)
	if season.is_over():
		return  # The road can kill; the count above already held.
	assert_bool(season.daylight <= daylight_before - Season.TRAVEL_COST - Season.HEAVY_PACK_SURCHARGE).is_true()
	season.travel_next()
	assert_int(house.chronicle.count_of(&"heavy_going")).is_equal(1)


func test_light_kit_travels_light() -> void:
	var route := Route.load_from_file("res://data/routes/tin_road_slice.json")
	var naming := Naming.load_from_file("res://data/names/scribes.json")
	var house := House.new("House Test", 1, route, naming)
	var kit := Outfit.new(0, 10, 2)
	assert_bool(kit.is_valid(House.YABNINU_ADVANCE)).is_true()
	var season := house.start_season(kit)
	season.begin()
	assert_int(season.travel_cost()).is_equal(Season.TRAVEL_COST)
	season.travel_next()
	assert_int(house.chronicle.count_of(&"heavy_going")).is_equal(0)


func test_renderer_composes_lost_fragments() -> void:
	var f := _fixture()
	var house: House = f["house"]
	var rng := SimRng.new(7)
	var renderer := ChronicleRenderer.load_default(rng.stream(&"prose"))
	var one_sheet := renderer.render_event(ChronicleEvent.make(1, 3, &"mishap",
		"the Salt Marsh", "Danel", {"kind": "hazard", "lost_clay": "0", "lost_papyrus": "1"}), house)
	assert_bool(one_sheet.contains("papyrus")).is_true()
	assert_bool(one_sheet.contains("{lost")).is_false()
	var both := renderer.render_event(ChronicleEvent.make(1, 4, &"shaken_down",
		"the Rival Sail", "Danel", {"lost_clay": "1", "lost_papyrus": "2"}), house)
	assert_bool(both.contains("sheets of papyrus")).is_true()
	assert_bool(both.contains("clay tablet")).is_true()
	var nothing := renderer.render_event(ChronicleEvent.make(1, 5, &"mishap",
		"Open Water", "Danel", {"kind": "hazard", "lost_clay": "0", "lost_papyrus": "0"}), house)
	assert_bool(nothing.contains("nothing worth keeping")).is_true()


func test_renderer_has_words_for_media_events() -> void:
	var f := _fixture()
	var house: House = f["house"]
	var rng := SimRng.new(7)
	var renderer := ChronicleRenderer.load_default(rng.stream(&"prose"))
	var events: Array[ChronicleEvent] = [
		ChronicleEvent.make(1, 2, &"heavy_going", "the Salt Marsh", "Danel", {"cost": "1"}),
		ChronicleEvent.make(1, 5, &"soaked", "Open Water", "Danel", {"papyrus": "6"}),
	]
	for ev: ChronicleEvent in events:
		assert_bool(renderer.render_event(ev, house).contains("no words yet for")).is_false()
