# @module Various short utilities

# Resolve caddy issue: `listen tcp :443: bind: permission denied`
# @link https://serverfault.com/questions/807883/caddy-listen-tcp-443-bind-permission-denied#807884
export def caddy_resolve_net_capability [] {
	sudo setcap CAP_NET_BIND_SERVICE=+eip (which caddy).0.path
}
