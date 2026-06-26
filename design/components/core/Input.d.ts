import * as React from "react";

/** Text field with optional label, hint, leading/trailing icons, and a search variant. */
export interface InputProps extends Omit<React.InputHTMLAttributes<HTMLInputElement>, "size"> {
  label?: string;
  hint?: string;
  /** @default "md" */
  size?: "sm" | "md" | "lg";
  iconLeft?: React.ReactNode;
  iconRight?: React.ReactNode;
  /** Red error styling. @default false */
  invalid?: boolean;
  /** Filled "search box" treatment (used in the clip-history header). @default false */
  search?: boolean;
}

export function Input(props: InputProps): JSX.Element;
