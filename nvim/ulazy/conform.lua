return {
	"stevearc/conform.nvim",
	--- @type conform.setupOpts
	opts = {
		formatters_by_ft = {
			lua = { "dprint", "stylua" },
			javascript = { "dprint" },
			javascriptreact = { "dprint" },
			typescript = { "dprint" },
			typescriptreact = { "dprint" },
			markdown = { "dprint" },
			svelte = { "dprint" },
			json = { "dprint" },
			jsonc = { "dprint" },
			html = { "dprint" },
			toml = { "dprint" },
			css = { "dprint" },
			scss = { "dprint" },
			yaml = { "dprint" },
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
