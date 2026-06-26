import React from "react";

const CSS = `
.ltch-card {
  font-family: var(--font-sans); background: var(--surface-card); border: 1px solid var(--border-subtle);
  border-radius: var(--radius-card); box-shadow: var(--shadow-sm); overflow: hidden;
}
.ltch-card--raised { box-shadow: var(--shadow-md); border-color: transparent; }
.ltch-card--flat { box-shadow: none; }
.ltch-card--ink { background: var(--ink-surface); border-color: var(--ink-line); color: var(--text-on-ink); }
.ltch-card--interactive { cursor: pointer; transition: box-shadow var(--dur-fast) var(--ease-out), transform var(--dur-fast) var(--ease-out), border-color var(--dur-fast) var(--ease-out); }
.ltch-card--interactive:hover { box-shadow: var(--shadow-lg); transform: translateY(-2px); border-color: var(--border-strong); }
.ltch-card--interactive:active { transform: translateY(0); box-shadow: var(--shadow-md); }
.ltch-card__pad { padding: var(--_pad, 18px); }
`;

function useCSS(id, css) {
  if (typeof document !== "undefined" && !document.getElementById(id)) {
    const s = document.createElement("style");
    s.id = id; s.textContent = css; document.head.appendChild(s);
  }
}

const PAD = { none: "0", sm: "12px", md: "18px", lg: "24px" };

export function Card({ variant = "default", padding = "md", interactive = false, className = "", style, children, ...rest }) {
  useCSS("ltch-card-css", CSS);
  const cls = [
    "ltch-card",
    variant !== "default" && `ltch-card--${variant}`,
    interactive && "ltch-card--interactive",
    className,
  ].filter(Boolean).join(" ");
  const inner = padding === "none"
    ? children
    : <div className="ltch-card__pad" style={{ "--_pad": PAD[padding] }}>{children}</div>;
  return <div className={cls} style={style} {...rest}>{inner}</div>;
}
