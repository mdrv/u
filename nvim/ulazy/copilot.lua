--- @type LazyPluginSpec
return {
	'zbirenbaum/copilot.lua',
	dependencies = {
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
	config = function()
		require('copilot').setup({
			suggestion = {
				enabled = true,
				auto_trigger = true,
				keymap = {
					accept = '<C-j>',
					dismiss = '<C-h>',
				},
			},
			nes = {
				enabled = true,
				keymap = {
					accept_and_goto = "<C-S-j>",
					accept = false,
					dismiss = "<Esc>",
				},
			},
		})
		-- require("copilot.suggestion").toggle_auto_trigger()
	end,
}
