# @module
# @link https://github.com/linux-surface/linux-surface/wiki/Installation-and-Setup#arch

# Configure linux-surface
export def main [] {
    curl -s https://raw.githubusercontent.com/linux-surface/linux-surface/master/pkg/keys/surface.asc | sudo pacman-key --add -
    sudo pacman-key --finger 56C464BAAC421453
    sudo pacman-key --lsign-key 56C464BAAC421453
    echo "\n[linux-surface]\nServer = https://pkg.surfacelinux.com/arch/" | sudo tee /etc/pacman.conf -a
	print $"(ansi defd)Execute this manually:\n(ansi bb)sudo pacman -Sy linux-surface linux-surface-headers iptsd(ansi reset)"
}
