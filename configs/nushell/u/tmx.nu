export def fonts [] {
    let uid = (open --raw /data/system/packages.list | grep "com.termux " | awk '{print $2}')
    if ($uid | is-empty) {
        error make {msg: "$uid for termux not found!"}
    }
    let dir = "/data/data/com.termux/files/home/.termux/"
    let repo = "ryanoasis/nerd-fonts"
    let gitdir = "patched-fonts/JetBrainsMono/Ligatures"
    let files = [
        {
            filename: "font.ttf"
            gitstem: "Regular/JetBrainsMonoNerdFont-Regular.ttf"
        }
        {
            filename: "font-italic.ttf"
            gitstem: "Italic/JetBrainsMonoNerdFont-Italic.ttf"
        }
        {
            filename: "font-bold.ttf"
            gitstem: "Bold/JetBrainsMonoNerdFont-Bold.ttf"
        }
        {
            filename: "font-bold-italic.ttf"
            gitstem: "BoldItalic/JetBrainsMonoNerdFont-BoldItalic.ttf"
        }
    ]
    for $f in $files {
        let local = ([$dir $f.filename] | path join)
        print $"(ansi yb)($f.filename)(ansi reset)"
        if (sudo nu -c $"echo r#'($local)'# | path exists") == 'true' {
            print "File already exists. Check hash? (y/N)"
            if (input -n 1 | str downcase) != 'y' {
                continue
            }
            let remotehash = (http get $"https://api.github.com/repos/($repo)/contents/($gitdir)/($f.gitstem)" | get sha)
            let localhash = (sudo git hash-object $local)
            print [$remotehash $localhash]
            if ($remotehash == $localhash) {
                print "Hashes are the same. Skipping..."
                continue
            }
            print "Download the new one?"
            if (input -n 1 | str downcase) != 'y' {
                continue
            }
        }
        print "Downloading..."
        http get $"https://github.com/($repo)/raw/refs/heads/master/($gitdir)/($f.gitstem)" | sudo tee $local out> /dev/null
        sudo chmod a+r $local
        sudo chown $"(uid):(uid)" $local 
        print $"(ansi gb)Download finished(ansi reset)"
    }
}
