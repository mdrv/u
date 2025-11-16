--- @type LazyPluginSpec
return {
	'nvim-treesitter/nvim-treesitter',
	branch = 'master',
	lazy = false,
	build = ':TSUpdate',
	opts = {
		ensure_installed = { 'html', 'lua', 'markdown', 'markdown_inline', 'vim', 'vimdoc' },
		sync_install = false,
		highlight = { enable = true },
		indent = { enable = true },
	},
	config = function(_, opts)
		require('nvim-treesitter.configs').setup(opts)
	end,
}
