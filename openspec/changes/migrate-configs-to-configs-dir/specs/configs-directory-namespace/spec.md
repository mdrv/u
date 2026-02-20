# configs-directory-namespace Specification

## ADDED Requirements

### Requirement: All configurations reside in unified configs/ directory

All configuration files must be stored in a single `configs/` directory at the repository root. This serves as the single source of truth for all application configurations.

#### Scenario: Repository root contains only core project files
- **WHEN** a user views the repository root
- **THEN** they see only core project files: `openspec/`, `.opencode/`, `configs/`, and project metadata files (`.gitignore`, `README.md`, etc.)
- **AND** no configuration directories exist at root level (no `nushell/`, `nvim/`, `hypr/`, etc.)

### Requirement: Configuration subdirectories maintain existing structure

Each configuration maintains its internal structure when moved to `configs/` namespace.

#### Scenario: Nushell configuration is relocated
- **WHEN** `nushell/` is moved to `configs/nushell/`
- **THEN** all files (`uinit.nu`, `uenv.nu`, `uconfig.nu`, `u/`) exist in `configs/nushell/`
- **AND** the directory structure is preserved

#### Scenario: Neovim configuration is relocated
- **WHEN** `nvim/` is moved to `configs/nvim/`
- **THEN** all files (`uinit.lua`, `utils.lua`, `ulazy/`, `ulsp/`, `unavigate/`) exist in `configs/nvim/`
- **AND** the directory structure is preserved

### Requirement: Removed components are deleted

The `web/` SvelteKit application and GitHub Actions workflows are removed from the repository.

#### Scenario: Web application directory is removed
- **WHEN** migration is complete
- **THEN** `web/` directory does not exist in the repository
- **AND** `web/` is not referenced in any documentation or scripts

#### Scenario: GitHub workflows are removed
- **WHEN** migration is complete
- **THEN** `.github/workflows/` directory does not exist in the repository
- **AND** no CI/CD references remain in project files

### Requirement: Internal path references are updated

All scripts, documentation, and configuration files that reference the old root-level structure are updated to use the new `configs/` paths.

#### Scenario: Symlink script references configs/ directory
- **WHEN** the symlink script runs
- **THEN** it symlinks files from `configs/<app>/` to their target locations
- **AND** no references to root-level configuration directories remain

#### Scenario: Documentation references configs/ directory
- **WHEN** a user reads the documentation
- **THEN** all config references point to `configs/<app>/` paths
- **AND** no documentation references old root-level config paths
