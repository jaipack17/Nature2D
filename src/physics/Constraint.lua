local line = require(script.Parent.Parent.utils.Line)
local Globals = require(script.Parent.Parent.constants.Globals)

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

function Constraint.new(p1, p2, canvas, config: segmentConfig)
	local self = setmetatable({
		Parent = nil,
		frame = nil,
		canvas = canvas,
		point1 = p1,
		point2 = p2,
		restLength = config.restLength or (p2.pos - p1.pos).magnitude,
		render = config.render,
		thickness = config.thickness,
		support = config.support
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
		if not self.frame then 
			self.frame = line(self.point1.pos, self.point2.pos, self.canvas.frame, self.thickness or Globals.constraint.thickness, Globals.constraint.color)
		end
		
		line(self.point1.pos, self.point2.pos, self.canvas.frame, self.thickness or Globals.constraint.thickness, Globals.constraint.color, self.frame)
	end
end

return Constraint

