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
	var catalog := ContractCatalog.load_from_file("res://data/contracts/slice_contracts.json")
	var house := House.new(house_name, seed_value, route, naming)
	for _i: int in range(seasons):
		var season := house.start_season(_choose_outfit(house))
		season.begin()
		_sign_contracts(season, house, catalog)
		_play_out(season, route)
		house.merge(season)
	var renderer := ChronicleRenderer.load_default(house.rng.stream(&"prose"))
	return {"book": renderer.render_book(house), "house": house}


## The brain buys the standard kit every season, deliberately. Outfit choice
## belongs to a human; the demo only has to exercise the purchase.
static func _choose_outfit(_house: House) -> Outfit:
	return Outfit.default_kit()


## What the brain signs is a budget call, not a strategy. While the road is
## still being charted, the pack must cover a survey AND the courier, so it
## signs only the income deal. Once the route is documented it signs
## everything on offer — and pays for that breadth with a thinner courier
## reserve, which is the intended tension, not a bug.
static func _sign_contracts(season: Season, house: House, catalog: ContractCatalog) -> void:
	if house.route_documented():
		for template: ContractCatalog.ContractTemplate in catalog.templates:
			season.sign_contract(template)
		return
	var income_deal := catalog.by_id("urtenu_consignment")
	if income_deal != null:
		season.sign_contract(income_deal)
	# Once the House holds any paper on the road, the far guild hall's door
	# is worth a page of the pack — the confirming seasons spend seals.
	if not house.surveyed_legs.is_empty() or not house.rumoured_legs.is_empty():
		var access_deal := catalog.by_id("sojourners_right")
		if access_deal != null:
			season.sign_contract(access_deal)


static func _play_out(season: Season, route: Route) -> void:
	var guard := 0
	while not season.is_over() and guard < 64:
		guard += 1
		season.travel_next()
		if season.is_over():
			return
		_consider_writing(season, route)
		# At the far guild hall, after the writing is done (a spent survey
		# frees pack room), restock seals if the pouch is low.
		if season.position == route.last_index() and season.seals <= 1:
			season.buy_seal()


static func _consider_writing(season: Season, route: Route) -> void:
	var node: Route.RouteNode = route.nodes[season.position]
	var travel_still_owed: int
	if season.heading_home:
		travel_still_owed = season.position * Season.TRAVEL_COST
	else:
		travel_still_owed = (route.last_index() * 2 - season.position) * Season.TRAVEL_COST
	var to_spare := season.daylight - travel_still_owed - HOME_BUFFER
	# A bad season admits it: when the light budget goes red, send what exists
	# home by courier. Once — a second dispatch would repeat the first.
	if to_spare < 0 and season.sent_entries.is_empty() and not season.entries.is_empty():
		season.send_courier()
		return
	# Survey the leg just completed, if the House doesn't know it and light allows.
	# One survey per season: the demo brain has read what happens to greedy scribes.
	if node.leg >= 1 and season.surveys.is_empty() and to_spare >= Ledger.daylight_cost(Ledger.EntryType.SURVEY):
		# Seal only what settles the road: the leg that completes it, or a
		# rumour a predecessor left behind. Earlier legs go home as hearsay —
		# the rumour economy gets exercised, and a courier seal stays in hand.
		var should_seal := node.leg == route.leg_count() or season.house.rumoured_legs.has(node.leg)
		season.write_entry(Ledger.EntryType.SURVEY,
			"the road as far as %s" % node.display_name, node.leg, should_seal)
		return
	# Otherwise, cheap notes at ruins — a scribe cannot help themselves.
	if node.kind == "ruin" and to_spare >= Ledger.daylight_cost(Ledger.EntryType.NOTE):
		season.write_entry(Ledger.EntryType.NOTE, "what the sea left at %s" % node.display_name)
