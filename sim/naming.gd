class_name Naming
extends RefCounted
## Scribe names, loaded from data/names/. Period-plausible names are cheap
## replayability texture and expensive-feeling lore. The data file marks which
## names are attested at Ugarit — keep the [real] convention alive even here.

var given: Array[String] = []


static func load_from_file(path: String) -> Naming:
	var naming := Naming.new()
	var text := FileAccess.get_file_as_string(path)
	assert(text != "", "Names file missing or empty: " + path)
	var parsed: Variant = JSON.parse_string(text)
	assert(parsed is Dictionary, "Names file is not valid JSON: " + path)
	var d := parsed as Dictionary
	var raw: Variant = d.get("given", [])
	for name: Variant in (raw as Array):
		naming.given.append(str(name))
	assert(not naming.given.is_empty(), "Names file has no given names")
	return naming


func pick(rng: RandomNumberGenerator, taken: Array[String] = []) -> String:
	var pool: Array[String] = []
	for name: String in given:
		if not taken.has(name):
			pool.append(name)
	if pool.is_empty():
		pool = given.duplicate()
	return pool[rng.randi_range(0, pool.size() - 1)]
