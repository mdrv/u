# Implementation Tasks

## Branch Setup

- [x] Create `v2` branch from `pipa` branch
- [x] Switch to `v2` branch as active development branch
- [x] Verify `v2` branch has all commits from `pipa`

## Directory Migration

- [ ] Create `configs/` directory at repository root
- [ ] Move `nushell/` to `configs/nushell/`
- [ ] Move `nvim/` to `configs/nvim/`
- [ ] Move `hypr/` to `configs/hypr/`
- [ ] Move `kitty/` to `configs/kitty/`
- [ ] Move `foot/` to `configs/foot/`
- [ ] Move `waybar/` to `configs/waybar/`
- [ ] Move `zellij/` to `configs/zellij/`
- [ ] Move `dunst/` to `configs/dunst/`
- [ ] Move `tofi/` to `configs/tofi/`
- [ ] Move `yazi/` to `configs/yazi/`
- [ ] Move `atuin/` to `configs/atuin/`
- [ ] Move `aichat/` to `configs/aichat/`
- [ ] Move `crush/` to `configs/crush/`
- [ ] Move `fastfetch/` to `configs/fastfetch/`
- [ ] Move `neovide/` to `configs/neovide/`
- [ ] Move `opencode/` to `configs/opencode/`
- [ ] Move `otd/` to `configs/otd/`
- [ ] Move `quickshell/` to `configs/quickshell/`
- [ ] Move `home/` to `configs/home/`
- [x] Verify all configs moved successfully (check `configs/` directory structure)
- [x] Verify no config directories remain at repository root

## Component Removal

- [x] Delete `web/` directory (SvelteKit application)
- [x] Delete `.github/workflows/` directory (GitHub Actions CI/CD)
- [x] Verify `web/` and `.github/workflows/` no longer exist in repository
- [x] Search for and remove any remaining references to `web/` in documentation
- [x] Search for and remove any remaining references to GitHub Actions in documentation

## Symlink Script Enhancement

### Core Data Structure

- [x] Define updated `DATA` constant with all configs in `configs/` namespace
- [x] Add `device_type` field mapping for device profiles (vps, arch-x64, arch-arm, termux)
- [x] Add device compatibility filters to each config entry in `DATA`
- [x] Update source paths in `DATA` to reference `configs/<app>/` instead of root-level paths

### Device Profile Support

- [x] Implement function to read `~/.u.json` for device type detection
- [x] Implement fallback to "arch-x64" profile when no device type is set
- [x] Add warning message when using default profile
- [x] Implement device profile filtering logic (vps, arch-x64, arch-arm, termux)

### Multi-Select Menu

- [x] Implement interactive menu using `input list` command
- [x] Display all available configurations with status indicators (symlinked, not symlinked, needs update)
- [x] Implement keyboard navigation (arrows, space to select, enter to confirm)
- [x] Filter menu items based on active device profile
- [x] Show device profile being used in menu header

### Symlink Validation

- [ ] Implement target directory existence check before symlinking
- [ ] Implement directory type validation (ensure target is a directory, not a file)
- [ ] Implement auto-creation of missing target directories
- [ ] Implement existing symlink detection and conflict warning
- [ ] Add confirmation prompt for replacing existing symlinks pointing to wrong location

### Parallel Processing

- [ ] Implement parallel symlink creation using `par-each` for multiple selections
- [ ] Ensure errors in one config don't stop others from processing
- [ ] Collect and display all errors at end of batch operation

### Pure Nushell Implementation

- [ ] Review all code for bash commands and replace with Nushell equivalents
- [ ] Prefix all external commands with `^` (e.g., `^ln -sf`)
- [ ] Implement error handling using `complete` and exit code checking
- [ ] Ensure no third-party tools are required
- [ ] Add comments explaining Nushell-specific patterns

### Post-Setup Messages

- [ ] Implement post-setup message display for zellij (zjstatus download)
- [ ] Implement post-setup message display for nvim (LV plugin enablement)
- [ ] Implement post-setup message display for opencode (skills symlink)
- [ ] Display post-setup messages after each config is symlinked

### Backward Compatibility

- [ ] Ensure `nu symlinks.nu <app_name>` still works (single-app mode)
- [ ] Test single-app symlinking without device filtering
- [ ] Verify behavior matches original script for single-app invocations

## Path Updates

- [ ] Search for hardcoded paths to root-level config directories in scripts
- [ ] Search for hardcoded paths to root-level config directories in documentation
- [ ] Search for hardcoded paths to root-level config directories in config files
- [x] Update all found references to use `configs/` paths (none found)
- [ ] Update README.md to reference new `configs/` directory structure
- [ ] Update AGENTS.md to reference new `configs/` directory structure

## Documentation Updates

- [ ] Add branch guidance to README.md (pipa vs v2 branch purpose)
- [ ] Add migration notes to README.md (how to switch branches, what's new in v2)
- [ ] Document device profiles in README.md or separate config guide
- [ ] Update symlinks.nu help messages for new features
- [ ] Document ~/.u.nuon device_type field format and values

## Testing - arm64

- [ ] Test symlink script on arm64 device with arch-arm profile
- [ ] Verify all compatible configs symlink correctly for arch-arm
- [ ] Verify neovide excluded (if unavailable) for arch-arm profile
- [ ] Test nvim plugin loading on arm64
- [ ] Test LSP servers on arm64
- [ ] Run Nushell scripts and verify no errors on arm64

## Testing - x64

- [ ] Test symlink script on x64 device with arch-x64 profile
- [ ] Verify all configs symlink correctly for arch-x64
- [ ] Test desktop environment configs (hypr, waybar, tofi, dunst, foot, kitty)
- [ ] Test nvim plugin loading on x64
- [ ] Test LSP servers on x64
- [ ] Run Nushell scripts and verify no errors on x64
- [ ] Verify parallel symlink creation works correctly on x64

## Testing - VPS Profile

- [ ] Test vps profile on actual VPS or simulated environment
- [ ] Verify only server-compatible configs are displayed in menu
- [ ] Verify desktop configs are excluded (hypr, waybar, tofi, dunst, foot, kitty, otd, quickshell, neovide, otd)
- [ ] Verify essential configs are symlinked (nushell, nvim minimal, atuin, aichat, crush, fastfetch, home)

## Testing - Termux Profile

- [ ] Test termux profile on Termux/Android environment
- [ ] Verify only nushell and nvim are displayed in menu
- [ ] Verify Linux-specific configs are excluded
- [ ] Verify Termux-specific paths work correctly
- [ ] Test Nushell functionality in Termux environment

## Validation & Cleanup

- [ ] Verify no broken symlinks exist in config directories
- [ ] Run `symlinks.nu` in all modes (no args, single app, multi-select)
- [ ] Verify all post-setup messages display correctly
- [ ] Check for any remaining references to old structure
- [ ] Verify `.gitignore` still works with new structure
- [ ] Commit all changes to `v2` branch

## Final Verification

- [ ] Switch to `pipa` branch and verify it still works
- [ ] Switch back to `v2` branch
- [ ] Verify `v2` and `pipa` branches have distinct commit histories
- [ ] Create summary of migration changes for future reference
- [ ] Mark all tasks as complete in this file
