extends SceneTree
## Headless demo: chronicle a House and print the book.
##   godot --headless --path . -s scripts/demo_season.gd
## Environment:
##   TIN_SEED    master seed (default 1259, the year of the Treaty)
##   TIN_SEASONS generations to run (default 4)


func _init() -> void:
	var seed_value := 1259
	if OS.has_environment("TIN_SEED"):
		seed_value = int(OS.get_environment("TIN_SEED"))
	var seasons := 6
	if OS.has_environment("TIN_SEASONS"):
		seasons = int(OS.get_environment("TIN_SEASONS"))
	var result: Dictionary = DemoRunner.run(seed_value, seasons)
	print(str(result["book"]))
	quit(0)
