import * as React from "react";

/** On/off toggle for settings rows (sync, launch-at-login, exclude-passwords…). */
export interface SwitchProps {
  /** @default false */
  checked?: boolean;
  /** Called with the next boolean state. */
  onChange?: (next: boolean) => void;
  /** Optional trailing label. */
  label?: string;
  /** @default "md" */
  size?: "sm" | "md";
  disabled?: boolean;
}

export function Switch(props: SwitchProps): JSX.Element;
