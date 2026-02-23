--- Copilot menu using fzf-lua

local M = {}

-- Copilot command mappings
local COPILOT_COMMANDS = {
	{
		label = 'Toggle Copilot',
		action = function()
			local client = require('copilot.client')
			if client.is_disabled() then
				require('copilot.command').enable()
				vim.notify('Copilot: ENABLED', 'info')
			else
				require('copilot.command').disable()
				vim.notify('Copilot: DISABLED', 'info')
			end
		end,
	},
	{
		label = 'Toggle Suggestions',
		action = function()
			require('copilot')
			local suggestion = require('copilot.suggestion')
			suggestion.toggle_auto_trigger()
			-- Check state from buffer-local or global setting
			local enabled = vim.b.copilot_suggestion_auto_trigger or false
			vim.notify('Copilot suggestions: ' .. (enabled and 'ON' or 'OFF'), 'info')
		end,
	},
	{
		label = 'Open Panel',
		action = function()
			require('copilot.panel').open()
		end,
	},
	{
		label = 'Close Panel',
		action = function()
			require('copilot.panel').close()
		end,
	},
	{
		label = 'Status',
		action = function()
			vim.cmd('Copilot status')
		end,
	},
	{
		label = 'Authenticate',
		action = function()
			vim.cmd('Copilot auth')
		end,
	},
	{
		label = 'Version',
		action = function()
			vim.cmd('Copilot version')
		end,
	},
	{
		label = 'Clear History',
		action = function()
			vim.cmd('Copilot clear')
		end,
	},
}

-- Get copilot status info
local function get_copilot_status()
	local enabled = false
	local copilot_enabled = true

	-- Ensure copilot module is loaded (triggers lazy.nvim to load it)
	local ok, copilot = pcall(require, 'copilot')
	if ok and copilot then
		-- Check buffer-local setting first, then global config
		if vim.b.copilot_suggestion_auto_trigger ~= nil then
			enabled = vim.b.copilot_suggestion_auto_trigger
		elseif copilot.auto_trigger ~= nil then
			enabled = copilot.auto_trigger
		end
	end

	-- Check if Copilot is disabled
	local client_ok, client = pcall(require, 'copilot.client')
	if client_ok then
		copilot_enabled = not client.is_disabled()
	end

	-- Check auth status (best effort - may require :Copilot status)
	local auth_status = 'Not checked'
	if vim.g.copilot_node_command then
		auth_status = 'Plugin loaded'
	else
		auth_status = 'Plugin not loaded'
	end

	return {
		suggestions_enabled = enabled,
		copilot_enabled = copilot_enabled,
		auth_status = auth_status,
	}
end

-- Open copilot menu
function M.open_menu()
	local status = get_copilot_status()

	-- Build entries
	local entries = {}
	for _, item in ipairs(COPILOT_COMMANDS) do
		local status_icon = ''
		if item.label:match('Toggle Copilot$') then
			status_icon = status.copilot_enabled and '●' or '○'
		elseif item.label:match('Toggle Suggestions') then
			status_icon = status.suggestions_enabled and '●' or '○'
		elseif item.label:match('Status') then
			status_icon = '●'
		end
		table.insert(entries, {
			label = item.label,
			display = string.format(' [%s] %s', status_icon, item.label),
			action = item.action,
		})
	end

	-- Build display lines and map
	local display_lines = {}
	local label_map = {}
	for _, entry in ipairs(entries) do
		table.insert(display_lines, entry.display)
		label_map[entry.display] = entry.action
	end

	-- Header
	local header_lines = {
		string.format(
			'Copilot: %s | Suggestions: %s | Enter: Execute action',
			status.copilot_enabled and 'ON' or 'OFF',
			status.suggestions_enabled and 'ON' or 'OFF'
		),
		'',
	}

	require('fzf-lua').fzf_exec(display_lines, {
		prompt = 'Copilot> ',
		fzf_opts = {
			['--header'] = table.concat(header_lines, '\n'),
			['--preview-window'] = 'hidden',
		},
		actions = {
			['default'] = function(selected)
				if #selected == 0 then
					return
				end
				local action = label_map[selected[1]]
				if action then
					action()
				end
			end,
		},
	})
end

return M
