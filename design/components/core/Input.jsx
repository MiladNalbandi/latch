import React from "react";

const CSS = `
.ltch-field { display: flex; flex-direction: column; gap: 6px; font-family: var(--font-sans); }
.ltch-field__label { font-size: 13px; font-weight: 600; color: var(--text-body); }
.ltch-field__hint { font-size: 12px; color: var(--text-muted); }
.ltch-input {
  position: relative; display: flex; align-items: center; gap: 8px;
  background: var(--paper-0); border: 1px solid var(--border-strong); border-radius: var(--radius-md);
  padding: 0 12px; box-shadow: var(--inset-field);
  transition: border-color var(--dur-fast) var(--ease-out), box-shadow var(--dur-fast) var(--ease-out);
}
.ltch-input--md { height: 38px; } .ltch-input--sm { height: 32px; } .ltch-input--lg { height: 46px; }
.ltch-input:focus-within { border-color: var(--border-focus); box-shadow: var(--ring); }
.ltch-input--invalid { border-color: var(--danger); }
.ltch-input--invalid:focus-within { box-shadow: 0 0 0 3px color-mix(in srgb, var(--danger) 30%, transparent); }
.ltch-input__el {
  flex: 1; border: none; outline: none; background: transparent; min-width: 0;
  font-family: var(--font-sans); font-size: 15px; color: var(--text-strong);
}
.ltch-input__el::placeholder { color: var(--text-faint); }
.ltch-input__ico { display: inline-flex; color: var(--text-muted); }
.ltch-input__ico svg { width: 17px; height: 17px; display: block; }
.ltch-input--search { background: var(--paper-100); border-color: transparent; box-shadow: none; }
.ltch-input--search:focus-within { background: var(--paper-0); border-color: var(--border-focus); }
`;

function useCSS(id, css) {
  if (typeof document !== "undefined" && !document.getElementById(id)) {
    const s = document.createElement("style");
    s.id = id; s.textContent = css; document.head.appendChild(s);
  }
}

export function Input({
  label,
  hint,
  size = "md",
  iconLeft = null,
  iconRight = null,
  invalid = false,
  search = false,
  id,
  className = "",
  ...rest
}) {
  useCSS("ltch-input-css", CSS);
  const inputId = id || (label ? `ltch-${label.replace(/\s+/g, "-").toLowerCase()}` : undefined);
  const boxCls = [
    "ltch-input", `ltch-input--${size}`,
    invalid && "ltch-input--invalid", search && "ltch-input--search", className,
  ].filter(Boolean).join(" ");
  return (
    <div className="ltch-field">
      {label && <label className="ltch-field__label" htmlFor={inputId}>{label}</label>}
      <div className={boxCls}>
        {iconLeft && <span className="ltch-input__ico">{iconLeft}</span>}
        <input id={inputId} className="ltch-input__el" {...rest} />
        {iconRight && <span className="ltch-input__ico">{iconRight}</span>}
      </div>
      {hint && <span className="ltch-field__hint">{hint}</span>}
    </div>
  );
}
