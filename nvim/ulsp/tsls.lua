-- id=lsp-tsls
-- #tag= typescript
-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/configs/ts_ls.lua
return {
	cmd = { "typescript-language-server", "--stdio" },
	filetypes = {
		"javascript",
		"javascriptreact",
		"javascript.jsx",
		"typescript",
		"typescriptreact",
		"typescript.tsx",
	},
	root_markers = { "tsconfig.json", "package.json" },
	init_options = {
		hostInfo = "neovim",
		preferences = {
			quotePreference = "single",
		},
	},
	settings = {
		javascript = {
			format = {
				semicolons = "remove",
				tabSize = 4,
			},
		},
		typescript = {
			format = {
				semicolons = "remove",
				tabSize = 4,
			},
		},
		implicitProjectConfiguration = {
			checkJs = true,
		},
	},
}
