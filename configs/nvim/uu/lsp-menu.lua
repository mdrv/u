-- LSP Management Menu using fzf-lua
-- Flashcard module: LSP start/stop with filetype-based recommendations

local M = {}

-- Get all available LSP configs from lsp-loader
function M.get_available_lsps()
	local ok, loader = pcall(require, 'lsp-loader')
	if not ok then
		return {}
	end
	return loader.list_available()
end

-- Get running LSP clients
function M.get_running_lsps()
	local clients = {}
	for _, client in ipairs(vim.lsp.get_clients()) do
		clients[client.name] = true
	end
	return clients
end

-- Get LSPs recommended for current buffer filetype
function M.get_recommended_lsps()
	local ft = vim.bo.filetype
	if not ft or ft == '' then
		return {}
	end

	-- Filetype to LSP mappings (common patterns)
	local mappings = {
		javascript = { 'tsls' },
		javascriptreact = { 'tsls' },
		typescript = { 'tsls' },
		typescriptreact = { 'tsls' },
		tsx = { 'tsls' },
		jsx = { 'tsls' },
		lua = { 'luals' },
		svelte = { 'svelte', 'tailwind', 'emmet' },
		astro = { 'astro', 'tailwind', 'emmet' },
		rust = { 'rust_analyzer' },
		python = { 'ruff', 'pyright' },
		nushell = { 'nushell' },
		markdown = { 'mdx_analyzer' },
		mdx = { 'mdx_analyzer' },
		json = { 'jsonls' },
		yaml = { 'yamlls' },
		c = { 'clangd' },
		cpp = { 'clangd' },
		html = { 'tailwind', 'emmet' },
		css = { 'tailwind', 'cssls' },
		qml = { 'qmlls' },
	}

	return mappings[ft] or {}
end

-- Format LSP entry for fzf-lua
function M.format_lsp_entry(lsp_name, running, recommended)
	local status = running and '✓' or '✗'
	local star = recommended and '⭐' or '  '
	return string.format('%s %s %s', star, status, lsp_name)
end

-- Toggle LSP (start if stopped, stop if running)
function M.toggle_lsp(lsp_name)
	local clients = M.get_running_lsps()

	if clients[lsp_name] then
		-- Stop LSP
		for _, client in ipairs(vim.lsp.get_clients()) do
			if client.name == lsp_name then
				vim.lsp.stop_client(client.id)
				vim.schedule(function()
					vim.notify('Stopped LSP: ' .. lsp_name)
				end)
				return
			end
		end
	else
		-- Start LSP
		pcall(function()
			vim.lsp.enable(lsp_name)
			vim.schedule(function()
				vim.notify('Started LSP: ' .. lsp_name)
			end)
		end)
	end
end

-- Stop all LSPs
function M.stop_all_lsps()
	for _, client in ipairs(vim.lsp.get_clients()) do
		vim.lsp.stop_client(client.id)
	end
	vim.schedule(function()
		vim.notify('Stopped all LSP clients')
	end)
end

-- Start all recommended LSPs for current filetype
function M.start_recommended_lsps()
	local recommended = M.get_recommended_lsps()
	local running = M.get_running_lsps()
	local started = {}

	for _, lsp_name in ipairs(recommended) do
		if not running[lsp_name] then
			pcall(function()
				vim.lsp.enable(lsp_name)
				table.insert(started, lsp_name)
			end)
		end
	end

	if #started > 0 then
		vim.schedule(function()
			vim.notify('Started recommended LSPs: ' .. table.concat(started, ', '))
		end)
	else
		vim.notify('All recommended LSPs already running')
	end
end

-- Open LSP management menu with fzf-lua
function M.open_menu()
	local available = M.get_available_lsps()
	local running = M.get_running_lsps()
	local recommended = M.get_recommended_lsps()
	local recommended_set = {}
	for _, lsp in ipairs(recommended) do
		recommended_set[lsp] = true
	end

	-- Build entries
	local entries = {}
	for _, lsp_name in ipairs(available) do
		local is_running = running[lsp_name] or false
		local is_recommended = recommended_set[lsp_name] or false
		table.insert(entries, {
			lsp_name = lsp_name,
			display = M.format_lsp_entry(lsp_name, is_running, is_recommended),
			is_running = is_running,
			is_recommended = is_recommended,
		})
	end

	-- Sort: recommended first, then alphabetically
	table.sort(entries, function(a, b)
		if a.is_recommended ~= b.is_recommended then
			return a.is_recommended
		end
		return a.lsp_name < b.lsp_name
	end)

	-- Prepare fzf-lua display
	local display_lines = {}
	local lsp_map = {}
	for _, entry in ipairs(entries) do
		table.insert(display_lines, entry.display)
		lsp_map[entry.display] = entry.lsp_name
	end

	-- Help text
	local help_lines = {
		'',
		'Enter    Toggle LSP (start/stop)',
		'Ctrl-a   Start recommended LSPs for current filetype',
		'Ctrl-s   Stop all running LSPs',
		'?        Show this help',
		'',
	}

	-- Quick actions header
	local header_lines = {
		'Enter: Toggle LSP | Ctrl-a: Start Recommended | Ctrl-s: Stop All | ?: Help',
		'',
	}

	require('fzf-lua').fzf_exec(display_lines, {
		prompt = 'LSP> ',
		fzf_opts = {
			['--header'] = table.concat(header_lines, '\n'),
			['--preview'] = 'echo "Actions: Enter=Toggle, Ctrl-a=Start Recommended, Ctrl-s=Stop All"',
		},
		actions = {
			['default'] = function(selected)
				if #selected == 0 then
					return
				end
				local lsp_name = lsp_map[selected[1]]
				if lsp_name then
					M.toggle_lsp(lsp_name)
				end
			end,
			['ctrl-a'] = function()
				M.start_recommended_lsps()
			end,
			['ctrl-s'] = function()
				M.stop_all_lsps()
			end,
		},
	})
end

return M
