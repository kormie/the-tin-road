# Playtest script

For the facilitator. Read it before the session; keep the recording sheet at
the end of it open during.

This covers the half of the measurement plan that is not instrumented. The
build handles the arithmetic (`docs/design/measurement.md`); what it cannot do
is watch somebody's face at the moment the game either works or does not. That
moment is §3, it is the whole hypothesis, and everything else in this script
exists so that it is not contaminated before it arrives.

**Sessions are two seasons minimum.** A single-season session cannot test the
thing and is not worth running.

Sessions run so far: `playtests/session-01.md`, `playtests/session-02.md`.
Read the last one before running the next — several of session 01's findings
became changes to the build that this script has not yet been used to check,
and session 02 ended one click short of §3 in a way the next session should
be braced for.

---

## Before

- **Capture stdout.** The playable layer prints one `TINMEASURE ` line per
  closed season. Without it you have notes and no numbers.
  `grep '^TINMEASURE ' session.log | sed 's/^TINMEASURE //' > playtest.jsonl`
- **Note the seed** the player enters. Same seed, same road — two sessions on
  one seed are directly comparable.
- **Be able to see their face.** A shared screen is not enough for §3. If the
  session is remote, camera on, and say why: "there's one moment later I need
  to watch you for, and I'll explain afterwards."
- **Run `scripts/measure.gd` on their seed first** if you can. It tells you
  which season the first automated return lands in, so you know which stretch
  of the session to stop taking notes and start watching.

### Rules of the room

1. **Explain the controls, never the goal.** "This is the button that writes an
   entry" is fine. "You'll want to survey all three legs so you can automate
   the route" destroys signal 2 for that session and every conclusion drawn
   from it.
2. **Do not narrate the game back to them.** No "nice, that's a leg
   documented."
3. **Silence is data.** When they pause, let it run. The urge to fill it is the
   single most common way a facilitator wrecks a session.
4. **Answer questions with the question.** "What happens if I don't write
   anything?" → "What do you think happens?" Then let them find out.
5. **Log the time** against anything you say that was not in rule 1.

---

## §1 — Daylight spent writing vs travelling

*Instrumented. Nothing to do but listen.*

The number arrives on its own. What the transcript cannot capture is whether
the tension was **felt as a choice** or experienced as an accounting chore.
Note verbatim anything they say about the clock, especially:

- counting days out loud before deciding to write
- expressing regret about an entry after writing it
- asking how many days they have left when the UI is showing them

Zero remarks about daylight across two seasons is itself a finding: the
central tension is not surfacing as a tension.

---

## §2 — Whether they survey a full route unprompted

*Half instrumented. The build records whether and when; you record what it
cost you to get there.*

The build cannot tell an insight from a hint. So hints are rationed, scripted,
and logged — always in this order, never skipping a rung, and only when the
player is genuinely stuck rather than merely slow.

| Rung | What you may say | Log |
|---|---|---|
| 0 | nothing | *the result we want* |
| 1 | "Anything you're curious about?" | time |
| 2 | "What do you think the survey does?" | time |
| 3 | "What do you think 'the House knows 1 leg of 3' means?" | time |
| 4 | "Surveying all three legs does something." | time — **signal 2 is now unmeasurable for this session** |

Rung 3 used to be "have a look at what the archive is holding." After session 01
the archive is on screen by default — what the House holds, and which legs it
knows by name — so that rung stopped being a hint and became a description of
the panel. It now points at the readout the player already has instead.

Record: the highest rung used, the time at which each was used, and whether
they got there afterwards. A session that reaches rung 4 still produces good
data for §3 and §5 — note it and carry on.

Also worth writing down: what they *thought* a survey was for, in their words,
before they found out.

---

## §3 — Reaction at the first automated return

*Not instrumented and never will be. This is the hypothesis.*

The vertical slice exists to answer one question: does documenting a road and
then watching a caravan run it unattended feel good? This is where that gets
answered, and it gets answered by a person's face in the two seconds after the
caravan line appears on screen.

### Setup

Run the measurement pass on their seed beforehand so you know roughly which
season it lands in. Post the standing order at the desk, begin the next season,
and the line is printed at the head of it: *"While the House slept, a caravan
walked the Ugarit road on its own and came home with 317 shekels, weighed."*

### At the moment

**Say nothing.** Not before, not during, not for ten seconds after. Do not lean
in, do not look at them expectantly, do not make a noise. If you signal that
something is supposed to happen, whatever happens next is worthless.

Record, within five seconds, on the sheet:

| Score | What it looks like |
|---|---|
| **3** | Unprompted reaction — says something, laughs, sits back, "oh, *nice*" |
| **2** | Visible pause; re-reads the line; scrolls back up to it |
| **1** | Reads it, moves on, no visible change |
| **0** | Does not appear to notice it went past |

Also record, verbatim, **anything they say in the next thirty seconds**, even
if it seems unrelated. And whether they went back and read it again later
unprompted — that is worth as much as the initial reaction.

A **0** is the most important result this script can produce, and the easiest
to explain away in the write-up. Do not explain it away. A payoff nobody
noticed is not a payoff, and the fix is presentation, not tuning.

### Afterwards, not now

Wait until the debrief. Then, open and unleading: *"Was there anything in that
session that landed differently from the rest?"* If they name it themselves,
that is a stronger 3 than the face was. If you have to bring it up, say so on
the sheet — a reaction you had to go looking for is a 1 whatever the face did.

---

## §4 — Whether they use the Courier

*Instrumented. Observe one thing the log cannot see.*

The number says whether it was used. It does not say whether it was
*considered*. Record:

- whether they ever asked what the Courier does
- whether they knew it existed before they needed it
- if a season died with an unsent ledger: their reaction to losing the writing,
  and whether they mentioned the Courier afterwards

An unused Courier the player never knew about is a UI finding. An unused
Courier they knew about and priced out is a tuning finding. The log cannot
tell these apart and they call for opposite fixes.

---

## §5 — Whether season two feels different from season one

*Half instrumented. The build records what was inherited; you record whether
it registered.*

At the **outfit step of season two**, before they buy anything, ask exactly
these two, in this order, and write the answers verbatim:

1. *"What does this scribe know that the last one didn't?"*
2. *"Is there anything you're going to do differently this season?"*

That is all. Do not prompt toward the archive, do not correct a wrong answer,
and do not ask a third question.

What you are listening for is whether the inheritance is **legible** — whether
they can name what carried over without being shown. A player who inherits two
documented legs and answers "nothing, I think?" has told you the archive is
carrying weight the game is not communicating, and that is the "inheritance
reads as a reset" failure condition arriving in a form the numbers would have
missed entirely.

If a scribe died in season one, note whether they connect the loss to the
Courier or to the writing they did not send.

---

## Debrief

Open questions only, in this order. Stop at the first one that produces a long
answer and let them run.

1. "Talk me through what you were trying to do."
2. "Was there anything that landed differently from the rest?"
3. "What did writing things down get you?"
4. "If you played a third season, what would you do?"

Do not ask whether they liked it. Do not ask them to rate anything. Do not
explain what the game was trying to do until the recorder is off — and then do,
because they will usually tell you something useful about the gap.

---

## Recording sheet

```
session ______  date ______  facilitator ______  seed ______  seasons played ______

§1  daylight remarks (verbatim):

    counted days aloud before writing?   Y / N
    expressed regret about an entry?     Y / N

§2  highest hint rung used: 0 / 1 / 2 / 3 / 4    at (time): ______
    documented the road?  Y / N   in season ______
    what they thought a survey was for, before finding out:

§3  automated return appeared in season ______    observed?  Y / N
    SCORE:  3 / 2 / 1 / 0
    said, within 30s (verbatim):

    returned to re-read it later unprompted?  Y / N
    did you have to raise it in the debrief?  Y / N

§4  asked what the Courier does?   Y / N    knew it existed before needing it?  Y / N
    lost a ledger to the road?     Y / N    reaction:

§5  Q1 "what does this scribe know that the last one didn't?" (verbatim):

    Q2 "anything you'll do differently?" (verbatim):

    named the inheritance unprompted?  Y / N

debrief notes:

TINMEASURE lines captured?  Y / N     file: ______________
```
