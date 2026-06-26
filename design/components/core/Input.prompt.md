Text input with optional label, hint text, and icons. Use `search` for the filled history search box.

```jsx
<Input label="Snippet name" placeholder="e.g. Work email" />
<Input search iconLeft={<SearchIcon/>} placeholder="Search history…" />
<Input label="Sync key" invalid hint="That key didn't match." />
```

`search` swaps to a filled, borderless box that focuses to white. Pass `iconLeft`/`iconRight` as SVG nodes.
