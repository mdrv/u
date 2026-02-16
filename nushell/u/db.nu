# @module SurrealDB helpers

# Run SurrealDB instance easily
export def main [
	--log: string
] {
	let $C = (open ($nu.home-dir)/.u.nuon | get DB)
	let LOG = ($log | default $C.LOG? | default "info")
	let $args = [
		"--deny-all"
		"--no-identification-headers"
		"--strict"
		"--log"
		$LOG
		"--allow-funcs"
		($C.ALLOW_FUNCS | str join ",")
		"--bind"
		$C.BIND
		$C.PATH
	]
	print $args
	with-env $C.ENV { run-external surreal start ...$args }
}
