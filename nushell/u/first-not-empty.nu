export def main [
    l: list<any> # a list of anything
    --allow-null (-a) # allow null as fallback (instead of error)
] {
    let $tmp = ($l | skip while {is-empty})
    if ($tmp | is-empty) {
        if ($allow_null) {return null}
        error make {
            msg: "All values are empty."
            label: {
                text: "Please check here."
                span: (metadata $l).span
            }
        }
    } else { $tmp.0 }
}
