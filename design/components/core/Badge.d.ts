import * as React from "react";

/** Small status / category pill. Used for clip types, "Local only", "Pinned", counts. */
export interface BadgeProps {
  /** @default "neutral" */
  tone?: "neutral" | "primary" | "secure" | "accent" | "success" | "warning" | "danger" | "solid";
  /** @default "md" */
  size?: "sm" | "md";
  /** Show a leading status dot in the current color. @default false */
  dot?: boolean;
  /** Optional leading icon node. */
  icon?: React.ReactNode;
  children?: React.ReactNode;
}

export function Badge(props: BadgeProps): JSX.Element;
