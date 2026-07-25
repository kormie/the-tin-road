class_name ChronicleEvent
extends RefCounted
## One thing that happened, in structured form.
##
## The sim never writes prose. It records events; renderers turn events into
## text. This is the whole trick behind "every playthrough is a narrative":
## the game and the book are two views of the same log.

var season: int
var day: int
var type: StringName
var place: String
var actor: String
var data: Dictionary


static func make(p_season: int, p_day: int, p_type: StringName, p_place: String, p_actor: String, p_data: Dictionary = {}) -> ChronicleEvent:
	var ev := ChronicleEvent.new()
	ev.season = p_season
	ev.day = p_day
	ev.type = p_type
	ev.place = p_place
	ev.actor = p_actor
	ev.data = p_data
	return ev


func to_dict() -> Dictionary:
	return {
		"season": season,
		"day": day,
		"type": String(type),
		"place": place,
		"actor": actor,
		"data": data,
	}
