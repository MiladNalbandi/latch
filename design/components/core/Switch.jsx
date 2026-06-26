import React from "react";

const CSS = `
.ltch-switch { display: inline-flex; align-items: center; gap: 10px; font-family: var(--font-sans); cursor: pointer; user-select: none; }
.ltch-switch[data-disabled="true"] { opacity: 0.45; pointer-events: none; }
.ltch-switch__track {
  position: relative; width: 40px; height: 24px; border-radius: var(--radius-full);
  background: var(--ink-200); transition: background var(--dur-base) var(--ease-out); flex: none;
}
.ltch-switch__track--sm { width: 32px; height: 19px; }
.ltch-switch__thumb {
  position: absolute; top: 2px; left: 2px; width: 20px; height: 20px; border-radius: 50%;
  background: #fff; box-shadow: var(--shadow-sm);
  transition: transform var(--dur-base) var(--ease-spring);
}
.ltch-switch__track--sm .ltch-switch__thumb { width: 15px; height: 15px; }
.ltch-switch[data-on="true"] .ltch-switch__track { background: var(--primary); }
.ltch-switch[data-on="true"] .ltch-switch__thumb { transform: translateX(16px); }
.ltch-switch[data-on="true"] .ltch-switch__track--sm .ltch-switch__thumb { transform: translateX(13px); }
.ltch-switch:focus-visible { outline: none; }
.ltch-switch:focus-visible .ltch-switch__track { box-shadow: var(--ring); }
.ltch-switch__label { font-size: 14px; font-weight: 500; color: var(--text-body); }
`;

function useCSS(id, css) {
  if (typeof document !== "undefined" && !document.getElementById(id)) {
    const s = document.createElement("style");
    s.id = id; s.textContent = css; document.head.appendChild(s);
  }
}

export function Switch({ checked = false, onChange, label, size = "md", disabled = false, className = "" }) {
  useCSS("ltch-switch-css", CSS);
  const toggle = () => { if (!disabled && onChange) onChange(!checked); };
  return (
    <label
      className={["ltch-switch", className].filter(Boolean).join(" ")}
      data-on={checked} data-disabled={disabled}
      tabIndex={disabled ? -1 : 0} role="switch" aria-checked={checked}
      onClick={toggle}
      onKeyDown={(e) => { if (e.key === " " || e.key === "Enter") { e.preventDefault(); toggle(); } }}
    >
      <span className={["ltch-switch__track", size === "sm" && "ltch-switch__track--sm"].filter(Boolean).join(" ")}>
        <span className="ltch-switch__thumb"></span>
      </span>
      {label && <span className="ltch-switch__label">{label}</span>}
    </label>
  );
}
