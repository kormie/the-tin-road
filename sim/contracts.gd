class_name ContractCatalog
extends RefCounted
## Standing contract templates (docs/design/systems.md §3): signed once at a
## settlement, resolving every leg. Income, access, or protection, ticking —
## and each one is an obligation someone can call in at the moment it is most
## expensive to honour. Contracts are content: new deals are new entries in
## data/contracts/, not code. All display strings (terms, demand, penalty)
## are data-authored — the sim never writes prose.

## The road outcomes a call-in may ride. Load-time allowlist so content
## cannot name an event the season never resolves.
const TRIGGERS: Array[StringName] = [&"shaken_down", &"peril_survived", &"turned_home"]


class ContractTemplate:
	extends RefCounted
	## One signable deal. A demand in daylight is always honoured (and can
	## strand you); a demand in silver defaults when the purse cannot cover it.

	var id: String
	var display_name: String
	var holder: String
	var sign_at: Array[String] = []
	var income_per_leg := 0
	var peril_death_chance := -1.0  # -1 = no protection clause.
	var grants_seal_access := false
	var trigger: StringName
	var demand_silver := 0
	var demand_daylight := 0
	var default_media_penalty := 0
	var voids_on_default := true
	var terms: String
	var demand: String
	var penalty: String


var templates: Array[ContractTemplate] = []


static func load_from_file(path: String) -> ContractCatalog:
	var text := FileAccess.get_file_as_string(path)
	assert(text != "", "Contract file missing or empty: " + path)
	var parsed: Variant = JSON.parse_string(text)
	assert(parsed is Dictionary, "Contract file is not valid JSON: " + path)
	return from_dict(parsed as Dictionary)


static func from_dict(data: Dictionary) -> ContractCatalog:
	var catalog := ContractCatalog.new()
	var raw_list: Variant = data.get("contracts", [])
	assert(raw_list is Array, "Contract file needs a 'contracts' array")
	for raw: Variant in (raw_list as Array):
		assert(raw is Dictionary, "Each contract must be an object")
		var cd := raw as Dictionary
		var t := ContractTemplate.new()
		t.id = str(cd.get("id", ""))
		assert(t.id != "", "A contract needs an id")
		t.display_name = str(cd.get("display_name", t.id))
		t.holder = str(cd.get("holder", ""))
		for place: Variant in (cd.get("sign_at", []) as Array):
			t.sign_at.append(str(place))
		t.income_per_leg = int(cd.get("income_per_leg", 0))
		t.peril_death_chance = float(cd.get("peril_death_chance", -1.0))
		t.grants_seal_access = bool(cd.get("grants_seal_access", false))
		t.trigger = StringName(str(cd.get("trigger", "")))
		assert(TRIGGERS.has(t.trigger),
			"Contract '%s' names an unsupported trigger: %s" % [t.id, t.trigger])
		t.demand_silver = int(cd.get("demand_silver", 0))
		t.demand_daylight = int(cd.get("demand_daylight", 0))
		t.default_media_penalty = int(cd.get("default_media_penalty", 0))
		t.voids_on_default = bool(cd.get("voids_on_default", true))
		t.terms = str(cd.get("terms", ""))
		t.demand = str(cd.get("demand", ""))
		t.penalty = str(cd.get("penalty", ""))
		catalog.templates.append(t)
	return catalog


func by_id(contract_id: String) -> ContractTemplate:
	for t: ContractTemplate in templates:
		if t.id == contract_id:
			return t
	return null
