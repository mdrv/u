const SUFFIX = r#'
def mod_list [] {{
	completions: (ls -as ($"($env.FILE_PWD)/*.nu" | into glob) | get name | where $it != mod.nu | str substring ..-4)
}}

# bypass export commands; in case executed directly
export def --wrapped x [mod_name: string@mod_list, ...args: string] {nu -n ($env.FILE_PWD)/($mod_name).nu ...$args}
'#

# overwrites mod.nu
export def main [] {
    print -n "Generating mod.nu"
    mut str = ""
    for x in (ls *.nu | get name) {
        if $x in [_.nu mod.nu] {continue}
        $str += $"export module ./($x)\n"
    }
    $str += $SUFFIX
	if ("mod.nu" | path exists) { mv mod.nu mod.nu~ }
    $str | save -f mod.nu
    print " ✅"
}
