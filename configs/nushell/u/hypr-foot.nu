export def --wrapped main [
    --alt
	--no-special (-n)
    --id (-i): string
    ...cmd: string
] {
    let $l = (^hyprctl clients -j | from json | where title == if $no_special {$"hypr-nospecial-foot-($id)"} else {$"hypr-foot-($id)"})
    if ($l | is-not-empty) {
        if $alt {
            ^hyprctl dispatch movetoworkspacesilent (if $l.0.workspace.name == $"special:hypr-foot-($id)" {"+0,"} else {$"special:hypr-foot-($id),"}) $"address:($l.0.address)"
        } else {
			if $no_special {
				let $workspace_id = (^hyprctl activeworkspace -j | from json | get id)
				if $l.0.workspace.id == $workspace_id {
					^hyprctl dispatch movetoworkspacesilent special:hidden, $"address:($l.0.address)"
				} else {
					^hyprctl dispatch movetoworkspace +0, $"address:($l.0.address)"
				}
			} else {
				^hyprctl dispatch togglespecialworkspace $"hypr-foot-($id)"
			}
        }
        # if ($l.0.workspace.name | str length) > 3 {
        #     ^hyprctl dispatch setfloating $"address:($l.0.address)"
        #     ^hyprctl dispatch togglespecialworkspace hypr-foot
            # ^hyprctl dispatch movetoworkspacesilent +0, $"address:($l.0.address)"
            # ^hyprctl dispatch alterzorder top, $"address:($l.0.address)"
            # ^hyprctl dispatch focuswindow $"address:($l.0.address)"
        # } else {
        #     ^hyprctl dispatch movetoworkspacesilent special:hypr-foot, $"address:($l.0.address)"
        #     ^hyprctl dispatch togglespecialworkspace hypr-foot
        # }
    } else {
		if $no_special {
			^foot -T $"hypr-nospecial-foot-($id)" --override locked-title=yes ...$cmd
		} else {
			^hyprctl dispatch exec $'[workspace special:hypr-foot-($id)]' -- foot -T $"hypr-foot-($id)" --override locked-title=yes ...$cmd
		}
    }
}
