import * as React from "react";

/** Surface container — settings groups, feature cards, marketing tiles. */
export interface CardProps extends React.HTMLAttributes<HTMLDivElement> {
  /** @default "default" */
  variant?: "default" | "raised" | "flat" | "ink";
  /** Inner padding. @default "md" */
  padding?: "none" | "sm" | "md" | "lg";
  /** Adds hover-lift + pointer for clickable cards. @default false */
  interactive?: boolean;
  children?: React.ReactNode;
}

export function Card(props: CardProps): JSX.Element;
