## Why

The current repository structure has configuration files (nushell, nvim, hypr, kitty, foot, waybar, zellij, etc.) scattered at the root level, making the root directory cluttered and harder to navigate. Additionally, the `pipa` branch has only been tested on arm64, leaving x64 support unverified.

We previously considered chezmoi for config management but rejected it due to unnecessary overhead. A simpler, Nushell-first approach is preferred:

- Keep all configs in a unified `configs/` directory for a cleaner repository root
- Remove the `web/` SvelteKit config viewer (GitHub Pages) for now — online docs will be created later when v2 is stable
- Remove GitHub Actions/Workflows as they're currently unused
- Support multi-architecture deployment (arm64 and x64) on a new `v2` branch
- Use pure Nushell for all operations (no bash, no third-party tools)
- Build a smarter symlink script with multi-select and device-specific configuration support

The existing `~/.u.nuon` → `~/.u.json` device-specific config mechanism (nushell/uenv.nu:45-51) should be preserved and leveraged.

## What Changes

### Structural Changes

1. **Create new branch `v2`** — Forked from `pipa` (or `main`), this becomes the new development branch for the migration
2. **Create `configs/` directory** — Move all configuration directories into a single `configs/` namespace
3. **Move configurations** — Relocate the following from root to `configs/`:
   - `nushell/` → `configs/nushell/`
   - `nvim/` → `configs/nvim/`
   - `hypr/` → `configs/hypr/`
   - `kitty/` → `configs/kitty/`
   - `foot/` → `configs/foot/`
   - `waybar/` → `configs/waybar/`
   - `zellij/` → `configs/zellij/`
   - `dunst/` → `configs/dunst/`
   - `tofi/` → `configs/tofi/`
   - `yazi/` → `configs/yazi/`
   - `atuin/` → `configs/atuin/`
   - `aichat/` → `configs/aichat/`
   - `crush/` → `configs/crush/`
   - `fastfetch/` → `configs/fastfetch/`
   - `neovide/` → `configs/neovide/`
   - `opencode/` → `configs/opencode/`
   - `otd/` → `configs/otd/`
   - `quickshell/` → `configs/quickshell/`
   - `home/` → `configs/home/`

4. **Remove deprecated components**:
   - Delete `web/` directory (SvelteKit app + GitHub Pages deployment)
   - Delete `.github/workflows/` directory (GitHub Actions CI/CD)

### Symlink Script Enhancements

5. **Replace `symlinks.nu` with enhanced version**:
   - Multi-select capability — Choose multiple configs to symlink at once
   - Device-specific configuration support:
     - VPS-specific profiles
     - Arch Linux x64 profiles
     - Arch Linux ARM profiles
     - Termux/Android profiles
   - Leverage existing `~/.u.nuon` → `~/.u.json` mechanism for device detection
   - Pure Nushell implementation (no bash, no external dependencies)

### Path Updates

6. **Update all internal path references** — Update any hardcoded paths in scripts, docs, and configs that reference the old root-level structure

## Capabilities

### New Capabilities

- **configs-directory-namespace**: Unified `configs/` directory as single source of truth for all configuration files
- **multi-device-config**: Device-specific configuration profiles for VPS, Arch x64, Arch ARM, and Termux/Android
- **multi-select-symlinks**: Enhanced symlink script supporting batch selection of configurations
- **dual-architecture-support**: Verified support for both arm64 and x64 architectures on v2 branch

### Modified Capabilities

- **symlink-management**: Enhanced from single-app symlinking to multi-select with device profiles
- **device-config**: Leverage existing `~/.u.nuon` → `~/.u.json` mechanism for device detection and profile loading

## Impact

### Positive Impact

- **Cleaner repository root** — Only core project files (openspec/, .opencode/, etc.) at root
- **Better organization** — All configs consolidated in `configs/` namespace
- **Multi-architecture readiness** — v2 branch tested on both arm64 and x64
- **Simplified tooling** — Remove unused web/ and GitHub Actions overhead
- **Better device support** — Device-specific profiles for different deployment targets
- **Faster onboarding** — Clear structure for new contributors

### Breaking Changes

- **Path changes** — Users with existing symlinks from root-level `symlinks.nu` will need to re-run the new script
- **Branch migration** — Development shifts from `pipa` to `v2` branch
- **Web viewer removed** — No GitHub Pages config viewer (will be added back later)

### Migration Risk

- **Low** — The change is mostly structural. Functionality remains the same, just relocated.
- **Testing required** — Start with nushell config migration, verify symlink script, then migrate remaining configs incrementally.
- **Rollback available** — Can revert to `pipa` branch if issues arise.

### Dependencies

- **Nushell 0.105.0+** — Required for data-oriented symlink script operations
- **Existing `~/.u.nuon`** — Device config mechanism already implemented, to be preserved

