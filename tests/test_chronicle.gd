extends GdUnitTestSuite
## Events in, book out — and the same seed always writes the same book.


func test_events_are_recorded_in_order() -> void:
	var chronicle := Chronicle.new()
	chronicle.record(ChronicleEvent.make(1, 1, &"season_began", "Ugarit", "Testscribe"))
	chronicle.record(ChronicleEvent.make(1, 2, &"arrived", "the Salt Marsh", "Testscribe"))
	assert_int(chronicle.events.size()).is_equal(2)
	assert_str(String(chronicle.events[0].type)).is_equal("season_began")


func test_demo_run_is_deterministic() -> void:
	var a: Dictionary = DemoRunner.run(1259, 3)
	var b: Dictionary = DemoRunner.run(1259, 3)
	assert_str(str(a["book"])).is_equal(str(b["book"]))


func test_different_seeds_write_different_books() -> void:
	var a: Dictionary = DemoRunner.run(1259, 3)
	var b: Dictionary = DemoRunner.run(735, 3)
	assert_bool(str(a["book"]) == str(b["book"])).is_false()


func test_renderer_covers_every_emitted_event_type() -> void:
	# Any event the sim can emit must have prose. If this fails, the sim
	# learned to do something the book cannot yet say.
	var result: Dictionary = DemoRunner.run(90, 6)
	var book := str(result["book"])
	assert_bool(book.contains("no words yet for")).is_false()


func test_rng_streams_are_independent() -> void:
	var rng := SimRng.new(7)
	var road_first := rng.stream(&"road").randf()
	var rng2 := SimRng.new(7)
	rng2.stream(&"prose").randf()  # Draw from an unrelated stream first.
	var road_second := rng2.stream(&"road").randf()
	assert_float(road_first).is_equal_approx(road_second, 0.000001)
