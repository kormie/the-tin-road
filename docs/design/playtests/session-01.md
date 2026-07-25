# Playtest 01 — the first one

Seed 101, two seasons, both survived. Unfacilitated: the player was alone with
the build and wrote notes afterwards, so §3 and §5 were reconstructed from
questions asked after the fact rather than from a face in the room. That is
weaker evidence than the script asks for and it is marked as such below.

The `TINMEASURE` lines are in `session-01.jsonl`.

**The finding, in one sentence:** nothing was wrong with the tuning, and the
slice's question still went unanswered, because the road was never documented,
because the survey was never understood.

---

## Recording sheet

```
session 01   date 2026-07-25   facilitator (none — unfacilitated)   seed 101   seasons played 2

§1  daylight remarks (verbatim): none volunteered about the clock at all.

    counted days aloud before writing?   N
    expressed regret about an entry?     N

§2  highest hint rung used: 0 (none available — no facilitator)
    documented the road?  N   in season ——
    what they thought a survey was for, before finding out:
      "more expensive than a note, and that it would gather recon about the
       current location"

§3  automated return appeared in season ——   observed?  N
    SCORE:  not reached
    NEVER FIRED. The road was not documented, so no order could be posted, so
    no caravan ever ran. The hypothesis was not tested.

§4  asked what the Courier does?   Y ("not sure what contracts do" / tried it blind)
    knew it existed before needing it?  Y — pressed it in season 1 and was refused
    lost a ledger to the road?     N    reaction: —

§5  Q1 "what does this scribe know that the last one didn't?" (verbatim):
      "felt like a fresh start"
    Q2 "anything you'll do differently?" — n/a, asked after the fact

    named the inheritance unprompted?  N

TINMEASURE lines captured?  Y   file: docs/design/playtests/session-01.jsonl
```

---

## The numbers

| | s1 | s2 | band |
|---|---|---|---|
| Writing share of spent light | 29% | **13%** | 25–45% |
| Legs known, end | 1 (rumour) | 1 (rumour) | — |
| Seasons to a documented road | — | **never** | 2–5 |
| Courier sent | no | yes | 10–40% |
| Legs inherited at season two | — | 1 | 1–3 |
| Entries lost | 0 | 0 | — |

Two seasons is far too small a sample to move a band, and none of these are
being read as verdicts on the tuning. They are read here for what they say
about comprehension.

---

## What actually happened

### The survey was understood as a place, not a stretch of road

The player's own words: a survey would "gather recon about the current
location." It does not. It documents the **leg behind you** — the stretch just
walked — and legs are the only thing the House can accumulate.

Everything downstream follows from that one wrong model:

- Season 1 wrote one survey, unsealed, which entered the archive as a rumour.
- Season 2 wrote **five notes and no surveys at all** — the cheapest button,
  pressed repeatedly, because nothing distinguished the four.
- The road was therefore never documented, so no standing order was possible,
  so **signal 3 — the entire hypothesis of the vertical slice — never fired.**

This is not a tuning failure. Both seasons had light to spare (1 and 2 days
unspent). The player could have afforded surveys and did not know they were the
thing worth affording.

### Three of the four writing buttons currently do nothing

Worth stating plainly because it is a design gap, not a UI one: `note`,
`record` and `treatise` cost daylight and media, land in the archive, and are
read by nothing. Only `survey` changes what the House knows
(`House._fold_surveys`), and only surveyed or rumoured legs are priced by
`House._archive_income`. A treatise costs 15 of 40 daylight — over a third of a
season — for an entry with no consumer.

The player asked directly: *"Do 'note', 'record', 'survey', 'treatise' cost
and/or do anything?"* The honest answer for three of them is "cost, yes; do,
not yet." That is the most valuable thing this session produced and it is a
milestone-2 item, not a copy fix.

### The refusal messages listed every cause and named none

At day 6 with 13 light, the courier was refused. The player had two seals and
concluded the run might be dead. The actual reason was media: 8 bought, 8 spent
on note + record + survey, 0 left, and the courier needs 4 to copy the ledger
onto. The message said:

> No courier goes: it takes a seal, 4 media, and something written.

All three conditions, no indication which one was true, and the one the player
had plenty of listed first. The same pattern applied to every other refusal in
the build. The player's response — *"I end up just clicking all four hoping
something happens"* — is the correct response to a game that refuses without
saying why.

### Nothing announced the empty pack

Running out of media was the game's one wholly silent state change. Nothing in
the book, nothing on the panel. From that moment the season is a walk home, and
the player had no way to know that was a known state rather than a bug — hence
"is the run essentially DOA?" (It was not: the scribe walked home and merged
three entries.)

### The seal checkbox was invisible, and it is the sealed/rumour switch

Not seen at all, and its function not guessed. Consequence, in the log:
`surveys_sealed: 0`, `legs_sealed_end: 0`. Two seals were bought in each
season and neither was ever knowingly spent. The single survey the player did
write landed at half value because of a control they could not see.

### The season summary was written for a facilitator

*"It says the scribe came home with 3 entries and none lost. Not sure what that
means."* Correct — that line was `SeasonRecord.headline()`, an instrument for
whoever is running the session, printed to the person playing.

### Signal 5 fired the failure condition the number scored as healthy

`measurement.md` predicted this, in the "numbers I would argue about" section:

> a player who inherits one leg and cannot remember which has inherited
> nothing they can *feel*.

Legs inherited at season two: **1** — inside the healthy band of 1–3. The
player's description of season two: **"felt like a fresh start."** The band and
the human disagree, and on this signal the human is the measurement. The number
is not wrong, it is measuring the wrong thing.

---

## What changed as a result

Legibility only. No tuning constant was touched, deliberately: nothing in this
session is evidence about the tuning, because the player never got far enough
to make the choices the tuning governs.

| Finding | Change |
|---|---|
| Refusals list every cause | `Season.preview_*_reason()` — the sim names one reason, presentation prints that one |
| Buttons priced nowhere | Costs read onto every button from `Ledger`/`Season` constants |
| Four indistinguishable buttons | One line each, from `data/ui/glossary.json` |
| Survey read as a place | That line says "the leg of road behind you — not the place you are standing in" |
| Empty pack silent | New `stock_spent` event + prose in `en.json` |
| Seal checkbox invisible | States its setting in words, and how many seals remain |
| Contracts opaque | Terms rendered from the contract's own numbers, beside each button |
| Desk written for a facilitator | Plain summary for the player; headline kept, marked, and demoted |
| Inheritance illegible | "What this scribe inherits" on the outfit panel; legs named, not numbered |

### The line held

The build now says what a survey **is**. It still does not say what documenting
a road **buys** — no mention of the standing order, the caravan, or that three
legs is a threshold. `playtest-script.md` §2 measures whether a player finds
that out unprompted, and one sentence in the UI would end that measurement
permanently. `data/ui/glossary.json` carries that constraint in its header.

Naming the legs did cost one hint rung: the archive is now visible by default,
so §2's rung 3 ("have a look at what the archive is holding") no longer says
anything the screen isn't already showing. The ladder has been rewritten
accordingly.

---

## What to watch in session 02

1. **Does the survey get written now?** If a player who can read what a survey
   is still does not write one, the problem is cost, not copy, and the tuning
   argument in `measurement.md` becomes the live one.
2. **Signal 3, finally.** No session has reached it. Until one does, the
   vertical slice has not been evaluated.
3. **Does the empty pack now read as a decision that was made** — "I spent it"
   — rather than as a fault?
4. **Ask §5's two questions at the outfit step, in the room.** The inheritance
   panel is a fix aimed squarely at "fresh start" and it is unproven.
5. **Three inert buttons.** Watch whether a player who now knows what a
   treatise costs ever writes one, and what they expect to get.
