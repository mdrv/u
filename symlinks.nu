const DATA = {
	dunstrc: {
		items: [ dunstrc ]
	}
	fastfetch: {
		items: [
			ascii.txt
			config.jsonc
		]
	}
	foot: {
		items: [
			foot.ini
			cyberdream.ini
			cyberdream-light.ini
			tokyonight-storm.ini
		]
	}
	home: {
		items: [
			{ gitconfig: .gitconfig }
		]
	}
	hypr: {
		items: [
			hyprland.conf
		]
	}
	kitty: {
		items: [
			kitty.conf
		]
	}
	neovide: {
		items: [
			config.toml
		]
	}
	nvim: {
		target: ($nu.home-path)/.config/nvim/lua
		items: [
			ulazy
			ulsp
			uinit.lua
			utils.lua
		]
		message: r#'Enable plugins by adding `.u.lua`: `return {LV = 1}`'#
	}
	quickshell: {
		items: [
			shell.qml
		]
	}
	tofi: {
		items: [
			config
		]
	}
	waybar: {
		items: [
			config.jsonc
			style.css
		]
	}
	zellij: {
		items: [
			config.kdl
			layouts/android-alx.kdl
			layouts/default.kdl
			layouts/minimal.kdl
			themes/cyberdream.kdl
			themes/cyberdream-light.kdl
		]
		message: r#'Execute this:
http get https://github.com/dj95/zjstatus/releases/latest/download/zjstatus.wasm | save -f ($nu.home-path)/.config/zellij/zjstatus.wasm'#
	}
	nushell: {
		target: $nu.default-config-dir # = ($nu.home-path)/.config/($app_name)
		items: [
			u
			uinit.nu
			uconfig.nu
			uenv.nu
		]
	}
}
const PWD = (path self | path dirname) # alt: $env.FILE_PWD

def app_completion [] {
	{
		completions: ($DATA | columns)
	}
}

def is-list []: any -> bool { describe | str starts-with "list" }
def into-list []: any -> bool {
	if ($in | is-list) {$in} else {[$in]}
}

export def main [
	app_name: string@app_completion
] {
	let app_data = ($DATA | get $app_name)
	$app_data |	into-list | par-each {|$app|
		let app_target_dir = ($app.target? | default ($nu.home-path)/.config/($app_name) )
		if ($app_target_dir | path type) != "dir" {
			error make { msg: $"Target is not a directory: ($app_target_dir)" }
		}
		$app.items | par-each {|$item|
			let $source = ([$PWD $app_name $in] | path join)
			let $item_target_dir = ([$app_target_dir $item] | path join | path dirname)
			if ($item_target_dir | path type) != "dir" {
				error make { msg: $"Item target is not a directory: ($item_target_dir)" }
			}
			print $"($source) → ($item_target_dir)/"
			ln -sf $source ($item_target_dir)/
		} | ignore
		if ($app.message? | is-not-empty) {
			print (ansi rb)($app.message)(ansi reset)
		}
	} | ignore
}
