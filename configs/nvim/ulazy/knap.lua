--https://github.com/frabjous/knap
--- @type LazyPluginSpec
return {
	enabled = false,
	'frabjous/knap',
	keys = {
		{
			'<Leader>kp',
			function()
				require('knap').process_once()
			end,
			desc = 'knap: process_once()',
		},
		{
			'<Leader>kq',
			function()
				require('knap').close_viewer()
			end,
			desc = 'knap: close_viewer()',
		},
		{
			'<Leader>ka',
			function()
				require('knap').toggle_autopreviewing()
			end,
			desc = 'knap: toggle_autopreviewing()',
		},
	},
}
