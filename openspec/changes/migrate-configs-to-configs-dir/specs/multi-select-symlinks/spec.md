# multi-select-symlinks Specification

## ADDED Requirements

### Requirement: Interactive multi-select menu for configurations

The symlink script provides an interactive menu allowing users to select multiple configurations to symlink at once.

#### Scenario: User invokes symlink script without arguments
- **WHEN** user runs `nu symlinks.nu` without specifying an app name
- **THEN** a multi-select menu is displayed listing all available configurations
- **AND** user can select multiple items using keyboard navigation
- **AND** selected items are symlinked after confirmation

#### Scenario: User invokes symlink script with specific app
- **WHEN** user runs `nu symlinks.nu <app_name>`
- **THEN** the script symlinks only that specific configuration
- **AND** no interactive menu is displayed

### Requirement: Configuration list displays all available configs

The multi-select menu displays all configuration directories available in `configs/`.

#### Scenario: Menu shows all configurations
- **WHEN** the multi-select menu is displayed
- **THEN** all configs from `configs/` are listed (nushell, nvim, hypr, kitty, foot, waybar, zellij, dunst, tofi, yazi, atuin, aichat, crush, fastfetch, neovide, opencode, otd, quickshell, home)
- **AND** each item shows its status (already symlinked, not symlinked, or needs update)

#### Scenario: Menu filters configs by device profile
- **WHEN** a device profile is active (e.g., VPS)
- **THEN** only configs compatible with that device are displayed
- **AND** incompatible configs are hidden or marked as unavailable

### Requirement: Symlink validation and conflict detection

The script validates symlinks before creation and detects conflicts with existing files.

#### Scenario: Symlink target directory exists and is a directory
- **WHEN** symlink target directory exists and is a valid directory
- **THEN** the symlink is created successfully
- **AND** success message is displayed

#### Scenario: Symlink target does not exist
- **WHEN** symlink target directory does not exist
- **THEN** the directory is created before symlinking
- **AND** symlink is created successfully

#### Scenario: Symlink target exists and is not a directory
- **WHEN** symlink target path exists but is a file (not a directory)
- **THEN** an error is displayed indicating the target is not a directory
- **AND** the symlink is not created

#### Scenario: Existing symlink points to wrong location
- **WHEN** an existing symlink points to a different location
- **THEN** a warning is displayed showing the current target
- **AND** user is prompted to confirm symlink replacement

### Requirement: Post-symlink instructions displayed

After symlinking, the script displays any application-specific instructions for setup.

#### Scenario: Post-setup message displayed for zellij
- **WHEN** zellij is symlinked
- **THEN** a message is displayed: "Execute this: http get https://github.com/dj95/zjstatus/releases/latest/download/zjstatus.wasm | save -f ($nu.home-dir)/.config/zellij/zjstatus.wasm"

#### Scenario: Post-setup message displayed for nvim
- **WHEN** nvim is symlinked
- **THEN** a message is displayed: "Enable plugins by adding `.u.lua`: `return {LV = 1}`"

#### Scenario: Post-setup message displayed for opencode
- **WHEN** opencode is symlinked
- **THEN** a message is displayed: "Don't forget to symlink /g/ai/skills to ($nu.home-dir)/.agents/skills"

### Requirement: Pure Nushell implementation

The symlink script is implemented entirely in Nushell with no bash commands or external third-party tools.

#### Scenario: Script uses only Nushell built-ins
- **WHEN** the symlink script is analyzed
- **THEN** no bash commands (e.g., `ls`, `rm`, `ln`) are used without `^` prefix
- **THEN** all file operations use Nushell built-in commands (`path expand`, `path join`, `ln -sf` for external commands)
- **AND** no third-party tools are required (only Nushell standard library)

#### Scenario: External commands are properly prefixed
- **WHEN** the script needs to run external commands (e.g., `ln`)
- **THEN** the command is prefixed with `^` (e.g., `^ln -sf source target`)
- **AND** error handling uses `complete` and exit code checking
