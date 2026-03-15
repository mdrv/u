export def main [
    --type (-t): string
] {
    if ($type == 'ulid') {
        if (which ulid | is-empty) {
            print $"(ansi bb)📢 ulid (ansi y)is not installed!(ansi reset)"
            ^dunstify -u critical -t 1000 "ulid binary is not installed!"
            return
        }
        let $str = (ulid | str trim)
        $str | wl-copy
        ^dunstify -u low -t 1000 $"Copied: ($str)"
    } else if ($type == 'iso') {
        let $str = (date now | date to-timezone '+0000' | format date '%Y-%m-%dT%H:%M:%SZ')
        $str | wl-copy
        ^dunstify -u low -t 1000 $"Copied: ($str)"
    } else if ($type == 'time') {
        let $str = (date now | date to-timezone local | format date '%Y%m%d-%H%M%S')
        $str | wl-copy
        ^dunstify -u low -t 1000 $"Copied: ($str)"
    } else if ($type == 'epoch') {
        let $str = (date now | format date '%s')
        $str | wl-copy
        ^dunstify -u low -t 1000 $"Copied: ($str)"
	}
}
