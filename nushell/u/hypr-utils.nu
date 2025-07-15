const $HYPRLAND_CONFIG_DIR = ("~/.config/hypr" | path expand)

# Hyprland utilities
# Mainly for more concise hyprland.conf
export def --wrapped main [
	...args: string
] {
	let $args = ($args | into string)
	# ^dunstify $"($args)"
	match $args.0 {
		gaps_out | padding => {
			if $args.1 == reset {
				hyprctl keyword general:gaps_out 20
				return
			}
			let $directions = ($args.1 | split row ",")
			let $int = ($args.2 | into int)
			mut $gaps = (hyprctl getoption general:gaps_out | parse -r ': (?<top>\d+) (?<right>\d+) (?<bottom>\d+) (?<left>\d+)' | update cells { into int } | get 0)
			$gaps = ([$gaps] | update cells --columns $directions {[($in + $int) 0] | math max}).0
			hyprctl keyword general:gaps_out ($gaps | values | str join ",")
		}
		expandarea | lessmargin => {
			hyprctl keyword general:gaps_out ([0 ((hyprctl getoption general:gaps_out | parse -r ': (?<value>\d+)' | get value.0 | into int) - 10)] | math max)
		}
		shrinkarea | moremargin => {
			hyprctl keyword general:gaps_out ((hyprctl getoption general:gaps_out | parse -r ': (?<value>\d+)' | get value.0 | into int) + 10)
		}

		opacity | alpha => {
			let mod = ($args.1 | into float)
			let address = (hyprctl activewindow -j | from json | get address)
			let f = ($nu.temp-path)/hypr-alpha-($address).nuon
			let _alpha = if $args.2? == 'fixed' {$mod} else if ($f | path exists) {
					(open $f) + $mod
				} else { 1.0 + $mod }
			let alpha = ([$_alpha 0.0 1.0] | math median | math round --precision 2)
			$alpha | save -f $f

			hyprctl dispatch setprop activewindow alpha $alpha
		}

		opaque => {
			^dunstify $args.1
			hyprctl dispatch setprop activewindow opaque $args.1
		}

		rounding => {
			let mod = ($args.1 | into int)
			let address = (hyprctl activewindow -j | from json | get address)
			let f = ($nu.temp-path)/hypr-rounding-($address).nuon
			let _rounding = if $args.2? == 'fixed' {$mod} else if ($f | path exists) {
					(open $f) + $mod
				} else { 0 + $mod }
			let rounding = ([$_rounding 0 100] | math median | math round --precision 2)
			$rounding | save -f $f

			hyprctl dispatch setprop activewindow rounding $rounding
		}

		generatehelp => {
			let lines = (open --raw ($HYPRLAND_CONFIG_DIR)/hyprland.conf | lines | where $it starts-with '## ' | str substring 3..)
			mut res = {}
			mut modes = []

			for l in $lines {
				if ($l | str starts-with "SUBMAP:") {
					let $mode = ($l | str substring 7..)
					$modes = ($modes | append $mode)
					$res = ($res | insert $mode [])
				} else if ($l | str starts-with "SUBMAP_END") {
					$modes = ($modes | drop)
				} else if ($modes | is-not-empty) {
					$res = ($res | update ($modes | last) { $in ++ [$l] })
				}
			}

			# NOTE: Must convert to table first.
			# https://github.com/nushell/nushell/issues/11965#issuecomment-2640559819
			$res = ([$res] | update cells {str join "  \n"} | get 0)

			{submap: $res} | save -f ($HYPRLAND_CONFIG_DIR)/.u.help.json
		}

	}
}
