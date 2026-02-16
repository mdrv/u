const $MPV_SOCK = $"($nu.home-dir)/.config/mpv/mpvx"
use ($nu.default-config-dir + /u/assert-missing.nu)

# bind = SUPER, COMMA, exec, nu -n $u/ua-mpvx.nu --toggle-pause
# bind = SUPER SHIFT, COMMA, exec, nu -n $u/ua-mpvx.nu --playlist-prev
# bind = SUPER SHIFT, PERIOD, exec, nu -n $u/ua-mpvx.nu --playlist-next

export def main [
    ...$args
    --add (-a) = []
    --verbose (-v)
    --dir (-d): string
    --ctrl: string
] {
	if ($ctrl | is-not-empty) {
		assert-missing socat
		match $ctrl {
			# TODO: Use the same notify-send ID to avoid clutter.
			toggle-pause => {
				let $pause = (({command: ["get_property" pause]} | to json --raw) + (char nl) | socat - $MPV_SOCK | from json | get data)
				match $pause {
					false => {
						({command: ["set_property" pause true]} | to json --raw) + (char nl) | socat - $MPV_SOCK
						^notify-send "⏸ mpv paused"
					}
					true => {
						({command: ["set_property" pause false]} | to json --raw) + (char nl) | socat - $MPV_SOCK
						^notify-send "▶ mpv resumed"
					}
				}
				return
			}

			# TODO: Use the same notify-send ID to avoid clutter.
			# TODO: Use optimistic assumption (fetch next track title without delay)
			# https://en.wikipedia.org/wiki/Speculative_execution
			playlist-next => {
				({command: ["playlist-next"]} | to json --raw) + (char nl) | ^socat - $MPV_SOCK | complete
				sleep 200ms
				let $data = (({command: ["get_property" "playlist-pos-1"]} | to json --raw) + (char nl) + ({command: ["get_property" "media-title"]} | to json --raw) + (char nl) | socat - $MPV_SOCK)
				# ^notify-send $data
				let $data = ($data | lines | each {from json} | get data | str join " - ")
				^notify-send $"⏮ mpv playlist-prev\n($data)"
			}

			# TODO: Use the same notify-send ID to avoid clutter.
			# TODO: Use optimistic assumption (fetch prev track title without delay)
			# https://en.wikipedia.org/wiki/Speculative_execution
			playlist-prev => {
				({command: ["playlist-prev"]} | to json --raw) + (char nl) + ({command: ["playlist-pos-1"]} | to json --raw) + (char nl) | ^socat - $MPV_SOCK | complete
				sleep 200ms
				let $data = (({command: ["get_property" "playlist-pos-1"]} | to json --raw) + (char nl) + ({command: ["get_property" "media-title"]} | to json --raw) + (char nl) | socat - $MPV_SOCK)
				# ^notify-send $data
				let $data = ($data | lines | each {from json} | get data | str join " - ")
				^notify-send $"⏭ mpv playlist-next\n($data)"
			}

			# TODO: Use same notify-send ID to avoid clutter.
			volume-up => {
				({command: ["add" "volume" "+1"]} | to json --raw) + (char nl) | socat - $MPV_SOCK | complete
				sleep 200ms
				let $vol = (({command: ["get_property" "volume"]} | to json --raw) + (char nl) | socat - $MPV_SOCK | from json | get data)
				^notify-send $"🔊 mpv volume +1% ($vol)"
				return
			}

			# TODO: Use same notify-send ID to avoid clutter.
			volume-down => {
				({command: ["add" "volume" "-2"]} | to json --raw) + (char nl) | socat - $MPV_SOCK | complete
				sleep 200ms
				let $vol = (({command: ["get_property" "volume"]} | to json --raw) + (char nl) | socat - $MPV_SOCK | from json | get data)
				^notify-send $"🔉 mpv volume -2% ($vol)"
				return
			}
		}
		return
	}

    mut $mods = ["--no-audio-display" "--pause" $"--input-ipc-server=($MPV_SOCK)"]

    let $glob = ([($args | last)] | flatten)

    if "q15" in $args {$mods ++= ["--audio-exclusive" '--audio-device=alsa/iec958:CARD=Q15,DEV=0']}
    if "ja11" in $args {$mods ++= ["--audio-exclusive" '--audio-device=alsa/iec958:CARD=JA11,DEV=0']}
    if "dc03pro" in $args {$mods ++= ["--audio-exclusive" '--audio-device=alsa/iec958:CARD=iBassoDC03Pro,DEV=0']}

    if "ft5" in $args {$mods ++= [([
        '-af=format=double,volume=-8.3dB    '
        'equalizer=f=62  :t=q:w=0.78 :g=-3.9'
        'equalizer=f=142 :t=q:w=1.22 :g=0.4 '
        'equalizer=f=374 :t=q:w=0.28 :g=-7.0'
        'equalizer=f=393 :t=q:w=2.23 :g=-2.0'
        'equalizer=f=552 :t=q:w=6.00 :g=2.8 '
        'equalizer=f=725 :t=q:w=2.62 :g=-1.8'
        'equalizer=f=1395:t=q:w=0.53 :g=8.0 '
        'equalizer=f=4101:t=q:w=2.15 :g=2.0 '
        'equalizer=f=8358:t=q:w=1.97 :g=-1.3'
        'highshelf=f=6435:t=q:w=0.60 :g=8.5 '
    ] | str replace -a ' ' '' | str join ',')]}

    if "ft5-ladspa" in $args {$mods ++= ['-af=ladspa=/usr/lib/ladspa/ladspa_dsp.so:"ladspa_dsp:ft5"']}
    # uses `PACMAN:dsp` LADSPA plugin with specified config

    if "ft5-noshelf" in $args {$mods ++= [([
        '-af=format=double,volume=-8.3dB     '
        'equalizer=f=69   :t=q:w=0.63 :g=-4.1'
        'equalizer=f=127  :t=q:w=3.80 :g=3.3 '
        'equalizer=f=131  :t=q:w=2.46 :g=-1.3'
        'equalizer=f=205  :t=q:w=2.57 :g=1.1 '
        'equalizer=f=369  :t=q:w=0.34 :g=-7.5'
        'equalizer=f=574  :t=q:w=2.58 :g=2.5 '
        'equalizer=f=704  :t=q:w=3.09 :g=-1.2'
        'equalizer=f=1270 :t=q:w=0.83 :g=6.2 '
        'equalizer=f=10000:t=q:w=0.25 :g=6.1 '
        'equalizer=f=10000:t=q:w=0.40 :g=2.0 '
    ] | str replace -a ' ' '' | str join ',')]}

    if "ariase" in $args {$mods ++= [([
        '-af=format=double,volume=-7.1dB  '
        'lowshelf =f= 107:t=q:w=0.53:g=+2.9'
        'equalizer=f=  47:t=q:w=0.54:g=-3.9'
        'equalizer=f= 167:t=q:w=1.56:g=-0.6'
        'equalizer=f= 514:t=q:w=0.62:g=+1.5'
        'equalizer=f= 836:t=q:w=2.28:g=+0.5'
        'equalizer=f=1250:t=q:w=2.80:g=-0.7'
        'equalizer=f=1865:t=q:w=0.85:g=-2.1'
        'equalizer=f=3509:t=q:w=1.48:g=-0.7'
        'equalizer=f=5974:t=q:w=2.54:g=-4.9'
        'highshelf=f=5211:t=q:w=0.70:g=+7.1'
    ] | str replace -a ' ' '' | str join ',')]}

    if "ariase-5band" in $args {$mods ++= [([
        '-af=format=double,volume=-4.8dB    '
        'equalizer=f=53   :t=q:w=0.43 :g=-3.5'
        'equalizer=f=697  :t=q:w=0.68 :g=+3.3'
        'equalizer=f=3013 :t=q:w=0.23 :g=-2.6'
        'equalizer=f=10000:t=q:w=1.70 :g=+4.3'
        'highshelf=f=5209 :t=q:w=0.40 :g=+2.8'
    ] | str replace -a ' ' '' | str join ',')]}

    if "t1lite" in $args {$mods ++= [([
        '-af=format=double,volume=0dB      '
        'equalizer=f=20  :t=q:w=1.7 :g=-4.4'
        'equalizer=f=39  :t=q:w=0.5 :g=-12 '
        'equalizer=f=43  :t=q:w=1.6 :g=2.0 '
        'equalizer=f=190 :t=q:w=1.0 :g=-2.1'
        'equalizer=f=660 :t=q:w=1.3 :g=1.0 '
        'equalizer=f=2000:t=q:w=2   :g=-7.6'
        'equalizer=f=7100:t=q:w=2   :g=-7.8'
    ] | str replace -a ' ' '' | str join ',')]}

    if "stage" in $args {$mods ++= [([
        '-af=format=double,volume=0dB    '
        'lowshelf=f=450  :t=q:w=0.5 :g=-9'
    ] | str replace -a ' ' '' | str join ',')]}

    if "stage-old" in $args {$mods ++= [([
        '-af=format=double,volume=0dB    '
        'lowshelf=f=500  :t=q:w=0.8 :g=-7'
        'equalizer=f=300 :t=q:w=0.5 :g=-1'
    ] | str replace -a ' ' '' | str join ',')]}

    if "active2" in $args {$mods ++= [([
        '-af=format=double,volume=0dB      '
        'lowshelf=f=450  :t=q:w=0.5 :g=-4.0'
        'highshelf=f=10000  :t=q:w=0.8 :g=-1.0 '
    ] | str replace -a ' ' '' | str join ',')]}

    if $verbose {
        print ([mpv $mods $add $glob] | flatten | str join " ")
    }

    if ($dir | is-not-empty) {
        let $dir = ([$"~/n/audio/($dir)/flac/" $"/n/audio/($dir)/flac/"] | skip until {|| $in | path exists})
        if ($dir | is-empty) {
            error make {msg: "directory not found!"}
        }
        cd $dir.0
    }
    run-external mpv ...$mods ...$add ...(ls ...($glob | par-each -k {|$in| into glob}) | get name)
}
