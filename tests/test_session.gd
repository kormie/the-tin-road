extends GdUnitTestSuite
## The playable layer stays thin: these tests drive the session controller's
## handlers directly (no simulated clicks) and assert phase flow, the growing
## book, and that refusals are reported rather than predicted.


func _session() -> GameSession:
	var scene := load("res://game/main.tscn") as PackedScene
	var session: GameSession = scene.instantiate()
	add_child(session)
	return auto_free(session)


func test_scene_boots_to_the_title() -> void:
	var session := _session()
	assert_bool(session.title_panel.visible).is_true()
	assert_bool(session.house == null).is_true()


func test_found_and_depart_reach_the_road() -> void:
	var session := _session()
	session.seed_input.text = "1"
	session._on_found_pressed()
	assert_int(session.phase).is_equal(GameSession.Phase.OUTFIT)
	assert_bool(session.house != null).is_true()
	session._on_depart_pressed()
	assert_int(session.phase).is_equal(GameSession.Phase.ROAD)
	assert_bool(session.season != null).is_true()
	assert_bool(session.book.text.contains("Season")).is_true()


func test_travel_grows_the_book() -> void:
	var session := _session()
	session.seed_input.text = "1"
	session._on_found_pressed()
	session._on_depart_pressed()
	var length_before := session.book.text.length()
	session._on_travel_pressed()
	assert_bool(session.book.text.length() > length_before).is_true()


func test_refusals_are_reported_not_predicted() -> void:
	var session := _session()
	session.seed_input.text = "1"
	session._on_found_pressed()
	session._on_depart_pressed()
	session.season.seals = 0
	session.seal_check.button_pressed = true
	session._on_write_pressed(Ledger.EntryType.NOTE)
	assert_bool(session.refusal_label.text.is_empty()).is_false()


func test_invalid_kit_is_refused_at_the_counter() -> void:
	var session := _session()
	session.seed_input.text = "1"
	session._on_found_pressed()
	session.clay_spin.value = 8
	session.papyrus_spin.value = 16
	session._on_depart_pressed()
	assert_int(session.phase).is_equal(GameSession.Phase.OUTFIT)
	# The mapped copy, not the generic fallback — the code contract holds.
	# (Cost is checked before bulk: this kit fails as unaffordable first.)
	assert_str(session.refusal_label.text).is_equal(GameSession.OUTFIT_REFUSALS[&"too_costly"])


func test_season_end_reaches_the_desk() -> void:
	var session := _session()
	session.seed_input.text = "1"
	session._on_found_pressed()
	session._on_depart_pressed()
	session.season.result = Season.Result.RETURNED
	session._after_action()
	assert_int(session.phase).is_equal(GameSession.Phase.DESK)
	session._on_next_season_pressed()
	assert_int(session.phase).is_equal(GameSession.Phase.OUTFIT)


func test_the_desk_emits_the_season_record() -> void:
	# The playable layer produces the same record scripts/measure.gd does, so a
	# playtest and the reference pass can be read side by side. It computes
	# nothing itself — it reads the chronicle, like everything else here.
	var session := _session()
	session.seed_input.text = "1"
	session._on_found_pressed()
	session._on_depart_pressed()
	# Run the light out on a real step rather than forcing the result: the
	# record is read off the log, so an ending the sim never announced is an
	# ending the measurement is right not to see.
	session.season.daylight = 1
	session._on_travel_pressed()
	assert_int(session.phase).is_equal(GameSession.Phase.DESK)
	var expected: SeasonRecord = Measurement.of_chronicle(
		session.house.chronicle, session.house.rng.master_seed).records[0]
	assert_str(expected.outcome).is_equal("stranded")
	assert_int(expected.light_travel).is_equal(Season.TRAVEL_COST)
	assert_str(session.desk_label.text).contains(expected.headline())


func test_incremental_rendering_matches_the_whole_book() -> void:
	# Prose variants draw in event order, so a book grown in two pulls must
	# equal the same book rendered in one.
	var whole_result: Dictionary = DemoRunner.run(7, 2)
	var whole_house: House = whole_result["house"]
	var reference := ChronicleRenderer.load_default(SimRng.new(7).stream(&"prose"))
	var one_pull := reference.render_events(whole_house, 0)
	var split := ChronicleRenderer.load_default(SimRng.new(7).stream(&"prose"))
	@warning_ignore("integer_division")
	var midpoint := whole_house.chronicle.events.size() / 2
	var part_one := split.render_events(whole_house, 0, midpoint)
	var part_two := split.render_events(whole_house, midpoint)
	assert_str(part_one + part_two).is_equal(one_pull)
