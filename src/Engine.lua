local RigidBody = require(script.Parent.physics.RigidBody)
local Point = require(script.Parent.physics.Point)
local Constraint = require(script.Parent.physics.Constraint)
local Globals = require(script.Parent.constants.Globals)

local RunService = game:GetService("RunService")

local Engine = {}
Engine.__index = Engine

local function CollisionResponse(body, other, isColliding, Collision)
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
		p1.pos -= penetration * ((1 - t) * factor/2)
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
		connection = nil,
		gravity = Globals.engineInit.gravity,
		friction = Globals.engineInit.friction,
		bounce = Globals.engineInit.bounce,
		timeSteps = Globals.engineInit.timeSteps,
		path = screengui,
		canvas = {
			frame = nil,
			topLeft = Globals.engineInit.canvas.topLeft,
			size = Globals.engineInit.canvas.size
		}
	}, Engine)
	
	return self
end
 
function Engine:Start()
	if not self.canvas then error("No canvas found, initialize the engine's canvas using Engine:CreateCanvas()", 2) end
	if #self.bodies == 0 then warn("No rigid bodies found on start") end
		
	local connection;
	connection = RunService.RenderStepped:Connect(function(dt)
		for _, body in ipairs(self.bodies) do 
			body:Update(dt)
			for _, other in ipairs(self.bodies) do 
				if body.id ~= other.id and (body.collidable and other.collidable) then
					local result = body:DetectCollision(other)
					local isColliding = result[1]
					local Collision = result[2]
					
					CollisionResponse(body, other, isColliding, Collision)
				end
			end
			for _, vertex in ipairs(body.vertices) do
				vertex:Render()
			end
			body:Render()
		end
		
		if #self.constraints > 0 then 
			for _, constraint in ipairs(self.constraints) do 
				constraint.point1:Update(dt)
				constraint.point2:Update(dt)
				constraint.point1:Render(dt)
				constraint.point2:Render(dt)
				constraint:Constrain()
				constraint:Render()
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
	if not typeof(collidable) == "boolean" then error("Invalid Argument #2. 'collidable' must be a boolean", 2) end
	if not typeof(anchored) == "boolean" then error("Invalid Argument #3. 'anchored' must be a boolean", 2) end	
	
	local newBody = RigidBody.new(frame, Globals.universalMass, collidable, anchored, self)
	self.bodies[#self.bodies + 1] = newBody
	
	return newBody
end

function Engine:CreateConstraint(point1, point2, visible: boolean, thickness: number)
	if not typeof(visible) == "boolean" then error("Invalid Argument #3. 'visible' must be a boolean", 2) end
	if not typeof(thickness) == "number" then error("Invalid Argument #4. 'thickness' must be a number", 2) end
	
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

function Engine:CreateCanvas(topLeft: Vector2, size: Vector2)
	if not typeof(topLeft) == "Vector2" then error("Invalid Argument #1. 'topLeft' must be a Vector2", 2) end
	if not typeof(size) == "Vector2" then error("Invalid Argument #2. 'size' must be a Vector2", 2) end
	
	self.canvas.absolute = topLeft
	self.canvas.size = size
end

function Engine:SetPhysicalProperty(property: string, value)
	if not typeof(property) == "string" then error("Invalid Argument #1. Property must be a string", 2) end
	
	local properties = Globals.properties
	
	if table.find(properties, string.lower(property)) then 
		for _, b in ipairs(self.bodies) do 
			for _, v in ipairs(b:GetVertices()) do 
				if string.lower(property) == "collisionmultiplier" then 
					if not typeof(value) == "number" then error("Invalid Argument #2. CollisionMultiplier must be a number. 0-1 is advisable.", 2) end
					v.bounce = value
				elseif string.lower(property) == "gravity" then 
					if not typeof(value) == "Vector2" then error("Invalid Argument #2. Gravity must be a Vector2.", 2) end
					v.gravity = value
				elseif string.lower(property) == "friction" then 
					if not typeof(value) == "number" then error("Invalid Argument #2. Friction must be a number. 0-1 is advisable.", 2) end
					v.friction = value
				end
			end
		end
	else
		error("Invalid Argument #1. Property not found", 2)
	end
end

function Engine:GetBodyById(id: string)
	if not typeof(id) == "string" then error("Invalid Argument #1. 'id' must be a string", 2) end
	
	for _, b in ipairs(self.bodies) do 
		if b.id == id then 
			return b
		end
	end
	
	return;
end

function Engine:GetConstraintById(id: string)
	if not typeof(id) == "string" then error("Invalid Argument #1. 'id' must be a string", 2) end

	for _, c in ipairs(self.constraints) do 
		if c.id == id then 
			return c
		end
	end

	return;
end

return Engine
