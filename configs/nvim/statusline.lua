-- Statusline module for Neovim
-- Flashcard pattern: <500 lines, brief concise comments

local M = {}

-- Get active LSP client names
-- Returns: '<client1 client2 ...>'
function M.lsp()
	local tmp = vim.lsp.get_clients({ bufnr = 0 })
	return '<' .. table.concat(
		vim.tbl_map(function(t)
			return t.name
		end, tmp),
		' '
	) .. '>'
end

-- Get diagnostic indicator by level
-- Levels: 1=HINT, 2=INFO, 3=WARN, 4=ERROR
-- Returns: '●' if present, '○' if empty
function M.diag(level)
	local levels = {
		vim.diagnostic.severity.HINT,
		vim.diagnostic.severity.INFO,
		vim.diagnostic.severity.WARN,
		vim.diagnostic.severity.ERROR,
	}
	if (vim.diagnostic.count(0)[levels[level]] or 0) > 0 then
		return '●'
	else
		return '○'
	end
end

-- Build complete statusline string
-- Colors, diagnostics, LSP, file info, position
function M.build()
	local set_color_0 = '%#ModeBg#'
	local set_color_1 = '%#CursorLineNr#'
	local set_color_2 = '%#LineNr#'
	local diag_error = '%#DiagnosticError#%{%v:lua._statusline.diag(4)%}'
	local diag_warn = '%#DiagnosticWarn#%{%v:lua._statusline.diag(3)%}'
	local diag_info = '%#DiagnosticInfo#%{%v:lua._statusline.diag(2)%}'
	local diag_hint = '%#DiagnosticHint#%{%v:lua._statusline.diag(1)%}'
	local file_name = '%f'
	local modified = '%m'
	local align_right = '%=%<'
	local lsp = '%{%v:lua._statusline.lsp()%}'
	local filetype = ' %y'
	local fileencoding = ' %{&fileencoding?&fileencoding:&encoding}'
	local fileformat = ' [%{&fileformat}]'
	local percentage = ' %p%%'
	local linecol = ' %l:%c'

	return string.format(
		'%s %s%s%s%s [ %s %s %s %s %s] %s %s%s%s%s%s%s',
		set_color_0,
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

-- Setup statusline
-- Sets vim.o.statusline to M.build()
function M.setup()
	-- Store functions in global namespace for v:lua access
	_G._statusline = {
		lsp = M.lsp,
		diag = M.diag,
	}
	vim.o.statusline = M.build()
end

return M
