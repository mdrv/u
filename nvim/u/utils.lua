local u = {}

-- ternary conditional operator / inline if
u.IIF = function(cond, T, F)
	if cond then
		return T
	else
		return F
	end
end

return u
