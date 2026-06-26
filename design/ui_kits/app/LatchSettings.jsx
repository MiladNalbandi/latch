/* LatchSettings — macOS-style preferences window. */
(function () {
  const { Switch, Button, Badge, Kbd, Input } = window.LatchDesignSystem_fe0ecb;
  const I = window.LatchIcons;

  function Row({ title, desc, children }) {
    return (
      <div className="ls-row">
        <div className="ls-row__text">
          <div className="ls-row__title">{title}</div>
          {desc && <div className="ls-row__desc">{desc}</div>}
        </div>
        <div className="ls-row__control">{children}</div>
      </div>
    );
  }

  function Section({ title, children }) {
    return (
      <div className="ls-section">
        <div className="ls-section__title">{title}</div>
        <div className="ls-card">{children}</div>
      </div>
    );
  }

  const TABS = [
    { key: "general", label: "General", Icon: I.Settings },
    { key: "privacy", label: "Privacy", Icon: I.Shield },
    { key: "sync",    label: "Sync",    Icon: I.Sparkles },
  ];

  function LatchSettings({ onClose, accents = [], accentKey, onAccent }) {
    const [tab, setTab] = React.useState("general");
    const [s, setS] = React.useState({
      launch: true, sound: false, showCount: true,
      excludePw: true, clearOnLock: false, incognito: false,
      sync: true, history: 200,
    });
    const set = (k) => (v) => setS((p) => ({ ...p, [k]: v }));

    return (
      <div className="ls">
        <div className="ls__titlebar">
          <div className="ls__traffic">
            <span className="tl tl--r" onClick={onClose}></span>
            <span className="tl tl--y"></span>
            <span className="tl tl--g"></span>
          </div>
          <div className="ls__title">Latch Settings</div>
          <div style={{ width: 52 }}></div>
        </div>

        <div className="ls__tabs">
          {TABS.map((t) => (
            <button key={t.key} className={"ls__tab" + (tab === t.key ? " is-on" : "")} onClick={() => setTab(t.key)}>
              <t.Icon size={17} /> {t.label}
            </button>
          ))}
        </div>

        <div className="ls__body">
          {tab === "general" && (
            <React.Fragment>
              <Section title="Appearance">
                <Row title="Accent color" desc="Used for selection, controls, and highlights — follows your macOS accent.">
                  <div className="ls-accents">
                    {accents.map((a) => (
                      <button key={a.key}
                        className={"ls-accent" + (a.key === accentKey ? " is-on" : "")}
                        style={{ background: a.value, color: a.value }}
                        title={a.name} aria-label={a.name}
                        onClick={() => onAccent && onAccent(a.key)}>
                        {a.key === accentKey && (
                          <span style={{ color: a.on, display: "inline-flex" }}><I.Check size={12} strokeWidth={3} /></span>
                        )}
                      </button>
                    ))}
                  </div>
                </Row>
              </Section>
              <Section title="Startup">
                <Row title="Launch Latch at login" desc="Keep your history a keystroke away.">
                  <Switch checked={s.launch} onChange={set("launch")} />
                </Row>
                <Row title="Play a sound on copy" desc="A soft tick when something's captured.">
                  <Switch checked={s.sound} onChange={set("sound")} />
                </Row>
                <Row title="Show item count in menu bar">
                  <Switch checked={s.showCount} onChange={set("showCount")} />
                </Row>
              </Section>
              <Section title="Shortcut">
                <Row title="Open clipboard history" desc="The one you'll use a hundred times a day.">
                  <Kbd keys="cmd+shift+V" />
                </Row>
                <Row title="Quick-paste recent" desc="Paste the last copy without opening Latch.">
                  <Kbd keys="cmd+opt+V" />
                </Row>
              </Section>
            </React.Fragment>
          )}

          {tab === "privacy" && (
            <React.Fragment>
              <div className="ls-banner">
                <I.Lock size={18} />
                <div>
                  <b>Your clipboard never leaves this Mac by default.</b>
                  <div>History is stored encrypted in your login keychain. No account required.</div>
                </div>
              </div>
              <Section title="What Latch captures">
                <Row title="Ignore passwords" desc="Skip anything copied from a password manager.">
                  <Switch checked={s.excludePw} onChange={set("excludePw")} />
                </Row>
                <Row title="Clear history when Mac locks">
                  <Switch checked={s.clearOnLock} onChange={set("clearOnLock")} />
                </Row>
                <Row title="Pause capture (incognito)" desc="Temporarily stop recording new copies.">
                  <Switch checked={s.incognito} onChange={set("incognito")} />
                </Row>
              </Section>
              <div className="ls-foot">
                <Button variant="danger" iconLeft={<I.Trash size={15} />}>Clear all history…</Button>
              </div>
            </React.Fragment>
          )}

          {tab === "sync" && (
            <React.Fragment>
              <Section title="iCloud sync">
                <Row title="Sync across your devices" desc="End-to-end encrypted. Only your devices can read it.">
                  <Switch checked={s.sync} onChange={set("sync")} />
                </Row>
                <Row title="Devices">
                  <div style={{ display: "flex", gap: 6 }}>
                    <Badge tone="success" dot>MacBook Pro</Badge>
                    <Badge tone="neutral" dot>Mac mini</Badge>
                  </div>
                </Row>
              </Section>
              <Section title="History">
                <Row title="Keep the last" desc="Older clips fall off automatically.">
                  <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
                    <Badge tone="primary">{s.history} items</Badge>
                  </div>
                </Row>
              </Section>
            </React.Fragment>
          )}
        </div>
      </div>
    );
  }

  window.LatchSettings = LatchSettings;
})();
