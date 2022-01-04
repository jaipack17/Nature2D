-- RigidBodies are formed by Constraints, Points and UI Elements.

-- Services and utilities
local Point = require(script.Parent.Point)
local Constraint = require(script.Parent.Constraint)
local Globals = require(script.Parent.Parent.Constants.Globals)
local Signal = require(script.Parent.Parent.Utilities.Signal)
local Types = require(script.Parent.Parent.Types)
local throwTypeError = require(script.Parent.Parent.Debugging.TypeErrors)
local throwException = require(script.Parent.Parent.Debugging.Exceptions)
local restrict = require(script.Parent.Parent.Debugging.Restrict)
local HttpService = game:GetService("HttpService")

local RigidBody = {}
RigidBody.__index = RigidBody

-- [PRIVATE]
-- This method is used to fetch the positions of the 4 corners of  UI element.
local function GetCorners(frame: GuiObject, engine)
	local pos, size = frame.AbsolutePosition, frame.AbsoluteSize
	local rotation = math.rad(frame.Rotation)
	local center = pos + size/2
	local temp = math.sqrt((size.X/2)^2+(size.Y/2)^2)

	local offset = (engine.path and engine.path.IgnoreGuiInset) and Globals.offset or Vector2.new(0, 0)
	
	-- Calculate and return all 4 corners of the GuiObject
	-- Also adheres to the Rotation of the GuiObject
	local t = math.atan2(size.Y, size.X)
	local a = rotation + t
	local b = rotation - t
	
	return {
		center - temp * Vector2.new(math.cos(a), math.sin(a)) + offset, -- topleft
		center + temp * Vector2.new(math.cos(b), math.sin(b)) + offset, -- topright
		center - temp * Vector2.new(math.cos(b), math.sin(b)) + offset, -- bottomleft
		center + temp * Vector2.new(math.cos(a), math.sin(a)) + offset, -- bottomright
	}
end

-- This method is used to calculate the depth/penetration of a collision
local function CalculatePenetration(minA: number, maxA: number, minB: number, maxB: number) : number
	if minA < minB then 
		return minB - maxA 
	else 
		return minA - maxB 
	end
end

local function CalculateOffset(pos, anchorPoint, size)
	return (Vector2.new(.5, .5) - anchorPoint) * size
end

-- This method is used to calculate the center position of a UI element
local function CalculateCenter(vertices) : Vector2
	local center = Vector2.new(0, 0)

	local minX = math.huge
	local minY = math.huge
	local maxX = -math.huge
	local maxY = -math.huge

	for _, v in ipairs(vertices) do 
		center += v.pos
		minX = math.min(minX, v.pos.x)
		minY = math.min(minY, v.pos.y)
		maxX = math.max(maxX, v.pos.x)
		maxY = math.max(maxY, v.pos.y)
	end

	center /= #vertices

	return center
end

-- Used to calculate the AbsoluteSize for custom RigidBodies
local function CalculateSize(vertices)
	local minX = math.huge
	local minY = math.huge
	local maxX = -math.huge
	local maxY = -math.huge

	for _, v in ipairs(vertices) do 
		minX = math.min(minX, v.pos.x)
		minY = math.min(minY, v.pos.y)
		maxX = math.max(maxX, v.pos.x)
		maxY = math.max(maxY, v.pos.y)
	end

	return Vector2.new(maxX - minX, maxY - minY)
end

-- This method is used to update the positions of each point of a rigidbody to the corners of a UI element.
local function UpdateVertices(frame: GuiObject, vertices, engine)
	local corners = GetCorners(frame, engine)
	for i, vertex in ipairs(vertices) do 
		vertex:SetPosition(corners[i].X, corners[i].Y)
	end
end

-- [PUBLIC]
-- This method is used to initialize a new RigidBody.
function RigidBody.new(frame: GuiObject?, m: number, collidable: boolean?, anchored: boolean?, engine, custom: Types.Custom?)
	local isCustom = false
	
	if custom then 
		isCustom = true
	end
	
	local vertices = isCustom and custom.Vertices or {}
	local edges = isCustom and custom.Edges or {}
	
	-- Configurations
	local pointConfig = {
		snap = anchored, 
		selectable = false, 
		render = false,
		keepInCanvas = true
	}

	local constraintConfig = {
		restLength = nil, 
		render = false, 
		thickness = 4,
		support = false,
		TYPE = "ROD"
	}
	
	-- Point creation method
	local function addPoint(pos)
		local newPoint = Point.new(pos, engine.canvas, engine, pointConfig)
		vertices[#vertices + 1] = newPoint

		return newPoint
	end
	
	-- Constraint creation method
	local function addConstraint(p1, p2, support)
		constraintConfig.support = support

		local newConstraint = Constraint.new(p1, p2, engine.canvas, constraintConfig)
		edges[#edges + 1] = newConstraint

		return newConstraint
	end
	
	if not isCustom then 
		-- Create Points
		local corners = GetCorners(frame, engine)
		local topleft = addPoint(corners[1])
		local topright = addPoint(corners[2])
		local bottomleft = addPoint(corners[3])
		local bottomright = addPoint(corners[4])

		-- Connect points with constraints
		addConstraint(topleft, topright, false)
		addConstraint(topleft, bottomleft, false)
		addConstraint(topright, bottomright, false)
		addConstraint(bottomleft, bottomright, false)
		addConstraint(topleft, bottomright, true)
		addConstraint(topright, bottomleft, true)    	
	end           

	local self = setmetatable({
		id = HttpService:GenerateGUID(false),
		custom = isCustom,
		vertices = vertices,
		edges = edges,
		frame = isCustom and nil or frame,
		size = isCustom and CalculateSize(vertices) or nil,
		anchored = anchored,
		mass = m,
		collidable = collidable,
		center = isCustom and CalculateCenter(vertices) or frame.AbsolutePosition + frame.AbsoluteSize/2,
		engine = engine,
		spawnedAt = os.clock(),
		lifeSpan = nil,
		anchorRotation = (anchored and not isCustom) and frame.Rotation or nil,
		anchorPos = (anchored and not isCustom) and frame.AbsolutePosition + frame.AbsoluteSize/2 or nil,
		Touched = nil,
		TouchEnded = nil,
		CanvasEdgeTouched = nil,
		Collisions = {			
			Body = false,
			CanvasEdge = false,
			Other = {}
		},
		States = {},
		filtered = {},
	}, RigidBody)
	
	-- Apply offsets if ScreenGui's IgnoreGuiInset property is set to true
	-- Offset = Vector2.new(0, 36)
	if engine.path and engine.path.IgnoreGuiInset then 
		self.anchorPos = self.anchorPos and self.anchorPos + Globals.offset or nil
		self.center += Globals.offset
	end
	
	-- Create events
	self.Touched = Signal.new()
	self.TouchEnded = Signal.new()
	self.CanvasEdgeTouched = Signal.new()
	
	-- Set parents of points and constraints
	for _, edge in ipairs(edges) do
		edge.point1.Parent = edge
		edge.point2.Parent = edge
		edge.Parent = self
	end

	return self
end

-- This method projects the RigidBody on an axis. Used for collision detection.
function RigidBody:CreateProjection(Axis: Vector2, Min: number, Max: number) : (number, number)
	local DotP = Axis:Dot(self.vertices[1].pos)
	Min, Max = DotP, DotP

	for _, v in ipairs(self.vertices) do
		DotP = Axis:Dot(v.pos)
		Min = math.min(DotP, Min)
		Max = math.max(DotP, Max)
	end

	return Min, Max
end

-- This method detects collision between two RigidBodies.
function RigidBody:DetectCollision(other)
	if not self.custom and (not self.frame and not other.frame) then 
		return { false, {} }
	end
	
	-- Calculate center of the Body
	self.center = CalculateCenter(self.vertices)
	
	-- Initialize collision information
	local minDist = math.huge
	local collision: Types.Collision = {
		axis = nil,
		depth = nil,
		edge = nil,
		vertex = nil
	}
	
	-- Loop throught both bodies' edges (excluding support edges)
	-- Calculate an axis and then project both bodies to the axis
	-- Assign axis and edge of collision to the collision information dictionary
	-- Calculate the penetration/depth of the collision
	-- Find the vertex that collided with the edge
	-- If a collision took place, return the collision information
	for i = 1, #self.edges + #other.edges, 1 do
		local edge = i <= #self.edges and self.edges[i] or other.edges[i - #self.edges]

		if not edge.support then 
			local axis = Vector2.new(
				edge.point1.pos.Y - edge.point2.pos.Y,
				edge.point2.pos.X - edge.point1.pos.X
			).Unit

			local MinA, MinB, MaxA, MaxB
			MinA, MaxA = self:CreateProjection(axis, MinA, MaxA)
			MinB, MaxB = other:CreateProjection(axis, MinB, MaxB)

			local dist = CalculatePenetration(MinA, MaxA, MinB, MaxB)

			if dist > 0 then 
				return { false, {} }
			elseif math.abs(dist) < minDist then
				minDist = math.abs(dist) 
				collision.axis = axis
				collision.edge = edge
			end	
		end
	end

	collision.depth = minDist

	if collision.edge and collision.edge.Parent ~= other then
		local Temp = other
		other = self
		self = Temp
	end

	local centerDif = self.center - other.center
	local dot = collision.axis:Dot(centerDif)

	if dot < 0 then 
		collision.axis *= -1
	end	

	local minMag = math.huge 

	for i = 1, #self.vertices, 1 do
		local dif =  self.vertices[i].pos - other.center
		local dist = collision.axis:Dot(dif)

		if dist < minMag then
			minMag = dist
			collision.vertex = self.vertices[i]
		end
	end

	return { true, collision }
end

-- This method is used to apply an external force on the rigid body.
function RigidBody:ApplyForce(force: Vector2, t: number)
	throwTypeError("force", force, 1, "Vector2")
	
	if t then 
		throwTypeError("time", t, 2, "number")
		if t <= 0 then 
			throwException("error", "INVALID_TIME")
		end
	end
	
	for _, v in ipairs(self.vertices) do 
		v:ApplyForce(force, t)
	end
end

-- This method updates the positions of the RigidBody's points and constraints.
function RigidBody:Update(dt: number)
	self.center = CalculateCenter(self.vertices)
	
	-- Update vertices and edges together
	for i = 1, #self.vertices + #self.edges do 
		local edge = i > #self.vertices

		if edge then 
			local e = self.edges[(#self.vertices + #self.edges) + 1 - i]
			e:Constrain()
			if self.custom then 
				e:Render()
			end
		else 
			self.vertices[i]:Update(dt)
			self.vertices[i]:Render()
		end
	end	
end

-- This method updates the positions and appearance of the RigidBody on screen.
function RigidBody:Render()
	-- If the RigidBody exceeds its life span, it is destroyed.
	if self.lifeSpan and os.clock() - self.spawnedAt >= self.lifeSpan then 
		self:Destroy()
	end
	
	if self.custom then return end
	
	-- Apply rotations and update positions
	-- Respects the anchor point of the GuiObject

	if self.anchored then
		local anchorPos = self.anchorPos - CalculateOffset(self.anchorPos, self.frame.AnchorPoint, self.frame.AbsoluteSize)
		self.frame.Position = UDim2.fromOffset(anchorPos.X, anchorPos.Y)
		self:Rotate(self.anchorRotation)
	else 
		local center = self.center - CalculateOffset(self.center, self.frame.AnchorPoint, self.frame.AbsoluteSize)
		local dif: Vector2 = self.vertices[2].pos - self.vertices[1].pos

		self.frame.Position = UDim2.new(0, center.X, 0, center.Y)
		self.frame.Rotation = math.deg(math.atan2(dif.Y, dif.X))
	end
end

-- This method is used to clone the RigidBody while keeping the original one intact.
function RigidBody:Clone(deepCopy: boolean)
	restrict(self.custom)
	if not self.frame then return end
	
	local frame = self.frame:Clone()
	frame.Parent = self.frame.Parent
	
	local copy = RigidBody.new(frame, self.mass, self.collidable, self.anchored, self.engine)
	
	-- Copy lifespan, states and filtered RigidBodies
	if deepCopy == true then 
		copy.States = self.States
		
		if self.lifeSpan then 
			copy:SetLifeSpan(self.lifeSpan)
		end
		
		for _, body in ipairs(self.filtered) do
			copy:FilterCollisionsWith(body)
		end
	end
	
	table.insert(self.engine.bodies, copy)
	self.engine.ObjectAdded:Fire(copy)
	
	return copy
end

-- This method is used to destroy the RigidBody. 
-- The body's UI element is destroyed, its connections are disconnected and the body is removed from the engine.
function RigidBody:Destroy(keepFrame: boolean)
	for i, body in ipairs(self.engine.bodies) do
		if self.id == body.id then
			-- Destroy events
			-- Destroy the frame and remove the RigidBody from the Engine.
			self.Touched:Destroy()
			self.CanvasEdgeTouched:Destroy()
			self.Touched = nil 
			self.CanvasEdgeTouched = nil
			if not self.custom and not keepFrame then 
				self.frame:Destroy()
			end
			if self.custom and not keepFrame then 
				for _, c in ipairs(self.edges) do 
					if c.frame then 
						c.frame:Destroy()
					end
				end
			end
			table.clear(self.Collisions.Other)
			table.remove(self.engine.bodies, i)
			self.engine.ObjectRemoved:Fire(self)
			break
		end
	end
end

-- This method is used to rotate the RigidBody's UI element. 
-- After rotation the positions of its points and constraints are automatically updated.
function RigidBody:Rotate(newRotation: number)
	restrict(self.custom)
	throwTypeError("newRotation", newRotation, 1, "number")
	
	-- Update anchorRotation if the body is anchored
	if self.anchored and self.anchorRotation then 
		self.anchorRotation = newRotation
	end
	
	-- Apply rotation and update positions
	-- Update the RigidBody's points
	local oldRotation = self.frame.Rotation
	local offset = CalculateOffset(self.anchorPos, self.frame.AnchorPoint, self.frame.AbsoluteSize)
	local position = self.anchorPos - offset
	self.frame.Position = self.anchored and UDim2.fromOffset(position.X, position.Y)  or UDim2.fromOffset(self.center.x, self.center.y)
	self.frame.Rotation = newRotation
	UpdateVertices(self.frame, self.vertices, self.engine)

	return oldRotation, newRotation
end

-- This method is used to set a new position of the RigidBody's UI element.
function RigidBody:SetPosition(PositionX: number, PositionY: number)
	restrict(self.custom)
	throwTypeError("PositionX", PositionX, 1, "number")
	throwTypeError("PositionY", PositionY, 2, "number")
	
	-- Update anchorPos if the body is anchored
	if self.anchored and self.anchorPos then 
		self.anchorPos = Vector2.new(PositionX, PositionY)
	end
	
	-- Update position
	-- Update the RigidBody's points
	local oldPosition = self.frame.Position
	self.frame.Position = UDim2.fromOffset(PositionX, PositionY)
	UpdateVertices(self.frame, self.vertices, self.engine)

	return oldPosition, UDim2.fromOffset(PositionX, PositionY)
end

-- This method is used to set a new size of the RigidBody's UI element. 
function RigidBody:SetSize(SizeX: number, SizeY: number)
	restrict(self.custom)
	throwTypeError("SizeX", SizeX, 1, "number")
	throwTypeError("SizeY", SizeY, 2, "number")	
	
	-- Update size
	-- Update the RigidBody's points
	local oldSize = self.frame.Size
	self.frame.Size = UDim2.fromOffset(SizeX, SizeY)
	UpdateVertices(self.frame, self.vertices, self.engine)

	return oldSize, UDim2.fromOffset(SizeX, SizeY)
end

-- This method is used to anchor the RigidBody.
-- Its position will no longer change.
function RigidBody:Anchor()
	self.anchored = true
	self.anchorRotation = self.frame and self.frame.Rotation or nil
	self.anchorPos = self.center

	for _, vertex in ipairs(self.vertices) do
		if not vertex.selectable then vertex.snap = self.anchored end
	end
end

-- This method is used to unachor and anchored RigidBody.
function RigidBody:Unanchor()
	self.anchored = false
	self.anchorRotation = nil
	self.anchorPos = nil

	for _, vertex in ipairs(self.vertices) do
		if not vertex.selectable then vertex.snap = self.anchored end
	end
end

-- This method is used to determine whether the RigidBody will collide with other RigidBodies. 
function RigidBody:CanCollide(collidable: boolean)
	throwTypeError("collidable", collidable, 1, "boolean")
	self.collidable = collidable
end

-- The RigidBody's UI Element can be fetched using this method.
function RigidBody:GetFrame() : GuiObject
	return self.frame
end

-- The RigidBody's unique ID can be fetched using this method.
function RigidBody:GetId() : string
	return self.id
end

-- The RigidBody's Points can be fetched using this method.
function RigidBody:GetVertices()
	return self.vertices
end

-- The RigidBody's Constraints can be fetched using this method.
function RigidBody:GetConstraints()
	return self.edges
end

--vThis method is used to set the RigidBody's life span. 
-- Life span is determined by 'seconds'.
-- After this time in seconds has been passed after the RigidBody is created, the RigidBody is automatically destroyed and removed from the engine.
function RigidBody:SetLifeSpan(seconds: number)
	throwTypeError("seconds", seconds, 1, "number")
	self.lifeSpan = seconds
end

-- This method determines if the RigidBody stays inside the engine's canvas at all times. 
function RigidBody:KeepInCanvas(keepInCanvas: boolean)
	throwTypeError("keepInCanvas", keepInCanvas, 1, "boolean")

	for _, p in ipairs(self.vertices) do 
		p.keepInCanvas = keepInCanvas
	end
end

-- This method sets a custom frictional damp value just for the RigidBody.
function RigidBody:SetFriction(friction: number)
	throwTypeError("friction", friction, 1, "number")

	for _, p in ipairs(self.vertices) do
		p.friction =  math.clamp(1 - friction, 0, 1)
	end
end

-- This method sets a custom air frictional damp value just for the RigidBody.
function RigidBody:SetAirFriction(friction: number)
	throwTypeError("friction", friction, 1, "number")

	for _, p in ipairs(self.vertices) do
		p.airfriction =  math.clamp(1 - friction, 0, 1)
	end
end

-- This method sets a custom gravitational force just for the RigidBody.
function RigidBody:SetGravity(force: Vector2)
	throwTypeError("force", force, 1, "Vector2")

	for _, p in ipairs(self.vertices) do
		p.gravity = force
	end
end

-- Sets a new mass for the RigidBody
function RigidBody:SetMass(mass: number)
	if self.mass ~= mass and mass >= 1 then 
		self.mass = mass
	end
end

-- Returns true if the RigidBody lies within the boundaries of the canvas, else false.
function RigidBody:IsInBounds() : boolean
	local canvas = self.engine.canvas
	if not canvas then return false end
	
	-- Check if all vertices lie within the canvas.
	for _, v in ipairs(self.vertices) do 
		local pos = v.pos 
	
		if not ((pos.X >= canvas.topLeft.X and pos.X <= canvas.topLeft.X + canvas.size.X) and (pos.Y >= canvas.topLeft.Y and pos.Y <= canvas.topLeft.Y + canvas.size.Y)) then 
			return false
		end
	end
	
	return true
end

-- Returns the average of all the velocities of the RigidBody's points
function RigidBody:AverageVelocity() : Vector2
	local sum = Vector2.new(0, 0)
	
	for _, v in ipairs(self.vertices) do
		sum += v:Velocity()
	end
	
	-- Return average
	return sum/#self.vertices
end

-- STATE MANAGEMENT
-- Used to initialize or update states of a RigidBody
function RigidBody:SetState(state: string, value: any)
	throwTypeError("state", state, 1, "string")
	if self.States[state] == value then return end

	self.States[state] = value
end

-- Used to fetch an already existing state
function RigidBody:GetState(state: string) : any
	throwTypeError("state", state, 1, "string")
	return self.States[state]
end

-- Used to fetch the center position of the RigidBody
function RigidBody:GetCenter()
	return self.center
end

-- Used to ignore/filter any collisions with the other RigidBody.
function RigidBody:FilterCollisionsWith(otherBody)	
	if not otherBody.id or not typeof(otherBody.id) == "string" or not otherBody.filtered then 
		throwException("error", "INVALID_RIGIDBODY")
	end
	
	if otherBody.id == self.id then throwException("error", "SAME_ID") end

	-- Insert the ids into their respective places
	if not table.find(self.filtered, otherBody.id) then 
		table.insert(self.filtered, otherBody.id)
		table.insert(otherBody.filtered, self.id)
	end
end

-- Used to unfilter collisions with the other RigidBody. 
-- The two bodies will now collide with each other.
function RigidBody:UnfilterCollisionsWith(otherBody)
	if not otherBody.id or not typeof(otherBody.id) == "string" or not otherBody.filtered then 
		throwException("error", "INVALID_RIGIDBODY")
	end

	if otherBody.id == self.id then throwException("error", "SAME_ID") end
	
	local i1 = table.find(self.filtered, otherBody.id)
	local i2 = table.find(otherBody.filtered, self.id)
	
	-- Remove the ids from their respective places
	if i1 and i2 then 
		table.remove(self.filtered, i1)
		table.remove(otherBody.filtered, i2)
	end
end

-- Returns all filtered RigidBodies.
function RigidBody:GetFilteredRigidBodies()
	return self.filtered
end

-- Returns an array of all RigidBodies that are in collision with the current
function RigidBody:GetTouchingRigidBodies()
	return self.Collisions.Other
end

-- Determines the max force that can be aoplied to the RigidBody.
function RigidBody:SetMaxForce(maxForce: number)
	throwTypeError("maxForce", maxForce, 1, "number")
	for _, p in ipairs(self.vertices) do 
		p:SetMaxForce(maxForce)
	end
end

return RigidBody
