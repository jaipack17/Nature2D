--[[
	RigidBodies are formed by Constraints, Points and UI Elements.
]]--

local Point = require(script.Parent.Point)
local Constraint = require(script.Parent.Constraint)
local Globals = require(script.Parent.Parent.constants.Globals)
local Signal = require(script.Parent.Parent.utils.Signal)
local Types = require(script.Parent.Parent.Types)
local throwTypeError = require(script.Parent.Parent.debug.TypeErrors)

local HttpService = game:GetService("HttpService")

local RigidBody = {}
RigidBody.__index = RigidBody

--[[
	[PRIVATE]

	This method is used to fetch the positions of the 4 corners of  UI element.

	[METHOD]: GetCorners()
	[PARAMETERS]: frame: GuiObject, engine: Engine 
	[RETURNS]: corners: table
]]--

local function GetCorners(frame: GuiObject, engine)
	local pos, size = frame.AbsolutePosition, frame.AbsoluteSize
	local rotation = math.rad(frame.Rotation)
	local center = pos + size/2
	local temp = math.sqrt((size.X/2)^2+(size.Y/2)^2)

	local offset = (engine.path and engine.path.IgnoreGuiInset) and Globals.offset or Vector2.new(0, 0)

	return {
		center - temp*Vector2.new(math.cos(rotation + math.atan2(size.Y, size.X)), math.sin(rotation + math.atan2(size.Y, size.X))) + offset, -- topleft
		center + temp*Vector2.new(math.cos(rotation - math.atan2(size.Y, size.X)), math.sin(rotation - math.atan2(size.Y, size.X))) + offset, -- topright
		center - temp*Vector2.new(math.cos(rotation - math.atan2(size.Y, size.X)), math.sin(rotation - math.atan2(size.Y, size.X))) + offset, -- bottomleft
		center + temp*Vector2.new(math.cos(rotation + math.atan2(size.Y, size.X)), math.sin(rotation + math.atan2(size.Y, size.X))) + offset, -- bottomright
	}
end

--[[
	This method is used to calculate the depth/penetration of a collision

	[METHOD]: CalculatePenetration()
	[PARAMETERS]: minA: number, maxA: number, minB: number, maxB: number
	[RETURNS]: depth: number
]]--

local function CalculatePenetration(minA: number, maxA: number, minB: number, maxB: number) : number
	if minA < minB then 
		return minB - maxA 
	else 
		return minA - maxB 
	end
end

--[[
	This method is used to calculate the center position of a UI element

	[METHOD]: CalculateCenter()
	[PARAMETERS]: vertices: table
	[RETURNS]: center: Vector2
]]--

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

--[[
	This method is used to update the positions of each point of a rigidbody to the corners of a UI element.

	[METHOD]: UpdateVertices()
	[PARAMETERS]: frame: GuiObject, vertices: table, engine: Engine
	[RETURNS]: nil
]]--

local function UpdateVertices(frame: GuiObject, vertices, engine)
	local corners = GetCorners(frame, engine)
	for i, vertex in ipairs(vertices) do 
		vertex.oldPos = corners[i]
		vertex.pos = corners[i]
	end
end

--[[
	[PUBLIC]

	This method is used to initialize a new RigidBody.

	[METHOD]: RigidBody.new()
	[PARAMETERS]: frame: GuiObject, m: number, collidable: boolean, anchored: boolean, engine: Engine
	[RETURNS]: RigidBody
]]--

function RigidBody.new(frame: GuiObject, m: number, collidable: boolean, anchored: boolean, engine) 	
	local vertices = {}
	local edges = {}
	
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

	local function addPoint(pos)
		local newPoint = Point.new(pos, engine.canvas, engine, pointConfig)
		vertices[#vertices + 1] = newPoint

		return newPoint
	end

	local function addConstraint(p1, p2, support)
		constraintConfig.support = support

		local newConstraint = Constraint.new(p1, p2, engine.canvas, constraintConfig)
		edges[#edges + 1] = newConstraint

		return newConstraint
	end

	local corners = GetCorners(frame, engine)
	local topleft = addPoint(corners[1])
	local topright = addPoint(corners[2])
	local bottomleft = addPoint(corners[3])
	local bottomright = addPoint(corners[4])

	addConstraint(topleft, topright, false)
	addConstraint(topleft, bottomleft, false)
	addConstraint(topright, bottomright, false)
	addConstraint(bottomleft, bottomright, false)
	addConstraint(topleft, bottomright, true)
	addConstraint(topright, bottomleft, true)               

	local self = setmetatable({
		id = HttpService:GenerateGUID(false),
		vertices = vertices,
		edges = edges,
		frame = frame,
		anchored = anchored,
		mass = m,
		collidable = collidable,
		center = frame.AbsolutePosition + frame.AbsoluteSize/2,
		engine = engine,
		spawnedAt = os.time(),
		lifeSpan = nil,
		anchorRotation = anchored and frame.Rotation or nil,
		anchorPos = anchored and frame.AbsolutePosition or nil,
		Touched = nil,
		CanvasEdgeTouched = nil,
		Collisions = {			
			Body = false,
			CanvasEdge = false,
		},
		States = {}
	}, RigidBody)

	if engine.path and engine.path.IgnoreGuiInset then 
		self.anchorPos = self.anchorPos and self.anchorPos + Globals.offset or nil
		self.center += Globals.offset
	end

	self.Touched = Signal.new()
	self.CanvasEdgeTouched = Signal.new()

	for _, edge in ipairs(edges) do
		edge.point1.Parent = edge
		edge.point2.Parent = edge
		edge.Parent = self
	end

	return self
end

--[[
	This method projects the RigidBody on an axis. Used for collision detection.

	[METHOD]: RigidBody:CreateProjection()
	[PARAMETERS]: Axis: Vector2, Min: number, Max: number
	[RETURNS]: Min: number, Max: number
]]--

function RigidBody:CreateProjection(Axis: Vector2, Min: number, Max: number) : (number, number)
	local DotP = Axis.X * self.vertices[1].pos.x + Axis.Y * self.vertices[1].pos.y
	Min, Max = DotP, DotP

	for I = 2, #self.vertices, 1 do
		DotP = Axis.X * self.vertices[I].pos.x + Axis.Y * self.vertices[I].pos.y
		Min = math.min(DotP, Min)
		Max = math.max(DotP, Max)
	end

	return Min, Max
end

--[[
	This method detects collision between two RigidBodies.

	[METHOD]: RigidBody:DetectCollision()
	[PARAMETERS]: other: RigidBody
	[RETURNS]: { colliding: table, info: table }
]]--

function RigidBody:DetectCollision(other)
	if self.frame and other.frame then 
		self.center = CalculateCenter(self.vertices)

		local minDist = math.huge
		local collision: Types.Collision = {
			axis = nil,
			depth = nil,
			edge = nil,
			vertex = nil
		}

		for i = 1, #self.edges + #other.edges, 1 do
			local edge = i <= #self.edges and self.edges[i] or other.edges[i - #self.edges]

			if not edge.support then 
				local axis = Vector2.new(edge.point1.pos.Y - edge.point2.pos.Y, edge.point2.pos.X - edge.point1.pos.X).Unit

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
		local dot = collision.axis.X * centerDif.x + collision.axis.Y * centerDif.Y

		if dot < 0 then 
			collision.axis *= -1
		end	

		local minMag = math.huge 

		for i = 1, #self.vertices, 1 do
			local dif =  self.vertices[i].pos - other.center
			local dist = collision.axis.X * dif.X + collision.axis.Y * dif.Y

			if dist < minMag then
				minMag = dist
				collision.vertex = self.vertices[i]
			end
		end

		return { true, collision }
	end

	return { false, {} }
end

--[[
	This method is used to apply an external force on the rigid body.

	[METHOD]: RigidBody:ApplyForce()
	[PARAMETERS]: force: Vector2
	[RETURNS]: nil
]]--

function RigidBody:ApplyForce(force: Vector2)
	throwTypeError("force", force, 1, "Vector2")

	for _, v in ipairs(self.vertices) do 
		v:ApplyForce(force)
	end
end

--[[
	This method updates the positions of the RigidBody's points and constraints.

	[METHOD]: RigidBody:Update()
	[PARAMETERS]: dt: number
	[RETURNS]: nil
]]--

function RigidBody:Update(dt: number)
	self.center = CalculateCenter(self.vertices)

	for i = 1, #self.vertices + #self.edges do 
		local edge = i > #self.vertices

		if edge then 
			self.edges[(#self.vertices + #self.edges) + 1 - i]:Constrain()
		else 
			self.vertices[i]:Update(dt)
		end
	end
end

--[[
	This method updates the positions and appearance of the RigidBody on screen.

	[METHOD]: RigidBody:Render()
	[PARAMETERS]: none
	[RETURNS]: nil
]]--

function RigidBody:Render()
	if self.lifeSpan and os.time() - self.spawnedAt >= self.lifeSpan then 
		self:Destroy()
	end

	if self.anchored then 
		self:SetPosition(self.anchorPos)
		self:Rotate(self.anchorRotation)
	else 
		local center = self.center
		local offset = Vector2.new(.5, .5) - self.frame.AnchorPoint
		offset *= self.frame.AbsoluteSize
		center -= offset
		
		self.frame.Rotation = math.deg(math.atan2((self.vertices[2].pos - self.vertices[1].pos).y, (self.vertices[2].pos - self.vertices[1].pos).x))
		self.frame.Position = UDim2.new(0, center.x, 0, center.y)		
	end
end

--[[
	This method is used to destroy the RigidBody. The body's UI element is destroyed, its connections are disconnected and the body is removed from the engine.

	[METHOD]: RigidBody:Destroy()
	[PARAMETERS]: none
	[RETURNS]: nil
]]--

function RigidBody:Destroy()
	for i, body in ipairs(self.engine.bodies) do
		if self.id == body.id then
			self.Touched:Destroy()
			self.CanvasEdgeTouched:Destroy()
			self.Touched = nil 
			self.CanvasEdgeTouched = nil
			self.frame:Destroy()
			table.remove(self.engine.bodies, i)
		end
	end
end

--[[
	This method is used to rotate the RigidBody's UI element. After rotation the positions of its points and constraints are automatically updated.

	[METHOD]: RigidBody:Rotate()
	[PARAMETERS]: newRotation: number
	[RETURNS]: oldRotation: number, newRotation: number
]]--

function RigidBody:Rotate(newRotation: number)
	throwTypeError("newRotation", newRotation, 1, "number")

	if self.anchored and self.anchorRotation then 
		self.anchorRotation = newRotation
	end

	local oldRotation = self.frame.Rotation
	self.frame.Position = self.anchored and UDim2.new(0, self.anchorPos.x, 0, self.anchorPos.y) or UDim2.new(0, self.center.x, 0, self.center.y)
	self.frame.Rotation = newRotation
	UpdateVertices(self.frame, self.vertices, self.engine)

	return oldRotation, newRotation
end

--[[
	This method is used to set a new position of the RigidBody's UI element.
	
	[METHOD]: RigidBody:SetPosition()
	[PARAMETERS]: newPosition: Vector2
	[RETURNS]: oldPosition: UDim2, newPosition: UDim2
]]--

function RigidBody:SetPosition(newPosition: Vector2)
	throwTypeError("newPosition", newPosition, 1, "Vector2")

	if self.anchored and self.anchorPos then 
		self.anchorPos = newPosition
	end

	local oldPosition = self.frame.Position
	self.frame.Position = UDim2.new(0, newPosition.X, 0, newPosition.Y)
	UpdateVertices(self.frame, self.vertices, self.engine)

	return oldPosition, UDim2.new(0, newPosition.X, 0, newPosition.Y)
end

--[[
	This method is used to set a new size of the RigidBody's UI element. 
	
	[METHOD]: RigidBody:SetSize()
	[PARAMETERS]: newSize: Vector2
	[RETURNS]: oldSize: UDim2, newSize: UDim2
]]--

function RigidBody:SetSize(newSize: Vector2)
	throwTypeError("newSize", newSize, 1, "Vector2")

	local oldSize = self.frame.Size
	self.frame.Size = UDim2.new(0, newSize.X, 0, newSize.Y)
	UpdateVertices(self.frame, self.vertices, self.engine)

	return oldSize, UDim2.new(0, newSize.X, 0, newSize.Y)
end

--[[
	This method is used to anchor the RigidBody. Its position will no longer change.
	
	[METHOD]: RigidBody:Anchor()
	[PARAMETERS]: none
	[RETURNS]: nil
]]--

function RigidBody:Anchor()
	self.anchored = true
	self.anchorRotation = self.frame.Rotation
	self.anchorPos = self.center

	for _, vertex in ipairs(self.vertices) do
		if not vertex.selectable then vertex.snap = self.anchored end
	end
end

--[[
	This method is used to unachor and anchored RigidBody.
	
	[METHOD]: RigidBody:Unanchor()
	[PARAMETERS]: none
	[RETURNS]: nil
]]--

function RigidBody:Unanchor()
	self.anchored = false
	self.anchorRotation = nil
	self.anchorPos = nil

	for _, vertex in ipairs(self.vertices) do
		if not vertex.selectable then vertex.snap = self.anchored end
	end
end

--[[
	This method is used to determine whether the RigidBody will collide with other RigidBodies. 

	[METHOD]: RigidBody:CanCollide()
	[PARAMETERS]: collidable: boolean
	[RETURNS]: nil
]]--

function RigidBody:CanCollide(collidable: boolean)
	throwTypeError("collidable", collidable, 1, "boolean")
	self.collidable = collidable
end

--[[
	The RigidBody's UI Element can be fetched using this method.

	[METHOD]: RigidBody:GetFrame()
	[PARAMETERS]: none 
	[RETURNS]: GuiObject
]]--

function RigidBody:GetFrame() : GuiObject
	return self.frame
end

--[[
	The RigidBody's unique ID can be fetched using this method.

	[METHOD]: RigidBody:GetId()
	[PARAMETERS]: none 
	[RETURNS]: id: string
]]--

function RigidBody:GetId() : string
	return self.id
end

--[[
	The RigidBody's Points can be fetched using this method.


	[METHOD]: RigidBody:GetVertices()
	[PARAMETERS]: none 
	[RETURNS]: points: table
]]--

function RigidBody:GetVertices()
	return self.vertices
end

--[[
	The RigidBody's Constraints can be fetched using this method.


	[METHOD]: RigidBody:GetConstraints()
	[PARAMETERS]: none 
	[RETURNS]: constraints: table
]]--

function RigidBody:GetConstraints()
	return self.edges
end

--[[
	This method is used to set the RigidBody's life span. Life span is determined by 'seconds'. After this time in seconds has been passed after the RigidBody is created, the RigidBody is automatically destroyed and removed from the engine.

	[METHOD]: RigidBody:SetLifeSpan()
	[PARAMETERS]: seconds: number 
	[RETURNS]: nil
]]--

function RigidBody:SetLifeSpan(seconds: number)
	throwTypeError("seconds", seconds, 1, "number")
	self.lifeSpan = seconds
end

--[[
	This method determines if the RigidBody stays inside the engine's canvas at all times. 

	[METHOD]: RigidBody:KeepInCanvas()
	[PARAMETERS]: keepInCanvas: boolean
	[RETURNS]: nil
]]--

function RigidBody:KeepInCanvas(keepInCanvas: boolean)
	throwTypeError("keepInCanvas", keepInCanvas, 1, "boolean")

	for _, p in ipairs(self.vertices) do 
		p.keepInCanvas = keepInCanvas
	end
end

--[[
	This method sets a custom frictional damp value just for the RigidBody.

	[METHOD]: RigidBody:SetFriction()
	[PARAMETERS]: friction: number
	[RETURNS]: nil
]]--

function RigidBody:SetFriction(friction: number)
	throwTypeError("friction", friction, 1, "number")

	for _, p in ipairs(self.vertices) do
		p.friction =  math.clamp(1 - friction, 0, 1)
	end
end

--[[
	This method sets a custom air frictional damp value just for the RigidBody.

	[METHOD]: RigidBody:SetAirFriction()
	[PARAMETERS]: friction: number
	[RETURNS]: nil
]]--

function RigidBody:SetAirFriction(friction: number)
	throwTypeError("friction", friction, 1, "number")

	for _, p in ipairs(self.vertices) do
		p.airfriction =  math.clamp(1 - friction, 0, 1)
	end
end

--[[
	This method sets a custom gravitational force just for the RigidBody.

	[METHOD]: RigidBody:SetFriction()
	[PARAMETERS]: force: Vector2
	[RETURNS]: nil
]]--

function RigidBody:SetGravity(force: Vector2)
	throwTypeError("force", force, 1, "Vector2")

	for _, p in ipairs(self.vertices) do
		p.gravity = force
	end
end

--[[
	Returns true if the RigidBody lies within the boundaries of the canvas, else false.

	[METHOD]: RigidBody:IsInBounds()
	[PARAMETERS]: none
	[RETURNS]: isInBounds: boolean
]]--

function RigidBody:IsInBounds() : boolean
	local canvas = self.engine.canvas
	if not canvas then return false end
	
	for _, v in ipairs(self.vertices) do 
		local pos = v.pos 
		
		if not ((pos.X >= canvas.topLeft.X and pos.X <= canvas.topLeft.X + canvas.size.X) and (pos.Y >= canvas.topLeft.Y and pos.Y <= canvas.topLeft.Y + canvas.size.Y)) then 
			return false
		end
	end
	
	return true
end

--[[
	Returns the average of all the velocities of the RigidBody's points

	[METHOD]: RigidBody:AverageVelocity()
	[PARAMETERS]: none
	[RETURNS]: velocity: Vector2
]]--

function RigidBody:AverageVelocity() : Vector2
	local sum = Vector2.new(0, 0)
	
	for _, v in ipairs(self.vertices) do
		sum += v:Velocity()
	end
	
	return sum/#self.vertices
end

-- STATE MANAGEMENT

--[[
	Used to initialize or update states of a RigidBody

	[METHOD]: RigidBody:SetState()
	[PARAMETERS]: state: string, value: any
	[RETURNS]: nil
]]--

function RigidBody:SetState(state: string, value: any)
	throwTypeError("state", state, 1, "string")
	if self.States[state] == value then return end

	self.States[state] = value
end

--[[
	Used to fetch a state

	[METHOD]: RigidBody:GetState()
	[PARAMETERS]: state: string
	[RETURNS]: value: any
]]--

function RigidBody:GetState(state: string) : any
	throwTypeError("state", state, 1, "string")
	return self.States[state]
end

--[[
	Used to fetch the center position of the RigidBody

	[METHOD]: RigidBody:SetState()
	[PARAMETERS]: none
	[RETURNS]: center: Vector2
]]--

function RigidBody:GetCenter()
	return self.center
end

return RigidBody
