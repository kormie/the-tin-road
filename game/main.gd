extends Control
## Day-zero main scene: run a demo house, read its chronicle.
## This is scaffolding, not the game — the game starts with the season clock
## (docs/design/vertical-slice.md, build order step 1).

@onready var seed_input: LineEdit = %SeedInput
@onready var run_button: Button = %RunButton
@onready var output: RichTextLabel = %Output


func _ready() -> void:
	run_button.pressed.connect(_on_run_pressed)
	output.text = "The archive is empty. Choose a seed and chronicle a House.\n\nSeed 1259 is the year of the Treaty, and as good a place to start as any."


func _on_run_pressed() -> void:
	var seed_value := int(seed_input.text) if seed_input.text.is_valid_int() else 1259
	var result: Dictionary = DemoRunner.run(seed_value, 6)
	var book := str(result["book"])
	output.text = book
