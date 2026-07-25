# design-sync notes — The Tin Road design system

- The chronicle serif stack ("Iowan Old Style", "Palatino Linotype", Palatino, Georgia, serif) is a deliberate system-font stack — there is no brand woff2 to ship, and Georgia is the universal metric-similar floor. `runtimeFontPrefixes` covers Iowan/Palatino so `[FONT_MISSING]` stays quiet; this is design intent, not an accepted substitute.
- `cssEntry` must be `dist/index.css` (esbuild-bundled). The source `index.css` is an @import stub and ships broken (`[CSS_IMPORT_MISSING]`).
- Playwright for the render check must pin the chromium build cached in /opt/pw-browsers (build 1194 → playwright 1.56.x in this environment). A newer playwright wants a headless-shell build that isn't cached.
- `@types/react` and `typescript` must be devDeps of design-system/ itself — the converter's DTS pass and validate's parse check read the package's own node_modules.

## From the preview-authoring waves

- The capture viewport sits under `Shell`'s 900px breakpoint, so Shell cards render book-over-tool (the documented responsive collapse), never the two-pane signature. Fine on the rubric; a wider capture viewport would show the canonical grid.
- Cell height budget for full-page compositions: roughly title block + two chronicle entries + one major panel. More overflows the cell.
- Never name a cell for a responsive behavior the fixed-width sheet cannot show.
- Refusal's reserved-empty-line contract photographs well as two panels in one story (one empty, one with words).
- Nesting TinRoot inside the provider's TinRoot is harmless — the provider component's own preview renders true.

## Re-sync risks

- `design-system/dist/` is gitignored and rebuilt by `npm run build --prefix design-system`; a re-sync on a fresh clone must run the install + build first (buildCmd in config).
- The playwright-version-to-cached-chromium pin (1.56.x ↔ build 1194) is environment-specific; other machines re-derive it per the skill's §4.1.
- Preview content quotes seed-101 chronicle prose; if templates in data/chronicle/en.json change, previews stay valid (they are compositions, not renders of the game) but may drift from the current book's wording.
