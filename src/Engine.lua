local RigidBody = require(script.Parent.physics.RigidBody)
local Point = require(script.Parent.physics.Point)
local Constraint = require(script.Parent.physics.Constraint)
local Globals = require(script.Parent.constants.Globals)
local throwException = require(script.Parent.debug.Exceptions)
local throwTypeError = require(script.Parent.debug.TypeErrors)

local RunService = game:GetService("RunService")

local Engine = {}
Engine.__index = Engine

local function CollisionResponse(body, other, isColliding, Collision, dt)
	if not isColliding then return end
	
	body.Touched:Fire(other.id)
	
	local penetration = Collision.axis * Collision.depth
	local p1 = Collision.edge.point1
	local p2 = Collision.edge.point2

	local t
	if math.abs(p1.pos.x - p2.pos.x) > math.abs(p1.pos.y - p2.pos.y) then
		t = (Collision.vertex.pos.x - penetration.x - p1.pos.x)/(p2.pos.x - p1.pos.x);
	else 
		t = (Collision.vertex.pos.y - penetration.y - p1.pos.y)/(p2.pos.y - p1.pos.y);
	end

	local factor = 1/(t^2 + (1 - t)^2)
	
	if not Collision.edge.Parent.anchored then 
		p1.pos -= penetration * ((1 - t) * factor/2) * dt * 60
		p2.pos -= penetration * (t * factor/2)
	end	
	
	if not Collision.vertex.Parent.Parent.anchored then 	
		Collision.vertex.pos += penetration/2
	end	
end

function Engine.init(screengui: ScreenGui)
	if not typeof(screengui) == "ScreenGui" then error("Invalid Argument #1. 'screengui' must be a ScreenGui.", 2) end
	
	local self = setmetatable({
		bodies = {},
		constraints = {},
		points = {},
		connection = nil,
		gravity = Globals.engineInit.gravity,
		friction = Globals.engineInit.friction,
		bounce = Globals.engineInit.bounce,
		timeSteps = Globals.engineInit.timeSteps,
		path = screengui,
		speed = Globals.speed,
		canvas = {
			frame = nil,
			topLeft = Globals.engineInit.canvas.topLeft,
			size = Globals.engineInit.canvas.size
		}
	}, Engine)
	
	return self
end
 
function Engine:Start()
	if not self.canvas then throwException("error", "NO_CANVAS_FOUND") end
	if #self.bodies == 0 then throwException("warn", "NO_RIGIDBODIES_FOUND") end
	
	local connection;
	connection = RunService.RenderStepped:Connect(function(dt)
		for _, body in ipairs(self.bodies) do 
			body:Update(dt)
			for _, other in ipairs(self.bodies) do 
				if body.id ~= other.id and (body.collidable and other.collidable) then
					local result = body:DetectCollision(other)
					local isColliding = result[1]
					local Collision = result[2]
					
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

function Engine:Stop()
	if self.connection then 
		self.connection:Disconnect()
		self.connection = nil
	end
end

function Engine:CreateRigidBody(frame: GuiObject, collidable: boolean, anchored: boolean)
	if not typeof(frame) == "GuiObject" then error("Invalid Argument #1. 'frame' must be a GuiObject", 2) end
	throwTypeError("collidable", collidable, 2, "boolean")
	throwTypeError("anchored", anchored, 3, "boolean")

	local newBody = RigidBody.new(frame, Globals.universalMass, collidable, anchored, self)
	self.bodies[#self.bodies + 1] = newBody
	
	return newBody
end

function Engine:CreatePoint(position: Vector2, visible: boolean)
	throwTypeError("position", position, 1, "Vector2")
	throwTypeError("visible", visible, 2, "boolean")
	
	local newPoint = Point.new(position, self.canvas, self, {
		snap = false, 
		selectable = false, 
		render = visible,
		keepInCanvas = true
	})
	self.points[#self.points + 1] = newPoint
	
	return newPoint
end

function Engine:CreateConstraint(point1, point2, visible: boolean, thickness: number)
	throwTypeError("visible", visible, 3, "boolean")
	throwTypeError("thickness", thickness, 4, "number")
	
	local dist = (point2.pos - point1.pos).magnitude
	
	local newConstraint = Constraint.new(point1, point2, self.canvas, {
		restLength = dist, 
		render = visible, 
		thickness = thickness,
		support = true
	}, self)
	
	self.constraints[#self.constraints + 1] = newConstraint
	
	return newConstraint
end

function Engine:GetBodies()
	return self.bodies
end

function Engine:GetConstraints()
	return self.constraints
end

function Engine:GetPoints()
	return self.points
end

function Engine:CreateCanvas(topLeft: Vector2, size: Vector2, frame: Frame)
	throwTypeError("topLeft", topLeft, 1, "Vector2")
	throwTypeError("size", size, 2, "Vector2")
	
	self.canvas.absolute = topLeft
	self.canvas.size = size
	
	if frame and frame:IsA("Frame") then 
		self.canvas.frame = frame
	end
end

function Engine:SetSimulationSpeed(speed: number)
	throwTypeError("speed", speed, 1, "number")
	self.speed = speed
end

function Engine:SetPhysicalProperty(property: string, value)
	throwTypeError("property", property, 1, "string")
	
	local properties = Globals.properties
	
	if table.find(properties, string.lower(property)) then 
		for _, b in ipairs(self.bodies) do 
			for _, v in ipairs(b:GetVertices()) do 
				if string.lower(property) == "collisionmultiplier" then 
					throwTypeError("value", value, 2, "number")
					self.bounce = value
					v.bounce = value
				elseif string.lower(property) == "gravity" then 
					throwTypeError("value", value, 2, "Vector2")
					self.gravity = value
					v.gravity = value
				elseif string.lower(property) == "friction" then 					
					throwTypeError("value", value, 2, "number")
					self.friction = value
					v.friction = value
				end
			end
		end
	else
		throwException("error", "PROPERTY_NOT_FOUND")
	end
end

function Engine:GetBodyById(id: string)
	throwTypeError("id", id, 1, "string")
	
	for _, b in ipairs(self.bodies) do 
		if b.id == id then 
			return b
		end
	end
	
	return;
end

function Engine:GetConstraintById(id: string)
	throwTypeError("id", id, 1, "string")
	
	for _, c in ipairs(self.constraints) do 
		if c.id == id then 
			return c
		end
	end

	return;
end

return Engine