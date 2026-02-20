local M = {}

local o = vim.o

-- Theme lists by background mode
local themes = {
	dark = {
		'cyberdream', 'tokyonight-storm', 'tokyonight', 'kanagawa', 'juliana', 'minimal', 'sonokai',
		'default', 'slate', 'habamax', 'desert', 'industry', 'lunaperche', 'darkblue',
	},
	light = {
		'kanso-pearl', 'classic-monokai', 'catppuccin-latte', 'tokyonight-day', 'rose-pine-dawn',
		'shine', 'peachpuff', 'quiet', 'morning',
	},
}

-- Set first available theme from list
function M.set_with_fallback(theme_list)
	local available_themes = vim.fn.getcompletion('', 'color')
	for _, x in pairs(theme_list) do
		if vim.tbl_contains(available_themes, x) then
			vim.cmd.colorscheme(x)
			break
		end
	end
end

-- Get theme list for mode ('dark' or 'light')
function M.get_themes(mode)
	return themes[mode] or {}
end

-- Setup UiEnter autocmd to set theme based on background
function M.setup()
	vim.api.nvim_create_autocmd('UiEnter', {
		callback = function()
			M.set_with_fallback(themes[o.background])
		end,
	})
end

return M
