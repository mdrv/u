#!/usr/bin/env -S nu

const MIN_CLASS = "Min"
const MIN_SPECIAL_WS = "min"

export def main [] {
	# Get all windows
	let all_windows = (^hyprctl clients -j | from json)

	# Filter for Min windows
	let min_windows = ($all_windows | where class == $MIN_CLASS)
	let most_recent = ($min_windows | sort-by focusHistoryID | reverse | first)

	if ($min_windows | is-empty) {
		# Min not running, launch it
		^dunstify "Launching Min..."
		job spawn { min }
		return
	}

	# Check if active window is Min
	let $workspace_id = (^hyprctl activeworkspace -j | from json | get id)
	if $most_recent.workspace.id == $workspace_id {
		# Minimize to special workspace
		^dunstify "Minimizing Min..."
		if $most_recent.pinned == true {
			hyprctl dispatch pin address:($most_recent.address)
		}
		hyprctl dispatch movetoworkspacesilent special:hidden, address:($most_recent.address)
	} else {
		# Focus most recently used Min
		^dunstify "Focusing Min..."
		if $most_recent.pinned == false {
			hyprctl dispatch pin address:($most_recent.address)
		}
		hyprctl dispatch movetoworkspace +0,address:($most_recent.address)
	}
}
