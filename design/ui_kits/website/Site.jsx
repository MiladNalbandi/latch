/* Latch marketing site — composed from DS primitives. Well-factored sections. */
(function () {
  const { Button, Badge, Kbd, Card, ClipItem } = window.LatchDesignSystem_fe0ecb;
  const I = window.LatchIcons;

  function Nav() {
    return (
      <header className="nav">
        <div className="nav__inner">
          <a className="nav__brand" href="#">
            <img src="../../assets/latch-mark.svg" width="30" height="30" alt="" />
            <span>Latch</span>
          </a>
          <nav className="nav__links">
            <a href="#features">Features</a>
            <a href="#security">Security</a>
            <a href="#pricing">Pricing</a>
            <a href="#">Changelog</a>
          </nav>
          <div className="nav__cta">
            <a className="nav__signin" href="#">Sign in</a>
            <Button size="sm" iconLeft={<I.Apple size={15} />}>Download</Button>
          </div>
        </div>
      </header>
    );
  }

  function HeroPanel() {
    const rows = [
      { type: "link", content: "latch.app/security", source: "Safari", time: "now", index: 1, selected: true },
      { type: "text", content: "Thanks so much — talk Thursday!", source: "Mail", time: "4m", index: 2, pinned: true },
      { type: "color", content: "#12a877", source: "Figma", time: "12m", index: 3 },
      { type: "code", content: "git rebase -i HEAD~3", source: "Terminal", time: "26m", index: 4 },
    ];
    return (
      <div className="hero__panel">
        <div className="hero__panel-search">
          <I.Search size={16} />
          <span>Search your clipboard…</span>
          <span className="hero__panel-badge"><I.Shield size={12} /> Local only</span>
        </div>
        <div className="hero__panel-list">
          {rows.map((r, i) => <ClipItem key={i} {...r} />)}
        </div>
        <div className="hero__panel-foot">
          <span><Kbd keys={["up","down"]} size="sm" tone="ink" /> Navigate</span>
          <span><Kbd keys="enter" size="sm" tone="ink" /> Paste</span>
          <span style={{ flex: 1 }}></span>
          <span><Kbd keys="esc" size="sm" tone="ink" /> Close</span>
        </div>
      </div>
    );
  }

  function Hero() {
    return (
      <section className="hero">
        <div className="hero__copy">
          <Badge tone="primary" icon={<I.Sparkles size={13} />}>Now for macOS Sonoma</Badge>
          <h1>Copy once.<br /> Paste anywhere.</h1>
          <p>Latch remembers everything you copy and brings it back with one friendly shortcut. Private by default — nothing leaves your Mac.</p>
          <div className="hero__actions">
            <Button size="lg" iconLeft={<I.Apple size={18} />}>Download for Mac</Button>
            <div className="hero__shortcut">Press <Kbd keys="cmd+shift+V" /> anywhere</div>
          </div>
          <div className="hero__trust">
            <span><I.Shield size={15} /> On-device & encrypted</span>
            <span><I.Check size={15} /> Free for 200 clips</span>
          </div>
        </div>
        <HeroPanel />
      </section>
    );
  }

  const FEATURES = [
    { Icon: "Clock", title: "A clipboard with a memory", body: "Your last 200 copies, always a keystroke away. Text, links, images, colors, files — Latch keeps them all in order." },
    { Icon: "Command", title: "Built for the keyboard", body: "Open with ⌘⇧V, filter as you type, hit a number to paste. Your hands never leave the home row." },
    { Icon: "Pin", title: "Pin what matters", body: "Keep your address, a signature, or that one command pinned to the top. The rest rolls off automatically." },
    { Icon: "Shield", title: "Private by default", body: "History lives encrypted in your keychain. Passwords are skipped automatically. No account, no cloud, unless you ask." },
  ];

  function Features() {
    return (
      <section className="sec" id="features">
        <div className="sec__head">
          <Badge tone="neutral">Features</Badge>
          <h2>Everything you copy, exactly when you need it.</h2>
        </div>
        <div className="feat-grid">
          {FEATURES.map((f, i) => {
            const Ico = I[f.Icon];
            return (
              <Card key={i} variant="raised" padding="lg" className="feat">
                <div className="feat__ico"><Ico size={20} /></div>
                <div className="feat__title">{f.title}</div>
                <div className="feat__body">{f.body}</div>
              </Card>
            );
          })}
        </div>
      </section>
    );
  }

  function Security() {
    return (
      <section className="security" id="security">
        <div className="security__inner">
          <div className="security__copy">
            <Badge tone="secure" icon={<I.Lock size={13} />}>Security</Badge>
            <h2>Your clipboard is nobody's business but yours.</h2>
            <p>Latch stores history encrypted in your login keychain and never sends it anywhere by default. Turn on sync and it stays end-to-end encrypted across your devices.</p>
            <ul className="security__list">
              <li><I.Check size={17} /> On-device storage, encrypted at rest</li>
              <li><I.Check size={17} /> Passwords & secure fields skipped automatically</li>
              <li><I.Check size={17} /> Incognito mode pauses capture in one tap</li>
              <li><I.Check size={17} /> Open about what's stored — clear it anytime</li>
            </ul>
          </div>
          <div className="security__card">
            <div className="security__lock"><I.Lock size={30} /></div>
            <div className="security__big">200</div>
            <div className="security__sub">clips kept on this Mac</div>
            <div className="security__divider"></div>
            <div className="security__stat"><span>Sent to the cloud</span><b>0 bytes</b></div>
            <div className="security__stat"><span>Accounts required</span><b>None</b></div>
          </div>
        </div>
      </section>
    );
  }

  function Pricing() {
    const plans = [
      { name: "Free", price: "$0", note: "forever", feats: ["Last 200 clips", "All clip types", "Pin & search", "On-device & private"], cta: "Download", variant: "secondary" },
      { name: "Pro", price: "$3", note: "/ month", feats: ["Unlimited history", "End-to-end sync", "Smart filters & snippets", "Priority support"], cta: "Start free trial", variant: "primary", featured: true },
    ];
    return (
      <section className="sec" id="pricing">
        <div className="sec__head">
          <Badge tone="neutral">Pricing</Badge>
          <h2>Free to start. A few dollars to go unlimited.</h2>
        </div>
        <div className="price-grid">
          {plans.map((p, i) => (
            <Card key={i} variant={p.featured ? "raised" : "default"} padding="lg" className={"price" + (p.featured ? " price--feat" : "")}>
              {p.featured && <div className="price__tag"><Badge tone="primary">Most popular</Badge></div>}
              <div className="price__name">{p.name}</div>
              <div className="price__amount">{p.price}<span>{p.note}</span></div>
              <ul className="price__feats">
                {p.feats.map((f, j) => <li key={j}><I.Check size={16} /> {f}</li>)}
              </ul>
              <Button variant={p.variant} fullWidth>{p.cta}</Button>
            </Card>
          ))}
        </div>
      </section>
    );
  }

  function Footer() {
    return (
      <footer className="foot">
        <div className="foot__inner">
          <div className="foot__brand">
            <img src="../../assets/latch-wordmark-onink.svg" height="32" alt="Latch" />
            <p>The friendly, private clipboard for macOS.</p>
            <div className="foot__shortcut"><Kbd keys="cmd+shift+V" tone="ink" /></div>
          </div>
          <div className="foot__cols">
            <div><h4>Product</h4><a href="#">Features</a><a href="#">Security</a><a href="#">Pricing</a><a href="#">Changelog</a></div>
            <div><h4>Company</h4><a href="#">About</a><a href="#">Blog</a><a href="#">Contact</a></div>
            <div><h4>Legal</h4><a href="#">Privacy</a><a href="#">Terms</a></div>
          </div>
        </div>
        <div className="foot__bar">
          <span>© 2026 Latch. Made for Mac.</span>
          <span>Designed in the open.</span>
        </div>
      </footer>
    );
  }

  function Site() {
    return (
      <div className="site">
        <Nav />
        <Hero />
        <Features />
        <Security />
        <Pricing />
        <Footer />
      </div>
    );
  }

  window.LatchSite = Site;
})();
