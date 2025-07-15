local M = {}

-- ternary conditional operator / inline if
M.IIF = function(cond, T, F)
	if cond then
		return T
	else
		return F
	end
end

return M
