#!/usr/bin/env nu
# ANNOTATION: Migration script for single-file tool configurations
# Adds configs to chezmoi using chezmoi add --follow to capture actual file content
# Run this after chezmoi is initialized

# Import chezmoi wrapper
use nushell/u/chezmoi.nu *

print $"(ansi cyan_bold)Migrating single-file tool configurations to chezmoi...(ansi reset)"
print ""

# Track success/failure
let mut success_count = 0
let mut failed_count = 0

# Migrate kitty
print $"(ansi green_bold)1. kitty(ansi reset)"
if ($"($nu.home-dir)/.config/kitty/kitty.conf" | path exists) {
    add $"($nu.home-dir)/.config/kitty/kitty.conf" --follow
    if $env.LAST_EXIT_CODE == 0 {
        $success_count = $success_count + 1
        print $"(ansi green)✓ kitty.conf migrated(ansi reset)"
    } else {
        $failed_count = $failed_count + 1
        print $"(ansi red)✗ kitty.conf failed(ansi reset)"
    }
} else {
    print $"(ansi yellow)⚠ kitty/kitty.conf not found at target, skipping(ansi reset)"
}
print ""

# Migrate tofi
print $"(ansi green_bold)2. tofi(ansi reset)"
if ($"($nu.home-dir)/.config/tofi/config" | path exists) {
    add $"($nu.home-dir)/.config/tofi/config" --follow
    if $env.LAST_EXIT_CODE == 0 {
        $success_count = $success_count + 1
        print $"(ansi green)✓ tofi/config migrated(ansi reset)"
    } else {
        $failed_count = $failed_count + 1
        print $"(ansi red)✗ tofi/config failed(ansi reset)"
    }
} else {
    print $"(ansi yellow)⚠ tofi/config not found at target, skipping(ansi reset)"
}
print ""

# Migrate dunst
print $"(ansi green_bold)3. dunst(ansi reset)"
if ($"($nu.home-dir)/.config/dunst/dunstrc" | path exists) {
    add $"($nu.home-dir)/.config/dunst/dunstrc" --follow
    if $env.LAST_EXIT_CODE == 0 {
        $success_count = $success_count + 1
        print $"(ansi green)✓ dunstrc migrated(ansi reset)"
    } else {
        $failed_count = $failed_count + 1
        print $"(ansi red)✗ dunstrc failed(ansi reset)"
    }
} else {
    print $"(ansi yellow)⚠ dunst/dunstrc not found at target, skipping(ansi reset)"
}
print ""

# Migrate aichat
print $"(ansi green_bold)4. aichat(ansi reset)"
if ($"($nu.home-dir)/.config/aichat/config.yaml" | path exists) {
    add $"($nu.home-dir)/.config/aichat/config.yaml" --follow
    if $env.LAST_EXIT_CODE == 0 {
        $success_count = $success_count + 1
        print $"(ansi green)✓ aichat/config.yaml migrated(ansi reset)"
    } else {
        $failed_count = $failed_count + 1
        print $"(ansi red)✗ aichat/config.yaml failed(ansi reset)"
    }
} else {
    print $"(ansi yellow)⚠ aichat/config.yaml not found at target, skipping(ansi reset)"
}
print ""

# Migrate atuin
print $"(ansi green_bold)5. atuin(ansi reset)"
if ($"($nu.home-dir)/.config/atuin/config.toml" | path exists) {
    add $"($nu.home-dir)/.config/atuin/config.toml" --follow
    if $env.LAST_EXIT_CODE == 0 {
        $success_count = $success_count + 1
        print $"(ansi green)✓ atuin/config.toml migrated(ansi reset)"
    } else {
        $failed_count = $failed_count + 1
        print $"(ansi red)✗ atuin/config.toml failed(ansi reset)"
    }
} else {
    print $"(ansi yellow)⚠ atuin/config.toml not found at target, skipping(ansi reset)"
}
print ""

# Migrate neovide
print $"(ansi green_bold)6. neovide(ansi reset)"
if ($"($nu.home-dir)/.config/neovide/config.toml" | path exists) {
    add $"($nu.home-dir)/.config/neovide/config.toml" --follow
    if $env.LAST_EXIT_CODE == 0 {
        $success_count = $success_count + 1
        print $"(ansi green)✓ neovide/config.toml migrated(ansi reset)"
    } else {
        $failed_count = $failed_count + 1
        print $"(ansi red)✗ neovide/config.toml failed(ansi reset)"
    }
} else {
    print $"(ansi yellow)⚠ neovide/config.toml not found at target, skipping(ansi reset)"
}
print ""

# Migrate crush
print $"(ansi green_bold)7. crush(ansi reset)"
if ($"($nu.home-dir)/.config/crush/crush.json" | path exists) {
    add $"($nu.home-dir)/.config/crush/crush.json" --follow
    if $env.LAST_EXIT_CODE == 0 {
        $success_count = $success_count + 1
        print $"(ansi green)✓ crush/crush.json migrated(ansi reset)"
    } else {
        $failed_count = $failed_count + 1
        print $"(ansi red)✗ crush/crush.json failed(ansi reset)"
    }
} else {
    print $"(ansi yellow)⚠ crush/crush.json not found at target, skipping(ansi reset)"
}
print ""

# Migrate home (gitconfig)
print $"(ansi green_bold)8. home (.gitconfig)(ansi reset)"
if ($"($nu.home-dir)/.gitconfig" | path exists) {
    add $"($nu.home-dir)/.gitconfig" --follow
    if $env.LAST_EXIT_CODE == 0 {
        $success_count = $success_count + 1
        print $"(ansi green)✓ .gitconfig migrated(ansi reset)"
    } else {
        $failed_count = $failed_count + 1
        print $"(ansi red)✗ .gitconfig failed(ansi reset)"
    }
} else {
    print $"(ansi yellow)⚠ .gitconfig not found, skipping(ansi reset)"
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
