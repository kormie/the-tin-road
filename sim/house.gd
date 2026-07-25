class_name House
extends RefCounted
## The thing that persists. Scribes are per-run; the House and its archive are
## forever — or at least until somebody poisons the archive, which is a later
## milestone (docs/design/systems.md §2, on probation).

const AUTOMATED_INCOME_BASE := 260  # shekels, weighed. First-pass.
const AUTOMATED_INCOME_SPREAD := 120

var display_name: String
var rng: SimRng
var chronicle: Chronicle
var naming: Naming
var route: Route

var generation := 0
var past_scribes: Array[String] = []
var archive: Array[Dictionary] = []
var surveyed_legs: Array[int] = []
var silver := 0


func _init(p_name: String, p_seed: int, p_route: Route, p_naming: Naming) -> void:
	display_name = p_name
	rng = SimRng.new(p_seed)
	chronicle = Chronicle.new()
	naming = p_naming
	route = p_route


func route_documented() -> bool:
	return surveyed_legs.size() >= route.leg_count()


## Begin the next generation's season. Handles succession and any automated
## caravans the archive can already run on its own.
func start_season() -> Season:
	generation += 1
	var scribe := naming.pick(rng.stream(&"names"), past_scribes)
	past_scribes.append(scribe)
	if generation > 1:
		chronicle.record(ChronicleEvent.make(generation, 0, &"succession",
			route.nodes[0].display_name, scribe,
			{"predecessor": past_scribes[past_scribes.size() - 2], "house": display_name}))
	if route_documented():
		var income := AUTOMATED_INCOME_BASE + rng.stream(&"trade").randi_range(0, AUTOMATED_INCOME_SPREAD)
		silver += income
		chronicle.record(ChronicleEvent.make(generation, 0, &"caravan_returned",
			route.nodes[0].display_name, scribe,
			{"income": str(income), "route": route.display_name}))
	return Season.new(self, route, rng, chronicle, scribe, generation)


## Fold a finished season back into the House. Only a scribe who came home
## merges anything — the courier (not yet built) is what will soften this.
func merge(season: Season) -> void:
	if season.result != Season.Result.RETURNED:
		return
	var newly_surveyed: Array[int] = []
	for entry: Dictionary in season.entries:
		archive.append(entry)
	for leg: int in season.surveys:
		if not surveyed_legs.has(leg):
			surveyed_legs.append(leg)
			newly_surveyed.append(leg)
	if not season.entries.is_empty():
		chronicle.record(ChronicleEvent.make(season.number, season.day, &"ledger_merged",
			route.nodes[0].display_name, season.scribe,
			{"entries": str(season.entries.size()), "house": display_name}))
	if not newly_surveyed.is_empty() and route_documented():
		chronicle.record(ChronicleEvent.make(season.number, season.day, &"route_documented",
			route.nodes[0].display_name, season.scribe, {"route": route.display_name}))
