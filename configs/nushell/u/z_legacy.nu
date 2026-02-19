#!/usr/bin/env nu

# TODO: Create reverse sync (mc=r)

const $D = $nu.default-config-dir
const $Z = (path self)

def _slice [
    $range: range
] {
    let $v = $in
    if (^vercmp $env.NU_VERSION 0.102.0 | into int) >= 0 {$v | slice $range} else {$v | range $range}
}

# 🥄 CONFIRM THAT KEEPS GOING (UNTIL DECIDES)
# 🔑 PROVIDES: main
def _C [
    s?: string
] {
    loop {
        let $answer = (input -n 1 $s)
        match ($answer | str downcase) {
            "y" => {return true}
            "n" => {return false}
        }
    }
}

# 🥄 SIMPLY GIVE SPECIFIED ANSI COLOR TO TEXT
# 🔑 PROVIDES: main
# No longer have to call ANSI RESET!
def _A [
    --blue (-u)
    --yellow (-y)
    --green (-g)
    --red (-r)
    --purple (-p)
    --cyan (-c)
    --black (-b)
    --defd (-d)
    --dgr (-e)
    --dgrd (-f)
    s: string
] {
    # HACK: Basically find length of first falses
    return (match ([$blue $yellow $green $red $purple $cyan $black $defd $dgr $dgrd] | take until {} | length) {
        0 => $"(ansi bb)($s)(ansi reset)"
        1 => $"(ansi yb)($s)(ansi reset)"
        2 => $"(ansi gb)($s)(ansi reset)"
        3 => $"(ansi rb)($s)(ansi reset)"
        4 => $"(ansi pb)($s)(ansi reset)"
        5 => $"(ansi cb)($s)(ansi reset)"
        6 => $"(ansi kb)($s)(ansi reset)"
        7 => $"(ansi defd)($s)(ansi reset)"
        8 => $"(ansi dgr)($s)(ansi reset)"
        9 => $"(ansi dgrd)($s)(ansi reset)"
        _ => $s
    })
}

# 🔎 CHECK DEPENDENCIES
# 🔑 PROVIDES: main
# Internal commanad/function; should not be called directly (since it’s the first thing to be called from MAIN)
# Will (hard) throw error if one of the deps is not found.
def _check_deps [
] {
    # NOTE: Wish Nushell has built-in compare/cmp command
    # 🐍: $l = List of dependencies with each of their purposes
    let $l = {
        cmp: "cmp (compare) binary is needed to check if two files are equal (or different)"
        fzf: "fzf (fuzzy finder) is needed for content preview and interactivity"
        nc: "nc (gnu-netcat) is needed to search for closed/unused ports"
        head: "head is needed to check UA version of each file"
    }

    # HACK: Not sure why `par-each`; just craving for performance.
    $l | columns | par-each {|$it| # a dependency
        if (which $it | is-empty) {
            error make {
                msg: ($l | get $it)
            }
        }
    }

}

# 🪟 UPDATE z.nu on CONFIG
# 🔑 PROVIDES: main
# basically duplicates `/x/m/z.nu` into `$D/z.nu` (if their content differs)
# bool specifier is needed to prevent long code (due to if) on main
# returns true if success, false if not copied
def _update [
    --silent (-s): string # either "true" or "false"
] {
	error make {msg: "Update no longer works. Migrate to serai."}

    if ($silent | describe) != bool {
        error make {msg: "$silent must be bool!"}
    }
    let $source = "/x/m/z.nu" # always there and updated
    let $target = $"($D)/z.nu" # often outdated
    let $cmp_result = (open --raw $source | ^cmp $target| complete)
    if $cmp_result.exit_code == 0 {
        print $"Both files \((_A -u $source) and (_A -u $target)) are already equal."
        return false
    }
    if not $silent {
        # 🐍: You know why $target is specified before $source
        do -i {^delta -n --no-gitconfig --paging=never $target $source}
        if (_C (_A -p "y/n?")) == false {
            print (_A -r "Cancelling update...")
            return false
        }
    }
    cp -f $source $target
    print $"(_A -u $source) ➜ (_A -u $target) ✅"
    return true
}

# 🪟 PARSE bash-like env ($HOME = ~)
# 🔑 PROVIDES: _parse-cm
# TODO: Support ${ENV} syntax
export def _parse-env-sh [
    s: string
] {
    let $components = ($s | split row "/")
    ($components | par-each -k {|$it|
        match ($it =~ '^\$') {
            true => {$env | get ($it | str substring 1..)}
            false => {$it}
        }
    }) | str join "/"
}

# 🪟 PARSE comment-stripped line
# 🔑 PROVIDES: _parse
export def _parse-cm [
    s: string
] {
    mut $obj = {}
    mut $i = 0
    loop {
        let $_s = ($s | str substring $i..-1)
        let $spaces_tmp = ($_s | parse -r '(?<spaces>^\s*)' | get spaces)
        let $spaces_len = if ($spaces_tmp | is-not-empty) {$spaces_tmp.0 | str length} else {0}
        let $parsed = ($_s | parse -r '^\s*(?<k>\w+)(?<sep>[ =])?')
        if ($parsed | is-empty) {return $obj}
        let $k = ($parsed | get k.0)
        $i += $spaces_len + ($k | str length)
        if ($parsed | get sep.0) == "=" {
            $i += 1
            let $__s = ($s | str substring $i..-1)
            let $delim = ($__s | str substring 0..0)
            mut $v = (match $delim {
                "'" => ($__s | parse -r `^'(?<v>[^']+)'` | get v.0)
                '"' => ($__s | parse -r `^"(?<v>[^"]+)"` | get v.0)
                _ => ($__s | parse -r `^(?<v>[^\s]+)` | get v.0)
            })
            # NOTE: $ variable will be bash-like parsed
            if ($k in ["d" "p" "s" "g"]) {
                $v = (_parse-env-sh $v)
            }
            $obj = ($obj | merge {$k: $v})
            $i += ($v | str length) + (if $delim in ["'" '"'] {2} else {0})
        } else {
            $obj = ($obj | merge {$k: true})
        }
    }
}

# 🪟 PARSE line with optional lnum
# 🔑 PROVIDES: main
# basically duplicates `/x/m/z.nu` into `$D/z.nu` (if their content differs)
# bool specifier is needed to prevent long code (due to if) on main
# returns true if success, false if not copied
export def _parse [
    s: string
    --lnum: int
] {
    let $prefix = if ($lnum | is-not-empty) {{lnum: $lnum}} else {{}}

    # NOTE: cb-end
    if $s =~ '^`{3,}$' {
        return ($prefix | merge {
            type: "cb-end"
            obj: {
                char: "`"
                len: ($s | str length)
            }
        })
    }

    # NOTE: cb-init
    if $s =~ '^`{3,}[^\s]+' {
        return ($prefix | merge {
            type: "cb-init"
            obj: {
                char: "`"
                len: ($s | parse -r '^(?<x>`{3,})' | get x.0 | str length)
                lang: ($s | parse -r '^`{3,}(?<lang>[^\s]+)' | get lang.0)
            }
        })
    }

    # NOTE: hr
    if $s =~ '^(-{3,}|_{3,}|\*{3,})$' {
        return ($prefix | merge {
            type: "hr"
            obj: {
                char: ($s | str substring 0..0)
                len: ($s | str length)
            }
        })
    }

    # NOTE: heading
    if $s =~ '^#{1,6}\s+[^\s]+' {
        let $tmp = ($s | split row ' ')
        let $ids = ($tmp | last | parse -r '{#(?<id>[^\s]+)}' | get id)
        let $obj = match ($ids | is-not-empty) {
            true => {
                level: ($tmp.0 | str length)
                title: ($tmp | _slice 1..-2 | str join ' ')
                id: $ids.0
            }
            false => {
                level: ($tmp.0 | str length)
                title: ($tmp | skip | str join ' ')
            }
        }
        return ($prefix | merge {
            type: "heading"
            obj: $obj
        })
    }

    # NOTE: cm-next
    # TODO: Currently not supported due to complexity!
    if $s =~ '^<!-- \. .+ -->$' {
        error make {
            msg: $"Currently, (_A -u 'cm-next') is not supported!"
        }
        return ($prefix | merge {
            type: "cm-next"
            obj: (_parse-cm ($s | str substring 7..-4))
        })
    }

    # NOTE: cm-init
    if $s =~ '^<!-- [\w]+[= ].+ -->$' {
        let $init = ($s | parse -r '^<!-- (?<init>[\w]+)[= ]' | get init.0)
        return ($prefix | merge {
            type: "cm-init"
            obj: ({init: $init} | merge (_parse-cm ($s | str substring 4..-4)))
        })
    }

    # NOTE: _
    return {}
}


# 🪟 Generate files from parsed MD data
# 🔑 PROVIDES: main
def _generate [
    r: record
] {
    let $path = $r.path
    let $lines = $r.lines
    let $lines_len = ($lines | length)
    mut $mds = $r.mds

    mut $gens = {}
    # NOTE: Config (mc=c) list<{lnum d db}>
    mut $confs = []
    mut $conf = {} # current conf

    # 🐍: Let’s try $mds exhaustion (instead of i continuation)
    while ($mds | is-not-empty) {
        # {mds: $mds gens: $gens} | explore
        let $lnum = $mds.0.lnum
        let $type = $mds.0.type
        let $obj = $mds.0.obj

        # NOTE: Config mode
        # TODO: Supports cm-next
        if ($type == "cm-init" and
            $obj.init? == "mc" and
            $obj.mc? == "c") {
            # TODO: Create better error
            if ("d" not-in $obj) {error make {msg: "No d in mc=c"}}
            $conf = ({
                lnum: $lnum
                d: null # MUST BE DEFINED!
                db: "keep"
            } | merge $obj)
            $confs ++= [$conf]

            $mds = ($mds | skip)
            continue
        }

        # NOTE: File duplication
        # TODO: Supports cm-next
        if ($type == "cm-init" and
            $obj.init? == "mc" and
            $obj.mc? == "d") {
            let $p = ([$conf.d $obj.p] | path join)
            $gens = ($gens | merge {$p: {
                path: $p
                type: "duplicate"
                source: ([($path | path dirname) $obj.s] | path join)
                ext: ($p | path parse | get extension)
            }})

            $mds = ($mds | skip)
            continue
        }

        # NOTE: Symlink generation
        # TODO: Supports cm-next
        if ($type == "cm-init" and
            $obj.init? == "mc" and
            $obj.mc? == "s") {
            let $p = ([$conf.d $obj.p] | path join)
            $gens = ($gens | merge {$p: {
                path: $p
                type: "symlink"
                source: ([($path | path dirname) $obj.s] | path join)
                ext: ($p | path parse | get extension)
            }})

            $mds = ($mds | skip)
            continue
        }

        # NOTE: Clean directory
        # TODO: Supports cm-next
        if ($type == "cm-init" and
            $obj.init? == "mc" and
            $obj.mc? == "x") {
            $gens = ($gens | merge {$"clean-($obj.g)": {
                glob: $obj.g
                type: "clean"
            }})

            $mds = ($mds | skip)
            continue
        }

        # NOTE: Ignore path (so it won’t get deleted)
        # TODO: Supports cm-next
        if ($type == "cm-init" and
            $obj.init? == "mc" and
            $obj.mc? == "i") {
            let $p = ([$conf.d $obj.p] | path join)
            $gens = ($gens | merge {$p: {
                path: $p
                type: "ignore"
            }})

            $mds = ($mds | skip)
            continue
        }

        # NOTE: The following needs next node.
        if ($mds | length) < 2 {
            $mds = ($mds | skip)
            continue
        }
        let $next = $mds.1

        # NOTE: Append via hr (horizontal rule)
        # TODO: Supports cm-next
        if ($type == "hr" and
            $obj.char == "_" and
            $obj.len >= 5 and
            $next.type == "cm-init" and
            $next.obj.init == "mc" and
            $next.obj.mc == "a" and
            $next.obj.t == "hr") {
            # HACK: soft continuation
            let $p = ([$conf.d $next.obj.p] | path join)
            let $_mds = ($mds | skip | skip until {$in.type == "hr" and $in.obj.char == "_" and $in.obj.len >= $obj.len})
            # initialization
            # HACK: Magic number "$lnum + 3" doesn’t look good.
            if $p not-in $gens {
                $gens = ($gens | merge {$p: {
                    path: $p
                    type: "raw"
                    lines: (match ($_mds | is-not-empty) {
                        true => ($lines | _slice ($lnum + 2)..($_mds.0.lnum - 1))
                        false => ($lines | _slice ($lnum + 2)..($lines_len - 1))
                    })
                    pos: {0: [$path ($lnum + 3)]}
                    ext: ($p | path parse | get extension)
                }})
            } else {
                let $gen = ($gens | get $p)
                let $gen = {
                    path: $gen.path
                    type: $gen.type
                    lines: ($gen.lines ++ [""] ++ (match ($_mds | is-not-empty) {
                        true => ($lines | _slice ($lnum + 3)..($_mds.0.lnum - 2))
                        false => ($lines | _slice ($lnum + 3)..($lines_len - 1))
                    }))
                    pos: ($gen.pos | merge {(($gen.lines | length) + 1): [$path ($lnum + 3)]})
                    ext: $gen.ext
                }
                $gens = ($gens | merge {$p: $gen})
            }

            $mds = ($mds | skip 2)
            continue
        }

        # NOTE: The following needs second next node.
        if ($mds | length) < 3 {
            $mds = ($mds | skip)
            continue
        }
        let $next2 = $mds.2

        # NOTE: Append via cb (code block)
        # HACK: It assumes cb-init will be immediately followed by cb-end
        # TODO: Supports cm-next
        if ($type == "cm-init" and
            $obj.init == "mc" and
            $obj.mc == "a" and
            $obj.t? in [null "cb"] and
            $next.type == "cb-init" and
            $next.obj.len >= 3 and
            $next2.type == "cb-end" and
            $next2.obj.len >= $next.obj.len) {
            # HACK: hard continuation
            let $p = ([$conf.d $obj.p] | path join)
            # initialization
            if $p not-in $gens {
                $gens = ($gens | merge {$p: {
                    path: $p
                    type: "raw"
                    lines: ($lines | _slice ($next.lnum + 1)..($next2.lnum - 1))
                    pos: {0: [$path ($next.lnum + 1)]}
                    ext: ($p | path parse | get extension)
                }})
            } else {
                let $gen = ($gens | get $p)
                let $gen = {
                    path: $gen.path
                    type: $gen.type
                    lines: ($gen.lines ++ [""] ++ ($lines | _slice ($next.lnum + 1)..($next2.lnum - 1)))
                    pos: ($gen.pos | merge {(($gen.lines | length) + 1): [$path ($next.lnum + 1)]})
                    ext: $gen.ext
                }
                $gens = ($gens | merge {$p: $gen})
            }

            $mds = ($mds | skip 3)
            continue
        }

        # if not matching anything
        $mds = ($mds | skip)
    }

    # TODO: Return $conf as well to make db=clean work
    return $gens
}

export def _fzf-preview [
    num: string
    --alt
] {
    let $num = ($num | into int)
    let $gen = (open $"($env.FZF_TMPD)/_.nuon" | get $num)
    match [$gen.type $alt] {
        ["raw" false] => {
            print $gen.path
            ^bat --color=always $gen.preview
        }
        ["raw" true] => {
            if ($gen.path | path exists) {
                ^delta -n --no-gitconfig --paging=never $gen.path $gen.preview
            } else {
                print $gen.path
                ^bat --color=always $gen.preview
            }
        }
        ["duplicate" _] => {
            print $gen
        }
        ["symlink" _] => {
            print $gen
        }
        ["ignore" _] => {
            ^bat --color=always $gen.path
        }
        ["remove" _] => {
            ^bat --color=always $gen.path
        }
    }
}

def _get-cmp [
    $gen: any
] {
    # $gen | explore
    match $gen.type {
        "raw" => {
            let $raw = ($gen.lines | str join "\n") + (char nl)
            return ($raw | ^cmp $gen.path | complete).exit_code
        }
        "duplicate" => {
            return (^cmp $gen.source $gen.path | complete).exit_code
        }
        "symlink" => {
            if not ($gen.path | path exists -n) {return 2}
            match ($gen.source == (^readlink $gen.path)) {
                true => {return 0}
                false => {return 1}
            }
        }
        "ignore" => {
            return 0
        }
        "remove" => {
            return 3
        }
    }
}

export def _edit [
    num: string
    lnum: string
] {
    let $num = ($num | into int)
    let $lnum = match ($lnum | is-not-empty) {
        true => {
            try {
                [($lnum | into int) 1] | math max
            } catch {
                1
            }
        }
        false => 1
    }
    let $gen = (open $"($env.FZF_TMPD)/_.nuon" | get $num)
    if ($gen.type == "remove") {
        ^nvim $"+($lnum)" $gen.path
    } else {
        let $tmp = ($gen.pos | columns | take while {|$it|
            ($it | into int) < $lnum} | last)
        let $reminder = $lnum - ($tmp | into int)
        let $pos = ($gen.pos | get $tmp)
        let $ts = (term size)
        let $split = if $ts.rows > $ts.columns {"split"} else {"vsplit"}
        # https://stackoverflow.com/questions/2148397/vim-open-multiples-files-on-different-lines
        let $args = [
            $"+($lnum)"
            $gen.path
            -c
            $":($split) ($pos.0)|:($pos.1 + $reminder)"
        ]
        ^nvim ...$args
    }
}

def _process [
    tgens: any
    --disable-remove
] {
    let catch_resolve_save = {|msg content fo|
        print $"(ansi y)($msg)(ansi reset)"
        print $"(ansi pb)Using sudo instead(ansi reset)"
        $content | ^sudo tee $fo | ignore
    }

    $tgens | each {|$gen|
        let $path = $gen.path
        let $dir = ($path | path dirname)
        if not ($dir | path exists) {
            mkdir $dir
            print $"(_A -p DIR) (_A -u $dir) (_A -g created)"
        }
        match $gen.type {
            "raw" => {
                let $raw = ($gen.lines | str join "\n") + (char nl)
                let $code = ($raw | ^cmp $path | complete).exit_code
                match $code {
                    0 => {print $"(_A -u $path) (_A -d skipped)"}
                    1 => {
                        try {
                            $raw | save -f $path
                        } catch {|err|
                            do $catch_resolve_save $err.msg $raw $path
                        }
                        print $"(_A -u $path) (_A -y updated)"
                    }
                    2 => {
                        try {
                            $raw | save -f $path
                        } catch {|err|
                            do $catch_resolve_save $err.msg $raw $path
                        }
                        print $"(_A -u $path) (_A -g created)"
                    }
                }
            }
            "duplicate"  => {
                let $source = $gen.source
                let $code = (^cmp $source $path | complete).exit_code
                match $code {
                    0 => {print $"(_A -u $path) (_A -d skipped)"}
                    1 => {
                        cp $source $path
                        print $"(_A -u $source) → (_A -u $path) (_A -y updated)"
                    }
                    2 => {
                        cp $source $path
                        print $"(_A -u $source) → (_A -u $path) (_A -g created)"
                    }
                }
            }
            "symlink"  => {
                let $source = ($gen.source | path expand)
                match ($source == ($path | path expand)) {
                    true => {print $"(_A -u $source) ⇢ (_A -u $path) (_A -d skipped)"}
                    false => {
                        ln -sf $source $path
                        print $"(_A -u $source) ⇢ (_A -u $path) (_A -g symlinked)"
                    }
                }
            }
            "ignore" => {
                print $"(_A -u $path) (_A -d ignored)"
            }
            "remove" => {
                if $disable_remove {
                    print $"(_A -u $path) (_A -d 'not removed')"
                }
                rm $path
                print $"(_A -u $path) (_A -r removed)"
            }
        }
    }
    return
}

def _fzf [
    tgens: any
] {
    let $tmpd = (^mktemp -t -d nu-z-XXXXXX)

    let $prompt = [
        (_A -g "P ")
        (_A -y "E ")
    ]

    let $preview = [
        $"use ($Z) _fzf-preview; _fzf-preview {1}"
        $"use ($Z) _fzf-preview; _fzf-preview --alt {1}"
    ]

    let $preview_label = [
        $"(_A -g NORMAL) (_A -u $tmpd)"
        $"(_A -y DIFF) (_A -u $tmpd)"
    ]

    let $bind = ([
        "space:toggle"
        "tab:toggle-all"
        "ctrl-d:preview-half-page-down"
        "pgdn:preview-half-page-down"
        "ctrl-u:preview-half-page-up"
        "pgup:preview-half-page-up"
        "ctrl-r:become(echo restart)"
        "enter:become\(print {+1})"
        $"`:change-preview-label\(($preview_label.0))+change-preview\(($preview.0))"
        $"~:change-preview-label\(($preview_label.1))+change-preview\(($preview.1))"
        $"-:clear-query+change-multi\(0)+disable-search+change-prompt\(($prompt.1))+rebind\(=)"
        $"+:clear-query+change-multi+enable-search+change-prompt\(($prompt.0))+unbind\(=)"
        $"=:execute\(use ($Z) _edit; _edit {1} {q})"
        $".:reload\(open --raw ($tmpd)/_fzfs-filtered.txt)"
        $",:reload\(open --raw ($tmpd)/_fzfs.txt)"
    ] | str join ",")

    # transform tgens
    let $tgens = ($tgens | par-each -k {|$gen|
        let $cmp = (_get-cmp $gen)
        let $preview = match $gen.type {
            "raw" => $"($tmpd)/($gen.num | fill -a r -c 0 -w 5)-($gen.path | path basename)"
            _ => null
        }
        if $gen.type == "raw" {
            let $raw = ($gen.lines | str join "\n") + (char nl)
            $raw | save -f $preview
        }
        return ({cmp: $cmp preview: $preview} | merge $gen)
    })

    # $tgens | explore
    $tgens | save -f $"($tmpd)/_.nuon"
    let $fzfs = ($tgens | par-each -k {|$gen|
        let $tmp = ($gen.path | path basename)
        let $tmp = (match $gen.cmp {
            0 => (_A -f $tmp)
            1 => (_A -y $tmp)
            2 => (_A -g $tmp)
            3 => (_A -r $tmp)
        })
        [$gen.num $tmp $gen.cmp] | str join "\n"
    } | str join (char nul))
    $fzfs | save -f $"($tmpd)/_fzfs.txt"
    # to filter list (cmp > 0)
    $fzfs | split row (char nul) | where ($it | str ends-with 0) == false | str join (char nul) | save -f $"($tmpd)/_fzfs-filtered.txt"

    $env.FZF_TMPD = $tmpd

    loop {
        let $res = ($fzfs | ^fzf ...[
            --ansi
            # -- listen $port
            --bind $bind
            --color dark
            --color "selected-fg:gray,marker:white,bg+:#667799,pointer:white,gutter:-1,info:magenta"
            --cycle
            --delimiter "\n"
            --layout reverse
            --marker "● "
            --multi
            --preview $preview.0
            --preview-window "right,70%,<50(down,50%)"
            --preview-label $preview_label.0
            --prompt $prompt.0
            --read0
            --sort
            --with-nth=2
            --highlight-line
        ])

        if ($res == "restart") {
            continue
        }

        let $selected = ($res | lines | par-each {into int})
        let $tgens = ($tgens | select ...$selected)
        _process $tgens
        return
    }
}

# DEPRECATED: Switch to serai
# 🚪 THE MAIN FUNCTION
# 📋 REQUIRES: _check_deps, ...
# If executed directly, this command/function will be the first one to respond. Needs to be as helpful as possible.
#
# TODO: NO DELETE OPERATION YET (with db=clean).
# TODO: A help section, which I wouldn’t care since I’m the only one using this. Just read the source code.
# NOTE: If you have made too many variables, separate them into its own function.
export def main [
    --update (-u) # ONLY updates the script on config
    --silent (-s) # No confirmation (but still prints)
    --paths (-p): list<string> # Filter paths immediately
    --single (-1): string # Echo a single path of content
    --read-only (-r) # Only read paths, then return as tables (NOT including linked)
    --parse-only # Only parse paths, then return as tables (NOT including linked)
    --ver-only # Only read versions (NOT including linked)
    --skip-only # Only read which one is code (NOT including linked)
    --addition-only # Only read additions made by mc=l
    --postaddition-only # Only read additions made by mc=l
    --gen-only # Only read gens
    --tgen-only # Only read tgens
    --explore (-e) # Explore what should be returned.
    --parse: string
    --parse-cm: string
    --linked # Only used internally, when linked files are to be acquired
    ...paths: string
] {
    _check_deps

    # NOTE: --parse or --parse-cm basically redirects string to the function
    if ($parse | is-not-empty) { return (_parse $parse) }
    if ($parse_cm | is-not-empty) { return (_parse-cm $parse_cm) }

    # NOTE: --update (-u) function basically duplicates `/x/m/z.nu` into `$D/z.nu` (if their content differs)
    if $update { return (_update -s $silent | ignore) }

    # NOTE: From this point, path(s) must be specified.
    # NOTE: No more symlinks due to `path expand`
    mut $paths = if ($paths | is-not-empty) {$paths} else {
        (ls /x/m/*.md | get name | where {^head -qn1 $in | _parse $in | get obj?.z?} | str join "\n" | ^fzf --multi --bind "space:toggle" --preview "^bat --color=always {}" --preview-window "right,70%,<50(down,50%)" | lines)
    }
    if ($paths | is-empty) {return}

    let $_path0 = ([/x/m $paths.0] | path join)
    if not ($paths.0 | path exists) and ($_path0 | path exists) {
        if (_C $"Path does not exist relatively, but exists as ($_path0). Change?") { $paths = [$_path0] } else {return}
    }

    # NOTE: Check UA version of each file.
    # HACK: Will force-check whether path is file via `^head`
    mut $vers = ($paths | par-each -k {|$it| {
        path: $it
        head: (^head -qn1 $it)
    } | merge (^head -qn1 $it | _parse $in)
    })
    if $ver_only and $explore {return ($vers | explore)}
    if $ver_only {return $vers} # WARN: Don’t work as script
    $vers | par-each {|$it|
        if $it.type? != "cm-init" or $it.obj.ua? != "2025" {
            error make {
                msg: $"File (_A -u $it.path) is not UA version 2025.\n\n(_A -y $it.head)"
            }
        }
    }

    # HACK: Will force-check whether path is file via `open --raw`
    mut $reads = ($paths | par-each -k {|$it| {
        path: $it
        content: (open --raw $it)
    }})
    if $read_only and $explore {return ($reads | explore)}
    if $read_only {return $reads} # WARN: Don’t work as script

    # NOTE: Prevent parsing lines and smaller code blocks that are within code blocks.
    mut $skips = ($reads | each {|$it|
        mut $tmp = ($it.content | lines | enumerate | where $it.item =~ '^`{3,}' | update item {|| _parse $in})
        mut $_skips = []
        while ($tmp | is-not-empty) {
            let $lnum = $tmp.0.index
            let $min_length = $tmp.0.item.obj.len
            $tmp = ($tmp | skip)
            $tmp = ($tmp | skip until {$in.item.obj.len >= $min_length})
            if ($tmp | is-not-empty) {
                $_skips ++= (($lnum + 1)..($tmp.0.index - 1) | each {})
                $tmp = ($tmp | skip)
            }
        }
        let $obj = {$it.path: $_skips}
        return $obj
    } | reduce {|a, b| $a | merge $b})
    if $skip_only and $explore {return ($skips | explore)}
    if $skip_only {return $skips} # WARN: Don’t work as script

    # NOTE: Parse lines in parallel for each file
    # NOTE: Each mds: {lnum, type, obj}
    let $_skips = $skips # Make it immutable
    mut $parses = ($reads | par-each -k {|$it|
        let $skipped = ($_skips | get $it.path)
        return {
        path: $it.path
        lines: ($it.content | lines)
        # NOTE: Check parsed inside code block!
        mds: ($it.content | lines | enumerate | where index not-in $skipped | par-each -k {_parse $in.item --lnum $in.index} | where {is-not-empty})
    }})
    if $parse_only and $explore {return ($parses | explore)}
    if $parse_only {return $parses} # WARN: Don’t work as script

    # NOTE: Check whether another file has to be required (with mc=l)
    # WARN: Order is not guaranteed (especially due to par-each)!
    mut $additions = ($parses | par-each -k {|$it|
        let $d = ($it.path | path dirname)
        return ($it.mds | where obj.mc? == "l" | par-each -k {[$d $in.obj.p] | path join})
    } | flatten)
    if $addition_only and $explore {return ($additions | explore)}
    if $addition_only {return $additions} # WARN: Don’t work as script

    # NOTE: Simply return if this command is executed from another.
    if $linked {
        return {
            paths: $paths
            vers: $vers
            reads: $reads
            skips: $skips
            parses: $parses
            additions: $additions
        }
    }

    # NOTE: Updates stuff every time linked file is parsed.
    # NOTE: $additions obviously needs to be emptied
    loop {
        let $_paths = $paths # make it immutable
        $additions = ($additions | skip while {$in in $_paths})
        if ($additions | is-empty) {break}
        let $notexists = ($additions | where ($it | path exists) == false)
        if ($notexists | is-not-empty) {
            error make {msg: $"These files don’t exist:\n($notexists | table)"}
        }
        let $tmp = (main --linked $additions.0)
        $additions = ($additions | skip)

        $paths ++= $tmp.paths
        $vers ++= $tmp.vers
        $reads ++= $tmp.reads
        $skips = ($skips | merge $tmp.skips)
        $parses ++= $tmp.parses
        $additions ++= $tmp.additions
    }
    if $postaddition_only and $explore {return ({
        paths: $paths
        vers: $vers
        reads: $reads
        skips: $skips
        parses: $parses
    }| explore)}
    if $postaddition_only {return {
        paths: $paths
        vers: $vers
        reads: $reads
        skips: $skips
        parses: $parses
    }} # WARN: Don’t work as script

    # 🐍: From here, only $parses is needed

    # 🐍: parses = list<{path lines mds}>
    # NOTE: Iterate mds from top to generate list of paths with content
    # TODO: Generated paths have type of either `hr` or `cb`
    let $gens = ($parses | par-each -k {_generate $in} | reduce {|acc, it|
        mut $_it = $it
        for $tmp in ($acc | columns) {
            if ($tmp not-in $_it) {
                $_it = ($_it | merge {$tmp: ($acc | get $tmp)})
            } else if (
                ($acc | get $tmp).type == "raw" and
                ($_it | get $tmp).type == "raw") {
                let $prev = ($_it | get $tmp)
                mut $next = ($acc | get $tmp)
                let $prev_lines_len = ($prev.lines | length)
                # NOTE: NEED TO ADJUST POSITION on NEXT!
                let $next_pos = ($next.pos | transpose k v | update k {($in | into int) + $prev_lines_len + 1} | par-each -k {{$in.k: $in.v}} | reduce {|a, b| $a | merge $b})
                $_it = ($_it | merge {$tmp: {
                    type: $prev.type
                    lines: ($prev.lines ++ [" "] ++ $next.lines)
                    pos: ($prev.pos | merge $next_pos)
                    ext: $prev.ext
                }})
            } else {
                $_it = ($_it | merge {$tmp: ($acc | get $tmp)})
            }
        }
        return $_it
    })
    if $gen_only and $explore {return ($gens | explore)}
    if $gen_only {return $gens} # WARN: Don’t work as script

    # NOTE: SINGLE MODE
    # TODO: Support absolute path (in addition to basename)
    if ($single | is-not-empty) {
        let $tmp = ($gens | columns | where ($it | path basename) == $single)
        if ($tmp | is-not-empty) {
            let $gen = ($gens | get $tmp.0)
            return (match $gen.type {
                "raw" => ($gen | get lines | str join (char nl))
                # HACK: Won’t make sense to output binary, but whatever...
                # WARN: Don’t work as script!
                "duplicate" => (open --raw $gen.source)
            })
        } else {
            error make {msg: $"To-be generated file (_A -u $single) not found!"}
        }

        error make {msg: "The script should not reach here."}
    }

    # tgens = {path type lines pos ext source}
    mut $tgens = ($gens | transpose k v | where $it.v.type != "clean" | enumerate | each {|$it|
        let $gen = $it.item.v
        return ({num: $it.index} | merge $gen)
    })
    let $gens_paths = ($tgens | get path)
    for $it in ($gens | transpose k v | where $it.v.type == "clean") {
        let $glob = ($it.v.glob | into glob)
        let $list = try {
            (ls $glob | where type == "file" | get name)
        } catch { print (_A -y $"Pattern not found! Glob: ($glob)"); input -n 1 "Press any key to continue..."; []}
        let $list = ($list | where $it not-in $gens_paths)
        for $it2 in $list {
            $tgens ++= [{num: ($tgens | length) path: $it2 cmp: 3 type: remove}]
        }
    }
    let $tgens = $tgens
    if $tgen_only and $explore {return ($tgens | explore)}
    if $tgen_only {return $tgens} # WARN: Don’t work as script

    # $tgens | explore

    if not $silent {
        _fzf $tgens
        return
    }

    # WARN: Use wisely!
    if $silent {
        _process $tgens --disable-remove
        return 
    }

    error make {msg: "The script should not reach here."}
}
