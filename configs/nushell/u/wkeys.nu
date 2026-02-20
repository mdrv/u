#!/usr/bin/env -S nu
# Toggle wkeys between bottom-left and bottom-right positions using CSS margins

const STYLE_LEFT = $"($nu.home-dir)/.config/wkeys/style-left.css"
const STYLE_RIGHT = $"($nu.home-dir)/.config/wkeys/style-right.css"
const STATE_FILE = "/tmp/wkeys-position"

def get_current_style []: nothing -> string {
    if ($STATE_FILE | path exists) {
        let state = (open $STATE_FILE)
        if $state == "left" {
            $STYLE_LEFT
        } else {
            $STYLE_RIGHT
        }
    } else {
        $STYLE_LEFT
    }
}

def save_state [pos: string] {
    $pos | save -f $STATE_FILE
}

export def main [pos?: string] {
    # Dispatch based on argument
    match $pos {
        "left" => {
            print "Switching wkeys to left"
            left
        }
        "right" => {
            print "Switching wkeys to right"
            right
        }
        _ => {
            # Default: toggle
            print "Toggling wkeys position"
            toggle
        }
    }
}

def toggle [] {
    let $current = (get_current_style)
    let $new_style = if ($current | path basename) == "style-left.css" {
        $STYLE_RIGHT
    } else {
        $STYLE_LEFT
    }

    # Save state
    if ($new_style | path basename) == "style-left.css" {
        save_state "left"
    } else {
        save_state "right"
    }

    # Restart wkeys using job spawn
    pkill wkeys | ignore
    wkeys -s $new_style
}

def left [] {
    save_state "left"
    pkill wkeys | ignore
    print "Switching wkeys to style-left.css"
    wkeys -s $STYLE_LEFT
}

def right [] {
    save_state "right"
    pkill wkeys | ignore
    print "Switching wkeys to style-right.css"
    wkeys -s $STYLE_RIGHT
}
