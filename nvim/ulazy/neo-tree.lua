return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
		"s1n7ax/nvim-window-picker",
	},
	lazy = false, -- neo-tree will lazily load itself
	opts = {
		-- fill any relevant options here
	},
	keys = {
		{
			"<Leader>bo",
			function()
				require("neo-tree.command").execute({ toggle = true, dir = vim.uv.cwd() })
			end,
			desc = "Toggle NeoTree (cwd)",
		},
	},
}
