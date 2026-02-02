const u = $"($nu.default-config-dir)/u"

def preview [s: string] {
    let $ext = ($s | path parse | get extension)
    if $ext == "txt" { ^bat $s }
	else if $ext == "png" { ^chafafzf $s }
}

export def fzf [s: string] {
    let $preview = $"use ($u)/stt.nu; stt preview stt {}"
    let $previewWindow = '60%,left,border-none'
    loop {
        let $res = (glob ($s + "*") | str join "\n" | ^fzf --ansi --preview $preview --preview-window $previewWindow)
        if ($res | is-empty) {return}

        let $ext = ($res | path parse | get extension)
        if $ext == "txt" {
            (open --raw $res) | ansi strip | nvim -mR -
        } else if $ext == "png" {
            ^qimgv $res
        } else if $ext == "wav" {
            ^mpv $res
        }
    }
}

export def main [l: string = "jpn"] {
    if DISPLAY not-in $env {
        error make {msg: "on-screen translate won’t work without display"}
    } else if (which tesseract grim slurp wdic trans | get command | uniq | length) < 5 {
        let $msg = "Need tesseract, grim, slurp, translate-shell (trans), wish (wdic; also needs autoconf and automake to install, else will get `autoreconf: command not found`), wish-edict"
        ^notify-send -u critical -t 5000 $msg
        error make {msg: $msg}
        return
    }

    mkdir /tmp/stt
    let $out = $"/tmp/stt/(date now | format date %s).png"
    ^grim -g (^slurp) $out
    print $"screenshot: ($out)"
    let $str = (^tesseract --psm 7 -l $l $out - | str replace -a " " "")
	print $"string: ($str)"
    # ^wdic $str --nopager --color | save -f $"($out).wdic.txt"
    # ^trans $str -s ja -t en | save -f $"($out).trans.txt"
    # ^trans $str -s ja --no-translate -download-audio-as $"($out).trans.wav"
	echo $str | wl-copy
	^notify-send $"Copied: ($str)"
}
