return {
	cmd = { "lua-language-server" },
	filetypes = { "lua" },
	root_markers = {
		".luarc.json",
		".luarc.jsonc",
		".luacheckrc",
		".stylua.toml",
		"stylua.toml",
		"selene.toml",
		"selene.yml",
		"dprint.json",
	},
	settings = {
		Lua = {
			runtime = {
				version = "LuaJIT",
			},
			diagnostics = {
				global = { "vim" },
			},
			workspace = {
				ignoreDir = { ".git" },
				checkThirdParty = false,
				-- library = vim.api.nvim_get_runtime_file("lua", true),
				library = {
					vim.env.VIMRUNTIME,
					"${3rd}/luv/library",
					"/x/a/b/serai.nvim",
					"~/.local/share/nvim/lazy/fzf-lua",
					"~/.local/share/nvim/lazy/lazy.nvim",
					"~/.local/share/nvim/lazy/blink.cmp",
					"~/.local/share/nvim/lazy/conform.nvim",
					-- "~/.local/share/nvim/lazy/snacks.nvim",
					-- "~/.local/share/nvim/lazy/nvim-notify",
					-- "~/.local/share/nvim/lazy/yazi.nvim",
				},
			},
		},
	},
}
