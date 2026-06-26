Primary action button — use for the main call-to-action and any clickable command in Latch UI.

```jsx
<Button variant="primary" size="md" onClick={save}>Save snippet</Button>
<Button variant="secondary" iconLeft={<PinIcon/>}>Pin</Button>
<Button variant="ghost" size="sm">Cancel</Button>
```

Variants: `primary` (green, default), `secondary` (paper + border), `ghost` (transparent), `danger` (red), `secure` (blue — encryption / lock actions). Sizes: `sm` / `md` / `lg`. Pass `iconLeft` / `iconRight` as SVG nodes; use `fullWidth` inside narrow panels.
