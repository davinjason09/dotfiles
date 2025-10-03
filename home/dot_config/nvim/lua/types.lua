---@meta

-- ╾╼ Terminal ╾──────────────────────────────────────────────────────╼

---@alias TermOpts { persist?: boolean, auto_close?: boolean }
---@alias TermBuf { bufnr: number, name: string, cmd?: string | string[], opts?: TermOpts, job_id: integer }

-- ╾╼ Color Palette ╾─────────────────────────────────────────────────╼

---@class CtpColors<T>: {
---  rosewater: T,
---  flamingo: T,
---  pink: T,
---  mauve: T,
---  red: T,
---  maroon: T,
---  peach: T,
---  yellow: T,
---  green: T,
---  teal: T,
---  sky: T,
---  sapphire: T,
---  blue: T,
---  lavender: T,
---  text: T,
---  subtext1: T,
---  subtext0: T,
---  overlay2: T,
---  overlay1: T,
---  overlay0: T,
---  surface2: T,
---  surface1: T,
---  surface0: T,
---  base: T,
---  mantle: T,
---  crust: T,
---  none: T }

