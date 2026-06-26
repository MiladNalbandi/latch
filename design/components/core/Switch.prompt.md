Controlled on/off toggle for settings rows. Green when on, gentle spring on the thumb.

```jsx
<Switch checked={sync} onChange={setSync} label="Sync across devices" />
<Switch checked={excludePw} onChange={setExcludePw} size="sm" />
```

Always controlled — pass `checked` and handle `onChange(next)`.
