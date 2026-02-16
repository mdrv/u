#!/usr/bin/env nu
# ANNOTATION: Master migration script for chezmoi dotfile management
# Runs all individual migration scripts in the correct order
# Run this after installing chezmoi to migrate from symlink-based system

print $"(ansi cyan_bold)==================================================(ansi reset)"
print $"(ansi cyan_bold)μ Dotfiles - Chezmoi Migration(ansi reset)"
print $"(ansi cyan_bold)==================================================(ansi reset)"
print ""

print $"(ansi gray)This will migrate your dotfiles from symlinks.nu to chezmoi.(ansi reset)"
print $"(ansi gray)Make sure you have:(ansi reset)"
print $"(ansi green)1. Installed chezmoi (https://chezmoi.io/get/)(ansi reset)"
print $"(ansi green)2. Initialized chezmoi (chezmoi init)(ansi reset)"
print ""

# Ask for confirmation
print $"(ansi yellow)Continue with migration? [y/N](ansi reset)"
let response = (input | str trim)

if ($response | str downcase) != "y" {
    print ""
    print $"(ansi gray)Migration cancelled. Run this script again to continue.(ansi reset)"
    exit 0
}

print ""
print $"(ansi cyan_bold)Starting migration...(ansi reset)"
print ""

# Track overall success/failure
let mut overall_success = 0
let mut overall_failed = 0

# ==============================================================================
# Phase 1: Infrastructure
# ==============================================================================
print $"(ansi green_bold)Phase 1: Chezmoi Infrastructure(ansi reset)"
print ""

if (".chezmoi.yaml" | path exists) and (".chezmoiignore" | path exists) and (".chezmoiroot" | path exists) {
    print $"(ansi green)✓ Chezmoi infrastructure already set up(ansi reset)"
    $overall_success = $overall_success + 1
} else {
    print $"(ansi yellow)Infrastructure not yet set up. Please run:(ansi reset)"
    print $"(ansi cyan)  1. Create .chezmoi.yaml with configuration(ansi reset)"
    print $"(ansi cyan)  2. Create .chezmoiignore for exclusions(ansi reset)"
    print $"(ansi cyan)  3. Create .chezmoiroot to specify source root(ansi reset)"
    print ""
    error make { msg: "Please set up chezmoi infrastructure first" }
}
print ""

# ==============================================================================
# Phase 2: Single-file tools
# ==============================================================================
print $"(ansi green_bold)Phase 2: Single-file Tools(ansi reset)"
print ""

try {
    nu nushell/u/migrate-single-files.nu
    print $"(ansi green)✓ Single-file tools migration completed(ansi reset)"
    $overall_success = $overall_success + 1
} catch {
    $overall_failed = $overall_failed + 1
    print $"(ansi red)✗ Single-file tools migration failed(ansi reset)"
}
print ""

# ==============================================================================
# Phase 3: nvim
# ==============================================================================
print $"(ansi green_bold)Phase 3: nvim Configuration(ansi reset)"
print ""

try {
    nu nushell/u/migrate-nvim.nu
    print $"(ansi green)✓ nvim migration completed(ansi reset)"
    $overall_success = $overall_success + 1
} catch {
    $overall_failed = $overall_failed + 1
    print $"(ansi red)✗ nvim migration failed(ansi reset)"
}
print ""

# ==============================================================================
# Phase 4: nushell
# ==============================================================================
print $"(ansi green_bold)Phase 4: Nushell Configuration(ansi reset)"
print ""

try {
    nu nushell/u/migrate-nushell.nu
    print $"(ansi green)✓ nushell migration completed(ansi reset)"
    $overall_success = $overall_success + 1
} catch {
    $overall_failed = $overall_failed + 1
    print $"(ansi red)✗ nushell migration failed(ansi reset)"
}
print ""

# ==============================================================================
# Phase 5: Complex multi-file tools
# ==============================================================================
print $"(ansi green_bold)Phase 5: Complex Multi-file Tools(ansi reset)"
print ""

try {
    nu nushell/u/migrate-complex.nu
    print $"(ansi green)✓ Complex tools migration completed(ansi reset)"
    $overall_success = $overall_success + 1
} catch {
    $overall_failed = $overall_failed + 1
    print $"(ansi red)✗ Complex tools migration failed(ansi reset)"
}
print ""

# ==============================================================================
# Phase 6: Post-apply hooks
# ==============================================================================
print $"(ansi green_bold)Phase 6: Post-Apply Hooks(ansi reset)"
print ""

if (".chezmoi.post-apply.nu" | path exists) {
    print $"(ansi green)✓ Post-apply hooks are configured(ansi reset)"
    print $"(ansi gray)  Hooks will run automatically on 'chezmoi apply'(ansi reset)"
    $overall_success = $overall_success + 1
} else {
    print $"(ansi yellow)⚠ Post-apply hooks not found, this is okay(ansi reset)"
    print $"(ansi gray)  Hooks are optional. Create .chezmoi.post-apply.nu if needed.(ansi reset)"
    $overall_success = $overall_success + 1
}
print ""

# ==============================================================================
# Final Summary
# ==============================================================================
print $"(ansi cyan_bold)==================================================(ansi reset)"
print $"(ansi cyan_bold)Migration Summary(ansi reset)"
print $"(ansi cyan_bold)==================================================(ansi reset)"
print ""
print $"(ansi green)✓(ansi reset) Phases completed: (ansi cyan_bold)($overall_success)(ansi reset)"
if $overall_failed > 0 {
    print $"(ansi red)✗(ansi reset) Phases failed: (ansi red_bold)($overall_failed)(ansi reset)"
    print ""
    print $"(ansi yellow)Please fix the errors above and re-run the migration.(ansi reset)"
    print ""
    print $"(ansi gray)You can run individual migration scripts to retry specific phases:(ansi reset)"
    print $"(ansi gray)  nu nushell/u/migrate-single-files.nu(ansi reset)"
    print $"(ansi gray)  nu nushell/u/migrate-nvim.nu(ansi reset)"
    print $"(ansi gray)  nu nushell/u/migrate-nushell.nu(ansi reset)"
    print $"(ansi gray)  nu nushell/u/migrate-complex.nu(ansi reset)"
    exit 1
}
print ""
print $"(ansi green_bold)Migration Successful!(ansi reset)"
print ""
print $"(ansi cyan)Next steps:(ansi reset)"
print $"(ansi gray)1. Review migrated configs: chezmoi managed --verbose(ansi reset)"
print $"(ansi gray)2. Apply configurations: nu install.nu(ansi reset)"
print $"(ansi gray)3. Verify everything works: chezmoi verify(ansi reset)"
print ""
print $"(ansi cyan)Nushell aliases for chezmoi management:(ansi reset)"
print $"(ansi gray)  cm        - chezmoi wrapper commands(ansi reset)"
print $"(ansi gray)  cminstall - install configurations(ansi reset)"
print $"(ansi gray)  cmadd     - add new configs(ansi reset)"
print $"(ansi gray)  cmstatus  - show managed configs(ansi reset)"
print ""
print $"(ansi gray)Old symlinks.nu will be preserved for reference.(ansi reset)"
print $"(ansi gray)Archive it after confirming everything works: chezmoi archive symlinks(ansi reset)"
