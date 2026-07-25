# Measurement

The plan that closes milestone 1. `docs/design/vertical-slice.md` names five
signals and says "impressions after the fact are not usable data here." This
document says, for each of them, exactly what is computed from what — and for
the one that cannot be computed, says so instead of inventing a proxy.

It gates milestones 2 and 3. A baseline taken after the loop changes is a
baseline for a different loop.

---

## The split, first

Three of the five signals are instrumented. Two are half-instrumented. One is
not instrumented at all and never will be.

| # | Signal | Build measures | Human observes |
|---|---|---|---|
| 1 | Daylight writing vs travelling | the whole thing | nothing |
| 2 | A full route surveyed **unprompted** | whether, and in which season | whether a hint was needed, and which one |
| 3 | Reaction at first automated return | **nothing** — it points at the moment | **all of it** |
| 4 | Whether the Courier is used | the whole thing | whether they knew it existed |
| 5 | Whether season two **feels** different | what season two inherited | whether that reads as progress |

Signal three is the hypothesis. "Watch faces, not surveys" is an instruction,
not a caveat, and the build honours it by refusing to score it: the pass prints
`[NOT MEASURED]` and names the season to be in the room for. `scripts/check.sh`
asserts that it stays that way. The protocol for the human half of every row in
that table is `playtest-script.md`.

---

## Running it

```bash
godot --headless --path . -s scripts/measure.gd            # 3 seeds x 8 seasons
TIN_SEEDS=1259,735 TIN_SEASONS=12 godot --headless --path . -s scripts/measure.gd
TIN_FORMAT=jsonl godot --headless --path . -s scripts/measure.gd   # one season per line
```

A human session emits the same records. Capture stdout and sieve it:

```bash
grep '^TINMEASURE ' session.log | sed 's/^TINMEASURE //' > playtest.jsonl
```

The playable layer emits a record whenever a season closes, and again if a desk
action changes it (posting a standing order lands in the season just finished).
Two lines for one season is expected — the later one wins.

---

## How the log carries it

Measurement reads `ChronicleEvent`s and nothing else. `chronicle/renderer.gd`
reads the same log for prose; `measure/` reads it for numbers; neither knows
anything the other cannot see. Nothing in `sim/` counts anything, and a season
nobody measures plays identically.

Two pieces of the log were added to make this possible, because two things the
sim did were genuinely unobservable.

**Daylight had no attribution.** `sim/season.gd` now names a bucket at every
spend — `travel`, `writing`, `road` (what the road takes regardless of any
choice), `obligation` (a contract called in) — and the next event emitted
carries the tally away as `light_travel`, `light_writing`, `light_road`,
`light_obligation`. Attribution happens at the point of spending, so it cannot
drift from what was actually paid. The season-ending events (`returned`,
`fell`, `stranded`) carry `light`, what was never spent at all. That closes an
identity worth stating, because it is what `test_measurement.gd` asserts:

> the four buckets + what was left = 40, the season's whole budget

with one exception: the road bills in full against an empty purse, so a final
spend can overshoot. The excess is `light_short()` — how many more days the
season needed and did not have, which is a tuning number in its own right.

**A leg documented under seal changed state silently.** `_fold_surveys` emitted
`leg_rumoured` for an unsealed survey and `rumour_confirmed` for an upgrade,
but a fresh sealed survey — the most important state change in the game, the
automation threshold advancing — wrote nothing to the log. There is now a
`leg_surveyed` event, with prose in `data/chronicle/en.json`, so all three ways
a leg enters the archive leave a mark and the House's knowledge of the road is
reconstructable from the chronicle at any point in its history.

A side effect worth keeping: the book now quotes real costs. Three templates
had numbers typed into them ("three days of light") that a tuning change would
have turned into lies. They read the attributed spend instead.

---

## What each signal is computed from

### 1. Daylight spent writing vs travelling

Sum `light_writing` across every event of every season; divide by the sum of
all four buckets. `heavy_surcharge` is the part of `light_travel` above the
base fare — clay's weight, in days. Reported alongside: the road's own toll,
obligations, light never spent, and the average overshoot on seasons that ran
out.

### 2. Whether a full route gets surveyed

The season carrying `route_documented`, per run; the median across runs, and
the count of runs that never got there. A run that never documents the road has
failed the slice's question and the pass says `WATCH` regardless of the median.

The word **unprompted** is not in this number. `playtest-script.md` §2 has the
hint ladder and the facilitator records which rung was needed.

### 3. Reaction at the first automated return

Not computed. The pass reports the season in which the first `caravan_returned`
lands and how many seasons of play precede it, so an observer knows which
session to be present for and what to be watching when. `playtest-script.md` §3
is the protocol; it produces a rubric score and a quote, not a number.

### 4. Whether the Courier is used

Share of seasons carrying a `courier_sent`. Reported alongside the thing that
actually calibrates the price: how many seasons ended on the road, how many of
those had already couriered, and how many entries — and surveys specifically —
never reached the archive. A courier that is too expensive shows up as a rising
pile of lost writing, not as a low percentage on its own.

### 5. Whether season two differs from season one

What season two *opens* on: legs of known road inherited, archived entries,
treasury. Legs inherited is the headline, because it is the number that can
falsify the generational premise outright — zero legs means season one bought
the House nothing it can point at.

Whether that reads as progress is `playtest-script.md` §5.

---

## The bands

The thresholds live in `data/measure/bands.json`, so arguing with one means
editing a file and saying why in the commit. They are **predictions, written
before the playtests**, which is the only way to stop a disappointing result
being retrofitted into a satisfying one.

| Signal | Healthy | Worrying |
|---|---|---|
| Writing share of spent light | 25–45% | Under 25% is "players optimise writing away". Over 45% means travel is too cheap to be a real alternative. |
| Seasons to a documented road | 2–5 | Above 5 the goal is illegible or unaffordable. Never is a failed run. Below 2 would mean the threshold is trivial. |
| Reaction at first automated return | an unprompted reaction | silence, or a scroll past |
| Seasons in which a courier is sent | 10–40% | Under 10% *with entries being lost* means the price is prohibitive. Over 40% means it is simply correct and has stopped being a decision. |
| Legs inherited at season two | 1–3 | Zero is "inheritance reads as a reset", and the generational premise is in trouble. |

---

## What the automated pass can and cannot tell you

`scripts/measure.gd` runs the reference brain in `chronicle/demo_runner.gd`,
which is a placeholder for a human and bad at the game on purpose. So:

**It is** an instrumentation check, a determinism check, and a tripwire — if a
tuning change moves the split, you find out in `check.sh` rather than in a
playtest three weeks later.

**It is not** playtest data, and reporting it as such would be the single
easiest way for this whole apparatus to mislead. The report says so at the top,
every time.

The pass also prints **what it never exercised**. A signal computed over zero
observations is an absence, not a finding, and the two look identical at a
glance: the bot's `0% courier use` reads as damning until you notice nothing in
the pass ever tried to send one. Anything in that block should be read as
"unknown", not "bad".

---

## What the first playtest did to this document

One session, two seasons, seed 101: `playtests/session-01.md`. It moved no
band and touched no constant, because it never reached the choices the
constants govern — the road was never documented and **signal 3 never fired**.
Its finding was comprehension, not tuning: the survey was understood as
"recon about the current location" rather than as the leg of road behind you,
and everything downstream followed from that.

Two things here are worth reading in that light. Signal 5's band was
contradicted by the player it was measuring (see below). And the bands on
signals 2 and 3 remain **completely untested by a human** — the reference brain
is the only thing that has ever exercised them.

---

## Numbers I would argue about

Written down because the brief asked for the ones worth arguing over, and
because the first pass has already produced one real problem.

**The writing-share band may be arithmetically unreachable.** The slice route
is six nodes out and back: ten steps at `TRAVEL_COST` 2 = **20 daylight of the
season's 40 is mandatory travel** before a single decision is made. Over the
first pass the road's own toll averaged another ~10 days a season. That leaves
about 10 days for writing — a ceiling of roughly **25%**, which is exactly the
*floor* of the 25–45% band. A player who wrote as much as the season allows
would still barely clear the low bar, and 45% is not reachable at all. One of
these is wrong: the band, `STARTING_DAYLIGHT`, or `TRAVEL_COST`. My guess is
the band was written for a season with more slack in it than this one has, and
that the honest fix is daylight up rather than the band down — but that is a
tuning argument to have with playtest numbers in hand, not this bot's.

**A third of the season goes to neither side of the central tension.** The
road's toll ran at ~29% of spent light. The signal is framed as writing *vs*
travelling; in practice the biggest single line item after travel is the road
taking light from you regardless of what you chose. That may be correct — the
road is supposed to be an antagonist — but it means the "tension" the signal
tests is being fought over a smaller budget than 40 suggests, and the failure
condition "the season clock is too tight" should be read with that in mind.

**Seasons-to-documented sits on the band's edge.** Median 5 against a healthy
ceiling of 5, and one of three seeds never documented the road in eight
seasons. That is the reference brain's caution rather than a verdict on the
tuning, but if human playtests land in the same place the ceiling is wrong or
the survey is too expensive.

**The courier band is a guess.** 10–40% was written from the design intent —
"the courier should feel like an admission that this season is going badly" —
and nothing has tested it. The reference brain never sends one, so the first
real reading of this signal will come from a human, and it may well show that
the band's shape is wrong rather than its bounds.

**Legs-inherited may be too coarse.** One leg out of three is a third of a road
and scores `OK`, but a player who inherits one leg and cannot remember which
has inherited nothing they can *feel*. If §5 of the playtest keeps disagreeing
with this number, the number is measuring the wrong thing and should probably
become "did the second scribe act on what the first wrote".

> **Session 01 settled this one against the number.** Legs inherited at season
> two: 1 — inside the band. The player's account of season two: "felt like a
> fresh start." That is the "inheritance reads as a reset" failure condition,
> firing on a season the band scored healthy, exactly as predicted above. The
> first response was presentation — the outfit step now names what carried over
> — because an inheritance nobody can see cannot be an inheritance nobody
> valued. If §5 disagrees with this number a second time, the number changes.
> `playtests/session-01.md`.

---

## Files

| Path | What it is |
|---|---|
| `scripts/measure.gd` | the headless pass |
| `measure/season_record.gd` | one season, counted — the record the playable layer also emits |
| `measure/measurement.gd` | per-run facts, the five signals, and the coverage gaps |
| `measure/measure_report.gd` | the words for the numbers |
| `data/measure/bands.json` | healthy vs worrying, as data |
| `docs/design/playtest-script.md` | the human half |
| `tests/test_measurement.gd` | the accounting identity, and that signal three stays unscored |
