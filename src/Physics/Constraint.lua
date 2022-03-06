-- Constraints keep two points together in place and maintain uniform distance between the two.
-- Constraints and Points together join to keep a RigidBody in place hence making both Points and Constraints a vital part of the library. 
-- Custom constraints such as Ropes, Rods, Bridges and chains can also be made. 
-- Points of two rigid bodies can be connected with constraints, two individual points can also be connected with constraints to form Ropes etc.

-- Services and utilities
local line = require(script.Parent.Parent.Utilities.Line)
local Globals = require(script.Parent.Parent.Constants.Globals)
local throwTypeError = require(script.Parent.Parent.Debugging.TypeErrors)
local throwException = require(script.Parent.Parent.Debugging.Exceptions)
local Janitor = require(script.Parent.Parent.Utilities.Janitor)
local Types = require(script.Parent.Parent.Types)
local https = game:GetService("HttpService")

local Constraint = {}
Constraint.__index = Constraint

-- This method is used to initialize a constraint.
function Constraint.new(p1: Types.Point, p2: Types.Point, canvas: Types.Canvas, config: Types.SegmentConfig, engine, parent)
	local self = setmetatable({
		id = https:GenerateGUID(false),
		_janitor = nil,
		engine = engine,
		Parent = parent,
		frame = nil,
		canvas = canvas,
		point1 = p1,
		point2 = p2,
		restLength = config.restLength or (p2.pos - p1.pos).Magnitude,
		render = config.render,
		thickness = config.thickness or Globals.constraint.thickness,
		support = config.support,
		_TYPE = config.TYPE,
		k = 0.1,
		color = nil,
	}, Constraint)
	
	local janitor = Janitor.new()
	janitor:Add(self, "Destroy")
	janitor:Add(self.point1, "Destroy")
	janitor:Add(self.point2, "Destroy")
	if self.Parent then 
		janitor:Add(self.Parent, "Destroy")
	end
	self._janitor = janitor
	
	self.point1.Parent = self
	self.point2.Parent = self
	self.point1._janitor:Add(self.point1.Parent, "Destroy")
	self.point2._janitor:Add(self.point2.Parent, "Destroy")
	
	return self
end

-- This method is used to keep uniform distance between the constraint's points, i.e. constrain.
function Constraint:Constrain()
	local cur = (self.point2.pos - self.point1.pos).Magnitude
	local force
	
	-- Validate constraint types
	if self._TYPE == "ROPE" then 
		local restLength = self.restLength
		if cur < self.thickness then 
			restLength = self.thickness
		end
		
		if cur > self.restLength or self.restLength < self.thickness then 
			-- Solve rope constraint force
			local offset = ((restLength - cur)/restLength)/2
			force = self.point2.pos - self.point1.pos 
			force *= offset
		end
	elseif self._TYPE == "ROD" then 
		-- Solve rod constraint force
		local offset = self.restLength - cur
		local dif = self.point2.pos - self.point1.pos
		dif = dif.Unit
		force = (dif * offset)/2
	elseif self._TYPE == "SPRING" then
		-- Solve spring constraint force
		force = self.point2.pos - self.point1.pos 
		local mag = force.Magnitude - self.restLength
		force = force.Unit
		force *= -1 * self.k * mag
	else
		return
	end
	
	-- Apply forces to constraint's points
	if force then 
		if not self.point1.snap then self.point1.pos -= force end
		if not self.point2.snap then self.point2.pos += force end		
	end
end

-- This method is used to update the position and appearance of the constraint on screen.
function Constraint:Render()
	if self.render and not self.support then
		if not self.canvas.frame then 
			throwException("error", "CANVAS_FRAME_NOT_FOUND")
		end
		
		local thickness = self.thickness or Globals.constraint.thickness
		local color = self.color or Globals.constraint.color
		local image = self._TYPE == "SPRING" and "rbxassetid://8404350124" or nil
		
		if not self.frame then 
			self.frame = line(self.point1.pos, self.point2.pos, self.canvas.frame, thickness, color, nil, image)
			
			self._janitor:LinkToInstance(self.frame)
			self._janitor:Add(self.frame, "Destroy")
		end
		
		-- Draw constraint on screen
		line(self.point1.pos, self.point2.pos, self.canvas.frame, thickness, color, self.frame, image)
	end
end

-- Used to set the minimum constrained distance between two points. 
-- By default, the initial distance between the two points.
function Constraint:SetLength(newLength: number)
	throwTypeError("length", newLength, 1, "number")
	if newLength <= 0 then 
		throwException("error", "INVALID_CONSTRAINT_LENGTH")
	end
	
	self.restLength = newLength
end

-- This method returns the current distance between the two points of a constraint.
function Constraint:GetLength() : number
	return (self.point2.pos - self.point1.pos).Magnitude
end

-- This method is used to change the color of a constraint. 
-- By default a constraint's color is set to the default value of (WHITE) Color3.new(1, 1, 1).
function Constraint:Stroke(color: Color3)
	throwTypeError("color", color, 1, "Color3")
	self.color = color
end

-- This method destroys the constraint. 
-- Its UI element is no longer rendered on screen and the constraint is removed from the engine. 
-- This is irreversible.	
function Constraint:Destroy()
	self._janitor:Cleanup()
	self.engine.ObjectRemoved:Fire(self)
	
	for i, c in ipairs(self.engine.constraints) do 
		if c.id == self.id then 
			table.remove(self.engine.constraints, i)
		end
	end
end

-- Returns the constraints points.
function Constraint:GetPoints()
	return self.point1, self.point2
end

-- Returns the UI element for the constrained IF rendered.
function Constraint:GetFrame() : Frame?
	return self.frame
end

-- This method is used to update the Spring constant (by default 0.1) used for spring constraint calculations.
function Constraint:SetSpringConstant(k: number)
	throwTypeError("springConstant", k, 1, "number")
	self.k = k
end

-- The constraints's unique ID can be fetched using this method.
function Constraint:GetId() : string
	return self.id
end

-- Returns the Parent (RigidBody) of the Constraint if any.
function Constraint:GetParent()
	return self.Parent
end

return Constraint
