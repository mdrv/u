#!/usr/bin/env nu
# ANNOTATION: Migration script for nvim configuration
# nvim has custom target: ~/.config/nvim/lua (not ~/.config/nvim/)
# Uses chezmoi templates to handle the nested path

# Import chezmoi wrapper
use nushell/u/chezmoi.nu *

print $"(ansi cyan_bold)Migrating nvim configuration to chezmoi...(ansi reset)"
print ""

print $"(ansi yellow)Note: nvim has special target: ~/.config/nvim/lua/(ansi reset)"
print $"(ansi yellow)We'll use chezmoi templates to handle this.(ansi reset)"
print ""

# Track success/failure
let mut success_count = 0
let mut failed_count = 0

# The nvim config directory
let nvim_config = $"($nu.home-dir)/.config/nvim"
let nvim_lua_dir = $"($nvim_config)/lua"

# Create nvim_lua_dir template that creates the nested structure
# This template will be executed by chezmoi to ensure the directory exists
let create_nvim_lua_template = '''#!/bin/bash
# Create nvim/lua directory structure
NVIM_LUA_DIR="$HOME/.config/nvim/lua"
mkdir -p "$NVIM_LUA_DIR"
echo "Created $NVIM_LUA_DIR"
'''

# 1. Create the nvim/lua directory
print $"(ansi green_bold)1. Creating nvim/lua directory structure...(ansi reset)"
if ($nvim_lua_dir | path exists) {
    print $"(ansi green)✓ nvim/lua directory exists(ansi reset)"
} else {
    print $"(ansi yellow)Creating nvim/lua directory...(ansi reset)"
    mkdir -p $nvim_lua_dir
    print $"(ansi green)✓ nvim/lua directory created(ansi reset)"
}
print ""

# 2. Migrate individual Lua files
print $"(ansi green_bold)2. Migrating Lua files...(ansi reset)"

# uinit.lua
if ($"($nvim_lua_dir)/uinit.lua" | path exists) {
    add $"($nvim_lua_dir)/uinit.lua" --follow
    if $env.LAST_EXIT_CODE == 0 {
        $success_count = $success_count + 1
        print $"(ansi green)✓ uinit.lua migrated(ansi reset)"
    } else {
        $failed_count = $failed_count + 1
        print $"(ansi red)✗ uinit.lua failed(ansi reset)"
    }
} else {
    print $"(ansi yellow)⚠ uinit.lua not found at target, skipping(ansi reset)"
}

# utils.lua
if ($"($nvim_lua_dir)/utils.lua" | path exists) {
    add $"($nvim_lua_dir)/utils.lua" --follow
    if $env.LAST_EXIT_CODE == 0 {
        $success_count = $success_count + 1
        print $"(ansi green)✓ utils.lua migrated(ansi reset)"
    } else {
        $failed_count = $failed_count + 1
        print $"(ansi red)✗ utils.lua failed(ansi reset)"
    }
} else {
    print $"(ansi yellow)⚠ utils.lua not found at target, skipping(ansi reset)"
}
print ""

# 3. Migrate directories
print $"(ansi green_bold)3. Migrating plugin directories...(ansi reset)"

# ulazy/ - plugin specs
if ($"($nvim_lua_dir)/ulazy" | path type) == "dir" {
    add $"($nvim_lua_dir)/ulazy" --follow --recursive
    if $env.LAST_EXIT_CODE == 0 {
        $success_count = $success_count + 1
        print $"(ansi green)✓ ulazy/ directory migrated(ansi reset)"
    } else {
        $failed_count = $failed_count + 1
        print $"(ansi red)✗ ulazy/ failed(ansi reset)"
    }
} else {
    print $"(ansi yellow)⚠ ulazy/ not found at target, skipping(ansi reset)"
}

# ulsp/ - LSP configs
if ($"($nvim_lua_dir)/ulsp" | path type) == "dir" {
    add $"($nvim_lua_dir)/ulsp" --follow --recursive
    if $env.LAST_EXIT_CODE == 0 {
        $success_count = $success_count + 1
        print $"(ansi green)✓ ulsp/ directory migrated(ansi reset)"
    } else {
        $failed_count = $failed_count + 1
        print $"(ansi red)✗ ulsp/ failed(ansi reset)"
    }
} else {
    print $"(ansi yellow)⚠ ulsp/ not found at target, skipping(ansi reset)"
}

# unavigate/ - navigation plugin
if ($"($nvim_lua_dir)/unavigate" | path type) == "dir" {
    add $"($nvim_lua_dir)/unavigate" --follow --recursive
    if $env.LAST_EXIT_CODE == 0 {
        $success_count = $success_count + 1
        print $"(ansi green)✓ unavigate/ directory migrated(ansi reset)"
    } else {
        $failed_count = $failed_count + 1
        print $"(ansi red)✗ unavigate/ failed(ansi reset)"
    }
} else {
    print $"(ansi yellow)⚠ unavigate/ not found at target, skipping(ansi reset)"
}
print ""

# 4. Handle device-specific config (.u.lua)
print $"(ansi green_bold)4. Device-specific configuration (.u.lua)(ansi reset)"
print $"(ansi yellow)Note: .u.lua is device-specific and not in the repo.(ansi reset)"
print $"(ansi yellow)The nvim config should load .u.lua if it exists.(ansi reset)"
print $"(ansi cyan)See nvim/uinit.lua for the loading logic.(ansi reset)"
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
