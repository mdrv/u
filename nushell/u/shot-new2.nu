const ROOT_DIR = $"($nu.home-dir)/n/img/ushot"
const NUON_FILE = $"($nu.temp-dir)/ushot.nuon"
const LOG_FILE = $"($nu.temp-dir)/ushot.md"

# TODO: Set up via .u.shot.nuon .u.nuon

# Helper function for debug logging
def _log [msg: string, level: string = "INFO"] {
    let $NOW = (date now | format date "%Y-%m-%dT%H:%M:%S%:z")
    let $emoji = if $level == "INFO" {"ℹ️"} else if $level == "ERROR" {"❌"} else if $level == "WARN" {"⚠️"} else if $level == "SUCCESS" {"✅"} else {"🐛"}
    $">\t($NOW) ($emoji) [($level)] ($msg)\n" | save -a $LOG_FILE
}

# Helper function to always get current Hyprland instance (handles restarts)
def _get_hyprland_instance []: nothing -> list<record<instance: string, wl_socket: string>> {
    let $INSTANCES = (^hyprctl instances -j | from json)
    if ($INSTANCES | is-empty) {
        error make {msg: "No Hyprland instance."}
    }

    # Always update these env vars from current instance (fixes zellij cache issue)
    $env.HYPRLAND_INSTANCE_SIGNATURE = $INSTANCES.0.instance
    $env.WAYLAND_DISPLAY = $INSTANCES.0.wl_socket

    # Ensure required env vars are set
    # Note: Use quotes inside $() to prevent Nushell from treating values as commands
    if XDG_RUNTIME_DIR not-in $env {
        $env.XDG_RUNTIME_DIR = "/run/user/1000"
    }

    if HOSTNAME not-in $env {
        $env.HOSTNAME = (open --raw /etc/hostname | str trim)
    }

    return $INSTANCES
}

def _shot [
    --force
    --notify
    --quality (-q): string
] {
    let $NOW = (date now)
    let $LOG_TIME = ($NOW | format date "%Y-%m-%dT%H:%M:%S%:z")
    # let $LOG_TIME = ($NOW | format date "%+")

    _log "Starting shot with quality: $quality"

    # Always refresh Hyprland instance (handles restarts)
    try {
        _get_hyprland_instance | ignore
    } catch {|err|
        _log $"Failed to get Hyprland instance: ($err.msg)" "ERROR"
        error make {msg: "No Hyprland instance."}
    }

    try {
        # Step 1: Check idle state
        _log "Checking NUON file: $NUON_FILE"

        if not ($NUON_FILE | path exists) {
            _log "NUON file doesn't exist, creating new"
            let $cursorpos = (^hyprctl cursorpos)
            _log "Got cursor position: $cursorpos"
            {curpos: $cursorpos, pid: $nu.pid, running: true} | to nuon | save -f $NUON_FILE
            _log "Created NUON file successfully"
        } else {
            _log "Reading existing NUON file"
            let $nuon = try {
                open --raw $NUON_FILE | from nuon
            } catch {|err|
                _log $"Failed to read NUON file: ($err.msg)" "ERROR"
                return 4sec
            }
            _log $"NUON content: ($nuon | to nuon)"

            let $tmp = try {
                ^hyprctl cursorpos
            } catch {|err|
                _log $"Failed to get cursor position: ($err.msg)" "ERROR"
                return 4sec
            }

            _log $"Current cursor pos: ($tmp)"

            if $nuon.curpos != $tmp {
                _log "Cursor moved, updating NUON"
                {curpos: $tmp, pid: $nu.pid, running: true} | to nuon | save -f $NUON_FILE
            } else {
                _log "Cursor idle (no movement)" "WARN"
                ^dunstify -u low -t 500 -a ushot "🛇"
                return 4sec
            }
        }

        # Step 2: Check for blocked apps
        _log "Checking for blocked apps (tofi)"
        let $pidof_result = try {
            ^pidof -sq tofi | complete
        } catch {|err|
            _log $"pidof failed: ($err.msg)" "ERROR"
            {exit_code: 1, stdout: "", stderr: $err.msg}
        }

        if ($pidof_result | get exit_code) == 0 {
            _log "Found tofi running, blocking screenshot" "WARN"
            ^dunstify -u low -t 500 -a ushot "🛇"
            return 4sec
        }

        # Step 3: Get window class
        _log "Getting active window class"
        let $CLASS = try {
            ^hyprctl activewindow -j | from json
        } catch {|err|
            _log $"Failed to get active window: ($err.msg)" "ERROR"
            {}
        }

        if ($CLASS | is-empty) {
            _log "No active window found" "WARN"
            let $wait_time = match $quality {
                'low' => {4sec}
                'high' => {4sec}
                _ => {4sec}
            }
            return $wait_time
        }

        _log $"Active window JSON: ($CLASS | to nuon)"
        let $CLASS = $CLASS | get initialClass
        _log $"Window class: ($CLASS)"

        # Step 4: Setup file paths
        let $class_modifier = {
            "org.inkscape.Inkscape": "inkscape"
        }

        let $CLASS = if $CLASS in ($class_modifier | columns) {
            $class_modifier | get $CLASS
        } else {
            $CLASS
        }
        _log $"Modified window class: ($CLASS)"

        let $DIR = $"($ROOT_DIR)/w($NOW | format date '%Y%m%d')"
        let $EXT = "avif"
        let $FILE = $"($DIR)/($env.HOSTNAME | str trim)-w($NOW | format date '%Y%m%d-%H%M%S')-($CLASS).($EXT)"
        _log $"Output file: ($FILE)"

        if not ($DIR | path exists) {
            _log "Creating directory: $DIR"
            mkdir $DIR
        }

        # Step 5: Calculate parameters using match instead of if-else
        let $params = match $quality {
            'low' => {size: 0.66667, quality: 50, speed: 6}
            'high' => {size: 1, quality: 66, speed: 5}
            _ => {size: 0.75, quality: 60, speed: 5}
        }
        _log $"Encoding params: size=($params.size), quality=($params.quality), speed=($params.speed)"

        # Step 6: Create temp file
        _log "Creating temp file with mktemp"
        let $tmp = try {
            ^mktemp -t "ushot-XXXXXX.png"
        } catch {|err|
            _log $"mktemp failed: ($err.msg)" "ERROR"
            return 4sec
        }
        _log $"Temp file: ($tmp)"

        # Step 7: Capture screenshot with grim
        # Extract size to variable first to avoid interpolation issues
        let $size = $params.size
        _log $"Running grim: -t png -s ($size) -l 0 ($tmp)"
        let $grim_result = try {
            ^grim -t png -s $size -l 0 $tmp | complete
        } catch {|err|
            _log $"grim failed: ($err.msg)" "ERROR"
            {exit_code: 1, stdout: "", stderr: $err.msg}
        }

        if ($grim_result | get exit_code) != 0 {
            _log $"grim exit code: ($grim_result | get exit_code)" "ERROR"
            _log $"grim stderr: ($grim_result | get stderr)" "ERROR"
            ^rm -f $tmp
            return 4sec
        }
        _log "grim succeeded"

        # Step 8: Encode to AVIF
        # Extract params to variables first to avoid interpolation issues
        let $quality_val = $params.quality
        let $speed_val = $params.speed
        _log $"Running avifenc: -q ($quality_val) -s ($speed_val) ($tmp) ($FILE)"
        let $avifenc_result = try {
            ^avifenc -q $quality_val -s $speed_val $tmp $FILE e+o> /dev/null | complete
        } catch {|err|
            _log $"avifenc failed: ($err.msg)" "ERROR"
            {exit_code: 1, stdout: "", stderr: $err.msg}
        }

        if ($avifenc_result | get exit_code) != 0 {
            _log $"avifenc exit code: ($avifenc_result | get exit_code)" "ERROR"
            _log $"avifenc stderr: ($avifenc_result | get stderr)" "ERROR"
            ^rm -f $tmp
            return 4sec
        }
        _log "avifenc succeeded"

        # Step 9: Cleanup
        _log "Removing temp file: $tmp"
        ^rm -f $tmp

        if $notify {
            ^dunstify -u low -t 500 -a ushot "⛶"
        }

        _log $"Screenshot saved: ($CLASS) → ($FILE)" "SUCCESS"

        # Use match for return value instead of nested if-else
        let $wait_time = match $quality {
            'low' => {4sec}
            'high' => {15sec}
            _ => {10sec}
        }
        return $wait_time
    } catch {|err|
        _log $"Unhandled error: ($err | describe)" "ERROR"
        _log $"Error message: ($err.msg)" "ERROR"
        _log $"Error span: ($err.span | default {})" "ERROR"
        ^dunstify -u critical -t 2000 -a ushot "ERROR" $err.msg
    }
}

# TODO: disable cron option (rather than toggle)
export def main [
    --loop
    --quality (-q): string
    --notify
    --toggle
] {
    let $NOW = (date now)
    let $LOG_TIME = ($NOW | format date "%Y-%m-%dT%H:%M:%S%:z")

    _log $"main() called with args: loop=($loop), notify=($notify), toggle=($toggle), quality=($quality)"

    # Check env vars before using them to avoid parsing issues
    let $xdg_runtime_set = if 'XDG_RUNTIME_DIR' in $env {true} else {false}
    let $hostname_set = if 'HOSTNAME' in $env {true} else {false}

    _log $"Environment check: XDG_RUNTIME_DIR in env? ($xdg_runtime_set)"
    _log $"Environment check: HOSTNAME in env? ($hostname_set)"
    if $hostname_set {
        _log $"Current HOSTNAME: ($env.HOSTNAME)"
    }

    # Reinitialize environment variables
    _log "Checking Hyprland instances..."

    # Always get fresh instance (handles Hyprland restarts in zellij sessions)
    let $INSTANCES = try {
        ^hyprctl instances -j | from json
    } catch {|err|
        _log $"Failed to get Hyprland instances: ($err.msg)" "ERROR"
        []
    }

    _log $"Instances: ($INSTANCES | to nuon)"

    if ($INSTANCES | is-empty) {
        _log "ERROR: No Hyprland instance found" "ERROR"
        error make {msg: "No Hyprland instance."}
    }

    # Always update these from current instance (fixes zellij cache issue)
    $env.HYPRLAND_INSTANCE_SIGNATURE = $INSTANCES.0.instance
    $env.WAYLAND_DISPLAY = $INSTANCES.0.wl_socket
    _log $"Updated HYPRLAND_INSTANCE_SIGNATURE: ($env.HYPRLAND_INSTANCE_SIGNATURE)"
    _log $"Updated WAYLAND_DISPLAY: ($env.WAYLAND_DISPLAY)"

    if XDG_RUNTIME_DIR not-in $env {
        _log "Setting up XDG_RUNTIME_DIR" "WARN"
        $env.XDG_RUNTIME_DIR = "/run/user/1000"
    }

    if HOSTNAME not-in $env {
        _log "Setting up HOSTNAME" "WARN"
        $env.HOSTNAME = (open --raw /etc/hostname | str trim)
    }

    # Use match for mode handling instead of nested if-else
    match [$loop $notify $toggle] {
        [true, false, false] => {
            # loop mode
            _log "Starting loop mode" "INFO"
            $">\t($LOG_TIME) LOOP START\n" | save -a $LOG_FILE

            # Use match for interval calculation
            let $mod = match $quality {
                'low' => {4}
                'high' => {15}
                _ => {10}
            }

            loop {
                let $epoch = (date now | format date %s | into int)
                if $epoch mod 60 >= (60 - $mod) {break}
                if $epoch mod $mod == 0 {
                    _log "Loop iteration: taking screenshot"
                    _shot --notify --quality $quality
                }
                let $next = (($epoch // $mod + 1) * $mod * 1000000000 | into datetime)
                _log $"Next screenshot at: ($next)"
                sleep ($next - (date now))
            }

            let $end_time = (date now | format date "%Y-%m-%dT%H:%M:%S%:z")
            $">\t($end_time) LOOP END\n" | save -a $LOG_FILE
            _log "Loop ended naturally" "SUCCESS"
        }
        [false, true, false] => {
            # notify mode
            _log "Taking single screenshot with notify"
            _shot --notify --quality $quality
        }
        [false, false, true] => {
            # toggle mode
            _log "Toggling cron job"
            let $CRON_PREFIX = "* * * * * nu ~/.config/nushell/u/shot-new2.nu --loop"
            let $quality_suffix = if ($quality | is-not-empty) {
                $" --quality ($quality)"
            } else {
                ""
            }
            let $CRON_TEXT = $"($CRON_PREFIX)($quality_suffix)"
            _log $"Cron text: ($CRON_TEXT)"

            let $cronlist = try {
                ^crontab -l | lines
            } catch {|err|
                _log $"crontab -l failed: ($err.msg), assuming empty" "WARN"
                []
            }

            _log $"Current cron entries: (($cronlist | length))"

            # Check for existing cron entry
            let $has_entry = $cronlist | any {|entry| $entry | str starts-with $CRON_PREFIX}

            # Filter out existing entry using structured operations
            let $_cronlist = $cronlist | where {|entry| not ($entry | str starts-with $CRON_PREFIX)}

            if not $has_entry {
                # Add new entry
                _log "Adding new cron entry"
                let $cronlist_new = ($_cronlist | append $CRON_TEXT)
                let $crontab_input = ($cronlist_new | str join "\n") + "\n"

                _log "Writing crontab"
                try {
                    $crontab_input | ^crontab -
                    _log "Crontab updated successfully" "SUCCESS"
                } catch {|err|
                    _log $"Failed to update crontab: ($err.msg)" "ERROR"
                    return
                }

                $">\t($LOG_TIME) ⏺️\n" | save -a $LOG_FILE
                ^dunstify -u low -t 1000 -a ushot "🔴"
                _log "Starting loop mode" "WARN"
                main --loop # WARNING: will block/potentially spawn multiple instances
            } else {
                # Remove existing entry
                _log "Removing cron entry"
                let $crontab_input = ($_cronlist | str join "\n") + "\n"

                try {
                    $crontab_input | ^crontab -
                    _log "Crontab updated (entry removed) successfully" "SUCCESS"
                } catch {|err|
                    _log $"Failed to update crontab: ($err.msg)" "ERROR"
                    return
                }

                $">\t($LOG_TIME) ⏹️\n" | save -a $LOG_FILE
                ^dunstify -u low -t 1000 -a ushot "⬛"

                # Kill existing shot process
                if ($NUON_FILE | path exists) {
                    _log "Killing existing shot process from NUON file"
                    let $nuon = try {
                        open --raw $NUON_FILE | from nuon
                    } catch {|err|
                        _log $"Failed to read NUON file for cleanup: ($err.msg)" "WARN"
                        {}
                    }

                    if 'pid' in ($nuon | columns) {
                        try {
                            ^kill $nuon.pid
                            _log $"Killed PID: ($nuon.pid)" "SUCCESS"
                        } catch {|err|
                            _log $"Failed to kill PID ($nuon.pid): ($err.msg)" "WARN"
                        }
                    }
                }

                # BUG: When stopping at 01, cron is still running
                # let $pids = (ps -l | where command =~ "ushot.nu --loop" | get pid)
                # for $pid in $pids {^kill $pid}
            }
        }
        _ => {
            # Default: no mode specified
            _log "No action specified (no --loop, --notify, or --toggle)" "WARN"
        }
    }
}
