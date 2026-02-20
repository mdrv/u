--- @type LazyPluginSpec
return {
	enabled = false,
	dir = vim.fn.stdpath('config') .. '/lua/unavigate',
	name = 'unavigate',
	lazy = false,
	opts = {
		keymaps = true,
		id_search_keymap = '<Leader>oi', -- Search ID tags with fzf
	},
	config = function(_, opts)
		require('unavigate').setup(opts)
	end,
}
