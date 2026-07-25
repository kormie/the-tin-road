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

echo
echo "ALL CHECKS PASSED"
