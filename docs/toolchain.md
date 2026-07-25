# Toolchain

The rule that decides whether a tool enters this project: **it must be
drivable headless, by API, or by editing text** — because the developer is
often a phone and an AI agent, not a person at a workstation. A tool that only
works through a human pointing at a GUI does not get a seat.

## Core (in use now)

| Tool | Role | AI-native driver |
|---|---|---|
| Godot 4.7.x | Engine | `godot --headless --path .` for import, tests, demos; scenes/scripts are text |
| gdUnit4 (pinned v6.1.3) | Tests | `./scripts/check.sh`, also run in CI |
| pandoc | Codex → EPUB | `./scripts/build_codex.sh` |
| git + GitHub Actions | Truth | CI runs the full check on every push — a green check means `check.sh` passed on a clean machine |
| Claude Code | Primary builder | Reads CLAUDE.md; the repo *is* the interface. Optional: a community Godot MCP (e.g. `npx @coding-solo/godot-mcp`) for run/inspect loops, though most edits need no editor bridge |

## Working from a phone

This repo assumes no laptop. Two good paths:

**Bootstrap (one-time):** create an empty GitHub repo → open a **Codespace**
in the mobile browser → upload the zip via the file explorer → in the
terminal: `unzip *.zip && rm *.zip && git add -A && git commit -m "Season zero" && git push`.
(The iOS app **Working Copy** also imports zips and pushes, if you prefer a
native client.)

**Daily loop:** drive **Claude Code from the Claude mobile app** against the
GitHub repo. The agent edits, runs `./scripts/check.sh` in its sandbox, and
pushes; you review diffs and watch Actions go green. CI is the referee, so
"works on my machine" is never in dispute — there is no machine.

**The sandbox provisions itself.** A remote session starts from a bare
container with no engine in it, so `.claude/hooks/session-start.sh` (registered
in `.claude/settings.json`) installs the toolchain before the agent's first
turn: the Godot version CI pins — read out of `.github/workflows/ci.yml` so the
two cannot drift — plus gdUnit4, a primed import cache, pandoc for the codex
EPUB, and the web export templates. Cold that is about a minute; warm, on a
cached container, a few seconds of existence checks. It is a no-op outside a
remote session (`$CLAUDE_CODE_REMOTE`), so it never touches the Godot on your
own machine. The effect is that `./scripts/check.sh` and `./scripts/export_web.sh`
work in a session's first minute, and an agent has no excuse to claim a change
works without running them.

## Anticipated (with the AI-native path named in advance)

**2D art — the only art this game needs.** Fresco-style pieces come from
image-generation models using `docs/art-direction.md`; post-processing
(crops, WebP, palette checks) is ImageMagick/Pillow in scripts. Import is
`godot --headless --import`. No drawing app in the loop.

**Audio — tool now chosen; see `docs/audio-direction.md`.** That file was the
precondition this table demanded, and it exists. The tool is **ElevenLabs**
(sound effects, text-to-speech, voice design, music), driven from `scripts/`
by API against `data/audio/manifest.json`, hash-locked so nothing regenerates
unchanged, and imported headless. A first slice of it arrives at milestone 2,
gated on the vertical slice's measurement data; the rest waits for milestone 9.

The rule that matters more than the tool: **build-time only, never runtime.**
A key in a web export is a key given away, a per-player API bill is a business
model nobody asked for, an offline player would lose the game's voice, and
generation that varies per playthrough would break "same seed, same story."
Generated audio is committed content, exactly like generated art.

Licensing is an open gate, not a settled question — commercial rights depend
on the account tier, and `audio-direction.md` requires the tier and date be
recorded there before any generated second ships in a build.

**Fonts.** OFL-licensed only (the site work used Fraunces + Instrument Sans +
IBM Plex Mono — same family thinking applies in-game). Licenses ship in
`assets/fonts/` alongside the files.

**Blender: not needed.** This is a 2D, UI-heavy game; nothing on the roadmap
requires 3D. If that ever changes (marketing renders, a diorama experiment),
Blender runs fully headless (`blender -b -P script.py`) and a Blender MCP
exists that pairs with the Godot MCP in one agent session — the roadmap will
say so explicitly before any milestone assumes it. You will not discover a
tool requirement by surprise; adding one requires updating this file first.

**Localization (far future).** Godot's translation system is CSV/PO text —
agent-friendly by construction. The chronicle templates in
`data/chronicle/en.json` are already keyed by language for this reason.
