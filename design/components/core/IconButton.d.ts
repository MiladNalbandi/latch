import * as React from "react";

/** Square, icon-only button — toolbar actions, row controls, panel chrome. */
export interface IconButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  /** @default "plain" */
  variant?: "plain" | "solid" | "outline";
  /** @default "md" */
  size?: "sm" | "md" | "lg";
  /** Toggle/selected state (applies green tint). @default false */
  active?: boolean;
  /** Accessible label — also used as the tooltip title. */
  label: string;
  /** The icon node (a Lucide <svg>). */
  children?: React.ReactNode;
}

export function IconButton(props: IconButtonProps): JSX.Element;
