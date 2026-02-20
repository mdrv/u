-- filetype.lua - Filetype detection and language-specific settings
-- Part of μ Neovim config

local M = {}

function M.setup()
	-- Register file extensions and patterns
	-- These ensure proper syntax highlighting and LSP support
	vim.filetype.add({
		extension = {
			-- Nushell data format - same as regular nu scripts
			nuon = 'nu',
			-- Caddy web server config
			caddy = 'caddy',
			-- MDX (Markdown + JSX) - React markdown components
			mdx = 'mdx',
			-- MDsveX (Markdown + Svelte) - Svelte markdown components
			svx = 'markdown',
		},
		filename = {
			-- Explicit filename match for Caddyfile
			['Caddyfile'] = 'caddy',
		},
		pattern = {
			-- Hyprland config files use hyprlang syntax
			['${HOME}/.config/hypr/.*.conf'] = 'hyprlang',
		},
	})

	-- FileType autocmds for language-specific settings
	-- These run after buffer is loaded to apply editor behavior
	vim.api.nvim_create_autocmd('FileType', {
		group = vim.api.nvim_create_augroup('FiletypeSettings', { clear = true }),
		pattern = {
			'json',
			'jsonc',
		},
		callback = function()
			-- JSON typically uses 2-space indentation
			vim.opt_local.tabstop = 2
			vim.opt_local.shiftwidth = 2
			vim.opt_local.expandtab = true
		end,
	})

	vim.api.nvim_create_autocmd('FileType', {
		group = 'FiletypeSettings',
		pattern = {
			'javascript',
			'typescript',
			'javascriptreact',
			'typescriptreact',
		},
		callback = function()
			-- JavaScript ecosystem standard: 2-space indentation
			vim.opt_local.tabstop = 2
			vim.opt_local.shiftwidth = 2
			vim.opt_local.expandtab = true
		end,
	})

	vim.api.nvim_create_autocmd('FileType', {
		group = 'FiletypeSettings',
		pattern = 'markdown',
		callback = function()
			-- Markdown wraps for readability, 80 chars is standard
			vim.opt_local.textwidth = 80
			vim.opt_local.wrap = true
			vim.opt_local.linebreak = true
		end,
	})

	vim.api.nvim_create_autocmd('FileType', {
		group = 'FiletypeSettings',
		pattern = 'lua',
		callback = function()
			-- Lua style guide recommends 4-space indentation
			vim.opt_local.tabstop = 4
			vim.opt_local.shiftwidth = 4
		end,
	})
end

return M
