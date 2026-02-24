use ($nu.default-config-dir + /u/error-if.nu)
use ($nu.default-config-dir + /u/assert-missing.nu)
const u = $"($nu.default-config-dir)/u"
alias eif = error-if

# Get wallpaper list from ~/.u.nuon WP.LIST property
export def get-wp-list [] {
    let config_path = $"($nu.home-dir)/.u.nuon"
    if not ($config_path | path exists) {
        return []
    }

    let config = try { open $config_path } catch { return [] }
    if ($config | get --optional WP --optional LIST | is-empty) {
        return []
    }

    $config.WP.LIST
}

export def main [
    n?: any
    --persist (-p) # save to hyprpaper.conf
    --all (-a) # list all /x/b/*.{avif,jxl} instead of WP.LIST
] {
    assert-missing fzf chafa vipsthumbnail magick
    let $_type = ($n | describe -n)
    let $p = match $_type {
        # int => {$"/x/m/wp-($n | into string | fill -a r -c 0 -w 2)*" | into glob}
        string => $n
        nothing => {
            # H: No AVIF support on hyprgraphics
            # l: https://github.com/hyprwm/hyprgraphics/issues/16
            # l: https://github.com/hyprwm/hyprpaper/issues/53

            # Get wallpaper list based on --all flag
            let $wp_list = if $all {
                # Full /x/b listing
                glob "/x/b/*.{avif,jxl}"
            } else {
                # Try WP.LIST from ~/.u.nuon first
                let $list = get-wp-list
                if ($list | length) > 0 {
                    $list | each {|row|
                        let path = $row.path
                        let aliases = if ($row | get --optional aliases | is-empty) {[]} else {$row.aliases}
                        # Add aliases to display name
                        if ($aliases | length) > 0 {
                            let alias_str = ($aliases | str join ', ')
                            $"($path) \e[2m($alias_str)\e[0m"
                        } else {
                            $path
                        }
                    }
                } else {
                    # Fallback to full listing if WP.LIST is empty
                    glob "/x/b/*.{avif,jxl}"
                }
            }

            let $preview = $"use ($u)/chafa-fzf.nu; clear; chafa-fzf {1}"
            let $fzfs = ($wp_list | str join "\n")

            # Build fzf bindings
            # enter: change wallpaper
            # tab: change + save persist
            # shift-tab: copy path to clipboard
            # ctrl-a: toggle --all mode (restart with opposite mode)
            # ctrl-c: copy path to clipboard and exit fzf
            let $toggle_all_flag = if $all { "" } else { "--all" }
            let $bind = ([
				$"enter:execute-silent\(use ($u)/hypr-wp.nu; hypr-wp {1})+change-preview-label\((ansi pb)CHANGED(ansi reset))"
                $"tab:execute-silent\(use ($u)/hypr-wp.nu; hypr-wp -p {1})+change-preview-label\((ansi gb)CHANGED + SAVED(ansi reset))"
				$"shift-tab:execute-silent\(echo {1} | wl-copy)+change-preview-label\((ansi cb)COPIED TO CLIPBOARD(ansi reset))"
                $"ctrl-a:become\(nu -n ($u)/hypr-wp.nu ($toggle_all_flag))"
            ] | str join ",")

            # Display mode indicator
            let $mode_label = if $all {
                [ [(ansi yellow_bold), "FULL MODE"], [(ansi reset), " - Press "], [(ansi cyan), "CTRL-A"], [(ansi reset), " for list mode"] ] | flatten | str join
            } else {
                [ [(ansi green_bold), "LIST MODE"], [(ansi reset), " - Press "], [(ansi cyan), "CTRL-A"], [(ansi reset), " for full mode"] ] | flatten | str join
            }

            # Add header to show current mode
            let $header = $"($mode_label)\n($fzfs)"

            $header | ^fzf ...[
                --ansi
                --color
                --header-lines 1
                --bind $bind
                --preview $preview
                --preview-window 75%
                --reverse
                --cycle
                --min-height=24
            ]
        }
        _ => {error make {msg: $"($_type) type not supported!"}}
    }
    let $_p = (ls $p | get 0.name)
    # H: No AVIF supprort on hyprgraphics
    # l: https://github.com/hyprwm/hyprgraphics/issues/16
    # l: https://github.com/hyprwm/hyprpaper/issues/53
    let $p = if ($_p | path parse | get extension) == 'avif' {
        let $monitor = ( hyprctl monitors -j | from json | select width height | get 0 )
        let $dir = $"($nu.home-dir)/n/img/jxl"
        if not ($dir | path exists) { mkdir $dir }
        let $jxl = ($_p | path parse | update parent $dir | update extension $"($monitor.width)x($monitor.height).jxl" | path join)
        if not ($jxl | path exists) {
            ^magick $_p -filter Mitchell -resize $"($monitor.width)x($monitor.height)^" $jxl # Might result in bigger file size...
        }
        $jxl
    } else {$_p}
    if not ($p | path exists) {
        ^dunstify -u critical -t 1000 "Path does not exist!"
        return
    }
    ^hyprctl hyprpaper unload all | ignore
    ^hyprctl hyprpaper preload $p | ignore
    ^hyprctl hyprpaper wallpaper $",($p)" | ignore

    if $persist {
        [
			"splash = false"
			"ipc = true"
			""
			"wallpaper {"
			"	monitor ="
            $"    path = ($p)"
            $"    fit_mode = cover"
            "}"
        ] | save -f ~/.config/hypr/hyprpaper.conf
        print $"(ansi bb)hyprpaper.conf(ansi gb) updated(ansi reset)"
    }
}
