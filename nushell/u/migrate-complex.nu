#!/usr/bin/env nu
# ANNOTATION: Migration script for complex multi-file tool configurations
# Includes waybar, hypr, zellij, quickshell, foot, yazi, fastfetch
# Handles special setup requirements (e.g., zjstatus.wasm download)

# Import chezmoi wrapper
use nushell/u/chezmoi.nu *

print $"(ansi cyan_bold)Migrating complex multi-file tool configurations to chezmoi...(ansi reset)"
print ""

# Track success/failure
let mut success_count = 0
let mut failed_count = 0

# ==============================================================================
# Waybar
# ==============================================================================
print $"(ansi green_bold)1. Waybar(ansi reset)"

if ($"($nu.home-dir)/.config/waybar/config.jsonc" | path exists) {
    add $"($nu.home-dir)/.config/waybar/config.jsonc" --follow
    if $env.LAST_EXIT_CODE == 0 {
        $success_count = $success_count + 1
        print $"(ansi green)✓ waybar/config.jsonc migrated(ansi reset)"
    } else {
        $failed_count = $failed_count + 1
        print $"(ansi red)✗ waybar/config.jsonc failed(ansi reset)"
    }
} else {
    print $"(ansi yellow)⚠ waybar/config.jsonc not found at target, skipping(ansi reset)"
}

if ($"($nu.home-dir)/.config/waybar/style.css" | path exists) {
    add $"($nu.home-dir)/.config/waybar/style.css" --follow
    if $env.LAST_EXIT_CODE == 0 {
        $success_count = $success_count + 1
        print $"(ansi green)✓ waybar/style.css migrated(ansi reset)"
    } else {
        $failed_count = $failed_count + 1
        print $"(ansi red)✗ waybar/style.css failed(ansi reset)"
    }
} else {
    print $"(ansi yellow)⚠ waybar/style.css not found at target, skipping(ansi reset)"
}
print ""

# ==============================================================================
# Hyprland
# ==============================================================================
print $"(ansi green_bold)2. Hyprland(ansi reset)"

let hypr_dir = $"($nu.home-dir)/.config/hypr"

# Main config files
let hypr_configs = ["hyprland.conf", "hyprlock.conf", "hyprtoolkit.conf"]
for $config in $hypr_configs {
    let target = $"($hypr_dir)/($config)"
    if ($target | path exists) {
        add $target --follow
        if $env.LAST_EXIT_CODE == 0 {
            $success_count = $success_count + 1
            print $"(ansi green)✓ hypr/($config) migrated(ansi reset)"
        } else {
            $failed_count = $failed_count + 1
            print $"(ansi red)✗ hypr/($config) failed(ansi reset)"
        }
    } else {
        print $"(ansi yellow)⚠ hypr/($config) not found at target, skipping(ansi reset)"
    }
}

# monitor.nu
if ($"($hypr_dir)/monitor.nu" | path exists) {
    add $"($hypr_dir)/monitor.nu" --follow
    if $env.LAST_EXIT_CODE == 0 {
        $success_count = $success_count + 1
        print $"(ansi green)✓ hypr/monitor.nu migrated(ansi reset)"
    } else {
        $failed_count = $failed_count + 1
        print $"(ansi red)✗ hypr/monitor.nu failed(ansi reset)"
    }
} else {
    print $"(ansi yellow)⚠ hypr/monitor.nu not found at target, skipping(ansi reset)"
}

# shaders/ directory
if ($"($hypr_dir)/shaders" | path type) == "dir" {
    add $"($hypr_dir)/shaders" --follow --recursive
    if $env.LAST_EXIT_CODE == 0 {
        $success_count = $success_count + 1
        print $"(ansi green)✓ hypr/shaders/ directory migrated(ansi reset)"
    } else {
        $failed_count = $failed_count + 1
        print $"(ansi red)✗ hypr/shaders/ failed(ansi reset)"
    }
} else {
    print $"(ansi yellow)⚠ hypr/shaders/ not found at target, skipping(ansi reset)"
}
print ""

# ==============================================================================
# Zellij
# ==============================================================================
print $"(ansi green_bold)3. Zellij(ansi reset)"
print $"(ansi yellow)Note: zjstatus.wasm needs to be downloaded separately(ansi reset)"

let zellij_dir = $"($nu.home-dir)/.config/zellij"

# config.kdl
if ($"($zellij_dir)/config.kdl" | path exists) {
    add $"($zellij_dir)/config.kdl" --follow
    if $env.LAST_EXIT_CODE == 0 {
        $success_count = $success_count + 1
        print $"(ansi green)✓ zellij/config.kdl migrated(ansi reset)"
    } else {
        $failed_count = $failed_count + 1
        print $"(ansi red)✗ zellij/config.kdl failed(ansi reset)"
    }
} else {
    print $"(ansi yellow)⚠ zellij/config.kdl not found at target, skipping(ansi reset)"
}

# layouts/ directory
if ($"($zellij_dir)/layouts" | path type) == "dir" {
    add $"($zellij_dir)/layouts" --follow --recursive
    if $env.LAST_EXIT_CODE == 0 {
        $success_count = $success_count + 1
        print $"(ansi green)✓ zellij/layouts/ directory migrated(ansi reset)"
    } else {
        $failed_count = $failed_count + 1
        print $"(ansi red)✗ zellij/layouts/ failed(ansi reset)"
    }
} else {
    print $"(ansi yellow)⚠ zellij/layouts/ not found at target, skipping(ansi reset)"
}

# themes/ directory
if ($"($zellij_dir)/themes" | path type) == "dir" {
    add $"($zellij_dir)/themes" --follow --recursive
    if $env.LAST_EXIT_CODE == 0 {
        $success_count = $success_count + 1
        print $"(ansi green)✓ zellij/themes/ directory migrated(ansi reset)"
    } else {
        $failed_count = $failed_count + 1
        print $"(ansi red)✗ zellij/themes/ failed(ansi reset)"
    }
} else {
    print $"(ansi yellow)⚠ zellij/themes/ not found at target, skipping(ansi reset)"
}

# zjstatus.wasm download info
print $"(ansi gray)→ zjstatus.wasm will be downloaded via chezmoi hook(ansi reset)"
print ""

# ==============================================================================
# Quickshell
# ==============================================================================
print $"(ansi green_bold)4. Quickshell(ansi reset)"

let quickshell_dir = $"($nu.home-dir)/.config/quickshell"

# shell.qml
if ($"($quickshell_dir)/shell.qml" | path exists) {
    add $"($quickshell_dir)/shell.qml" --follow
    if $env.LAST_EXIT_CODE == 0 {
        $success_count = $success_count + 1
        print $"(ansi green)✓ quickshell/shell.qml migrated(ansi reset)"
    } else {
        $failed_count = $failed_count + 1
        print $"(ansi red)✗ quickshell/shell.qml failed(ansi reset)"
    }
} else {
    print $"(ansi yellow)⚠ quickshell/shell.qml not found at target, skipping(ansi reset)"
}

# u/ directory
if ($"($quickshell_dir)/u" | path type) == "dir" {
    add $"($quickshell_dir)/u" --follow --recursive
    if $env.LAST_EXIT_CODE == 0 {
        $success_count = $success_count + 1
        print $"(ansi green)✓ quickshell/u/ directory migrated(ansi reset)"
    } else {
        $failed_count = $failed_count + 1
        print $"(ansi red)✗ quickshell/u/ failed(ansi reset)"
    }
} else {
    print $"(ansi yellow)⚠ quickshell/u/ not found at target, skipping(ansi reset)"
}
print ""

# ==============================================================================
# Foot
# ==============================================================================
print $"(ansi green_bold)5. Foot(ansi reset)"

let foot_dir = $"($nu.home-dir)/.config/foot"

# Get all foot config files
if ($foot_dir | path exists) {
    try {
        let foot_files = (ls $foot_dir | where type == file | get name)
        for $file in $foot_files {
            let target = $"($foot_dir)/($file)"
            add $target --follow
            if $env.LAST_EXIT_CODE == 0 {
                $success_count = $success_count + 1
                print $"(ansi green)✓ foot/($file) migrated(ansi reset)"
            } else {
                $failed_count = $failed_count + 1
                print $"(ansi red)✗ foot/($file) failed(ansi reset)"
            }
        }
    } catch {
        print $"(ansi yellow)⚠ foot/ directory listing failed, skipping(ansi reset)"
    }
} else {
    print $"(ansi yellow)⚠ foot/ not found at target, skipping(ansi reset)"
}
print ""

# ==============================================================================
# Yazi
# ==============================================================================
print $"(ansi green_bold)6. Yazi(ansi reset)"

let yazi_dir = $"($nu.home-dir)/.config/yazi"

# yazi.toml
if ($"($yazi_dir)/yazi.toml" | path exists) {
    add $"($yazi_dir)/yazi.toml" --follow
    if $env.LAST_EXIT_CODE == 0 {
        $success_count = $success_count + 1
        print $"(ansi green)✓ yazi/yazi.toml migrated(ansi reset)"
    } else {
        $failed_count = $failed_count + 1
        print $"(ansi red)✗ yazi/yazi.toml failed(ansi reset)"
    }
} else {
    print $"(ansi yellow)⚠ yazi/yazi.toml not found at target, skipping(ansi reset)"
}

# init.lua
if ($"($yazi_dir)/init.lua" | path exists) {
    add $"($yazi_dir)/init.lua" --follow
    if $env.LAST_EXIT_CODE == 0 {
        $success_count = $success_count + 1
        print $"(ansi green)✓ yazi/init.lua migrated(ansi reset)"
    } else {
        $failed_count = $failed_count + 1
        print $"(ansi red)✗ yazi/init.lua failed(ansi reset)"
    }
} else {
    print $"(ansi yellow)⚠ yazi/init.lua not found at target, skipping(ansi reset)"
}
print ""

# ==============================================================================
# Fastfetch
# ==============================================================================
print $"(ansi green_bold)7. Fastfetch(ansi reset)"

let fastfetch_dir = $"($nu.home-dir)/.config/fastfetch"

# config.jsonc
if ($"($fastfetch_dir)/config.jsonc" | path exists) {
    add $"($fastfetch_dir)/config.jsonc" --follow
    if $env.LAST_EXIT_CODE == 0 {
        $success_count = $success_count + 1
        print $"(ansi green)✓ fastfetch/config.jsonc migrated(ansi reset)"
    } else {
        $failed_count = $failed_count + 1
        print $"(ansi red)✗ fastfetch/config.jsonc failed(ansi reset)"
    }
} else {
    print $"(ansi yellow)⚠ fastfetch/config.jsonc not found at target, skipping(ansi reset)"
}

# config-tty.jsonc
if ($"($fastfetch_dir)/config-tty.jsonc" | path exists) {
    add $"($fastfetch_dir)/config-tty.jsonc" --follow
    if $env.LAST_EXIT_CODE == 0 {
        $success_count = $success_count + 1
        print $"(ansi green)✓ fastfetch/config-tty.jsonc migrated(ansi reset)"
    } else {
        $failed_count = $failed_count + 1
        print $"(ansi red)✗ fastfetch/config-tty.jsonc failed(ansi reset)"
    }
} else {
    print $"(ansi yellow)⚠ fastfetch/config-tty.jsonc not found at target, skipping(ansi reset)"
}

# ascii.txt
if ($"($fastfetch_dir)/ascii.txt" | path exists) {
    add $"($fastfetch_dir)/ascii.txt" --follow
    if $env.LAST_EXIT_CODE == 0 {
        $success_count = $success_count + 1
        print $"(ansi green)✓ fastfetch/ascii.txt migrated(ansi reset)"
    } else {
        $failed_count = $failed_count + 1
        print $"(ansi red)✗ fastfetch/ascii.txt failed(ansi reset)"
    }
} else {
    print $"(ansi yellow)⚠ fastfetch/ascii.txt not found at target, skipping(ansi reset)"
}
print ""

# ==============================================================================
# Summary
# ==============================================================================
print ""
print $"(ansi cyan_bold)Migration Summary(ansi reset)"
print $"(ansi green)✓(ansi reset) Successfully migrated: (ansi cyan_bold)($success_count)(ansi reset)"
if $failed_count > 0 {
    print $"(ansi red)✗(ansi reset) Failed to migrate: (ansi red_bold)($failed_count)(ansi reset)"
}
print ""
print $"(ansi gray)Run 'nu install.nu' to apply all configurations(ansi reset)"
print $"(ansi gray)See .chezmoi.post-apply.nu for post-link setup (e.g., zjstatus.wasm)(ansi reset)"
