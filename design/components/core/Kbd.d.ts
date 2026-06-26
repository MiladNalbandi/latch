import * as React from "react";

/**
 * Keyboard shortcut display — Latch's signature motif. Renders one or a sequence
 * of keycaps. Friendly names (`cmd`, `shift`, `enter`, `opt`…) auto-map to glyphs.
 *
 * @startingPoint section="Core" subtitle="Keycaps & shortcut sequences" viewport="700x150"
 */
export interface KbdProps {
  /** Keys as an array (`["cmd","shift","V"]`) or a "+"-joined string ("cmd+shift+V"). */
  keys?: string | string[];
  /** @default "md" */
  size?: "sm" | "md" | "lg";
  /** Cap styling. `go` = green primary key; `ink` = on dark surfaces. @default "default" */
  tone?: "default" | "go" | "ink";
  /** Alternative to `keys`: pass cap contents as children. */
  children?: React.ReactNode;
}

export function Kbd(props: KbdProps): JSX.Element;
