import React from "react";

const CSS = `
.ltch-btn {
  --_bg: var(--primary); --_fg: var(--text-on-primary); --_bd: transparent; --_bgh: var(--primary-hover); --_bgp: var(--primary-press);
  font-family: var(--font-sans); font-weight: 600; line-height: 1;
  display: inline-flex; align-items: center; justify-content: center; gap: 8px;
  border: 1px solid var(--_bd); border-radius: var(--radius-md);
  background: var(--_bg); color: var(--_fg); cursor: pointer; white-space: nowrap;
  transition: background var(--dur-fast) var(--ease-out), transform var(--dur-instant) var(--ease-out), box-shadow var(--dur-fast) var(--ease-out);
  user-select: none;
}
.ltch-btn:hover { background: var(--_bgh); }
.ltch-btn:active { background: var(--_bgp); transform: scale(var(--press-scale)); }
.ltch-btn:focus-visible { outline: none; box-shadow: var(--ring); }
.ltch-btn[disabled] { opacity: 0.45; pointer-events: none; }
.ltch-btn--sm { font-size: 13px; padding: 6px 11px; border-radius: var(--radius-sm); gap: 6px; }
.ltch-btn--md { font-size: 15px; padding: 9px 16px; }
.ltch-btn--lg { font-size: 16px; padding: 12px 22px; border-radius: var(--radius-lg); }
.ltch-btn--full { width: 100%; }
.ltch-btn--secondary { --_bg: var(--paper-0); --_fg: var(--text-strong); --_bd: var(--border-strong); --_bgh: var(--paper-100); --_bgp: var(--paper-200); box-shadow: var(--shadow-xs); }
.ltch-btn--ghost { --_bg: transparent; --_fg: var(--text-body); --_bd: transparent; --_bgh: var(--paper-100); --_bgp: var(--paper-200); }
.ltch-btn--danger { --_bg: var(--danger); --_fg: #fff; --_bgh: var(--red-600); --_bgp: var(--red-600); }
.ltch-btn--secure { --_bg: var(--secure); --_fg: #fff; --_bgh: var(--blue-600); --_bgp: var(--blue-600); }
.ltch-btn__ico { display: inline-flex; width: 1em; height: 1em; }
.ltch-btn__ico svg { width: 100%; height: 100%; display: block; }
`;

function useCSS(id, css) {
  if (typeof document !== "undefined" && !document.getElementById(id)) {
    const s = document.createElement("style");
    s.id = id; s.textContent = css; document.head.appendChild(s);
  }
}

export function Button({
  variant = "primary",
  size = "md",
  iconLeft = null,
  iconRight = null,
  fullWidth = false,
  disabled = false,
  type = "button",
  className = "",
  children,
  ...rest
}) {
  useCSS("ltch-btn-css", CSS);
  const cls = [
    "ltch-btn",
    `ltch-btn--${size}`,
    variant !== "primary" && `ltch-btn--${variant}`,
    fullWidth && "ltch-btn--full",
    className,
  ].filter(Boolean).join(" ");
  return (
    <button type={type} className={cls} disabled={disabled} {...rest}>
      {iconLeft && <span className="ltch-btn__ico">{iconLeft}</span>}
      {children}
      {iconRight && <span className="ltch-btn__ico">{iconRight}</span>}
    </button>
  );
}
