--- @type vim.lsp.Config
return {
	cmd = { 'biome' },
	root_markers = {
		'biome.json',
		'biome.jsonc',
		'dprint.json',
	},
	filetypes = {
		'astro',
		'css',
		'graphql',
		'html',
		'javascript',
		'javascriptreact',
		'json',
		'jsonc',
		'svelte',
		'typescript',
		'typescript.tsx',
		'typescriptreact',
		'vue',
	},
}
