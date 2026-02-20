-- id=lsp-loader
-- LSP config loader with filetype-based autostart

local M = {}

-- Load all ulsp/*.lua configs into vim.lsp.config._configs
function M.load_configs()
	for _, path in ipairs(vim.api.nvim_get_runtime_file('**/ulsp/*.lua', true)) do
		local id = vim.fs.basename(path):sub(1, -5)
		local config = require('ulsp.' .. id)
		vim.lsp.config._configs[id] = vim.tbl_deep_extend('force', vim.lsp.config._configs[id] or {}, config)
	end
end

-- Enable LSPs that match the current filetype
function M.enable_for_filetype(ft)
	for id, config in pairs(vim.lsp.config._configs) do
		if id ~= '*' and config.filetypes and vim.tbl_contains(config.filetypes, ft) then
			vim.lsp.enable(id)
		end
	end
end


-- Return list of loaded configs for fzf-lua
function M.list_available()
	local result = {}
	for id, config in pairs(vim.lsp.config._configs) do
		if id ~= '*' then
			table.insert(result, id)
		end
	end
	return result
end

return M
