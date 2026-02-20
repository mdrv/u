const SELF = (path self)
# Get the current script's path for recursive calls

const PACMAN = [sudo pacman -S --needed --noconfirm]
# Base pacman command with flags to skip confirmation

export def pipewire [] {
	run-external ...$PACMAN pipewire pipewire-pulse wireplumber pavucontrol ladspa dsp mpv
	systemctl enable --user pipewire pipewire-pulse.socket
	print $"Don't forget to populate (ansi bb)~/.config/ladspa/(ansi reset) with (ansi bb)config_[name](ansi reset)."
}
# Install and enable PipeWire audio stack for Linux sound system

export def essential [] {
	run-external ...$PACMAN base base-devel linux networkmanager usbutils udisks2
	print $"Might be needed: linux-firmware-realtek linux-firmware-nvidia"
	print $"Might be needed: intel-ucode nvidia"
}
# Install essential Arch Linux packages for a basic working system

export def cli [] {
	run-external ...$PACMAN aichat ttyper rsync rclone yt-dlp git-delta github-cli bottom brightnessctl dust neovim fzf git nushell socat unison openssh autossh zellij fastfetch ffmpeg atuin ripgrep zoxide man-db less yazi jq fd android-tools rhash copyparty rtorrent evtest keyd iperf3 eza acpi batsignal chezmoi lazygit gitui tig ugrep typos
	print $"AUR: dprint-bin paru-bin gallery-dl-bin gitui-bin"
	print "aarch64 has gnu-netcat available in pacman"
}
# Install comprehensive CLI tools for development and daily use

export def dev [] {
	run-external ...$PACMAN stylua lua-language-server svelte-language-server typescript typescript-language-server typescript-svelte-plugin pnpm nodejs vscode-css-languageserver vscode-html-languageserver vscode-json-languageserver astyle pacman-contrib
	print $"AUR: carapace-bin bun-bin lefthook-bin opencode-bin crush-bin openspec surrealdb-bin"
}
# Install development tools including language servers for web development

export def vps [] {
	run-external ...$PACMAN miniserve caddy
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
	run-external ...$PACMAN hyprland hyprpaper hyprpicker hyprshot slurp wl-clipboard nwg-displays kitty foot noto-fonts noto-fonts-cjk noto-fonts-extra ttf-jetbrains-mono-nerd grim tesseract-data-eng xdg-desktop-portal-hyprland quickshell libnotify wev nwg-drawer wvkbd squeekboard fnott
	run-external ...$PACMAN kid3 nsxiv waybar telegram-desktop dunst firefox firefox-ublock-origin firefox-tree-style-tab firefox-tridactyl mupdf keepassxc gthumb sqlitebrowser
	run-external ...$PACMAN imagemagick libvips libopenslide poppler-glib chafa libheif
	run-external ...$PACMAN nemo nemo-fileroller nemo-preview
	run-external ...$PACMAN mkvtoolnix-cli mkvtoolnix-gui
	run-external ...$PACMAN neovide fcitx5 fcitx5-config-qt
	print $"Might be needed: vulkan-intel"
	print $"AUR: grimblast-git bibata-cursor-git noctalia-shell google-breakpad localsend-bin tofi ttf-twemoji bulky qpdfview"
	print $"for armpipa-alx: sddm xorg-xrandr xorg-xinput qt6-virtualkeyboard"
	print $"for armpipa-alx AUR: sddm-silent-theme"
}


export def main [] {
	print $SELF
	let selected = ([pipewire hyprland] | input list --fuzzy)
	nu -n $SELF $selected
}
