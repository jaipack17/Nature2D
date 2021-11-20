-- Handling exceptions

local TYPES = {
	NO_CANVAS_FOUND = "No canvas found, initialize the engine's canvas using Engine:CreateCanvas().",
	NO_RIGIDBODIES_FOUND = "No rigid bodies found on start.",
	PROPERTY_NOT_FOUND = "Invalid Argument #1. Property not found.",
	INVALID_CONSTRAINT_TYPE = "Received Invalid Constraint Type.",
	INVALID_CONSTRAINT_LENGTH = "Received Invalid Constraint Length.",
	INVALID_CONSTRAINT_THICKNESS = "Received Invalid Constraint Thickness.",
	SAME_ID = "Cannot ignore collisions for the same RigidBodies.",
	INVALID_RIGIDBODY = "Received Invalid RigidBody.",
	INVALID_OBJECT = "Received an Invalid Object. Valid objects - RigidBody, Point and Constraint",
	INVALID_PROPERTY = "Received an Invalid Object Property.",
	MUST_HAVE_PROPERTY = "Missing must-have properties.",
}

return function (TASK: string, TYPE: string)
	if TYPES[TYPE] then 
		if TASK == "warn" then 
			warn(TYPES[TYPE])
		elseif TASK == "error" then 
			error("[Nature2D]: "..TYPES[TYPE], 2)
		end
	end
end
