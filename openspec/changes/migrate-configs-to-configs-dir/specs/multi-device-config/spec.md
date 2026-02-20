# multi-device-config Specification

## ADDED Requirements

### Requirement: Device-specific configuration profiles supported

The symlink script must support device-specific configuration profiles for different deployment targets.

#### Scenario: Device profile detected from ~/.u.nuon
- **WHEN** the symlink script runs
- **THEN** it reads `~/.u.nuon` to detect the current device type
- **AND** applies the appropriate device profile (VPS, Arch x64, Arch ARM, or Termux/Android)

### Requirement: VPS-specific profile configuration

The system supports VPS-specific configuration profile with minimal server-oriented settings.

#### Scenario: VPS profile is selected
- **WHEN** device type in `~/.u.nuon` is set to "vps"
- **THEN** only essential configs are symlinked (nushell, nvim minimal, no desktop environment configs)
- **AND** desktop-specific tools (hypr, waybar, tofi, dunst, foot, kitty, otd, quickshell) are excluded

### Requirement: Arch Linux x64 profile configuration

The system supports Arch Linux x64 desktop configuration profile with full desktop environment.

#### Scenario: Arch x64 profile is selected
- **WHEN** device type in `~/.u.nuon` is set to "arch-x64"
- **THEN** all configs are symlinked including full desktop environment
- **AND** desktop tools (hypr, waybar, tofi, dunst, foot, kitty, otd, quickshell) are included

### Requirement: Arch Linux ARM profile configuration

The system supports Arch Linux ARM profile for ARM-based devices (like Raspberry Pi, ARM VPS).

#### Scenario: Arch ARM profile is selected
- **WHEN** device type in `~/.u.nuon` is set to "arch-arm"
- **THEN** configs appropriate for ARM architecture are symlinked
- **AND** architecture-specific settings are applied (e.g., neovide may be excluded if unavailable)

### Requirement: Termux/Android profile configuration

The system supports Termux/Android profile for Android devices with Termux environment.

#### Scenario: Termux profile is selected
- **WHEN** device type in `~/.u.nuon` is set to "termux"
- **THEN** only Termux-compatible configs are symlinked (nushell, nvim)
- **AND** Linux-specific tools (hypr, waybar, dunst, foot, kitty, etc.) are excluded
- **AND** Termux-specific paths are used

### Requirement: Existing ~/.u.nuon mechanism is preserved

The existing device configuration mechanism in `nushell/uenv.nu:45-51` is preserved and leveraged by the symlink script.

#### Scenario: Device config is read from ~/.u.nuon
- **WHEN** `~/.u.nuon` exists
- **THEN** the file is read and converted to `~/.u.json`
- **AND** symlink script reads `~/.u.json` for device type detection
- **AND** ENV variables from `~/.u.json` are loaded into Nushell environment
