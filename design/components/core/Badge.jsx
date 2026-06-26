import React from "react";

const CSS = `
.ltch-badge {
  display: inline-flex; align-items: center; gap: 5px; font-family: var(--font-sans);
  font-weight: 600; font-size: 12px; line-height: 1; border-radius: var(--radius-full);
  padding: 4px 9px; border: 1px solid transparent; white-space: nowrap;
}
.ltch-badge--sm { font-size: 11px; padding: 3px 7px; gap: 4px; }
.ltch-badge--neutral { background: var(--paper-100); color: var(--text-muted); border-color: var(--line); }
.ltch-badge--primary { background: var(--primary-tint); color: var(--green-700); }
.ltch-badge--secure  { background: var(--secure-tint); color: var(--blue-600); }
.ltch-badge--accent  { background: var(--accent-tint); color: var(--amber-600); }
.ltch-badge--success { background: var(--success-tint); color: var(--green-700); }
.ltch-badge--warning { background: var(--warning-tint); color: var(--amber-600); }
.ltch-badge--danger  { background: var(--danger-tint); color: var(--red-600); }
.ltch-badge--solid   { background: var(--primary); color: #fff; }
.ltch-badge__dot { width: 6px; height: 6px; border-radius: 50%; background: currentColor; }
.ltch-badge svg { width: 13px; height: 13px; display: block; }
`;

function useCSS(id, css) {
  if (typeof document !== "undefined" && !document.getElementById(id)) {
    const s = document.createElement("style");
    s.id = id; s.textContent = css; document.head.appendChild(s);
  }
}

export function Badge({ tone = "neutral", size = "md", dot = false, icon = null, className = "", children }) {
  useCSS("ltch-badge-css", CSS);
  const cls = ["ltch-badge", `ltch-badge--${tone}`, size === "sm" && "ltch-badge--sm", className].filter(Boolean).join(" ");
  return (
    <span className={cls}>
      {dot && <span className="ltch-badge__dot"></span>}
      {icon}
      {children}
    </span>
  );
}
