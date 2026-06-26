import * as React from "react";

/**
 * A single row in the Latch clipboard history — the product's signature object.
 * Shows a type glyph, content preview, source app, time, pin state, and a
 * keyboard index that appears on hover/select.
 *
 * @startingPoint section="Clipboard" subtitle="Clipboard history row" viewport="700x150"
 */
export interface ClipItemProps extends React.HTMLAttributes<HTMLDivElement> {
  /** Content kind — drives the leading glyph & styling. @default "text" */
  type?: "text" | "link" | "image" | "code" | "color" | "file";
  /** Preview text (or a hex string when type="color", or an <img> via `icon`). */
  content?: string;
  /** Originating app, e.g. "Safari". */
  source?: string;
  /** Relative time, e.g. "2m ago". */
  time?: string;
  /** Pinned to top. @default false */
  pinned?: boolean;
  /** Keyboard-selected (green tint). @default false */
  selected?: boolean;
  /** Quick-paste index shown on hover (1–9). */
  index?: number | string;
  /** Override the kind glyph with a custom node (Lucide icon or <img>). */
  icon?: React.ReactNode;
}

export function ClipItem(props: ClipItemProps): JSX.Element;
