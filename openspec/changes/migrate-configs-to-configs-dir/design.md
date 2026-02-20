# Design: Migrate Configs to configs/ Directory

## Context

The repository currently has configuration files scattered at the root level (nushell, nvim, hypr, kitty, foot, waybar, zellij, etc.), making the directory cluttered and harder to navigate. The `pipa` branch has only been tested on arm64 architecture, leaving x64 support unverified.

The user previously considered chezmoi for configuration management but rejected it due to unnecessary overhead. The preference is for a simpler, Nushell-first approach that:

1. Consolidates all configs into a unified `configs/` directory
2. Removes unused components (web/, GitHub Actions)
3. Supports multi-architecture (arm64 and x64) via a new `v2` branch
4. Implements an enhanced symlink script with multi-select and device-specific profiles
5. Uses pure Nushell (no bash, no third-party tools)

The existing device-specific configuration mechanism (`~/.u.nuon` → `~/.u.json`) in `nushell/uenv.nu:45-51` must be preserved and leveraged.

## Goals / Non-Goals

**Goals:**

1. Clean up repository root by moving all configuration directories to `configs/`
2. Delete deprecated components: `web/` SvelteKit app and `.github/workflows/`
3. Create `v2` branch from `pipa` for dual-architecture support (arm64 + x64)
4. Implement enhanced `symlinks.nu` with:
   - Multi-select interactive menu for batch configuration installation
   - Device-specific profile filtering (VPS, Arch x64, Arch ARM, Termux)
   - Validation and conflict detection for symlinks
   - Parallel symlink creation for efficiency
5. Update all internal path references to use new `configs/` structure
6. Preserve and leverage existing `~/.u.nuon` → `~/.u.json` mechanism

**Non-Goals:**

1. Do NOT reorganize internal structure of individual config directories (only move them)
2. Do NOT create a web-based config viewer or online documentation in this change
3. Do NOT migrate to chezmoi or other configuration management tools
4. Do NOT add CI/CD or automated testing pipelines
5. Do NOT change the behavior of individual applications (only their location)
6. Do NOT implement device profiles within individual config files (handle at symlink layer)

## Decisions

### 1. Repository Structure: Unified configs/ Directory

**Decision:** Create a `configs/` directory at repository root and move all configuration directories into it.

**Rationale:**
- Provides a clear namespace for all configurations
- Keeps repository root clean with only core project files (openspec/, .opencode/, configs/, metadata)
- Easier to understand the project structure at a glance
- Simplifies backup and sync operations

**Alternatives considered:**
- **Alternative 1:** Use chezmoi or stow for config management
  - **Rejected because:** Adds unnecessary complexity and overhead. User explicitly rejected chezmoi.
- **Alternative 2:** Keep configs at root but organize with symlinks
  - **Rejected because:** Doesn't solve root clutter problem, adds indirection.
- **Alternative 3:** Create separate repo per application
  - **Rejected because:** Loss of unified dotfiles repository concept, harder to maintain.

### 2. Branch Strategy: v2 from pipa

**Decision:** Create new `v2` branch forking from `pipa` branch, preserving `pipa` as stable arm64 reference.

**Rationale:**
- `pipa` has arm64-tested configs that work; keep as stable reference
- `v2` enables experimentation with dual-architecture support without breaking arm64 users
- Allows rollback to `pipa` if issues arise during migration
- Clear separation between stable arm64 and multi-arch development

**Alternatives considered:**
- **Alternative 1:** Migrate directly on `pipa` branch
  - **Rejected because:** Risk of breaking existing arm64 deployments; harder to isolate migration-specific changes.
- **Alternative 2:** Merge `pipa` into `main` and branch from there
  - **Rejected because:** `main` may not be up to date with `pipa`; creates merge complexity.
- **Alternative 3:** Delete `pipa` after migration
  - **Rejected because:** Lose arm64-stable reference; pipa branch provides rollback option.

### 3. Symlink Script: Enhanced with Multi-Select and Device Profiles

**Decision:** Rewrite `symlinks.nu` to support:
- Multi-select interactive menu (using Nushell's `input list` or similar)
- Device profile filtering based on `~/.u.json` device_type
- Parallel symlink creation with `par-each`
- Validation and conflict detection before symlinking
- Pure Nushell implementation (no bash, no external dependencies)

**Rationale:**
- Multi-select reduces repetitive single-app symlink operations
- Device profiles prevent installing incompatible configs (e.g., desktop apps on VPS)
- Parallel processing speeds up batch installations
- Validation prevents broken symlinks and data loss
- Pure Nushell aligns with project's shell philosophy

**Alternatives considered:**
- **Alternative 1:** Use `fzf` or `peco` for multi-select
  - **Rejected because:** Adds external tool dependency; Nushell built-in capabilities sufficient.
- **Alternative 2:** Separate scripts per device type (e.g., `symlinks-vps.nu`)
  - **Rejected because:** Code duplication; harder to maintain; single script with profiles cleaner.
- **Alternative 3:** Keep bash implementation with multi-select
  - **Rejected because:** User explicitly requires pure Nushell; bash violates project principles.
- **Alternative 4:** Auto-detect device without profiles
  - **Rejected because:** Less predictable; user may want explicit control over what's installed.

### 4. Device Configuration: Leverage Existing ~/.u.nuon Mechanism

**Decision:** Preserve existing `~/.u.nuon` → `~/.u.json` mechanism and extend it with `device_type` field for profile selection.

**Rationale:**
- Already implemented in `nushell/uenv.nu:45-51`; working and tested
- NUON format is human-readable and editable
- JSON is efficient for symlink script to parse
- Single source of truth for device-specific settings
- Enables non-Nushell apps to read `~/.u.json` for configuration

**Alternatives considered:**
- **Alternative 1:** Create separate device config file (e.g., `~/.device.nuon`)
  - **Rejected because:** Redundant; `~/.u.nuon` already serves this purpose.
- **Alternative 2:** Detect device automatically from system (e.g., `uname -m`)
  - **Rejected because:** Less flexible; can't distinguish between Arch x64 and VPS running on same arch.
- **Alternative 3:** Store device type in repository (e.g., `.device-type` file)
  - **Rejected because:** Device-specific setting should live in home directory, not repository.

### 5. Multi-Select UI Implementation: Nushell input list

**Decision:** Use Nushell's built-in `input list` command for multi-select menu.

**Rationale:**
- No external dependencies required
- Native Nushell UX consistent with shell
- Supports keyboard navigation (arrows, space to select, enter to confirm)
- Handles large lists efficiently

**Alternatives considered:**
- **Alternative 1:** Implement custom TUI with `term` commands
  - **Rejected because:** Overkill; `input list` provides sufficient functionality.
- **Alternative 2:** Use command-line flags (e.g., `--select nushell,nvim,hypr`)
  - **Rejected because:** Less discoverable; interactive menu more user-friendly.

### 6. Parallel Symlink Creation: par-each

**Decision:** Use Nushell's `par-each` command for parallel symlink creation when multiple configs are selected.

**Rationale:**
- Faster than sequential processing
- Built-in Nushell concurrency (no external tools)
- Errors in one config don't block others
- Natural fit for batch operations

**Alternatives considered:**
- **Alternative 1:** Sequential processing (existing approach)
  - **Rejected because:** Slower; no user benefit from selecting multiple configs.
- **Alternative 2:** Use `xargs -P` or GNU parallel
  - **Rejected because:** Requires bash/external tools; violates pure Nushell requirement.

### 7. Device Profile Definitions: Filter by Compatibility

**Decision:** Define device profiles based on compatibility:

- **vps:** nushell, nvim (minimal), atuin, aichat, crush, fastfetch, home
  - Excludes: Desktop environment (hypr, waybar, tofi, dunst, foot, kitty, otd, quickshell), GUI tools (neovide), drawing tablet (otd)
- **arch-x64:** All configs (full desktop environment)
- **arch-arm:** All configs except neovide (if unavailable on ARM)
- **termux:** nushell, nvim only
  - Excludes: All Linux-specific tools (hypr, waybar, dunst, foot, kitty, etc.)

**Rationale:**
- Clear separation based on use cases (server vs desktop vs mobile)
- Prevents configuration errors from incompatible software
- Reduces clutter on devices that don't need certain configs

**Alternatives considered:**
- **Alternative 1:** Single profile with conditional excludes in each app's config
  - **Rejected because:** Complexity shifts to individual configs; harder to maintain.
- **Alternative 2:** Use architecture detection only (arm64 vs x64)
  - **Rejected because:** Can't distinguish between VPS and desktop on same architecture.
- **Alternative 3:** User selects which configs manually every time
  - **Rejected because:** Defeats purpose of device profiles; repetitive and error-prone.

### 8. Symlink Validation: Pre-flight Checks

**Decision:** Implement validation before symlink creation:
1. Check if target directory exists and is a directory
2. Check if existing symlink points to correct location
3. Prompt user for confirmation on conflicts
4. Create missing target directories automatically

**Rationale:**
- Prevents accidental overwrites of real files with symlinks
- Provides clear feedback before making changes
- Reduces user confusion from broken symlinks

**Alternatives considered:**
- **Alternative 1:** Force overwrite without checking
  - **Rejected because:** Risk of data loss; poor UX.
- **Alternative 2:** Skip symlinking if target exists
  - **Rejected because:** User can't update configs if needed; no feedback loop.

### 9. Component Removal: Delete web/ and .github/workflows/

**Decision:** Delete `web/` directory (SvelteKit app) and `.github/workflows/` directory (GitHub Actions CI/CD).

**Rationale:**
- Not currently used; adds repository bloat
- Online docs and GitHub Pages will be added later when v2 is stable
- Simplifies repository for the migration focus
- Reduces dependency on external services

**Alternatives considered:**
- **Alternative 1:** Keep `web/` but don't deploy it
  - **Rejected because:** Still requires maintenance; dead code in repository.
- **Alternative 2:** Move `web/` to archive directory
  - **Rejected because:** If needed later, can be restored from git history; archive adds clutter.
- **Alternative 3:** Keep GitHub Actions for future use
  - **Rejected because:** No CI/CD plans; can add back later when needed.

### 10. Path Updates: Search and Replace in Scripts/Docs

**Decision:** Update all hardcoded paths referencing root-level config directories to use new `configs/` paths.

**Rationale:**
- Ensures scripts and docs work after migration
- Prevents user confusion from outdated documentation
- Centralizes path knowledge in `symlinks.nu` DATA constant

**Alternatives considered:**
- **Alternative 1:** Leave old paths and use git history for reference
  - **Rejected because:** Scripts would break; poor user experience.
- **Alternative 2:** Use relative paths from script location
  - **Rejected because:** Scripts run from various locations; absolute or relative to repo root is clearer.

## Risks / Trade-offs

### Risks

1. **Symlink script complexity:** Multi-select, device profiles, and validation add complexity to `symlinks.nu`
   - **Mitigation:** Write clear Nushell code with comments; test each profile separately; add help messages.

2. **User confusion on branch migration:** Users may not know to switch to `v2` branch
   - **Mitigation:** Update README.md with branch guidance; add migration notes; keep `pipa` working.

3. **Path breakage:** Missed path references could cause scripts to fail
   - **Mitigation:** Comprehensive grep search for config directory references; test all scripts after migration.

4. **Device profile mismatches:** User may set wrong device type
   - **Mitigation:** Validate device type; show warning if profile excludes many configs; provide fallback to full profile.

5. **Testing on x64:** No existing x64 testing on `pipa` branch
   - **Mitigation:** Test on actual x64 hardware before merging `v2`; verify all Nushell features work cross-arch.

### Trade-offs

1. **Symlink script size:** Enhanced `symlinks.nu` will be larger and more complex than the current simple version
   - **Benefit:** Much more powerful (multi-select, device profiles, validation)
   - **Trade-off:** Acceptable complexity for significant UX improvement.

2. **Profile rigidity:** Device profiles are pre-defined; users may want custom combinations
   - **Benefit:** Clear, tested profiles for common scenarios
   - **Trade-off:** Advanced users can still symlink individual configs with `nu symlinks.nu <app_name>`.

3. **Branch proliferation:** Keeping both `pipa` and `v2` branches increases branch count
   - **Benefit:** Stable arm64 reference + multi-arch development
   - **Trade-off:** Acceptable; git can handle multiple branches easily.

4. **Component removal:** Deleting `web/` loses SvelteKit code that could be reused
   - **Benefit:** Cleaner repository; code can be restored from git history if needed
   - **Trade-off:** Online docs can be re-created later; no need to maintain unused code now.

5. **Nushell-only constraint:** Cannot use bash or external tools even if convenient
   - **Benefit:** Consistent shell usage; no dependency management across tools
   - **Trade-off:** Some tasks may require more Nushell code than bash would need.
