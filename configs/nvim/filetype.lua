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
end

return M
