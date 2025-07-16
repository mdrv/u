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
			layouts/minimal.kdl
			themes/cyberdream.kdl
			themes/cyberdream-light.kdl
		]
	}
	nushell: {
		target: $nu.default-config-dir # = ($nu.home-path)/.config/($app_name)
		items: [
			u
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

export def main [
	app_name: string@app_completion
] {
	let app_data = ($DATA | get $app_name)
	[$app_data] | flatten | par-each {|$app|
		let default_target_dir = ($app.target? | default ($nu.home-path)/.config/($app_name))
		if ($default_target_dir | path type) != "dir" {
			error make { msg: $"Target is not a directory: ($default_target_dir)" }
		}
		$app.items | par-each {|$item|
			let $source = ([$PWD $app_name $in] | path join)
			print $"($source) → ($app.target)(ansi defd)/($item)(ansi reset)"
			ln -sf $source ($app.target)/
		} | ignore
	} | ignore
}
