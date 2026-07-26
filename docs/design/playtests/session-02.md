# Playtest 02 — the road documented, the return unseen

Seed 101, sixteen seasons, one sitting. Unfacilitated, again: the player was
alone with the build, and this sheet is reconstructed from a conversation with
them afterwards. That is the same weakened evidence as session 01 and it is
marked below wherever it matters. Same seed as session 01, so the two runs are
directly comparable leg for leg.

The `TINMEASURE` lines are in `session-02.jsonl` — seventeen of them: sixteen
closed seasons, plus the re-emit at season 16 when the standing order was
posted at the desk.

**The finding, in one sentence:** the road was documented and the order was
posted — sixteen seasons of progress session 01 never made — and the slice's
question is *still* unanswered, because the player closed the app at the
order, one click short of the return, and the build gave them no reason to
think anything was still owed.

---

## Recording sheet

```
session 02   date 2026-07-26   facilitator (none — unfacilitated)   seed 101   seasons played 16

§1  daylight remarks (verbatim): none captured — reconstructed session.

    counted days aloud before writing?   not observed
    expressed regret about an entry?     not observed

§2  highest hint rung used: 0 during play (no facilitator).
    documented the road?  Y   in season 16
    what they thought a survey was for, before finding out (verbatim,
    after the session):
      "it seems like I took some scribe actions along the way and then
       eventually it made me able to start a caravan… Not exactly sure how I
       unlocked this caravan or what it did. Honestly i just clicked a bunch
       and eventually the bar became fully yellow and that allowed me to
       start a caravan… I think?"
    NOTE: after the session the full mechanism was explained to the player.
    Signal 2 is permanently unmeasurable for this player from here on — their
    next run measures informed execution, not discovery.

§3  automated return appeared in season ——   observed?  N
    SCORE:  not reached
    NEVER FIRED — for a new reason. The road WAS documented and the order WAS
    posted, both in season 16. The player then quit. The return pays at the
    head of the NEXT season; there are no saves; the state is gone. Two
    sessions, two different failures to reach the same moment.

§4  asked what the Courier does?   not captured
    knew it existed before needing it?  Y — sent in seasons 12, 14, 15
    lost a ledger to the road?     Y — season 10, stranded; one survey lost,
    and no courier went that season.    reaction: not captured

§5  Q1 / Q2 — not asked (unfacilitated, and reconstructed after the fact).
    The inheritance panel added after session 01 remains untested by a
    facilitated session.
    named the inheritance unprompted?  partially — the player named the road
    strip ("the bar became fully yellow"), not the legs or the archive.

TINMEASURE lines captured?  Y   file: docs/design/playtests/session-02.jsonl
```

---

## The numbers

Computed the way `measure/measurement.gd` computes them (writing share is
writing over *spent* light — travel + writing + road toll + obligations —
not over the season's 40).

| | this run (16 seasons) | band | session 01 |
|---|---|---|---|
| Writing share of spent light | **10%** (49 of 510) | 25–45% | 29% → 13% |
| Seasons to a documented road | **16** | 2–5 | never |
| Courier sent | **19%** (3 of 16 seasons) | 10–40% | 1 of 2 |
| Legs inherited at season two | 1 (rumour) | 1–3 | 1 |
| Seasons ended on the road | 2 (fell s9, stranded s10) | — | 0 |
| …of those, ledger already couriered | **0** | — | — |
| Surveys written / sealed | 4 / **0** | — | 1 / 0 |
| Entries written / lost | 13 / 1 | — | 8 / 0 |

One player, one seed, one sitting, no facilitator: none of this moves a band,
and — same discipline as session 01 — none of it is read as a verdict on the
tuning. It is read for comprehension, and for the first time there is enough
run behind the numbers for a few of them to mean something.

---

## What actually happened

### The road was documented by attrition, not intent

Sixteen seasons against a healthy band of 2–5. The three surveys that did it
landed in seasons 1, 11, and 16 (a fourth, season 10's, died on the road with
its scribe). In between: seasons 2 through 8 wrote **nothing at all**, and six
of those seasons bought a one-shekel kit — one tablet, no papyrus, no seals —
that could barely have written anything anyway.

The player's own model of the run, afterwards: *"I just clicked a bunch and
eventually the bar became fully yellow."* That sentence is the finding. The
causal chain — a survey merges, a leg fills, three legs is a documented road,
a documented road takes a standing order — was **walked, end to end, without
ever being held**. The player reached the unlock and could not say afterwards
what had unlocked it.

Against session 01, this is real movement: surveys got written this time, so
the glossary line about what a survey *is* ("the leg of road behind you")
appears to have landed. What did not land is what a survey *does to the
House* — the link from the entry to the bar, and from the bar to the caravan,
read as correlation. The road strip made the state visible, which is what it
was built to do; visibility of state is evidently not the same thing as
visibility of cause.

### The seal was never used — sixteen seasons, four surveys, zero sealed

`surveys_sealed: 0` on every line. Session 01's fix — the seal control now
states its setting in words, and how many seals remain — is now tested by a
full-length run, and the behaviour did not move. Seals rode along in the kit
in ten of sixteen seasons and were never once spent on a survey. Every leg of
the documented road is held as rumour, so the caravan this run paid 100
shekels to post will pay out at **half share, indefinitely** — and the player
does not know that.

The caveat is the unfacilitated one, and it is exactly the fork §4 of the
script exists to resolve: an unread hint is a UI finding, a read-and-dismissed
hint is a different finding, and this sheet cannot tell them apart. A
facilitated session watching the first survey get written would settle it in
thirty seconds.

### The order read as an ending, and the player quit at it

The new failure mode, and the one this session exists in the record for.

The standing order is a setup whose receipt arrives at the head of the *next*
season. Nothing in the build says so. The player posted the order — at 100
shekels, the largest single spend of the entire run — read the desk, and
closed the app, reasonably treating the purchase as the finale. There are no
saves, deliberately; the documented road, the posted order, and the sixteen
seasons behind them are unrecoverable. Signal 3 has now failed to fire in two
sessions **for opposite reasons**: session 01 never reached the unlock,
session 02 reached it and stopped one click short of the payoff. The line the
whole slice exists to have a player read has still never been read by one.

The glossary's standing constraint (its header, and session 01's "the line
held") is that the build never says what documenting the road *buys* — that
is signal 2's discovery, and pricing it in the UI would end the measurement.
But that constraint is about **before**. A player who has posted the order
has already made the discovery; telling them, at the desk, when the caravan
will first walk — *after the order exists* — spoils nothing that has not
already happened. Post-discovery information is not a hint. That distinction
is the legibility candidate this session nominates.

### The Courier hit its band — used backwards

First signal ever measured inside its band: couriers went in 3 of 16 seasons,
19%, against 10–40%. But the pattern inverts the intent. The design calls the
Courier "an admission that a season is going badly." This run's couriers went
in seasons 12, 14, and 15 — three seasons that all came home fine, carrying
records and notes — and did **not** go in season 10, the one season that
actually died with an unsent survey in the pack. The band cannot see this;
the number scores healthy while the behaviour it is meant to certify
(insurance at the moment of danger) happened zero times in two chances. Same
lesson as session 01's signal 5: the number is not wrong, it is measuring
the wrong thing. Small sample; watch it, don't act on it.

### Nine of thirteen entries were written into the void

Seasons 11–15 wrote five notes and four records. Those are the inert types —
they cost light and media, land in the archive, and are consumed by nothing.
Session 01 called this the most valuable finding it produced; this session
adds the observation that the inert entries *look* like progress: they grew
`archive_end` season over season, and an archive visibly filling is exactly
what a player who has half-understood "documentation is the goal" would treat
as advancement. The open design question (consumers for note / record /
treatise) is still the loudest one in the slice, and it is now actively
misleading players rather than just idling.

### Seven seasons of nothing in the middle

Seasons 2–8: no writing, no couriers, no deaths, one near-empty kit after
another, +29 silver a season. The treasury growth eventually funded the
standing order, but by accident — the player was not saving toward anything
they could name. This is constraint 2's exact language — repetition that
neither compounds nor becomes automatable — showing up as a *player
experience* rather than a shipped feature. It was not economically forced:
the advance covers a full writing kit every season. It was goal-blindness;
with no known goal, the cheapest click wins. Worth watching whether an
informed player's run still contains this trough at all.

---

## What changed as a result

Nothing, yet — deliberately. This writeup exists before any change so that
the fix list is argued from the record rather than retrofitted to it. The
candidates it nominates, all legibility, no tuning, in order of confidence:

1. **A receipt at the order.** When the standing order is posted, the desk
   says when it pays: the caravan walks at the opening of the next season.
   Post-discovery, so it does not touch the glossary constraint. Directly
   addresses the way this session ended.
2. **The seal, facilitated before fixed.** The next change to the seal
   control should wait for one facilitated observation of a survey being
   written, which resolves the unread-vs-dismissed fork this sheet cannot.
3. **Cause, not just state, on the road strip.** The strip shows what the
   House knows; nothing connects the survey just merged to the leg that just
   filled. No specific fix nominated — the moment of merge (the desk) is
   where to look.

Saves came up, and are noted as considered and deferred: a suspend-and-resume
of a sitting is playtest tooling, not meta-progression, so it would not
violate constraint 1 — but the slice's question is answerable inside one
sitting, and the milestone's remaining work is running sessions, not
engineering. If the loss this session suffered recurs, the calculus changes.

---

## What to watch in session 03

Session 03 is this player again, replaying **informed** — the mechanism was
explained after this session, so signal 2 is dead for them and the session
measures execution instead of discovery. Still worth running, against
different questions:

1. **Signal 3, finally.** The player intends to replay to the return. If
   unfacilitated again, the §3 face-watch degrades to self-report; say so on
   the sheet, and record their words verbatim within thirty seconds anyway.
2. **Does an informed player document in-band?** Knowing the goal, 2–5
   seasons is the prediction. Materially over that and the cost side of the
   `measurement.md` argument — not the legibility side — becomes the live
   one.
3. **Does the seal get ticked once its purpose is known?** If yes, the
   problem was discovery and the control is fine. If still no, the control
   itself is implicated, whatever the hint text says.
4. **Do they stop at the order again?** They know the receipt timing now; if
   they still quit there, the ending is mis-shaped in a way knowledge does
   not fix.
5. **The inert buttons, knowingly.** Does a player who knows notes and
   records feed nothing ever write one again? Their answer is design data
   for the note/record/treatise question.
