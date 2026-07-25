class_name GameSession
extends Control
## The playable layer: a human makes the choices the demo brain makes, and
## the chronicle grows down the page as they play. This layer stays thin —
## every rule lives in sim/. Buttons attempt sim calls; refusals are
## reported, never predicted by re-implementing gates here.
##
## What a refusal SAYS is presentation's job, and it says exactly one thing:
## the reason the sim actually gave (`Season.preview_*_reason`). A list of
## everything that might have gone wrong teaches nothing — the first playtest
## spent a season pressing all four writing buttons to find out which of three
## listed conditions was the true one (docs/design/playtests/session-01.md).

enum Phase { TITLE, OUTFIT, ROAD, DESK }

## Prefix on every measurement line, so a playtest transcript can be sieved out
## of a log with grep and fed to whatever plots it (docs/design/measurement.md).
const MEASURE_TAG := "TINMEASURE "

## The words for sim refusal codes. Presentation strings, so they live with
## the presentation; the codes and their order belong to sim/. Slots are filled
## from live state at the moment of refusal, so no number here can go stale.
const OUTFIT_REFUSALS: Dictionary[StringName, String] = {
	&"negative": "A pack cannot hold less than nothing.",
	&"too_costly": "The treasury cannot cover that kit.",
	&"too_bulky": "The pack will not close over that much.",
	&"no_media": "A scribe with nothing to write on is a passenger.",
}

const WRITE_REFUSALS: Dictionary[StringName, String] = {
	&"season_over": "The season is over. Nothing more gets written.",
	&"no_light": "A {type} takes {days} days of light, and {left} remain. A scribe who spends the last of the light never finishes the sentence.",
	&"no_media": "A {type} takes {media} of clay or papyrus. The pack holds {stock}.",
	&"no_seal": "There is no seal left to press. Untick the box and it can still be written — it reaches the archive as rumour.",
	&"nothing_behind": "There is no road behind you yet. A survey describes a leg you have walked.",
	&"leg_unreached": "You have not walked that far yet.",
	&"leg_written": "{leg} is already written up, this season, in this ledger.",
	&"leg_documented": "The House already holds {leg} under seal. It does not need it twice.",
	&"rumour_unsealed": "The House holds {leg} only as rumour. Nothing but a sealed survey confirms a rumour — tick the seal box.",
}

const COURIER_REFUSALS: Dictionary[StringName, String] = {
	&"season_over": "The season is over. The ledger goes home with whoever is carrying it.",
	&"nothing_written": "Nothing has been written yet. A courier carrying nothing is a walk.",
	&"no_media": "The courier carries a copy, and a copy needs {media} of clay or papyrus. The pack holds {stock}.",
	&"no_seal": "A courier travels under seal, and there is no seal left in the pack.",
}

const SEAL_REFUSALS: Dictionary[StringName, String] = {
	&"season_over": "The season is over.",
	&"not_settlement": "There is no guild hall out here.",
	&"home_hall": "This is your own hall — you buy seals here at the outfitting, before you leave.",
	&"no_standing": "No standing at this hall. Standing at a foreign hall is what a contract buys.",
	&"no_silver": "A seal here costs {price}. The road purse holds {purse}.",
	&"no_room": "The pack will not close over another seal.",
}

const CONTRACT_REFUSALS: Dictionary[StringName, String] = {
	&"season_over": "The season is over. Nothing gets signed.",
	&"not_settlement": "Deals are struck in settlements, not on the road.",
	&"not_offered_here": "{name} is not offered at {place}.",
	&"voided": "{name} was torn up, and word travels. Not this season.",
	&"already_signed": "{name} is already in force.",
	&"no_media": "A contract has to be written down, and there is nothing left to write it on.",
}

## The road outcome a call-in rides, in words. Contract data names the trigger;
## the phrasing is presentation's.
const TRIGGER_WORDS: Dictionary[StringName, String] = {
	&"shaken_down": "when rivals shake you down",
	&"peril_survived": "each time the road nearly takes you",
	&"turned_home": "at the turn for home",
}

var house: House
var season: Season
var route: Route
var naming: Naming
var catalog: ContractCatalog
var renderer: ChronicleRenderer
var subjects: Dictionary = {}
var glossary: Dictionary = {}
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
@onready var inherit_label: Label = %InheritLabel
@onready var contracts_box: VBoxContainer = %ContractsBox
@onready var seal_check: CheckBox = %SealCheck
@onready var seal_hint: Label = %SealHint
@onready var travel_button: Button = %TravelButton
@onready var desk_label: Label = %DeskLabel
@onready var holdings_label: Label = %HoldingsLabel
@onready var facilitator_label: Label = %FacilitatorLabel


func _ready() -> void:
	route = Route.load_from_file("res://data/routes/tin_road_slice.json")
	naming = Naming.load_from_file("res://data/names/scribes.json")
	catalog = ContractCatalog.load_from_file("res://data/contracts/slice_contracts.json")
	subjects = _load_json("res://data/ui/entry_subjects.json")
	glossary = _load_json("res://data/ui/glossary.json")
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
	seal_check.toggled.connect(func(_on: bool) -> void: _refresh_seal_hint())
	# Spinner ranges come from sim constants — the scene must never invent a
	# gate the sim does not have; the guild hall does all the refusing.
	clay_spin.max_value = floorf(float(Outfit.PACK_CAPACITY) / float(Outfit.CLAY_BULK))
	papyrus_spin.max_value = floorf(float(Outfit.PACK_CAPACITY) / float(Outfit.PAPYRUS_BULK))
	seals_spin.max_value = floorf(float(Outfit.PACK_CAPACITY) / float(Outfit.SEAL_BULK))
	for spin: SpinBox in [clay_spin, papyrus_spin, seals_spin]:
		spin.value_changed.connect(func(_v: float) -> void: _refresh_kit_label())
	_label_the_shop()
	_label_the_desk()
	_refresh_seal_hint()
	_show_phase(Phase.TITLE)
	book.text = "The archive is empty. Found a House, and write what you learn.\n"


func _load_json(path: String) -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed as Dictionary if parsed is Dictionary else {}


func _word(key: String) -> String:
	return str(glossary.get(key, ""))


func _plural(n: int, one: String, many: String) -> String:
	return "%d %s" % [n, one if n == 1 else many]


## Price and weight, from sim constants, onto the labels. A scribe outfitting
## for the first time could previously see three nouns and no numbers; the
## first playtest could not tell what any of them were for.
func _label_the_shop() -> void:
	%ClayLabel.text = "Clay — %d each, weighs %d" % [Outfit.CLAY_PRICE, Outfit.CLAY_BULK]
	%PapyrusLabel.text = "Papyrus — %d each, weighs %d" % [Outfit.PAPYRUS_PRICE, Outfit.PAPYRUS_BULK]
	%SealsLabel.text = "Seals — %d each, weighs %d" % [Outfit.SEAL_PRICE, Outfit.SEAL_BULK]
	%MediaHint.text = "%s\n%s" % [_word("media"), _word("seals")]


## Costs onto the writing buttons, descriptions beside them. Both read off
## Ledger, so a tuning change cannot leave the shop quoting last month's price.
func _label_the_desk() -> void:
	_label_entry(%NoteButton, %NoteDesc, Ledger.EntryType.NOTE, "entry_note")
	_label_entry(%RecordButton, %RecordDesc, Ledger.EntryType.RECORD, "entry_record")
	_label_entry(%SurveyButton, %SurveyDesc, Ledger.EntryType.SURVEY, "entry_survey")
	_label_entry(%TreatiseButton, %TreatiseDesc, Ledger.EntryType.TREATISE, "entry_treatise")
	%WriteHint.text = "%s\nd = days of light, m = clay or papyrus." % _word("writing")
	%CourierButton.text = "Send the ledger home by courier — 1 seal, %dm" % Season.COURIER_MEDIA_COST
	%CourierHint.text = _word("courier")
	%BuySealButton.text = "Buy a seal at the guild hall — %d shekels" % Season.SEAL_ROAD_PRICE
	%ContractsHint.text = _word("contracts")


## One writing button: what it costs, on the button; what it is, beside it.
func _label_entry(button: Button, desc: Label, type: Ledger.EntryType, key: String) -> void:
	button.text = "%s — %dd, %dm" % [
		Ledger.type_name(type).capitalize(),
		Ledger.daylight_cost(type), Ledger.media_cost(type)]
	button.tooltip_text = "%d days of light, %d of clay or papyrus" % [
		Ledger.daylight_cost(type), Ledger.media_cost(type)]
	desc.text = _word(key)


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


## Look up the words for a sim refusal code and fill in the live numbers. The
## sim named exactly one reason; this prints exactly that one.
func _refusal_text(table: Dictionary[StringName, String], code: StringName, slots: Dictionary) -> String:
	var template: String = table.get(code, "The road refuses, and does not say why.")
	return template.format(slots)


## Pull everything new out of the chronicle into the page, then update the
## standing facts. Called after every action.
func _refresh() -> void:
	if house != null:
		var grown := renderer.render_events(house, rendered_to)
		rendered_to = house.chronicle.events.size()
		if grown.strip_edges() != "":
			book.text += grown
	_refresh_status()
	_refresh_seal_hint()


func _refresh_status() -> void:
	if house == null:
		status_label.text = "No House yet."
		return
	if season == null or season.is_over():
		status_label.text = "%s — treasury %d shekels\n%s" % [
			house.display_name, house.silver, _road_knowledge()]
		return
	var node: Route.RouteNode = season.route.nodes[season.position]
	status_label.text = "%s at %s — day %d\nLight %d of %d — the next step costs %d\nPack: %d clay, %d papyrus (%d to write on) — %d seals — road purse %d" % [
		season.scribe, node.display_name, season.day,
		season.daylight, Season.STARTING_DAYLIGHT, season.travel_cost(),
		season.clay, season.papyrus, season.media_total(), season.seals, season.silver]
	if season.media_total() < 1:
		status_label.text += "\n" + _word("empty_pack")


## What the House knows of the road, in leg names rather than indices. The
## first playtest inherited a leg between seasons and reported season two as
## "a fresh start" — a number the measurement scored as healthy
## (docs/design/measurement.md, signal 5). A leg you cannot name is a leg you
## cannot feel you were left.
func _road_knowledge() -> String:
	var known: Array[String] = []
	for leg: int in range(1, route.leg_count() + 1):
		if house.surveyed_legs.has(leg):
			known.append("%s (sealed)" % route.leg_name(leg))
		elif house.rumoured_legs.has(leg):
			known.append("%s (rumour)" % route.leg_name(leg))
	if known.is_empty():
		return "Of %s the House knows nothing yet — 0 legs of %d." % [
			route.display_name, route.leg_count()]
	return "Of %s the House knows: %s — %d leg%s of %d." % [
		route.display_name, ", ".join(known), known.size(),
		"" if known.size() == 1 else "s", route.leg_count()]


## Everything one scribe leaves the next, on one panel, before a shekel is
## spent. This is the inheritance the generational premise stands on, and it
## used to be invisible at the moment it mattered most.
func _refresh_inheritance() -> void:
	if house == null:
		return
	if house.archive.is_empty():
		inherit_label.text = "Nothing. This is the first scribe of the House, and the archive is empty.\n\n%s" % _word("archive")
		return
	var lines: Array[String] = []
	lines.append("%s in the archive, written by %s." % [
		_plural(house.archive.size(), "entry", "entries"), ", ".join(house.past_scribes)])
	lines.append(_road_knowledge())
	lines.append("Treasury %d shekels; the patron advances %d more with the season." % [
		house.silver, House.YABNINU_ADVANCE])
	if house.has_standing_order():
		lines.append("A standing order for %s is posted in the archive." % route.display_name)
	inherit_label.text = "\n".join(lines)


func _refresh_kit_label() -> void:
	var kit := _kit_from_spinners()
	kit_label.text = "This kit: %d shekels, %d to write on, weight %d of %d.\nTreasury holds %d; the patron advances %d with the season." % [
		kit.total_cost(), kit.clay + kit.papyrus, kit.total_bulk(), Outfit.PACK_CAPACITY,
		house.silver if house != null else 0, House.YABNINU_ADVANCE]


## The seal box states which way it is set, in words, because a tick is easy to
## miss and this one silently decides whether a survey lands as fact or rumour.
func _refresh_seal_hint() -> void:
	var seals_left := season.seals if season != null else 0
	seal_check.text = "Seal the next entry (%d in the pack)" % seals_left
	seal_hint.text = _word("seal_toggle_on") if seal_check.button_pressed \
		else _word("seal_toggle_off")


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
	_refresh_inheritance()


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
		var row := VBoxContainer.new()
		row.add_theme_constant_override("separation", 2)
		var button := Button.new()
		button.text = "Sign %s" % template.display_name
		button.tooltip_text = template.terms
		button.pressed.connect(_on_sign_pressed.bind(template))
		row.add_child(button)
		var terms := Label.new()
		terms.text = _contract_summary(template)
		terms.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		terms.add_theme_color_override("font_color", Color(0.647, 0.616, 0.549))
		row.add_child(terms)
		contracts_box.add_child(row)


## What a contract does, read off its own numbers. The data's `terms` and
## `demand` are the holder's own words and belong to the chronicle; this is the
## deal, in shekels and days. The first playtest saw three identical buttons
## and a tooltip nobody hovers over, and signed none of them.
func _contract_summary(template: ContractCatalog.ContractTemplate) -> String:
	var lines: Array[String] = []
	lines.append("Gives: %s." % _contract_gains(template))
	lines.append("Called in %s: %s" % [
		TRIGGER_WORDS.get(template.trigger, "when the holder chooses"),
		_contract_demand(template)])
	lines.append("Signed at %s. Costs %d media to write." % [
		_places(template.sign_at), Season.CONTRACT_MEDIA_COST])
	return "\n".join(lines)


func _contract_gains(template: ContractCatalog.ContractTemplate) -> String:
	var gains: Array[String] = []
	if template.income_per_leg > 0:
		gains.append("%d silver each leg travelled" % template.income_per_leg)
	if template.grants_seal_access:
		gains.append("seals sold to you at foreign guild halls")
	if template.peril_death_chance >= 0.0:
		gains.append("death on a bad crossing drops from %d%% to %d%%" % [
			roundi(Season.PERIL_DEATH_CHANCE * 100.0),
			roundi(template.peril_death_chance * 100.0)])
	if gains.is_empty():
		return "standing, and nothing else"
	return ", ".join(gains)


## A demand in daylight is always honoured, so it has no default clause and can
## strand you; a demand in silver is the one that can go wrong.
func _contract_demand(template: ContractCatalog.ContractTemplate) -> String:
	if template.demand_daylight > 0:
		return "%d days of light. Always paid, even when there is no light to spare." \
			% template.demand_daylight
	if template.demand_silver <= 0:
		return "nothing."
	var fallout: Array[String] = ["the purse is emptied"]
	if template.default_media_penalty > 0:
		fallout.append("%d media seized" % template.default_media_penalty)
	if template.voids_on_default:
		fallout.append("the deal torn up")
	return "%d shekels from the road purse. Come up short and %s." % [
		template.demand_silver, _join_and(fallout)]


## "a, b and c" — a list a person can read out loud.
func _join_and(parts: Array[String]) -> String:
	if parts.size() < 2:
		return "".join(parts)
	var head := parts.slice(0, parts.size() - 1)
	return "%s and %s" % [", ".join(head), parts[parts.size() - 1]]


## Node ids are for the data files; players read the names on the map.
func _places(ids: Array[String]) -> String:
	var names: Array[String] = []
	for id: String in ids:
		for node: Route.RouteNode in route.nodes:
			if node.id == id:
				names.append(node.display_name)
				break
	return ", ".join(names) if not names.is_empty() else "nowhere on this road"


func _on_sign_pressed(template: ContractCatalog.ContractTemplate) -> void:
	refusal_label.text = ""
	var code := season.preview_contract_reason(template)
	if not season.sign_contract(template):
		_refuse(_refusal_text(CONTRACT_REFUSALS, code, {
			"name": template.display_name,
			"place": season.route.nodes[season.position].display_name,
		}))
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
	var code := season.preview_write_reason(type, leg, seal_check.button_pressed)
	if season.write_entry(type, subject, leg, seal_check.button_pressed):
		seal_check.button_pressed = false  # The seal box means the NEXT write.
	else:
		_refuse(_refusal_text(WRITE_REFUSALS, code, {
			"type": Ledger.type_name(type),
			"days": Ledger.daylight_cost(type),
			"media": Ledger.media_cost(type),
			"left": season.daylight,
			"stock": season.media_total(),
			"leg": route.leg_name(leg),
		}))
	_refresh()
	_after_action()


func _on_courier_pressed() -> void:
	refusal_label.text = ""
	var code := season.preview_courier_reason()
	if not season.send_courier():
		_refuse(_refusal_text(COURIER_REFUSALS, code, {
			"media": Season.COURIER_MEDIA_COST,
			"stock": season.media_total(),
		}))
	_refresh()
	_after_action()


func _on_buy_seal_pressed() -> void:
	refusal_label.text = ""
	var code := season.preview_seal_reason()
	if not season.buy_seal():
		_refuse(_refusal_text(SEAL_REFUSALS, code, {
			"price": Season.SEAL_ROAD_PRICE,
			"purse": season.silver,
		}))
	_refresh()
	_after_action()


func _after_action() -> void:
	if season != null and season.is_over():
		house.merge(season)
		_refresh()
		_emit_measurement()
		_show_phase(Phase.DESK)


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
	_write_the_desk(record)


## The end of a season, in words a player can act on. The record's headline is
## a facilitator's instrument — the first playtest read "3 entries and none
## lost" off the desk and could not say what it meant — so it stays on the
## panel, small and marked as what it is, under a summary meant for the person
## playing.
func _write_the_desk(record: SeasonRecord) -> void:
	var endings: Dictionary[String, String] = {
		"returned": "The season is over: the scribe came home.",
		"fell": "The season is over: the road kept the scribe.",
		"stranded": "The season is over: the light ran out on the road.",
	}
	var lines: Array[String] = [str(endings.get(record.outcome, "The season is over."))]
	lines.append("")
	lines.append(_fate_of_the_writing(record))
	lines.append("Light went: %d travelling, %d writing, %d taken by the road, %d to obligations. %d unspent." % [
		record.light_travel, record.light_writing, record.light_road,
		record.light_obligation, record.light_unspent])
	desk_label.text = "\n".join(lines)
	var gained := record.legs_known_end() - record.legs_known_start()
	var holdings: Array[String] = []
	holdings.append("The archive now holds %s." % _plural(house.archive.size(), "entry", "entries"))
	holdings.append(_road_knowledge())
	if gained > 0:
		holdings.append("That is %d more than the season began with." % gained)
	holdings.append("Treasury %d shekels." % house.silver)
	holdings_label.text = "\n".join(holdings)
	facilitator_label.text = "for the facilitator — " + record.headline()


## What happened to the season's writing, which is the only question the desk
## really answers. Entries that never reached the archive are named as losses,
## not left to be inferred from a difference between two numbers.
func _fate_of_the_writing(record: SeasonRecord) -> String:
	if record.entries_written == 0:
		return "%s wrote nothing down. The season leaves no trace in the archive." % record.scribe
	if record.entries_lost() == 0:
		return "%s wrote %d entries, and all %d reached the archive." % [
			record.scribe, record.entries_written, record.entries_merged]
	if record.entries_merged == 0:
		return "%s wrote %d entries. None reached the archive: what was not sent ahead died on the road." % [
			record.scribe, record.entries_written]
	return "%s wrote %d entries. %d reached the archive — the courier had them — and %d were lost with the scribe." % [
		record.scribe, record.entries_written, record.entries_merged, record.entries_lost()]


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
	_refresh_inheritance()
