# Wallpaper dispatcher for Hyprland submap
# This script is called by specific submap keys (D/F)

export def main [
    --default (-d) # Set default wallpaper from ~/.u.nuon WP.DEFAULT
] {
    let config_path = $"($nu.home-dir)/.u.nuon"

    if not ($config_path | path exists) {
        ^dunstify -u critical -t 2000 "Error" "~/.u.nuon not found"
        return
    }

    let config = open $config_path

    if $default {
        let default_wp = $config.WP.DEFAULT

        if not ($default_wp | path exists) {
            ^dunstify -u critical -t 2000 "Error" $"Default wallpaper not found:\n($default_wp)"
            return
        }

        # Set default wallpaper
        use ($nu.default-config-dir + /u/hypr-wp.nu)
        hypr-wp $default_wp --persist

        ^dunstify -t 2000 "Wallpaper" $"Set to default\n($default_wp | path basename)"
    } else {
        # Open full wallpaper selection
        use ($nu.default-config-dir + /u/hypr-wp.nu)
        hypr-wp
    }
}
