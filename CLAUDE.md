# CLAUDE.md — The Tin Road

Working agreement for AI agents (and forgetful humans) on this repo.

## What this is

A run-based generational trading game set in a Bronze Age that never collapsed.
Documentation is automation: what a scribe writes down is the only thing that
survives them, and a well-documented route runs itself. The full design lives
in `docs/` — read it before proposing mechanics:

- `docs/design/tin-road.md` — the core design document. Start here.
- `docs/design/systems.md` — mechanics and first-pass numbers.
- `docs/design/vertical-slice.md` — build order. Steps 1–5 are built, as is the
  measurement plan that closes milestone 1.
- `docs/design/measurement.md` — what each of the five signals is computed
  from, and what a healthy number looks like. Read before touching any first-
  pass constant: the tuning has a baseline now.
- `docs/design/playtest-script.md` — the half of the measurement that is a
  person watching a face, not a number. Signal three is deliberately not
  instrumented; do not "fix" that.
- `docs/world/` — the setting bible, timeline, and factions.
- `docs/art-direction.md` · `docs/audio-direction.md` — how it looks, how it
  sounds. Read the relevant one before generating any asset.

## The three constraints (do not violate)

1. **Meta-progression must be diegetic.** What carries between runs is written
   records. If a feature persists progress any other way, it is wrong.
2. **No repeated action ships unless it compounds or becomes automatable.**
3. **The support role is structurally central.** (The Keeper — not built yet.)

## Commands

```bash
./scripts/setup.sh        # one-time: fetch gdUnit4 (pinned), prime import cache
./scripts/check.sh        # THE loop: import + scene smoke + tests + demo. Run before claiming done.
godot --headless --path . -s scripts/demo_season.gd          # print a chronicle
TIN_SEED=735 TIN_SEASONS=8 godot --headless --path . -s scripts/demo_season.gd
godot --headless --path . -s scripts/measure.gd             # the five signals
TIN_SEEDS=1259,735 TIN_FORMAT=jsonl godot --headless --path . -s scripts/measure.gd
./scripts/build_codex.sh  # compile data/codex/*.md into the book (epub if pandoc)
```

Godot 4.7.x required (CI pins 4.7.1). Never claim a change works without a
green `./scripts/check.sh`.

## Architecture rules

- **`sim/` is pure.** `RefCounted` only — no Nodes, no scene tree, no
  `get_node`, no signals to UI, no `randi()` outside an injected `SimRng`
  stream. Everything in `sim/` must be testable headless and deterministic
  per seed. If you need the scene tree, you are in the wrong directory.
- **The sim never writes prose.** State changes emit `ChronicleEvent`s;
  `chronicle/renderer.gd` turns events into text via `data/chronicle/en.json`.
  New sim behavior = new event type = new template variants, in that order.
  The test `test_renderer_covers_every_emitted_event_type` enforces this.
- **`sim/` is also silent.** No `AudioStreamPlayer`, no audio bus, no cue
  lookup in `sim/`. Sound binds off `ChronicleEvent`s in `game/`, the way prose
  binds off them in `chronicle/renderer.gd`. Silence is a valid cue — most
  events should make none. Generated audio is baked at build time by
  `scripts/`, committed, and imported headless; **no audio API is ever called
  at runtime.** Doctrine: `docs/audio-direction.md`.
- **Content is data.** Routes, names, prose templates, lore, and the tuning
  bands the measurement judges against live in `data/` as JSON/Markdown.
  Adding content should not require code.
- **`measure/` reads the log for numbers**, exactly as `chronicle/renderer.gd`
  reads it for prose. Neither knows anything the other cannot see. Measurement
  never becomes a system inside `sim/`: a season nobody measures must play
  identically. If a signal has no event behind it, the order is new event type
  → new prose variants in `data/chronicle/en.json` → then the measurement.
- **`game/` binds sim to presentation** and stays thin.
- **Determinism is sacred.** Same seed, same story. All randomness flows
  through `SimRng` named streams. Adding a stream is fine; sharing one
  between systems is not.

## GDScript conventions (Godot 4.7 — strict mode is ON)

`untyped_declaration` is set to **error** in project.godot. Everything is typed:

- `var x: int = 3` or `var x := 3` (inferred, non-Variant). Annotate Variants
  explicitly: `var parsed: Variant = JSON.parse_string(text)`.
- Loops: `for e: ChronicleEvent in events:` · `for i: int in range(n):`
- Tabs for indentation. `class_name` + `extends` on the first lines.
- Signals connect Godot-4 style: `button.pressed.connect(_on_pressed)`.
- **Never** use Godot 3 idioms: no `onready var` (use `@onready`), no
  `export var` (use `@export`), no `yield` (use `await`), no
  `connect("sig", self, "_fn")` string form, no `KinematicBody`.
- StringName literals for event types: `&"season_began"`.
- Doc comments with `##` on every class and public function.

## Testing rules

- Every `sim/` change lands with a gdUnit4 test in `tests/`.
- Tests extend `GdUnitTestSuite`; keep them deterministic (fixed seeds).
- The road can kill scribes in fixtures — tests that travel must tolerate or
  pin seeds around it.

## Current honest state

Vertical-slice steps 1–5 and the slice's Scribe kit: season clock, daylight,
node traversal, the Ledger's four entry types, death (stranding/peril),
succession, the Courier (snapshot dispatch, partial merge on death), seals as
authentication (unsealed surveys merge as half-value rumours), the outfit step
(patron advance, priced and bulk-capped kit), Standing Contracts (road-wired
call-ins, the season purse, contract-gated seal replenishment), media types
that matter (water ruins papyrus, heavy packs cost daylight), assignable
automation (a standing order in the archive: silver to post, a per-season
caravan fee, income scaled by archive quality), the chronicle pipeline, a
playable text-first UI (`game/session.gd` — thin, attempt-and-report), a
web-export pipeline (`scripts/export_web.sh`, CI artifact), and the
measurement plan that closes milestone 1 (`scripts/measure.gd` over seeded
runs; the same per-season record emitted by the playable layer as
`TINMEASURE` lines; four signals computed, the fifth deliberately left to a
human — `docs/design/measurement.md`, `docs/design/playtest-script.md`).
**One playtest has now been run** (`docs/design/playtests/session-01.md`, two
seasons, seed 101) and the slice's question is still unanswered: the road was
never documented, so no caravan ever ran, so signal 3 never fired. The finding
was comprehension, not tuning — the survey was read as "recon about the current
location" rather than the leg of road behind you. What followed was a
legibility pass and no constant changed: sim-owned refusal reasons
(`Season.preview_*_reason` — the sim names one reason, `game/` prints that one),
costs read onto every button from the constants, a `stock_spent` event so the
empty pack stops being silent, named legs (`Route.leg_name`), and an
inheritance panel at the outfit step. **A second legibility pass made the
season visual** (still no constant changed): a drawn road strip
(`game/road_strip.gd` — node shapes by kind, each leg in one of four states:
unknown contour, rumoured half-fill, sealed solid, written-this-season-but-
unmerged in kiln red, which is the Courier's stake made visible; scribe
marker with direction) at the outfit step, on the road, and at the desk; and
a daylight bar (`game/daylight_bar.gd`) over the live season, splitting spent
light into the four attributed buckets read from the same `SeasonRecord` the
measurement computes, with the next act's daylight price outlined as a ghost —
cost shown, availability never predicted. Both are flat `_draw` primitives,
no raster art. The palette's one shipped home is `data/ui/palette.json`
(loaded by `game/palette.gd`), mirrored from `design-system/tokens.json`
under test (`tests/test_palette.gd`); `main.tscn` carries semantic `ink_*`
groups instead of inline hex. **Three of the four entry types —
`note`, `record`, `treatise` — still have no consumer:** they cost daylight and
media and are read by nothing. Only `survey` changes what the House knows.
That is the loudest open design question the slice has.
**Not built:** order revocation, incident reports and caravan loss,
the Keeper and Endurance,
archive corruption, factions beyond the Yabninu commission const, presses, the
Concord axis, any real UI beyond the text panels and the two drawn widgets,
saves. **No audio of any kind** — the game is
currently silent, and `docs/audio-direction.md` is doctrine for a pipeline that
does not exist yet. Do not gold-plate scaffolding; the next
milestone is `docs/design/vertical-slice.md`.
