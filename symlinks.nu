#!/usr/bin/env nu
# symlinks.nu — Symlink manager for μ dotfiles
# Usage:
#   nu symlinks.nu              # Interactive multi-select menu
#   nu symlinks.nu <app_name>   # Link a single app's configs
#   nu symlinks.nu --help       # Show help

const REPO_ROOT = (path self .)

const VALID_DEVICE_TYPES = ["vps", "arch-x64", "arch-arm", "termux"]

const DEVICE_PROFILES = {
	vps: {
		description: "Server-only (no desktop apps)"
		excludes: ["hypr", "waybar", "tofi", "dunst", "foot", "kitty", "otd", "quickshell", "neovide"]
	}
	arch-x64: {
		description: "Full Arch Linux desktop (x86_64)"
		excludes: []
	}
	arch-arm: {
		description: "Arch Linux desktop (ARM)"
		excludes: ["neovide"]
	}
	termux: {
		description: "Termux (minimal)"
		excludes: [
			"hypr", "waybar", "tofi", "dunst", "foot", "kitty", "otd", "quickshell", "neovide",
			"zellij", "yazi", "atuin", "aichat", "crush", "fastfetch", "opencode", "home"
		]
	}
}

const DATA = {
	nushell: {
		items: [u, uinit.nu, uconfig.nu, uenv.nu]
		compatible_with: ["vps", "arch-x64", "arch-arm", "termux"]
	}
	nvim: {
		items: [uinit.lua, utils.lua, autocmds.lua, filetype.lua, keymaps.lua, lsp-loader.lua, statusline.lua, theme.lua, ulazy, ulsp, unavigate]
		target: "~/.config/nvim/lua"
		compatible_with: ["vps", "arch-x64", "arch-arm", "termux"]
		message: "Enable plugins by adding `.u.lua`: `return {LV = 1}`. Link .luarc.jsonc manually: ln -s configs/nvim/.luarc.jsonc ~/.config/nvim/.luarc.jsonc"
	}
	hypr: {
		items: [hyprland.conf, hyprlock.conf, hyprtoolkit.conf, monitor.nu, shaders]
		compatible_with: ["arch-x64", "arch-arm"]
	}
	kitty: {
		items: [kitty.conf, themes-cyberdream.conf]
		compatible_with: ["arch-x64", "arch-arm"]
	}
	foot: {
		items: [foot.ini, cyberdream.ini, cyberdream-light.ini, tokyonight-storm.ini]
		compatible_with: ["arch-x64", "arch-arm"]
	}
	waybar: {
		items: [config.jsonc, style.css]
		compatible_with: ["arch-x64", "arch-arm"]
	}
	dunst: {
		items: [dunstrc]
		compatible_with: ["arch-x64", "arch-arm"]
	}
	tofi: {
		items: [config]
		compatible_with: ["arch-x64", "arch-arm"]
	}
	yazi: {
		items: [init.lua, yazi.toml]
		compatible_with: ["vps", "arch-x64", "arch-arm"]
	}
	zellij: {
		items: [config.kdl, layouts, themes]
		compatible_with: ["vps", "arch-x64", "arch-arm"]
		message: "Execute this: http get https://github.com/dj95/zjstatus/releases/latest/download/zjstatus.wasm | save -f ($nu.home-dir)/.config/zellij/zjstatus.wasm"
	}
	atuin: {
		items: [config.toml]
		compatible_with: ["vps", "arch-x64", "arch-arm"]
	}
	aichat: {
		items: [config.yaml]
		compatible_with: ["vps", "arch-x64", "arch-arm"]
	}
	crush: {
		items: [crush.json]
		compatible_with: ["vps", "arch-x64", "arch-arm"]
	}
	fastfetch: {
		items: [config.jsonc, config-tty.jsonc, ascii.txt]
		compatible_with: ["vps", "arch-x64", "arch-arm"]
	}
	neovide: {
		items: [config.toml]
		compatible_with: ["arch-x64"]
	}
	opencode: {
		items: [AGENTS.md opencode.jsonc, oh-my-opencode-slim.json oh-my-opencode-slim package.json]
		compatible_with: ["vps", "arch-x64", "arch-arm"]
		message: "Don't forget to do bun install and add dprint.jsonc"
	}
	otd: {
		items: ["Deco 640 Absolute Mode.json", "Deco 640 Artist Mode.json"]
		target: "~/.config/OpenTabletDriver/Presets"
		compatible_with: ["arch-x64", "arch-arm"]
	}
	quickshell: {
		items: [shell.qml, u]
		compatible_with: ["arch-x64", "arch-arm"]
	}
	home: {
		items: [{ ".gitconfig": ".gitconfig" }, { "makepkg.conf": "makepkg.conf" }]
		target: "~"
		compatible_with: ["vps", "arch-x64", "arch-arm"]
		message: "Home dotfiles linked. Remember to create ~/.u.gitconfig for device-specific git settings."
	}
}

# Read device_type from ~/.u.json, defaulting to "arch-x64"
def get_device_type []: nothing -> string {
	let ujson_path = $"($nu.home-dir)/.u.json"
	if not ($ujson_path | path exists) {
		print $"(ansi yb)⚠ ~/.u.json not found, defaulting to arch-x64(ansi reset)"
		return "arch-x64"
	}
	let ujson = (open $ujson_path)
	let device_type = ($ujson | get DEVICE | get TYPE | default "arch-x64")
	if $device_type not-in $VALID_DEVICE_TYPES {
		print $"(ansi rd)✗ Invalid DEVICE.TYPE '($device_type)' in ~/.u.json(ansi reset)"
		print $"  Valid types: ($VALID_DEVICE_TYPES | str join ', ')"
		print $"(ansi yb)⚠ Defaulting to arch-x64(ansi reset)"
		return "arch-x64"
	}
	if ($ujson | get DEVICE | get TYPE | is-empty) {
		print $"(ansi yb)⚠ No DEVICE.TYPE in ~/.u.json, defaulting to arch-x64(ansi reset)"
	}
	$device_type
}

# Resolve the target directory for a given app config
def resolve_target [app_name: string]: nothing -> string {
	let config = ($DATA | get $app_name)
	let raw_target = ($config | get target? | default $"~/.config/($app_name)")
	$raw_target | str replace "~" $nu.home-dir
}

# Get the source path for a config item
def resolve_source [app_name: string, item_name: string]: nothing -> string {
	[$REPO_ROOT "configs" $app_name $item_name] | path join
}

# Get what an existing symlink points to, or null if not a symlink
def get_symlink_target [path: string]: nothing -> string {
	let result = (do { ^readlink $path } | complete)
	if $result.exit_code == 0 {
		$result.stdout | str trim
	} else {
		""
	}
}

# Get status indicator for a config item
def get_symlink_status [target_path: string, expected_source: string]: nothing -> string {
	if not ($target_path | path exists) {
		$"(ansi c)○(ansi reset)" # not linked
	} else {
		let current = (get_symlink_target $target_path)
		if $current == "" {
			$"(ansi yb)●(ansi reset)" # exists but not a symlink
		} else if $current == $expected_source {
			$"(ansi gr)✓(ansi reset)" # correctly linked
		} else {
			$"(ansi rd)✗(ansi reset)" # linked to wrong location
		}
	}
}

# Create a single symlink with validation
def create_symlink [source: string, target_path: string]: nothing -> record {
	# Check source exists
	if not ($source | path exists) {
		return { ok: false, error: $"Source not found: ($source)" }
	}

	# Ensure target parent directory exists
	let target_dir = ($target_path | path dirname)
	if not ($target_dir | path exists) {
		mkdir $target_dir
		print $"  (ansi c)Created directory: ($target_dir)(ansi reset)"
	} else if not (($target_dir | path type) == "dir") {
		return { ok: false, error: $"Target parent is not a directory: ($target_dir)" }
	}

	# Check if target already exists
	if ($target_path | path exists) {
		let current = (get_symlink_target $target_path)
		if $current == $source {
			print $"  (ansi gr)✓(ansi reset) Already linked: ($target_path | str replace $nu.home-dir '~')"
			return { ok: true, error: "" }
		}
		if $current != "" {
			print $"  (ansi yb)⚠(ansi reset) Symlink exists → ($current)"
		} else {
			print $"  (ansi yb)⚠(ansi reset) File exists, not a symlink"
		}
		# Remove existing to replace
		rm -rf $target_path
		print $"  (ansi c)↻(ansi reset) Replaced existing"
	}

	# Create symlink
	let result = (do { ^ln -sf $source $target_path } | complete)
	if $result.exit_code != 0 {
		return { ok: false, error: $"ln failed: ($result.stderr | str trim)" }
	}
	print $"  (ansi gr)✓(ansi reset) Linked: ($target_path | str replace $nu.home-dir '~') → ($source | str replace $REPO_ROOT '.')"
	{ ok: true, error: "" }
}

# Link all items for a single app config
def link_app [app_name: string]: nothing -> list<string> {
	let config = ($DATA | get $app_name)
	let target_dir = (resolve_target $app_name)
	let items = ($config.items)

	print $"(ansi rb)▸(ansi reset) (ansi attr_bold)($app_name)(ansi reset) → ($target_dir | str replace $nu.home-dir '~')"

	mut errors: list<string> = []

	for item in $items {
		# Handle record items (e.g., { gitconfig: .gitconfig })
		let item_info = if ($item | describe | str starts-with "record") {
			let cols = ($item | columns)
			let src_name = ($cols | first)
			let tgt_name = ($item | get $src_name | into string)
			{ source_name: $src_name, target_name: $tgt_name }
		} else {
			let name = ($item | into string)
			{ source_name: $name, target_name: $name }
		}

		let source = (resolve_source $app_name $item_info.source_name)
		let target_path = [$target_dir $item_info.target_name] | path join

		let result = (create_symlink $source $target_path)
		if not $result.ok {
			let err_msg = $"($app_name)/($item_info.source_name): ($result.error)"
			print $"  (ansi rd)✗(ansi reset) ($err_msg)"
			$errors = ($errors | append $err_msg)
		}
	}

	# Show post-setup message if any
	let message = ($config | get message? | default "")
	if $message != "" {
		print $"  (ansi c)ℹ(ansi reset) ($message)"
	}

	$errors
}

# Get list of configs compatible with the given device type
def get_compatible_configs [device_type: string]: nothing -> list<string> {
	let excludes = ($DEVICE_PROFILES | get $device_type | get excludes)
	$DATA | columns | where { |app| $app not-in $excludes }
}

# Build display entries for the interactive menu
def build_menu_entries [device_type: string]: nothing -> table {
	let compatible = (get_compatible_configs $device_type)
	$compatible | each { |app_name|
		let config = ($DATA | get $app_name)
		let target_dir = (resolve_target $app_name)
		let items = $config.items
		let item_count = ($items | length)

		# Check overall status
		let statuses = ($items | each { |item|
			let item_info = if ($item | describe | str starts-with "record") {
				let cols = ($item | columns)
				let src_name = ($cols | first)
				let tgt_name = ($item | get $src_name | into string)
				{ source_name: $src_name, target_name: $tgt_name }
			} else {
				let name = ($item | into string)
				{ source_name: $name, target_name: $name }
			}
			let source = (resolve_source $app_name $item_info.source_name)
			let target_path = [$target_dir $item_info.target_name] | path join
			get_symlink_status $target_path $source
		})

		# Determine overall icon
		let has_correct = ($statuses | any { |s| $s =~ "✓" })
		let has_missing = ($statuses | any { |s| $s =~ "○" })
		let has_wrong = ($statuses | any { |s| $s =~ "✗" })
		let has_conflict = ($statuses | any { |s| $s =~ "●" })

		let icon = if $has_wrong or $has_conflict {
			$"(ansi yb)⚠(ansi reset)"
		} else if $has_missing {
			$"(ansi c)○(ansi reset)"
		} else {
			$"(ansi gr)✓(ansi reset)"
		}

		let target_short = ($target_dir | str replace $nu.home-dir "~")

		{
			name: $app_name
			display: $"($icon) ($app_name) [($item_count) items] → ($target_short)"
		}
	}
}

# Provide tab completions for app names
def app_completion []: nothing -> list<string> {
	$DATA | columns
}

# μ symlinks — Dotfiles symlink manager
#
# Interactive multi-select menu when run without arguments.
# Single-app mode: nu symlinks.nu <app_name>
# Detailed info:   nu symlinks.nu --info
#
# Device type is read from ~/.u.json field "device_type".
# Defaults to "arch-x64" if not set.
export def main [
	app_name?: string@app_completion # App to link (omit for interactive menu)
	--info (-i) # Show available apps and device profiles
]: nothing -> nothing {
	if $info {
		print $"(ansi attr_bold)μ symlinks — Dotfiles symlink manager(ansi reset)"
		print ""
		print "Usage:"
		print $"  (ansi c)nu symlinks.nu(ansi reset)              Interactive multi-select menu"
		print $"  (ansi c)nu symlinks.nu <app>(ansi reset)        Link a single app's configs"
		print $"  (ansi c)nu symlinks.nu --help(ansi reset)       Show usage help"
		print $"  (ansi c)nu symlinks.nu --info(ansi reset)       Show apps and device profiles"
		print ""
		print $"(ansi attr_bold)Available apps:(ansi reset)"
		let apps = ($DATA | columns)
		$apps | each { |app|
			let compat = ($DATA | get $app | get compatible_with | str join ", ")
			print $"  (ansi gr)($app)(ansi reset) — ($compat)"
		}
		print ""
		print $"(ansi attr_bold)Device profiles:(ansi reset)"
		$VALID_DEVICE_TYPES | each { |dt|
			let desc = ($DEVICE_PROFILES | get $dt | get description)
			print $"  (ansi rb)($dt)(ansi reset) — ($desc)"
		}
		print ""
		print $"Device type is read from (ansi c)~/.u.json(ansi reset) field \"device_type\"."
		print $"Defaults to (ansi yb)arch-x64(ansi reset) if not set."
		return
	}

	let device_type = (get_device_type)

	if $app_name != null {
		# Single-app mode: bypass device filtering for backward compatibility
		if $app_name not-in ($DATA | columns) {
			print $"(ansi rd)✗ Unknown app: ($app_name)(ansi reset)"
			print $"Available: ($DATA | columns | str join ', ')"
			return
		}

		print $"(ansi attr_bold)μ symlinks(ansi reset) — device: (ansi rb)($device_type)(ansi reset)"
		print ""
		let errors = (link_app $app_name)
		print ""
		if ($errors | length) > 0 {
			let err_count = ($errors | length)
			print $"(ansi rd)($err_count) errors:(ansi reset)"
			$errors | each { |e| print $"  (ansi rd)✗(ansi reset) ($e)" }
		} else {
			print $"(ansi gr)✓ Done(ansi reset)"
		}
		return
	}

	# Interactive mode
	let profile_desc = ($DEVICE_PROFILES | get $device_type | get description)
	print $"(ansi attr_bold)μ symlinks(ansi reset) — device: (ansi rb)($device_type)(ansi reset) [($profile_desc)]"
	print ""

	let entries = (build_menu_entries $device_type)

	if ($entries | length) == 0 {
		print $"(ansi yb)No compatible configs for device type '($device_type)'(ansi reset)"
		return
	}

	let display_list = ($entries | get display)
	let selected = ($display_list | input list --multi "Select configs to link (space to toggle, enter to confirm):")

	if ($selected | is-empty) {
		print $"(ansi yb)No configs selected.(ansi reset)"
		return
	}

	# Map selected display strings back to app names
	let selected_apps = ($selected | each { |sel|
		let match = ($entries | where { |e| $e.display == $sel } | first)
		$match.name
	})

	print ""
	let sel_count = ($selected_apps | length)
	print $"(ansi attr_bold)Linking ($sel_count) configs...(ansi reset)"
	print ""

	# Process in parallel and collect errors
	let all_errors = ($selected_apps | par-each --keep-order { |app|
		link_app $app
	} | flatten)

	print ""
	if ($all_errors | length) > 0 {
		let total_err = ($all_errors | length)
		print $"(ansi rd)($total_err) errors:(ansi reset)"
		$all_errors | each { |e| print $"  (ansi rd)✗(ansi reset) ($e)" }
	} else {
		print $"(ansi gr)✓ All done!(ansi reset)"
	}
}
