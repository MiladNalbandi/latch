/* LatchPanel — the floating Spotlight-style clipboard history.
   Composes ClipItem, Input, Kbd, Badge, Button, IconButton from the DS bundle. */
(function () {
  const { ClipItem, Input, Kbd, Badge, Button, IconButton } = window.LatchDesignSystem_fe0ecb;
  const I = window.LatchIcons;

  const TYPE_META = {
    text:  { label: "Text",  Icon: I.Type },
    link:  { label: "Link",  Icon: I.Link },
    image: { label: "Image", Icon: I.Image },
    code:  { label: "Code",  Icon: I.Code },
    color: { label: "Color", Icon: I.Image },
    file:  { label: "File",  Icon: I.File },
  };
  const FILTERS = [
    { key: "all", label: "All" },
    { key: "pinned", label: "Pinned" },
    { key: "link", label: "Links" },
    { key: "text", label: "Text" },
    { key: "code", label: "Code" },
    { key: "color", label: "Colors" },
  ];

  function typeIcon(type) {
    const M = TYPE_META[type];
    return M && M.Icon ? React.createElement(M.Icon, { size: 18 }) : null;
  }

  function Preview({ clip, onPaste, onPin, onDelete }) {
    if (!clip) return (
      <div className="lp-preview lp-preview--empty">
        <div style={{ textAlign: "center", color: "var(--text-faint)" }}>
          <I.Clipboard size={30} />
          <div style={{ marginTop: 10, fontSize: 13 }}>Nothing selected</div>
        </div>
      </div>
    );
    const M = TYPE_META[clip.type] || TYPE_META.text;
    const isColor = clip.type === "color";
    return (
      <div className="lp-preview">
        <div className="lp-preview__head">
          <Badge tone="neutral" size="sm" icon={<M.Icon size={13} />}>{M.label}</Badge>
          {clip.pinned && <Badge tone="primary" size="sm" icon={<I.Pin size={12} />}>Pinned</Badge>}
          <span style={{ flex: 1 }}></span>
          <span className="lp-preview__time"><I.Clock size={12} /> {clip.time}</span>
        </div>

        {isColor ? (
          <div className="lp-preview__color">
            <div className="lp-preview__swatch" style={{ background: clip.content }}></div>
            <div className="lp-preview__hex">{clip.content.toUpperCase()}</div>
          </div>
        ) : (
          <div className={"lp-preview__content" + (clip.type === "code" || clip.type === "link" ? " is-mono" : "")}>
            {clip.content}
          </div>
        )}

        <div className="lp-preview__meta">
          <span>From <b>{clip.source}</b></span>
          <span className="lp-dot"></span>
          <span>{clip.content.length} chars</span>
          <span className="lp-dot"></span>
          <span className="lp-secure"><I.Shield size={12} /> Local only</span>
        </div>

        <div className="lp-preview__actions">
          <Button size="md" onClick={onPaste} iconLeft={<I.Check size={16} />}>Paste</Button>
          <Button size="md" variant="secondary" onClick={onPin} iconLeft={<I.Pin size={15} />}>
            {clip.pinned ? "Unpin" : "Pin"}
          </Button>
          <span style={{ flex: 1 }}></span>
          <IconButton label="Delete" onClick={onDelete}><I.Trash size={17} /></IconButton>
        </div>
      </div>
    );
  }

  function LatchPanel({ initialClips, onClose, onOpenSettings }) {
    const [clips, setClips] = React.useState(initialClips || window.LATCH_CLIPS);
    const [query, setQuery] = React.useState("");
    const [filter, setFilter] = React.useState("all");
    const [activeIdx, setActiveIdx] = React.useState(0);
    const [toast, setToast] = React.useState(null);
    const listRef = React.useRef(null);

    const filtered = React.useMemo(() => {
      let rows = clips;
      if (filter === "pinned") rows = rows.filter((c) => c.pinned);
      else if (filter !== "all") rows = rows.filter((c) => c.type === filter);
      if (query.trim()) {
        const q = query.toLowerCase();
        rows = rows.filter((c) => c.content.toLowerCase().includes(q) || c.source.toLowerCase().includes(q));
      }
      // pinned first
      return [...rows].sort((a, b) => (b.pinned ? 1 : 0) - (a.pinned ? 1 : 0));
    }, [clips, query, filter]);

    React.useEffect(() => { setActiveIdx(0); }, [query, filter]);
    const active = filtered[activeIdx];

    const flash = (msg) => { setToast(msg); setTimeout(() => setToast(null), 1400); };
    const paste = (c) => { if (c) flash("Pasted to " + (c.source === "Finder" ? "frontmost app" : "frontmost app")); };
    const togglePin = (c) => c && setClips((cs) => cs.map((x) => x.id === c.id ? { ...x, pinned: !x.pinned } : x));
    const del = (c) => c && setClips((cs) => cs.filter((x) => x.id !== c.id));

    const onKeyDown = (e) => {
      if (e.key === "ArrowDown") { e.preventDefault(); setActiveIdx((i) => Math.min(i + 1, filtered.length - 1)); }
      else if (e.key === "ArrowUp") { e.preventDefault(); setActiveIdx((i) => Math.max(i - 1, 0)); }
      else if (e.key === "Enter") { e.preventDefault(); paste(active); }
      else if (e.key === "Escape") { e.preventDefault(); onClose && onClose(); }
    };

    React.useEffect(() => {
      const el = listRef.current && listRef.current.querySelector('[data-active="true"]');
      if (el && el.scrollIntoView) el.scrollIntoView({ block: "nearest" });
    }, [activeIdx, filtered.length]);

    return (
      <div className="lp" onKeyDown={onKeyDown} tabIndex={0}>
        <div className="lp__header">
          <div className="lp__searchwrap">
            <Input
              search autoFocus value={query}
              onChange={(e) => setQuery(e.target.value)}
              iconLeft={<I.Search size={17} />}
              placeholder="Search your clipboard…"
            />
          </div>
          <Badge tone="secure" dot>Local only</Badge>
          <IconButton label="Settings" onClick={onOpenSettings}><I.Settings size={18} /></IconButton>
        </div>

        <div className="lp__filters">
          {FILTERS.map((f) => (
            <button key={f.key}
              className={"lp__filter" + (filter === f.key ? " is-on" : "")}
              onClick={() => setFilter(f.key)}>
              {f.label}
            </button>
          ))}
        </div>

        <div className="lp__body">
          <div className="lp__list" ref={listRef}>
            {filtered.length === 0 && (
              <div className="lp__empty">No clips match “{query}”.</div>
            )}
            {filtered.map((c, i) => (
              <div key={c.id} data-active={i === activeIdx} onMouseEnter={() => setActiveIdx(i)}>
                <ClipItem
                  type={c.type} content={c.content} source={c.source} time={c.time}
                  pinned={c.pinned} selected={i === activeIdx} index={i < 9 ? i + 1 : undefined}
                  icon={typeIcon(c.type)}
                  onClick={() => { setActiveIdx(i); paste(c); }}
                />
              </div>
            ))}
          </div>
          <Preview clip={active} onPaste={() => paste(active)} onPin={() => togglePin(active)} onDelete={() => del(active)} />
        </div>

        <div className="lp__footer">
          <span className="lp__hint"><Kbd keys={["up","down"]} size="sm" tone="ink" /> Navigate</span>
          <span className="lp__hint"><Kbd keys="enter" size="sm" tone="ink" /> Paste</span>
          <span className="lp__hint"><Kbd keys={["cmd","del"]} size="sm" tone="ink" /> Delete</span>
          <span style={{ flex: 1 }}></span>
          <span className="lp__hint"><Kbd keys="esc" size="sm" tone="ink" /> Close</span>
        </div>

        {toast && <div className="lp__toast"><I.Check size={15} /> {toast}</div>}
      </div>
    );
  }

  window.LatchPanel = LatchPanel;
})();
