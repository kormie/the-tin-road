class_name SimRng
extends RefCounted
## Deterministic, named-stream randomness.
##
## Every source of chance in the sim draws from a named stream derived from one
## master seed. Same seed, same story — which makes a playthrough a shareable,
## reproducible artifact. Streams keep systems independent: adding a roll to
## the road does not reshuffle the prose.

var master_seed: int
var _streams: Dictionary[StringName, RandomNumberGenerator] = {}


func _init(seed_value: int) -> void:
	master_seed = seed_value


func stream(stream_name: StringName) -> RandomNumberGenerator:
	if not _streams.has(stream_name):
		var rng := RandomNumberGenerator.new()
		rng.seed = hash(str(master_seed) + ":" + String(stream_name))
		_streams[stream_name] = rng
	return _streams[stream_name]
