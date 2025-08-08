const SELF = (path self)
const PACMAN = [sudo pacman -S --needed --noconfirm]

export def pipewire [] {
	run-external ...$PACMAN pipewire pipewire-pulse wireplumber pavucontrol ladspa dsp mpv
	systemctl enable --user pipewire pipewire-pulse.socket
	print $"Don’t forget to populate (ansi bb)~/.config/ladspa/(ansi reset) with (ansi bb)config_[name](ansi reset)."
}

export def essential [] {
	run-external ...$PACMAN base base-devel linux networkmanager usbutils udisks2
	print $"Might be needed: linux-firmware-realtek linux-firmware-nvidia"
	print $"Might be needed: intel-ucode nvidia"
}

export def cli [] {
	run-external ...$PACMAN rsync rclone yt-dlp git-delta github-cli bottom brightnessctl dust neovim fzf git nushell socat unison openssh zellij fastfetch ffmpeg atuin ripgrep zoxide man-db less yazi jq fd android-tools rhash
	print $"AUR: dprint-bin paru-bin gallery-dl-bin"
}

export def dev [] {
	run-external ...$PACMAN svelte-language-server typescript typescript-language-server typescript-svelte-plugin pnpm nodejs vscode-css-languageserver vscode-html-languageserver vscode-json-languageserver
	print $"AUR: carapace-bin bun-bin"
}

export def audiodev [] {
	run-external ...$PACMAN ardour surge-xt lsp-plugins lv2-plugins
	print $"AUR: vital-synth"
}

export def graphics [] {
	run-external ...$PACMAN blender krita inkscape
	print $"AUR: blender-3.6-bin"
}

export def hyprland [] {
	run-external ...$PACMAN hyprland hyprpaper wl-clipboard kitty foot noto-fonts noto-fonts-cjk noto-fonts-extra ttf-jetbrains-mono-nerd grim tesseract-data-eng
	run-external ...$PACMAN kid3 nsxiv waybar telegram-desktop dunst firefox firefox-ublock-origin firefox-tree-style-tab firefox-tridactyl mupdf keepassxc gthumb
	run-external ...$PACMAN imagemagick libvips libopenslide poppler-glib chafa libheif
	run-external ...$PACMAN nemo nemo-fileroller nemo-preview
	run-external ...$PACMAN neovide fcitx5 fcitx5-config-qt
	print $"Might be needed: vulkan-intel"
	print $"AUR: bibata-cursor-git quickshell-git google-breakpad localsend-bin tofi ttf-twemoji"
}


export def main [] {
	print $SELF
	let selected = ([pipewire hyprland] | input list --fuzzy)
	nu -n $SELF $selected
}
