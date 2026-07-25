extends SceneTree
## The measurement pass that closes milestone 1: replay seeded runs, read the
## chronicle each one wrote, and report the five signals from
## docs/design/vertical-slice.md — naming the one it cannot measure.
##
##   godot --headless --path . -s scripts/measure.gd
##   TIN_SEEDS=1259,735 TIN_SEASONS=10 godot --headless --path . -s scripts/measure.gd
##
## Environment:
##   TIN_SEEDS    comma-separated master seeds (default 1259,735,90)
##   TIN_SEASONS  generations per seed (default 8)
##   TIN_FORMAT   "report" (default, for humans) or "jsonl" (one season per line)
##
## Nothing here plays the game differently from `scripts/demo_season.gd` — the
## same reference brain walks the same roads. All this adds is reading.

const DEFAULT_SEEDS: Array[int] = [1259, 735, 90]
const DEFAULT_SEASONS := 8


func _init() -> void:
	var seeds := DEFAULT_SEEDS.duplicate()
	if OS.has_environment("TIN_SEEDS"):
		seeds = _parse_seeds(OS.get_environment("TIN_SEEDS"))
	var seasons := DEFAULT_SEASONS
	if OS.has_environment("TIN_SEASONS"):
		seasons = maxi(1, int(OS.get_environment("TIN_SEASONS")))
	var format := "report"
	if OS.has_environment("TIN_FORMAT"):
		format = OS.get_environment("TIN_FORMAT")
	if seeds.is_empty():
		printerr("No seeds to measure. TIN_SEEDS must be a comma-separated list of integers.")
		quit(1)
		return

	var runs: Array[Measurement] = []
	for seed_value: int in seeds:
		var result: Dictionary = DemoRunner.run(seed_value, seasons)
		var house: House = result["house"]
		runs.append(Measurement.of_chronicle(house.chronicle, seed_value))

	if format == "jsonl":
		print(MeasureReport.render_jsonl(runs).trim_suffix("\n"))
		quit(0)
		return
	var signals := Measurement.signals(runs, Measurement.load_bands())
	print(MeasureReport.render(runs, signals, seasons).trim_suffix("\n"))
	quit(0)


func _parse_seeds(raw: String) -> Array[int]:
	var out: Array[int] = []
	for part: String in raw.split(",", false):
		var trimmed := part.strip_edges()
		if trimmed.is_valid_int():
			out.append(int(trimmed))
	return out
