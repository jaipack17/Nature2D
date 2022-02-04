-- This only exists because the LSP warns Key `__tostring` not found in type `table?`.
local function Symbol(Name: string)
	local self = newproxy(true)
	local Metatable = getmetatable(self)
	function Metatable.__tostring()
		return Name
	end

	return self
end

return Symbol