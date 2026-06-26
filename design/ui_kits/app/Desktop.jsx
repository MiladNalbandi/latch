/* Desktop — a faux macOS scene hosting the Latch panel + settings window. */
(function () {
  const I = window.LatchIcons;
  const { Kbd } = window.LatchDesignSystem_fe0ecb;

  function MenuBar({ count, onToggle, panelOpen }) {
    return (
      <div className="mb">
        <div className="mb__left">
          <span className="mb__apple"><I.Apple size={15} /></span>
          <span className="mb__app">Latch</span>
          <span className="mb__menu">File</span>
          <span className="mb__menu">Edit</span>
          <span className="mb__menu">View</span>
          <span className="mb__menu">Help</span>
        </div>
        <div className="mb__right">
          <span className="mb__status"><I.Shield size={15} /></span>
          <button className={"mb__latch" + (panelOpen ? " is-on" : "")} onClick={onToggle} title="Latch — ⌘⇧V">
            <I.Clipboard size={15} />
            <span className="mb__count">{count}</span>
          </button>
          <span className="mb__clock">9:41</span>
        </div>
      </div>
    );
  }

  // macOS system accent colors (System Settings → Appearance). "Latch" is the brand default.
  const ACCENTS = [
    { key: "latch",    name: "Latch",    value: "#12a877", on: "#ffffff" },
    { key: "blue",     name: "Blue",     value: "#007aff", on: "#ffffff" },
    { key: "purple",   name: "Purple",   value: "#a64dd6", on: "#ffffff" },
    { key: "pink",     name: "Pink",     value: "#f74f9e", on: "#ffffff" },
    { key: "red",      name: "Red",      value: "#ff5257", on: "#ffffff" },
    { key: "orange",   name: "Orange",   value: "#f7821b", on: "#ffffff" },
    { key: "yellow",   name: "Yellow",   value: "#ffc402", on: "#3a2c00" },
    { key: "graphite", name: "Graphite", value: "#8a8a8e", on: "#ffffff" },
  ];

  function Desktop() {
    const [panelOpen, setPanelOpen] = React.useState(true);
    const [settingsOpen, setSettingsOpen] = React.useState(false);
    const [accentKey, setAccentKey] = React.useState(() => {
      try { return localStorage.getItem("latch-accent") || "latch"; } catch (e) { return "latch"; }
    });
    const accent = ACCENTS.find((a) => a.key === accentKey) || ACCENTS[0];
    React.useEffect(() => { try { localStorage.setItem("latch-accent", accentKey); } catch (e) {} }, [accentKey]);
    // Suppress transitions for one frame so accent recolor snaps instead of sticking mid-transition.
    React.useEffect(() => {
      const root = document.documentElement;
      root.classList.add("latch-no-transition");
      const id = requestAnimationFrame(() => requestAnimationFrame(() => root.classList.remove("latch-no-transition")));
      return () => cancelAnimationFrame(id);
    }, [accentKey]);
    const count = (window.LATCH_CLIPS || []).length;

    React.useEffect(() => {
      const onKey = (e) => {
        if ((e.metaKey || e.ctrlKey) && e.shiftKey && (e.key === "V" || e.key === "v")) {
          e.preventDefault(); setPanelOpen((o) => !o);
        }
      };
      window.addEventListener("keydown", onKey);
      return () => window.removeEventListener("keydown", onKey);
    }, []);

    return (
      <div className="desk" style={{ "--primary": accent.value, "--text-on-primary": accent.on }}>
        <MenuBar count={count} panelOpen={panelOpen} onToggle={() => setPanelOpen((o) => !o)} />

        {/* desktop hint */}
        {!panelOpen && !settingsOpen && (
          <div className="desk__hint">
            <div className="desk__hint-card">
              <span className="desk__hint-icon"><I.Clipboard size={22} /></span>
              <div className="desk__hint-text">
                <b>Open your clipboard history</b>
                <div className="desk__hint-sub">Press this anywhere on your Mac — even inside another app.</div>
              </div>
              <div className="desk__hint-keys"><Kbd keys="cmd+shift+V" size="lg" tone="ink" /></div>
            </div>
          </div>
        )}

        {panelOpen && (
          <div className="desk__panel">
            <window.LatchPanel
              onClose={() => setPanelOpen(false)}
              onOpenSettings={() => setSettingsOpen(true)}
            />
          </div>
        )}

        {settingsOpen && (
          <div className="desk__modal" onMouseDown={(e) => { if (e.target === e.currentTarget) setSettingsOpen(false); }}>
            <window.LatchSettings
              onClose={() => setSettingsOpen(false)}
              accents={ACCENTS} accentKey={accentKey} onAccent={setAccentKey}
            />
          </div>
        )}
      </div>
    );
  }

  window.LatchDesktop = Desktop;
})();
