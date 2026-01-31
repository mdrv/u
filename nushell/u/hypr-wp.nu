use ($nu.default-config-dir + /u/error-if.nu)
use ($nu.default-config-dir + /u/assert-missing.nu)
const u = $"($nu.default-config-dir)/u"
alias eif = error-if

export def main [
    n?: any
    --persist (-p) # save to hyprpaper.conf
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
            let $l = (glob "/x/b/*.{avif,jxl}")
            let $preview = $"use ($u)/chafa-fzf.nu; clear; chafa-fzf {}"
            let $fzfs = ($l | str join "\n")
            let $bind = ([
                $"enter:execute-silent\(use ($u)/hypr-wp.nu; hypr-wp {})+change-preview-label\((ansi pb)CHANGED(ansi reset))"
                $"tab:execute-silent\(use ($u)/hypr-wp.nu; hypr-wp -p {})+change-preview-label\((ansi gb)CHANGED + SAVED(ansi reset))"
            ] | str join ",")
            $fzfs | ^fzf ...[
                --ansi
                --color
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
