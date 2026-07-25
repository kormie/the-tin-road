# Audio Direction — the recital standard

`docs/toolchain.md` requires this file to exist before any audio tool is
chosen. It exists now, and it chooses one: **ElevenLabs** (sound effects,
text-to-speech, voice design, music), driven from `scripts/` by API against a
committed manifest. Nothing here is built. This is the doctrine the build
will be held to.

The companion doc is `art-direction.md`, and the relationship is deliberate:
that file governs what the game looks excavated from, this one governs what it
sounds recited from.

## The style sentence

A Bronze Age archive read aloud: material sound and human voice, no synthesis,
no orchestra — stylus on clay, reed on papyrus, water, hide, bronze, breath,
footfall, and a scribe saying words that outlive them.

## The palette (materials, not instruments)

| Name | What it is | Where it carries |
|---|---|---|
| Stylus | Wedge into damp clay; a blunt, close, repeating tap | Writing. The sound of daylight being spent. |
| Reed | Pen on papyrus; dry, fast, a whisper with grain in it | Writing, lighter and more fragile than clay |
| Seal | The press, the give of the clay, the lift | Authentication. The most important sound in the game. |
| Water | Marsh, bilge, rain on a pack | Peril, and the ruin of papyrus |
| Hide & bronze | Straps, buckles, ingots shifting, beasts | The pack's weight; heavy going |
| Breath | Footfall, effort, the caravan as a body | The road, and Endurance when it exists |
| Voice | Recitation, unaccompanied | The archive, the Keeper, the dead |

Anything that cannot be traced to one of those seven rows needs an argument
before it ships.

## Rules learned from the art direction, applied to sound

- **No anachronism, and no glow.** Pigment does not glow; neither does bronze
  hum. No pads, no risers, no sub-drops, no reversed-cymbal transitions, no
  "epic Bronze Age trailer" anything. Generators produce that by default and
  it must be refused every time.
- **Diegetic by default.** Everything the player hears should be something
  that could be heard on the road or in the archive room. Music is the single
  licensed exception, and it is licensed only because a caravan that sings is
  period truth (see below).
- **Voices are designed, never cloned.** Every voice in this game comes from a
  text prompt describing a fictional person. No real person's voice is
  reproduced, sampled, or imitated, including with permission. This is not a
  legal hedge, it is a line.
- **Speech is asemic's opposite.** Images use script-shaped marks that are
  never legible glyphs, because the setting's scripts are invented. Speech
  gets the reverse treatment: the chronicle is in English and is spoken
  clearly, because prose is the one place this game is not coy. Place and
  person names, however, are pronounced *this House's* way — see the lexicon.
- **The archive room is quiet.** Road phases carry sound. The desk does not,
  beyond the stylus and whoever is reading. The contrast is the point: the
  Ledger's central decision is a decision to stop, and stopping should sound
  like stopping.

## Voice doctrine

The setting's thesis is that what a scribe writes down is the only thing that
survives them. Sound has a way of stating that which text cannot.

**One voice per scribe.** A designed voice, drawn from a small committed pool
by the sim's seeded `&"voice"` stream at succession, exactly as names are drawn
now. A generation's voice is part of the generation.

**The archive speaks in the voice of whoever wrote it.** An entry recited
years later is recited by its author, who is dead. Reading your own archive
means hearing your grandfather. This is meta-progression you can hear, and it
costs nothing conceptually because the sim already records who wrote what.

**Sealed speaks; unsealed is reported.** A sealed entry is read in the
writer's own voice. A rumour — the unsealed survey that already merges at half
value — is read by an uncredited hearsay voice, flat and distant, someone
recounting what they were told. The mechanical distinction between fact and
hearsay becomes an audible one, and it needs no tutorial.

**The Keeper is the loudest character in the game.** When milestone 3 arrives,
Petition and Mediate are the only actions in the design that consist of
speaking to people. If recorded speech is spent anywhere in gameplay, it is
spent there. The support role being structurally central should be audible.

Voice IDs are **build inputs, not shipped truth.** Voice design is not
reliably reproducible from a prompt, so the artifacts of record are the
rendered audio files plus the design prompt kept beside them. A committed
`data/audio/voices.json` maps role → voice ID for the bake; if the account
changes, voices are re-designed and re-baked, and the prompts are how that
stays possible.

## The lexicon, and the forgery it catches

The setting is full of names a generator will mangle: Ugarit, Alashiya,
Yabninu, Urtenu, Sapanu, Ilimilku, Niqmaddu, Ahatmilku. A **pronunciation
dictionary** fixes them once, and every batch afterwards agrees with every
previous batch. That alone justifies it as production hygiene. The source of
truth is a committed `data/audio/lexicon.json`; the account-side dictionary is
generated from it, never edited by hand.

Then it earns its keep twice, because the lexicon is a thing a House *knows*.

**The forgery tell (milestone 5, archive corruption).** A forged entry is
baked with the lexicon deliberately **not** applied. The place name comes out
in the generator's naive English, and the reason is diegetic and exact: the
forger was never trained in this House and does not know how the name is said.

That tell is worth having because it is:

- **invisible in text and audible in recital** — which is precisely the design
  requirement that a poisoned entry "looks identical to a good one until acted
  on";
- **free to produce**, being the absence of a pipeline step rather than the
  addition of one;
- **learnable** — the player gets better at hearing it across seasons, which
  is player skill compounding rather than a stat increasing, and the rule
  about repeated actions is satisfied by a repeated action becoming *easier
  for the human*;
- **the reason Verify is an audible action.** The Keeper's counter to
  corruption is to have the entry read aloud. Verify is listening.

**Accessibility is not optional here, and fixing it improves the idea.** A
tell that exists only in audio is a tell some players cannot use. So it exists
in both channels: heard as a mispronunciation, seen as a *misspelling* in the
rendered entry. A forged tablet with the place name spelled wrong is better
period texture than the audio version, and the two together mean the player
can catch a forgery by ear, by eye, or by both. Neither channel is a
concession; ship both or ship neither.

## Music, on a short leash

One rule decides every music question: **it must be performable by people and
instruments that exist in this world.** Lyre, double reed, frame drum,
sistrum, unaccompanied voice. No harmony that postdates the setting by two
millennia, no percussion that arrived with the drum kit.

**Road tunes.** A documented route gets a tune, shipped with the route as
content — routes are data, and so is the music for them. The trick is when the
player hears it: the tune assembles as the archive fills. Baked in three
completeness passes — footfall and drum, then drum and reed, then the whole
thing — crossfaded on how many legs the archive holds. A road you have not
written down is a road that has not got a melody yet. A road walking itself
unattended while you are elsewhere is a tune you built playing in a place you
are not, which is the entire pleasure this game is chasing, in a form you can
hear from another room.

**On probation:** the rumoured leg played slightly sour — the same tune, a
tired player, a little flat. If a generator can produce that reliably it is a
gorgeous piece of information design. If it cannot, drop it without mourning
and let the leg count carry the whole signal.

## The silence budget

An ambient loop heard four hundred times is a repeated action, and this
project's governing rule is that no repeated action ships unless it compounds
or can be handed off. Audio obeys it via inversion: **the rarer the moment,
the larger the craft budget.**

| Frequency per season | Examples | Treatment |
|---|---|---|
| >100× | Travel step, stylus tap | Short, material, ≥5 variants, varied in pitch and level at runtime rather than by baking fifty clips |
| 5–20× | Arrival, seal press, contract signed | 3 variants, no melodic content |
| 0–2× | Death, succession, route documented, the first automated return | One clip, unique, unrepeated, and where the budget actually goes |

Writing gets a duration, not a hit. A Note costs one day and a Treatise costs
fifteen; if the stylus runs for a length proportional to the entry, the
player feels the arithmetic of daylight without reading a number. This is the
one place where audio carries a rule the UI would otherwise have to explain.

## The pipeline

Non-negotiable, and it comes straight from the toolchain rule that a tool must
be drivable headless: **ElevenLabs is a build-time dependency and never a
runtime one.**

```
data/audio/manifest.json   → what to generate: id, kind, prompt, duration, voice, variants
data/audio/lexicon.json    → the House pronunciation, source of truth
data/audio/voices.json     → role → voice ID, for the bake only
assets/audio/audio.lock.json → prompt hash → generated file, so nothing regenerates unchanged
assets/audio/**            → the shipped result, imported headless
data/audio/cues.json       → event type → cue. Presentation binding, read by game/.
```

`scripts/bake_audio.sh` reads the manifest, skips everything whose prompt hash
is already in the lock, generates the rest, writes the lock, and imports. A
`--dry-run` prints what it would spend before it spends it. The manifest and
the lock are the audio equivalent of the accepted-prompt-beside-its-output
rule in `art-direction.md`, and the pleasing part is that the audio pipeline is
itself an instance of the game's thesis: write the recipe down well enough and
it runs without you.

**Why no runtime API, stated once so it is not relitigated:** a key in a web
export is a key given away; a per-player API cost is a business model nobody
asked for; an offline player would lose the game's voice; and a generation
that varies per playthrough breaks "same seed, same story," which is the one
promise this project treats as sacred. Determinism includes the recital.

### Rules for the code that will eventually exist

- **`sim/` is silent.** No `AudioStreamPlayer`, no audio bus, no cue lookup in
  `sim/`. Audio binds off `ChronicleEvent`s in `game/`, exactly as prose binds
  off them in `chronicle/renderer.gd`. The order of work is unchanged and now
  has a fourth step: new sim behaviour → new event type → new prose variants →
  *then* optionally a cue.
- **Silence is a valid cue.** The renderer test demands a template for every
  emitted event type. The audio equivalent must not: most events should make
  no sound. The test runs the other way, as an unused-asset lint — `cues.json`
  may not name an event type the sim never emits, and the manifest may not
  carry an asset no cue references.
- **Variant choice is seeded.** Cue variants draw from a `&"voice"` stream, so
  a seed reproduces its recital the way it already reproduces its prose.
- **Repo weight.** Audio is heavy and git is not. The manifest, lexicon,
  prompts and lock are always committed. The audio itself is committed only
  while it fits a stated budget; past that it becomes a release artifact that
  `scripts/setup.sh` fetches, and the lock is what makes that safe.

## Open questions, flagged rather than papered over

- **Licensing, and it gates everything.** Commercial rights to generated audio
  depend on the account tier that generated it, and the API key in this
  project carries a Terms-of-Service-Accept permission — meaning the pipeline
  is technically able to accept terms on our behalf, which is a reason for
  more deliberation, not less. Before a single generated second ships in a
  build: confirm the terms for the tier in use, record the tier and the date
  in this file, and note anything requiring attribution. Prototype freely;
  ship nothing unverified.
- Does the recital voice help or intrude during play? The archive reader and
  the audiobook are safe. A voice narrating the road as it happens may be the
  best thing in the game or may be unbearable by the third season.
- Can a music generator hold a period constraint across a whole batch, or does
  every prompt need policing? If it cannot, music becomes commissioned work
  from a human and this doc gets shorter.
- How much of the chronicle can be spoken at all? Prose is assembled from
  templates with live slots — names, places, counts — so full sentences cannot
  be pre-rendered. Either the audiobook stays a per-seed offline bake (cheap,
  certain, milestone 10) or in-game recital is spliced from fixed spans and
  closed-set slot words. Splicing sounds mechanical, except that formulaic
  oral poetry is *exactly* composition by reusable phrase, so the artifice may
  read as the tradition. Worth one experiment before it is believed.
