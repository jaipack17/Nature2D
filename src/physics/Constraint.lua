local line = require(script.Parent.Parent.utils.Line)
local Globals = require(script.Parent.Parent.constants.Globals)
local throwTypeError = require(script.Parent.Parent.debug.TypeErrors)
local https = game:GetService("HttpService")

local Constraint = {}
Constraint.__index = Constraint

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

function Constraint:GetLength()
	return (self.point2.pos - self.point1.pos).magnitude
end

function Constraint:Stroke(color: Color3)
	throwTypeError("color", color, 1, "Color3")
	self.color = color
end

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

return Constraint