-- https://github.com/sudo-tee/opencode.nvim
-- Last updated: 2026-01-31

--- @type LazyPluginSpec
return {
	'sudo-tee/opencode.nvim',
	config = function()
		require('opencode').setup({
			default_global_keymaps = true, -- If false, disables all default global keymaps
			default_mode = 'plan', -- 'build' or 'plan' or any custom configured. @see [OpenCode Agents](https://opencode.ai/docs/modes/)
			keymap_prefix = '<leader>z', -- Default keymap prefix for global keymaps change to your preferred prefix and it will be applied to all keymaps starting with <leader>o
		})
	end,
	dependencies = {
		'nvim-lua/plenary.nvim',
		{
			'MeanderingProgrammer/render-markdown.nvim',
			opts = {
				anti_conceal = { enabled = false },
				file_types = { 'markdown', 'opencode_output' },
				html = {
					comment = {
						conceal = false,
					},
				},
			},
			ft = { 'markdown', 'Avante', 'copilot-chat', 'opencode_output' },
			keys = {
				{
					'<Leader>mv',
					function()
						require('render-markdown').buf_toggle()
					end,
					desc = 'Toggle render-markdown.nvim (buffer)',
				},
			},
		},
		-- Optional, for file mentions and commands completion, pick only one
		'saghen/blink.cmp',
		-- 'hrsh7th/nvim-cmp',

		-- Optional, for file mentions picker, pick only one
		'folke/snacks.nvim',
		-- 'nvim-telescope/telescope.nvim',
		-- 'ibhagwan/fzf-lua',
		-- 'nvim_mini/mini.nvim',
	},
}

-- unused since 2026-02-01
--- @type LazyPluginSpec
--[[
return {
	'NickvanDyke/opencode.nvim',
	dependencies = {
		-- Recommended for `ask()` and `select()`.
		-- Required for `snacks` provider.
		---@module 'snacks' <- Loads `snacks.nvim` types for configuration intellisense.
		{ 'folke/snacks.nvim', opts = { input = {}, picker = {}, terminal = {} } },
	},
	config = function()
		---@type opencode.Opts
		vim.g.opencode_opts = {
			-- Fix for SSE decode errors and buffer glitching with neo-tree
			events = {
				enabled = true, -- Keep SSE enabled
				reload = false, -- Disable auto-reload to prevent buffer glitching
			},
			provider = {
				snacks = {
					auto_close = true, -- Close terminal on exit
					win = {
						position = 'right',
						enter = false,
					},
				},
			},
		}

		-- Required for `opts.events.reload`.
		vim.o.autoread = true

		-- Suppress SSE decode error messages that cause screen flooding
		vim.opt.shortmess:append('S')

		-- Recommended/example keymaps.
		vim.keymap.set({ 'n', 'x' }, '<leader>za', function()
			require('opencode').ask('@this: ', { submit = true })
		end, { desc = 'Ask opencode' })
		vim.keymap.set({ 'n', 'x' }, '<leader>zx', function()
			require('opencode').select()
		end, { desc = 'Execute opencode action…' })
		vim.keymap.set({ 'n', 'x' }, '<leader>zg', function()
			require('opencode').prompt('@this')
		end, { desc = 'Add to opencode' })
		vim.keymap.set({ 'n', 't' }, '<leader>zt', function()
			require('opencode').toggle()
		end, { desc = 'Toggle opencode' })
		vim.keymap.set('n', '<leader>zu', function()
			require('opencode').command('session.half.page.up')
		end, { desc = 'opencode half page up' })
		vim.keymap.set('n', '<leader>zd', function()
			require('opencode').command('session.half.page.down')
		end, { desc = 'opencode half page down' })
		-- You may want these if you stick with the opinionated "<C-a>" and "<C-x>" above — otherwise consider "<leader>o".
		-- vim.keymap.set("n", "+", "<C-a>", { desc = "Increment", noremap = true })
		-- vim.keymap.set("n", "-", "<C-x>", { desc = "Decrement", noremap = true })
	end,
}
]]
