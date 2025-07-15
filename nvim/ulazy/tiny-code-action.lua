return {
	"rachartier/tiny-code-action.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	event = "LspAttach",
	opts = {
		backend = "delta",
		picker = {
			"buffer",
			opts = {
				hotkeys = true,
			},
		},
	},
	keys = {
		{
			"<Leader>ca",
			function()
				require("tiny-code-action").code_action()
			end,
			{ noremap = true, silent = true },
		},
	},
}
