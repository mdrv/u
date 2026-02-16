# ANNOTATION: Show managed configurations and their status
# Provides overview of what's managed by chezmoi and sync state

use std "format"

# Import chezmoi wrapper
use nushell/u/chezmoi.nu *

# Parse chezmoi managed output into structured data
def parse-managed-output [output: string]: list<record<name: string, type: string, target: string>> {
    $output
    | lines
    | where {|line| $line != "" and not ($line | str starts-with "chezmoi") }
    | each {|line|
        let parts = $line | str split " "
        if ($parts | length) >= 2 {
            let target = $parts | skip 1 | str join " "
            let name = $target | path basename
            let type = if ($target | path type) == "dir" { "dir" } else { "file" }
            { name: $name, type: $type, target: $target }
        } else {
            null
        }
    }
    | where {|item| $item != null }
}

# Show status of managed configurations
export def main [
    --json (-j)                      # Output in JSON format
    --verbose (-v)                    # Show detailed information
] {
    if not (is-chezmoi-installed) {
        error make { msg: "chezmoi is not installed" }
    }

    print $"(ansi cyan)Chezmoi Managed Configurations(ansi reset)"
    print ""

    # Get managed files
    let managed_output = (managed --json)
    let managed = if $managed_output == "" {
        []
    } else {
        $managed_output | from json
    }

    if ($managed | is-empty) {
        print $"(ansi yellow)⚠ No files are currently managed by chezmoi(ansi reset)"
        print ""
        print $"(ansi gray)Use 'nu add.nu <path>' to add configurations(ansi reset)"
        return
    }

    # Count by type
    let file_count = ($managed | where type == "file" | length)
    let dir_count = ($managed | where type == "dir" | length)

    # Show summary
    print $"(ansi green)Total:(ansi reset) ($managed | length) items"
    print $"  (ansi cyan)Files: (ansi white)($file_count)(ansi reset)"
    print $"  (ansi cyan)Directories: (ansi white)($dir_count)(ansi reset)"
    print ""

    # Group by common locations
    let by_category = $managed | group-by { |item|
        let target = $item.target
        if ($target | str contains ".config/nvim") { "nvim" }
        else if ($target | str contains ".config/nushell") { "nushell" }
        else if ($target | str contains ".config/kitty") { "kitty" }
        else if ($target | str contains ".config/hypr") { "hypr" }
        else if ($target | str contains ".config/waybar") { "waybar" }
        else if ($target | str contains ".config/zellij") { "zellij" }
        else if ($target | str contains ".config/foot") { "foot" }
        else if ($target | str contains ".config/tofi") { "tofi" }
        else if ($target | str contains ".config/yazi") { "yazi" }
        else if ($target | str contains ".config/dunst") { "dunst" }
        else if ($target | str contains ".config/atuin") { "atuin" }
        else if ($target | str contains ".config/aichat") { "aichat" }
        else if ($target | str contains ".config/fastfetch") { "fastfetch" }
        else if ($target | str contains ".config/neovide") { "neovide" }
        else if ($target | str contains ".config/opencode") { "opencode" }
        else if ($target | str contains ".config/quickshell") { "quickshell" }
        else if ($target | str contains ".config/keyd") { "keyd" }
        else if ($target | str contains ".gitconfig") { "git" }
        else if ($target | str contains "OpenTabletDriver") { "otd" }
        else { "other" }
    }

    # Show by category
    for category in (["nvim", "nushell", "kitty", "foot", "hypr", "waybar", "dunst", "tofi", "yazi", "zellij", "atuin", "aichat", "fastfetch", "neovide", "opencode", "quickshell", "keyd", "git", "otd", "other"]) {
        let items = $by_category | get -i $category -i null
        if $items != null {
            let items_list = $items
            let count = ($items_list | length)

            if $count > 0 {
                print $"(ansi green_bold)($category | str rpad 20)(ansi reset) ($count | str rpad 4) item(s)"

                if $verbose {
                    for item in $items_list {
                        print $"  (ansi cyan)•(ansi reset) (ansi yellow)($item.name)(ansi reset)"
                        print $"    (ansi gray)→ ($item.target)(ansi reset)"
                    }
                }
            }
        }
    }

    print ""
    print $"(ansi gray)Use 'nu chezmoi.nu verify' to check sync status(ansi reset)"
    print $"(ansi gray)Use 'nu install.nu' to apply changes(ansi reset)"
}

# Quick status check
export def quick [] {
    if not (is-chezmoi-installed) {
        error make { msg: "chezmoi is not installed" }
    }

    let managed_output = (managed --json)
    let managed = if $managed_output == "" {
        []
    } else {
        $managed_output | from json
    }

    let count = ($managed | length)

    if $count == 0 {
        print $"(ansi red)✗(ansi reset) No configs managed"
    } else {
        print $"(ansi green)✓(ansi reset) ($count) config(s) managed"
    }
}
    }
    | where {|item| $item != null }
}

# Show status of managed configurations
export def main [
    --json (-j)                      # Output in JSON format
    --verbose (-v)                    # Show detailed information
] {
    if not (is-chezmoi-installed) {
        error make { msg: "chezmoi is not installed" }
    }

    print $"(ansi cyan)Chezmoi Managed Configurations(ansi reset)"
    print ""

    # Get managed files
    let managed_output = (managed --json)
    let managed = if $managed_output == "" {
        []
    } else {
        $managed_output | from json
    }

    if ($managed | is-empty) {
        print $"(ansi yellow)⚠ No files are currently managed by chezmoi(ansi reset)"
        print ""
        print $"(ansi gray)Use 'nu add.nu <path>' to add configurations(ansi reset)"
        return
    }

    # Count by type
    let file_count = ($managed | where type == "file" | length)
    let dir_count = ($managed | where type == "dir" | length)

    # Show summary
    print $"(ansi green)Total:(ansi reset) ($managed | length) items"
    print $"  (ansi cyan)Files: (ansi white)($file_count)(ansi reset)"
    print $"  (ansi cyan)Directories: (ansi white)($dir_count)(ansi reset)"
    print ""

    # Group by common locations
    let by_category = $managed | group-by { |item|
        let target = $item.target
        if ($target | str contains ".config/nvim") { "nvim" }
        else if ($target | str contains ".config/nushell") { "nushell" }
        else if ($target | str contains ".config/kitty") { "kitty" }
        else if ($target | str contains ".config/hypr") { "hypr" }
        else if ($target | str contains ".config/waybar") { "waybar" }
        else if ($target | str contains ".config/zellij") { "zellij" }
        else if ($target | str contains ".config/foot") { "foot" }
        else if ($target | str contains ".config/tofi") { "tofi" }
        else if ($target | str contains ".config/yazi") { "yazi" }
        else if ($target | str contains ".config/dunst") { "dunst" }
        else if ($target | str contains ".config/atuin") { "atuin" }
        else if ($target | str contains ".config/aichat") { "aichat" }
        else if ($target | str contains ".config/fastfetch") { "fastfetch" }
        else if ($target | str contains ".config/neovide") { "neovide" }
        else if ($target | str contains ".config/opencode") { "opencode" }
        else if ($target | str contains ".config/quickshell") { "quickshell" }
        else if ($target | str contains ".config/keyd") { "keyd" }
        else if ($target | str contains ".gitconfig") { "git" }
        else if ($target | str contains "OpenTabletDriver") { "otd" }
        else { "other" }
    }

    # Show by category
    for category in (["nvim", "nushell", "kitty", "foot", "hypr", "waybar", "dunst", "tofi", "yazi", "zellij", "atuin", "aichat", "fastfetch", "neovide", "opencode", "quickshell", "keyd", "git", "otd", "other"]) {
        let items = $by_category | get -i $category -i null
        if $items != null {
            let items_list = $items
            let count = ($items_list | length)

            if $count > 0 {
                print $"(ansi green_bold)($category | str rpad 20)(ansi reset) ($count | str rpad 4) item(s)"

                if $verbose {
                    for item in $items_list {
                        print $"  (ansi cyan)•(ansi reset) (ansi yellow)($item.name)(ansi reset)"
                        print $"    (ansi gray)→ ($item.target)(ansi reset)"
                    }
                }
            }
        }
    }

    print ""
    print $"(ansi gray)Use 'nu chezmoi.nu verify' to check sync status(ansi reset)"
    print $"(ansi gray)Use 'nu install.nu' to apply changes(ansi reset)"
}

# Quick status check
export def quick [] {
    if not (is-chezmoi-installed) {
        error make { msg: "chezmoi is not installed" }
    }

    let managed_output = (managed --json)
    let managed = if $managed_output == "" {
        []
    } else {
        $managed_output | from json
    }

    let count = ($managed | length)

    if $count == 0 {
        print $"(ansi red)✗(ansi reset) No configs managed"
    } else {
        print $"(ansi green)✓(ansi reset) ($count) config(s) managed"
    }
}
