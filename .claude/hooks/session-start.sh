#!/usr/bin/env bash
# SessionStart hook — provisions the toolchain ./scripts/check.sh needs.
#
# Claude Code on the web starts from a bare container: no Godot, no gdUnit4,
# no import cache. This installs the same pinned engine CI uses, fetches the
# test framework, primes the import cache, and pre-fetches the web export
# templates, so an agent's first `./scripts/check.sh` is a real verification
# rather than a tool hunt.
#
# Idempotent: everything is guarded by an existence check, so re-running on a
# cached container is a few seconds of no-ops.
#
# Escape hatches (set in the environment's variables, if you want a leaner box):
#   TIN_SKIP_EXPORT_TEMPLATES=1   don't pre-fetch the web export templates
#   TIN_SKIP_PANDOC=1             don't apt-install pandoc (codex EPUB step)
set -euo pipefail

# Local machines already have a toolchain (and a Godot the developer chose).
# Only provision the remote container.
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
	exit 0
fi

REPO="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
cd "$REPO"

# CI is the referee, so CI pins the version. Read it from the workflow rather
# than keeping a second copy that can drift.
GODOT_VERSION="$(sed -n 's/^ *GODOT_VERSION: *//p' .github/workflows/ci.yml | head -1)"
GODOT_VERSION="${GODOT_VERSION:-4.6.3-stable}"

BIN_DIR="$HOME/.local/share/godot/bin"
GODOT_BIN="$BIN_DIR/Godot_v${GODOT_VERSION}_linux.x86_64"
LINK_DIR="$HOME/.local/bin"

echo "== Godot ${GODOT_VERSION} =="
if [ ! -x "$GODOT_BIN" ]; then
	mkdir -p "$BIN_DIR"
	curl -sSL -o "$BIN_DIR/godot.zip" \
		"https://github.com/godotengine/godot-builds/releases/download/${GODOT_VERSION}/Godot_v${GODOT_VERSION}_linux.x86_64.zip"
	unzip -o -q "$BIN_DIR/godot.zip" -d "$BIN_DIR"
	rm -f "$BIN_DIR/godot.zip"
	chmod +x "$GODOT_BIN"
	echo "installed $("$GODOT_BIN" --headless --version)"
else
	echo "already present ($("$GODOT_BIN" --headless --version))"
fi

# CLAUDE.md's commands say plain `godot`; the scripts honour $GODOT. Serve both.
mkdir -p "$LINK_DIR"
ln -sf "$GODOT_BIN" "$LINK_DIR/godot"
if [ -n "${CLAUDE_ENV_FILE:-}" ]; then
	{
		echo "export GODOT=\"$GODOT_BIN\""
		echo "export PATH=\"$LINK_DIR:\$PATH\""
	} >> "$CLAUDE_ENV_FILE"
fi
export GODOT="$GODOT_BIN"
export PATH="$LINK_DIR:$PATH"

# pandoc: only the EPUB half of ./scripts/build_codex.sh needs it, and that
# script degrades to markdown without it — so a failure here is not fatal.
if [ "${TIN_SKIP_PANDOC:-}" != "1" ] && ! command -v pandoc > /dev/null; then
	echo "== pandoc (codex -> EPUB) =="
	if ! (apt-get install -y --no-install-recommends pandoc > /tmp/tinroad_pandoc.log 2>&1 \
		|| (apt-get update > /dev/null 2>&1 && apt-get install -y --no-install-recommends pandoc > /tmp/tinroad_pandoc.log 2>&1)); then
		echo "pandoc install failed — build_codex.sh will still emit markdown. See /tmp/tinroad_pandoc.log" >&2
	fi
fi

# gdUnit4 (pinned) + the import cache. The repo already owns this step; keep it
# quiet unless it fails, then show everything.
echo "== gdUnit4 + import cache =="
if ! ./scripts/setup.sh > /tmp/tinroad_setup.log 2>&1; then
	cat /tmp/tinroad_setup.log >&2
	echo "scripts/setup.sh failed — the test framework is missing." >&2
	exit 1
fi

# Web export templates (~1 GB download, web slice kept). Pre-fetching here means
# it lands in the cached container instead of costing a session its first export.
if [ "${TIN_SKIP_EXPORT_TEMPLATES:-}" != "1" ]; then
	echo "== web export templates =="
	./scripts/export_web.sh --fetch-templates-only \
		|| echo "template fetch failed — export_web.sh will retry on demand" >&2
fi

echo
echo "Toolchain ready: godot $("$GODOT_BIN" --headless --version), gdUnit4, $(command -v pandoc > /dev/null && echo pandoc || echo 'no pandoc')."
echo "Verify anything with ./scripts/check.sh — that is what done means here."
