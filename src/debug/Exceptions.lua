--[[
	Handling exceptions
]]--

local Types = require(script.Parent.Parent.Types)

local EXCEPTIONS: Types.Exceptions = {
	NO_CANVAS_FOUND = "[Nature2D]: No canvas found, initialize the engine's canvas using Engine:CreateCanvas().",
	NO_RIGIDBODIES_FOUND = "[Nature2D]: No rigid bodies found on start.",
	PROPERTY_NOT_FOUND = "[Nature2D]: Invalid Argument #1. Property not found.",
}

return function (TASK: string, TYPE: string)
	if EXCEPTIONS[TYPE] then 
		if TASK == "warn" then 
			warn(EXCEPTIONS[TYPE])
		elseif TASK == "error" then 
			error(EXCEPTIONS[TYPE], 2)
		end
	end
end
