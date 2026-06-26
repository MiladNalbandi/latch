import React from "react";

const CSS = `
.ltch-kbd { display: inline-flex; align-items: center; gap: 4px; font-family: var(--font-mono); vertical-align: middle; }
.ltch-kbd__cap {
  font-family: var(--font-mono); font-weight: 600; color: var(--ink-800);
  background: var(--paper-0); border: 1px solid var(--line-strong); border-bottom-width: 2px;
  border-radius: var(--radius-keycap); text-align: center; box-shadow: var(--shadow-keycap);
  display: inline-flex; align-items: center; justify-content: center;
}
.ltch-kbd--sm .ltch-kbd__cap { font-size: 11px; min-width: 14px; padding: 3px 5px; }
.ltch-kbd--md .ltch-kbd__cap { font-size: 13px; min-width: 18px; padding: 5px 8px; }
.ltch-kbd--lg .ltch-kbd__cap { font-size: 16px; min-width: 22px; padding: 8px 11px; border-bottom-width: 2.5px; }
.ltch-kbd__cap--go { background: var(--primary); color: #fff; border-color: var(--primary-press); }
.ltch-kbd__cap--ink { background: var(--ink-surface-2); color: var(--text-on-ink); border-color: #000; }
.ltch-kbd__plus { color: var(--text-faint); font-size: 0.85em; }
`;

function useCSS(id, css) {
  if (typeof document !== "undefined" && !document.getElementById(id)) {
    const s = document.createElement("style");
    s.id = id; s.textContent = css; document.head.appendChild(s);
  }
}

// Common token aliases → display glyphs
const GLYPH = { cmd: "⌘", command: "⌘", shift: "⇧", opt: "⌥", option: "⌥", alt: "⌥",
  ctrl: "⌃", control: "⌃", enter: "↩", return: "↩", esc: "⎋", escape: "⎋",
  space: "Space", tab: "⇥", del: "⌫", backspace: "⌫", up: "↑", down: "↓", left: "←", right: "→" };

export function Kbd({ keys, size = "md", tone = "default", className = "", children }) {
  useCSS("ltch-kbd-css", CSS);
  let parts;
  if (keys) parts = Array.isArray(keys) ? keys : String(keys).split("+").map((k) => k.trim());
  else parts = React.Children.toArray(children);

  const capCls = ["ltch-kbd__cap", tone !== "default" && `ltch-kbd__cap--${tone}`].filter(Boolean).join(" ");
  return (
    <span className={["ltch-kbd", `ltch-kbd--${size}`, className].filter(Boolean).join(" ")}>
      {parts.map((p, i) => {
        const label = typeof p === "string" ? (GLYPH[p.toLowerCase()] || p) : p;
        return (
          <React.Fragment key={i}>
            {i > 0 && <span className="ltch-kbd__plus">+</span>}
            <kbd className={capCls}>{label}</kbd>
          </React.Fragment>
        );
      })}
    </span>
  );
}
