# Use this for pixiv (to prevent duplicate via avif)
export def main [
    query: list<string>
    --dry-run (-d)
] {
    let $list = run-external "gallery-dl" "-s" ...$query | lines | each { str substring 2.. } | where not ( $"/n/img/pixiv/avif/($it).avif" | path exists ) | where not ( $"/n/img/pixiv/($it)" | path exists )
    print $list
    if ($list | is-not-empty) and (not $dry_run) {
        $list | each { $"https://pixiv.net/artworks/($in | str substring ..<($in | str index-of '_'))" } | uniq | gallery-dl ...$in
    }
}
