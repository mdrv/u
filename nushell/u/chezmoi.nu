# ANNOTATION: Core wrapper for chezmoi commands providing convenient interface
# Provides commonly used chezmoi operations with helpful messages and error handling

use std "assert"

# Constant for chezmoi config directory
const CHEZMOI_DIR = ($nu.home-dir | path join ".local/share/chezmoi")

# Check if chezmoi is installed
export def is-chezmoi-installed []: nothing -> bool {
    (which chezmoi | is-not-empty)
}

# Get list of managed tools from original symlinks.nu DATA constant
export def get-managed-tools []: nothing -> list<string> {
    [
        "nvim"
        "nushell"
        "kitty"
        "foot"
        "hypr"
        "waybar"
        "dunst"
        "tofi"
        "yazi"
        "zellij"
        "atuin"
        "aichat"
        "fastfetch"
        "crush"
        "home"
        "neovide"
        "opencode"
        "quickshell"
        "otd"
        "keyd"
    ]
}

# Apply all managed configurations
export def apply [
    --verbose (-v)  # Show detailed chezmoi output
] {
    if not (is-chezmoi-installed) {
        error make {
            msg: "chezmoi is not installed. Install it first."
            label: {
                text: "Installation guide"
                span: (metadata $env).shell.span
                url: "https://chezmoi.io/get/"
            }
        }
    }

    print $"(ansi green_bold)Applying chezmoi configurations...(ansi reset)"
    print ""

    let args = if $verbose { ["--verbose"] } else { [] }
    chezmoi apply ...$args

    if $env.LAST_EXIT_CODE == 0 {
        print ""
        print $"(ansi green)✓ All configurations applied successfully(ansi reset)"
    } else {
        print ""
        error make { msg: "Failed to apply chezmoi configurations" }
    }
}

# Add a file or directory to chezmoi
export def add [
    path: path           # Path to add (relative to home or absolute)
    --template (-t)      # Add as template
    --follow (-f)        # Follow symlinks (for migration)
    --recursive (-r)     # Add directories recursively
] {
    if not (is-chezmoi-installed) {
        error make { msg: "chezmoi is not installed" }
    }

    mut args = []
    if $template { $args = ($args | append ["--template"]) }
    if $follow { $args = ($args | append ["--follow"]) }
    if $recursive { $args = ($args | append ["--recursive"]) }

    print $"(ansi cyan)Adding (ansi yellow)($path)(ansi cyan) to chezmoi...(ansi reset)"
    chezmoi add $path ...$args

    if $env.LAST_EXIT_CODE == 0 {
        print $"(ansi green)✓ Added (ansi yellow)($path)(ansi reset)"
    } else {
        error make { msg: $"Failed to add ($path) to chezmoi" }
    }
}

# Edit a managed file
export def edit [
    file: path          # File to edit
] {
    if not (is-chezmoi-installed) {
        error make { msg: "chezmoi is not installed" }
    }

    chezmoi edit $file
}

# Verify all managed files are in sync
export def verify [
    --verbose (-v)
] {
    if not (is-chezmoi-installed) {
        error make { msg: "chezmoi is not installed" }
    }

    print $"(ansi cyan)Verifying chezmoi state...(ansi reset)"
    print ""

    let args = if $verbose { ["--verbose"] } else { [] }
    chezmoi verify ...$args

    if $env.LAST_EXIT_CODE == 0 {
        print ""
        print $"(ansi green)✓ All files are in sync(ansi reset)"
    } else {
        print ""
        print $"(ansi yellow)Some files are out of sync. Run 'chezmoi apply' to fix.(ansi reset)"
    }
}

# Run chezmoi doctor to check system
export def doctor [] {
    if not (is-chezmoi-installed) {
        error make { msg: "chezmoi is not installed" }
    }

    print $"(ansi cyan)Running chezmoi doctor...(ansi reset)"
    chezmoi doctor
}

# List all managed files
export def managed [
    --json  # Output in JSON format
] {
    if not (is-chezmoi-installed) {
        error make { msg: "chezmoi is not installed" }
    }

    let args = if $json { ["--format", "json"] } else { [] }
    chezmoi managed ...$args
}

# Run arbitrary chezmoi command with remaining args
export def run [
    ...args: string    # Arguments to pass to chezmoi
] {
    if not (is-chezmoi-installed) {
        error make { msg: "chezmoi is not installed" }
    }

    chezmoi ...$args
}

# Show help
export def main [] {
    print $"(ansi cyan)chezmoi.nu - Nushell wrapper for chezmoi(ansi reset)"
    print ""
    print "Available commands:"
    print "  apply       Apply all configurations to home directory"
    print "  add         Add a file or directory to chezmoi"
    print "  edit        Edit a managed file"
    print "  verify      Verify all managed files are in sync"
    print "  doctor      Run chezmoi diagnostics"
    print "  managed     List all managed files"
    print "  run         Run arbitrary chezmoi command"
    print ""
    print "See also: install.nu, add.nu, status.nu"
}
