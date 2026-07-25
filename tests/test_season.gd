extends GdUnitTestSuite
## The season state machine: daylight arithmetic, ledger costs, end conditions.


func _fixture() -> Dictionary:
	var route := Route.load_from_file("res://data/routes/tin_road_slice.json")
	var naming := Naming.load_from_file("res://data/names/scribes.json")
	var house := House.new("House Test", 1, route, naming)
	var season := house.start_season()
	season.begin()
	return {"route": route, "house": house, "season": season}


func test_route_loads_the_slice() -> void:
	var route := Route.load_from_file("res://data/routes/tin_road_slice.json")
	assert_int(route.nodes.size()).is_equal(6)
	assert_int(route.leg_count()).is_equal(3)
	assert_str(route.nodes[0].display_name).is_equal("Ugarit")


func test_travel_costs_daylight() -> void:
	var f := _fixture()
	var season: Season = f["season"]
	var before := season.daylight
	season.travel_next()
	assert_int(season.position).is_equal(1)
	assert_bool(season.daylight < before).is_true()


func test_note_costs_daylight_and_media() -> void:
	var f := _fixture()
	var season: Season = f["season"]
	season.travel_next()
	if season.is_over():
		return  # The road can kill; that path is exercised elsewhere.
	var daylight_before := season.daylight
	var media_before := season.media_total()
	var ok := season.write_entry(Ledger.EntryType.NOTE, "a fact")
	assert_bool(ok).is_true()
	assert_int(season.daylight).is_equal(daylight_before - Ledger.daylight_cost(Ledger.EntryType.NOTE))
	assert_int(season.media_total()).is_equal(media_before - Ledger.media_cost(Ledger.EntryType.NOTE))


func test_survey_requires_having_travelled_the_leg() -> void:
	var f := _fixture()
	var season: Season = f["season"]
	assert_bool(season.write_entry(Ledger.EntryType.SURVEY, "leg two, unseen", 2)).is_false()


func test_cannot_write_without_media() -> void:
	var f := _fixture()
	var season: Season = f["season"]
	season.clay = 0
	season.papyrus = 0
	season.travel_next()
	if season.is_over():
		return
	assert_bool(season.write_entry(Ledger.EntryType.NOTE, "unaffordable")).is_false()


func test_daylight_exhaustion_away_from_home_strands() -> void:
	var f := _fixture()
	var season: Season = f["season"]
	season.daylight = 1
	season.travel_next()
	assert_bool(season.is_over()).is_true()
	assert_int(season.result).is_equal(Season.Result.STRANDED)


func test_ledger_costs_match_systems_doc() -> void:
	assert_int(Ledger.daylight_cost(Ledger.EntryType.NOTE)).is_equal(1)
	assert_int(Ledger.daylight_cost(Ledger.EntryType.SURVEY)).is_equal(8)
	assert_int(Ledger.media_cost(Ledger.EntryType.TREATISE)).is_equal(10)
