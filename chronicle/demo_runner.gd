class_name DemoRunner
extends RefCounted
## Runs a few generations of a House with a simple "player brain", then renders
## the chronicle. Shared by the CLI demo (scripts/demo_season.gd), the main
## scene, and the tests — one code path, three doors.
##
## The policy below is a placeholder for a human. It exists so the bootstrap
## can demonstrate the thesis (documentation -> automation -> narrative)
## end to end on day zero, not to be good at the game.

const HOME_BUFFER := 6  # daylight held in reserve against the road home. First-pass.


static func run(seed_value: int, seasons: int, house_name: String = "House Sapanu") -> Dictionary:
	var route := Route.load_from_file("res://data/routes/tin_road_slice.json")
	var naming := Naming.load_from_file("res://data/names/scribes.json")
	var house := House.new(house_name, seed_value, route, naming)
	for _i: int in range(seasons):
		var season := house.start_season()
		season.begin()
		_play_out(season, route)
		house.merge(season)
	var renderer := ChronicleRenderer.load_default(house.rng.stream(&"prose"))
	return {"book": renderer.render_book(house), "house": house}


static func _play_out(season: Season, route: Route) -> void:
	var guard := 0
	while not season.is_over() and guard < 64:
		guard += 1
		season.travel_next()
		if season.is_over():
			return
		_consider_writing(season, route)


static func _consider_writing(season: Season, route: Route) -> void:
	var node: Route.RouteNode = route.nodes[season.position]
	var travel_still_owed: int
	if season.heading_home:
		travel_still_owed = season.position * Season.TRAVEL_COST
	else:
		travel_still_owed = (route.last_index() * 2 - season.position) * Season.TRAVEL_COST
	var to_spare := season.daylight - travel_still_owed - HOME_BUFFER
	# Survey the leg just completed, if the House doesn't know it and light allows.
	# One survey per season: the demo brain has read what happens to greedy scribes.
	if node.leg >= 1 and season.surveys.is_empty() and to_spare >= Ledger.daylight_cost(Ledger.EntryType.SURVEY):
		season.write_entry(Ledger.EntryType.SURVEY,
			"the road as far as %s" % node.display_name, node.leg)
		return
	# Otherwise, cheap notes at ruins — a scribe cannot help themselves.
	if node.kind == "ruin" and to_spare >= Ledger.daylight_cost(Ledger.EntryType.NOTE):
		season.write_entry(Ledger.EntryType.NOTE, "what the sea left at %s" % node.display_name)
