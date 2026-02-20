# dual-architecture-support Specification

## ADDED Requirements

### Requirement: v2 branch created from pipa branch

A new `v2` branch is created for the migration, forking from the `pipa` branch.

#### Scenario: v2 branch is created
- **WHEN** the migration process starts
- **THEN** a new branch named `v2` is created from `pipa` branch
- **AND** all commits from `pipa` are present in `v2`
- **AND** `v2` becomes the active development branch for the migration

### Requirement: Configuration tested on both arm64 and x64

All configuration files and scripts are tested and verified to work on both arm64 and x64 architectures.

#### Scenario: Nushell scripts run on arm64
- **WHEN** the enhanced symlink script is run on an arm64 device
- **THEN** all Nushell features used in the script work correctly
- **AND** no architecture-specific errors occur

#### Scenario: Nushell scripts run on x64
- **WHEN** the enhanced symlink script is run on an x64 device
- **THEN** all Nushell features used in the script work correctly
- **AND** no architecture-specific errors occur

#### Scenario: Neovim plugins load on arm64
- **WHEN** Neovim is started on an arm64 device
- **THEN** all specified plugins load correctly
- **AND** LSP servers start successfully

#### Scenario: Neovim plugins load on x64
- **WHEN** Neovim is started on an x64 device
- **THEN** all specified plugins load correctly
- **AND** LSP servers start successfully

### Requirement: Architecture-specific configs are profile-based

Architecture differences are handled through device profiles rather than architecture-specific config files.

#### Scenario: ARM device uses appropriate profile
- **WHEN** an ARM device runs the symlink script
- **THEN** the `arch-arm` or `termux` profile is applied (if configured in `~/.u.nuon`)
- **AND** only compatible configurations are symlinked

#### Scenario: x64 device uses appropriate profile
- **WHEN** an x64 device runs the symlink script
- **THEN** the `arch-x64` or `vps` profile is applied (if configured in `~/.u.nuon`)
- **AND** only compatible configurations are symlinked

### Requirement: pipa branch remains as stable arm64 reference

The `pipa` branch is preserved as a stable arm64 reference while `v2` branch becomes the new development branch.

#### Scenario: pipa branch is preserved
- **WHEN** migration is complete on `v2` branch
- **THEN** `pipa` branch still exists
- **AND** `pipa` can be used for arm64-only deployments
- **AND** `v2` is the primary branch for development

#### Scenario: Users can switch between branches
- **WHEN** a user wants to use arm64-stable configs
- **THEN** they can checkout `pipa` branch
- **WHEN** a user wants to use the latest migration with dual-architecture support
- **THEN** they can checkout `v2` branch
