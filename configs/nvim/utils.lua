local M = {}

---Ternary conditional operator / inline if
---@generic T
---@generic F
---@param cond boolean Condition
---@param T T Value if true
---@param F F Value if false
---@return T|F Result
M.IIF = function(cond, T, F)
	if cond then
		return T
	else
		return F
	end
end

---This function reads and parses JSON file
---@param path: string - the path to the JSON file
---@return: table - the parsed JSON data as a Lua table
---@throws: error if the file cannot be read or if the JSON is invalid
---Example usage:
---local data = read_json_file('config.json')
M.read_json_file = function(path)
	local file = io.open(path, 'r')
	if not file then
		error('Could not open file: ' .. path)
	end
	local content = file:read('*a')
	file:close()
	local success, result = pcall(vim.fn.json_decode, content)
	if not success then
		error('Invalid JSON in file: ' .. path .. '\nError: ' .. result)
	end
	return result
end

---Execute Lua code string and display result via vim.notify
---Handles nil returns and pretty-prints tables with vim.inspect
---@param code string - Lua code to execute
M.execute_lua_and_notify = function(code)
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

return M
