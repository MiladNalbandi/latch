import React from "react";

const CSS = `
.ltch-iconbtn {
  font-family: var(--font-sans); display: inline-flex; align-items: center; justify-content: center;
  border: 1px solid transparent; background: transparent; color: var(--text-body);
  cursor: pointer; border-radius: var(--radius-md);
  transition: background var(--dur-fast) var(--ease-out), color var(--dur-fast) var(--ease-out), transform var(--dur-instant) var(--ease-out);
}
.ltch-iconbtn:hover { background: var(--paper-100); color: var(--text-strong); }
.ltch-iconbtn:active { transform: scale(var(--press-scale)); background: var(--paper-200); }
.ltch-iconbtn:focus-visible { outline: none; box-shadow: var(--ring); }
.ltch-iconbtn[disabled] { opacity: 0.4; pointer-events: none; }
.ltch-iconbtn--sm { width: 28px; height: 28px; border-radius: var(--radius-sm); }
.ltch-iconbtn--md { width: 34px; height: 34px; }
.ltch-iconbtn--lg { width: 42px; height: 42px; border-radius: var(--radius-lg); }
.ltch-iconbtn--solid { background: var(--primary); color: #fff; }
.ltch-iconbtn--solid:hover { background: var(--primary-hover); color: #fff; }
.ltch-iconbtn--solid:active { background: var(--primary-press); }
.ltch-iconbtn--outline { border-color: var(--border-strong); background: var(--paper-0); }
.ltch-iconbtn--active { background: var(--primary-tint); color: var(--primary-press); }
.ltch-iconbtn svg { width: 1.05em; height: 1.05em; display: block; }
.ltch-iconbtn--sm svg { font-size: 15px; } .ltch-iconbtn--md svg { font-size: 18px; } .ltch-iconbtn--lg svg { font-size: 20px; }
`;

function useCSS(id, css) {
  if (typeof document !== "undefined" && !document.getElementById(id)) {
    const s = document.createElement("style");
    s.id = id; s.textContent = css; document.head.appendChild(s);
  }
}

export function IconButton({
  variant = "plain",
  size = "md",
  active = false,
  disabled = false,
  label,
  className = "",
  children,
  ...rest
}) {
  useCSS("ltch-iconbtn-css", CSS);
  const cls = [
    "ltch-iconbtn",
    `ltch-iconbtn--${size}`,
    variant !== "plain" && `ltch-iconbtn--${variant}`,
    active && "ltch-iconbtn--active",
    className,
  ].filter(Boolean).join(" ");
  return (
    <button type="button" className={cls} disabled={disabled} aria-label={label} title={label} {...rest}>
      {children}
    </button>
  );
}
