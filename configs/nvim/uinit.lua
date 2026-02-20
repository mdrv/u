-- μ (mu) Neovim configuration - Main orchestrator
-- Flashcard: Core setup < 500 lines, delegates to modules for specifics

local IIF = require('utils').IIF
local read_json_file = require('utils').read_json_file

-- Load device-specific configuration from ~/.u.json
U = read_json_file(vim.fs.joinpath(vim.env.HOME, '.u.json'))['NVIM']
if U == nil then
	U = { LV = 0 }
end

-- Transparent backgrounds for terminal compositors
vim.api.nvim_set_hl(0, 'Normal', { bg = 'none' })
vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'none' })
vim.api.nvim_set_hl(0, 'FloatBorder', { bg = 'none' })
vim.api.nvim_set_hl(0, 'Pmenu', { bg = 'none' })
vim.api.nvim_set_hl(0, 'StatusLine', { bg = 'none' })
-- Transparent bg for picom/wayland compositor compatibility

local uname = vim.uv.os_uname()
local hostname = vim.uv.os_getenv('HOSTNAME') or 'unknown'
local g = vim.g
local o = vim.o

-- Window borders
o.winborder = 'rounded'
-- Rounded borders match modern UI aesthetics

-- Disable unused providers for faster startup
g.loaded_python3_provider = 0
g.loaded_ruby_provider = 0
g.loaded_node_provider = 0
-- Python/Ruby/Node providers slow startup; enable only if needed

-- Enable Lua/Perl syntax in Vim scripts
g.vimsyn_embed = 'lP'

-- Mouse support on GUI-capable machines only
o.mouse = IIF(uname.machine == 'x86_64' or hostname == 'armpipa-alx', 'a', '')
-- RISC-V headless hardware doesn't need mouse

-- Backup copy prevents file watcher crashes (Bun, etc.)
o.backupcopy = 'yes'

-- Enable modelines for per-file vim settings
o.modeline = true

-- Hide -- INSERT -- (use statusline instead)
o.showmode = false

-- System clipboard integration
o.clipboard = 'unnamedplus'

-- Leader keys (set once before any plugins load)
g.mapleader = ' '
g.maplocalleader = '\\'

-- Indentation: tabs, width 4
o.tabstop = 4
o.softtabstop = 4
o.shiftwidth = 4
o.expandtab = false
-- Tabs over spaces; 4-wide for readability

-- Line endings: prefer Unix, don't auto-add final newline
o.ffs = 'unix,dos'
o.fixeol = false

-- Search: case insensitive by default
o.ignorecase = true

-- UI: numbers, colors, global statusline
o.number = true
o.relativenumber = true
o.termguicolors = true
o.laststatus = 3

-- Shada: persistent history, registers, marks
o.shada = "!,'1000,<50,s10,h"
-- 1000 files, 50 lines per register, 10KB per item


-- Diagnostic display: minimal signs (⏺), virtual text on current line only
-- Reduces visual noise while keeping diagnostics accessible
vim.diagnostic.config({
	virtual_text = { current_line = true },
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = '⏺',
			[vim.diagnostic.severity.WARN] = '⏺',
			[vim.diagnostic.severity.INFO] = '⏺',
			[vim.diagnostic.severity.HINT] = '⏺',
		},
	},
	severity_sort = true,
})
-- Initialize modules
require('filetype').setup() -- Filetype detection + language settings
require('keymaps').setup() -- Global keymaps
require('statusline').setup() -- Statusline
require('theme').setup() -- Theme with fallback
require('autocmds').setup() -- JSONC commentstring and other autocmds

-- LSP setup (only if plugins enabled)
if U.LV < 1 then
	return
end

-- Bootstrap lazy.nvim plugin manager
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
	local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
	local out = vim.fn.system({ 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ 'Failed to clone lazy.nvim:\n', 'ErrorMsg' },
			{ out, 'WarningMsg' },
			{ '\nPress any key to exit...' },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

-- Setup plugins via lazy.nvim on VimEnter
vim.api.nvim_create_autocmd('VimEnter', {
	callback = function()
		require('lazy').setup({ import = 'ulazy' })
	end,
})

-- Prevent which-key warning for gc mapping
vim.keymap.del('n', 'gc')

-- Load all LSP configs
local lsp_loader = require('lsp-loader')
lsp_loader.load_configs()
-- Load configs into memory; LSPs start manually

-- Explicitly enable commonly-used LSPs (always active)
vim.lsp.enable('svelte')
vim.lsp.enable('tsls')
vim.lsp.enable('nushell')
