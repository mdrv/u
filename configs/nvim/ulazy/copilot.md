# Copilot Configuration

Plugins: `zbirenbaum/copilot.lua` + `copilotlsp-nvim/copilot-lsp`

## Overview

GitHub Copilot inline suggestions and NES (Next Edit Suggestion) for Neovim.

## Setup

- Inline suggestions: Enabled (toggle via menu)
- NES (multi-line edits): Enabled
- Auto-trigger: **Disabled** (manual control via `<Leader>zc`)
- FZF menu: Uses `fzf-lua` for quick actions

## Keymaps (Prefix: `z`)

| Keymap       | Action    | Description                   |
| ------------ | --------- | ----------------------------- |
| `<Leader>zc` | Open menu | FZF menu with Copilot actions |

### Insert Mode (Suggestions)

| Keymap   | Action                              |
| -------- | ----------------------------------- |
| `Ctrl+j` | Accept suggestion                   |
| `Ctrl+h` | Dismiss suggestion                  |
| `Ctrl+m` | Accept NES edit                     |
| `Ctrl+n` | Dismiss NES                         |

## Menu Actions (Via `<Leader>zc`)

Open menu with `<Leader>zc`, then:

1. Use arrow keys or type to filter actions
2. Press **Enter** to execute selected action

Available actions:

| Action             | Description                       |
| ------------------ | --------------------------------- |
| Toggle suggestions | Enable/disable inline suggestions |
| Open panel         | Open Copilot suggestion panel     |
| Close panel        | Close suggestion panel            |
| Status             | Show authentication status        |
| Authenticate       | Start GitHub OAuth flow           |
| Version            | Show plugin version               |
| Clear history      | Clear suggestion history          |
## Menu Features

### Status Display

- Header shows current suggestions state (ON/OFF)
- Visual indicators: `●` for enabled, `○` for disabled
- Auth status displayed in help text

### Preview Window

- Preview window is disabled for cleaner UI
- Focus on quick action selection

## Configuration Notes

- **Auto-trigger disabled**: Suggestions won't appear automatically; toggle via menu
- **NES enabled**: Accepts multi-line edits with keymap (jump to next edit)
- **Auth required**: First time use requires `<Leader>zc > Authenticate > Enter`
- **FZF menu**: Uses `fzf-lua` for quick actions

### Default Copilot Keymaps

For reference, these are the default keymaps when `keymap` is not configured in setup:

- `accept`: `<M-l>` (Alt+l)
- `next`: `<M-]>` (Alt+])
- `prev`: `<M-[>` (Alt+[)
- `dismiss`: `<C-]>` (Ctrl+])
- `toggle_auto_trigger`: `false` (disabled by default)

## Troubleshooting

### "Not logged in" messages

- Open menu: `<Leader>zc`
- Select "Authenticate", press Enter
- Complete GitHub OAuth flow in browser

### Suggestions not appearing

- Check if suggestions enabled: `<Leader>zc > Toggle Suggestions > Enter`
- Verify auth status: `<Leader>zc > Status > Enter`
- Ensure in insert mode (suggestions only appear while typing)

### NES not working

- Verify NES enabled in config (`ulazy/copilot.lua`)
- Check keymap is not remapped by other plugins
- NES and suggestions use same toggle - ensure both are enabled

## Integration

- Copilot LSP provides inline diagnostics and code actions
- Uses blink.cmp for completions (optional dependency)
