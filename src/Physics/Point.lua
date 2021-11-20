-- Points are what make the rigid bodies behave like real world entities. 
-- Points are responsible for the movement of the RigidBodies and Constraints.

-- Services and utilities
local Globals = require(script.Parent.Parent.Constants.Globals)
local Types = require(script.Parent.Parent.Types)
local throwTypeError = require(script.Parent.Parent.Debugging.TypeErrors)

local Point = {}
Point.__index = Point

-- This method is used to initialize a new Point.
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
		airfriction = engine.airfriction,
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

-- This method is used to apply a force to the Point. 
function Point:ApplyForce(force: Vector2)
	self.forces += force
end

-- This method is used to apply external forces like gravity and is responsible for moving the point.
function Point:Update(dt: number)
	if not self.snap then
		self:ApplyForce(self.gravity)
		
		-- Calculate velocity
		local velocity = self.pos 
		velocity -= self.oldPos
		if self.engine.independent then 
			self.forces *= dt * self.engine.speed
		end
		velocity += self.forces 
		
		local body = self.Parent
		
		-- Apply friction
		if body and body.Parent then 
			if body.Parent.Collisions.CanvasEdge or body.Parent.Collisions.Body then 
				velocity *= self.friction 
			else 
				velocity *= self.airfriction
			end			
		else 
			velocity *= self.friction
		end
		
		-- Update point positions
		self.oldPos = self.pos
		self.pos += velocity
		self.forces *= 0
	end
end

-- This method is used to keep the point in the engine's canvas. 
-- Any point that goes past the canvas, is positioned correctly and the direction of its flipped is reversed accordingly. 
function Point:KeepInCanvas()
	-- vx = velocity.X
	-- vy = velocity.Y
	local vx = self.pos.x - self.oldPos.x
	local vy = self.pos.y - self.oldPos.y

	local width = self.canvas.size.x	
	local height = self.canvas.size.y 

	local collision = false
	local edge
	
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
	
	local body = self.Parent
	
	-- Fire CanvasEdgeTouched event
	if body and body.Parent then 
		if collision then 
			body.Parent.Collisions.CanvasEdge = true
			body.Parent.CanvasEdgeTouched:Fire(edge)
		else
			body.Parent.Collisions.CanvasEdge = false
		end
	end
end

-- This method is used to update the position and appearance of the Point on screen.
function Point:Render()
	if self.render then 
		if not self.frame then 
			-- Create new instance for the point
			local p = Instance.new("Frame")
			local border = Instance.new("UICorner")
			local r = self.radius or Globals.point.radius
			
			p.AnchorPoint = Vector2.new(.5, .5)
			p.BackgroundColor3 = self.color or Globals.point.color
			p.Size = UDim2.new(0, r * 2, 0, r * 2)
			p.Parent = self.canvas.frame

			border.CornerRadius = Globals.point.uicRadius
			border.Parent = p

			self.frame = p
		end
		
		-- Update the point's instance
		self.frame.Position = UDim2.new(0, self.pos.x, 0, self.pos.y)
	end
	
	if self.keepInCanvas then 
		self:KeepInCanvas()
	end
end

-- This method is used to determine the radius of the point.
function Point:SetRadius(radius: number)
	throwTypeError("radius", radius, 1, "number")
	self.radius = radius
end

-- his method is used to determine the color of the point on screen. 
-- By default this is set to (RED) Color3.new(1, 0, 0).
function Point:Stroke(color: Color3)
	throwTypeError("color", color, 1, "Color3")
	self.color = color
end

-- This method determines if the point remains anchored. 
-- If set to false, the point is unanchored.
function Point:Snap(snap: boolean)
	throwTypeError("snap", snap, 1, "boolean")
	self.snap = snap
end

-- Returns the velocity of the Point
function Point:Velocity() : Vector2
	return self.pos - self.oldPos
end

-- Returns the Parent (Constraint) of the Point if any.
function Point:GetParent()
	return self.Parent
end

-- Used to set a new position for the point
function Point:SetPosition(newPosition: Vector2)
	throwTypeError("newPosition", newPosition, 1, "Vector2")
	self.oldPos = newPosition
	self.pos = newPosition
end

return Point