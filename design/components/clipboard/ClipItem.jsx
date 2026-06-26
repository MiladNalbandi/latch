import React from "react";

const CSS = `
.ltch-clip {
  display: flex; align-items: center; gap: 12px; font-family: var(--font-sans);
  padding: 10px 12px; border-radius: var(--radius-md); cursor: pointer; position: relative;
  border: 1px solid transparent;
  transition: background var(--dur-fast) var(--ease-out), border-color var(--dur-fast) var(--ease-out);
}
.ltch-clip:hover { background: var(--paper-100); }
.ltch-clip[data-selected="true"] { background: var(--primary-tint-soft); border-color: var(--primary-tint); }
.ltch-clip[data-selected="true"]:hover { background: var(--primary-tint-soft); }
.ltch-clip__kind {
  flex: none; width: 38px; height: 38px; border-radius: var(--radius-sm);
  display: grid; place-items: center; font-family: var(--font-mono); font-weight: 600; font-size: 13px;
  background: var(--paper-100); color: var(--text-muted); border: 1px solid var(--line);
  overflow: hidden;
}
.ltch-clip__kind svg { width: 18px; height: 18px; }
.ltch-clip__kind img { width: 100%; height: 100%; object-fit: cover; }
.ltch-clip__kind--link { background: var(--secure-tint); color: var(--blue-600); border-color: transparent; }
.ltch-clip__kind--code { background: var(--ink-surface); color: var(--green-300); border-color: transparent; }
.ltch-clip__kind--color { border-color: var(--line); }
.ltch-clip__body { flex: 1; min-width: 0; }
.ltch-clip__text {
  font-size: 14px; color: var(--text-strong); font-weight: 500;
  white-space: nowrap; overflow: hidden; text-overflow: ellipsis; margin-bottom: 3px;
}
.ltch-clip__text--mono { font-family: var(--font-mono); font-size: 13px; }
.ltch-clip__meta { display: flex; align-items: center; gap: 7px; font-size: 12px; color: var(--text-muted); }
.ltch-clip__meta b { font-weight: 600; color: var(--text-body); }
.ltch-clip__dotsep { width: 3px; height: 3px; border-radius: 50%; background: var(--ink-200); }
.ltch-clip__right { flex: none; display: flex; align-items: center; gap: 8px; }
.ltch-clip__pin { color: var(--amber-500); display: inline-flex; }
.ltch-clip__pin svg { width: 15px; height: 15px; }
.ltch-clip__idx {
  font-family: var(--font-mono); font-size: 11px; font-weight: 600; color: var(--text-faint);
  background: var(--paper-0); border: 1px solid var(--line-strong); border-bottom-width: 2px;
  border-radius: var(--radius-keycap); min-width: 16px; height: 22px; padding: 0 6px;
  display: none; align-items: center; justify-content: center;
}
.ltch-clip:hover .ltch-clip__idx, .ltch-clip[data-selected="true"] .ltch-clip__idx { display: inline-flex; }
`;

function useCSS(id, css) {
  if (typeof document !== "undefined" && !document.getElementById(id)) {
    const s = document.createElement("style");
    s.id = id; s.textContent = css; document.head.appendChild(s);
  }
}

const KIND_LABEL = { text: "T", link: "↗", image: "▦", code: "{}", color: "", file: "▤" };

export function ClipItem({
  type = "text",
  content = "",
  source,
  time,
  pinned = false,
  selected = false,
  index,
  icon,
  className = "",
  ...rest
}) {
  useCSS("ltch-clip-css", CSS);
  const isColor = type === "color";
  const kindCls = ["ltch-clip__kind", `ltch-clip__kind--${type}`].filter(Boolean).join(" ");
  return (
    <div className={["ltch-clip", className].filter(Boolean).join(" ")} data-selected={selected} role="option" aria-selected={selected} {...rest}>
      <div className={kindCls} style={isColor ? { background: content, color: "transparent" } : undefined}>
        {icon || (type === "image" ? null : KIND_LABEL[type])}
      </div>
      <div className="ltch-clip__body">
        <div className={["ltch-clip__text", (type === "code" || type === "link") && "ltch-clip__text--mono"].filter(Boolean).join(" ")}>
          {content}
        </div>
        <div className="ltch-clip__meta">
          {source && <b>{source}</b>}
          {source && time && <span className="ltch-clip__dotsep"></span>}
          {time && <span>{time}</span>}
        </div>
      </div>
      <div className="ltch-clip__right">
        {pinned && (
          <span className="ltch-clip__pin" title="Pinned">
            <svg viewBox="0 0 24 24" fill="currentColor"><path d="M9.5 2h5l-1 6 3 3v2h-5v7l-1.5 2-1.5-2v-7H4v-2l3-3-1-6z"/></svg>
          </span>
        )}
        {index != null && <span className="ltch-clip__idx">{index}</span>}
      </div>
    </div>
  );
}
