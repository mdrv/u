def main [] {
    print -n "Generating mod.nu"
    let $d = ($env.CURRENT_FILE | path dirname)
    cd $d
    mut str = ""
    for x in (ls *.nu | get name) {
        if $x in [_.nu mod.nu] {continue}
        $str += $"export module ./($x)\n"
    }
    $str += $"\n\nexport def x [module: string, args: list<string>] {nu -n ($d)/\($module).nu ...$args}"
    $str | save -f mod.nu
    print " ✅"
}
