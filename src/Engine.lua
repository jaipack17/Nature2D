--[[
	The Engine or the core of the library handles all the RigidBodies, constraints and points. 
	It's responsible for the simulation of these elements and handling all tasks related to the library.
]]--

local RigidBody = require(script.Parent.physics.RigidBody)
local Point = require(script.Parent.physics.Point)
local Constraint = require(script.Parent.physics.Constraint)
local Globals = require(script.Parent.constants.Globals)
local Signal = require(script.Parent.utils.Signal)
local Quadtree = require(script.Parent.utils.Quadtree)
local Types = require(script.Parent.Types)
local throwException = require(script.Parent.debug.Exceptions)
local throwTypeError = require(script.Parent.debug.TypeErrors)

local RunService = game:GetService("RunService")

local Engine = {}
Engine.__index = Engine

--[[
	[PRIVATE]

	Collision Response: This method is responsible for separating two rigidbodies if they collide with each other.
]]--

local function CollisionResponse(body: Types.RigidBody, other: Types.RigidBody, isColliding: boolean, Collision: Types.Collision, dt: number)
	if not isColliding then return end

	body.Touched:Fire(other.id)

	local penetration: Vector2 = Collision.axis * Collision.depth
	local p1: Types.Point = Collision.edge.point1
	local p2: Types.Point = Collision.edge.point2

	local t
	if math.abs(p1.pos.X - p2.pos.X) > math.abs(p1.pos.Y - p2.pos.Y) then
		t = (Collision.vertex.pos.X - penetration.X - p1.pos.X)/(p2.pos.X - p1.pos.X)
	else 
		t = (Collision.vertex.pos.Y - penetration.Y - p1.pos.Y)/(p2.pos.Y - p1.pos.Y)
	end

	local factor: number = 1/(t^2 + (1 - t)^2)
	
	if not Collision.edge.Parent.anchored then 
		p1.pos -= penetration * ((1 - t) * factor/2)
		p2.pos -= penetration * (t * factor/2)
	end

	if not Collision.vertex.Parent.Parent.anchored then 	
		Collision.vertex.pos += penetration/2
	end	
end

--[[
	[PUBLIC]

	This method is used to initialize basic configurations of the engine and allocate memory for future tasks.

	[METHOD]: Engine.init()
	[PARAMETERS]: screengui: ScreenGui 
	[RETURNS]: Engine
]]--

function Engine.init(screengui: Instance)
	if not typeof(screengui) == "Instance" or not screengui:IsA("Instance") then 
		error("Invalid Argument #1. 'screengui' must be a ScreenGui.", 2) 
	end

	local self = setmetatable({
		bodies = {},
		constraints = {},
		points = {},
		connection = nil,
		gravity = Globals.engineInit.gravity,
		friction = Globals.engineInit.friction,
		airfriction = Globals.engineInit.airfriction,
		bounce = Globals.engineInit.bounce,
		timeSteps = Globals.engineInit.timeSteps,
		path = screengui,
		speed = Globals.speed,
		quadtrees = false,
		independent = true,
		canvas = {
			frame = nil,
			topLeft = Globals.engineInit.canvas.topLeft,
			size = Globals.engineInit.canvas.size
		},
		Started = Signal.new(),
		Stopped = Signal.new()
	}, Engine)

	return self
end

--[[
	This method is used to start simulating rigid bodies and constraints.
	
	[METHOD]: Engine:Start()
	[PARAMETERS]: none 
	[RETURNS]: nil
]]--

function Engine:Start()
	if not self.canvas then throwException("error", "NO_CANVAS_FOUND") end
	if #self.bodies == 0 then throwException("warn", "NO_RIGIDBODIES_FOUND") end

	self.Started:Fire()

	local connection;
	connection = RunService.RenderStepped:Connect(function(dt)
		local tree;

		if self.quadtrees then 
			tree = Quadtree.new(self.canvas.topLeft, self.canvas.size, 4)

			for _, body in ipairs(self.bodies) do 
				tree:Insert(body)
			end			
		end

		for _, body in ipairs(self.bodies) do 
			body:Update(dt)

			local filtered = self.bodies

			if self.quadtrees then 
				local abs =  body.frame.AbsoluteSize
				local side = abs.X > abs.Y and abs.X or abs.Y

				local range = {
					position = body.center - Vector2.new(side * 1.5, side * 1.5),
					size = Vector2.new(side * 3, side * 3)
				}

				filtered = tree:Search(range, {})				
			end

			for _, other in ipairs(filtered) do 
				if body.id ~= other.id and (body.collidable and other.collidable) and not table.find(body.filtered, other.id) then
					local result = body:DetectCollision(other)
					local isColliding = result[1]
					local Collision = result[2]
					
					if isColliding then 
						body.Collisions.Body = true
						other.Collisions.Body = true
					else 
						body.Collisions.Body = false
						other.Collisions.Body = false
					end

					CollisionResponse(body, other, isColliding, Collision, dt)
				end
			end

			for _, vertex in ipairs(body.vertices) do
				vertex:Render()
			end

			body:Render()
		end

		if #self.constraints > 0 then 
			for _, constraint in ipairs(self.constraints) do 
				constraint:Constrain()
				constraint:Render()
			end			
		end

		if #self.points > 0 then 
			for _, point in ipairs(self.points) do 
				point:Update(dt)
				point:Render()
			end
		end
	end)

	self.connection = connection
end

--[[
	This method is used to stop simulating rigid bodies and constraints.
	
	[METHOD]: Engine:Stop()
	[PARAMETERS]: none 
	[RETURNS]: nil
]]--

function Engine:Stop()
	if self.connection then 
		self.Stopped:Fire()
		self.connection:Disconnect()
		self.connection = nil
	end
end

--[[
	This method is used to turn a normal UI element into a physical entity.

	[METHOD]: Engine:CreateRigidBody()
	[PARAMETERS]: frame: GuiObject, collidable: boolean, anchored: boolean
	[RETURNS]: RigidBody
]]--

function Engine:CreateRigidBody(frame: GuiObject, collidable: boolean, anchored: boolean)
	if not typeof(frame) == "Instance" or not frame:IsA("GuiObject") then 
		error("Invalid Argument #1. 'frame' must be a GuiObject", 2)
	end

	throwTypeError("collidable", collidable, 2, "boolean")
	throwTypeError("anchored", anchored, 3, "boolean")

	local newBody = RigidBody.new(frame, Globals.universalMass, collidable, anchored, self)
	table.insert(self.bodies, newBody)

	return newBody
end

--[[
	This method is used to create a custom point in the Engine. It can be used to create custom constraints.

	[METHOD]: Engine:CreatePoint()
	[PARAMETERS]: position: Vector2, visible: boolean
	[RETURNS]: Point
]]--

function Engine:CreatePoint(position: Vector2, visible: boolean)
	throwTypeError("position", position, 1, "Vector2")
	throwTypeError("visible", visible, 2, "boolean")

	local newPoint = Point.new(position, self.canvas, self, {
		snap = false, 
		selectable = false, 
		render = visible,
		keepInCanvas = true
	})
	table.insert(self.points, newPoint)

	return newPoint
end

--[[
	This method is used to create non collidable constraints that hold together two points.

	[METHOD]: Engine:CreateConstraint()
	[PARAMETERS]: point1: Point, point2: Point, visible: boolean, thickness: number
	[RETURNS]: Constraint
]]--

function Engine:CreateConstraint(Type: string, point1: Types.Point, point2: Types.Point, visible: boolean, thickness: number, restLength: number?)
	throwTypeError("type", Type, 1, "string")
	throwTypeError("visible", visible, 3, "boolean")
	throwTypeError("thickness", thickness, 4, "number")

	if not table.find(Globals.constraint.types, string.lower(Type)) then 
		throwException("error", "INVALID_CONSTRAINT_TYPE")
	end
	
	if restLength then 
		throwTypeError("restLength", restLength, 5, "number")
		if restLength <= 0 then 
			throwException("error", "INVALID_CONSTRAINT_LENGTH") 
		end
	end
	if thickness and thickness <= 0 then throwException("error", "INVALID_CONSTRAINT_THICKNESS") end

	local dist = (point2.pos - point1.pos).Magnitude
		
	local newConstraint = Constraint.new(point1, point2, self.canvas, {
		restLength = restLength or dist, 
		render = visible, 
		thickness = thickness,
		support = true,
		TYPE = string.upper(Type)
	}, self)

	table.insert(self.constraints, newConstraint)

	return newConstraint
end

--[[
	This method is used to fetch all RigidBodies that have been created. Ones that have been destroyed, won't be fetched.

	[METHOD]: Engine:GetBodies()
	[PARAMETERS]: none
	[RETURNS]: bodies: table
]]--

function Engine:GetBodies()
	return self.bodies
end

--[[
	This method is used to fetch all Constraints that have been created. Ones that have been destroyed, won't be fetched.

	[METHOD]: Engine:GetConstraints()
	[PARAMETERS]: none
	[RETURNS]: constraints: table
]]--

function Engine:GetConstraints()
	return self.constraints
end

--[[
	This method is used to fetch all Points that have been created. 

	[METHOD]: Engine:GetPoints()
	[PARAMETERS]: none
	[RETURNS]: points: table
]]--

function Engine:GetPoints()
	return self.points
end

--[[
	This function is used to initialize boundaries to which all bodies and constraints obey. An object cannot go past this boundary.

	[METHOD]: Engine:CreateCanvas()
	[PARAMETERS]: topLeft: Vector2, size: Vector2, frame: Frame | nil
	[RETURNS]: nil
]]--


function Engine:CreateCanvas(topLeft: Vector2, size: Vector2, frame: Frame)
	throwTypeError("topLeft", topLeft, 1, "Vector2")
	throwTypeError("size", size, 2, "Vector2")

	self.canvas.absolute = topLeft
	self.canvas.size = size

	if frame and frame:IsA("Frame") then 
		self.canvas.frame = frame
	end
end

--[[
	This method is used to determine the simulation speed of the engine. By default the simulation speed is set to 55.
	
	[METHOD]: Engine:SetSimulationSpeed()
	[PARAMETERS]: speed: number
	[RETURNS]: nil
]]--

function Engine:SetSimulationSpeed(speed: number)
	throwTypeError("speed", speed, 1, "number")
	self.speed = speed
end

--[[
	This method is used to configure universal physical properties possessed by all rigid bodies and constraints. 
	
	[METHOD]: Engine:SetPhysicalProperty()
	[PARAMETERS]: property: string, value: Vector2 | number
	[RETURNS]: nil
]]--

function Engine:SetPhysicalProperty(property: string, value: Vector2 | number)
	throwTypeError("property", property, 1, "string")

	local properties = Globals.properties
	
	local function Update(object)
		if string.lower(property) == "collisionmultiplier" then 
			throwTypeError("value", value, 2, "number")
			object.bounce = value
		elseif string.lower(property) == "gravity" then 
			throwTypeError("value", value, 2, "Vector2")
			object.gravity = value
		elseif string.lower(property) == "friction" then 					
			throwTypeError("value", value, 2, "number")
			object.friction = math.clamp(1 - value, 0, 1)
		elseif string.lower(property) == "airfriction" then 
			throwTypeError("value", value, 2, "number")
			object.airfriction = math.clamp(1 - value, 0, 1)
		end
	end

	if table.find(properties, string.lower(property)) then 
		if #self.bodies < 1 then 
			Update(self)
		else 
			Update(self)
			for _, b in ipairs(self.bodies) do 
				for _, v in ipairs(b:GetVertices()) do 
					Update(v)
				end
			end
		end
	else
		throwException("error", "PROPERTY_NOT_FOUND")
	end
end

--[[
	This method is used to fetch an individual rigid body from its ID.

	[METHOD]: Engine:GetBodyById()
	[PARAMETERS]: id: string
	[RETURNS]: RigidBody
]]--

function Engine:GetBodyById(id: string)
	throwTypeError("id", id, 1, "string")

	for _, b in ipairs(self.bodies) do 
		if b.id == id then 
			return b
		end
	end

	return
end

--[[
	This method is used to fetch an individual constraint body from its ID. 
	
	[METHOD]: Engine:GetConstraintById()
	[PARAMETERS]: id: string
	[RETURNS]: Constraint
]]--

function Engine:GetConstraintById(id: string)
	throwTypeError("id", id, 1, "string")

	for _, c in ipairs(self.constraints) do 
		if c.id == id then 
			return c
		end
	end

	return 
end

--[[
	Returns current canvas the engine adheres to.
	
	[METHOD]: Engine:GetCurrentCanvas()
	[PARAMETERS]: none
	[RETURNS]: { frame: Frame, topLeft: Vector2, size: Vector2 }
]]--

function Engine:GetCurrentCanvas() : Types.Canvas
	return self.canvas
end

--[[
	Determines if Quadtrees will be used in collision detection
	
	[METHOD]: Engine:UseQuadtrees()
	[PARAMETERS]: use: boolean
	[RETURNS]: nil
]]--

function Engine:UseQuadtrees(use: boolean)
	throwTypeError("useQuadtrees", use, 1, "boolean")
	self.quadtrees = use
end

--[[
	Determines if Frame rate does not affect the simulation speed. By default set to true.
	
	[METHOD]: Engine:FrameRateIndependent()
	[PARAMETERS]: independent: boolean
	[RETURNS]: nil
]]--

function Engine:FrameRateIndependent(independent: boolean)
	throwTypeError("independent", independent, 1, "boolean")
	self.independent = independent
end

return Engine
