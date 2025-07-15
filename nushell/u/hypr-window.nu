use ($nu.default-config-dir + /u/assert-missing.nu)

# v20240000
# Window switcher
# TODO: Use foot + fzf
export def main [--tmp: string, --exec (-x)] {
    assert-missing hyprctl tofi awk

    let state = (^hyprctl -j clients)
    let active_window = (^hyprctl -j activewindow)

    let current_addr = ($active_window | from json | get address -i)

    let window = ($state | from json | where monitor != -1 | par-each {get address workspace.name title | str join " "} | str join "\n" |
        sed $"s|($current_addr | default "unknown")|focused ->|" |
        ^sort -r | tofi --fuzzy-match=true --prompt-text="window: ")

    let addr = ($window | awk '{print $1}')
    let ws = ($window | awk '{print $2}')

    # notify-send -t 2000 ([address: $addr] | str join)
    ^hyprctl dispatch focuswindow ([address: $addr] | str join)
}
