extends GdUnitTestSuite
## Assignable automation: a documented route pays nothing until the House
## posts a standing order — a sealed document in the archive. The document
## IS the assignment: erase it and the caravans stop.


func _fixture() -> Dictionary:
	var route := Route.load_from_file("res://data/routes/tin_road_slice.json")
	var naming := Naming.load_from_file("res://data/names/scribes.json")
	var house := House.new("House Test", 1, route, naming)
	return {"route": route, "house": house}


func _document_route(house: House) -> void:
	for leg: int in [1, 2, 3]:
		house.surveyed_legs.append(leg)


func test_documentation_alone_pays_nothing() -> void:
	var f := _fixture()
	var house: House = f["house"]
	_document_route(house)
	house.start_season()
	assert_int(house.chronicle.count_of(&"caravan_returned")).is_equal(0)
	assert_int(house.silver).is_equal(House.YABNINU_ADVANCE - 26)


func test_posting_gates() -> void:
	var f := _fixture()
	var house: House = f["house"]
	house.silver = House.STANDING_ORDER_COST
	assert_bool(house.post_standing_order()).is_false()  # Undocumented.
	assert_int(house.silver).is_equal(House.STANDING_ORDER_COST)  # Refusals are free.
	_document_route(house)
	house.silver = House.STANDING_ORDER_COST - 1
	assert_bool(house.post_standing_order()).is_false()  # Broke.
	assert_int(house.silver).is_equal(House.STANDING_ORDER_COST - 1)
	house.silver = House.STANDING_ORDER_COST
	assert_bool(house.post_standing_order()).is_true()
	assert_int(house.silver).is_equal(0)
	house.silver = House.STANDING_ORDER_COST
	assert_bool(house.post_standing_order()).is_false()  # Already standing.
	assert_int(house.silver).is_equal(House.STANDING_ORDER_COST)
	assert_int(house.chronicle.count_of(&"caravan_assigned")).is_equal(1)


func test_the_order_is_a_sealed_archive_document() -> void:
	var f := _fixture()
	var house: House = f["house"]
	var route: Route = f["route"]
	_document_route(house)
	house.silver = House.STANDING_ORDER_COST
	assert_bool(house.post_standing_order()).is_true()
	var found := false
	for entry: Dictionary in house.archive:
		if str(entry.get("type", "")) == "order":
			found = true
			assert_str(str(entry.get("subject", ""))).is_equal(route.display_name)
			assert_bool(bool(entry.get("sealed", false))).is_true()
	assert_bool(found).is_true()


func test_caravan_pays_income_minus_fee() -> void:
	var f := _fixture()
	var house: House = f["house"]
	_document_route(house)
	house.silver = House.STANDING_ORDER_COST
	assert_bool(house.post_standing_order()).is_true()
	house.start_season()
	assert_int(house.chronicle.count_of(&"caravan_returned")).is_equal(1)
	var income := -1
	var fee := -1
	for ev: ChronicleEvent in house.chronicle.events:
		if ev.type == &"caravan_returned":
			income = int(str(ev.data["income"]))
			fee = int(str(ev.data["fee"]))
	assert_bool(income >= House.AUTOMATED_INCOME_BASE).is_true()
	assert_int(fee).is_equal(House.CARAVAN_FEE)
	assert_int(house.silver).is_equal(income - fee + House.YABNINU_ADVANCE - 26)


func test_order_survives_succession_and_death() -> void:
	var f := _fixture()
	var house: House = f["house"]
	_document_route(house)
	house.silver = House.STANDING_ORDER_COST
	assert_bool(house.post_standing_order()).is_true()
	var first := house.start_season()
	first.result = Season.Result.FELL
	house.merge(first)
	house.start_season()
	assert_int(house.chronicle.count_of(&"caravan_assigned")).is_equal(1)
	assert_int(house.chronicle.count_of(&"caravan_returned")).is_equal(2)


func test_erasing_the_order_stops_the_caravans() -> void:
	# The assignment is the document, not a flag: what the archive loses,
	# the House loses. This is the seam archive corruption will widen.
	var f := _fixture()
	var house: House = f["house"]
	_document_route(house)
	house.silver = House.STANDING_ORDER_COST
	assert_bool(house.post_standing_order()).is_true()
	assert_bool(house.has_standing_order()).is_true()
	for i: int in range(house.archive.size()):
		if str((house.archive[i] as Dictionary).get("type", "")) == "order":
			house.archive.remove_at(i)
			break
	assert_bool(house.has_standing_order()).is_false()
	house.start_season()
	assert_int(house.chronicle.count_of(&"caravan_returned")).is_equal(0)
	# And the recovery loop: what was erased can be written again, at price.
	house.silver = House.STANDING_ORDER_COST
	assert_bool(house.post_standing_order()).is_true()
	house.start_season()
	assert_int(house.chronicle.count_of(&"caravan_returned")).is_equal(1)


func test_demo_reaches_the_automation_arc() -> void:
	# The thesis end to end: the demo documents the road, posts the order,
	# and watches caravans return. Seed 90 completes the arc by season 8.
	var result: Dictionary = DemoRunner.run(90, 8)
	var house: House = result["house"]
	assert_int(house.chronicle.count_of(&"route_documented")).is_equal(1)
	assert_int(house.chronicle.count_of(&"caravan_assigned")).is_equal(1)
	assert_bool(house.chronicle.count_of(&"caravan_returned") >= 1).is_true()


func test_renderer_has_words_for_assignment_events() -> void:
	var f := _fixture()
	var house: House = f["house"]
	var rng := SimRng.new(7)
	var renderer := ChronicleRenderer.load_default(rng.stream(&"prose"))
	var events: Array[ChronicleEvent] = [
		ChronicleEvent.make(2, 0, &"caravan_assigned", "Ugarit", "House Test",
			{"route": "the Ugarit road", "price": "100"}),
		ChronicleEvent.make(3, 0, &"caravan_returned", "Ugarit", "Anat",
			{"income": "301", "fee": "60", "route": "the Ugarit road"}),
	]
	for ev: ChronicleEvent in events:
		assert_bool(renderer.render_event(ev, house).contains("no words yet for")).is_false()
