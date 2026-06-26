# Latch Website — UI kit

The Latch marketing landing page: nav, hero with a live panel mock, features, a dark security section, pricing, and footer.

## Open
`index.html` — full single-page scroll.

## Files
- `index.html` — page shell + all section CSS + script wiring.
- `Site.jsx` — every section as a small sub-component (`Nav`, `Hero`, `Features`, `Security`, `Pricing`, `Footer`), exported as `window.LatchSite`.
- Icons come from `../app/Icons.js` (`window.LatchIcons`).

## Composition
Uses DS primitives `Button`, `Badge`, `Kbd`, `Card`, `ClipItem` from `_ds_bundle.js` (`window.LatchDesignSystem_fe0ecb`). The hero panel reuses real `ClipItem` rows so the marketing shot matches the product exactly. Section layout CSS is local; colors/type/spacing come from DS tokens.

## Notes
This is a recreation scaffold, not production code — links are inert (`#`). Swap copy and the download targets for real use.
