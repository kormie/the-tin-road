# The Tin Road — Design Document

**Working title.** Setting is The Long Bronze (`../world/long-bronze.md`).

---

## The pitch

A run-based generational game in which documentation is automation.

You are a scribe of a minor merchant house running one trading season down the tin route. Everything you learn dies with you unless you spent the daylight writing it down. Write a route well enough and the game runs it for you afterwards, sending caravans down it unattended while your next character walks off the edge of the map.

The archive is the meta-progression, the automation layer, and the setting's central technology, all the same object.

## Why this design and not another one

Three constraints drove every decision here, and if you cut one the design stops making sense.

**Meta-progression should be diegetic.** Most roguelites justify persistent upgrades with a shrug. Here what carries between runs is written records, which is both the honest mechanical answer and the entire thesis of the setting. Nothing else needed inventing.

**Repetition must compound or disappear.** The failure mode to avoid is the one where a promising loop turns into chores around hour fifteen. The rule below is absolute and it is what the automation system exists to satisfy.

**The support role should be structurally central.** In a setting whose win condition is an alliance holding together, the character who maintains cohesion is doing the most important job available. That is a design opportunity most games leave on the floor.

---

## The season loop

One run is one trading season. Target 45 to 90 minutes.

**1. Commission.** Take a contract from a Concord seat, a great house, a temple, or the Settled. It sets the objective, the starting capital, and which rivals now have a reason to care where you are. See `../world/factions.md` for who commissions what.

**2. Outfit.** Beasts, guards, trade goods, and blank media. Clay tablets are cheap and heavy. Papyrus is light and fragile. Cast blocks are late-game and reproduce rather than record. Media capacity is the constraint that decides how much of this season you get to keep.

**3. The Road.** Node-based travel. Settlements, hazards, ruins, rival caravans, border officials with opinions about your paperwork. Resolve with skills, standing contracts, and whichever factors you left in place three seasons ago.

**4. The Ledger.** At any point you may stop and write. It costs time from a finite season and it costs media. This is the only mechanism by which anything survives you, and the decision to stop and write is the game's central tension.

**5. Return or Fall.** Reach home and the ledger merges into the House archive. Die on the road and you keep only what you already sent home by courier.

## Between seasons

Your successor inherits the House, the Archive, and the Concord's memory of what the last one did.

Any route documented to a sufficient standard becomes **automatable**. Assign a caravan and it runs unattended, generating income and occasional incident reports while you go somewhere nobody has recorded.

This is the Factorio move, and here it is also literally true in fiction: a written road is a road anyone can walk. The pleasure of watching a system you built run without you is the same pleasure the setting is about.

---

## Progression, five axes

Nothing in this game improves along only one of these.

| Axis | Scope | What it is |
|---|---|---|
| The House | Permanent | Holdings, standing with each seat, unlocked archetypes |
| The Archive | Permanent | Routes, contacts, techniques, contract templates. Automatable. Corruptible. |
| The Scribe | Per run | Skills, contracts in force, seals in hand |
| The Caravan | Per run | Beasts, guards, capacity, endurance |
| The Concord | World state | The alliance strains across dozens of runs |

The Concord axis is the campaign. Across thirty or more seasons the world moves toward or away from the alliance surviving contact with mass literacy, driven by aggregate player behaviour rather than any single choice. No run decides it. Every run pushes.

---

## The two classes

Full mechanical detail in `systems.md`. The design intent:

**The Scribe** is built on the observation that a mid-vanilla WoW warlock was essentially a bureaucrat — prepared resources gathered in advance, layered persistent effects, autonomous agents parked elsewhere, and lossy conversion between currencies. Every element of that kit has a natural Bronze Age analogue and several of them are better in translation.

**The Keeper** is the support role, and it does not heal. The caravan has one shared Endurance pool that decays every leg. The Keeper spends actions slowing decay rather than reversing damage, which makes the role proactive and readable instead of reactive. Their real power is Standing: talking a hostile settlement into resupply, settling a blood debt before it costs a guard, keeping the caravan from dissolving two hundred miles from anywhere.

---

## The risky idea

Rival houses can plant false entries in the shared record. Your meta-progression can be poisoned. A route you "know" may be wrong, and finding out costs a season.

Almost no roguelite does this, because monotonic improvement is safer and players are protective of progress they have earned. It is the most interesting thing in this design and the most likely to make playtesters genuinely unhappy.

**Prototype it early and be prepared to hear that it does not work.** If it survives testing it is the thing that makes this game distinct. If it does not, cut it cleanly rather than defanging it into a minor inconvenience.

---

## The rule that protects the whole thing

> No repeated action ships unless it compounds or becomes automatable.

If the player is doing something for the fortieth time and it neither builds toward anything nor can be handed to the archive, it gets cut. No exceptions, no beloved features, no "but it's atmospheric."

This is what keeps a game about record-keeping from becoming clerical work, and it is the single line in this document most likely to be quietly violated during production.

---

## Study list

| Game | For |
|---|---|
| Slay the Spire | Run shape, node structure, readable per-run decisions |
| Factorio | The automation curve and when to hand a system over |
| FTL | Resource attrition across a journey |
| Pendragon | Generational hand-off done well |
| Sunless Sea | Prose economy in a systems game |
| Pentiment | Period texture, scribes, and the arrival of printing |

Pentiment matters most. It is the closest existing work to this premise, set two thousand years later, and studying it beats pretending it does not exist.
