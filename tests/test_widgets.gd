extends GdUnitTestSuite
## The drawn widgets are readers, not systems: the road strip reads Route,
## House and Season; the daylight bar reads the SeasonRecord the measurement
## already computes. These tests drive the session controller directly, the
## way tests/test_session.gd does, and assert the STATE each widget would
## draw — the drawing itself is flat primitives over exactly this state, and
## headless CI never rasterises a frame.


func _session() -> GameSession:
	var scene := load("res://game/main.tscn") as PackedScene
	var session: GameSession = scene.instantiate()
	add_child(session)
	return auto_free(session)


func test_a_fresh_house_inherits_an_unknown_road() -> void:
	# The first scribe of a House sees the whole route in contour outline:
	# nothing known, nothing at risk, and no scribe on the road yet.
	var session := _session()
	session.seed_input.text = "1"
	session._on_found_pressed()
	for leg: int in range(1, session.route.leg_count() + 1):
		assert_int(session.outfit_strip.leg_state(leg))\
			.is_equal(RoadStrip.LegState.UNKNOWN)
	assert_int(session.outfit_strip.marker_index()).is_equal(-1)
	assert_int(session.daylight_bar.spent_days()).is_equal(0)
	# With no season under way the bar's box is still the season's whole
	# budget — an empty bar, not a zero-width one.
	assert_int(session.daylight_bar.total_days()).is_equal(Season.STARTING_DAYLIGHT)


func test_a_survey_in_the_ledger_is_held_but_at_risk() -> void:
	# The courier's reason to exist, made visible: a leg written this season
	# is in the ledger and nowhere else — kiln-red on the strip until it
	# merges, while the House behind it still knows nothing.
	var session := _session()
	session.seed_input.text = "1"
	session._on_found_pressed()
	session._on_depart_pressed()
	session.season.max_leg_reached = 1
	session.season.position = 2
	assert_bool(session.season.write_entry(
		Ledger.EntryType.SURVEY, "the leg behind", 1, false)).is_true()
	session._refresh()
	assert_int(session.road_strip.leg_state(1)).is_equal(RoadStrip.LegState.IN_LEDGER)
	assert_int(session.road_strip.leg_state(2)).is_equal(RoadStrip.LegState.UNKNOWN)
	assert_bool(session.house.surveyed_legs.is_empty()).is_true()
	assert_bool(session.house.rumoured_legs.is_empty()).is_true()
	# The scribe stands where the sim says, walking outward.
	assert_int(session.road_strip.marker_index()).is_equal(2)
	assert_bool(session.road_strip.marker_heading_home()).is_false()
	# The bar read the same log the measurement reads: the survey's price sits
	# in the writing bucket, and what remains is the season's own count.
	assert_int(session.daylight_bar.days(&"writing"))\
		.is_equal(Ledger.daylight_cost(Ledger.EntryType.SURVEY))
	assert_int(session.daylight_bar.remaining_days()).is_equal(session.season.daylight)
	assert_int(session.daylight_bar.ghost_days()).is_equal(session.season.travel_cost())
	assert_int(session.daylight_bar.total_days()).is_equal(Season.STARTING_DAYLIGHT)
	# The turn for home flips the chevron; the sim's flag is the only source.
	session.season.heading_home = true
	assert_bool(session.road_strip.marker_heading_home()).is_true()


func test_writing_at_risk_outranks_the_rumour_it_confirms() -> void:
	# A sealed survey confirming a standing rumour is still unmerged writing:
	# the strip shows the at-risk state, not the safe half-truth under it.
	var session := _session()
	session.seed_input.text = "1"
	session._on_found_pressed()
	session._on_depart_pressed()
	session.house.rumoured_legs.append(1)
	assert_int(session.road_strip.leg_state(1)).is_equal(RoadStrip.LegState.RUMOURED)
	session.season.max_leg_reached = 1
	assert_bool(session.season.write_entry(
		Ledger.EntryType.SURVEY, "the leg behind", 1, true)).is_true()
	assert_int(session.road_strip.leg_state(1)).is_equal(RoadStrip.LegState.IN_LEDGER)


func test_an_inherited_road_is_drawn_as_already_inked() -> void:
	# The fix aimed at "felt like a fresh start": a House holding one sealed
	# leg and one rumoured one hands the next scribe a strip with both drawn,
	# at the desk when the season closes and at the outfit step after it.
	var session := _session()
	session.seed_input.text = "1"
	session._on_found_pressed()
	session._on_depart_pressed()
	session.season.clay = 10  # Two surveys cost more media than the default kit.
	session.season.max_leg_reached = 2
	assert_bool(session.season.write_entry(
		Ledger.EntryType.SURVEY, "the first leg", 1, true)).is_true()
	assert_bool(session.season.write_entry(
		Ledger.EntryType.SURVEY, "the second leg", 2, false)).is_true()
	session.season.result = Season.Result.RETURNED
	session._after_action()
	# At the desk the ledger has merged: the House's records are the truth
	# again, and the strip shows what the closed season added.
	assert_int(session.phase).is_equal(GameSession.Phase.DESK)
	assert_int(session.desk_strip.leg_state(1)).is_equal(RoadStrip.LegState.SEALED)
	assert_int(session.desk_strip.leg_state(2)).is_equal(RoadStrip.LegState.RUMOURED)
	assert_int(session.desk_strip.leg_state(3)).is_equal(RoadStrip.LegState.UNKNOWN)
	assert_int(session.desk_strip.marker_index()).is_equal(-1)
	session._on_next_season_pressed()
	assert_int(session.outfit_strip.leg_state(1)).is_equal(RoadStrip.LegState.SEALED)
	assert_int(session.outfit_strip.leg_state(2)).is_equal(RoadStrip.LegState.RUMOURED)
	assert_int(session.outfit_strip.leg_state(3)).is_equal(RoadStrip.LegState.UNKNOWN)
	# Season two's bar reads season two's record — a note's single day of
	# writing, not the sixteen the first season's record carries.
	session._on_depart_pressed()
	assert_bool(session.season.write_entry(Ledger.EntryType.NOTE, "a note")).is_true()
	session._refresh()
	assert_int(session.daylight_bar.days(&"writing"))\
		.is_equal(Ledger.daylight_cost(Ledger.EntryType.NOTE))


func test_a_fallen_scribes_ledger_leaves_only_what_the_courier_carried() -> void:
	# The other half of the kiln state's promise: when the road keeps the
	# scribe, what was couriered merges and shows as the House's own, and
	# what was not simply is not there — no leg stays "at risk" forever.
	var session := _session()
	session.seed_input.text = "1"
	session._on_found_pressed()
	session._on_depart_pressed()
	session.season.clay = 20  # A survey, a courier copy, and a second survey.
	session.season.max_leg_reached = 2
	assert_bool(session.season.write_entry(
		Ledger.EntryType.SURVEY, "the first leg", 1, true)).is_true()
	assert_bool(session.season.send_courier()).is_true()
	assert_bool(session.season.write_entry(
		Ledger.EntryType.SURVEY, "the second leg", 2, false)).is_true()
	session._refresh()
	assert_int(session.road_strip.leg_state(1)).is_equal(RoadStrip.LegState.IN_LEDGER)
	assert_int(session.road_strip.leg_state(2)).is_equal(RoadStrip.LegState.IN_LEDGER)
	session.season.result = Season.Result.FELL
	session._after_action()
	assert_int(session.desk_strip.leg_state(1)).is_equal(RoadStrip.LegState.SEALED)
	assert_int(session.desk_strip.leg_state(2)).is_equal(RoadStrip.LegState.UNKNOWN)


func test_the_bar_clamps_when_the_road_overdraws_the_light() -> void:
	# The road bills in full against an empty purse, so attributed light can
	# exceed the season's whole budget. The bar's box stretches to the real
	# spend — nothing draws outside it — and the overdraw is named.
	var record := SeasonRecord.new()
	record.light_travel = 30
	record.light_writing = 5
	record.light_road = 14
	record.light_obligation = 3
	var bar: DaylightBar = auto_free(DaylightBar.new())
	add_child(bar)
	bar.show_light(record, 0, 0)
	# Each bucket lands under its own name — the record's fields map to the
	# bar's buckets one for one, not merely to the same sum.
	assert_int(bar.days(&"travel")).is_equal(30)
	assert_int(bar.days(&"writing")).is_equal(5)
	assert_int(bar.days(&"road")).is_equal(14)
	assert_int(bar.days(&"obligation")).is_equal(3)
	assert_int(bar.spent_days()).is_equal(52)
	assert_int(bar.total_days()).is_equal(52)
	assert_int(bar.short_days()).is_equal(12)
	assert_int(bar.remaining_days()).is_equal(0)


func test_the_ghost_never_overflows_what_remains() -> void:
	# The ghost shows cost inside the light that exists. Whether the act is
	# refused stays the sim's call, made only when the button is pressed.
	var bar: DaylightBar = auto_free(DaylightBar.new())
	add_child(bar)
	bar.show_light(null, 10, 2)
	assert_int(bar.ghost_days()).is_equal(2)
	bar.show_ghost(7)  # A different price takes: show_ghost is not a no-op.
	assert_int(bar.ghost_days()).is_equal(7)
	bar.show_ghost(15)  # More than remains draws as what remains.
	assert_int(bar.ghost_days()).is_equal(10)


func test_a_hovered_price_survives_the_refresh_a_click_causes() -> void:
	# Clicking a button is the one moment the pointer is guaranteed to be on
	# it, and every click ends in a refresh. The ghost must re-arm with the
	# hovered act's price, not fall back to the road's.
	var session := _session()
	session.seed_input.text = "1"
	session._on_found_pressed()
	session._on_depart_pressed()
	session._hovered_cost = func() -> int: return Ledger.daylight_cost(Ledger.EntryType.SURVEY)
	session._refresh()
	assert_int(session.daylight_bar.ghost_days())\
		.is_equal(Ledger.daylight_cost(Ledger.EntryType.SURVEY))
	session._hovered_cost = Callable()
	session._refresh()
	assert_int(session.daylight_bar.ghost_days()).is_equal(session.season.travel_cost())
