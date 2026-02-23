--- @type LazyPluginSpec
return {
	'rachartier/tiny-inline-diagnostic.nvim',
	event = 'VeryLazy',
	priority = 1000,
	config = function()
		require('tiny-inline-diagnostic').setup({
			options = {
				multilines = {
					enabled = true, -- Multi-line display for long messages
				},
				show_source = {
					enabled = true, -- Show LSP name (e.g., [tsls])
				},
				add_messages = {
					display_count = true, -- Show diagnostic count in statusline
				},
			},
		})
		vim.diagnostic.config({ virtual_text = false }) -- Disable Neovim's default virtual text diagnostics
	end,
}
