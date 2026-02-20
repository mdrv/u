-- https://github.com/folke/which-key.nvim

--- @type LazyPluginSpec
return {
	'folke/which-key.nvim',
	dependencies = { 'nvim-tree/nvim-web-devicons', 'nvim-mini/mini.icons' },
	event = 'VeryLazy',
	config = function()
		--- @type wk
		local wk = require('which-key')

		-- Setup which-key with default options
		wk.setup({
			-- Your configuration comes here
			-- or leave it empty to use the default settings
			icons = {
				-- Set custom icons for different types of keys
				breadcrumb = '»', -- symbol used in the breadcrumb line
				separator = '→', -- symbol used between a key and it's label
				group = '+', -- symbol prepended to a group
			},
			win = {
				border = 'rounded', -- none, single, double, shadow, rounded
				padding = { 1, 2 }, -- extra window padding [top/bottom, right/left]
				wo = {
					winblend = 0, -- value between 0-100 for transparency
				},
			},
			layout = {
				height = { min = 4, max = 25 }, -- min and max height of the columns
				width = { min = 20, max = 50 }, -- min and max width of the columns
				spacing = 3, -- spacing between columns
				align = 'left', -- align columns left, center or right
			},
		})

		-- Register key groups for better organization
		wk.add({
			{ '<leader>l', group = 'LSP' },
			{ '<leader>z', group = 'OpenCode' },
			{ '<leader>a', group = 'Sidekick' },
			{ '<leader>x', group = 'Execute' },
			{ '<leader>t', group = 'Tab/Tree' },
		})
	end,
}
