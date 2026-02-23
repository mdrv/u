--- @type LazyPluginSpec
return {
	"dariuscorvus/tree-sitter-surrealdb.nvim",
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	lazy = false,  -- This makes sure it loads immediately
	ft = { "surql", "surrealql" },
	config = function()
		require("tree-sitter-surrealdb").setup()
	end,
}
