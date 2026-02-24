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

## Patterns

### Device-Specific Configs

**Dotfiles:** Add `~/.u.nuon` for device-specific tweaks.

### Nushell Architecture

Extend defaults by appending:

- `env.nu`: `source configs/nushell/uenv.nu`
- `config.nu`: `source configs/nushell/uconfig.nu`
