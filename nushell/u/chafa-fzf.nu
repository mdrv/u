export def main [
    s?: string
    --clear (-c) # clear cache/tmp
] {
    if ($clear) {
        rm ($"($nu.temp-dir)/nu-chafafzf-*.avif" | into glob)
        return
    }
    if ($s | is-empty) {
        print "Please input string."
        return
    }
    let $_p = ($s | path parse)
    let $s = match $_p.extension {
        _ => {
            let $_s = $"($nu.temp-dir)/nu-chafafzf-(open $s | hash md5).avif"
            if not ($_s | path exists) or ((du -r $_s | get apparent.0 | into int) == 0) {
                ^vipsthumbnail $s -s 720> -o $_s --vips-concurrency=4
            }
            $_s
        }
    }
    ^chafa --clear -w 3 -c full --align=center,center -s $'($env.FZF_PREVIEW_COLUMNS)x(($env.FZF_PREVIEW_LINES | into int) - 2)' --view-size $'($env.FZF_PREVIEW_COLUMNS)x($env.FZF_PREVIEW_LINES)' $s
}
