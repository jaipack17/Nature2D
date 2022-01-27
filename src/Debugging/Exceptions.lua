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
	INVALID_OBJECT = "Received an Invalid Object. Valid objects - RigidBody, Point and Constraint.",
	INVALID_PROPERTY = "Received an Invalid Object Property.",
	MUST_HAVE_PROPERTY = "Missing must-have properties.",
	CANVAS_FRAME_NOT_FOUND = "No canvas frame found, initialize the canvas's frame to render custom Points and Constraints!",
	INVALID_TIME = "Received invalid time to apply force for.",
	ALREADY_STARTED = "Engine is already running.",
	CANNOT_SET_COLLISION_ITERATIONS = "Cannot set collision iterations! You must turn on quadtree usage using Engine:UseQuadtrees(true)."
}

return function (TASK: string, TYPE: string, details: string?)
	if TYPES[TYPE] then
		local exception = string.format("[Nature2D]: %s%s", TYPES[TYPE], if details then " "..details else "")

		if TASK == "warn" then
			warn(exception)
		elseif TASK == "error" then
			error(exception, 2)
		end
	end
end
