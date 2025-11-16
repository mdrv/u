--- @type vim.lsp.Config
return {
	cmd = { 'vscode-json-language-server', '--stdio' },
	filetypes = { 'json', 'jsonc' },
	root_markers = { 'package.json' },
	settings = {
		json = {
			schemas = {
				-- require("schemastore").json.schemas(),
				{
					fileMatch = { 'package.json' },
					url = 'https://json.schemastore.org/package.json',
				},
				{
					fileMatch = { 'tsconfig.json', 'tsconfig.*.json' },
					url = 'http://json.schemastore.org/tsconfig',
				},
				{
					fileMatch = { 'biome.json' },
					url = 'https://biomejs.dev/schemas/latest/schema.json',
				},
			},
			validate = { enable = true },
		},
	},
}
