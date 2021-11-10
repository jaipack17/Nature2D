--[[
	Points are what make the rigid bodies behave like real world entities. 
	Points are responsible for the movement of the RigidBodies and Constraints.
]]--

local Globals = require(script.Parent.Parent.constants.Globals)
local Types = require(script.Parent.Parent.Types)
local throwTypeError = require(script.Parent.Parent.debug.TypeErrors)

local Point = {}
Point.__index = Point

--[[
	This method is used to initialize a new Point.

	[METHOD]: Point.new()
	[PARAMETERS]: pos: Vector2, canvas, engine: engineConfig, config: pointConfig
	[RETURNS]: Point
]]--

function Point.new(pos: Vector2, canvas: Types.Canvas, engine: Types.EngineConfig, config: Types.PointConfig)
	local self = setmetatable({
		Parent = nil,
		frame = nil,
		engine = engine,
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

--[[
	This method is used to apply a force to the Point. 
	
	[METHOD]: Point:ApplyForce()
	[PARAMETERS]: force: Vector2
	[RETURNS]: nil
]]--

function Point:ApplyForce(force: Vector2)
	self.forces += force
end

--[[
	This method is used to apply external forces like gravity and is responsible for moving the point.
	
	[METHOD]: Point:Update()
	[PARAMETERS]: dt: number
	[RETURNS]: nil
]]--

function Point:Update(dt: number)
	if not self.snap then
		self:ApplyForce(self.gravity)

		local velocity = self.pos 
		velocity -= self.oldPos
		if self.engine.independent then 
			self.forces *= dt * self.engine.speed
		end
		velocity += self.forces 
		velocity *= self.friction 

		self.oldPos = self.pos
		self.pos += velocity
		self.forces *= 0
	end
end

--[[
	This method is used to keep the point in the engine's canvas. Any point that goes past the canvas, is positioned correctly and the direction of its flipped is reversed accordingly. 
	
	[METHOD]: Point:KeepInCanvas()
	[PARAMETERS]: none
	[RETURNS]: nil
]]--

function Point:KeepInCanvas()
	local vx = self.pos.x - self.oldPos.x;
	local vy = self.pos.y - self.oldPos.y;

	local width = self.canvas.size.x	
	local height = self.canvas.size.y 

	local collision = false
	local edge;
	
	if self.pos.y > height then
		self.pos = Vector2.new(self.pos.x, height) 
		self.oldPos = Vector2.new(self.oldPos.x, self.pos.y + vy * self.bounce)
		collision = true
		edge = "Bottom"
	elseif self.pos.y < self.canvas.topLeft.y then
		self.pos = Vector2.new(self.pos.x, self.canvas.topLeft.y) 
		self.oldPos = Vector2.new(self.oldPos.x, self.pos.y - vy * self.bounce)
		collision = true
		edge = "Top"
	end

	if self.pos.x < self.canvas.topLeft.x then
		self.pos = Vector2.new(self.canvas.topLeft.x, self.pos.y) 
		self.oldPos = Vector2.new(self.pos.x + vx * self.bounce, self.oldPos.y)
		collision = true
		edge = "Left"
	elseif self.pos.x > width then
		self.pos = Vector2.new(width, self.pos.y) 
		self.oldPos = Vector2.new(self.pos.x - vx * self.bounce, self.oldPos.y)
		collision = true
		edge = "Right"
	end

	if collision then 
		if self.Parent and self.Parent.Parent then 
			self.Parent.Parent.CanvasEdgeTouched:Fire(edge)
		end
	end
end

--[[
	This method is used to update the position and appearance of the Point on screen.
	
	[METHOD]: Point:Render()
	[PARAMETERS]: none
	[RETURNS]: nil
]]--

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

--[[
	This method is used to determine the radius of the point.
	
	[METHOD]: Point:SetRadius()
	[PARAMETERS]: radius: number
	[RETURNS]: nil
]]--


function Point:SetRadius(radius: number)
	throwTypeError("radius", radius, 1, "number")
	self.radius = radius
end

--[[
	This method is used to determine the color of the point on screen. By default this is set to (RED) Color3.new(1, 0, 0).
	
	[METHOD]: Point:Stroke()
	[PARAMETERS]: color: Color3
	[RETURNS]: nil
]]--

function Point:Stroke(color: Color3)
	throwTypeError("color", color, 1, "Color3")
	self.color = color
end

--[[
	This method determines if the point remains anchored. If set to false, the point is unanchored.
	
	[METHOD]: Point:Snap()
	[PARAMETERS]: snap: boolean
	[RETURNS]: nil
]]--


function Point:Snap(snap: boolean)
	throwTypeError("snap", snap, 1, "boolean")
	self.snap = snap
end

--[[
	Returns the velocity of the Point
	
	[METHOD]: Point:Velocity()
	[PARAMETERS]: none
	[RETURNS]: velocity: Vector2
]]--

function Point:Velocity() : Vector2
	return self.pos - self.oldPos
end

--[[
	Returns the Parent (Constraint) of the Point if any.
	
	[METHOD]: Point:GetParent()
	[PARAMETERS]: none
	[RETURNS]: parent: Constraint | nil
]]--

function Point:GetParent()
	return self.Parent
end

return Point