export def main [] {
	config reset -w
	const d = $nu.default-config-dir

	print -n $"Adding (ansi bb)empty.nu(ansi reset)"
	"" | save -f $"($d)/empty.nu"
	print " ✅"

	print -n $"Updating (ansi bb)env.nu(ansi reset)"
	r###'
	const d = $nu.default-config-dir
	const _ = $"($d)/empty.nu"
	def _E [f] {
		print $"(ansi bb)📢 ($f) (ansi y)can’t be sourced!(ansi reset)"
	}
	'### | save -a $"($d)/env.nu" #1
	([uenv.nu] | each { $"
const f = r#'($in)'#" + r###'; const p = $"($d)/($f)"
if not ($p | path exists) {_E $f}
source (if ($p | path exists) {$p} else {$_})
'###}) | str join | save -a $"($d)/env.nu" #2
	print " ✅"

	print -n $"Updating (ansi bb)config.nu(ansi reset)"
	([uconfig.nu] | each { $"
const f = r#'($in)'#" + r###'; const p = $"($d)/($f)"
if not ($p | path exists) {_E $f}
source (if ($p | path exists) {$p} else {$_})
'###}) | str join | save -a $"($d)/config.nu" #1
	(char nl) + "hide _E" | save -a $"($d)/config.nu" #2
	print " ✅"

	print -n $"Adding (ansi bb)zoxide.nu(ansi reset)"
	if (which zoxide | is-not-empty) {
		^zoxide init nushell | str replace -a "alias z" "alias c" | save -f $"($d)/zoxide.nu"
		print " ✅"
	} else {
		print $" 📢 (ansi bb)zoxide(ansi y) can’t be executed!(ansi reset)"
	}

	print -n $"Adding (ansi bb)atuin.nu(ansi reset)"
	if (which atuin | is-not-empty) {
		^atuin init nu --disable-up-arrow | save -f $"($d)/atuin.nu"
		print " ✅"
	} else {
		print $" 📢 (ansi bb)atuin(ansi y) can’t be executed!(ansi reset)"
	}
}
