class_name Ledger
extends RefCounted
## Entry types and costs. Numbers from docs/design/systems.md §1 — first-pass,
## and they exist to be argued with.

enum EntryType { NOTE, RECORD, SURVEY, TREATISE }

const COSTS: Dictionary[EntryType, Dictionary] = {
	EntryType.NOTE: {"daylight": 1, "media": 1},
	EntryType.RECORD: {"daylight": 3, "media": 2},
	EntryType.SURVEY: {"daylight": 8, "media": 5},
	EntryType.TREATISE: {"daylight": 15, "media": 10},
}

const NAMES: Dictionary[EntryType, String] = {
	EntryType.NOTE: "note",
	EntryType.RECORD: "record",
	EntryType.SURVEY: "survey",
	EntryType.TREATISE: "treatise",
}


static func daylight_cost(type: EntryType) -> int:
	var cost: Variant = COSTS[type]["daylight"]
	return int(cost)


static func media_cost(type: EntryType) -> int:
	var cost: Variant = COSTS[type]["media"]
	return int(cost)


static func type_name(type: EntryType) -> String:
	return NAMES[type]
