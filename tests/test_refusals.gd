extends GdUnitTestSuite
## The sim names exactly one reason for every refusal, and the reason it names
## is the one that actually stopped the action.
##
## These exist because of the first playtest (docs/design/playtests/session-01.md):
## a courier was refused for want of media while the player, holding two seals,
## read a message listing seals, media and writing and concluded the run was
## dead. A refusal that lists every possible cause teaches nothing. So the gate
## and the explanation are now the same code path — `write_entry` and friends
## refuse exactly when `preview_*_reason` says so, which is what these assert.


func _house(seed_value: int = 1) -> House:
	var route := Route.load_from_file("res://data/routes/tin_road_slice.json")
	var naming := Naming.load_from_file("res://data/names/scribes.json")
	return House.new("House Test", seed_value, route, naming)


func _season(outfit: Outfit = null) -> Season:
	var season := _house().start_season(outfit)
	season.begin()
	return season


func test_preview_and_action_always_agree_on_writing() -> void:
	var season := _season()
	for type: int in [Ledger.EntryType.NOTE, Ledger.EntryType.RECORD,
			Ledger.EntryType.SURVEY, Ledger.EntryType.TREATISE]:
		var entry_type: Ledger.EntryType = type
		var allowed := season.preview_write_reason(entry_type) == &""
		assert_bool(season.write_entry(entry_type, "a subject")).is_equal(allowed)


func test_an_empty_pack_is_the_reason_before_a_missing_seal() -> void:
	# The playtest's exact state: seals in the pack, nothing to write on.
	var season := _season()
	season.clay = 0
	season.papyrus = 0
	assert_int(season.seals).is_greater(0)
	assert_str(String(season.preview_write_reason(Ledger.EntryType.NOTE, -1, true))) \
		.is_equal("no_media")
	assert_str(String(season.preview_courier_reason())).is_equal("nothing_written")
	season.entries.append({"season": 1, "type": "note", "subject": "x", "leg": -1, "sealed": false})
	assert_str(String(season.preview_courier_reason())).is_equal("no_media")


func test_a_survey_at_the_gate_says_there_is_no_road_behind_you() -> void:
	var season := _season()
	assert_int(season.position).is_equal(0)
	assert_str(String(season.preview_write_reason(Ledger.EntryType.SURVEY, 0))) \
		.is_equal("nothing_behind")
	assert_str(String(season.preview_write_reason(Ledger.EntryType.SURVEY, 3))) \
		.is_equal("leg_unreached")


func test_a_leg_already_written_is_distinguished_from_one_the_house_holds() -> void:
	var season := _season()
	season.max_leg_reached = 1
	season.surveys.append(1)
	assert_str(String(season.preview_write_reason(Ledger.EntryType.SURVEY, 1))) \
		.is_equal("leg_written")
	season.surveys.clear()
	season.house.surveyed_legs.append(1)
	assert_str(String(season.preview_write_reason(Ledger.EntryType.SURVEY, 1))) \
		.is_equal("leg_documented")


func test_a_rumour_is_confirmed_only_under_seal_and_says_so() -> void:
	var season := _season()
	season.max_leg_reached = 2
	season.house.rumoured_legs.append(2)
	assert_str(String(season.preview_write_reason(Ledger.EntryType.SURVEY, 2, false))) \
		.is_equal("rumour_unsealed")
	assert_str(String(season.preview_write_reason(Ledger.EntryType.SURVEY, 2, true))).is_equal("")


func test_the_home_hall_is_not_a_foreign_hall() -> void:
	var season := _season()
	assert_str(String(season.preview_seal_reason())).is_equal("home_hall")
	assert_bool(season.buy_seal()).is_false()


func test_the_empty_pack_is_announced_once_and_only_when_it_empties() -> void:
	# Until now the pack emptying was the game's one silent state change. The
	# player who hit it could not tell an empty pack from a misread button.
	var season := _season(Outfit.new(0, 2, 1))
	assert_bool(_has_stock_event(season)).is_false()
	assert_bool(season.write_entry(Ledger.EntryType.NOTE, "one")).is_true()
	assert_bool(_has_stock_event(season)).is_false()
	assert_bool(season.write_entry(Ledger.EntryType.NOTE, "two")).is_true()
	assert_int(season.media_total()).is_equal(0)
	assert_int(_stock_events(season)).is_equal(1)
	# It never fires twice, whatever else happens afterwards.
	season.travel_next()
	assert_int(_stock_events(season)).is_equal(1)


func test_the_empty_pack_carries_no_daylight_away_from_the_event_that_caused_it() -> void:
	# The measurement's accounting identity depends on every spend landing on
	# exactly one event. A bookkeeping event that swallowed a tally would break
	# it silently (docs/design/measurement.md).
	var season := _season(Outfit.new(0, 1, 1))
	assert_bool(season.write_entry(Ledger.EntryType.NOTE, "the last sheet")).is_true()
	for ev: ChronicleEvent in season.chronicle.events:
		if ev.type == &"stock_spent":
			assert_bool(ev.data.has("light_writing")).is_false()
			assert_bool(ev.data.has("light_travel")).is_false()


func _stock_events(season: Season) -> int:
	var n := 0
	for ev: ChronicleEvent in season.chronicle.events:
		if ev.type == &"stock_spent":
			n += 1
	return n


func _has_stock_event(season: Season) -> bool:
	return _stock_events(season) > 0
