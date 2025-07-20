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

$env.TMPDIR = $nu.temp-path

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

if ($"($nu.default-config-dir)/.u.nuon" | path exists) {
	open ($nu.default-config-dir)/.u.nuon | get ENV? | default {} | load-env
}

def createLeftPrompt [--transient] {
    let dir = match (do -i { $env.PWD | path relative-to $nu.home-path }) {
        null => $env.PWD
        '' => '~'
        $relative_pwd => ([~ $relative_pwd] | path join)
    }

    let path_color = (if (is-admin) { ansi red_bold } else { ansi green_bold })
    let separator_color = (if (is-admin) { ansi light_red_bold } else { ansi light_green_bold })
    let path_segment = $"($path_color)($dir)(ansi reset)"
	let git_current_ref = (do { ^git rev-parse --abbrev-ref HEAD } | complete | get stdout | str trim)

    if $transient {return ($path_segment | str replace --all (char path_sep) $"($separator_color)(char path_sep)($path_color)")}

    [
		$"(ansi defd)($env.USER)@($env.HOSTNAME)"
		($path_segment | str replace --all (char path_sep) $"($separator_color)(char path_sep)($path_color)")
	] ++ if ($git_current_ref | is-empty) {[]} else {[$"(ansi yd)\(($git_current_ref)\) "]} | str join $"(ansi reset) "
}

def createRightPrompt [--transient] {
    # create a right prompt in magenta with green separators and am/pm underlined
    let time_segment = ([
        (ansi reset)
        (ansi magenta)
        # (date now | format date '%x %X %p') # try to respect user's locale
        # (date now | format date '%F %T (%s)') # MY OWN (with epoch)
        (date now | format date '%T') # MY OWN (without epoch)
    ] | str join | str replace --regex --all "([/:])" $"(ansi green)${1}(ansi magenta)" |
        str replace --regex --all "([AP]M)" $"(ansi magenta_underline)${1}")

    let last_exit_code = if ($env.LAST_EXIT_CODE != 0) {([
        (ansi rb)
        ($env.LAST_EXIT_CODE)
    ] | str join)
    } else { "" }

    if $transient or "DISABLE_STATS_PROMPT" in $env {return ([$last_exit_code $time_segment ""] | str join " ")}

    # const $d = $nu.default-config-dir
    # const $asnu = $"($d)/as.nu"
    # let surrealdb_version = (do {|| use $asnu *; get_surrealdb_version})
    # if ($surrealdb_version | describe) != "string" {return ([$last_exit_code $time_segment ""] | str join " ")}
    #
    # let surrealdb_duration = (if ($surrealdb_version | split row "." | get 0) != "2" {""} else {do {|| use $asnu *; get_surrealdb_duration}})
    # let surrealdb_string = (if ($surrealdb_version | split row "." | get 0) != "2" {""} else {$"(ansi bg_b) ✨(ansi yb)0 💠(ansi bb)($surrealdb_duration) (ansi reset)"}) # 🔹
    ([$last_exit_code $time_segment] | where ($it | is-not-empty) | str join " ") + " " # 💠
}

# TODO: Let’s create a menu for prompt configration! (command name: nup)
$env.PROMPT_COMMAND = {|| createLeftPrompt}
$env.PROMPT_COMMAND_RIGHT = {|| createRightPrompt }
$env.TRANSIENT_PROMPT_COMMAND = {|| createLeftPrompt --transient }
$env.TRANSIENT_PROMPT_COMMAND_RIGHT = {|| createRightPrompt --transient }

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
