$env.config.show_banner = false
$env.config.render_right_prompt_on_last_line = true

if (is-admin) {
    print "⚠️ You are logged in as root."
} else if (which fastfetch | is-empty) {
    print $"(ansi bb)📢 fastfetch (ansi y)is not installed!(ansi reset)"
} else if (^tty | complete).stdout =~ "^/dev/tty" {
    ^fastfetch -l arch --logo-padding-top 0
} else {
    ^fastfetch
}

const $d = $nu.default-config-dir
const _ = $"($d)/empty.nu"

const f = 'zoxide.nu'; const p = $"($d)/($f)"
const _E = $"(ansi bb)🚨 ($f) (ansi r)can’t be sourced!(ansi reset)"
if not ($p | path exists) {print $_E}
source (if ($p | path exists) {$p} else {$_})

const f = 'atuin.nu'; const p = $"($d)/($f)"
const _E = $"(ansi bb)🚨 ($f) (ansi r)can’t be sourced!(ansi reset)"
if not ($p | path exists) {print $_E}
source (if ($p | path exists) {$p} else {$_})

const f = 'carapace.nu'; const p = $"($d)/($f)"
const _E = $"(ansi bb)🚨 ($f) (ansi r)can’t be sourced!(ansi reset)"
if not ($p | path exists) {print $_E}
source (if ($p | path exists) {$p} else {$_})

const f = 'uinit.nu'; const p = $"($d)/($f)"
const _E = $"(ansi bb)🚨 ($f) (ansi r)can’t be used!(ansi reset)"
if not ($p | path exists) {print $_E}
use (if ($p | path exists) {$p} else {$_})

const f = 'u/'; const p = $"($d)/($f)"
const _E = $"(ansi bb)🚨 ($f) (ansi r) can’t be used!(ansi reset)"
if not ($p | path exists) {print $_E}
use (if ($p | path exists) {$p} else {$_})

alias l = ls
alias b = bun
alias g = git
alias n = nvim
alias no = do { SHOW_NEOTREE=1 nvim -c $"cd ($env.NOTE_PATH)" }
alias m = micro
alias s = serai
alias h = hirari
alias ac = aichat
alias dp = dprint
alias zj = zellij
alias oc = opencode
alias ff = fastfetch
alias pb = pocketbase
alias H = start-hyprland
alias gdl = gallery-dl
alias cop = copilot --allow-all-tools --enable-all-github-mcp-tools --add-dir . --resume -p
alias coph = copilot --model claude-haiku-4.5 --allow-all-tools --enable-all-github-mcp-tools --add-dir . --resume -p

alias umod = nu ~/.config/nushell/u/mod_.nu
alias um = u mount
alias up = u pacaur
alias us = u sync
alias mpvxx = u mpv q15 ft5-ladspa [*.flac]
alias mpvxxx = u mpv q15 ft5-ladspa [*.flac] -d (ls -s ~/n/audio | get name | str join "\n" | fzf)
alias mpvxxxx = u mpv q15 ft5-ladspa [*.flac] -d (ls -s /n/audio | get name | str join "\n" | fzf)
alias mpvxxj = u mpv ja11 [*.flac] -d (ls -s ~/n/audio | get name | str join "\n" | fzf)
alias mpvxxxj = u mpv ja11 [*.flac] -d (ls -s /n/audio | get name | str join "\n" | fzf)
alias mpvxxt = u mpv t1lite [*.flac] -d (ls -s ~/n/audio | get name | str join "\n" | fzf)
alias mpvxxxt = u mpv t1lite [*.flac] -d (ls -s /n/audio | get name | str join "\n" | fzf)
alias shizuku = ^adb shell /data/app/moe.shizuku.privileged.api-j5XlxmLhVhDNXXQgyrL4Nw==/lib/arm/libshizuku.so
alias shizukuold = ^adb shell sh /storage/emulated/0/Android/data/moe.shizuku.privileged.api/start.sh

alias ocb = opencode run --agent build
alias oct = opencode run --agent tens
alias ocp = opencode run --agent plan
alias ocf = opencode run --agent flash

alias time-update-google = sudo ntpdate -u time.google.com

def mg --wrapped [
	...paths: string
] {
	glob $paths | par-each {|path| run-external "git" "-C" $path "--work-tree" ($path | path parse | get parent) | complete | insert path $path | print } | ignore
}

def rgfzf [
    s: string = ""
    --max-depth (-d): number = 3
] {
    rg --max-depth $max_depth --follow --color=always --line-number --no-heading $s | fzf --ansi --height 50%
}
alias rf = rgfzf

def sftpd [
	host: string
] {
	^sftp $"($host):(pwd)"
}

def cataas_size_list [] { [xsmall small medium square] }
def cataas [size: string@cataas_size_list = "small"] {
    http get $'https://cataas.com/cat?type=($size)' | chafa --exact-size=on
}
alias meow = cataas
