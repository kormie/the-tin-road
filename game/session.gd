class_name GameSession
extends Control
## The playable layer: a human makes the choices the demo brain makes, and
## the chronicle grows down the page as they play. This layer stays thin —
## every rule lives in sim/. Buttons attempt sim calls; refusals are
## reported, never predicted by re-implementing gates here.

enum Phase { TITLE, OUTFIT, ROAD, DESK }

## Prefix on every measurement line, so a playtest transcript can be sieved out
## of a log with grep and fed to whatever plots it (docs/design/measurement.md).
const MEASURE_TAG := "TINMEASURE "

## The words for sim refusal codes. Presentation strings, so they live with
## the presentation.
const OUTFIT_REFUSALS: Dictionary[StringName, String] = {
	&"negative": "A pack cannot hold less than nothing.",
	&"too_costly": "The treasury cannot cover that kit.",
	&"too_bulky": "The pack will not close over that much.",
	&"no_media": "A scribe with nothing to write on is a passenger.",
}

var house: House
var season: Season
var route: Route
var naming: Naming
var catalog: ContractCatalog
var renderer: ChronicleRenderer
var subjects: Dictionary = {}
var phase := Phase.TITLE
var rendered_to := 0

@onready var book: RichTextLabel = %Book
@onready var status_label: Label = %Status
@onready var refusal_label: Label = %Refusal
@onready var seed_input: LineEdit = %SeedInput
@onready var title_panel: VBoxContainer = %TitlePanel
@onready var outfit_panel: VBoxContainer = %OutfitPanel
@onready var road_panel: VBoxContainer = %RoadPanel
@onready var desk_panel: VBoxContainer = %DeskPanel
@onready var clay_spin: SpinBox = %ClaySpin
@onready var papyrus_spin: SpinBox = %PapyrusSpin
@onready var seals_spin: SpinBox = %SealsSpin
@onready var kit_label: Label = %KitLabel
@onready var contracts_box: VBoxContainer = %ContractsBox
@onready var seal_check: CheckBox = %SealCheck
@onready var travel_button: Button = %TravelButton
@onready var desk_label: Label = %DeskLabel


func _ready() -> void:
	route = Route.load_from_file("res://data/routes/tin_road_slice.json")
	naming = Naming.load_from_file("res://data/names/scribes.json")
	catalog = ContractCatalog.load_from_file("res://data/contracts/slice_contracts.json")
	var parsed: Variant = JSON.parse_string(
		FileAccess.get_file_as_string("res://data/ui/entry_subjects.json"))
	if parsed is Dictionary:
		subjects = parsed as Dictionary
	%FoundButton.pressed.connect(_on_found_pressed)
	%DepartButton.pressed.connect(_on_depart_pressed)
	travel_button.pressed.connect(_on_travel_pressed)
	%NoteButton.pressed.connect(func() -> void: _on_write_pressed(Ledger.EntryType.NOTE))
	%RecordButton.pressed.connect(func() -> void: _on_write_pressed(Ledger.EntryType.RECORD))
	%SurveyButton.pressed.connect(func() -> void: _on_write_pressed(Ledger.EntryType.SURVEY))
	%TreatiseButton.pressed.connect(func() -> void: _on_write_pressed(Ledger.EntryType.TREATISE))
	%CourierButton.pressed.connect(_on_courier_pressed)
	%BuySealButton.pressed.connect(_on_buy_seal_pressed)
	%PostOrderButton.pressed.connect(_on_post_order_pressed)
	%NextSeasonButton.pressed.connect(_on_next_season_pressed)
	# Spinner ranges come from sim constants — the scene must never invent a
	# gate the sim does not have; the guild hall does all the refusing.
	clay_spin.max_value = floorf(float(Outfit.PACK_CAPACITY) / float(Outfit.CLAY_BULK))
	papyrus_spin.max_value = floorf(float(Outfit.PACK_CAPACITY) / float(Outfit.PAPYRUS_BULK))
	seals_spin.max_value = floorf(float(Outfit.PACK_CAPACITY) / float(Outfit.SEAL_BULK))
	for spin: SpinBox in [clay_spin, papyrus_spin, seals_spin]:
		spin.value_changed.connect(func(_v: float) -> void: _refresh_kit_label())
	_show_phase(Phase.TITLE)
	book.text = "The archive is empty. Found a House, and write what you learn.\n"


func _show_phase(next_phase: Phase) -> void:
	phase = next_phase
	title_panel.visible = phase == Phase.TITLE
	outfit_panel.visible = phase == Phase.OUTFIT
	road_panel.visible = phase == Phase.ROAD
	desk_panel.visible = phase == Phase.DESK
	refusal_label.text = ""
	_refresh_status()


func _refuse(text: String) -> void:
	refusal_label.text = text


## Pull everything new out of the chronicle into the page, then update the
## standing facts. Called after every action.
func _refresh() -> void:
	if house != null:
		var grown := renderer.render_events(house, rendered_to)
		rendered_to = house.chronicle.events.size()
		if grown.strip_edges() != "":
			book.text += grown
	_refresh_status()


func _refresh_status() -> void:
	if house == null:
		status_label.text = "No House yet."
		return
	if season == null or season.is_over():
		status_label.text = "%s — treasury %d shekels — %s" % [
			house.display_name, house.silver,
			"the road is documented" if house.route_documented() else "the road is not yet documented"]
		return
	var node: Route.RouteNode = season.route.nodes[season.position]
	status_label.text = "%s at %s — day %d — %d light — %d clay, %d papyrus, %d seals — purse %d — next step %d light" % [
		season.scribe, node.display_name, season.day, season.daylight,
		season.clay, season.papyrus, season.seals, season.silver, season.travel_cost()]


func _refresh_kit_label() -> void:
	var kit := _kit_from_spinners()
	kit_label.text = "%d shekels, bulk %d of %d. Treasury holds %d; the patron advances %d with the season." % [
		kit.total_cost(), kit.total_bulk(), Outfit.PACK_CAPACITY,
		house.silver if house != null else 0, House.YABNINU_ADVANCE]


func _kit_from_spinners() -> Outfit:
	return Outfit.new(int(clay_spin.value), int(papyrus_spin.value), int(seals_spin.value))


func _on_found_pressed() -> void:
	var seed_value := int(seed_input.text) if seed_input.text.is_valid_int() else 101
	house = House.new("House Sapanu", seed_value, route, naming)
	renderer = ChronicleRenderer.load_default(house.rng.stream(&"prose"))
	rendered_to = 0
	book.text = "# The Chronicle of %s\n\n*Seed %d. Written as it happens.*\n" % [house.display_name, seed_value]
	_show_phase(Phase.OUTFIT)
	_refresh_kit_label()


func _on_depart_pressed() -> void:
	var kit := _kit_from_spinners()
	var reason := house.preview_outfit_reason(kit)
	if reason != &"":
		_refuse(OUTFIT_REFUSALS.get(reason, "The guild hall refuses."))
		return
	season = house.start_season(kit)
	season.begin()
	_show_phase(Phase.ROAD)
	_rebuild_contract_buttons()
	_refresh()


func _rebuild_contract_buttons() -> void:
	for child: Node in contracts_box.get_children():
		child.queue_free()
	for template: ContractCatalog.ContractTemplate in catalog.templates:
		var button := Button.new()
		button.text = "Sign %s" % template.display_name
		button.tooltip_text = template.terms
		button.pressed.connect(_on_sign_pressed.bind(template))
		contracts_box.add_child(button)


func _on_sign_pressed(template: ContractCatalog.ContractTemplate) -> void:
	refusal_label.text = ""
	if not season.sign_contract(template):
		_refuse("%s stays unsigned: wrong settlement, already in force or voided, or no page to write it on." % template.display_name)
	_refresh()
	_after_action()


func _on_travel_pressed() -> void:
	refusal_label.text = ""
	season.travel_next()
	_refresh()
	_after_action()


func _on_write_pressed(type: Ledger.EntryType) -> void:
	refusal_label.text = ""
	var node: Route.RouteNode = season.route.nodes[season.position]
	var subject := str(subjects.get(Ledger.type_name(type), "the road at {place}")) \
		.format({"place": node.display_name})
	var leg := node.leg if type == Ledger.EntryType.SURVEY else -1
	if season.write_entry(type, subject, leg, seal_check.button_pressed):
		seal_check.button_pressed = false  # The seal box means the NEXT write.
	else:
		_refuse("The %s does not get written: too little light or media, no seal to press, or the leg is already held." % Ledger.type_name(type))
	_refresh()
	_after_action()


func _on_courier_pressed() -> void:
	refusal_label.text = ""
	if not season.send_courier():
		_refuse("No courier goes: it takes a seal, %d media, and something written." % Season.COURIER_MEDIA_COST)
	_refresh()
	_after_action()


func _on_buy_seal_pressed() -> void:
	refusal_label.text = ""
	if not season.buy_seal():
		_refuse("No seal changes hands: a guild hall, standing, silver, and pack room are all required.")
	_refresh()
	_after_action()


func _after_action() -> void:
	if season != null and season.is_over():
		house.merge(season)
		_refresh()
		var endings: Dictionary[int, String] = {
			Season.Result.RETURNED: "The season is over: the scribe came home.",
			Season.Result.FELL: "The season is over: the road kept the scribe.",
			Season.Result.STRANDED: "The season is over: the light ran out.",
		}
		desk_label.text = str(endings.get(season.result, "The season is over."))
		_show_phase(Phase.DESK)
		_emit_measurement()


## Emit the season record the measurement pass also produces, so a human
## session and `scripts/measure.gd` yield the same shape and can be read side
## by side. Computed from the chronicle, exactly as the headless pass computes
## it — the playable layer counts nothing itself.
##
## Called again when a desk action changes the closing season (posting a
## standing order lands in the season just finished). Two lines for one season
## is expected: the later one supersedes the earlier.
func _emit_measurement() -> void:
	if house == null:
		return
	var measurement := Measurement.of_chronicle(house.chronicle, house.rng.master_seed)
	if measurement.records.is_empty():
		return
	var record: SeasonRecord = measurement.records[measurement.records.size() - 1]
	var row := record.to_dict()
	row["seed"] = house.rng.master_seed
	print(MEASURE_TAG + JSON.stringify(row))
	desk_label.text += "\n\n" + record.headline()


func _on_post_order_pressed() -> void:
	refusal_label.text = ""
	if not house.post_standing_order():
		_refuse("No order posted: it takes a documented road, %d shekels, and no order already standing." % House.STANDING_ORDER_COST)
		_refresh()
		return
	_refresh()
	_emit_measurement()


func _on_next_season_pressed() -> void:
	season = null
	_show_phase(Phase.OUTFIT)
	_refresh_kit_label()
