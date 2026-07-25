#!/usr/bin/env bash
# The verification loop. One command, green or red — this is what "done" means.
# Agents: run this before claiming any change works. Humans too.
set -euo pipefail
cd "$(dirname "$0")/.."
GODOT="${GODOT:-godot}"

echo "== import =="
"${GODOT}" --headless --path . --import > /dev/null 2>&1 || true

echo "== scene smoke (main scene boots headless) =="
timeout 60 "${GODOT}" --headless --path . --quit-after 3 > /dev/null

echo "== tests =="
if [ -d addons/gdUnit4 ]; then
  "${GODOT}" --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests --ignoreHeadlessMode
else
  echo "gdUnit4 missing — run ./scripts/setup.sh first." >&2
  exit 1
fi

echo "== demo (a chronicle must render, deterministically) =="
TIN_SEED=1259 TIN_SEASONS=6 "${GODOT}" --headless --path . -s scripts/demo_season.gd > /tmp/tinroad_demo_a.txt
TIN_SEED=1259 TIN_SEASONS=6 "${GODOT}" --headless --path . -s scripts/demo_season.gd > /tmp/tinroad_demo_b.txt
diff -q /tmp/tinroad_demo_a.txt /tmp/tinroad_demo_b.txt > /dev/null
grep -q "The Chronicle of" /tmp/tinroad_demo_a.txt

echo "== measurement (the five signals must report, deterministically) =="
TIN_SEEDS=1259,735 TIN_SEASONS=8 "${GODOT}" --headless --path . -s scripts/measure.gd > /tmp/tinroad_measure_a.txt
TIN_SEEDS=1259,735 TIN_SEASONS=8 "${GODOT}" --headless --path . -s scripts/measure.gd > /tmp/tinroad_measure_b.txt
diff -q /tmp/tinroad_measure_a.txt /tmp/tinroad_measure_b.txt > /dev/null
# Every signal in docs/design/vertical-slice.md must appear, including the one
# the build refuses to score. A silently dropped signal is the failure this
# guards against.
for signal in \
  "Daylight spent writing vs travelling" \
  "A full route surveyed" \
  "Reaction at first automated return" \
  "Whether the Courier is used" \
  "Whether season two differs from season one"
do
  grep -q "${signal}" /tmp/tinroad_measure_a.txt || {
    echo "measurement dropped a signal: ${signal}" >&2; exit 1; }
done
grep -q "\[NOT MEASURED\] Reaction at first automated return" /tmp/tinroad_measure_a.txt || {
  echo "the reaction signal must stay unscored — it is watched, not measured." >&2; exit 1; }

echo
echo "ALL CHECKS PASSED"
