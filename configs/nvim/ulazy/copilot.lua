--- @type LazyPluginSpec
	return {
	'zbirenbaum/copilot.lua',
	dependencies = {
		'ibhagwan/fzf-lua', -- Required for copilot-menu
		{
			'copilotlsp-nvim/copilot-lsp', -- (optional) for NES functionality
			config = function()
				vim.g.copilot_nes_debounce = 500
				vim.lsp.enable("copilot_ls")
			end,
		}
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
				auto_trigger = false, -- Disabled for manual control via menu
				keymap = {
					accept = '<C-j>',
					dismiss = '<C-h>',
				},
			},
			nes = {
				enabled = true,
				keymap = {
					accept_and_goto = "<C-j>",
					accept = false,
					dismiss = "<C-h>",
				},
			},
		})
	end,
}
