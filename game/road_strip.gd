class_name RoadStrip
extends Control
## The route drawn as a strip: node shapes joined by leg segments, each leg
## carrying the one state the House's records give it. This is a third reader
## of sim state alongside the labels — it draws what Route, House and Season
## already hold and adds nothing of its own. The first playtest read "survey"
## as recon about the current location; a road drawn as the stretches BETWEEN
## places is the correction no sentence managed
## (docs/design/playtests/session-01.md).
##
## Flat mineral fills with drawn contour lines, per docs/art-direction.md.
## No gradients, no shadows, no animation: state changes, the strip redraws.

## What the archive (or the ledger still on the road) says about one leg.
## IN_LEDGER is the courier's reason to exist made visible: written this
## season, not yet merged, lost if the scribe is — held, but at risk.
enum LegState { UNKNOWN, RUMOURED, SEALED, IN_LEDGER }

const FONT_SIZE := 10
const NODE_RADIUS := 7.0
const BAND_HEIGHT := 10.0
const BAND_Y := 44.0
const PAD_X := 14.0
## Labels keep clear of the panel's right edge, where the scroll bar rides.
const LABEL_INSET_RIGHT := 10.0

var _route: Route
var _house: House
var _season: Season


## Push the current state in. Any argument may be null (no House founded, no
## season under way); the strip draws whatever the rest still supports.
func show_road(route: Route, house: House, season: Season) -> void:
	_route = route
	_house = house
	_season = season
	queue_redraw()


## The one state a leg is drawn in. Precedence is what the player most needs
## to see: writing still on the road outranks what the archive already holds
## (a sealed survey confirming a rumour is at risk exactly like any other
## unmerged entry), then sealed fact, then rumour. Once the season is over the
## House's records are the whole truth again — a ledger that merged shows as
## sealed or rumoured, and one the road kept simply is not there.
func leg_state(leg: int) -> LegState:
	if _season != null and not _season.is_over() and _season.surveys.has(leg):
		return LegState.IN_LEDGER
	if _house != null and _house.surveyed_legs.has(leg):
		return LegState.SEALED
	if _house != null and _house.rumoured_legs.has(leg):
		return LegState.RUMOURED
	return LegState.UNKNOWN


## Node index the scribe stands at, or -1 when no scribe is on the road
## (outfit step, desk, title). The desk strip shows what the season left
## behind, not where it ended.
func marker_index() -> int:
	if _season == null or _season.is_over():
		return -1
	return _season.position


## Which way the marker points. Meaningless when marker_index() is -1.
func marker_heading_home() -> bool:
	return _season != null and _season.heading_home


func _draw() -> void:
	if _route == null or _route.nodes.size() < 2:
		return
	var count := _route.nodes.size()
	var usable := size.x - PAD_X * 2.0
	var xs: Array[float] = []
	for i: int in range(count):
		xs.append(PAD_X + usable * float(i) / float(count - 1))
	for i: int in range(count - 1):
		var band := Rect2(xs[i], BAND_Y - BAND_HEIGHT / 2.0,
			xs[i + 1] - xs[i], BAND_HEIGHT)
		_draw_segment(band, leg_state(_route.nodes[i + 1].leg))
	_draw_leg_names(xs)
	for i: int in range(count):
		_draw_node(Vector2(xs[i], BAND_Y), _route.nodes[i].kind, i == marker_index())
	if marker_index() >= 0:
		_draw_marker(Vector2(xs[marker_index()], BAND_Y))
	_draw_node_names(xs)


## One stretch of road, in the language of the archive: contour outline only
## while unknown, half a fill for a rumour (rumour is worth half), solid
## bronze once the House holds it under seal, and kiln red while it exists
## only in a ledger that has not reached home — kiln spent on a dangerous
## state, per the palette's rules, not decoration. The unknown outline gets
## the heavier line: with no fill to carry it, weight is what keeps a
## contour-on-night stretch visible at all (design-system rule 2 — emphasis
## is line weight and pigment).
func _draw_segment(band: Rect2, state: LegState) -> void:
	match state:
		LegState.SEALED:
			draw_rect(band, UiPalette.color(&"bronze"))
		LegState.IN_LEDGER:
			draw_rect(band, UiPalette.color(&"kiln"))
		LegState.RUMOURED:
			draw_rect(Rect2(band.position.x, band.position.y + band.size.y / 2.0,
				band.size.x, band.size.y / 2.0), UiPalette.color(&"bronze"))
		LegState.UNKNOWN:
			draw_rect(band, UiPalette.color(&"contour"), false, 2.0)
			return
	draw_rect(band, UiPalette.color(&"contour"), false, 1.0)


## Leg names over their span of road, so "the marsh crossing" is a place on
## a drawing rather than a phrase in a sentence. The row sits high enough
## that the scribe's chevron never stamps over it.
func _draw_leg_names(xs: Array[float]) -> void:
	var font := get_theme_default_font()
	for leg: int in range(1, _route.leg_count() + 1):
		var first := -1
		var last := -1
		for i: int in range(_route.nodes.size()):
			if _route.nodes[i].leg == leg:
				if first < 0:
					first = i
				last = i
		if first < 1:
			continue
		var mid := (xs[first - 1] + xs[last]) / 2.0
		_draw_label(font, _route.leg_name(leg), mid, BAND_Y - 28.0,
			UiPalette.color(&"papyrusDim"))


## A shape per kind, drawn over the band: square settlement, triangle hazard,
## diamond rival, circle ruin. Plaster fill, outlined in the same dim ink as
## the name beneath it — the contour pigment disappears against the night
## ground, and a place the eye cannot find is a kind the player cannot read.
## The node the scribe stands at is outlined in full papyrus, heavier.
func _draw_node(center: Vector2, kind: String, current: bool) -> void:
	var r := NODE_RADIUS
	var fill := UiPalette.color(&"plaster")
	var line := UiPalette.color(&"papyrus") if current else UiPalette.color(&"papyrusDim")
	var weight := 2.0 if current else 1.0
	match kind:
		"settlement":
			var square := Rect2(center - Vector2(r, r), Vector2(r * 2.0, r * 2.0))
			draw_rect(square, fill)
			draw_rect(square, line, false, weight)
		"hazard":
			_draw_shape(PackedVector2Array([center + Vector2(0.0, -r),
				center + Vector2(r, r), center + Vector2(-r, r)]), fill, line, weight)
		"rival":
			_draw_shape(PackedVector2Array([center + Vector2(0.0, -r),
				center + Vector2(r, 0.0), center + Vector2(0.0, r),
				center + Vector2(-r, 0.0)]), fill, line, weight)
		_:
			# Ruin, and any kind a future route invents: a fallen column drum.
			draw_circle(center, r, fill)
			draw_arc(center, r, 0.0, TAU, 24, line, weight)


func _draw_shape(points: PackedVector2Array, fill: Color, line: Color, weight: float) -> void:
	draw_colored_polygon(points, fill)
	var closed := points.duplicate()
	closed.append(points[0])
	draw_polyline(closed, line, weight)


## The scribe: a verdigris chevron above the node they stand at, pointing the
## way they are walking. Heading home flips it.
func _draw_marker(center: Vector2) -> void:
	var dir := -1.0 if marker_heading_home() else 1.0
	var tip_y := BAND_Y - NODE_RADIUS - 9.0
	draw_colored_polygon(PackedVector2Array([
		Vector2(center.x - dir * 4.0, tip_y - 5.0),
		Vector2(center.x + dir * 5.0, tip_y),
		Vector2(center.x - dir * 4.0, tip_y + 5.0),
	]), UiPalette.color(&"verdigris"))


## Names under the nodes, on two alternating rows so six of them fit the
## panel. The node the scribe stands at reads in papyrus; the rest are dim.
func _draw_node_names(xs: Array[float]) -> void:
	var font := get_theme_default_font()
	for i: int in range(_route.nodes.size()):
		var row := BAND_Y + 22.0 + (13.0 if i % 2 == 1 else 0.0)
		var ink := UiPalette.color(&"papyrus") if i == marker_index() \
			else UiPalette.color(&"papyrusDim")
		_draw_label(font, _route.nodes[i].display_name, xs[i], row, ink)


## Text centred on a point but clamped inside the widget (short of the right
## edge, where the panel's scroll bar rides), so the names at either end of
## the road never fall off it.
func _draw_label(font: Font, text: String, center_x: float, baseline: float, ink: Color) -> void:
	var width := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE).x
	var x := clampf(center_x - width / 2.0, 0.0,
		maxf(0.0, size.x - width - LABEL_INSET_RIGHT))
	draw_string(font, Vector2(x, baseline), text,
		HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE, ink)
