local Globals = require(script.Parent.Parent.constants.Globals)

local Point = {}
Point.__index = Point

type engineConfig = {
	gravity: Vector2,
	friction: number,
	bounce: number
}

type canvas = {
	topLeft: Vector2,
	size: Vector2,
	frame: Frame
}

type pointConfig = {
	snap: boolean, 
	selectable: boolean, 
	render: boolean,
	keepInCanvas: boolean
}

function Point.new(pos: Vector2, canvas, engine: engineConfig, config: pointConfig)
	local self = setmetatable({
		Parent = nil,
		frame = nil,
		canvas = canvas,
		oldPos = pos,
		pos = pos,
		forces = Vector2.new(0, 0),
		gravity = engine.gravity,
		friction = engine.friction,
		bounce = engine.bounce,
		snap = config.snap,
		selectable = config.selectable,
		render = config.render,
		keepInCanvas = config.keepInCanvas,
		color = nil,
		radius = Globals.point.radius
	}, Point)
	
	return self 
end

function Point:ApplyForce(force)
	self.forces += force
end

function Point:Update(dt: number)
	if not self.snap then
		self:ApplyForce(self.gravity)
		
		local velocity = self.pos 
		velocity -= self.oldPos
		velocity += self.forces * dt * Globals.speed
		velocity *= self.friction 
		
		self.oldPos = self.pos
		self.pos += velocity
		self.forces *= 0
	end
end

function Point:KeepInCanvas()
	local vx = self.pos.x - self.oldPos.x;
	local vy = self.pos.y - self.oldPos.y;
	
	local width = self.canvas.size.x	
	local height = self.canvas.size.y 
	
	local collision = false
	
	if self.pos.y > height then
		self.pos = Vector2.new(self.pos.x, height) 
		self.oldPos = Vector2.new(self.oldPos.x, self.pos.y + vy * self.bounce)
		collision = true
	elseif self.pos.y < self.canvas.topLeft.y then
		self.pos = Vector2.new(self.pos.x, self.canvas.topLeft.y) 
		self.oldPos = Vector2.new(self.oldPos.x, self.pos.y - vy * self.bounce)
		collision = true
	end
	
	if self.pos.x < self.canvas.topLeft.x then
		self.pos = Vector2.new(self.canvas.topLeft.x, self.pos.y) 
		self.oldPos = Vector2.new(self.pos.x + vx * self.bounce, self.oldPos.y)
		collision = true
	elseif self.pos.x > width then
		self.pos = Vector2.new(width, self.pos.y) 
		self.oldPos = Vector2.new(self.pos.x - vx * self.bounce, self.oldPos.y)
		collision = true
	end
	
	if collision then 
		if self.Parent and self.Parent.Parent then 
			self.Parent.Parent.CanvasEdgeTouched:Fire()
		end
	end
end

function Point:Render()
	if self.render then 
		if not self.frame then 
			local p = Instance.new("Frame")
			local border = Instance.new("UICorner")
			local r = self.radius or Globals.point.radius
			
			p.BackgroundColor3 = self.color or Globals.point.color
			p.Size = UDim2.new(0, r * 2, 0, r * 2)
			p.Parent = self.canvas.frame
			
			border.CornerRadius = Globals.point.uicRadius
			border.Parent = p
			
			self.frame = p
		end
		
		self.frame.Position = UDim2.new(0, self.pos.x, 0, self.pos.y)
	end
	
	if self.keepInCanvas then 
		self:KeepInCanvas()
	end
end

function Point:SetRadius(radius: number)
	if not typeof(radius) == "number" then error("Invalid Argument #1. 'radius' must be a number", 2) end 
	self.radius = radius
end

function Point:Stroke(color: Color3)
	if not typeof(color) == "Color3" then error("Invalid Argument #1. 'color' must be a Color3 value", 2) end 
	self.color = color
end

function Point:Snap(snap: boolean)
	if not typeof(snap) == "boolean" then error("Invalid Argument #1. 'snap' must be a boolean", 2) end 
	self.snap = snap
end

return Point
