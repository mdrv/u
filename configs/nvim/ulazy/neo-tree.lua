--- @type LazyPluginSpec
return {
	'nvim-neo-tree/neo-tree.nvim',
	branch = 'v3.x',
	dependencies = {
		'nvim-lua/plenary.nvim',
		'nvim-tree/nvim-web-devicons',
		'MunifTanjim/nui.nvim',
		's1n7ax/nvim-window-picker',
	},
	lazy = false, -- neo-tree will lazily load itself
	opts = {
		-- fill any relevant options here
	},
	config = function(_, opts)
		-- require("neo-tree").setup(opts)
		if vim.env.SHOW_NEOTREE == '1' then
			vim.cmd('Neotree show')
		end
	end,
	keys = {
		{
			'<Leader>bo',
			function()
				require('neo-tree.command').execute({ toggle = true, dir = vim.uv.cwd() })
			end,
			desc = 'Toggle NeoTree (cwd)',
		},
	},
}
