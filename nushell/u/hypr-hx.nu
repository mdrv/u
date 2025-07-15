export def --wrapped main [
	...url: string
] {
	let $l = (^hyprctl clients -j | from json | where class == hypr-hx)
	if ($l | is-not-empty) {
		let cur_x = (^hyprctl cursorpos | parse "{x}, {y}" | get x.0 | into int)
		let $workspace_id = (^hyprctl activeworkspace -j | from json | get id)
		if $l.0.workspace.id == $workspace_id {
			^hyprctl dispatch movetoworkspacesilent special:hidden, $"address:($l.0.address)"
		} else {
			hyprctl dispatch focuswindow $"address:($l.0.address)"
			if $cur_x <= 960 {
				if $l.0.at.0 != 0 {
					hyprctl dispatch movewindow l
				}
			} else {
				if $l.0.at.0 == 0 {
					hyprctl dispatch movewindow r
				}
			}
			^hyprctl dispatch movetoworkspace +0, $"address:($l.0.address)"
		}
	} else {
		^firefox --new-window --name hypr-hx -p hx ...$url
		loop {
			let $l = (^hyprctl clients -j | from json | where class == hypr-hx)
			if ($l | is-not-empty) {
				# hyprctl dispatch focuswindow $"address:($l.0.address)"
				hyprctl dispatch movewindow r
				break
			}
			sleep 0.1sec
		}
	}
}
