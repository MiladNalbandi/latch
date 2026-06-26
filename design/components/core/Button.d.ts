import * as React from "react";

/**
 * Primary action button for Latch. Friendly, native-macOS feel: soft radius,
 * quick press-scale to 0.97, green primary.
 *
 * @startingPoint section="Core" subtitle="Buttons in every variant & size" viewport="700x150"
 */
export interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  /** Visual style. @default "primary" */
  variant?: "primary" | "secondary" | "ghost" | "danger" | "secure";
  /** Control size. @default "md" */
  size?: "sm" | "md" | "lg";
  /** Icon node rendered before the label (e.g. a Lucide <svg>). */
  iconLeft?: React.ReactNode;
  /** Icon node rendered after the label. */
  iconRight?: React.ReactNode;
  /** Stretch to fill container width. @default false */
  fullWidth?: boolean;
  disabled?: boolean;
  children?: React.ReactNode;
}

export function Button(props: ButtonProps): JSX.Element;
