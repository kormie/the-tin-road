# The Tin Road

A run-based generational trading game set in **The Long Bronze** — an alternate
history where the Bronze Age never collapsed, seven centuries of peace have
made writing cheap, and the printing press has just arrived three thousand
years early.

You are not the hero. You are the House: a minor merchant family whose scribes
walk the tin routes one mortal lifetime at a time. **Everything a scribe
learns dies with them — unless they wrote it down.** Documentation is the
meta-progression, the automation system, and the point.

Built with Godot 4.6. Everything is text; the repo is the game.

## The pitch, demonstrated

Every playthrough is event-sourced into a chronicle, and the chronicle renders
as prose. This is seed 1259, unedited, from `docs/sample-chronicle.md`:

> The season ended where it stood, at the Salt Marsh. The ledger of Niqmepa
> never reached the archive.
>
> House Sapanu continued, as houses do, in the person of Arhalba, standing on
> everything Niqmepa left in writing.
>
> …
>
> While the House slept, a caravan walked the Ugarit road on its own and came
> home with 339 shekels, weighed. The road remembered. It had been written down.

Niqmepa surveyed the first leg and died before bringing it home, so the
knowledge died too. Three generations re-earned it, wrote it all down, and by
the fifth season the road ran itself. Nobody authored that story — the sim
emitted it, the renderer wrote it. Same seed, same book, every time.

## Quickstart

Requires [Godot 4.6.x](https://godotengine.org/download/) and git.

```bash
git init && git add -A && git commit -m "Season zero"
./scripts/setup.sh        # fetch the pinned test framework, prime imports
./scripts/check.sh        # import + scene smoke + 12 tests + demo determinism
```

Then either open the project in the Godot editor and press play, or stay
headless like a scribe of the road script:

```bash
godot --headless --path . -s scripts/demo_season.gd
TIN_SEED=735 TIN_SEASONS=8 godot --headless --path . -s scripts/demo_season.gd
```

Every seed is a different house, a different sequence of deaths and ledgers,
a different book. Seed 1259 — the Treaty year — is the committed sample.

## The ebook pipeline

The lore the game reads and the book you'd publish are the same files.
`data/codex/*.md` holds the setting entries (front matter marks which are
`[real]` attested history); the build compiles them:

```bash
./scripts/build_codex.sh   # -> build/long-bronze-codex.md (+ .epub if pandoc)
```

The chronicle of any playthrough is already markdown. "First DLC is an ebook"
is not a roadmap item; it is `pandoc` away.

## Where things are decided

`ROADMAP.md` is the build order — every deferred system lives there with a
pointer to its design. `docs/toolchain.md` is the tool policy (headless/API
or it doesn't enter), including the working-from-a-phone workflow.
`docs/art-direction.md` keeps the fresco standard.

## Repo map

```
sim/          Pure, deterministic simulation. No Nodes, no prose. Emits events.
chronicle/    Renderer (events -> prose) and the demo runner.
data/         Content: routes, names, prose templates, codex. JSON + Markdown.
game/         Scenes. Thin. Currently: a button that chronicles a house.
tests/        gdUnit4 suites. ./scripts/check.sh is the definition of done.
docs/         Design bible (docs/design/, docs/world/) + the sample chronicle.
scripts/      setup, check, demo, codex build.
CLAUDE.md     Working agreement for AI agents: conventions, constraints, rules.
```

## What this is not, yet

This is vertical-slice steps 1–2 of `docs/design/vertical-slice.md`: the season
clock, daylight, travel, the four ledger entry types, death, succession, and a
naive automation payout — enough to prove the loop
**write → die → inherit → automate → read the book**. Not built: the Courier,
the Keeper and Endurance, media weight, archive corruption, factions, presses,
real UI, saves. The design docs know the way.

## License

Undecided — all rights reserved for now. (The attested names and the Treaty
belong to history, which does not enforce copyright.)
