# Roadmap

Nothing absent from the code is dropped. Deferral is sequencing, not deletion —
the order below comes from `docs/design/vertical-slice.md` and exists to test
the riskiest assumption first. Agents: build the current milestone; do not
gold-plate ahead of it.

**Built (v0 scaffold):** season clock · daylight · node travel · the four
ledger entry types · death (peril + stranding) · succession · the Courier
(send the ledger home, die survivable) · seals & rumours (unsealed surveys
merge at half value) · the outfit step (patron advance, priced bulk-capped
kit) · Standing Contracts (income per leg, road-wired call-ins, the season
purse) · media that matters (water ruins papyrus, heavy packs cost daylight) ·
assignable automation (standing orders: posted, priced, generational) · the
chronicle pipeline (events → prose → markdown) · a playable text-first UI ·
a web-export beta (CI artifact) · codex → ebook build · tests + CI.

## Milestones

**1. Finish the vertical slice** — the hypothesis test. **Built.**
The Courier (send the ledger home mid-season, die survivable), media types
that matter (clay heavy/durable vs papyrus light/fragile), a real outfit step,
automation you *assign* rather than receive, and the measurement plan in
`docs/design/vertical-slice.md`. Exit question: does watching a caravan run a
road you documented feel good?

The measurement plan is the gate for everything below it, and specifically for
milestone 2. A baseline taken in silence is the only thing that can tell us
later whether sound helped.

It lands in two halves, and the split is the point. `scripts/measure.gd` reads
the chronicle and reports four of the five signals over seeded runs; the fifth
— the reaction at the first automated return — is not instrumented, because
"watch faces, not surveys" is an instruction rather than a caveat. The build
points at the moment and refuses to score it. `docs/design/measurement.md` has
what each signal is computed from and the bands it is judged against;
`docs/design/playtest-script.md` is the observation protocol for the human
half. What remains before milestone 2 is not code: it is running sessions.

**2. The audible payoff — small, gated, measured against the baseline.**
Doctrine in `docs/audio-direction.md`; hooks in `docs/design/systems.md` §6.
Runs only once milestone 1 has produced instrumented data, and it is an A/B
against that data, not a decoration pass.

Scope, and it is small on purpose: the write cue with a duration proportional
to the entry (a Note is a scratch, a Treatise is a wearying passage), the seal
press, the water that ruins papyrus, and one unique unrepeated sound for the
first automated return. Roughly a dozen assets, no voice, no music, and the
whole bake pipeline (`manifest → lock → headless import`) built once here so
every later milestone inherits it.

Exit question: does the same loop, measured the same way, land harder with the
payoff audible? If not, the roadmap keeps its data and audio goes back to
milestone 9 where it started.

**3. The Keeper and Endurance.** The support role, structurally central.
One shared Endurance pool, decay not damage, no health bars anywhere.
Designed in `docs/design/systems.md` §4. Verify is listening — the entry read
aloud is the action, which makes recorded speech load-bearing here rather than
ornamental, and makes Petition and Mediate the only voiced actions in the game.

**4. The remaining Scribe kit.** Seals, Standing Contracts, Obligations,
Factors, Conversion. `systems.md` §3.

**5. Archive corruption — on probation.** Poisoned entries, Verify, the
paranoia economy. Prototype early; cut cleanly if it produces frustration
instead of tension. `systems.md` §2, and the design doc's "risky idea."

Depends on milestone 3 for Verify and inherits its tell from milestone 2's
pipeline: a forged entry is baked without the House lexicon, so it mispronounces
the road, and the same entry renders with the place name *misspelled*. Identical
to a clean entry until acted on, catchable by ear or by eye, and free to produce
because it is a pipeline step omitted rather than a system added.

**6. Factions as commission variety.** Six seats, three great houses, the
temples, the Settled — each a contract source. `docs/world/factions.md`.
Temple script and road script pronounce the world differently
(`data/codex/020-two-scripts.md`); one lexicon per faction is content, not
code, and makes whose archive you are reading audible.

**7. Presses, then the Concord axis.** Copy / Publish / Forge; publishing as
the game's only irreversible act; the campaign-length axis last because it
cannot be validated short. `systems.md` §5.

**8. Presentation.** Real UI in the fresco direction (`docs/art-direction.md`),
saves, the in-game codex reader.

**9. Audio in full**, on the pipeline milestone 2 built. One designed voice per
scribe drawn by the seeded `&"voice"` stream, so the archive is recited by
whoever wrote it and a rumour is recited by a stranger; road tunes that
assemble as the archive fills, so a documented road has a melody and an
undocumented one has only footfall; the silence budget enforced. Doctrine and
its open questions live in `docs/audio-direction.md`, including the licensing
check that gates shipping any generated second.

**10. The book pipeline, matured.** Chronicle → edited-novel workflow, codex
growth toward the ebook DLC, per-seed "chronicle sharing."

And its audio twin, which the determinism buys us for almost nothing: a seed
replays headless, renders its chronicle, and speaks it. `scripts/narrate.sh
--seed 735` produces the audiobook of a playthrough nobody else has had. Seed →
story → recital, offline, no runtime key, shareable as a file.
