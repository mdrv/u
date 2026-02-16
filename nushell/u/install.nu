# ANNOTATION: Replacement for symlinks.nu - installs chezmoi-managed configurations
# Maintains compatibility with symlinks.nu API (same app_name completion)
# Single command to install all or specific tools

# Import chezmoi wrapper
use ./chezmoi.nu *

# App completion for supported tools
def app_completion [] {
    {
        completions: (get-managed-tools)
    }
}

# Map tool names to their target paths (for reference)
const TARGET_MAP = {
    nvim: "~/.config/nvim"
    nushell: "~/.config/nushell"
    kitty: "~/.config/kitty"
    foot: "~/.config/foot"
    hypr: "~/.config/hypr"
    waybar: "~/.config/waybar"
    dunst: "~/.config/dunst"
    tofi: "~/.config/tofi"
    yazi: "~/.config/yazi"
    zellij: "~/.config/zellij"
    atuin: "~/.config/atuin"
    aichat: "~/.config/aichat"
    fastfetch: "~/.config/fastfetch"
    crush: "~/.config/crush"
    home: "~"
    neovide: "~/.config/neovide"
    opencode: "~/.config/opencode"
    quickshell: "~/.config/quickshell"
    otd: "~/.config/OpenTabletDriver/Presets"
    keyd: "~/.config/keyd"
}

# Get target path for a specific tool
def get-target-path [app_name: string] {
    $TARGET_MAP | get --optional $app_name
}

# Apply configurations for specific tool(s)
export def main [
    ...tools: string@app_completion  # Tool(s) to install (empty = install all)
    --dry-run (-d)              # Show what would be applied without doing it
    --verbose (-v)                # Show detailed output
] {
    if not (is-chezmoi-installed) {
        error make {
            msg: "chezmoi is not installed"
            label: {
                text: "Install chezmoi"
                span: (metadata $env).shell.span
                url: "https://chezmoi.io/get/"
            }
        }
    }

    # If no tools specified, apply all
    if ($tools | is-empty) {
        print $"(ansi green_bold)Installing all configurations...(ansi reset)"
        print ""

        if $dry_run {
            print $"(ansi yellow)Dry run mode - no changes will be made(ansi reset)"
            print ""
            ^chezmoi apply --dry-run
        } else {
            apply --verbose=$verbose
        }

        return
    }

    # Install specific tools
    for $tool in $tools {
        print $"(ansi green_bold)Installing (ansi cyan)($tool)(ansi green_bold) configurations...(ansi reset)"
        let target = (get-target-path $tool)
        print $"  Target: (ansi yellow)($target)(ansi reset)"

        if $dry_run {
            print $"  (ansi yellow)Dry run mode(ansi reset)"
            print ""
            continue
        }

        # Apply and check if the tool's config exists
        apply --verbose=$verbose

        if ($target | path type) == "dir" {
            print $"  (ansi green)✓ Configurations applied to ($target)(ansi reset)"
        } else if ($target | path type) == "file" {
            print $"  (ansi green)✓ Configuration applied to ($target)(ansi reset)"
        } else {
            print $"  (ansi yellow)⚠ Warning: Target ($target) does not exist yet(ansi reset)"
        }

        print ""
    }
}

# Show available tools
export def list [] {
    print $"(ansi cyan)Available managed tools:(ansi reset)"
    print ""

    for $tool in (get-managed-tools) {
        let target = (get-target-path $tool)
        print $"  (ansi green)•(ansi reset) (ansi cyan)($tool | str rpad 15)(ansi reset) → (ansi yellow)($target)(ansi reset)"
    }

    print ""
    print $"Usage: (ansi cyan)install (ansi yellow)<tool_name>(ansi reset) or (ansi cyan)install(ansi reset) for all"
}
