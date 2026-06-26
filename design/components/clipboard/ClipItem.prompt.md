The signature Latch object: one clipboard-history row. Compose many inside a scrollable list.

```jsx
<ClipItem type="link" content="https://latch.app/pricing" source="Safari" time="2m ago" index={1} />
<ClipItem type="text" content="Thanks so much — talk soon!" source="Mail" time="9m ago" pinned selected index={2} />
<ClipItem type="color" content="#12a877" source="Figma" time="1h ago" index={3} />
<ClipItem type="code" content="git rebase -i HEAD~3" source="Terminal" time="3h ago" index={4} />
```

`type` controls the leading glyph (`text/link/image/code/color/file`). `selected` is the keyboard-highlighted row; `index` is the quick-paste number shown on hover. For images, pass an `<img>` through `icon`.
