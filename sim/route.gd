class_name Route
extends RefCounted
## A road, loaded from data. Routes are content, not code: authoring a new road
## means writing a JSON file in data/routes/, which is exactly how a game about
## documentation should extend its map.

class RouteNode:
	extends RefCounted
	var id: String
	var display_name: String
	var kind: String    # settlement | hazard | rival | ruin
	var leg: int        # which leg you complete by arriving here, outward. 0 = home.
	var flavor: String  # what the place does to cargo: "water" ruins papyrus. "" = neutral.

var id: String
var display_name: String
var nodes: Array[RouteNode] = []
## What each leg is called, by leg number. Content, like everything else about
## a road: a route that names its legs lets the House say what it knows in
## words instead of indices.
var leg_names: Dictionary[int, String] = {}


static func load_from_file(path: String) -> Route:
	var text := FileAccess.get_file_as_string(path)
	assert(text != "", "Route file missing or empty: " + path)
	var parsed: Variant = JSON.parse_string(text)
	assert(parsed is Dictionary, "Route file is not valid JSON: " + path)
	return from_dict(parsed as Dictionary)


static func from_dict(d: Dictionary) -> Route:
	var route := Route.new()
	route.id = str(d.get("id", "unnamed"))
	route.display_name = str(d.get("display_name", route.id))
	var raw_nodes: Variant = d.get("nodes", [])
	assert(raw_nodes is Array, "Route nodes must be an array")
	for raw: Variant in (raw_nodes as Array):
		assert(raw is Dictionary, "Each route node must be a dictionary")
		var nd := raw as Dictionary
		var node := RouteNode.new()
		node.id = str(nd.get("id", ""))
		node.display_name = str(nd.get("name", node.id))
		node.kind = str(nd.get("kind", "settlement"))
		node.leg = int(nd.get("leg", 0))
		node.flavor = str(nd.get("flavor", ""))
		route.nodes.append(node)
	var raw_legs: Variant = d.get("legs", {})
	if raw_legs is Dictionary:
		for key: Variant in (raw_legs as Dictionary):
			route.leg_names[int(str(key))] = str((raw_legs as Dictionary)[key])
	return route


## What to call a leg out loud. Falls back to the index for a road whose
## author never named its legs.
func leg_name(leg: int) -> String:
	return leg_names.get(leg, "leg %d" % leg)


func leg_count() -> int:
	var highest := 0
	for node: RouteNode in nodes:
		highest = maxi(highest, node.leg)
	return highest


func last_index() -> int:
	return nodes.size() - 1
