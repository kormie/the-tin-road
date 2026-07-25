# The Tin Road — design system

A React design system in the game's fired-clay language, for building
Tin-Road-flavored web surfaces (and for feeding to design tools such as
claude.ai/design — `tokens.json` carries the palette, type, spacing, and
the rules as machine-readable data; this README and the component source
carry the rest).

Bronze Age fresco: mineral pigment on cracked lime plaster. Flat
perspective, strong contour lines, surfaces that look excavated rather
than rendered. **Rule zero: pigment does not glow** — no shadows, no
gradients-as-sheen, no blur, no emissive anything, ever.

## Files

- `tokens.css` — design tokens as CSS custom properties.
- `tokens.json` — the same tokens plus the system's rules, machine-readable.
- `components.css` — component styles (plain CSS, no preprocessor).
- `TinRoad.jsx` — the components (plain React, zero dependencies).
- `demo/` — every component on one page, arranged as the game arranges
  them, with real prose from the seed-101 chronicle.

## The components

| Component | Role |
|---|---|
| `TinRoot`, `Shell` | Night ground; the book on the left, the tool on the right |
| `Title`, `MeanderRule` | Bronze title; the tiled border reserved for major pieces (one per view) |
| `Chronicle`, `SeasonHeading`, `Entry`, `Colophon` | The book: serif, generous leading, selectable, never truncated |
| `Panel`, `PanelHeading` | Plaster over night with one drawn contour line; `major` earns the heavy line |
| `StatusStrip` | The standing facts, in verdigris |
| `Refusal` | The world saying no, in kiln red, in words |
| `Button`, `ButtonRow`, `Stack` | Attempt-and-report: buttons stay pressable; refusals are stated, not predicted |
| `Input`, `Stepper` | Outfit-desk quantities — bounds are the caller's business, the system never invents a gate |
| `SealToggle` | Kiln red, one-shot by convention |
| `ContractCard` | Name, holder, data-authored terms, one act |
| `Stats`, `Stat` | Small labelled figures: daylight, media, silver |

## The rules (also in tokens.json)

1. Pigment does not glow.
2. Every surface gets a drawn contour; emphasis is line weight and
   pigment, never elevation.
3. The chronicle is the centerpiece of any view that has one.
4. Kiln red is spent, not decorated with: refusals, seals, danger.
5. Interfaces attempt and report — a disabled button is a prediction,
   and predictions belong to the sim.
6. The meander marks major pieces only.
7. Ornament may suggest writing; it never spells anything.

## Run the demo

```bash
npm install esbuild react react-dom
npx esbuild demo/main.jsx --bundle --outfile=demo/bundle.js --jsx=automatic
python3 -m http.server -d . 8080   # open localhost:8080/demo/
```
