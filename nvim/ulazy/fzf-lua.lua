return {
	"ibhagwan/fzf-lua",
	-- optional for icon support
	dependencies = { "nvim-tree/nvim-web-devicons" },
	-- or if using mini.icons/mini.nvim
	-- dependencies = { "echasnovski/mini.icons" },
	opts = {},
	keys = {
		{
			"<Leader>od",
			function()
				require("fzf-lua").zoxide({
					actions = {
						tab = function(selected)
							if #selected == 0 then
								return
							end
							local cwd = selected[1]:match("[^\t]+$") or selected[1]
							vim.cmd.tcd(cwd)
						end,
						enter = function(selected)
							if #selected == 0 then
								return
							end
							local cwd = selected[1]:match("[^\t]+$") or selected[1]
							require("fzf-lua").files({
								cwd = cwd,
								actions = {
									tab = {
										fn = function()
											vim.cmd.tcd(cwd)
										end,
										exec_silent = true,
									},
								},
							})
						end,
					},
				})
			end,
			{ desc = "Search directory (fzf-lua)" },
		},
		{
			"<Leader>oo",
			function()
				require("fzf-lua").oldfiles()
			end,
			{ desc = "Search oldfiles (fzf-lua)" },
		},
		{
			"<Leader>og",
			function()
				require("fzf-lua").live_grep()
			end,
			{ desc = "live_grep (fzf-lua)" },
		},
		{
			"<Leader>hh",
			function()
				require("fzf-lua").helptags()
			end,
			{ desc = "Search helptags (fzf-lua)" },
		},
		{
			"<Leader>kk",
			function()
				require("fzf-lua").keymaps()
			end,
			{ desc = "Search keymaps (fzf-lua)" },
		},
	},
}
