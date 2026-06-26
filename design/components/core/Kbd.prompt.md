Latch's signature keycap / shortcut display. Friendly key names map to Mac glyphs automatically (`cmd`→⌘, `shift`→⇧, `opt`→⌥, `enter`→↩, `space`→Space…).

```jsx
<Kbd keys="cmd+shift+V" />
<Kbd keys={["cmd", "V"]} tone="go" size="lg" />
<Kbd keys="esc" tone="ink" />   {/* on dark panel chrome */}
```

Use `tone="go"` to highlight the operative key in green, `tone="ink"` on dark surfaces. The default `md` size sits inline with body text.
