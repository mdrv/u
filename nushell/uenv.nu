if not ("PATH" in $env) {$env.PATH = []}
$env.PATH = ($env.PATH ++ [
    /usr/local/sbin
    /usr/local/bin
    /usr/bin
    # /system/bin # Android binary dir
    # /usr/bin/vendor_perl # for fakeroot-tcp/po4a
    # /data/data/com.termux/files/usr/bin # Termux binary dir
    $"($env.HOME)/.bun/bin" # Bun (JS runtime)
    # $"($env.HOME)/.local/share/bob/nvim-bin" # Bob (Neovim manager)
    # $"($env.HOME)/.local/bin" # for non-latest python
    # $env.PNPM_HOME
    # add more if needed...
] | uniq | where {path exists})

$env.EDITOR = "nvim"

$env.LANG = "en_US.UTF-8"
$env.LC_CTYPE = "en_US.UTF-8"
$env.LC_NUMERIC = "en_US.UTF-8"
$env.LC_TIME = "en_US.UTF-8"
$env.LC_COLLATE = "en_US.UTF-8"
$env.LC_MONETARY = "en_US.UTF-8"
$env.LC_MESSAGES = "en_US.UTF-8"
$env.LC_PAPER = "en_US.UTF-8"
$env.LC_NAME = "en_US.UTF-8"
$env.LC_ADDRESS = "en_US.UTF-8"
$env.LC_TELEPHONE = "en_US.UTF-8"
$env.LC_MEASUREMENT = "en_US.UTF-8"
$env.LC_IDENTIFICATION = "en_US.UTF-8"
$env.LC_ALL = "en_US.UTF-8"

let HOSTNAME_PATH = ($env.PREFIX?)/etc/hostname
if not ($HOSTNAME_PATH | path exists) or (open $HOSTNAME_PATH | str trim) in ["" "localhost"] {
    input $"($HOSTNAME_PATH): " | str trim | sudo tee $HOSTNAME_PATH out> /dev/null
}
$env.HOSTNAME = (open $HOSTNAME_PATH --raw | str trim)

# l: https://carapace-sh.github.io/carapace-bin/setup.html#nushell
if (which carapace | is-not-empty) {
    $env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense' # optional
    mkdir ~/.cache/carapace
    carapace _carapace nushell | save --force ~/.cache/carapace/init.nu
}
