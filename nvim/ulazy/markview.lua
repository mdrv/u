-- https://github.com/OXY2DEV/markview.nvim

--- @type LazyPluginSpec
return {
	enabled = false,
	'OXY2DEV/markview.nvim',
	lazy = false,

    -- Completion for `blink.cmp`
    dependencies = { "saghen/blink.cmp" },
	keys = {
		{
			'<Leader>mv',
			function()
				require('markview.commands').Toggle()
			end,
			desc = 'knap: process_once()',
		},
	}
}
