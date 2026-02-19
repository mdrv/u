use ($nu.default-config-dir + /u/format-obj.nu)
alias fo = format-obj

export def main [
    b: bool
    s: list<any>
    --yes (-y) # continue no matter the input
] {
    if not $b { return }
    match ($s | length) {
        0 => {}
        1 => {print ($s.0 | fo)}
        _ => {print ($s | par-each -k {fo})}
    }
    match $yes {
        true => {print "Let’s continue."}
        false => {print "Continue? (y/n/e)"}
    }
    loop {
        let $res = (input -n 1 | str downcase)
        if $yes or $res == "y" {
            break
        } else if $res == "n" {
            error make {
                msg: $"(ansi gb)Program has been terminated manually.(ansi reset)"
                label: {
                    text: "This line was last reached."
                    span: (metadata $b).span
                }
            }
        } else if $res == "e" {
            $s | explore
        }
    }
}
