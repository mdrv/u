--- @type LazyPluginSpec
return {
	'akinsho/toggleterm.nvim',
	enabled = true,
	lazy = false,
	config = function()
		require('toggleterm').setup({
			start_in_insert = false,
			-- shell = "nu -n --no-history --no-std-lib", -- much better performance in expense of convenience
			shell = 'nu -n --no-history --no-std-lib', -- much better performance in expense of convenience
			-- shell = "nu", -- skipped input due to slowness
			-- shell = "/bin/sh",
		})
	end,
	keys = {
		{
			'<Leader>x0',
			'<Cmd>ToggleTerm direction=\'float\'<CR>',
			desc = 'ToggleTerm: Open a floating terminal',
		},
		{
			'<Leader>xo',
			'<Cmd>ToggleTerm direction=\'float\'<CR>',
			desc = 'ToggleTerm: Open a floating terminal',
		},
		{
			'<A-q>',
			'<Cmd>exe v:count1 . \'ToggleTerm direction=horizontal\'<CR>',
			mode = { 'n', 'i', 't' },
			desc = 'ToggleTerm: Open a vertical terminal',
		},
		{
			'<A-o>',
			'<Cmd>exe v:count1 . \'ToggleTerm direction=float\'<CR>',
			mode = { 'n', 'i', 't' },
			desc = 'ToggleTerm: Open a floating terminal',
		},
	},
}
