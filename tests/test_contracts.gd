extends GdUnitTestSuite
## Standing contracts: signed at settlements, ticking income per leg, and —
## the half that matters — callable at the worst moment. Call-in arithmetic
## is pinned by invoking _resolve_call_ins directly (state forced, road not
## rolled, per the test_courier convention); the road wiring is covered by
## the pinned-seed demo reachability test.


func _fixture() -> Dictionary:
	var route := Route.load_from_file("res://data/routes/tin_road_slice.json")
	var naming := Naming.load_from_file("res://data/names/scribes.json")
	var catalog := ContractCatalog.load_from_file("res://data/contracts/slice_contracts.json")
	var house := House.new("House Test", 1, route, naming)
	var season := house.start_season()
	season.begin()
	return {"route": route, "house": house, "season": season, "catalog": catalog}


func test_sign_at_settlement_only() -> void:
	var f := _fixture()
	var season: Season = f["season"]
	var house: House = f["house"]
	var catalog: ContractCatalog = f["catalog"]
	var media_before := season.media_total()
	assert_bool(season.sign_contract(catalog.by_id("urtenu_consignment"))).is_true()
	assert_int(house.chronicle.count_of(&"contract_signed")).is_equal(1)
	assert_int(season.media_total()).is_equal(media_before - Season.CONTRACT_MEDIA_COST)
	season.position = 1
	assert_bool(season.sign_contract(catalog.by_id("storm_pledge"))).is_false()
	season.position = 5
	assert_bool(season.sign_contract(catalog.by_id("storm_pledge"))).is_false()
	season.position = 0
	assert_bool(season.sign_contract(catalog.by_id("urtenu_consignment"))).is_false()
	assert_int(season.contracts.size()).is_equal(1)
	assert_int(season.media_total()).is_equal(media_before - Season.CONTRACT_MEDIA_COST)


func test_income_ticks_per_leg_into_purse() -> void:
	var f := _fixture()
	var season: Season = f["season"]
	var catalog: ContractCatalog = f["catalog"]
	assert_bool(season.sign_contract(catalog.by_id("urtenu_consignment"))).is_true()
	season.travel_next()
	if season.is_over():
		return  # The road can kill; that path is exercised elsewhere.
	assert_int(season.silver).is_equal(catalog.by_id("urtenu_consignment").income_per_leg)


func test_call_in_honoured_when_purse_covers() -> void:
	var f := _fixture()
	var season: Season = f["season"]
	var house: House = f["house"]
	var catalog: ContractCatalog = f["catalog"]
	assert_bool(season.sign_contract(catalog.by_id("urtenu_consignment"))).is_true()
	season.silver = 12
	season._resolve_call_ins(&"shaken_down")
	assert_int(season.silver).is_equal(0)
	assert_int(season.contracts.size()).is_equal(1)
	assert_int(house.chronicle.count_of(&"contract_called")).is_equal(1)
	assert_int(house.chronicle.count_of(&"contract_honoured")).is_equal(1)


func test_call_in_default_voids_and_costs_media() -> void:
	var f := _fixture()
	var season: Season = f["season"]
	var house: House = f["house"]
	var catalog: ContractCatalog = f["catalog"]
	assert_bool(season.sign_contract(catalog.by_id("urtenu_consignment"))).is_true()
	season.silver = 5  # Short of the twelve-shekel demand.
	var media_before := season.media_total()
	season._resolve_call_ins(&"shaken_down")
	assert_int(house.chronicle.count_of(&"contract_defaulted")).is_equal(1)
	assert_int(season.silver).is_equal(0)
	assert_int(season.media_total()).is_equal(media_before - 2)
	assert_bool(season.contracts.is_empty()).is_true()
	season._resolve_call_ins(&"shaken_down")
	assert_int(house.chronicle.count_of(&"contract_defaulted")).is_equal(1)
	assert_bool(season.sign_contract(catalog.by_id("urtenu_consignment"))).is_false()


func test_protection_shifts_the_same_fate_draw() -> void:
	# Seed 2's first fate draw is ~0.1965: fatal at the default 0.35
	# threshold, survivable under the storm pledge's 0.15. Same single draw.
	var route := Route.load_from_file("res://data/routes/tin_road_slice.json")
	var naming := Naming.load_from_file("res://data/names/scribes.json")
	var catalog := ContractCatalog.load_from_file("res://data/contracts/slice_contracts.json")
	var hazard: Route.RouteNode = route.nodes[1]
	var doomed_house := House.new("House Doomed", 2, route, naming)
	var doomed := doomed_house.start_season()
	doomed.begin()
	doomed.position = 1
	doomed._peril(hazard)
	assert_int(doomed.result).is_equal(Season.Result.FELL)
	var pledged_house := House.new("House Pledged", 2, route, naming)
	var pledged := pledged_house.start_season()
	pledged.begin()
	pledged.contracts.append(catalog.by_id("storm_pledge"))
	pledged.position = 1
	pledged._peril(hazard)
	assert_bool(pledged.is_over()).is_false()
	assert_int(pledged_house.chronicle.count_of(&"peril_survived")).is_equal(1)


func test_daylight_call_in_can_strand() -> void:
	var f := _fixture()
	var season: Season = f["season"]
	var house: House = f["house"]
	var catalog: ContractCatalog = f["catalog"]
	season.contracts.append(catalog.by_id("storm_pledge"))
	season.position = 1
	season.daylight = 2
	season._resolve_call_ins(&"peril_survived")
	assert_int(season.result).is_equal(Season.Result.STRANDED)
	assert_int(house.chronicle.count_of(&"contract_called")).is_equal(1)
	assert_int(house.chronicle.count_of(&"contract_honoured")).is_equal(0)
	var called_at := -1
	var stranded_at := -1
	for i: int in range(house.chronicle.events.size()):
		var ev: ChronicleEvent = house.chronicle.events[i]
		if ev.type == &"contract_called":
			called_at = i
		if ev.type == &"stranded":
			stranded_at = i
	assert_bool(called_at >= 0 and stranded_at > called_at).is_true()


func test_seal_access_gates_buy_seal() -> void:
	var f := _fixture()
	var season: Season = f["season"]
	var house: House = f["house"]
	var catalog: ContractCatalog = f["catalog"]
	season.clay = 2
	season.silver = Season.SEAL_ROAD_PRICE
	season.position = 5
	assert_bool(season.buy_seal()).is_false()
	season.position = 0
	assert_bool(season.sign_contract(catalog.by_id("sojourners_right"))).is_true()
	season.position = 5
	assert_bool(season.buy_seal()).is_true()
	assert_int(season.silver).is_equal(0)
	assert_int(season.seals).is_equal(Outfit.DEFAULT_SEALS + 1)
	assert_int(house.chronicle.count_of(&"seal_bought")).is_equal(1)
	season.silver = Season.SEAL_ROAD_PRICE
	season.clay = 4
	season.papyrus = 6
	assert_bool(season.buy_seal()).is_false()
	season.clay = 2
	season.position = 0
	assert_bool(season.buy_seal()).is_false()


func test_turned_home_call_in_voids_access_when_unpaid() -> void:
	var f := _fixture()
	var season: Season = f["season"]
	var house: House = f["house"]
	var catalog: ContractCatalog = f["catalog"]
	assert_bool(season.sign_contract(catalog.by_id("sojourners_right"))).is_true()
	season.silver = 0
	season.position = 5
	season._resolve_call_ins(&"turned_home")
	assert_int(house.chronicle.count_of(&"contract_defaulted")).is_equal(1)
	assert_bool(season.contracts.is_empty()).is_true()
	season.clay = 2
	season.silver = Season.SEAL_ROAD_PRICE
	assert_bool(season.buy_seal()).is_false()


func test_purse_banks_on_return_and_dies_on_the_road() -> void:
	var f := _fixture()
	var season: Season = f["season"]
	var house: House = f["house"]
	var silver_before := house.silver
	season.silver = 9
	season.result = Season.Result.RETURNED
	house.merge(season)
	assert_int(house.silver).is_equal(silver_before + 9)
	assert_int(season.silver).is_equal(0)
	assert_int(house.chronicle.count_of(&"purse_banked")).is_equal(1)
	var g := _fixture()
	var fell_season: Season = g["season"]
	var fell_house: House = g["house"]
	var fell_before := fell_house.silver
	fell_season.silver = 9
	assert_bool(fell_season.write_entry(Ledger.EntryType.NOTE, "sent ahead")).is_true()
	assert_bool(fell_season.send_courier()).is_true()
	fell_season.result = Season.Result.FELL
	fell_house.merge(fell_season)
	assert_int(fell_house.silver).is_equal(fell_before)
	assert_int(fell_house.chronicle.count_of(&"purse_banked")).is_equal(0)
	var h := _fixture()
	var stranded_season: Season = h["season"]
	var stranded_house: House = h["house"]
	var stranded_before := stranded_house.silver
	stranded_season.silver = 9
	stranded_season.result = Season.Result.STRANDED
	stranded_house.merge(stranded_season)
	assert_int(stranded_house.silver).is_equal(stranded_before)
	assert_int(stranded_house.chronicle.count_of(&"purse_banked")).is_equal(0)


func test_turn_for_home_ticks_income_before_dues() -> void:
	# Arriving at Alashiya draws nothing (settlement), so this is fully
	# deterministic: the leg's income must land before the turn-home dues
	# are called, and the turn must be written before the call.
	var f := _fixture()
	var season: Season = f["season"]
	var house: House = f["house"]
	var catalog: ContractCatalog = f["catalog"]
	assert_bool(season.sign_contract(catalog.by_id("urtenu_consignment"))).is_true()
	assert_bool(season.sign_contract(catalog.by_id("sojourners_right"))).is_true()
	season.position = 4
	season.silver = 2
	season.travel_next()
	assert_int(season.position).is_equal(5)
	assert_int(house.chronicle.count_of(&"contract_honoured")).is_equal(1)
	assert_int(house.chronicle.count_of(&"contract_defaulted")).is_equal(0)
	assert_int(season.silver).is_equal(0)
	var turned_at := -1
	var called_at := -1
	for i: int in range(house.chronicle.events.size()):
		var ev: ChronicleEvent = house.chronicle.events[i]
		if ev.type == &"turned_home":
			turned_at = i
		if ev.type == &"contract_called" and called_at < 0:
			called_at = i
	assert_bool(turned_at >= 0).is_true()
	assert_bool(called_at > turned_at).is_true()


func test_demo_reaches_the_contract_pipeline() -> void:
	var result: Dictionary = DemoRunner.run(1259, 6)
	var house: House = result["house"]
	assert_bool(house.chronicle.count_of(&"contract_signed") >= 1).is_true()
	assert_bool(house.chronicle.count_of(&"contract_called") >= 1).is_true()
	assert_bool(house.chronicle.count_of(&"contract_honoured") >= 1).is_true()
	assert_bool(house.chronicle.count_of(&"contract_defaulted") >= 1).is_true()
	assert_bool(house.chronicle.count_of(&"seal_bought") >= 1).is_true()
	assert_bool(house.chronicle.count_of(&"purse_banked") >= 1).is_true()


func test_renderer_has_words_for_contract_events() -> void:
	var f := _fixture()
	var house: House = f["house"]
	var rng := SimRng.new(7)
	var renderer := ChronicleRenderer.load_default(rng.stream(&"prose"))
	var events: Array[ChronicleEvent] = [
		ChronicleEvent.make(1, 1, &"contract_signed", "Ugarit", "Danel",
			{"holder": "House Urtenu", "contract": "the Urtenu consignment", "terms": "carriage silver every leg"}),
		ChronicleEvent.make(1, 4, &"contract_called", "the Rival Sail", "Danel",
			{"holder": "House Urtenu", "contract": "the Urtenu consignment", "demand": "twelve shekels, weighed"}),
		ChronicleEvent.make(1, 4, &"contract_honoured", "the Rival Sail", "Danel",
			{"holder": "House Urtenu", "contract": "the Urtenu consignment", "demand": "twelve shekels, weighed"}),
		ChronicleEvent.make(1, 4, &"contract_defaulted", "the Rival Sail", "Danel",
			{"holder": "House Urtenu", "contract": "the Urtenu consignment", "penalty": "two of media, seized"}),
		ChronicleEvent.make(1, 6, &"seal_bought", "Alashiya", "Danel", {"price": "5"}),
		ChronicleEvent.make(1, 12, &"purse_banked", "Ugarit", "Danel", {"silver": "14"}),
	]
	for ev: ChronicleEvent in events:
		assert_bool(renderer.render_event(ev, house).contains("no words yet for")).is_false()
