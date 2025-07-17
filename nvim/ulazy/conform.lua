return {
	"stevearc/conform.nvim",
	--- @type conform.setupOpts
	opts = {
		formatters_by_ft = {
			lua = { "dprint", "stylua" },
			javascript = { "dprint", "biome", "prettierd", "prettier" },
			javascriptreact = { "dprint", "biome", "prettierd", "prettier" },
			typescript = { "dprint", "biome", "prettierd", "prettier" },
			typescriptreact = { "dprint", "biome", "prettierd", "prettier" },
			svelte = { "dprint" },
			json = { "dprint" },
			jsonc = { "dprint" },
			html = { "dprint" },
			toml = { "dprint" },
		},
	},
	keys = {
		{
			"<Leader>ff",
			function()
				require("conform").format({ async = true })
			end,
		},
	},
}
