class_name MeasureReport
extends RefCounted
## The words for the numbers. `Measurement` computes; this prints — the same
## split `sim/` and `chronicle/renderer.gd` keep, for the same reason: the
## thing that decides and the thing that phrases should never be one thing.

const RULE := "----------------------------------------------------------------------"


## The whole pass: a season table per seed, then the five signals with their
## verdicts. Deterministic, so two runs of the same seeds diff clean.
static func render(runs: Array[Measurement], signals: Dictionary, seasons_per_run: int) -> String:
	var out := "== The Tin Road — vertical-slice measurement ==\n"
	out += "%d seed(s) x %d season(s), played by the reference brain in chronicle/demo_runner.gd.\n\n" % [
		runs.size(), seasons_per_run]
	out += _caveat()
	for m: Measurement in runs:
		out += "\n" + _run_table(m)
	out += "\n" + RULE + "\nSIGNALS\n" + RULE + "\n"
	for id: String in ["daylight_split", "route_surveyed", "first_automated_return",
			"courier_use", "season_two_delta"]:
		out += _signal_block(signals.get(id, {}) as Dictionary)
	out += _coverage_block(Measurement.coverage_gaps(runs))
	return out


## Printed last and read first, ideally. A verdict computed over nothing that
## happened is the easiest way for this report to lie to somebody.
static func _coverage_block(gaps: Array[String]) -> String:
	if gaps.is_empty():
		return "\n" + RULE + "\nEvery mechanic the signals cover was exercised at least once in this pass.\n"
	var out := "\n" + RULE + "\nWHAT THIS PASS NEVER EXERCISED\n" + RULE + "\n"
	out += "No signal above can speak to these. Read any verdict that depends on\nthem as \"unknown\", not as \"bad\".\n"
	for gap: String in gaps:
		out += "  - %s\n" % gap
	return out


## Said once, at the top, because it is the easiest thing in this file to
## forget and the most expensive to forget.
static func _caveat() -> String:
	return """These are BOT numbers. The reference brain is a placeholder for a human, so
this pass measures the instrumentation and gives tuning changes a tripwire —
it is not playtest data and must never be reported as if it were. Human
numbers come from the same SeasonRecord, emitted by the playable layer during
a session run to docs/design/playtest-script.md.

Signal three is not instrumented at all, on purpose. See its block below.
"""


static func _run_table(m: Measurement) -> String:
	var out := "%s\nseed %d\n%s\n" % [RULE, m.seed_value, RULE]
	out += "  s  scribe        outcome    day   trav writ road oblg left  entries  legs  courier  caravan\n"
	for r: SeasonRecord in m.records:
		out += "%3d  %-12s  %-9s  %3d  %5d %4d %4d %4d %4d  %3d(-%d)  %d>%d  %-7s  %s\n" % [
			r.season, r.scribe.left(12), r.outcome, r.days,
			r.light_travel, r.light_writing, r.light_road, r.light_obligation, r.light_unspent,
			r.entries_written, r.entries_lost(),
			r.legs_known_start(), r.legs_known_end(),
			"sent d%d" % r.courier_day if r.courier_sent else "-",
			"+%d" % (r.caravan_income - r.caravan_fee) if r.caravan_returned else "-",
		]
	return out


static func _signal_block(s: Dictionary) -> String:
	if s.is_empty():
		return ""
	var value_text := "—"
	if bool(s.get("measurable", true)):
		value_text = "%.1f%s" % [float(s.get("value", -1.0)), str(s.get("unit", ""))]
	var out := "\n[%s] %s\n" % [str(s.get("verdict", "?")), str(s.get("title", ""))]
	out += "        tells us: %s\n" % str(s.get("tells", ""))
	out += "         measure: %s\n" % str(s.get("metric", ""))
	out += "           value: %s   (%s)\n" % [value_text, str(s.get("band", ""))]
	var detail_raw: Variant = s.get("detail", [])
	if detail_raw is Array:
		for line: Variant in (detail_raw as Array):
			out += "                  %s\n" % str(line)
	return out


## Every season record of every run, one JSON object per line. The machine
## -readable twin of the table above, for whoever wants to plot it.
static func render_jsonl(runs: Array[Measurement]) -> String:
	var out := ""
	for m: Measurement in runs:
		for r: SeasonRecord in m.records:
			var row := r.to_dict()
			row["seed"] = m.seed_value
			out += JSON.stringify(row) + "\n"
	return out
