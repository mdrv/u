export def main [...bins] {
    let $missing = ($bins | where {|x| which $x | is-empty })
    if ($missing | is-not-empty) {
        let $msg = $"($missing | str join ' ') is not installed!"
        if (which notify-send | is-not-empty) {
            notify-send -t 5000 -u critical $msg
        }
        error make {msg: $msg}
    }
}
