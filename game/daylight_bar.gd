class_name DaylightBar
extends Control
## The season's light as one bar: the spent portion split into the four
## buckets the sim attributed at the point of spending, the remainder in
## papyrus, and — outlined inside the remainder — what the next act would
## cost. The first playtest made zero remarks about daylight across two
## seasons; the clock was a number nobody watched
## (docs/design/playtests/session-01.md, playtest-script.md §1).
##
## The numbers are never re-derived here. The chronicle is read for shape the
## way chronicle/renderer.gd reads it for prose and measure/ reads it for
## numbers: session.gd hands this widget the same SeasonRecord the
## measurement computes, plus the live season's remaining light. Three
## readers, one log, none knowing anything the others cannot see.

const FONT_SIZE := 10
const BAR_HEIGHT := 16.0
const BAR_Y := 2.0
const PAD_X := 1.0

## Bucket order and pigment. Travel and writing are the two chosen spends —
## bronze and verdigris, the two accents. The road's own toll is kiln: the
## light the road takes from you is the dangerous act made visible, which is
## what kiln is for. Obligations are papyrusDim — dull duty, drawn in the
## dim ink (contour would vanish into the bar's own frame). What remains is
## papyrus, literally.
const BUCKETS: Array[Dictionary] = [
	{"key": &"travel", "ink": &"bronze", "label": "travel"},
	{"key": &"writing", "ink": &"verdigris", "label": "writing"},
	{"key": &"road", "ink": &"kiln", "label": "road"},
	{"key": &"obligation", "ink": &"papyrusDim", "label": "obligations"},
]

var _days: Dictionary[StringName, int] = {}
var _remaining := 0
var _short := 0
var _ghost := 0


## Push the season's light in. `record` is the in-progress season's
## SeasonRecord (null when no season is under way), `remaining` is
## season.daylight, `ghost` the daylight price of the next act — cost shown
## before it is paid, never a prediction of refusal.
func show_light(record: SeasonRecord, remaining: int, ghost: int) -> void:
	_days = {}
	_short = 0
	if record != null:
		_days[&"travel"] = record.light_travel
		_days[&"writing"] = record.light_writing
		_days[&"road"] = record.light_road
		_days[&"obligation"] = record.light_obligation
		_short = record.light_short()
	_remaining = maxi(0, remaining)
	_ghost = maxi(0, ghost)
	queue_redraw()


## Change only the ghost — hovering a priced act previews that price.
func show_ghost(ghost: int) -> void:
	_ghost = maxi(0, ghost)
	queue_redraw()


## Days attributed to one bucket (&"travel", &"writing", &"road",
## &"obligation"), as the record handed them over.
func days(bucket: StringName) -> int:
	return _days.get(bucket, 0)


## Every attributed day, across the four buckets.
func spent_days() -> int:
	var total := 0
	for bucket: Dictionary in BUCKETS:
		var key: StringName = bucket["key"]
		total += days(key)
	return total


## The light not yet spent — the season's own count, not a derivation.
func remaining_days() -> int:
	return _remaining


## The overdraw, straight off the record: the road bills in full against an
## empty purse, so attributed light can exceed the season's whole budget.
func short_days() -> int:
	return _short


## What the bar's box represents. Normally the season's whole budget; on an
## overdrawn season the box stretches to hold the real spend instead of
## letting the fills run out of it — the bar clamps, the log keeps the truth.
func total_days() -> int:
	return maxi(Season.STARTING_DAYLIGHT, spent_days() + _remaining)


## The ghost as drawn: capped at what remains, because the bar shows cost
## inside the light that exists. Whether the act is refused is the sim's call
## alone, made when the button is pressed.
func ghost_days() -> int:
	return mini(_ghost, _remaining)


func _draw() -> void:
	var bar := Rect2(PAD_X, BAR_Y, size.x - PAD_X * 2.0, BAR_HEIGHT)
	draw_rect(bar, UiPalette.color(&"plasterDeep"))
	var total := total_days()
	if total > 0:
		var unit := bar.size.x / float(total)
		var x := bar.position.x
		var seams: Array[float] = []
		for bucket: Dictionary in BUCKETS:
			var key: StringName = bucket["key"]
			var ink: StringName = bucket["ink"]
			var width := unit * float(days(key))
			if width > 0.0:
				draw_rect(Rect2(x, bar.position.y, width, bar.size.y),
					UiPalette.color(ink))
				x += width
				seams.append(x)
		if _remaining > 0:
			draw_rect(Rect2(x, bar.position.y, unit * float(_remaining), bar.size.y),
				UiPalette.color(&"papyrus"))
		if ghost_days() > 0:
			draw_rect(Rect2(x + 1.0, bar.position.y + 2.0,
				unit * float(ghost_days()) - 2.0, bar.size.y - 4.0),
				UiPalette.color(&"contour"), false, 1.0)
		# Seams go on after every fill, on whole pixels, so the next fill
		# cannot paint over its own divider.
		for seam: float in seams:
			var sx := roundf(seam)
			draw_line(Vector2(sx, bar.position.y), Vector2(sx, bar.end.y),
				UiPalette.color(&"night"), 1.0)
	draw_rect(bar, UiPalette.color(&"contour"), false, 1.0)
	_draw_legend(bar)


## The same numbers in words, under the bar, so "20 on travel and 5 on
## writing" is readable at a glance rather than inferred from widths.
func _draw_legend(bar: Rect2) -> void:
	var font := get_theme_default_font()
	var x := bar.position.x
	var baseline := bar.end.y + 14.0
	for bucket: Dictionary in BUCKETS:
		var key: StringName = bucket["key"]
		var ink: StringName = bucket["ink"]
		x = _legend_item(font, x, baseline, ink,
			"%s %d" % [str(bucket["label"]), days(key)])
	x = _legend_item(font, x, baseline, &"papyrus", "left %d" % _remaining)
	if _short > 0:
		_legend_item(font, x, baseline, &"kiln", "short %d" % _short)


func _legend_item(font: Font, x: float, baseline: float, ink: StringName, text: String) -> float:
	var swatch := Rect2(x, baseline - 8.0, 8.0, 8.0)
	draw_rect(swatch, UiPalette.color(ink))
	draw_rect(swatch, UiPalette.color(&"contour"), false, 1.0)
	draw_string(font, Vector2(x + 11.0, baseline), text,
		HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE, UiPalette.color(&"papyrusDim"))
	return x + 11.0 + font.get_string_size(text,
		HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE).x + 10.0
