# Roadmap

Nothing absent from the code is dropped. Deferral is sequencing, not deletion —
the order below comes from `docs/design/vertical-slice.md` and exists to test
the riskiest assumption first. Agents: build the current milestone; do not
gold-plate ahead of it.

**Built (v0 scaffold):** season clock · daylight · node travel · the four
ledger entry types · death (peril + stranding) · succession · naive automation
payout · the chronicle pipeline (events → prose → markdown) · codex → ebook
build · tests + CI.

## Milestones

**1. Finish the vertical slice** — the hypothesis test.
The Courier (send the ledger home mid-season, die survivable), media types
that matter (clay heavy/durable vs papyrus light/fragile), a real outfit step,
automation you *assign* rather than receive, and the measurement plan in
`docs/design/vertical-slice.md`. Exit question: does watching a caravan run a
road you documented feel good?

**2. The Keeper and Endurance.** The support role, structurally central.
One shared Endurance pool, decay not damage, no health bars anywhere.
Designed in `docs/design/systems.md` §4.

**3. Archive corruption — on probation.** Poisoned entries, Verify, the
paranoia economy. Prototype early; cut cleanly if it produces frustration
instead of tension. `systems.md` §2, and the design doc's "risky idea."

**4. The remaining Scribe kit.** Seals, Standing Contracts, Obligations,
Factors, Conversion. `systems.md` §3.

**5. Factions as commission variety.** Six seats, three great houses, the
temples, the Settled — each a contract source. `docs/world/factions.md`.

**6. Presses, then the Concord axis.** Copy / Publish / Forge; publishing as
the game's only irreversible act; the campaign-length axis last because it
cannot be validated short. `systems.md` §5.

**7. Presentation.** Real UI in the fresco direction (`docs/art-direction.md`),
audio, saves, the in-game codex reader.

**8. The book pipeline, matured.** Chronicle → edited-novel workflow, codex
growth toward the ebook DLC, per-seed "chronicle sharing."
