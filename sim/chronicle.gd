class_name Chronicle
extends RefCounted
## The append-only log of everything that has happened to a House.
##
## Persists across seasons and generations. This object is the meta-progression,
## the narrative substrate, and (eventually) the save format — the same object,
## which is the thesis of the game.

var events: Array[ChronicleEvent] = []


func record(ev: ChronicleEvent) -> void:
	events.append(ev)


func for_season(season: int) -> Array[ChronicleEvent]:
	var out: Array[ChronicleEvent] = []
	for ev: ChronicleEvent in events:
		if ev.season == season:
			out.append(ev)
	return out


func count_of(type: StringName) -> int:
	var n := 0
	for ev: ChronicleEvent in events:
		if ev.type == type:
			n += 1
	return n


func to_dicts() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for ev: ChronicleEvent in events:
		out.append(ev.to_dict())
	return out
