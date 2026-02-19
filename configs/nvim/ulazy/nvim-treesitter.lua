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

		vim.api.nvim_create_user_command(
			'TSInstallWeb',
			'TSInstall astro css html http javascript json json5 jsonc nginx scss tsx typescript svelte vue xml',
			{}
		)
		vim.api.nvim_create_user_command(
			'TSInstallSys',
			'TSInstall bash c cpp csv glsl go hyprlang ini kdl python query regex rust scheme toml tsv yaml zig',
			{}
		)

		vim.treesitter.language.register('markdown', { 'mdx' })
	end,
}
