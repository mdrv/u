export def --wrapped main [
    --alt
	--no-special (-n)
    --id (-i): string
    ...cmd: string
] {
    let $l = (^hyprctl clients -j | from json | where title == if $no_special {$"hypr-nospecial-kitty-($id)"} else {$"hypr-kitty-($id)"})
    if ($l | is-not-empty) {
        if $alt {
            ^hyprctl dispatch movetoworkspacesilent (if $l.0.workspace.name == $"special:hypr-kitty-($id)" {"+0,"} else {$"special:hypr-kitty-($id),"}) $"address:($l.0.address)"
        } else {
			if $no_special {
				let $workspace_id = (^hyprctl activeworkspace -j | from json | get id)
				if $l.0.workspace.id == $workspace_id {
					^hyprctl dispatch movetoworkspacesilent special:hidden, $"address:($l.0.address)"
				} else {
					^hyprctl dispatch movetoworkspace +0, $"address:($l.0.address)"
				}
			} else {
				^hyprctl dispatch togglespecialworkspace $"hypr-kitty-($id)"
			}
        }
        # if ($l.0.workspace.name | str length) > 3 {
        #     ^hyprctl dispatch setfloating $"address:($l.0.address)"
        #     ^hyprctl dispatch togglespecialworkspace hypr-kitty
            # ^hyprctl dispatch movetoworkspacesilent +0, $"address:($l.0.address)"
            # ^hyprctl dispatch alterzorder top, $"address:($l.0.address)"
            # ^hyprctl dispatch focuswindow $"address:($l.0.address)"
        # } else {
        #     ^hyprctl dispatch movetoworkspacesilent special:hypr-kitty, $"address:($l.0.address)"
        #     ^hyprctl dispatch togglespecialworkspace hypr-kitty
        # }
    } else {
		if $no_special {
			^kitty -T $"hypr-nospecial-kitty-($id)" --override locked-title=yes ...$cmd
		} else {
			^hyprctl dispatch exec $'[workspace special:hypr-kitty-($id)]' -- kitty -T $"hypr-kitty-($id)" --override locked-title=yes ...$cmd
		}
    }
}
