class_name ChronicleRenderer
extends RefCounted
## Turns the event log into prose. The sim writes facts; this writes the book.
##
## Rendering is deterministic per House seed — the same playthrough always
## produces the same chronicle, which makes a seed a shareable story.

var templates: Dictionary = {}
var rng: RandomNumberGenerator


static func load_default(p_rng: RandomNumberGenerator) -> ChronicleRenderer:
	return load_from_file("res://data/chronicle/en.json", p_rng)


static func load_from_file(path: String, p_rng: RandomNumberGenerator) -> ChronicleRenderer:
	var renderer := ChronicleRenderer.new()
	renderer.rng = p_rng
	var text := FileAccess.get_file_as_string(path)
	assert(text != "", "Template file missing or empty: " + path)
	var parsed: Variant = JSON.parse_string(text)
	assert(parsed is Dictionary, "Template file is not valid JSON: " + path)
	renderer.templates = parsed as Dictionary
	return renderer


## Render the full chronicle of a House as markdown — the raw material of the
## novel that "naturally flows from a playthrough."
func render_book(house: House) -> String:
	var lines: Array[String] = []
	lines.append("# The Chronicle of %s" % house.display_name)
	lines.append("")
	lines.append("*As compiled from the House archive. Seed %d.*" % house.rng.master_seed)
	var current_season := -1
	for ev: ChronicleEvent in house.chronicle.events:
		if ev.season != current_season:
			current_season = ev.season
			lines.append("")
			lines.append("## The %s Season" % _ordinal(current_season).capitalize())
			lines.append("")
		var sentence := render_event(ev, house)
		if sentence != "":
			lines.append(sentence)
			lines.append("")
	return "\n".join(lines)


func render_event(ev: ChronicleEvent, house: House) -> String:
	var key := String(ev.type)
	if not templates.has(key):
		return "*(The chronicle has no words yet for: %s.)*" % key
	var variants: Variant = templates[key]
	assert(variants is Array, "Template variants for %s must be an array" % key)
	var pool := variants as Array
	var template := str(pool[rng.randi_range(0, pool.size() - 1)])
	var slots := {
		"scribe": ev.actor,
		"house": house.display_name,
		"place": ev.place,
		"day": str(ev.day),
		"day_ord": _ordinal(ev.day),
		"season_ord": _ordinal(ev.season),
	}
	for data_key: Variant in ev.data.keys():
		slots[str(data_key)] = str(ev.data[data_key])
	if ev.data.has("lost_clay") or ev.data.has("lost_papyrus"):
		slots["lost"] = _compose_lost(int(str(ev.data.get("lost_clay", "0"))),
			int(str(ev.data.get("lost_papyrus", "0"))))
	if ev.data.has("cost"):
		var cost := int(str(ev.data["cost"]))
		slots["cost_days"] = "%d day" % cost if cost == 1 else "%d days" % cost
	var sentence := template.format(slots)
	if sentence.length() > 1:
		sentence = sentence[0].to_upper() + sentence.substr(1)
	return sentence


## Compose the {lost} slot from structured loss counts. The words live in
## en.json's _fragments object — prose stays in data, in sim and renderer alike.
func _compose_lost(lost_clay: int, lost_papyrus: int) -> String:
	var fragments: Variant = templates.get("_fragments", {})
	assert(fragments is Dictionary, "en.json needs a _fragments object for {lost}")
	var f := fragments as Dictionary
	var parts: Array[String] = []
	if lost_papyrus == 1:
		parts.append(str(f.get("lost_papyrus_one", "papyrus")))
	elif lost_papyrus > 1:
		parts.append(str(f.get("lost_papyrus_many", "papyrus")).format({"n": str(lost_papyrus)}))
	if lost_clay == 1:
		parts.append(str(f.get("lost_clay_one", "clay")))
	elif lost_clay > 1:
		parts.append(str(f.get("lost_clay_many", "clay")).format({"n": str(lost_clay)}))
	if parts.is_empty():
		return str(f.get("lost_nothing", "nothing"))
	return str(f.get("lost_join", " and ")).join(parts)


func _ordinal(n: int) -> String:
	const WORDS: Array[String] = ["zeroth", "first", "second", "third", "fourth", "fifth",
		"sixth", "seventh", "eighth", "ninth", "tenth", "eleventh", "twelfth"]
	if n >= 0 and n < WORDS.size():
		return WORDS[n]
	var suffix := "th"
	if n % 100 < 11 or n % 100 > 13:
		match n % 10:
			1: suffix = "st"
			2: suffix = "nd"
			3: suffix = "rd"
	return str(n) + suffix
