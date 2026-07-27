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


func test_a_refusal_names_the_one_reason_that_is_true() -> void:
	# The first playtest could not tell an empty pack from a missing seal,
	# because the refusal listed every condition at once and named none of
	# them. A refusal reports the code the sim gave, and only that code.
	var session := _session()
	session.seed_input.text = "1"
	session._on_found_pressed()
	session._on_depart_pressed()
	session.season.clay = 0
	session.season.papyrus = 0
	session._on_courier_pressed()
	# Nothing written yet: that is the true reason, ahead of the empty pack.
	assert_str(session.refusal_label.text).is_equal(
		GameSession.COURIER_REFUSALS[&"nothing_written"])
	session.season.clay = 4
	session.season.papyrus = 0
	session._on_write_pressed(Ledger.EntryType.NOTE)
	session.season.clay = 0
	session._on_courier_pressed()
	# Now something is written and the pack is empty — the pack is the reason,
	# and the seals in the pack are not mentioned at all.
	assert_bool(session.season.seals > 0).is_true()
	assert_str(session.refusal_label.text).contains("copy needs")
	assert_str(session.refusal_label.text).not_contains("seal")


func test_the_road_panel_quotes_costs_from_the_ledger() -> void:
	# A price typed into the scene is a price that rots. Every cost on a
	# writing button is read off Ledger at load.
	var session := _session()
	var button: Button = session.get_node("%SurveyButton")
	assert_str(button.text).contains(str(Ledger.daylight_cost(Ledger.EntryType.SURVEY)))
	assert_str(button.text).contains(str(Ledger.media_cost(Ledger.EntryType.SURVEY)))


func test_the_outfit_step_shows_what_was_inherited() -> void:
	# Signal 5 is whether the inheritance is legible. It cannot be legible if
	# it is not on the screen at the moment the player is deciding.
	var session := _session()
	session.seed_input.text = "1"
	session._on_found_pressed()
	assert_str(session.inherit_label.text).contains("first scribe")
	session._on_depart_pressed()
	session.season.write_entry(Ledger.EntryType.NOTE, "a first note")
	session.season.result = Season.Result.RETURNED
	session._after_action()
	session._on_next_season_pressed()
	assert_str(session.inherit_label.text).contains("1 entry in the archive")
	assert_str(session.inherit_label.text).contains(session.route.display_name)


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
	# The instrument stays on the panel for whoever is running the session —
	# but under a summary written for whoever is playing (playtest-script.md).
	assert_str(session.facilitator_label.text).contains(expected.headline())
	assert_str(session.desk_label.text).contains("the light ran out")
	assert_str(session.desk_label.text).not_contains(expected.headline())


## Post a standing order the way a player does: a season closed at the desk, the
## road documented, the treasury able to cover it.
func _desk_with_a_posted_order(session: GameSession) -> void:
	session.seed_input.text = "1"
	session._on_found_pressed()
	session._on_depart_pressed()
	session.season.result = Season.Result.RETURNED
	session._after_action()
	for leg: int in range(1, session.route.leg_count() + 1):
		session.house.surveyed_legs.append(leg)
	session.house.silver = House.STANDING_ORDER_COST + 200
	session._on_post_order_pressed()


func test_the_desk_says_when_the_caravan_first_runs() -> void:
	# Session 02, encoded: the order was posted and the app was closed, because
	# nothing said the caravan had not run yet. The desk says so now, and the
	# button a leaving player presses says it too.
	var session := _session()
	_desk_with_a_posted_order(session)
	assert_bool(session.refusal_label.text.is_empty()).is_true()
	assert_bool(session.house.has_standing_order()).is_true()
	assert_str(session.holdings_label.text).contains(
		GameSession.ORDER_RECEIPT % session.route.display_name)
	assert_str(session.next_season_button.text).is_equal(
		GameSession.NEXT_SEASON_LABEL_PENDING)


func test_the_desk_says_nothing_of_caravans_before_an_order() -> void:
	# The signal 2 guard (docs/design/playtest-script.md §2). Whether a player
	# finds the automation goal unprompted is a measurement, and a word about
	# caravans on a desk they reach in season one would end it. Every string
	# added for the receipt is gated on an order that already exists.
	var session := _session()
	session.seed_input.text = "1"
	session._on_found_pressed()
	session._on_depart_pressed()
	session.season.result = Season.Result.RETURNED
	session._after_action()
	assert_bool(session.house.has_standing_order()).is_false()
	assert_str(session.holdings_label.text.to_lower()).not_contains("caravan")
	assert_str(session.desk_label.text.to_lower()).not_contains("caravan")
	assert_str(session.next_season_button.text).is_equal(GameSession.NEXT_SEASON_LABEL)


func test_the_receipt_names_a_time_and_never_a_sum() -> void:
	# The signal 3 guard (docs/design/playtest-script.md §3, measurement.md).
	# The receipt is affordable only because it names WHEN, not WHAT: §3 scores
	# a reaction to an unknown quantity arriving at a known time. A figure here
	# would quietly re-scope that signal from surprise to confirmation.
	var forbidden: Array[String] = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
		"shekel", "silver", "income", "profit", "pay"]
	for copy: String in [GameSession.ORDER_RECEIPT, GameSession.NEXT_SEASON_LABEL,
			GameSession.NEXT_SEASON_LABEL_PENDING]:
		for word: String in forbidden:
			assert_str(copy.to_lower()).not_contains(word)


func test_the_caravan_comes_home_at_depart_and_the_desk_stops_saying_not_yet() -> void:
	# The copy's timing claim, made executable. "Begin the next season" only
	# opens the outfitting; the caravan runs inside House.start_season(), which
	# the UI calls at Depart. If that ever moves, this fails rather than turning
	# the receipt into a lie — and once the caravan HAS run, the desk stops
	# saying it has not.
	var session := _session()
	_desk_with_a_posted_order(session)
	session._on_next_season_pressed()
	assert_int(session.house.chronicle.count_of(&"caravan_returned")).is_equal(0)
	session._on_depart_pressed()
	assert_int(session.house.chronicle.count_of(&"caravan_returned")).is_equal(1)
	session.season.result = Season.Result.RETURNED
	session._after_action()
	assert_str(session.holdings_label.text).not_contains("has not run yet")
	assert_str(session.next_season_button.text).is_equal(GameSession.NEXT_SEASON_LABEL)


func test_the_glossary_never_names_the_caravan() -> void:
	# The glossary describes controls, never goals — its header says so, and
	# nothing enforced it until now. Keys beginning with "_" are that header,
	# which discusses the boundary and so may use the words the copy may not.
	var parsed: Variant = JSON.parse_string(
		FileAccess.get_file_as_string("res://data/ui/glossary.json"))
	assert_bool(parsed is Dictionary).is_true()
	var glossary := parsed as Dictionary
	assert_bool(glossary.size() > 1).is_true()
	for key: Variant in glossary:
		if str(key).begins_with("_"):
			continue
		var value := str(glossary[key]).to_lower()
		assert_str(value).not_contains("caravan")
		assert_str(value).not_contains("standing order")
		assert_str(value).not_contains("automat")


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
