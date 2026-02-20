use ($nu.default-config-dir + "/u/error-if.nu")
alias eif = error-if
use ($nu.default-config-dir + "/u/confirm-if.nu")
alias cif = confirm-if

# Mount manager
export def main [
    t: string = "l" # command type
    p?: string # dev/partition
    --confirm (-c)
] {
    let actions = {
        u: "umount"
        l: "list"
        m: "mount /mnt"
        n: "mount /n"
        a: "mount /mnt + /n + pacman"
        k: "udisksctl power-off"
        uk: "umount & udisksctl power-off"
    }

    eif ($t not-in ($actions | columns)) [$actions]

    if $t == "l" {
        let $out = (^sudo lsblk -o name,label,mountpoints -rn | complete).stdout
        let $out = ($out | lines | par-each -k {|$it|
            let $lw = ($it | split row " ")
            match ($lw | where (is-not-empty) | length) {
                1 => $"(ansi defd)($lw.0)(ansi reset)"
                _ if ($lw.2 | is-not-empty) => $"(ansi gb)($lw.0)(ansi pd) ($lw.1)(ansi defd) ($lw.2? | split row '\x0a')(ansi reset)"
                _ if ($lw.2 | is-empty) => $"(ansi gb)($lw.0)(ansi pd) ($lw.1)(ansi reset)"
            }
        } | str join "\n")
        return $out
    }

    let $p = if ($p | is-not-empty) {$p} else {(sudo lsblk -o name -rn | str trim | split row "\n" | input list -f)}

    let $paths = ([$"/dev/($p)" $"/dev/block/($p)"] | skip until {path exists})
    eif ($paths | is-empty) [
        "Path does not exist!"
        $paths
    ]
    let $path = $paths.0

    def u [] {
        if (mount | find $path | is-empty) {
            print $"(ansi bb)($path)(ansi defd) skipped(ansi reset)"
            return
        }
        print $"(ansi pd)sudo umount -A ($path)(ansi reset)"
        let $res = (^sudo umount -A $path | complete)
        match $res.exit_code {
            0 => { print $"(ansi bb)($path)(ansi gb) unmounted(ansi reset)" }
            _ => { print $"(ansi rb)ERROR(ansi defd)\n($res.stderr)" }
        }
    }

    def k [] {
        print $"(ansi pd)sudo udisksctl power-off -b ($path)(ansi reset)"
        let $res = (^sudo udisksctl power-off -b $path | complete)
        match $res.exit_code {
            0 => {
                print $"(ansi bb)($path)(ansi gb) turned off(ansi reset)"
                return
            }
            _ => {
                print $"(ansi rb)ERROR(ansi defd)\n($res.stderr)"
                return
            }
        }
    }

    if $t == "u" {
        u; return;
    } else if $t == "k" {
        k; return;
    } else if $t == "uk" {
        u; k; return;
    }

    let label = (sudo blkid -s LABEL -o value $path)
    let arch = (uname | get machine)

    print {
        part: $p
        path: $path
        label: $label
        type: $t
    }

    if ($label | is-empty) {
        print $"(ansi yb)WARNING: Label not detected!(ansi reset)"
        cif true []
    } else {
        cif $confirm []
    }

    let preset = {
        a: {|s| {s: $s, t: $"/mnt($s)"}}
        b: {|s| {s: $s, t: $"/mnt/label/($label)"}}
        n: {|s| {mode: "bind", s: $"/mnt($s)/n", t: "/n"}}
        pmpkg: {|s| {mode: "bind", s: $"/mnt($s)/n/pacman/($arch)/pkg", t: "/var/cache/pacman/pkg"}}
        pmsync: {|s| {mode: "bind", s: $"/mnt($s)/n/pacman/($arch)/sync", t: "/var/lib/pacman/sync"}}
    }

    let list = {
        m: [a b]
        n: [n]
        a: [a b n pmpkg pmsync]
    }

    for $it in ($list | get $t) {
        let $dirs = ( do ($preset | get $it) $path )
        let $_out = (^findmnt -r -o source $dirs.t | complete).stdout
        if ($_out | is-not-empty) {
            print $"(ansi bb)($dirs.t)(ansi yb) already mounted(ansi defd) by ($_out | lines | last)(ansi reset)"
            continue
        }
        if not ($dirs.t | path exists) {
            ^sudo mkdir -p $dirs.t
            print $"DIR (ansi bb)($dirs.t)(ansi gb) created(ansi reset)"
        }
        match $dirs.mode? {
            "bind" => {
                print -n $"($dirs.s) → ($dirs.t) (ansi defd)\(bind)(ansi reset)"
                ^sudo mount -o bind $dirs.s $dirs.t
                print " ✅"
            }
            _ => {
                print -n $"($dirs.s) → ($dirs.t) (ansi defd)\(normal)(ansi reset)"
                ^sudo mount $dirs.s $dirs.t
                print " ✅"
            }
        }
    }
}
