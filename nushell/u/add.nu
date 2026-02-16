# ANNOTATION: Add new configurations to chezmoi with intelligent path detection
# Wraps chezmoi add with sensible defaults for the dotfile repository structure

# Import chezmoi wrapper
use ./chezmoi.nu *

# Detect if path is relative or absolute
def detect-path-type [path: path] -> record<type: string, value: path> {
    if ($path | path expand | str starts-with ($nu.home-dir | path expand)) {
        { type: "home", value: $path }
    } else if ($path | path expand | str starts-with (pwd | path expand)) {
        { type: "repo", value: $path }
    } else {
        { type: "absolute", value: ($path | path expand) }
    }
}

# Convert repo-relative path to home-relative path
def repo-to-home [path: path] -> path {
    let repo_root = (pwd | path expand)
    let expanded_path = ($path | path expand)

    # Remove repo root prefix
    let relative_path = $expanded_path | str replace -r $"^\($repo_root)/" ""

    # Map to appropriate location based on directory structure
    if ($relative_path | str starts-with "nvim/") {
        # nvim/ goes to ~/.config/nvim/lua/
        $relative_path | str replace "nvim/" "" | path expand --no-symlinks | $"~/.config/nvim/lua/($in)"
    } else if ($relative_path | str starts-with "nushell/") {
        # nushell/ goes to ~/.config/nushell/
        $relative_path | str replace "nushell/" "" | path expand --no-symlinks | $"~/.config/nushell/($in)"
    } else if ($relative_path | str starts-with "kitty/") {
        # kitty/ goes to ~/.config/kitty/
        $relative_path | str replace "kitty/" "" | path expand --no-symlinks | $"~/.config/kitty/($in)"
    } else if ($relative_path | str starts-with "hypr/") {
        # hypr/ goes to ~/.config/hypr/
        $relative_path | str replace "hypr/" "" | path expand --no-symlinks | $"~/.config/hypr/($in)"
    } else if ($relative_path | str starts-with "waybar/") {
        # waybar/ goes to ~/.config/waybar/
        $relative_path | str replace "waybar/" "" | path expand --no-symlinks | $"~/.config/waybar/($in)"
    } else if ($relative_path | str starts-with "zellij/") {
        # zellij/ goes to ~/.config/zellij/
        $relative_path | str replace "zellij/" "" | path expand --no-symlinks | $"~/.config/zellij/($in)"
    } else if ($relative_path | str starts-with "foot/") {
        # foot/ goes to ~/.config/foot/
        $relative_path | str replace "foot/" "" | path expand --no-symlinks | $"~/.config/foot/($in)"
    } else if ($relative_path | str starts-with "tofi/") {
        # tofi/ goes to ~/.config/tofi/
        $relative_path | str replace "tofi/" "" | path expand --no-symlinks | $"~/.config/tofi/($in)"
    } else if ($relative_path | str starts-with "yazi/") {
        # yazi/ goes to ~/.config/yazi/
        $relative_path | str replace "yazi/" "" | path expand --no-symlinks | $"~/.config/yazi/($in)"
    } else if ($relative_path | str starts-with "dunst/") {
        # dunst/ goes to ~/.config/dunst/
        $relative_path | str replace "dunst/" "" | path expand --no-symlinks | $"~/.config/dunst/($in)"
    } else if ($relative_path | str starts-with "atuin/") {
        # atuin/ goes to ~/.config/atuin/
        $relative_path | str replace "atuin/" "" | path expand --no-symlinks | $"~/.config/atuin/($in)"
    } else if ($relative_path | str starts-with "aichat/") {
        # aichat/ goes to ~/.config/aichat/
        $relative_path | str replace "aichat/" "" | path expand --no-symlinks | $"~/.config/aichat/($in)"
    } else if ($relative_path | str starts-with "fastfetch/") {
        # fastfetch/ goes to ~/.config/fastfetch/
        $relative_path | str replace "fastfetch/" "" | path expand --no-symlinks | $"~/.config/fastfetch/($in)"
    } else if ($relative_path | str starts-with "neovide/") {
        # neovide/ goes to ~/.config/neovide/
        $relative_path | str replace "neovide/" "" | path expand --no-symlinks | $"~/.config/neovide/($in)"
    } else if ($relative_path | str starts-with "opencode/") {
        # opencode/ goes to ~/.config/opencode/
        $relative_path | str replace "opencode/" "" | path expand --no-symlinks | $"~/.config/opencode/($in)"
    } else if ($relative_path | str starts-with "quickshell/") {
        # quickshell/ goes to ~/.config/quickshell/
        $relative_path | str replace "quickshell/" "" | path expand --no-symlinks | $"~/.config/quickshell/($in)"
    } else if ($relative_path | str starts-with "otd/") {
        # otd/ goes to ~/.config/OpenTabletDriver/Presets/
        $relative_path | str replace "otd/" "" | path expand --no-symlinks | $"~/.config/OpenTabletDriver/Presets/($in)"
    } else if ($relative_path | str starts-with "keyd/") {
        # keyd/ goes to ~/.config/keyd/
        $relative_path | str replace "keyd/" "" | path expand --no-symlinks | $"~/.config/keyd/($in)"
    } else if ($relative_path | str starts-with "home/") {
        # home/ goes to ~
        $relative_path | str replace "home/" "" | path expand --no-symlinks | $"~/($in)"
    } else {
        # Unknown directory, ask user
        error make {
            msg: $"Unknown directory structure for: ($path)"
            label: {
                text: "Please specify target manually"
                span: (metadata $env).shell.span
            }
        }
    }
}

# Add file/directory to chezmoi with path transformation
export def main [
    path: path                       # Path to add (can be repo-relative, home-relative, or absolute)
    --template (-t)                   # Add as template
    --follow (-f)                     # Follow symlinks (for migration)
    --recursive (-r)                  # Add directories recursively
    --exact                           # Add as exact directory (don't expand)
] {
    if not (is-chezmoi-installed) {
        error make { msg: "chezmoi is not installed" }
    }

    let path_info = (detect-path-type $path)
    let chezmoi_path = if $path_info.type == "repo" {
        repo-to-home $path_info.value
    } else {
        $path_info.value
    }

    print $"(ansi cyan)Adding to chezmoi:(ansi reset)"
    print $"  (ansi yellow)Input: (ansi white)($path)(ansi reset)"
    print $"  (ansi yellow)Type: (ansi white)($path_info.type)(ansi reset)"
    print $"  (ansi yellow)Target: (ansi white)($chezmoi_path)(ansi reset)"
    print ""

    # Check if path exists
    if not ($chezmoi_path | path exists) {
        error make {
            msg: $"Target path does not exist: ($chezmoi_path)"
            label: {
                text: "Create the file first"
                span: (metadata $env).shell.span
            }
        }
    }

    # Build args
    let args = []
    if $template { $args = ($args | append ["--template"]) }
    if $follow { $args = ($args | append ["--follow"]) }
    if $recursive { $args = ($args | append ["--recursive"]) }
    if $exact { $args = ($args | append ["--exact"]) }

    # Add to chezmoi
    chezmoi add $chezmoi_path ...$args

    if $env.LAST_EXIT_CODE == 0 {
        print $"(ansi green)✓ Successfully added to chezmoi(ansi reset)"
        print ""
        print $"(ansi gray)Run 'nu install.nu' to apply changes(ansi reset)"
    } else {
        error make { msg: $"Failed to add ($chezmoi_path) to chezmoi" }
    }
}

# Show usage
export def usage [] {
    print $"(ansi cyan)add.nu - Add configurations to chezmoi(ansi reset)"
    print ""
    print "Usage:"
    print "  nu add.nu <path>          Add file or directory"
    print "  nu add.nu <path> --follow  Follow symlinks (for migration)"
    print "  nu add.nu <path> -r       Add directory recursively"
    print "  nu add.nu <path> -t       Add as template"
    print ""
    print "Path types:"
    print "  repo-relative:  kitty/ → ~/.config/kitty/"
    print "  home-relative:  ~/.config/kitty/kitty.conf"
    print "  absolute:       /home/user/.config/kitty/kitty.conf"
}
