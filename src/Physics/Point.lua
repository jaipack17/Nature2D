-- Points are what make the rigid bodies behave like real world entities.
-- Points are responsible for the movement of the RigidBodies and Constraints.

-- Services and utilities
local Globals = require(script.Parent.Parent.Constants.Globals)
local Types = require(script.Parent.Parent.Types)
local throwTypeError = require(script.Parent.Parent.Debugging.TypeErrors)
local throwException = require(script.Parent.Parent.Debugging.Exceptions)
local Janitor = require(script.Parent.Parent.Utilities.Janitor)
local HttpService = game:GetService("HttpService")

local Point = {}
Point.__index = Point

-- This method is used to initialize a new Point.
function Point.new(pos: Vector2, canvas: Types.Canvas, engine: Types.EngineConfig, config: Types.PointConfig, parent)
	local self = setmetatable({
		id = HttpService:GenerateGUID(false),
		Parent = parent,
		frame = nil,
		_janitor = nil,
		engine = engine,
		canvas = canvas,
		oldPos = pos,
		pos = pos,
		oldForces = Vector2.new(),
		forces = Vector2.new(),
		maxForce = nil,
		gravity = engine.gravity,
		friction = engine.friction,
		airfriction = engine.airfriction,
		bounce = engine.bounce,
		snap = config.snap,
		selectable = config.selectable,
		render = config.render,
		keepInCanvas = config.keepInCanvas,
		color = nil,
		radius = Globals.point.radius,
		timed = {
			start = nil,
			t = nil,
			force = Vector2.new()
		}
	}, Point)

	local janitor = Janitor.new()
	janitor:Add(self, "Destroy")
	if self.Parent then
		janitor:Add(self.Parent, "Destroy")
	end
	self._janitor = janitor

	return self
end

-- This method is used to apply a force to the Point.
function Point:ApplyForce(force: Vector2, t: number)
	throwTypeError("force", force, 1, "Vector2")
	self.forces += force

	if t then
		throwTypeError("time", t, 2, "number")
		if t <= 0 then
			throwException("error", "INVALID_TIME")
		end

		self.timed.start = os.clock()
		self.timed.t = t
		self.timed.force = force
	end
end

-- This method is used to apply external forces like gravity and is responsible for moving the point.
function Point:Update(dt: number)
	if not self.snap then
		self:ApplyForce(self.gravity)

		if self.timed.start then
			if os.clock() - self.timed.start < self.timed.t then
				self:ApplyForce(self.timed.force)
			else
				self.timed.start = nil
				self.timed.t = nil
				self.timed.force = Vector2.new()
			end
		end


		-- Calculate velocity
		local velocity = self.pos
		velocity -= self.oldPos
		velocity += self.forces

		local body = self.Parent

		-- Apply friction
		if body and body.Parent then
			local mass = body.Parent.mass

			if mass then
				self.forces /= mass
			end

			if body.Parent.Collisions.CanvasEdge or body.Parent.Collisions.Body then
				velocity *= self.friction
			else
				velocity *= self.airfriction
			end
		else
			velocity *= self.friction
		end

		-- clamp velocity
		if self.maxForce then
			velocity = velocity.Unit * math.min(velocity.Magnitude, self.maxForce)
		end

		-- Update point positions
		self.oldPos = self.pos
		self.pos += velocity
		self.oldForces = self.forces
		self.forces *= 0
	end
end

-- This method is used to keep the point in the engine's canvas.
-- Any point that goes past the canvas, is positioned correctly and the direction of its flipped is reversed accordingly.
function Point:KeepInCanvas()
	-- vx = velocity.X
	-- vy = velocity.Y
	local vx = self.pos.X - self.oldPos.X
	local vy = self.pos.Y - self.oldPos.Y

	local boundX = self.canvas.topLeft.X + self.canvas.size.X
	local boundY = self.canvas.topLeft.Y + self.canvas.size.Y

	local collision = false
	local edge

	if self.pos.Y > boundY then
		self.pos = Vector2.new(self.pos.X, boundY)
		self.oldPos = Vector2.new(self.oldPos.X, self.pos.Y + vy * self.bounce)
		collision = true
		edge = "Bottom"
	elseif self.pos.Y < self.canvas.topLeft.Y then
		self.pos = Vector2.new(self.pos.X, self.canvas.topLeft.Y)
		self.oldPos = Vector2.new(self.oldPos.X, self.pos.Y - vy * self.bounce)
		collision = true
		edge = "Top"
	end

	if self.pos.X < self.canvas.topLeft.X then
		self.pos = Vector2.new(self.canvas.topLeft.X, self.pos.Y)
		self.oldPos = Vector2.new(self.pos.X + vx * self.bounce, self.oldPos.Y)
		collision = true
		edge = "Left"
	elseif self.pos.X > boundX then
		self.pos = Vector2.new(boundX, self.pos.Y)
		self.oldPos = Vector2.new(self.pos.X - vx * self.bounce, self.oldPos.Y)
		collision = true
		edge = "Right"
	end

	local body = self.Parent

	-- Fire CanvasEdgeTouched event
	if body and body.Parent then
		if collision then
			local prev = body.Parent.Collisions.CanvasEdge
			body.Parent.Collisions.CanvasEdge = true
			if prev == false then
				body.Parent.CanvasEdgeTouched:Fire(edge)
			end
		else
			body.Parent.Collisions.CanvasEdge = false
		end
	end
end

-- This method is used to update the position and appearance of the Point on screen.
function Point:Render()
	if self.render then
		if not self.canvas.frame then
			throwException("error", "CANVAS_FRAME_NOT_FOUND")
		end

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

			self._janitor:Add(self.frame, "Destroy")
		end

		-- Update the point's instance
		self.frame.Position = UDim2.new(0, self.pos.x, 0, self.pos.y)
	end

	if self.keepInCanvas then
		self:KeepInCanvas()
	end
end

function Point:Destroy()
	self._janitor:Cleanup()

	if not self.Parent then
		for i, c in ipairs(self.engine.points) do
			if c.id == self.id then
				table.remove(self.engine.points, i)
				self.engine.ObjectRemoved:Fire(self)
				break
			end
		end
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

function Point:GetNetForce() : Vector2
	return self.oldForces
end

-- Returns the Parent (Constraint) of the Point if any.
function Point:GetParent()
	return self.Parent
end

-- Used to set a new position for the point
function Point:SetPosition(x: number, y: number)
	throwTypeError("x", x, 1, "number")
	throwTypeError("y", y, 2, "number")
	local newPosition = Vector2.new(x, y)
	self.oldPos = newPosition
	self.pos = newPosition
end

-- Determines the max force that can be aoplied to the Point.
function Point:SetMaxForce(maxForce: number)
	throwTypeError("maxForce", maxForce, 1, "number")
	self.maxForce = math.abs(maxForce)
end

return Point
