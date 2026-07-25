#!/usr/bin/env bash
# One-time setup: fetch the pinned test framework and prime the import cache.
# Requires: git, and `godot` (4.6.x) on PATH or in $GODOT.
set -euo pipefail
cd "$(dirname "$0")/.."

GDUNIT_TAG="v6.1.3"  # verified against Godot 4.6.3
GODOT="${GODOT:-godot}"

if [ ! -d addons/gdUnit4 ]; then
  echo "Fetching gdUnit4 ${GDUNIT_TAG}..."
  tmp="$(mktemp -d)"
  git clone --depth 1 --branch "${GDUNIT_TAG}" https://github.com/MikeSchulze/gdUnit4.git "${tmp}/gdUnit4"
  mkdir -p addons
  cp -r "${tmp}/gdUnit4/addons/gdUnit4" addons/
  rm -rf addons/gdUnit4/test "${tmp}"
else
  echo "gdUnit4 already present."
fi

echo "Priming the Godot import cache..."
"${GODOT}" --headless --path . --import > /dev/null 2>&1 || true

echo
echo "Ready. Try:"
echo "  ./scripts/check.sh                # the whole verification loop"
echo "  ${GODOT} --headless --path . -s scripts/demo_season.gd   # read a chronicle"
