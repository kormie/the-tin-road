class_name UiPalette
extends RefCounted
## The fired-clay palette, read from its one shipped home
## (res://data/ui/palette.json — see that file's header for why it lives
## there and how it is kept from drifting off design-system/tokens.json).
##
## Presentation only: nothing in sim/ knows colours exist. Widgets ask for
## pigment by name; scene nodes carry an ink_* group and are painted once at
## load, which is what lets main.tscn hold no hex values of its own.

const PATH := "res://data/ui/palette.json"

## Scene groups to pigment names: a label tagged ink_bronze is painted bronze.
## Groups are semantic so the scene says what a thing IS (a heading, a hint, a
## refusal) and the palette file alone says what that looks like.
const INKS: Dictionary[StringName, StringName] = {
	&"ink_bronze": &"bronze",
	&"ink_papyrus": &"papyrus",
	&"ink_verdigris": &"verdigris",
	&"ink_kiln": &"kiln",
	&"ink_dim": &"papyrusDim",
}

static var _colors: Dictionary[StringName, Color] = {}


## The named pigment. Missing names are a build error, not a runtime guess.
static func color(name: StringName) -> Color:
	if _colors.is_empty():
		_load()
	assert(_colors.has(name), "No such pigment in %s: %s" % [PATH, name])
	return _colors[name]


## Walk a scene and ink every Control tagged with an ink_* group. RichTextLabel
## takes its body colour through default_color; everything else through
## font_color. Called once from the session's _ready.
static func paint(node: Node) -> void:
	for group: StringName in INKS:
		if node.is_in_group(group) and node is Control:
			var property := "default_color" if node is RichTextLabel else "font_color"
			(node as Control).add_theme_color_override(property, color(INKS[group]))
	for child: Node in node.get_children():
		paint(child)


static func _load() -> void:
	var text := FileAccess.get_file_as_string(PATH)
	assert(text != "", "Palette file missing or empty: " + PATH)
	var parsed: Variant = JSON.parse_string(text)
	assert(parsed is Dictionary, "Palette file is not valid JSON: " + PATH)
	for key: Variant in (parsed as Dictionary):
		var name := str(key)
		if name.begins_with("_"):
			continue
		var hex := str((parsed as Dictionary)[key])
		assert(Color.html_is_valid(hex), "Not a colour in %s: %s = %s" % [PATH, name, hex])
		_colors[StringName(name)] = Color.html(hex)
