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

return M
