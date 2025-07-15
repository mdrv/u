$env.config.show_banner = false
$env.config.render_right_prompt_on_last_line = true

const $d = $nu.default-config-dir
const _ = $"($d)/empty.nu"

const f = 'u/'; const p = $"($d)/($f)"
const _E = $"(ansi bb)🚨 ($f) (ansi r) can’t be used!(ansi reset)"
if not ($p | path exists) {print $_E}
use (if ($p | path exists) {$p} else {$_})

# l: https://carapace-sh.github.io/carapace-bin/setup.html#nushell
const f = 'carapace/init.nu'; const p = $"~/.cache/($f)"
const _E = $"(ansi bb)🚨 ($f) (ansi r)can’t be sourced!(ansi reset)"
if not ($p | path exists) {print $_E}
source (if ($p | path exists) {$p} else {$_})

alias b = bun
alias g = git
alias n = nvim
alias dp = dprint
alias zj = zellij
alias H = Hyprland

alias umod = nu ~/.config/nushell/u/mod_.nu
alias um = u mount
alias up = u pacaur
alias us = u sync
alias mpvxx = u mpv q15 ft5-ladspa [*.flac]
alias mpvxxx = u mpv q15 ft5-ladspa [*.flac] -d (ls -s ~/n/audio | get name | str join "\n" | fzf)
alias mpvxxxx = u mpv q15 ft5-ladspa [*.flac] -d (ls -s /n/audio | get name | str join "\n" | fzf)

def rgfzf [
    s: string = ""
    --max-depth (-d): number = 3
] {
    rg --max-depth $max_depth --follow --color=always --line-number --no-heading $s | fzf --ansi --height 50%
}

