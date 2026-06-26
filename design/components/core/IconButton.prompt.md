Icon-only square button for toolbars, clip-row controls, and panel chrome. Always pass a `label` for accessibility + tooltip.

```jsx
<IconButton label="Pin" onClick={pin}><PinIcon/></IconButton>
<IconButton variant="solid" label="New"><PlusIcon/></IconButton>
<IconButton label="Favorite" active={isFav}><StarIcon/></IconButton>
```

Variants: `plain` (default), `solid` (green), `outline`. Use `active` for toggled state.
