#!/usr/bin/env nu
# ANNOTATION: Migration script for nushell configuration
# Uses $nu.default-config-dir as target (equivalent to ~/.config/nushell/)
# Preserves the extension pattern that appends to default configs

# Import chezmoi wrapper
use nushell/u/chezmoi.nu *

print $"(ansi cyan_bold)Migrating nushell configuration to chezmoi...(ansi reset)"
print ""

print $"(ansi yellow)Target: ($nu.default-config-dir)(ansi reset)"
print $"(ansi yellow)This is equivalent to ~/.config/nushell/(ansi reset)"
print ""

# Track success/failure
let mut success_count = 0
let mut failed_count = 0

# The nushell config directory
let nushell_config = $nu.default-config-dir

# 1. Migrate main configuration files
print $"(ansi green_bold)1. Migrating main configuration files...(ansi reset)"

# uinit.nu
if ($"($nushell_config)/uinit.nu" | path exists) {
    add $"($nushell_config)/uinit.nu" --follow
    if $env.LAST_EXIT_CODE == 0 {
        $success_count = $success_count + 1
        print $"(ansi green)✓ uinit.nu migrated(ansi reset)"
    } else {
        $failed_count = $failed_count + 1
        print $"(ansi red)✗ uinit.nu failed(ansi reset)"
    }
} else {
    print $"(ansi yellow)⚠ uinit.nu not found at target, skipping(ansi reset)"
}

# uconfig.nu
if ($"($nushell_config)/uconfig.nu" | path exists) {
    add $"($nushell_config)/uconfig.nu" --follow
    if $env.LAST_EXIT_CODE == 0 {
        $success_count = $success_count + 1
        print $"(ansi green)✓ uconfig.nu migrated(ansi reset)"
    } else {
        $failed_count = $failed_count + 1
        print $"(ansi red)✗ uconfig.nu failed(ansi reset)"
    }
} else {
    print $"(ansi yellow)⚠ uconfig.nu not found at target, skipping(ansi reset)"
}

# uenv.nu
if ($"($nushell_config)/uenv.nu" | path exists) {
    add $"($nushell_config)/uenv.nu" --follow
    if $env.LAST_EXIT_CODE == 0 {
        $success_count = $success_count + 1
        print $"(ansi green)✓ uenv.nu migrated(ansi reset)"
    } else {
        $failed_count = $failed_count + 1
        print $"(ansi red)✗ uenv.nu failed(ansi reset)"
    }
} else {
    print $"(ansi yellow)⚠ uenv.nu not found at target, skipping(ansi reset)"
}
print ""

# 2. Migrate u/ directory (custom modules)
print $"(ansi green_bold)2. Migrating custom modules directory...(ansi reset)"

if ($"($nushell_config)/u" | path type) == "dir" {
    add $"($nushell_config)/u" --follow --recursive
    if $env.LAST_EXIT_CODE == 0 {
        $success_count = $success_count + 1
        print $"(ansi green)✓ u/ directory migrated(ansi reset)"
    } else {
        $failed_count = $failed_count + 1
        print $"(ansi red)✗ u/ failed(ansi reset)"
    }
} else {
    print $"(ansi yellow)⚠ u/ not found at target, skipping(ansi reset)"
}
print ""

# 3. Verify extension pattern
print $"(ansi green_bold)3. Extension pattern verification(ansi reset)"
print $"(ansi yellow)Nushell config should extend default configs by appending:(ansi reset)"
print $"(ansi gray)  source ~/.config/nushell/uenv.nu to env.nu(ansi reset)"
print $"(ansi gray)  source ~/.config/nushell/uconfig.nu to config.nu(ansi reset)"
print ""
print $"(ansi cyan)Check default configs to ensure these lines exist:(ansi reset)"
print $"(ansi gray)  ~/.config/nushell/env.nu (or system equivalent)(ansi reset)"
print $"(ansi gray)  ~/.config/nushell/config.nu (or system equivalent)(ansi reset)"
print ""

# 4. Test configuration loading
print $"(ansi green_bold)4. Testing nushell configuration...(ansi reset)"

# Try to verify nushell can load the config
try {
    ^nu -c "use ($nu.default-config-dir)/uinit.nu; print 'Config loaded successfully'"
    print $"(ansi green)✓ Nushell configuration loads correctly(ansi reset)"
} catch {
    print $"(ansi yellow)⚠ Nushell configuration test failed (this is OK if not installed yet)(ansi reset)"
}
print ""

# Summary
print ""
print $"(ansi cyan_bold)Migration Summary(ansi reset)"
print $"(ansi green)✓(ansi reset) Successfully migrated: (ansi cyan_bold)($success_count)(ansi reset)"
if $failed_count > 0 {
    print $"(ansi red)✗(ansi reset) Failed to migrate: (ansi red_bold)($failed_count)(ansi reset)"
}
print ""
print $"(ansi gray)Run 'nu install.nu' to apply all configurations(ansi reset)"
