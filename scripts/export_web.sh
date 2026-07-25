#!/usr/bin/env bash
# Export the playable web build. Needs Godot 4.6.x (GODOT env var or `godot`
# on PATH); fetches the matching web export templates if they are absent.
# Threads are disabled in the preset, so the result runs on any static host.
#
#   --fetch-templates-only   provision the templates and stop (used by the
#                            SessionStart hook to warm a fresh container)
set -euo pipefail
cd "$(dirname "$0")/.."
GODOT="${GODOT:-godot}"
VERSION="4.6.3"
TDIR="$HOME/.local/share/godot/export_templates/${VERSION}.stable"
if [ ! -f "$TDIR/web_nothreads_release.zip" ]; then
	echo "Fetching web export templates for ${VERSION}..."
	mkdir -p "$TDIR"
	curl -sL -o /tmp/tin_road_templates.tpz \
		"https://github.com/godotengine/godot-builds/releases/download/${VERSION}-stable/Godot_v${VERSION}-stable_export_templates.tpz"
	unzip -o -j -q /tmp/tin_road_templates.tpz 'templates/web_*' -d "$TDIR"
	rm /tmp/tin_road_templates.tpz
fi
if [ "${1:-}" = "--fetch-templates-only" ]; then
	echo "Web export templates ready in ${TDIR}"
	exit 0
fi
mkdir -p build/web
"$GODOT" --headless --path . --import > /dev/null 2>&1 || true
"$GODOT" --headless --path . --export-release "Web" build/web/index.html
echo "Web build in build/web/ — serve it:  python3 -m http.server -d build/web 8080"
