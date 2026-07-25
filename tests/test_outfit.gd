extends GdUnitTestSuite
## The outfit step: the patron's advance in, the pack's cost out, bulk as the
## cap that makes seals compete with media for space.


func _fixture() -> Dictionary:
	var route := Route.load_from_file("res://data/routes/tin_road_slice.json")
	var naming := Naming.load_from_file("res://data/names/scribes.json")
	var house := House.new("House Test", 1, route, naming)
	return {"route": route, "house": house}


func test_default_kit_matches_the_old_spawn_state() -> void:
	var kit := Outfit.default_kit()
	assert_int(kit.clay).is_equal(4)
	assert_int(kit.papyrus).is_equal(6)
	assert_int(kit.seals).is_equal(2)
	assert_int(kit.total_cost()).is_equal(26)
	assert_int(kit.total_bulk()).is_equal(Outfit.PACK_CAPACITY)
	assert_bool(kit.total_cost() <= House.YABNINU_ADVANCE).is_true()


func test_bare_start_season_buys_the_default_kit() -> void:
	var f := _fixture()
	var house: House = f["house"]
	var season := house.start_season()
	season.begin()
	assert_int(season.clay).is_equal(Outfit.DEFAULT_CLAY)
	assert_int(season.papyrus).is_equal(Outfit.DEFAULT_PAPYRUS)
	assert_int(season.seals).is_equal(Outfit.DEFAULT_SEALS)
	assert_int(house.silver).is_equal(House.YABNINU_ADVANCE - 26)
	assert_int(house.chronicle.count_of(&"commissioned")).is_equal(1)
	assert_int(house.chronicle.count_of(&"outfitted")).is_equal(1)


func test_commission_is_narrated_before_the_outfit() -> void:
	var f := _fixture()
	var house: House = f["house"]
	house.start_season()
	var commissioned_at := -1
	var outfitted_at := -1
	for i: int in range(house.chronicle.events.size()):
		var ev: ChronicleEvent = house.chronicle.events[i]
		if ev.type == &"commissioned" and commissioned_at < 0:
			commissioned_at = i
		if ev.type == &"outfitted" and outfitted_at < 0:
			outfitted_at = i
	assert_bool(commissioned_at >= 0).is_true()
	assert_bool(outfitted_at > commissioned_at).is_true()


func test_custom_outfit_applies_and_deducts() -> void:
	var f := _fixture()
	var house: House = f["house"]
	var kit := Outfit.new(6, 2, 2)
	assert_int(kit.total_cost()).is_equal(20)
	assert_int(kit.total_bulk()).is_equal(16)
	var season := house.start_season(kit)
	assert_int(season.clay).is_equal(6)
	assert_int(season.papyrus).is_equal(2)
	assert_int(season.seals).is_equal(2)
	assert_int(house.silver).is_equal(House.YABNINU_ADVANCE - 20)


func test_overpacked_kit_falls_back_to_default() -> void:
	var f := _fixture()
	var house: House = f["house"]
	var kit := Outfit.new(4, 6, 3)
	assert_bool(kit.is_valid(1000)).is_false()
	var season := house.start_season(kit)
	assert_int(season.seals).is_equal(Outfit.DEFAULT_SEALS)
	assert_int(house.silver).is_equal(House.YABNINU_ADVANCE - 26)


func test_kit_validity_gates() -> void:
	assert_bool(Outfit.new(0, 6, 2).is_valid(10)).is_false()
	assert_bool(Outfit.new(0, 6, 2).is_valid(22)).is_true()
	assert_bool(Outfit.new(-1, 6, 2).is_valid(1000)).is_false()
	assert_bool(Outfit.new(0, 0, 3).is_valid(1000)).is_false()
