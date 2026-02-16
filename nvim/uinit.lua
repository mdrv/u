local IIF = require('utils').IIF
local read_json_file = require('utils').read_json_file

U = read_json_file(vim.fs.joinpath(vim.env.HOME, '.u.json'))["NVIM"]
if U == nil then
	U = {
		LV = 0,
	}
end

vim.api.nvim_set_hl(0, 'Normal', { bg = 'none' })
vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'none' })
vim.api.nvim_set_hl(0, 'FloatBorder', { bg = 'none' })
vim.api.nvim_set_hl(0, 'Pmenu', { bg = 'none' })
vim.api.nvim_set_hl(0, 'StatusLine', { bg = 'none' })
-- ANNOTATION: Set transparent background for transparent terminal support

local uname = vim.uv.os_uname()
local hostname = vim.uv.os_getenv('HOSTNAME') or 'unknown'
local g = vim.g
local o = vim.o

vim.api.nvim_create_autocmd('FileType', {
	pattern = { 'jsonc' },
	callback = function()
		vim.bo.commentstring = '// %s'
	end,
})
-- ANNOTATION: Set comment string for JSONC files to use double-slash

o.winborder = 'rounded'
-- ANNOTATION: Use rounded borders for floating windows
-- vim.keymap.set("n", "K", function() vim.lsp.buf.hover({border = "rounded"}) end, { desc = "" })

-- Disable Python 3 support for faster startup
g.loaded_python3_provider = 0
-- ANNOTATION: Disabling Python provider speeds up Neovim startup significantly

-- :h g:vimsyn_embed
g.vimsyn_embed = 'lP'
-- ANNOTATION: Enable Lua and Perl syntax embedded in Vim scripts

-- navigation
o.mouse = IIF(uname.machine == 'x86_64' or hostname == 'armpipa-alx', 'a', '')
-- ANNOTATION: Enable mouse support on x86_64 only (RISC-V hardware doesn't have GUI)

-- backup copy
-- to prevent watch-enabled Bun instance from crashing
o.backupcopy = 'yes'

-- :h 'modeline'
o.modeline = true

-- :h 'showmode'
o.showmode = false

-- id=clipboard
o.clipboard = 'unnamedplus'

-- BUG?: `<Space>` cannot be used.
g.mapleader = ' '

-- tab
o.tabstop = 4
o.softtabstop = 4
o.shiftwidth = 4
o.expandtab = false -- tabs vs. spaces

-- content
o.ffs = 'unix,dos'
o.fixeol = false -- o.fixendofline

-- search
o.ignorecase = true

-- o.completeopt = "menu,popup" -- already default

-- styling
o.number = true
o.relativenumber = true
o.termguicolors = true
o.laststatus = 3
o.shada = '!,\'1000,<50,s10,h' -- default: !,'100,<50,s10,h

vim.filetype.add({
	extension = {
		nuon = 'nu',
		caddy = 'caddy',
		Caddyfile = 'caddy',
		svx = 'markdown',
		mdx = 'mdx',
	},
	filename = {
		['Caddyfile'] = 'caddy',
	},
	pattern = {
		['${HOME}/.config/hypr/.*.conf'] = 'hyprlang',
	},
})

-- id=disable-macro
local alphanumeric = {}
for i = 1, 26 do
	table.insert(alphanumeric, string.char(64 + i))
	table.insert(alphanumeric, string.char(96 + i))
end
for i = 0, 9 do
	table.insert(alphanumeric, tostring(i))
end
for _, char in ipairs(alphanumeric) do
	vim.keymap.set({ 'n', 'v' }, 'q' .. char, '', { desc = 'noop', remap = false, silent = true })
end

-- id=keymaps
vim.keymap.set({ 'n', 'v' }, ';', ':', { desc = 'No-Shift Ex mode' })
vim.keymap.set('n', 'qw', ':w<CR>', { desc = 'Quick/easy save', silent = true })
vim.keymap.set('n', 'qq', ':q<CR>', { desc = 'Quick/easy quit', silent = true })
vim.keymap.set('n', 'qa', ':qa<CR>', { desc = 'Quick/easy quit all', silent = true })
vim.keymap.set('n', 'qfa', ':qa!<CR>', { desc = 'Quick/easy quit all (force)', silent = true })
vim.keymap.set('n', 'qe', ':e<CR>', { desc = 'Quick/easy reload', silent = true })
vim.keymap.set('n', 'qs', ':mksession! ', { desc = 'Quick/easy save session' })

-- AI: Helper function to execute Lua code and display result via nvim-notify
local function execute_lua_and_notify(code)
	local fn, err = loadstring(code)
	if not fn then
		error(err)
	end
	local success, result = pcall(fn)
	if not success then
		error(result)
	end
	local output = result
	if output == nil then
		output = 'nil (no return)'
	elseif type(output) == 'table' then
		output = vim.inspect(output)
	else
		output = tostring(output)
	end
	vim.notify(output, vim.log.levels.INFO)
end

-- UA: Previous code
-- vim.keymap.set('n', '<Leader>xll', ':.lua<CR>', { desc = 'Execute Lua on current line', silent = true })
-- vim.keymap.set('v', '<Leader>xll', ':\'<,\'>lua<CR>', { desc = 'Execute Lua on selection', silent = true })

-- AI: Updated keymaps to use notification output
vim.keymap.set('n', '<Leader>xll', function()
	local line = vim.api.nvim_get_current_line()
	execute_lua_and_notify(line)
end, { desc = 'Execute Lua on current line', silent = true })

vim.keymap.set('v', '<Leader>xll', function()
	local start_line = vim.fn.line('\'<')
	local end_line = vim.fn.line('\'>')
	local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
	execute_lua_and_notify(table.concat(lines, '\n'))
end, { desc = 'Execute Lua on selection', silent = true })

vim.keymap.set('n', '<Leader>tcd', ':tcd %:h<CR>', { desc = 'Navigate tab (go) to current file directory' })

function _G._statusline_lsp()
	local tmp = vim.lsp.get_clients({ bufnr = 0 })
	return '<' .. table.concat(
		vim.tbl_map(function(t)
			return t.name
		end, tmp),
		' '
	) .. '>'
end

-- https://www.reddit.com/r/neovim/comments/1itvmme/comment/mdshwq0/
function _G._statusline_diag(level)
	local levels = {
		vim.diagnostic.severity.HINT,
		vim.diagnostic.severity.INFO,
		vim.diagnostic.severity.WARN,
		vim.diagnostic.severity.ERROR,
	}
	if (vim.diagnostic.count(0)[levels[level]] or 0) > 0 then
		return '●'
	else
		-- return "◌"
		return '○'
	end
end

local function statusline()
	local set_color_0 = '%#ModeBg#'
	local set_color_1 = '%#CursorLineNr#'
	local set_color_2 = '%#LineNr#'
	local diag_error = '%#DiagnosticError#%{%v:lua._G._statusline_diag(4)%}'
	local diag_warn = '%#DiagnosticWarn#%{%v:lua._G._statusline_diag(3)%}'
	local diag_info = '%#DiagnosticInfo#%{%v:lua._G._statusline_diag(2)%}'
	local diag_hint = '%#DiagnosticHint#%{%v:lua._G._statusline_diag(1)%}'
	local current_mode = '%{mode()}'
	local file_name = '%f'
	local modified = '%m'
	local align_right = '%=%<' -- + truncate line
	-- local completion = "%{%v:lua._G._statusline_completion()%}"
	local lsp = '%{%v:lua._G._statusline_lsp()%}'
	local filetype = ' %y'
	local fileencoding = ' %{&fileencoding?&fileencoding:&encoding}'
	local fileformat = ' [%{&fileformat}]'
	local percentage = ' %p%%'
	local linecol = ' %l:%c'

	return string.format(
		'%s %s%s%s%s [ %s %s %s %s %s] %s %s%s%s%s%s%s',
		set_color_0,
		-- current_mode,
		set_color_1,
		file_name,
		modified,
		set_color_2,
		diag_error,
		diag_warn,
		diag_info,
		diag_hint,
		set_color_2,
		align_right,
		lsp,
		filetype,
		fileencoding,
		fileformat,
		percentage,
		linecol
	)
end

vim.o.statusline = statusline()

-- id=util-set_theme_with_fallback
-- can be used anywhere
local function set_theme_with_fallback(themes)
	local available_themes = vim.fn.getcompletion('', 'color')
	for _, x in pairs(themes) do
		if vim.tbl_contains(available_themes, x) then
			-- vim.cmd(string.format('colorscheme %s', x))
			vim.cmd.colorscheme(x)
			break
		end
	end
end

-- id=prefs-themes
-- Defines table for THEMES
-- with key depending on `o:background` value
-- 🐍: Prevent becoming too long vertically
-- stylua: ignore
local themes = {
    dark = {
        'cyberdream', 'tokyonight-storm', 'tokyonight', 'kanagawa', 'juliana', 'minimal', 'sonokai', -- external
        'default', 'slate', 'habamax', 'desert', 'industry', 'lunaperche', 'darkblue', -- built-in
    },
    light = {
        -- 'cyberdream-light', -- H: Has issue with transparency
		'kanso-pearl', 'classic-monokai', 'catppuccin-latte', 'tokyonight-day', 'rose-pine-dawn', -- external
        'shine', 'peachpuff', 'quiet', 'morning', -- built-in
    },
}

-- id=theme-autocmd
vim.api.nvim_create_autocmd('UiEnter', {
	callback = function()
		set_theme_with_fallback(themes[o.background])
	end,
})

-- id=prefs-diagnostic
vim.diagnostic.config({
	virtual_text = {
		current_line = true,
	},
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = '⏺', -- ⏺⦁︎
			[vim.diagnostic.severity.WARN] = '⏺',
			[vim.diagnostic.severity.INFO] = '⏺',
			[vim.diagnostic.severity.HINT] = '⏺',
		},
	},
	severity_sort = true,
})

if U.LV < 1 then
	return
end

-- id=lazy.nvim-setup2
--
-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'

-- id=lazy.nvim-setup1
-- l: https://lazy.folke.io/installation
-- Bootstrap lazy.nvim
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

vim.api.nvim_create_autocmd('VimEnter', {
	callback = function()
		require('lazy').setup({ import = 'ulazy' })
	end,
})

vim.keymap.del('n', 'gc') -- prevent warning from which-key.nvim

vim.keymap.set('n', '<Leader>lz', '<Cmd>Lazy<CR>', { desc = 'Open lazy.nvim panel' })

vim.keymap.set({ 'n' }, '<leader>li', '<Cmd>checkhealth vim.lsp<CR>', { desc = 'Check LSP' })

-- load lsp files (by default; lsp must be configured and enabled to trigger load)
for _, path in ipairs(vim.api.nvim_get_runtime_file('**/ulsp/*.lua', true)) do
	local id = vim.fs.basename(path):sub(1, -5)
	-- local config = dofile(path)
	local config = require('ulsp.' .. id)
	vim.lsp.config._configs[id] = vim.tbl_deep_extend('force', vim.lsp.config._configs[id] or {}, config)
end

vim.lsp.enable('svelte')
vim.lsp.enable('tsls')

vim.keymap.set({ 'n' }, '<leader>ls', function()
	local ft = vim.bo.filetype
	-- https://github.com/ibhagwan/fzf-lua/wiki/Advanced
	require('fzf-lua').fzf_exec(function(fzf_cb)
		local nonstars = {}
		for id, config in pairs(vim.lsp.config._configs) do
			-- VNI({id, ft})
			if id == '*' then
			elseif config.filetypes ~= nil and vim.tbl_contains(config.filetypes, ft) then
				fzf_cb(id .. ' ⭐')
			else
				table.insert(nonstars, id)
			end
		end
		for _, n in ipairs(nonstars) do
			fzf_cb(n)
		end
		fzf_cb()
	end, {
		actions = {
			tab = function(selected, opts)
				local key = selected[1]:match('^([%w_]+)%s?') -- don’t forget underscore
				vim.lsp.enable(key)
			end,
			['default'] = function(selected, opts)
				if selected == nil then
					return
				end
				local key = selected[1]:match('^([%w_]+)%s?') -- don’t forget underscore
				local root_markers = vim.lsp.config._configs[key].root_markers or nil
				local config = vim.tbl_deep_extend(
					'error',
					vim.lsp.config._configs[key],
					{ root_dir = root_markers and vim.fs.root(0, root_markers) or nil }
				)
				vim.lsp.start(config, {
					reuse_client = function(client, config)
						if client.root_dir == nil then
							return false
						end
						if client.name == config.cmd[1] and client.root_dir == config.root_dir then
							return true
						end
					end,
				})
				-- VNI(selected[1])
				-- local config = vim.tbl_deep_extend("error",
				--     vim.lsp.config._configs[selected[1]],
				--     { root_dir = vim.fn.getcwd() }
				-- )
				-- VNI(config)
			end,
		},
	})
end, { desc = 'Start LSP (with fzf-lua)' })

vim.keymap.set({ 'n' }, '<leader>lxa', function()
	vim.notify('Stopping all LSP clients...')
	vim.lsp.stop_client(vim.lsp.get_clients())
end, { desc = 'Stop all LSP clients' })

vim.keymap.set({ 'n' }, '<leader>lxi', function()
	require('fzf-lua').fzf_exec(function(fzf_cb)
		local clients = vim.lsp.get_clients()
		for _, client in ipairs(clients) do
			if client.name ~= 'null-ls' then
				local str = string.format('%s %s %s', client.id, client.name, client.root_dir)
				fzf_cb(str)
			end
		end
		fzf_cb()
	end, {
		actions = {
			['default'] = function(selected)
				local id = selected[1]:match('^(%d+)%s?')
				vim.lsp.stop_client(tonumber(id))
			end,
		},
	})
end, { desc = 'Stop LSP (with fzf-lua)' })
