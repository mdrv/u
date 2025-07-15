# AUR package manager
export def main [
    ...pkgnames: string
    --force (-f)
    --gitonly (-g)
] {
    let arch = (uname | get machine)

    # H: Might change regularly
    let blacklist = [
        [surrealist-bin "Much slower than web-app version!"]
        [ttyper "Already available on official PACMAN!"]
    ]
    let caught = ($blacklist | where $it.0 in $pkgnames)
    if ($caught | is-not-empty) {
        error make {msg: $"These packages are blacklisted: ($caught)"}
    }

    def _prettify_pkg [$s] {
        let $prefix = ($s | split row "/" | drop | str join "/")
        let $filename = ($s | split row "/" | last)
        let $dimmed = ($filename | split row "-" | last 3 | str join "-")
        let $bolded = ($filename | split row "-" | drop 3 | str join "-")
        let $modf = $"($bolded)(ansi defd)-($dimmed)(ansi reset)"
        let $modp = if ($prefix | is-empty) {""} else {$"(ansi defd)($prefix)/(ansi reset)"}
        return $"($modp)($modf)"
    }

    if ($pkgnames | is-empty) {
        cd $"/n/aur/($arch)/pkg/"
        let $pkgs = (ls **/*.pkg.tar.* | get name | par-each {|$it| _prettify_pkg $it})
        let $selected = ($pkgs | to text | fzf --ansi -m --bind "space:toggle" | ansi strip | lines)
        print $selected
        sudo pacman -U ...$selected --needed
        return
    }

    if (is-admin) { error make {msg: "You are on root!"} }
    # bug: when package name and git name are different
    for pkgname in $pkgnames {
        let giturl = $"https://aur.archlinux.org/($pkgname).git"
        mut gitpath = $"/n/aur/($arch)/git/($pkgname)/"
        mut pkgpath = $"/n/aur/($arch)/pkg/"

        # Check whether path is desirable.
        print ([$gitpath, $pkgpath] | table -e)
        if not $force and (input "Continue? (y/N) " -n 1) != "y" {
            return
        }

        if ($gitpath | path exists) {
        } else if (^git ls-remote $giturl | is-not-empty) {
            ^git clone --depth=1 $giturl $gitpath
        } else if ($"/n/aur/($arch)/git/ua/($pkgname)/PKGBUILD" | path exists) {
            $gitpath = $"/n/aur/($arch)/git/ua/($pkgname)/"
            $pkgpath = $"/n/aur/($arch)/pkg/ua/"
            print $"Directory changed to:"
            print ([$gitpath, $pkgpath] | table -e)
        } else {
            error make {msg: "Remote git not found and no custom PKGBUILD."}
        }
        cd $gitpath

        if (^git rev-parse --is-inside-work-tree) == "true" {
            git pull
        }

        if $gitonly {
            print "Mode: Git only"
            continue
        }

        do -i { ^makepkg -si --noconfirm --needed --skippgpcheck --skipchecksums }
        # let _f = (ls | where name =~ "(pkg.tar.)(xz|zst)$" | sort-by modified -r | first | get name)
        let _f = (ls | where name =~ "(pkg.tar.)(xz|zst)$" | get name)
        print $_f
        print (pwd)

        let $pkgpath = $pkgpath # need immutable variable
        $_f | each {|$item| cp -u ([(pwd) $item] | path join) $pkgpath } # somehow the source needs absolute path; relative path gives error
    }
}
