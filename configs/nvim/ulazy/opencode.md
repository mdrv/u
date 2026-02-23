# OpenCode Configuration

Plugin: `sudo-tee/opencode.nvim`

## Overview

OpenCode AI assistant integration for Neovim. Provides editor-aware research, reviews, and code requests with a chat panel interface.

## Current Service Issues (Feb 2026)

**OpenCode service is experiencing authentication outages:**

- Error: `Response decode error: Unauthorized`
- Error: `Vim:E474: Unidentified byte: Unauthorized`
- **Root cause:** OpenCode Zen / OpenRouter provider issues (upstream)
- **Status:** Monitor [opencode.nvim issues](https://github.com/sudo-tee/opencode.nvim/issues)
- **Workaround:** Use opencode CLI or wait for service restoration

**This is NOT a configuration issue** - your setup is correct.

## Setup

- Auto-connects to opencode in current directory
- Shares buffer context, cursor position, selection, diagnostics
- Provides chat panel for persistent AI conversations
- Supports operator-mode for range-based requests
- **Keymap prefix:** `<leader>z` (custom, default is `<leader>o`)
- **Default global keymaps:** Enabled
- **Quick chat:** `<leader>z/` (experimental, see below)

## Keymaps (Prefix: `z`)

**Note:** These are keymaps with `<leader>z` prefix applied. Default uses `<leader>o`.

| Keymap        | Action                  | Description                                  |
| ------------- | ----------------------- | -------------------------------------------- |
| `<leader>zg`  | Toggle UI               | Open opencode. Close if opened               |
| `<leader>zq`  | Close UI                | Close opencode UI windows                    |
| `<leader>zi`  | Open input              | Open and focus input window                  |
| `<leader>zI`  | New session input       | Open input with new session                  |
| `<leader>zo`  | Open output             | Open and focus output window                 |
| `<leader>zt`  | Toggle focus            | Toggle between opencode and last window      |
| `<leader>zT`  | Timeline                | Display timeline picker (navigate/undo/fork) |
| `<leader>zs`  | Select session          | Open session picker                          |
| `<leader>zR`  | Rename session          | Rename current session                       |
| `<leader>zp`  | Configure provider      | Quick provider/model switch                  |
| `<leader>zV`  | Configure variant       | Switch model variant for current model       |
| `<leader>zy`  | Add visual selection    | Send visual selection to opencode            |
| `<leader>zz`  | Toggle zoom             | Zoom in/out opencode windows                 |
| `<leader>zv`  | Paste image             | Paste clipboard image as attachment          |
| `<leader>zd`  | Diff open               | Open diff tab since last prompt              |
| `<leader>z]`  | Diff next               | Navigate to next diff file                   |
| `<leader>z[`  | Diff prev               | Navigate to previous diff file               |
| `<leader>zc`  | Diff close              | Close diff view                              |
| `<leader>zra` | Revert all last prompt  | Revert all changes from last prompt          |
| `<leader>zrt` | Revert this last prompt | Revert current file from last prompt         |
| `<leader>zrA` | Revert all session      | Revert all changes since session start       |
| `<leader>zrT` | Revert this session     | Revert current file since session start      |
| `<leader>zrr` | Restore file snapshot   | Restore file to restore point                |
| `<leader>zrR` | Restore all snapshots   | Restore all files to restore point           |
| `<leader>zx`  | Swap position           | Swap opencode pane left/right                |
| `<leader>ztt` | Toggle tools output     | Show/hide diffs, cmd output, etc.            |
| `<leader>ztr` | Toggle reasoning output | Show/hide thinking steps                     |
| `<leader>z/`  | Quick chat              | Quick buffer chat (experimental)             |

### Scroll Keymaps (Custom)

These are manually set in your config:

| Keymap       | Action         | Description                      |
| ------------ | -------------- | -------------------------------- |
| `<leader>zu` | Half page up   | Scroll up in opencode messages   |
| `<leader>zd` | Half page down | Scroll down in opencode messages |

## Usage Patterns

### Quick Chat (Experimental)

```
Visual select code > <leader>z/
Normal mode > <leader>z/
```

Open quick chat with visual selection or current line context. AI responds with quick edits applied automatically.

### Toggle UI

```
<leader>zg
```

Open or close opencode UI.

### Open Input Window

```
<leader>zi
```

Open and focus input window.

### Check Session History

```
<leader>zs
```

Open session picker to load or switch between sessions.

### View Diffs

```
<leader>zd
```

Open diff view showing changes since last opencode prompt.

## Context Placeholders

| Placeholder    | Description                                             |
| -------------- | ------------------------------------------------------- |
| `@this`        | Operator range or visual selection (or cursor position) |
| `@buffer`      | Current buffer                                          |
| `@diagnostics` | Current buffer diagnostics                              |

## Window-Specific Keymaps

### Input Window

| Keymap   | Action         | Description                        |
| -------- | -------------- | ---------------------------------- |
| `<S-cr>` | Submit prompt  | Submit prompt (normal/insert mode) |
| `<esc>`  | Close UI       | Close opencode windows             |
| `<C-c>`  | Cancel request | Cancel running opencode request    |
| `~`      | Mention file   | Pick file to add to context        |
| `@`      | Insert mention | Insert file/agent mention          |
| `/`      | Slash commands | Pick command to run                |
| `#`      | Context items  | Manage context items               |
| `<M-v>`  | Paste image    | Paste image from clipboard         |
| `<C-i>`  | Focus input    | Focus input window from output     |
| `<tab>`  | Toggle pane    | Toggle between input/output panes  |
| `<up>`   | Prev history   | Navigate to previous prompt        |
| `<down>` | Next history   | Navigate to next prompt            |
| `<M-m>`  | Switch mode    | Switch between build/plan modes    |
| `<M-r>`  | Cycle variant  | Cycle through model variants       |

### Output Window

| Keymap  | Action         | Description                       |
| ------- | -------------- | --------------------------------- |
| `<esc>` | Close UI       | Close opencode windows            |
| `<C-c>` | Cancel request | Cancel running opencode request   |
| `]]`    | Next message   | Navigate to next message          |
| `[[`    | Prev message   | Navigate to previous message      |
| `<tab>` | Toggle pane    | Toggle between input/output panes |
| `i`     | Focus input    | Focus input window from output    |
| `<M-r>` | Cycle variant  | Cycle through model variants      |

### Session Picker

| Keymap  | Action         | Description             |
| ------- | -------------- | ----------------------- |
| `<C-r>` | Rename session | Rename selected session |
| `<C-d>` | Delete session | Delete selected session |
| `<C-s>` | New session    | Create new session      |

## Configuration

Plugin uses new keymap structure. Configured with:

```lua
default_global_keymaps = true, -- Enables all default global keymaps
keymap_prefix = '<leader>z', -- Prefix for all OpenCode keymaps (default: '<leader>o')
default_mode = 'plan', -- Default mode: 'build' or 'plan'
```

### UI Settings

- `position = 'right'` - Terminal opens on right side
- `input_position = 'bottom'` - Input window at bottom (default) or top
- `window_width = 0.40` - UI width as percentage of editor width
- `auto_close = true` - Terminal closes on exit
- `display_model = true` - Show model name in winbar
- `display_context_size = true` - Show context size in footer
- `display_cost = true` - Show cost in footer

### Keymap Note

Your configuration uses `keymap_prefix = '<leader>z'` instead of default `<leader>o`. This applies the prefix to all editor keymaps. Some custom scroll keymaps are manually defined outside the new structure.
