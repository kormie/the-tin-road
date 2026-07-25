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
	var header := "# The Chronicle of %s\n\n*As compiled from the House archive. Seed %d.*\n" \
		% [house.display_name, house.rng.master_seed]
	return (header + render_events(house, 0)).trim_suffix("\n")


## Render events from an index onward, season headings included — the
## incremental form render_book uses, and how a live game grows the book.
## Prose variants draw in event order, so rendering each event exactly once,
## in order, through one renderer produces the same book split or whole.
func render_events(house: House, from_index: int, to_index: int = -1) -> String:
	var stop := to_index if to_index >= 0 else house.chronicle.events.size()
	var out := ""
	var current_season := -1
	if from_index > 0 and from_index <= house.chronicle.events.size():
		current_season = house.chronicle.events[from_index - 1].season
	for i: int in range(from_index, stop):
		var ev: ChronicleEvent = house.chronicle.events[i]
		if ev.season != current_season:
			current_season = ev.season
			out += "\n## The %s Season\n\n" % _ordinal(current_season).capitalize()
		var sentence := render_event(ev, house)
		if sentence != "":
			out += sentence + "\n\n"
	return out


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
	if ev.data.has("entries"):
		slots["entry_count"] = _compose_count(int(str(ev.data["entries"])),
			"entries_one", "entries_many")
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


## Compose a pluralized count slot from the _fragments table.
func _compose_count(n: int, one_key: String, many_key: String) -> String:
	var fragments: Variant = templates.get("_fragments", {})
	var f := fragments as Dictionary
	if n == 1:
		return str(f.get(one_key, "one"))
	return str(f.get(many_key, "{n}")).format({"n": str(n)})


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
