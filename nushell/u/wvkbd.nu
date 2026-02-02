# ANNOTATION: Toggle wvkbd between bottom-left and bottom-right positions

const GEOMETRY_LEFT = "50%x60%+0%-60%"
const GEOMETRY_RIGHT = "50%x60%+50%-60%"
const STATE_FILE = "/tmp/wvkbd-position"

def get_current_position []: nothing -> string {
    if ($STATE_FILE | path exists) {
        open $STATE_FILE
    } else {
        $GEOMETRY_LEFT
    }
}

def save_position [pos: string] {
    $pos | save -f $STATE_FILE
}

export def main [] {
    let $current = (get_current_position)
    let $new_geom = if $current == $GEOMETRY_LEFT {
        $GEOMETRY_RIGHT
    } else {
        $GEOMETRY_LEFT
    }
    
    # Kill existing wvkbd
    pkill -x wvkbd-mobintl
    
    # Save new position
    save_position $new_geom
    
    # Start with new geometry
    exec wvkbd-mobintl --fn "Monospace 14" --geometry $new_geom --non-exclusive
}

export def left [] {
    pkill -x wvkbd-mobintl
    save_position $GEOMETRY_LEFT
    exec wvkbd-mobintl --fn "Monospace 14" --geometry $GEOMETRY_LEFT --non-exclusive
}

export def right [] {
    pkill -x wvkbd-mobintl
    save_position $GEOMETRY_RIGHT
    exec wvkbd-mobintl --fn "Monospace 14" --geometry $GEOMETRY_RIGHT --non-exclusive
}
