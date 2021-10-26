--[[
	Constraints keep two points together in place and maintain uniform distance between the two.
	Constraints and Points together join to keep a RigidBody in place hence making both Points and Constraints a vital part of the library. 
	Custom constraints such as Ropes, Rods, Bridges and chains can also be made. 
	Points of two rigid bodies can be connected with constraints, two individual points can also be connected with constraints to form Ropes etc.
]]--

local line = require(script.Parent.Parent.utils.Line)
local Globals = require(script.Parent.Parent.constants.Globals)
local throwTypeError = require(script.Parent.Parent.debug.TypeErrors)
local https = game:GetService("HttpService")

local Constraint = {}
Constraint.__index = Constraint

--[[
	Type Definitions
]]--

type canvas = {
	topLeft: Vector2,
	size: Vector2,
	frame: Frame
}

type segmentConfig = {	
	restLength: number?, 
	render: boolean, 
	thickness: number,
	support: boolean
}

--[[
	This method is used to initialize a constraint.

	[METHOD]: Constraint.new()
	[PARAMETERS]: p1: Point, p2: Point, canvas: canvas, config: segmentConfig
	[RETURNS]: Constraint
]]--

function Constraint.new(p1, p2, canvas, config: segmentConfig, engine)
	local self = setmetatable({
		id = https:GenerateGUID(false),
		engine = engine,
		Parent = nil,
		frame = nil,
		canvas = canvas,
		point1 = p1,
		point2 = p2,
		restLength = config.restLength or (p2.pos - p1.pos).magnitude,
		render = config.render,
		thickness = config.thickness,
		support = config.support,
		color = nil,
	}, Constraint)
	
	return self	
end

--[[
	This method is used to keep uniform distance between the constraint's points, i.e. constrain.

	[METHOD]: Constraint:Constrain()
	[PARAMETERS]: none
	[RETURNS]: nil
]]--

function Constraint:Constrain()
	local cur = (self.point2.pos - self.point1.pos).magnitude
	local offset = ((self.restLength - cur) / cur)/2

	local dir = self.point2.pos 
	dir -= self.point1.pos 
	dir *= offset

	if not self.point1.snap then
		self.point1.pos -= dir
	end

	if not self.point2.snap then
		self.point2.pos += dir
	end
end

--[[
	This method is used to update the position and appearance of the constraint on screen.

	[METHOD]: Constraint:Render()
	[PARAMETERS]: none
	[RETURNS]: nil
]]--

function Constraint:Render()
	if self.render and self.canvas.frame then
		local thickness = self.thickness or Globals.constraint.thickness
		local color = self.color or Globals.constraint.color
		
		if not self.frame then 
			self.frame = line(self.point1.pos, self.point2.pos, self.canvas.frame, thickness, color)
		end
		
		line(self.point1.pos, self.point2.pos, self.canvas.frame, thickness, color, self.frame)
	end
end

--[[
	Used to set the minimum constrained distance between two points. By default, the initial distance between the two points.
	
	[METHOD]: Constraint:SetLength()
	[PARAMETERS]: newLength: number,
	[RETURNS]: nil
]]--

function Constraint:SetLength(newLength: number)
	throwTypeError("length", newLength, 1, "number")
	self.restLength = newLength
end

--[[
	This method returns the current distance between the two points of a constraint.

	[METHOD]: Constraint:GetLength()
	[PARAMETERS]: none
	[RETURNS]: distance: number
]]--

function Constraint:GetLength()
	return (self.point2.pos - self.point1.pos).magnitude
end

--[[
	This method is used to change the color of a constraint. By default a constraint's color is set to the default value of (WHITE) Color3.new(1, 1, 1).
	
	[METHOD]: Constraint:Stroke()
	[PARAMETERS]: color: Color3,
	[RETURNS]: nil
]]--

function Constraint:Stroke(color: Color3)
	throwTypeError("color", color, 1, "Color3")
	self.color = color
end

--[[
	This method destroys the constraint. Its UI element is no longer rendered on screen and the constraint is removed from the engine. This is irreversible.	
	
	[METHOD]: Constraint:Destroy()
	[PARAMETERS]: none,
	[RETURNS]: nil
]]--

function Constraint:Destroy()
	if self.engine then 
		if self.frame then 
			self.frame:Destroy()
		end
		
		for i, c in ipairs(self.engine.constraints) do 
			if c.id == self.id then 
				table.remove(self.engine.constraints, i)
			end
		end
	end
end

--[[
	Returns the constraints points.
	
	[METHOD]: Constraint:GetPoints()
	[PARAMETERS]: none,
	[RETURNS]: point1: Point, point2: Point
]]--

function Constraint:GetPoints()
	return self.point1, self.point2
end

return Constraint