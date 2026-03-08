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
	vim.keymap.set('n', '<Leader>xll', function()
		utils.execute_lua_and_notify(vim.fn.getline('.'))
	end, { desc = 'Execute Lua on current line' })
	vim.keymap.set('v', '<Leader>xll', function()
		local start, end_ = vim.fn.line('\'<'), vim.fn.line('\'>')
		local lines = vim.fn.getline(start, end_)
		utils.execute_lua_and_notify(table.concat(lines, '\n'))
	end, { desc = 'Execute Lua on selection' })

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
	vim.keymap.set(
		'n',
		'<Leader>ls',
		'<Cmd>Telescope lsp_dynamic_workspace_symbols<CR>',
		{ desc = 'LSP workspace symbols' }
	)

	-- Diagnostic navigation
	vim.keymap.set('n', ']e', function()
		vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
	end, { desc = 'Next error' })
	vim.keymap.set('n', '[e', function()
		vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })
	end, { desc = 'Previous error' })
	vim.keymap.set('n', ']E', function()
		-- Go to first error in buffer
		local diagnostics = vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
		if #diagnostics > 0 then
			vim.api.nvim_win_set_cursor(0, { diagnostics[1].lnum + 1, diagnostics[1].col })
		end
	end, { desc = 'First error' })
	vim.keymap.set('n', '[E', function()
		-- Go to last error in buffer
		local diagnostics = vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
		if #diagnostics > 0 then
			local last = diagnostics[#diagnostics]
			vim.api.nvim_win_set_cursor(0, { last.lnum + 1, last.col })
		end
	end, { desc = 'Last error' })

	-- Diagnostic list (Telescope)
	vim.keymap.set('n', '<Leader>ld', function()
		require('telescope.builtin').diagnostics({ bufnr = 0 })
	end, { desc = 'LSP: Diagnostics (current buffer)' })
	vim.keymap.set('n', '<Leader>lD', function()
		require('telescope.builtin').diagnostics()
	end, { desc = 'LSP: Diagnostics (all buffers)' })

	-- LSP control
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
