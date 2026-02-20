-- Global keymaps for μ (mu) Neovim config
-- Flashcard module: focused, concise, < 500 lines

local M = {}

-- Setup all global keymaps
function M.setup()
	local utils = require('utils')

	-- Disable all q{alphanumeric} macros to free up q-leader keys
	for key in string.gmatch('qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM', '.') do
		vim.keymap.set({ 'n', 'v' }, 'q' .. key, '<Nop>', { silent = true })
	end

	-- Quick keys for common operations
	vim.keymap.set('n', ';', ':', { desc = 'No-Shift Ex mode' }) -- Type : without holding Shift
	vim.keymap.set('n', 'qw', ':w<CR>', { desc = 'Quick save' }) -- Save current buffer
	vim.keymap.set('n', 'qq', ':q<CR>', { desc = 'Quick quit' }) -- Quit current window
	vim.keymap.set('n', 'qa', ':qa<CR>', { desc = 'Quit all' }) -- Quit all windows
	vim.keymap.set('n', 'qfa', ':qa!<CR>', { desc = 'Force quit all' }) -- Force quit all (no save prompt)
	vim.keymap.set('n', 'qe', ':e<CR>', { desc = 'Reload file' }) -- Reload current file from disk
	vim.keymap.set('n', 'qs', ':mksession! ', { desc = 'Save session' }) -- Save session (prompt for path)

	-- Lua execution utilities
	vim.keymap.set(
		'n',
		'<Leader>xll',
		function()
			utils.execute_lua_and_notify(vim.fn.getline('.'))
		end,
		{ desc = 'Execute Lua on current line' }
	)
	vim.keymap.set(
		'v',
		'<Leader>xll',
		function()
			local start, end_ = vim.fn.line("'<"), vim.fn.line("'>")
			local lines = vim.fn.getline(start, end_)
			utils.execute_lua_and_notify(table.concat(lines, '\n'))
		end,
		{ desc = 'Execute Lua on selection' }
	)

	-- Navigation shortcuts
	vim.keymap.set('n', '<Leader>tcd', function()
		vim.cmd.tcd(vim.fn.expand('%:p:h'))
		vim.schedule(function()
			vim.notify('tcd to ' .. vim.fn.getcwd())
		end)
	end, { desc = 'tcd to current file directory' })

	-- LSP and plugin management
	vim.keymap.set('n', '<Leader>lz', '<Cmd>Lazy<CR>', { desc = 'Open lazy.nvim' })
	vim.keymap.set('n', '<Leader>li', '<Cmd>checkhealth vim.lsp<CR>', { desc = 'Check LSP health' })
	vim.keymap.set('n', '<Leader>ls', '<Cmd>Telescope lsp_dynamic_workspace_symbols<CR>', { desc = 'LSP workspace symbols' })
	vim.keymap.set('n', '<Leader>lxa', '<Cmd>LspStop<CR>', { desc = 'Stop all LSP clients' })
	vim.keymap.set('n', '<Leader>lxi', function()
		vim.ui.select(vim.lsp.get_clients(), {
			prompt = 'Select LSP client to stop:',
			format_item = function(client)
				return string.format('%s [%s]', client.name, client.id)
			end,
		}, function(choice)
			if choice then
				vim.lsp.stop_client(choice.id)
				vim.schedule(function()
					vim.notify('Stopped LSP client: ' .. choice.name)
				end)
			end
		end)
	end, { desc = 'Stop individual LSP client' })
end

return M
