# Art Direction — the fresco standard

Established during the early-access site work; recorded here so it survives
chat history and reaches every future agent. The anchor image lives with the
project files (the caravan-scribe key art) and one crop of it is the codex
cover at `assets/codex/cover.jpg`.

## The style sentence

Bronze Age fresco: mineral pigment on cracked lime plaster, in the family of
Minoan Akrotiri wall painting and Egyptian tomb painting — flat perspective,
strong contour lines, patterned borders, surfaces that look excavated rather
than rendered.

## Palette (fired clay)

| Name | Hex | Use |
|---|---|---|
| Night | `#161109` | Grounds, backgrounds |
| Papyrus | `#ecdfc0` | Light fields, text on dark |
| Bronze | `#c9913c` | Primary accent, titles |
| Verdigris | `#5ea892` | Secondary accent, water, patina |
| Kiln red | `#c05a35` | Warnings, seals, borders |

## Rules learned the hard way

- No emissive glow, no lens effects, no photographic depth of field —
  pigment does not glow.
- Oxhide copper ingots are described by shape (concave sides, drawn-out
  corners), never by name, or generators draw cowhides.
- Levantine mudbrick and stone, not Cycladic whitewash.
- Writing in images is asemic — script-shaped marks, never legible glyphs
  (generators misspell; the setting's scripts are invented anyway).
- Tiled geometric border top, spiral wave band bottom, on major pieces.
- Bodies and beasts in profile where possible; it is period truth and it
  hides generator anatomy failures.

## Deliverable hygiene

Generate large, crop with intent, convert to WebP for the web and PNG for
engine import. Keep every accepted prompt beside its output in
`assets/art/prompts/` (directory created when the first in-game art lands).
