--[[
	Handling exceptions
]]--

local TYPES = {
	NO_CANVAS_FOUND = "[Nature2D]: No canvas found, initialize the engine's canvas using Engine:CreateCanvas().",
	NO_RIGIDBODIES_FOUND = "[Nature2D]: No rigid bodies found on start.",
	PROPERTY_NOT_FOUND = "[Nature2D]: Invalid Argument #1. Property not found.",
	INVALID_CONSTRAINT_TYPE = "[Nature2D]: Received Invalid Constraint Type.",
	INVALID_CONSTRAINT_LENGTH = "[Nature2D]: Received Invalid Constraint Length.",
	INVALID_CONSTRAINT_THICKNESS = "[Nature2D]: Received Invalid Constraint Thickness."
}

return function (TASK: string, TYPE: string)
	if TYPES[TYPE] then 
		if TASK == "warn" then 
			warn(TYPES[TYPE])
		elseif TASK == "error" then 
			error(TYPES[TYPE], 2)
		end
	end
end
