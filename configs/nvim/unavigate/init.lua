local M = {}

--- Parse a line for navigation patterns
--- @param line string The line to parse
--- @return table|nil {file: string, search: string|nil, search_type: 'pattern'|'id'|nil}
local function parse_navigation_line(line)
	-- Remove leading comment markers (--, //, #, etc)
	local cleaned = line:gsub('^%s*[-/#]*%s*', '')

	-- Pattern 1: file.lua#id=identifier
	local file, id = cleaned:match('([^#%s]+)#id=([^%s]+)')
	if file and id then
		return { file = file, search = 'id=' .. id, search_type = 'id' }
	end

	-- Pattern 2: file.lua#pattern (general pattern)
	local file2, pattern = cleaned:match('([^#%s]+)#([^%s]+)')
	if file2 and pattern then
		return { file = file2, search = pattern, search_type = 'pattern' }
	end

	-- Pattern 3: file.lua:line_number (fallback to standard gF)
	local file3, line_num = cleaned:match('([^:%s]+):(%d+)')
	if file3 and line_num then
		return { file = file3, line = tonumber(line_num), search_type = 'line' }
	end

	-- Pattern 4: just a file path (standard gf)
	local file4 = cleaned:match('([^%s]+%.%w+)')
	if file4 then
		return { file = file4, search_type = 'file' }
	end

	return nil
end

--- Navigate to file and search for pattern
--- @param nav_info table Navigation info from parse_navigation_line
local function navigate(nav_info)
	if not nav_info then
		vim.notify('No navigation pattern found on current line', vim.log.levels.WARN)
		return
	end

	-- Try to find the file
	local file_path = nav_info.file

	-- Check if file exists as-is
	if vim.fn.filereadable(file_path) == 0 then
		-- Try relative to current file's directory
		local current_dir = vim.fn.expand('%:p:h')
		local relative_path = current_dir .. '/' .. file_path

		if vim.fn.filereadable(relative_path) == 1 then
			file_path = relative_path
		else
			-- Try findfile
			local found = vim.fn.findfile(file_path)
			if found ~= '' then
				file_path = found
			else
				vim.notify('File not found: ' .. nav_info.file, vim.log.levels.ERROR)
				return
			end
		end
	end

	-- Open the file
	vim.cmd('edit ' .. vim.fn.fnameescape(file_path))

	-- Perform search based on type
	if nav_info.search_type == 'line' and nav_info.line then
		vim.cmd('normal! ' .. nav_info.line .. 'G')
	elseif nav_info.search_type == 'id' or nav_info.search_type == 'pattern' then
		-- Search for the pattern
		local found = vim.fn.search(vim.fn.escape(nav_info.search, '/\\'), 'w')
		if found == 0 then
			vim.notify('Pattern not found: ' .. nav_info.search, vim.log.levels.WARN)
		end
	end

	-- Center the cursor
	vim.cmd('normal! zz')
end

--- Main goto file function
function M.goto_file()
	local line = vim.api.nvim_get_current_line()
	local nav_info = parse_navigation_line(line)
	navigate(nav_info)
end

--- Goto file in new split
function M.goto_file_split()
	local line = vim.api.nvim_get_current_line()
	local nav_info = parse_navigation_line(line)

	if nav_info then
		vim.cmd('split')
		navigate(nav_info)
	end
end

--- Goto file in new tab
function M.goto_file_tab()
	local line = vim.api.nvim_get_current_line()
	local nav_info = parse_navigation_line(line)

	if nav_info then
		vim.cmd('tabnew')
		navigate(nav_info)
	end
end

--- Search all ID tags using fzf-lua
function M.search_ids()
	local has_fzf, fzf = pcall(require, 'fzf-lua')

	if not has_fzf then
		vim.notify('fzf-lua is required for this feature', vim.log.levels.ERROR)
		return
	end

	fzf.grep({
		search = 'id=',
		prompt = 'Search ID> ',
		actions = {
			['default'] = function(selected)
				if not selected or #selected == 0 then
					return
				end

				-- Parse fzf output: "filepath:line:content"
				local parts = vim.split(selected[1], ':', { plain = false, trimempty = true })
				if #parts >= 2 then
					local file = parts[1]
					local line_num = tonumber(parts[2])

					vim.cmd('edit ' .. vim.fn.fnameescape(file))
					if line_num then
						vim.cmd('normal! ' .. line_num .. 'G')
						vim.cmd('normal! zz')
					end
				end
			end,
		},
	})
end

--- Setup function
function M.setup(opts)
	opts = opts or {}

	-- Default keymaps (can be disabled)
	if opts.keymaps ~= false then
		vim.keymap.set('n', 'gf', M.goto_file, { desc = 'Goto file (unavigate)' })
		vim.keymap.set('n', '<C-w>f', M.goto_file_split, { desc = 'Goto file in split (unavigate)' })
		vim.keymap.set('n', '<C-w>gf', M.goto_file_tab, { desc = 'Goto file in tab (unavigate)' })

		-- ID search
		if opts.id_search_keymap then
			vim.keymap.set('n', opts.id_search_keymap, M.search_ids, { desc = 'Search ID tags (unavigate)' })
		end
	end
end

return M
