extends GdUnitTestSuite
## The palette has one home in the shipped project (data/ui/palette.json,
## inside the export's data/** filter) and one in the design system
## (design-system/tokens.json, which does not ship). They are the same
## palette. Tests run against the real project directory and can read both,
## which is what makes this the place the two are held together: a colour
## changed in one file and not the other fails the build.


func _json(path: String) -> Dictionary:
	var text := FileAccess.get_file_as_string(path)
	assert_str(text).override_failure_message("Missing or empty: " + path).is_not_empty()
	var parsed: Variant = JSON.parse_string(text)
	assert_bool(parsed is Dictionary).override_failure_message("Not valid JSON: " + path).is_true()
	# A failed assertion reports and continues; return something the caller's
	# own assertions can fail on cleanly rather than crashing on a bad cast.
	return parsed as Dictionary if parsed is Dictionary else {}


## The shipped mirror, minus its _comment header.
func _shipped_palette() -> Dictionary[String, String]:
	var out: Dictionary[String, String] = {}
	var raw := _json("res://data/ui/palette.json")
	for key: Variant in raw:
		if not str(key).begins_with("_"):
			out[str(key)] = str(raw[key])
	return out


func test_the_shipped_palette_matches_the_design_tokens_exactly() -> void:
	var tokens := _json("res://design-system/tokens.json")
	var color_block: Variant = tokens.get("color", {})
	assert_bool(color_block is Dictionary).is_true()
	var colors := color_block as Dictionary
	var shipped := _shipped_palette()
	# Same names — nothing missing from the mirror, nothing invented in it.
	assert_int(shipped.size())\
		.override_failure_message("palette.json carries %d colours, tokens.json %d" % [
			shipped.size(), colors.size()])\
		.is_equal(colors.size())
	for name: Variant in colors:
		var entry: Variant = colors[name]
		assert_bool(entry is Dictionary).is_true()
		var expected := str((entry as Dictionary).get("value", ""))
		assert_str(shipped.get(str(name), "<missing from palette.json>"))\
			.override_failure_message("Colour '%s' drifted between tokens.json and palette.json" % str(name))\
			.is_equal(expected)


func test_every_shipped_colour_is_a_colour() -> void:
	var shipped := _shipped_palette()
	for name: String in shipped:
		assert_bool(Color.html_is_valid(shipped[name]))\
			.override_failure_message("palette.json '%s' does not parse as a colour" % name)\
			.is_true()


func test_the_loader_serves_the_shipped_values() -> void:
	# UiPalette is what every widget actually asks; it must answer with the
	# file's values, not defaults of its own.
	var shipped := _shipped_palette()
	for name: String in shipped:
		var expected := Color.html(shipped[name])
		assert_bool(UiPalette.color(StringName(name)).is_equal_approx(expected))\
			.override_failure_message("UiPalette.color(&\"%s\") does not match palette.json" % name)\
			.is_true()


func test_every_ink_group_in_the_scene_has_a_pigment() -> void:
	# UiPalette.paint walks the scene inking every node tagged ink_*; a group
	# it does not know is silently skipped, and the node quietly falls back to
	# the theme's default white. A typo'd group name must fail loudly, here.
	var scene := load("res://game/main.tscn") as PackedScene
	var session: Node = auto_free(scene.instantiate())
	var to_walk: Array[Node] = [session]
	while not to_walk.is_empty():
		var node: Node = to_walk.pop_back()
		for group: StringName in node.get_groups():
			if String(group).begins_with("ink_"):
				assert_bool(UiPalette.INKS.has(group))\
					.override_failure_message("%s carries unknown ink group '%s'" % [
						node.name, group])\
					.is_true()
		to_walk.append_array(node.get_children())
