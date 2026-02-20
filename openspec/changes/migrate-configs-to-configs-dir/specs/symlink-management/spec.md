# symlink-management Specification

## MODIFIED Requirements

### Requirement: Symlink script reads configuration from DATA constant

The script defines a `DATA` constant containing configuration information for all apps, including items, target directories, and post-setup messages.

#### Scenario: DATA constant contains all app configurations
- **WHEN** the script initializes
- **THEN** `DATA` constant is defined with entries for: nushell, nvim, hypr, kitty, foot, waybar, zellij, dunst, tofi, yazi, atuin, aichat, crush, fastfetch, neovide, opencode, otd, quickshell, home
- **AND** each app entry contains `items` (files/directories to symlink) and optional `target` (custom target directory) and `message` (post-setup instructions)

### Requirement: Multi-select capability added to existing symlink flow

The script now supports both single-app symlinking (existing behavior) and multi-select interactive menu (new behavior).

#### Scenario: Single-app symlinking maintains backward compatibility
- **WHEN** user runs `nu symlinks.nu <app_name>` (existing behavior)
- **THEN** only that specific configuration is symlinked
- **AND** the behavior is identical to the original script
- **AND** no interactive menu is displayed

#### Scenario: Multi-select menu invoked without arguments
- **WHEN** user runs `nu symlinks.nu` without arguments
- **THEN** an interactive multi-select menu is displayed
- **AND** user can select multiple configurations
- **AND** all selected configurations are symlinked after confirmation

### Requirement: Device profile filtering applied to available configs

The script filters available configurations based on the active device profile from `~/.u.json`.

#### Scenario: VPS profile filters out desktop configs
- **WHEN** device profile is "vps"
- **THEN** desktop-specific configs (hypr, waybar, tofi, dunst, foot, kitty, otd, quickshell) are filtered out
- **AND** only server-compatible configs are displayed in the menu

#### Scenario: Termux profile filters out Linux-specific configs
- **WHEN** device profile is "termux"
- **THEN** Linux-specific configs are filtered out
- **AND** only Termux-compatible configs (nushell, nvim) are displayed

### Requirement: Parallel symlink creation for multiple selections

When multiple configurations are selected, they are symlinked in parallel using `par-each`.

#### Scenario: Multiple configs selected and symlinked
- **WHEN** user selects multiple configurations in the menu
- **THEN** all selected configs are symlinked in parallel using `par-each`
- **AND** symlink creation is faster than sequential processing
- **AND** errors in one config do not stop others from being processed

### Requirement: Source paths updated to configs/ namespace

All source paths in the `DATA` constant reference the new `configs/` directory structure.

#### Scenario: Source path references configs/ directory
- **WHEN** the script builds source paths
- **THEN** all source paths start with `configs/<app_name>/`
- **AND** the PWD variable points to repository root containing `configs/`
- **AND** no source paths reference root-level config directories
