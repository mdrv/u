#!/usr/bin/env nu
# ANNOTATION: Post-apply hook for chezmoi
# Handles additional setup steps after configurations are applied
# Replaces post-link messages from symlinks.nu DATA constant

print $"(ansi cyan_bold)Running post-apply setup...(ansi reset)"
print ""

# Track executed hooks
let mut hook_count = 0
let mut hook_success_count = 0
let mut hook_failed_count = 0

# ==============================================================================
# nvim hook
# ==============================================================================
print $"(ansi green_bold)1. nvim(ansi reset)"
print $"(ansi yellow)Note: nvim supports device-specific configuration via .u.lua(ansi reset)"
print $"(ansi gray)  Create ~/.config/nvim/.u.lua with: return {LV = 1}(ansi reset)"
print $"(ansi gray)  to enable plugins. See nvim/uinit.lua for details.(ansi reset)"
$hook_count = $hook_count + 1
$hook_success_count = $hook_success_count + 1
print ""

# ==============================================================================
# zellij hook
# ==============================================================================
print $"(ansi green_bold)2. zellij(ansi reset)"
print $"(ansi yellow)Downloading zjstatus.wasm for zellij...(ansi reset)"

let zellij_dir = $"($nu.home-dir)/.config/zellij"
let zjstatus_path = $"($zellij_dir)/zjstatus.wasm"

# Check if already exists
if ($zjstatus_path | path exists) {
    print $"(ansi green)✓ zjstatus.wasm already exists(ansi reset)"
} else {
    print $"(ansi gray)  Downloading from GitHub releases...(ansi reset)"

    try {
        # Download latest zjstatus.wasm
        http get "https://github.com/dj95/zjstatus/releases/latest/download/zjstatus.wasm" | save -f $zjstatus_path

        if ($zjstatus_path | path exists) {
            $hook_success_count = $hook_success_count + 1
            print $"(ansi green)✓ zjstatus.wasm downloaded successfully(ansi reset)"
        } else {
            error make { msg: "Failed to download zjstatus.wasm" }
        }
    } catch {
        $hook_failed_count = $hook_failed_count + 1
        print $"(ansi red)✗ Failed to download zjstatus.wasm(ansi reset)"
        print $"(ansi gray)  Error: ($env.LAST_ERROR)(ansi reset)"
    }
}

$hook_count = $hook_count + 1
print ""

# ==============================================================================
# opencode hook
# ==============================================================================
print $"(ansi green_bold)3. opencode(ansi reset)"
print $"(ansi yellow)Note: opencode requires skills directory symlink(ansi reset)"
print $"(ansi gray)  Run this command to symlink skills:(ansi reset)"
print $"(ansi cyan)  sudo ln -sf /g/ai/skills ($nu.home-dir)/.agents/skills(ansi reset)"
print $"(ansi gray)  Or add it to your PATH and run opencode setup.(ansi reset)"
$hook_count = $hook_count + 1
$hook_success_count = $hook_success_count + 1
print ""

# ==============================================================================
# Summary
# ==============================================================================
print $"(ansi cyan_bold)Post-apply Summary(ansi reset)"
print $"(ansi green)✓(ansi reset) Hooks executed: (ansi cyan_bold)($hook_success_count)(ansi reset)"
if $hook_failed_count > 0 {
    print $"(ansi red)✗(ansi reset) Hooks failed: (ansi red_bold)($hook_failed_count)(ansi reset)"
}
print ""
print $"(ansi gray)All post-apply setup complete.(ansi reset)"
