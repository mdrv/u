export def main [
	root: string
] {
    let path = $"/x/b/config/shared/($root)/"
	sudo certbot certonly --domains $"*.($root)" --agree-tos --email "octh@outlook.co.id" --force-interactive  --manual --preferred-challenges dns --debug-challenges --cert-path $path --chain-path $path --fullchain-path $path --key-path $path
}
