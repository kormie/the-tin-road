# Systems Reference

Mechanical detail. Design rationale lives in `tin-road.md`. Numbers here are first-pass and exist to be argued with.

---

## 1. The Ledger

The core system. Everything else exists to make this decision interesting.

**Writing costs Daylight and Media.** Daylight is the season's clock. Media is physical stock you bought at outfit.

| Entry type | Daylight | Media | What it unlocks |
|---|---|---|---|
| Note | 1 | 1 | A fact. Reference only. |
| Record | 3 | 2 | A contact, hazard, or price. Usable next run. |
| Survey | 8 | 5 | One route leg documented. Three legs make a route automatable. |
| Treatise | 15 | 10 | A technique. Permanent House-wide modifier. |

**Media types**

| Medium | Weight | Fragility | Cost | Note |
|---|---|---|---|---|
| Clay | Heavy | Low | Cheap | Survives fire and shipwreck. Slows the caravan. |
| Papyrus | Light | High | Moderate | Ruined by water. The default mid-game choice. |
| Vellum | Light | Low | Expensive | Strictly better and priced accordingly. |
| Blocks | Heavy | Low | Very expensive | Reproduces rather than records. See §5. |

First-pass road numbers for the slice: a pack bulkier than 12 (bulk costs in
`sim/outfit.gd`) pays +1 Daylight per node travelled. Water mishaps ruin
papyrus only; surviving a water peril soaks every sheet. Clay is immune to
water — it walks out of the marsh streaked but legible.

**The tension:** Daylight spent writing is Daylight not spent travelling, trading, or getting clear of something. A season that documents everything reaches nowhere. A season that reaches everywhere teaches your successor nothing.

## 2. The Archive

Persistent. Merges on successful return. Partial merge on courier delivery (§3).

**Automation threshold.** Three surveyed legs constitute a documented route. A leg the archive holds only as rumour counts toward the threshold, but the caravan walks it at half confidence and half pay until a sealed survey confirms it. A documented route can be assigned a caravan — a standing order, posted and priced — which runs it unattended and returns income and an incident report each season without player input.

Automation is the primary reward curve. It should feel like the game handing you back your own past work, because it is.

**Archive integrity.** Every entry carries a provenance value. Entries you wrote yourself are clean. Entries acquired by purchase, theft, or gift are not necessarily.

**Corruption.** A poisoned entry looks identical to a good one until acted on. Detection requires either a Keeper's Verify action, a temple Archivist's services, or discovering it the hard way.

Corrupted survey → route leads somewhere wrong.
Corrupted record → contact is hostile or fictional.
Corrupted treatise → the modifier is inverted and hidden.

> **Prototype gate.** This system is on probation. If playtesting shows it produces frustration rather than paranoia, cut it whole. Do not soften it into a minor debuff — a defanged version costs the same complexity and delivers none of the tension.

## 3. The Scribe

Six mechanics, translated from a mid-vanilla warlock kit.

### Seals
*was: Soul Shards*

Consumed to authenticate any document. Without a seal, an entry is a rumour and merges at reduced value.

Replenished only at temples and guild halls. Carrying capacity is limited and competes with trade goods. The inventory pressure is the point and should not be optimised away.

### Standing Contracts
*was: damage over time*

Signed once at a settlement, then resolving every leg of the journey. Income, access, or protection, ticking.

Stack freely. Each active contract is also an obligation someone can call in at the moment it is most expensive to honour. A Scribe running six contracts is wealthy, mobile, and one bad node from catastrophe.

### Obligations
*was: curses*

Leverage placed on a rival house. Debt, blood price, or favour owed.

**One active per rival house.** Placing a second overwrites the first, so choosing which lever to hold on whom is a real decision rather than an accumulation.

### Factors
*was: pets*

Agents left behind in cities. They act autonomously between visits: gathering prices, holding goods, watching a rival.

Trained up across generations. A factor your grandfather placed is meaningfully better than one you placed last season. Factors can also be turned by a sufficiently motivated rival, and a turned factor keeps reporting.

### Conversion
*was: Life Tap*

Standing → coin → knowledge → standing. Lossy in every direction, and the exchange rate moves with the political weather.

Conversion is how a Scribe digs out of a bad position, and every use of it makes the next one worse.

### The Courier
*was: Soulstone*

Spend a seal and a portion of media to send a copy of the ledger home mid-season.

Die afterwards and that much survives. Resurrection reframed as archival redundancy, which is the game's argument about how anything outlives anyone.

Cost is deliberately steep. The courier should feel like an admission that this season is going badly.

## 4. The Keeper

**No health bars anywhere in the game.**

The caravan has **Endurance**, a single shared pool. It decays a fixed amount every leg and takes additional hits from hazards, weather, poor supply, and internal conflict. At zero the season ends where it stands.

### Design constraints
- The Keeper prevents decay rather than reversing damage. Proactive, legible, plannable.
- No action is ever the correct default. Every Keeper action has an opportunity cost against another Keeper action.
- There is no spam button and there should never be one.

### The kit
**Provision** — reduce decay for the coming legs. Costs supply.
**Mediate** — resolve an internal conflict before it costs a guard or a beast.
**Verify** — test an archive entry's provenance before the caravan acts on it. The main counter to corruption (§2).
**Petition** — convert Standing into access at a hostile or indifferent settlement. Resupply, safe passage, a night behind walls.
**Triage** — allocate a scarce resource among the caravan. Explicitly a choice with a loser.

**Standing is the Keeper's real resource**, not supply. A Keeper who has spent their reputation is far more crippled than one who has run out of medicine.

## 5. Presses and Blocks

Late-game. A House that acquires press capacity can reproduce its own archive.

- **Copy** — duplicate an archive entry. Sell it, gift it, or bank a spare against loss.
- **Publish** — release an entry into general circulation. Permanently reduces its value to you, permanently shifts faction standing, occasionally moves the Concord axis.
- **Forge** — produce a false entry indistinguishable from a real one, for planting in a rival's archive.

Publishing is the game's only genuinely irreversible action, and it is how a player pushes the Concord axis deliberately rather than incidentally. Printing the treaty is a move available to the player and it does what it did in 735 AK.

## 6. Open questions

Unresolved. Flagged rather than papered over.

- Does the player control the successor's archetype, or does the House's state determine it? Control is friendlier. Determination is more thematically honest.
- Is there co-op? The Scribe and Keeper are built for it, but generational hand-off across two players is an unsolved structural problem.
- How does the Concord axis surface to the player? A visible meter cheapens it. No feedback at all makes thirty seasons of drift invisible.
- Does automation ever fail? A route that silently stops paying is realistic and probably infuriating.
