-- The Engine or the core of the library handles all the RigidBodies, constraints and points.
-- It's responsible for the simulation of these elements and handling all tasks related to the library.

-- Services and utilities
local RigidBody = require(script.Parent.Physics.RigidBody)
local Point = require(script.Parent.Physics.Point)
local Constraint = require(script.Parent.Physics.Constraint)
local PhysicsRunner = require(script.Parent.Physics.Runner)
local Globals = require(script.Parent.Constants.Globals)
local Signal = require(script.Parent.Utilities.Signal)
local Quadtree = require(script.Parent.Utilities.Quadtree)
local Janitor = require(script.Parent.Utilities.Janitor)
local Types = require(script.Parent.Types)
local throwException = require(script.Parent.Debugging.Exceptions)
local throwTypeError = require(script.Parent.Debugging.TypeErrors)
local RunService = game:GetService("RunService")

local function SearchTable(t: { any }, a: any,  lambda: (a: any, b: any) -> boolean) : any
	for _, v in ipairs(t) do
		if lambda(a, v) then
			return v
		end
	end

	return nil
end

local Engine = {}
Engine.__index = Engine

-- This method is used to initialize basic configurations of the engine and allocate memory for future tasks.
function Engine.init(screengui: Instance)
	if not typeof(screengui) == "Instance" or not screengui:IsA("Instance") then
		error("Invalid Argument #1. 'screengui' must be a ScreenGui.", 2)
	end

	local self = setmetatable({
		bodies = {},
		constraints = {},
		points = {},
		connection = nil,
		_janitor = nil,
		gravity = Globals.engineInit.gravity,
		friction = Globals.engineInit.friction,
		airfriction = Globals.engineInit.airfriction,
		bounce = Globals.engineInit.bounce,
		timeSteps = Globals.engineInit.timeSteps,
		mass = Globals.universalMass,
		path = screengui,
		speed = Globals.speed,
		quadtrees = false,
		independent = true,
		canvas = {
			frame = nil,
			topLeft = Globals.engineInit.canvas.topLeft,
			size = Globals.engineInit.canvas.size
		},
		iterations = {
			constraint = 1,
			collision = 1,
		},
		Started = Signal.new(),
		Stopped = Signal.new(),
		ObjectAdded = Signal.new(),
		ObjectRemoved = Signal.new(),
		Updated = Signal.new(),
	}, Engine)

	local janitor = Janitor.new()
	janitor:Add(self.Started, "Destroy")
	janitor:Add(self.Stopped, "Destroy")
	janitor:Add(self.ObjectAdded, "Destroy")
	janitor:Add(self.ObjectRemoved, "Destroy")
	janitor:Add(self.Updated, "Destroy")

	self._janitor = janitor

	return self
end

-- This method is used to start simulating rigid bodies and constraints.
function Engine:Start()
	if not self.canvas then throwException("error", "NO_CANVAS_FOUND") end
	if #self.bodies == 0 then throwException("warn", "NO_RIGIDBODIES_FOUND") end
	if self.connection then throwException("warn", "ALREADY_STARTED") return end

	-- Fire Engine.Started event
	self.Started:Fire()

	local fixedDeltaTime = 1/60
	local epsilon = 1/1000
	local accumulator = 0
	--local framesRenderedBeforeStep = 0

	local connection;
	connection = RunService.RenderStepped:Connect(function(deltaTime)
		accumulator += deltaTime

		while accumulator > 0 do
			accumulator -= fixedDeltaTime
			PhysicsRunner.Update(self, deltaTime)
			PhysicsRunner.Render(self)
		end

		if accumulator >= -epsilon then
			accumulator = 0
		end
	end)

	self.connection = connection
	self._janitor:Add(self.connection, "Disconnect", "MainConnection")
end

-- This method is used to stop simulating rigid bodies and constraints.
function Engine:Stop()
	-- Fire Engine.Stopped event
	-- Disconnect all connections
	if self.connection then
		self.Stopped:Fire()
		self._janitor:Remove("MainConnection")
		self.connection = nil
	end
end

-- This method is used to create RigidBodies, Constraints and Points
function Engine:Create(object: string, properties: Types.Properties)
	-- Validate types of the object and property table
	throwTypeError("object", object, 1, "string")
	throwTypeError("properties", properties, 2, "table")

	-- Validate object
	if object ~= "Constraint" and object ~= "Point" and object ~= "RigidBody" then
		throwException("error", "INVALID_OBJECT")
	end

	-- Validate property table
	for prop, value in pairs(properties) do
		if not table.find(Globals.VALID_OBJECT_PROPS, prop) then
			throwException("error", "INVALID_PROPERTY", string.format("%q is not a valid property!", prop))
			return
		end

		if not table.find(Globals[string.lower(object)].props, prop) then
			throwException("error", "INVALID_PROPERTY", string.format("%q is not a valid property for a %s!", prop, object))
			return
		end

		if Globals.OBJECT_PROPS_TYPES[prop] and typeof(value) ~= Globals.OBJECT_PROPS_TYPES[prop] then
			error(
				string.format(
					"[Nature2D]: Invalid Property type for %q. Expected %q got %q.",
					prop,
					Globals.OBJECT_PROPS_TYPES[prop],
					typeof(value)
				),
				2
			)
		end
	end

	-- Check if must-have properties exist in the property table
	for _, prop in ipairs(Globals[string.lower(object)].must_have) do
		if not properties[prop] then
			local throw = true

			if prop == "Object" and properties.Structure then
				throw = false
			end

			if throw then
				throwException("error", "MUST_HAVE_PROPERTY", string.format("You must specify the %q property for a %s!", prop, object))
				return
			end
		end
	end

	local newObject

	-- Create the Point object
	if object == "Point" then
		local newPoint = Point.new(properties.Position or Vector2.new(), self.canvas, self, {
			snap = properties.Snap,
			selectable = false,
			render = properties.Visible,
			keepInCanvas = properties.KeepInCanvas or true
		}, nil)

		-- Apply properties
		if properties.Radius then newPoint:SetRadius(properties.Radius)	end
		if properties.Color then newPoint:Stroke(properties.Color) end

		table.insert(self.points, newPoint)
		newObject = newPoint
		-- Create the constraint object
	elseif object == "Constraint" then
		if not table.find(Globals.constraint.types, string.lower(properties.Type or "")) then
			throwException("error", "INVALID_CONSTRAINT_TYPE")
		end

		-- Validate restlength and thickness of the constraint
		if properties.RestLength and properties.RestLength <= 0 then
			throwException("error", "INVALID_CONSTRAINT_LENGTH")
		end

		if properties.Thickness and properties.Thickness <= 0 then
			throwException("error", "INVALID_CONSTRAINT_THICKNESS")
		end

		if properties.Point1 and properties.Point2 and properties.Type then
			-- Calculate distance
			local dist = (properties.Point1.pos - properties.Point2.pos).Magnitude

			local newConstraint = Constraint.new(properties.Point1, properties.Point2, self.canvas, {
				restLength = properties.RestLength or dist,
				render = properties.Visible,
				thickness = properties.Thickness,
				support = false,
				TYPE = string.upper(properties.Type)
			}, self)

			-- Apply properties
			if properties.SpringConstant then newConstraint:SetSpringConstant(properties.SpringConstant) end
			if properties.Color then newConstraint:Stroke(properties.Color) end

			table.insert(self.constraints, newConstraint)
			newObject = newConstraint
		end
		-- Create the RigidBody object
	elseif object == "RigidBody" then
		-- Validate custom RigidBody structure

		if properties.Object and not properties.Object:IsA("GuiObject") and not properties.Structure then
			error("'Object' must be a GuiObject", 2)
		end

		local obj = nil
		if not properties.Structure then
			obj = properties.Object
		end

		local custom: Types.Custom = {
			Vertices = {},
			Edges = {}
		}

		if properties.Structure then
			if not self.canvas.frame then
				throwException("error", "CANVAS_FRAME_NOT_FOUND")
			end

			for _, c in ipairs(properties.Structure) do
				local a = c[1]
				local b = c[2]
				local support = c[3]

				if typeof(a) ~= "Vector2" or typeof(b) ~= "Vector2" then
					error("[Nature2D]: Invalid point positions for custom RigidBody structure.", 2)
				end

				if support and typeof(support) ~= "boolean" then error("[Nature2D]: 'support' must be a boolean or nil") end
				if a == b then error("[Nature2D]: A constraint cannot have the same points.", 2) end

				local PointA = SearchTable(custom.Vertices, a, function(i, v) return i == v.pos end)
				local PointB = SearchTable(custom.Vertices, b, function(i, v) return i == v.pos end)

				if not PointA then
					PointA = Point.new(a, self.canvas, self, {
						snap = properties.Anchored,
						selectable = false,
						render = false,
						keepInCanvas = properties.KeepInCanvas or true
					})
					table.insert(custom.Vertices, PointA)
				end

				if not PointB then
					PointB = Point.new(b, self.canvas, self, {
						snap = properties.Anchored,
						selectable = false,
						render = false,
						keepInCanvas = properties.KeepInCanvas or true
					})
					table.insert(custom.Vertices, PointB)
				end

				local edge = Constraint.new(PointA, PointB, self.canvas, {
					render = support and false or true,
					thickness = 2,
					support = support,
					TYPE = "ROD"
				}, self)

				table.insert(custom.Edges, edge)
			end
		end

		local newBody = RigidBody.new(
			obj,
			properties.Mass or self.mass,
			properties.Collidable,
			properties.Anchored,
			self,
			properties.Structure and custom or nil,
			properties.Structure
		)

		--Apply properties
		if properties.LifeSpan then newBody:SetLifeSpan(properties.LifeSpan) end
		if typeof(properties.KeepInCanvas) == "boolean" then newBody:KeepInCanvas(properties.KeepInCanvas) end
		if properties.Gravity then newBody:SetGravity(properties.Gravity) end
		if properties.Friction then newBody:SetFriction(properties.Friction) end
		if properties.AirFriction then newBody:SetAirFriction(properties.AirFriction) end
		if typeof(properties.CanRotate) == "boolean" and not properties.Structure then newBody:CanRotate(properties.CanRotate) end

		table.insert(self.bodies, newBody)
		newObject = newBody
	end

	self._janitor:Add(newObject, "Destroy")

	self.ObjectAdded:Fire(newObject)
	return newObject
end

-- This method is used to fetch all RigidBodies that have been created.
-- Ones that have been destroyed, won't be fetched.
function Engine:GetBodies()
	return self.bodies
end

-- This method is used to fetch all Constraints that have been created.
-- Ones that have been destroyed, won't be fetched.
function Engine:GetConstraints()
	return self.constraints
end

-- This method is used to fetch all Points that have been created.
function Engine:GetPoints()
	return self.points
end

-- This function is used to initialize boundaries to which all bodies and constraints obey.
-- An object cannot go past this boundary.
function Engine:CreateCanvas(topLeft: Vector2, size: Vector2, frame: Frame)
	throwTypeError("topLeft", topLeft, 1, "Vector2")
	throwTypeError("size", size, 2, "Vector2")

	self.canvas.topLeft = topLeft
	self.canvas.size = size

	if frame and frame:IsA("Frame") then
		self.canvas.frame = frame
	end
end

-- This method is used to determine the simulation speed of the engine.
-- By default the simulation speed is set to 55.
function Engine:SetSimulationSpeed(speed: number)
	throwTypeError("speed", speed, 1, "number")
	self.speed = speed
end

-- This method is used to configure universal physical properties possessed by all rigid bodies and constraints.
function Engine:SetPhysicalProperty(property: string, value: Vector2 | number)
	throwTypeError("property", property, 1, "string")

	local properties = Globals.properties

	-- Update properties of the Engine
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
		elseif string.lower(property) == "universalmass" then
			throwTypeError("value", value, 2, "number")
			object.mass = math.max(0, value)
		end
	end

	-- Validate and update properties
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

-- This method is used to fetch an individual rigid body from its ID.
function Engine:GetBodyById(id: string)
	throwTypeError("id", id, 1, "string")

	for _, b in ipairs(self.bodies) do
		if b.id == id then
			return b
		end
	end

	return
end

-- This method is used to fetch an individual constraint body from its ID.
function Engine:GetConstraintById(id: string)
	throwTypeError("id", id, 1, "string")

	for _, c in ipairs(self.constraints) do
		if c.id == id then
			return c
		end
	end

	return
end

function Engine:GetDebugInfo() : Types.DebugInfo
	return {
		Objects = {
			RigidBodies = #self.bodies,
			Constraints = #self.constraints,
			Points = #self.points
		},
		Running = not not (self.connection),
		Physics = {
			Gravity = self.gravity,
			Friction = 1 - self.friction,
			AirFriction = 1 - self.airfriction,
			CollisionMultiplier = self.bounce,
			TimeSteps = self.timeSteps,
			SimulationSpeed = self.speed,
			UsingQuadtrees = self.quadtrees,
			FramerateIndependent = self.independent
		},
		Path = self.path,
		Canvas = {
			Frame = self.canvas.frame,
			TopLeft = self.canvas.topLeft,
			Size = self.canvas.size
		}
	}
end

-- Determines if Quadtrees will be used in collision deteWction.
-- By default this is set to false
function Engine:UseQuadtrees(use: boolean)
	throwTypeError("useQuadtrees", use, 1, "boolean")
	self.quadtrees = use
end

-- Determines if Frame rate does not affect the simulation speed.
-- By default set to true.
function Engine:FrameRateIndependent(independent: boolean)
	throwTypeError("independent", independent, 1, "boolean")
	self.independent = independent
end

function Engine:SetConstraintIterations(iterations: number)
	throwTypeError("iterations", iterations, 1, "number")
	self.iterations.constraint = math.floor(math.clamp(iterations, 1, 10))
end

function Engine:SetCollisionIterations(iterations: number)
	throwTypeError("iterations", iterations, 1, "number")

	if self.quadtrees then
		self.iterations.collision = math.floor(math.clamp(iterations, 1, 10))
	else
		throwException("warn", "CANNOT_SET_COLLISION_ITERATIONS")
	end
end

function Engine:Destroy()
	self._janitor:Destroy()
	setmetatable(self, nil)
end

return Engine
