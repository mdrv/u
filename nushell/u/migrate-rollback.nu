#!/usr/bin/env nu
# ANNOTATION: Rollback script for failed chezmoi migration
# Restores old symlinks system if migration fails

# Import chezmoi wrapper
use nushell/u/chezmoi.nu *

print $"(ansi cyan_bold)==================================================(ansi reset)"
print $"(ansi cyan_bold)Chezmoi Migration Rollback(ansi reset)"
print $"(ansi cyan_bold)==================================================(ansi reset)"
print ""

print $"(ansi red)⚠️  This will restore the old symlinks-based system(ansi reset)"
print ""

# Ask for confirmation
print $"(ansi yellow)This will:(ansi reset)"
print $"(ansi gray)  1. Restore old symlinks(ansi reset)"
print $"(ansi gray)  2. Remove chezmoi-managed files(ansi reset)"
print $"(ansi gray)  3. Update configs to use symlinks.nu again(ansi reset)"
print ""
print $"(ansi red_bold)Proceed with rollback? [y/N](ansi reset)"

let response = (input | str trim)

if ($response | str downcase) != "y" {
    print ""
    print $"(ansi gray)Rollback cancelled. No changes made.(ansi reset)"
    exit 0
}

print ""
print $"(ansi cyan_bold)Starting rollback...(ansi reset)"
print ""

# Track rollback operations
let mut restored_count = 0
let mut removed_count = 0
let mut failed_count = 0

# ==============================================================================
# 1. Restore symlinks.nu
# ==============================================================================
print $"(ansi green_bold)1. Restoring symlinks.nu(ansi reset)"
print ""

if ("symlinks.nu.archive" | path exists) {
    # Archive exists, restore from it
    print $"(ansi gray)  Restoring from symlinks.nu.archive...(ansi reset)"
    cp symlinks.nu.archive symlinks.nu
    $restored_count = $restored_count + 1
    print $"(ansi green)✓ symlinks.nu restored(ansi reset)"
} else if ("symlinks.nu" | path exists) {
    # Original still exists, no need to restore
    print $"(ansi yellow)⚠ symlinks.nu still exists, skipping restore(ansi reset)"
    $restored_count = $restored_count + 1
    print $"(ansi green)✓ symlinks.nu already present(ansi reset)"
} else {
    # Not found anywhere
    print $"(ansi red)✗ symlinks.nu not found - cannot rollback(ansi reset)"
    $failed_count = $failed_count + 1
}

print ""

# ==============================================================================
# 2. Remove chezmoi-managed files
# ==============================================================================
print $"(ansi green_bold)2. Removing chezmoi-managed files(ansi reset)"
print ""

if not (is-chezmoi-installed) {
    print $"(ansi yellow)⚠ chezmoi not installed, skipping removal(ansi reset)"
    print ""
    print $"(ansi gray)You'll need to manually remove chezmoi files:(ansi reset)"
    print $"(ansi cyan)  rm -rf ~/.local/share/chezmoi(ansi reset)"
    print ""
} else {
    # Get list of managed files
    let managed_output = (managed --json)
    let managed = if $managed_output == "" {
        []
    } else {
        $managed_output | from json
    }

    if ($managed | is-empty) {
        print $"(ansi yellow)⚠ No chezmoi-managed files found(ansi reset)"
    } else {
        # Remove each managed file/directory
        for $item in $managed {
            let target = $item.target

            # Skip if target is home directory itself
            if ($target | path expand) == ($nu.home-dir | path expand) {
                print $"(ansi gray)  Skipping (ansi yellow)~(ansi gray) (home directory itself)(ansi reset)"
                continue
            }

            # Remove the file/directory
            if ($target | path exists) {
                try {
                    rm -rf $target
                    $removed_count = $removed_count + 1
                    print $"(ansi green)✓ Removed (ansi yellow)($target)(ansi reset)"
                } catch {
                    print $"(ansi red)✗ Failed to remove (ansi yellow)($target)(ansi reset)"
                    $failed_count = $failed_count + 1
                }
            } else {
                print $"(ansi gray)  Target (ansi yellow)($target)(ansi gray) does not exist, skipping(ansi reset)"
            }
        }
    }
}

print ""

# ==============================================================================
# 3. Remove chezmoi configuration files
# ==============================================================================
print $"(ansi green_bold)3. Removing chezmoi configuration(ansi reset)"
print ""

# Remove chezmoi config files from repo
let chezmoi_configs = [".chezmoi.yaml", ".chezmoiignore", ".chezmoiroot", ".chezmoi.post-apply.nu"]

for $config in $chezmoi_configs {
    if ($config | path exists) {
        try {
            rm $config
            $removed_count = $removed_count + 1
            print $"(ansi green)✓ Removed (ansi yellow)($config)(ansi reset)"
        } catch {
            print $"(ansi red)✗ Failed to remove (ansi yellow)($config)(ansi reset)"
            $failed_count = $failed_count + 1
        }
    } else {
        print $"(ansi gray)  (ansi yellow)($config)(ansi gray) does not exist, skipping(ansi reset)"
    }
}

print ""

# ==============================================================================
# 4. Remove migration scripts
# ==============================================================================
print $"(ansi green_bold)4. Removing migration scripts(ansi reset)"
print ""

let migration_scripts = [
    "nushell/u/migrate-single-files.nu"
    "nushell/u/migrate-nvim.nu"
    "nushell/u/migrate-nushell.nu"
    "nushell/u/migrate-complex.nu"
    "nushell/u/migrate-validate.nu"
    "nushell/u/migrate-rollback.nu"
    "migrate-to-chezmoi.nu"
]

for $script in $migration_scripts {
    if ($script | path exists) {
        try {
            rm $script
            $removed_count = $removed_count + 1
            print $"(ansi green)✓ Removed (ansi yellow)($script)(ansi reset)"
        } catch {
            print $"(ansi red)✗ Failed to remove (ansi yellow)($script)(ansi reset)"
            $failed_count = $failed_count + 1
        }
    } else {
        print $"(ansi gray)  (ansi yellow)($script)(ansi gray) does not exist, skipping(ansi reset)"
    }
}

print ""

# ==============================================================================
# Summary
# ==============================================================================
print $"(ansi cyan_bold)==================================================(ansi reset)"
print $"(ansi cyan_bold)Rollback Summary(ansi reset)"
print $"(ansi cyan_bold)==================================================(ansi reset)"
print ""
print $"(ansi green)✓(ansi reset) Restored: (ansi cyan_bold)($restored_count)(ansi reset) items"
print $"(ansi green)✓(ansi reset) Removed: (ansi cyan_bold)($removed_count)(ansi reset) chezmoi items"
if $failed_count > 0 {
    print $"(ansi red)✗(ansi reset) Failed: (ansi red_bold)($failed_count)(ansi reset) operations"
}
print ""
print $"(ansi cyan_bold)Next steps:(ansi reset)"
print ""
print $"(ansi gray)1. Reinstall old system: nu symlinks.nu <app_name>(ansi reset)"
print $"(ansi gray)2. Test configurations work correctly(ansi reset)"
print ""
print $"(ansi gray)If successful, you can remove these migration scripts:(ansi reset)"
print $"(ansi cyan)  nushell/u/migrate-*.nu, migrate-to-chezmoi.nu(ansi reset)"
print ""
print $"(ansi green)✓ Rollback complete!(ansi reset)"
