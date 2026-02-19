export def main [
	--activity (-a) # turns broadcast into activity type
	...args: string # by default no argument will prompt an album
] {
	let $pkg = "com.maxmpz.audioplayer"
	let $cmd = if $activity {{sub: "activity", target: $"($pkg)/.PowerampAPIActivity"}} else  {{sub: "broadcast", target: $"($pkg)/.player.PowerampAPIReceiver"}}
	if ($args | is-not-empty) {
		if ($args.0 in [play pause stop toggle_play_pause next prev]) {
			let $extra_cmd = ($args.0 | str upcase)
			print $"Command: ($extra_cmd)"
			sudo cmd activity $cmd.sub -a $"($pkg).API_COMMAND" -e cmd $extra_cmd $cmd.target
			return
		}
		if ($args.0 == "scan") {
			print "SCANNING..."
			sudo cmd activity $cmd.sub -a $"($pkg).ACTION_SCAN_DIRS" --ez scanProviders true $cmd.target
			return
		}
		if ($args.0 == "repeat") {
			let repeat_values = [[id desc]; [0 REPEAT_NONE] [1 REPEAT_ON] [2 REPEAT_ADVANCE] [3 REPEAT_SONG] [4 SINGLE_SONG]]
			if ($args.1? not-in ($repeat_values | get id | into string)) {
				print "Needs second argument (0–4)"
				print $repeat_values
				return
			}
			let selected = ($repeat_values | where id == ($args.1 | into int) | get 0)
			print $"REPEAT MODE: ($selected.desc)"
			sudo cmd activity $cmd.sub -a $"($pkg).API_COMMAND" -e cmd REPEAT --ei repeat ($selected.id) $cmd.target
			return
		}
		print $"Unknown argument: ($args.0)"
		return
	}
	let $TMP = [$nu.temp-path poweramp.nuon] | path join
	sudo nu -c $'open /data/data/($pkg)/databases/folders.db | query db "SELECT _id as id,album FROM albums;" | save -f ($TMP)'
	let albums = (open $TMP)
	let fzf_str = ($albums | each {$"($in.id) ($in.album)"}) | str join "\n"
	let selected = ($fzf_str | fzf)
	if ($selected | is-empty) {
		print "No selection. Exiting..."
		return
	}
	let id = ($selected | split words | get 0)
	print $"Opening album: ($selected)"
	sudo cmd activity $cmd.sub -a $"($pkg).API_COMMAND" -d $"content://($pkg).data/albums/($id)/files" --ei cmd 20 $cmd.target
}
