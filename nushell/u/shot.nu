const ROOT_DIR = $"($nu.home-path)/n/img/ushot"
const NUON_FILE = $"($nu.temp-path)/ushot.nuon"
const LOG_FILE = $"($nu.temp-path)/ushot.md"

# TODO: Set up via .u.shot.nuon .u.nuon

def _shot [
    --force
    --notify
    --quality (-q): string
] {
    let $NOW = (date now)
    let $LOG_TIME = ($NOW | format date "%Y-%m-%dT%H:%M:%S%:z")
    # let $LOG_TIME = ($NOW | format date "%+")

    try {
        if not ($NUON_FILE | path exists) {
            {curpos: (^hyprctl cursorpos), pid: $nu.pid, running: true} | to nuon | save -f $NUON_FILE
        } else {
            let $nuon = (open --raw $NUON_FILE | from nuon)
            let $tmp = (^hyprctl cursorpos)

            if ($nuon.curpos != $tmp) {
                {curpos: $tmp, pid: $nu.pid, running: true} | to nuon | save -f $NUON_FILE
            } else {
                ^dunstify -u low -t 500 -a ushot "🛇"
                $">\t($LOG_TIME) 🛇 \(idle cursor)\n" | save -a $LOG_FILE
                return 4sec
            }
        }

        if (^pidof -sq tofi | complete | get exit_code) == 0 {
            ^dunstify -u low -t 500 -a ushot "🛇"
            $">\t($LOG_TIME) 🛇 \(tofi)\n" | save -a $LOG_FILE
            return 4sec
        } # BLOCKED APP LAUNCHER

        let $class_modifier = {
            "org.inkscape.Inkscape": "inkscape"
        }
        # H: Fix error: Cannot find column initial class
        let $CLASS = (hyprctl activewindow -j | from json)
        if ($CLASS | is-empty) { return (if $quality == 'low' {4sec} else if $quality == 'high' {15sec} else {10sec}) }
        let $CLASS = ($CLASS | get initialClass)
        # if not $force and $CLASS in [foot Min] {
        #     ^dunstify -u low -t 500 -a ushot "🛇"
        #     $">\t($LOG_TIME) 🛇 \(($CLASS))\n" | save -a $LOG_FILE
        #     return 4sec
        # } # BLOCKED SPECIFIC CLASS
        let $CLASS = if $CLASS in ($class_modifier | columns) {$class_modifier | get $CLASS} else {$CLASS}
        # if $CLASS not-in [krita inkscape blender] {return 1sec}

        let $DIR = $"($ROOT_DIR)/w($NOW | format date '%Y%m%d')"
        let $EXT = "avif"
        let $FILE = $"($DIR)/($env.HOSTNAME | str trim)-w($NOW | format date "%Y%m%d-%H%M%S")-($CLASS).($EXT)"
        if not ($DIR | path exists) {
            mkdir $DIR
        }

        let $params = if ($quality == 'low') {
			{size: 0.66667, quality: 50, speed: 6}
		} else if ($quality == 'high') {
			{size: 1, quality: 66, speed: 5}
		} else {
			{size: 0.75, quality: 60, speed: 5}
		}

		# H: Cannot pass binary to avifenc
		# H: Also, a shame Nushell can’t store stdout inside a temp file (process substitution)
		# l: https://github.com/nushell/nushell/issues/10610
		# let $tmp = mktemp -t "ushot-XXXXXX.jpg"
		let $tmp = mktemp -t "ushot-XXXXXX.png"

		# jxl
		# ^grim -s $params.size -l 0 - | ^cjxl /dev/stdin $FILE --lossless_jpeg=0 -d 3 -e 3
		# jpeg
		# ^grim -t jpeg -s 0.5 - | ^vipsthumbnail stdin -o $FILE -s 960

		# avif
		^grim -t png -s $params.size -l 0 $tmp
		^avifenc -q $params.quality -s $params.speed $tmp $FILE e+o> /dev/null

		rm -f $tmp # don’t forget to remove temp

        if $notify {^dunstify -u low -t 500 -a ushot "⛶"}
        $">\t($LOG_TIME) ⛶ \(($CLASS) → ($FILE))\n" | save -a $LOG_FILE
        return (if $quality == 'low' {4sec} else if $quality == 'high' {15sec} else {10sec})
    } catch {|err|
        $">\t($LOG_TIME) ✗ ($err)\n" | save -a $LOG_FILE
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

	# Reinitialize environment variables
    let $INSTANCES = (^hyprctl instances -j | from json)
    if ($INSTANCES | is-empty) {
        $">\t($LOG_TIME) ERROR: No Hyprland instance\n" | save -a $LOG_FILE
        error make {msg: "No Hyprland instance."}
    } else if XDG_RUNTIME_DIR not-in $env {
        $">\t($LOG_TIME) SETUP: Environment variables\n" | save -a $LOG_FILE
        $env.HOSTNAME = (open --raw /etc/hostname | str trim) # needed for file naming
        $env.XDG_RUNTIME_DIR = "/run/user/1000" # NEEDED for dunst!
        # $env.XDG_SEAT = "seat0"
        # $env.XDG_SESSION_CLASS = "user"
        # $env.XDG_SESSION_ID = "1"
        # $env.XDG_SESSION_TYPE = "wayland"
        # $env.DISPLAY = ":0"
        # $env.HYPRLAND_CMD = "/usr/bin/Hyprland" # needed for hyprctl
        $env.HYPRLAND_INSTANCE_SIGNATURE = $INSTANCES.0.instance # needed for hyprctl
        $env.WAYLAND_DISPLAY = $INSTANCES.0.wl_socket # needed for grim?
        # $env.XDG_BACKEND = "wayland"
        # $env.XDG_CURRENT_DESKTOP = "Hyprland"
    }

    # $">\t($LOG_TIME) @ ([$loop $notify $toggle])\n" | save -a $LOG_FILE
    if $loop {
        # for crontab per minute
        $">\t($LOG_TIME) LOOP START\n" | save -a $LOG_FILE
        loop {
            let $epoch = (date now | format date %s | into int)
            let $mod = if $quality == 'low' {4} else if $quality == 'high' {15} else {10}
            if $epoch mod 60 >= (60 - $mod) {break}
            if $epoch mod $mod == 0 {
                _shot --notify --quality $quality
            }
            let $next = (($epoch // $mod + 1) * $mod * 1000000000 | into datetime)
            sleep ($next - (date now))
        }
        $">\t(date now | format date "%Y-%m-%dT%H:%M:%S%:z") LOOP END\n" | save -a $LOG_FILE
    } else if $notify {
        _shot --notify --quality $quality
    } else if $toggle {
        let CRON_PREFIX = "* * * * * nu ~/.config/nushell/u/shot.nu --loop"
        let CRON_TEXT = $CRON_PREFIX + (if ($quality | is-not-empty) {$" --quality ($quality)"} else {""})
        let $cronlist = (^crontab -l | lines)

        mut $_cronlist = []
        mut $found = false
        for $x in $cronlist {
            if ($x | str starts-with $CRON_PREFIX) {
                $found = true
            } else {
                $_cronlist ++= [$x]
            }
        }
        if $found == false {
            $_cronlist ++= [$CRON_TEXT]
            ($_cronlist | str join "\n") + "\n" | ^crontab -

            $">\t($LOG_TIME) ⏺️\n" | save -a $LOG_FILE
            ^dunstify -u low -t 1000 -a ushot "🔴"
            main --loop # WARNING: will block/potentially spawn multiple instances
        } else {
            ($_cronlist | str join "\n") + "\n" | ^crontab -

            $">\t($LOG_TIME) ⏹️\n" | save -a $LOG_FILE
            ^dunstify -u low -t 1000 -a ushot "⬛"
            if ($NUON_FILE | path exists) {
                let $nuon = (open --raw $NUON_FILE | from nuon)
                ^kill $nuon.pid
            }

            # BUG: When stopping at 01, cron is still running

            # let $pids = (ps -l | where command =~ "ushot.nu --loop" | get pid)
            # for $pid in $pids {^kill $pid}
        }
    }
}
