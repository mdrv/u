-- ANNOTATION: User autocommands - event handlers for editor behavior
local M = {}

-- Setup all autocommands
function M.setup()
	local augroup = vim.api.nvim_create_augroup('UserAutocmds', { clear = true })

	-- JSONC files use // comments, not /* */
	vim.api.nvim_create_autocmd('FileType', {
		group = augroup,
		pattern = { 'jsonc' },
		callback = function()
			vim.bo.commentstring = '// %s'
		end,
	})
end

return M
