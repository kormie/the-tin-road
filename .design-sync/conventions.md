# The Tin Road — build conventions

Bronze Age fresco on a dark ground. **Rule zero: pigment does not glow** —
never use `box-shadow`, `text-shadow`, gradients-as-sheen, blur, or opacity
fades for emphasis. Emphasis is line weight and pigment.

## Wrap everything in `TinRoot`

Every screen goes inside `TinRoot` — it supplies the Night page ground,
the chrome font, and base text color. Without it, components render
papyrus-colored text on a white page and look broken. Two-pane screens use
`Shell` inside it (`book` = the content pane, `aside` = the control panel):

```jsx
<TinRoot>
  <Shell
    book={<Chronicle>…</Chronicle>}
    aside={<Panel major>…</Panel>}
  />
</TinRoot>
```

## Styling idiom: CSS custom properties, `--tin-*`

Components carry their own classes — never restyle them. For your own
layout glue, use the tokens (all defined in `styles.css`'s import closure):

| Token | Use |
|---|---|
| `--tin-night` `--tin-plaster` `--tin-plaster-deep` | page ground · raised panel · inset field |
| `--tin-papyrus` `--tin-papyrus-dim` | text on dark · captions/secondary |
| `--tin-bronze` | titles, section headings, the primary act |
| `--tin-verdigris` | status facts, secondary accent, water |
| `--tin-kiln` | ONLY refusals, seals, dangerous acts — spent, not decorated with |
| `--tin-contour` | the 1px drawn line around any surface you make |
| `--tin-font-chronicle` / `--tin-font-chrome` | serif for prose, system for tool chrome |
| `--tin-space-1..8`, `--tin-radius`, `--tin-line`, `--tin-line-heavy` | spacing, near-square corners, line weights |

Example glue: `style={{ background: "var(--tin-plaster)", border: "var(--tin-line) solid var(--tin-contour)", padding: "var(--tin-space-4)" }}`.

## Component conventions

- **The chronicle is the centerpiece** of any screen that has one: `Chronicle` > `Colophon` / `SeasonHeading` / `Entry`. Serif, roomy, never truncated with ellipsis.
- **Buttons attempt and report**: keep `Button` enabled and put the "no" in a `Refusal` (kiln red words). Do not pre-disable to predict rules. `tone="primary"` = the screen's one main act; `tone="danger"` = spending something irreversible.
- `Stepper` bounds are the caller's business; `SealToggle` is one-shot (clear it after a successful sealed act); `MeanderRule` marks ONE major piece per view; `Panel major` is that piece's heavy contour.
- Content voice: dry, literate, no exclamation marks. Realistic Bronze Age trade content (shekels, seals, papyrus), never lorem.

## Where the truth lives

Read `styles.css` and its imports (`_ds_bundle.css` — tokens then component
classes) before inventing anything. Per-component APIs are each
`components/general/<Name>/<Name>.d.ts`; usage patterns are in each
`<Name>.prompt.md`.
