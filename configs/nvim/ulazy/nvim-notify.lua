--- @type LazyPluginSpec
return {
	'rcarriga/nvim-notify',
	--- @type notify.Config
	opts = {
		merge_duplicates = false,
		stages = 'static',
		render = 'minimal',
	},
	config = function(_, opts)
		require('notify').setup(opts)
		vim.notify = require('notify')
	end,
}
