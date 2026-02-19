use ($nu.default-config-dir + '/u/first-not-empty.nu')
alias fne = first-not-empty
use ($nu.default-config-dir + '/u/format-obj.nu')

export def main [
    b: bool
    --reason (-r): string = "ERROR"
    --span (-s): record<start: int, end: int>
    s: list<any>
] {
    if not $b {return}

    let $msg = match ($s | is-not-empty) {
        true => {($s | each {format-obj} | str join "\n\n")}
        false => {"An error occurred."}
    }

    let $label = {
        text: $reason
        span: (fne [$span (metadata $b).span])
    }

    error make {
        msg: $msg
        label: $label
    }
}
