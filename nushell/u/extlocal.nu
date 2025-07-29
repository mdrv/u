# Transfer from external to local filesystem

export def main [
	dir: string = audio
] {

    let $list = (cd $"($env.N)/($dir)"; ls | get name | str join "\n" | fzf -m --bind "space:toggle" | lines)
	if ($list | is-empty) {return "Quitting..."}
	let $target = $"($nu.home-path)($env.N)/($dir)"
    try {
        mkdir $target
    }
    cd $target
    mkdir ...$list
    $list | par-each {|| cp -r $"($env.N)/($dir)/($in)/flac" $"($target)/($in)/"}
}
