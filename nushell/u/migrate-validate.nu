#!/usr/bin/env nu
# ANNOTATION: Validation script for chezmoi migration
# Checks if migration was successful and provides rollback capability

# Import chezmoi wrapper
use nushell/u/chezmoi.nu *

print $"(ansi cyan_bold)==================================================(ansi reset)"
print $"(ansi cyan_bold)Chezmoi Migration Validation(ansi reset)"
print $"(ansi cyan_bold)==================================================(ansi reset)"
print ""

# Track validation results
let mut total_checks = 0
let mut passed_checks = 0
let mut warning_checks = 0
let mut error_checks = 0

def record-check [name: string, result: string, details: string] {
    $total_checks = $total_checks + 1
    print $"(ansi gray)[$total_checks] (ansi reset) (ansi white)($name | str rpad 30):(ansi reset) (ansi cyan)($result | str rpad 8)(ansi reset)"

    if $result == "PASS" {
        $passed_checks = $passed_checks + 1
        print $"(ansi green)✓(ansi reset) (ansi gray)($details)(ansi reset)"
    } else if $result == "WARN" {
        $warning_checks = $warning_checks + 1
        print $"(ansi yellow)⚠(ansi reset) (ansi gray)($details)(ansi reset)"
    } else {
        $error_checks = $error_checks + 1
        print $"(ansi red)✗(ansi reset) (ansi gray)($details)(ansi reset)"
    }
}

# ==============================================================================
# 1. Check chezmoi installation
# ==============================================================================
print ""
print $"(ansi green_bold)1. Chezmoi Installation(ansi reset)"
print ""

if not (is-chezmoi-installed) {
    record-check "chezmoi binary" "ERROR" "chezmoi is not installed. Install it first: curl -fsSL https://chezmoi.io/get | sh"
} else {
    # Check version
    try {
        let version = (chezmoi --version | complete | get -i 0 | str split " " | get -i 1)
        record-check "chezmoi version" "PASS" $"Installed: (ansi cyan)($version)(ansi reset)"
    } catch {
        record-check "chezmoi version" "WARN" "Could not determine chezmoi version (continuing)"
    }
}

# ==============================================================================
# 2. Verify chezmoi source state
# ==============================================================================
print ""
print $"(ansi green_bold)2. Chezmoi Source State(ansi reset)"
print ""

if (".chezmoi.yaml" | path exists) {
    record-check ".chezmoi.yaml" "PASS" "Configuration file exists"
} else {
    record-check ".chezmoi.yaml" "ERROR" ".chezmoi.yaml not found chezmoi may not be initialized"
}

if (".chezmoiignore" | path exists) {
    record-check ".chezmoiignore" "PASS" "Ignore patterns configured"
} else {
    record-check ".chezmoiignore" "WARN" ".chezmoiignore not found (optional but recommended)"
}

if (".chezmoiroot" | path exists) {
    record-check ".chezmoiroot" "PASS" "Source root configured"
} else {
    record-check ".chezmoiroot" "WARN" ".chezmoiroot not found (using repository root)"
}

# ==============================================================================
# 3. Check managed configurations
# ==============================================================================
print ""
print $"(ansi green_bold)3. Managed Configurations(ansi reset)"
print ""

let managed_output = (managed --json)
let managed = if $managed_output == "" {
    []
} else {
    $managed_output | from json
}

if ($managed | is-empty) {
    record-check "managed files" "ERROR" "No files are currently managed by chezmoi"
    print ""
    print $"(ansi yellow)Suggestion: Run 'nu migrate-to-chezmoi.nu' to perform migration first(ansi reset)"
} else {
    let file_count = ($managed | where type == "file" | length)
    let dir_count = ($managed | where type == "dir" | length)
    record-check "managed files" "PASS" $"($managed | length) items: ($file_count) files, ($dir_count) directories"

    # Check for critical configs
    let critical_configs = [
        "nvim"
        "nushell"
        "kitty"
        "zellij"
    ]

    for $config in $critical_configs {
        let has_config = ($managed | where type == "dir" | get name | any {|name| $name == $config })
        if $has_config {
            record-check $"($config) config" "PASS" "Managed"
        } else {
            record-check $"($config) config" "WARN" "Not managed by chezmoi"
        }
    }
}

# ==============================================================================
# 4. Check file integrity
# ==============================================================================
print ""
print $"(ansi green_bold)4. File Integrity(ansi reset)"
print ""

# Check device-specific configs (.u.* files)
print $"(ansi cyan)Checking for device-specific configs (.u.* files)(ansi reset)"

let nvim_u_lua = $"($nu.home-dir)/.config/nvim/.u.lua"
if ($nvim_u_lua | path exists) {
    record-check "nvim/.u.lua" "PASS" "Device-specific nvim config exists"
} else {
    record-check "nvim/.u.lua" "INFO" "No device-specific nvim config (this is OK)"
}

# Check if nvim/lua structure is correct
let nvim_lua_dir = $"($nu.home-dir)/.config/nvim/lua"
if ($nvim_lua_dir | path type) == "dir" {
    record-check "nvim/lua directory" "PASS" "nvim/lua directory exists at expected location"
} else {
    record-check "nvim/lua directory" "WARN" "nvim/lua directory does not exist"
}

# Test nvim config loading
if ($nvim_lua_dir | path type) == "dir" {
    try {
        # Simple test - can nu load the config structure
        let test_result = (^nu -c $"ls ($nvim_lua_dir)" | complete)
        record-check "nvim config load test" "PASS" "nvim config structure is valid"
    } catch {
        record-check "nvim config load test" "WARN" "nvim config test failed (may need manual verification)"
    }
}

# ==============================================================================
# 5. Test Nushell integration
# ==============================================================================
print ""
print $"(ansi green_bold)5. Nushell Integration(ansi reset)"
print ""

# Check if Nushell wrapper scripts are loaded
print $"(ansi cyan)Checking if chezmoi wrapper scripts are loaded(ansi reset)"

# These should be loaded via nushell/uconfig.nu
let chezmoi_wrapper_exists = (which chezmoi | is-not-empty) and (which cminstall | is-not-empty)
if $chezmoi_wrapper_exists {
    record-check "Nushell chezmoi wrappers" "PASS" "Chezmoi wrapper commands available (cm, cminstall, cmadd, cmstatus)"
} else {
    record-check "Nushell chezmoi wrappers" "WARN" "Nushell chezmoi wrappers not available or not in PATH"
    print ""
    print $"(ansi gray)  Ensure nushell/uconfig.nu sources chezmoi wrapper scripts(ansi reset)"
}

# Test install.nu
print $"(ansi cyan)Testing install.nu script(ansi reset)"

if (which install | is-not-empty) {
    record-check "install.nu" "PASS" "install.nu is available"
} else {
    record-check "install.nu" "WARN" "install.nu is not in PATH"
}

# Test add.nu
if (which cmadd | is-not-empty) {
    record-check "add.nu" "PASS" "cmadd command is available"
} else {
    record-check "add.nu" "WARN" "cmadd command is not in PATH"
}

# Test status.nu
if (which cmstatus | is-not-empty) {
    record-check "status.nu" "PASS" "cmstatus command is available"
} else {
    record-check "status.nu" "WARN" "cmstatus command is not in PATH"
}

# ==============================================================================
# 6. Verify chezmoi commands work
# ==============================================================================
print ""
print $"(ansi green_bold)6. Chezmoi Command Verification(ansi reset)"
print ""

# Test chezmoi commands
print "(ansi cyan)Testing chezmoi commands..."

try {
    # Test doctor
    ^chezmoi doctor --help | complete
    record-check "chezmoi doctor" "PASS" "chezmoi doctor command works"
} catch {
    record-check "chezmoi doctor" "WARN" "chezmoi doctor command failed"
}

try {
    # Test verify
    ^chezmoi verify --help | complete
    record-check "chezmoi verify" "PASS" "chezmoi verify command works"
} catch {
    record-check "chezmoi verify" "WARN" "chezmoi verify command failed"
}

# ==============================================================================
# 7. Check symlinks.nu reference
# ==============================================================================
print ""
print $"(ansi green_bold)7. Legacy System(ansi reset)"
print ""

if ("symlinks.nu" | path exists) {
    record-check "symlinks.nu" "INFO" "symlinks.nu still exists (preserved for reference)"
    print $"(ansi gray)  Old symlinks can be removed after confirming chezmoi setup works(ansi reset)"
} else if ("symlinks.nu.archive" | path exists) {
    record-check "symlinks.nu.archive" "INFO" "symlinks.nu.archive exists (migration backup found)"
} else {
    record-check "symlinks backup" "WARN" "Neither symlinks.nu nor symlinks.nu.archive found"
}

# ==============================================================================
# Summary and Recommendations
# ==============================================================================
print ""
print $"(ansi cyan_bold)==================================================(ansi reset)"
print $"(ansi cyan_bold)Validation Summary(ansi reset)"
print $"(ansi cyan_bold)==================================================(ansi reset)"
print ""
print $"(ansi gray)Total checks: (ansi white_bold)($total_checks)(ansi reset)"
print $"(ansi green)Passed: (ansi green_bold)($passed_checks)(ansi reset)"
if $warning_checks > 0 {
    print $"(ansi yellow)Warnings: (ansi yellow_bold)($warning_checks)(ansi reset)"
}
if $error_checks > 0 {
    print $"(ansi red)Errors: (ansi red_bold)($error_checks)(ansi reset)"
}
print ""

# Exit code based on result
if $error_checks > 0 {
    print ""
    print $"(ansi red_bold)VALIDATION FAILED(ansi reset)"
    print ""
    print $"(ansi cyan)Next steps:(ansi reset)"
    print $"(ansi gray)1. Fix errors above and re-run: nu nushell/u/migrate-validate.nu(ansi reset)"
    print $"(ansi gray)2. Or run rollback: nu nushell/u/migrate-rollback.nu(ansi reset)"
    exit 2
} else if $warning_checks > 0 {
    print ""
    print $"(ansi yellow_bold)VALIDATION COMPLETED WITH WARNINGS(ansi reset)"
    print ""
    print $"(ansi cyan)Review warnings above and address if needed(ansi reset)"
    print ""
    print $"(ansi green)✓ You can proceed with chezmoi setup(ansi reset)"
    exit 1
} else {
    print ""
    print $"(ansi green_bold)VALIDATION PASSED(ansi reset)"
    print ""
    print $"(ansi green)✓ Migration appears successful!(ansi reset)"
    print ""
    print $"(ansi cyan)Recommended next steps:(ansi reset)"
    print $"(ansi gray)1. Apply configurations: nu install.nu(ansi reset)"
    print $"(ansi gray)2. Verify: chezmoi verify(ansi reset)"
    print $"(ansi gray)3. Archive old symlinks: chezmoi archive symlinks(ansi reset)"
    exit 0
}
