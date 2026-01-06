export def main [
	--type (-t) = flac
	--reverse (-r)
] {
	if ($reverse) {
		print "Not implemented yet"
		return
	}
    # let $list = (cd /n/audio; ls | get name | input list -m)
    let $list = (cd /n/audio; ls | get name | str join "\n" | fzf -m --bind "space:toggle" | lines)
	if ($list | is-empty) {
		print "No selected directory"
		return
	}
    try {
        mkdir ~/n/audio
    }
    cd ~/n/audio
    mkdir ...$list
    $list | par-each {|| cp -r $"/n/audio/($in)/($type)" $"($nu.home-path)/n/audio/($in)/"}
}
