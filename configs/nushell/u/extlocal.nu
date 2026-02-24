# Transfer from external to local filesystem

export def main [
	dir: string = audio
] {

    let $list = (cd $"($env.N)/($dir)"; ls | get name | str join "\n" | fzf -m --bind "space:toggle" | lines)
	if ($list | is-empty) {return "Quitting..."}
	let $target = $"($nu.home-path)($env.N)/($dir)"
    try {
        mkdir $target
    }
    cd $target
    mkdir ...$list
    $list | par-each {|| cp -r $"($env.N)/($dir)/($in)/flac" $"($target)/($in)/"}
}

# Install Chrome on Arch Linux ARM via Playwright binary
export def chrome-arm64 [] {
	let arch = (^uname -m | str trim)

	if $arch != "aarch64" {
		print $"(ansi r)Error: (ansi reset)chrome-arm64 is only for ARM64 architecture (detected: ($arch))"
		return
	}

	# Check if playwright is installed
	if (which playwright | is-empty) {
		print $"(ansi r)Error: (ansi reset)playwright is not installed"
		print $"(ansi y)Install with: (ansi reset)pacman -S aur/playwright (or yay -S aur/playwright)"
		return
	}

	let chrome_path = "/home/ua/.cache/ms-playwright/chromium-1208/chrome-linux/chrome"
	let target_path = $"($nu.home-dir)/.local/bin/chrome"

	# Check if chrome binary exists, offer to install if not
	if not ($chrome_path | path exists) {
		print $"(ansi y)Chrome binary not found. (ansi reset)Install with 'playwright install chromium'?"
		let answer = (input "Install? [y/N] " | str trim)

		if $answer not-in ["y", "Y"] {
			print "Cancelled."
			return
		}

		print "Installing Chromium via playwright..."
		let result = (^playwright install chromium | complete)

		if $result.exit_code != 0 {
			print $"(ansi r)Error: (ansi reset)Failed to install Chromium"
			print $result.stderr
			return
		}

		# Re-check after installation
		if not ($chrome_path | path exists) {
			print $"(ansi r)Error: (ansi reset)Chrome binary still not found after installation"
			return
		}
	}

	# Check if symlink already exists
	if ($target_path | path exists) {
		if ($target_path | path expand) == ($chrome_path | path expand) {
			print $"(ansi y)Chrome already symlinked to ($target_path)(ansi reset)"
		} else {
			print $"(ansi r)Error: (ansi reset)($target_path) exists but points elsewhere"
		}
		return
	}

	# Create symlink
	try {
		ln -s $chrome_path $target_path
		print $"(ansi g)✓ (ansi reset)Chrome symlinked to ($target_path)"
	} catch { |err|
		print $"(ansi r)Error: (ansi reset)Failed to create symlink: ($err.msg)"
	}
}
