# AGENTS.md

μ - Personal dotfiles repository for Arch Linux configurations.

## Tech Stack

- **Nushell** 0.105.0+ - Shell and scripting
- **Neovim** - Editor with lazy.nvim
- **Hyprland** 0.53.3 - Wayland compositor
- **dprint** - Formatter (tabs, no-semicolons, single quotes)

## Commands

```bash
# Symlink configs
nu symlinks.nu <app_name>

# Format
dprint fmt
```

## Structure

```
configs/          # All tool configs
├── nvim/         # Neovim: uinit.lua, ulazy/, ulsp/
├── nushell/      # Nushell: uinit.nu, uconfig.nu, uenv.nu, u/
├── hypr/         # Hyprland: hyprland.conf, toggle-monitor.nu
├── waybar/       # Waybar
├── kitty/        # Terminal
├── zellij/       # Terminal multiplexer
├── etc/          # System configs (requires sudo)
├── keyd/         # Keyboard remapper
└── symlinks.nu  # Symlink manager
```

## Patterns

### Device-Specific Configs

**Neovim:** Create `.u.lua` in nvim config dir:

```lua
return { LV = 1 }  -- Enable plugins
```

**Dotfiles:** Add `.u` or `.u.*` files for device-specific tweaks.

### Nushell Architecture

Extend defaults by appending:

- `env.nu`: `source configs/nushell/uenv.nu`
- `config.nu`: `source configs/nushell/uconfig.nu`

### Symlink Management

`symlinks.nu` manages config symlinks. Each tool in `DATA` constant specifies:

- `items`: Files/directories to symlink
- `target`: Target directory (defaults to `~/.config/<app_name>`)
- `message`: Post-link instructions (optional)
- `requires_root`: Require sudo for `/etc/` paths

### Code Style

- **Tabs**: Enabled (`useTabs: true`)
- **TypeScript**: Single quotes, no semicolons
- **Lua**: 4-space indent, single quotes

## Gotchas

### Hyprland Multi-Device

- Use `# hyprlang if $HOSTNAME == "device-name"` for device-specific blocks
- Monitor config: Use `toggle-monitor.nu` script to switch DSI-1/DP-1
- State stored in `~/.u.nuon` under `HYPR.FOLLOW_EXT_MONITOR`

### Symlinks

- Always use `nu symlinks.nu <app_name>` - don't manually symlink
- `/etc/` configs require `sudo nu symlinks.nu etc`

## Common Tasks

### Add New Tool Config

1. Create `configs/<tool-name>/` directory
2. Add config files
3. Update `symlinks.nu` DATA constant
4. Test: `nu symlinks.nu <tool-name>`

### Modify Neovim Config

1. Add plugin to `nvim/ulazy/<plugin-name>.lua`
2. Use lazy pattern: `return { 'user/repo', enabled = true, opts = { ... } }`
3. LSP in `nvim/ulsp/<lang>.lua` if needed
4. Device-specific: add to `.u.lua` in nvim config dir
