--- @type LazyPluginSpec
return {
	'zbirenbaum/copilot.lua',
	requires = {
		'copilotlsp-nvim/copilot-lsp', -- (optional) for NES functionality
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
		})
		-- require("copilot.suggestion").toggle_auto_trigger()
	end,
}
