--[[
	Handling type errors
]]--

return function (arg: string, param, pos: number, expected: string)
	if typeof(param) ~= expected then 
		error("[Nature2D]: Invalid Argument #"..pos..". Expected "..expected.." for '"..arg.."', got "..typeof(param)..".", 2)
	end
end