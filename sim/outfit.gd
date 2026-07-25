class_name Outfit
extends RefCounted
## What a scribe buys before the road: media stock and seals, paid in House
## silver, packed into finite space. The default kit fills the pack exactly,
## so a third seal costs a clay tablet — the inventory pressure is the point
## and should not be optimised away (docs/design/systems.md §3).

# --- First-pass prices and bulk. Argue with these in playtests, not in code review. ---
const CLAY_PRICE := 1
const PAPYRUS_PRICE := 2
const SEAL_PRICE := 5
const CLAY_BULK := 2
const PAPYRUS_BULK := 1
const SEAL_BULK := 1
const PACK_CAPACITY := 16
const DEFAULT_CLAY := 4
const DEFAULT_PAPYRUS := 6
const DEFAULT_SEALS := 2

var clay: int
var papyrus: int
var seals: int


func _init(p_clay: int = DEFAULT_CLAY, p_papyrus: int = DEFAULT_PAPYRUS, p_seals: int = DEFAULT_SEALS) -> void:
	clay = p_clay
	papyrus = p_papyrus
	seals = p_seals


## The standard kit: the old spawn state, now priced and packed to the brim.
static func default_kit() -> Outfit:
	return Outfit.new()


func total_cost() -> int:
	return clay * CLAY_PRICE + papyrus * PAPYRUS_PRICE + seals * SEAL_PRICE


func total_bulk() -> int:
	return clay * CLAY_BULK + papyrus * PAPYRUS_BULK + seals * SEAL_BULK


## A kit the House can actually buy and carry: affordable, packable, and
## holding at least one piece of media to write on.
func is_valid(silver: int) -> bool:
	return invalid_reason(silver) == &""


## Why a kit is refused, as a code (&"" means valid). The words belong to
## whoever is presenting the refusal; the reason belongs to the sim.
func invalid_reason(silver: int) -> StringName:
	if clay < 0 or papyrus < 0 or seals < 0:
		return &"negative"
	if total_cost() > silver:
		return &"too_costly"
	if total_bulk() > PACK_CAPACITY:
		return &"too_bulky"
	if clay + papyrus < 1:
		return &"no_media"
	return &""
