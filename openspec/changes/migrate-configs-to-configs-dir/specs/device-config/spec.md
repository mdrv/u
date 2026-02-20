# device-config Specification

## MODIFIED Requirements

### Requirement: Device configuration read from ~/.u.nuon

The device configuration is stored in `~/.u.nuon` and read by Nushell on startup.

#### Scenario: ~/.u.nuon exists
- **WHEN** Nushell starts and `~/.u.nuon` exists
- **THEN** the file is read into a temporary variable
- **AND** the content is compared with `~/.u.json`
- **AND** if `~/.u.json` doesn't exist or content differs, the temporary variable is saved to `~/.u.json`

#### Scenario: ~/.u.nuon does not exist
- **WHEN** Nushell starts and `~/.u.nuon` does not exist
- **THEN** no error is raised
- **AND** Nushell continues normally without device-specific configuration

### Requirement: Device configuration loaded into Nushell environment

Environment variables defined in `~/.u.json` are loaded into the Nushell environment.

#### Scenario: ENV variables loaded from ~/.u.json
- **WHEN** `~/.u.json` exists and contains an `ENV` field
- **THEN** all key-value pairs in `ENV` are loaded into the Nushell environment
- **AND** these variables are available for use in Nushell scripts

#### Scenario: No ENV field in ~/.u.json
- **WHEN** `~/.u.json` exists but doesn't contain an `ENV` field
- **THEN** an empty dictionary is used as default
- **AND** no environment variables are loaded

### Requirement: Symlink script leverages ~/.u.json for device detection

The enhanced symlink script reads `~/.u.json` to detect the current device type and applies appropriate configuration profile.

#### Scenario: Device type read from ~/.u.json
- **WHEN** the symlink script starts
- **THEN** it reads `~/.u.json` to determine the device type
- **AND** the device type is used to filter available configurations

#### Scenario: Device type not set in ~/.u.json
- **WHEN** `~/.u.json` exists but doesn't specify a device type
- **THEN** the script defaults to a standard profile (e.g., "arch-x64")
- **AND** a warning is displayed indicating default profile is being used

#### Scenario: ~/.u.json does not exist
- **WHEN** the symlink script starts and `~/.u.json` does not exist
- **THEN** the script prompts user to create a device configuration
- **OR** the script uses default profile without device filtering

### Requirement: ~/.u.nuon format supports device type specification

The `~/.u.nuon` file format includes a device type field for profile selection.

#### Scenario: ~/.u.nuon specifies device type
- **WHEN** `~/.u.nuon` is created or edited
- **THEN** a `device_type` field can be specified with values: "vps", "arch-x64", "arch-arm", "termux"
- **AND** the `device_type` value is written to `~/.u.json` on next Nushell startup

#### Scenario: ~/.u.nuon includes custom ENV variables
- **WHEN** `~/.u.nuon` is created or edited
- **THEN** custom environment variables can be added in an `ENV` field
- **AND** these variables are loaded into Nushell environment on startup
