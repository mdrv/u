--- @type LazyPluginSpec
return {
	'zbirenbaum/copilot.lua',
	dependencies = {
		'ibhagwan/fzf-lua', -- Required for copilot-menu
		{
			'copilotlsp-nvim/copilot-lsp', -- (optional) for NES functionality
			config = function()
				vim.g.copilot_nes_debounce = 500
				-- copilot_ls is disabled by default - enable via copilot menu
			end,
		},
	},
	cmd = 'Copilot',
	event = 'InsertEnter',
	keys = {
		-- Register keymap immediately (before plugin loads)
		{
			'<Leader>zc',
			function()
				require('uu/copilot-menu').open_menu()
			end,
			desc = 'Copilot menu',
		},
	},
	config = function()
		require('copilot').setup({
			suggestion = {
				enabled = true,
				auto_trigger = false,
				keymap = {
					accept = '<C-j>',
					dismiss = '<C-h>',
				},
			},
			nes = {
				enabled = true,
				keymap = {
					accept_and_goto = '<C-m>',
					accept = false,
					dismiss = '<C-n>',
				},
			},
		})
	end,
}
