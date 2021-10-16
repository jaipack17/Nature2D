local Point = require(script.Parent.Point)
local Constraint = require(script.Parent.Constraint)
local Globals = require(script.Parent.Parent.constants.Globals)

local HttpService = game:GetService("HttpService")

local RigidBody = {}
RigidBody.__index = RigidBody  

local function GetCorners(frame, engine)
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

local function CalculatePenetration(minA, maxA, minB, maxB)
	if (minA < minB) then 
		return minB - maxA 
	else 
		return minA - maxB 
	end
end

local function CalculateCenter(vertices)
	local center = Vector2.new(0, 0)

	local minX = math.huge
	local minY = math.huge
	local maxX = -math.huge
	local maxY = -math.huge

	for _, v in ipairs(vertices) do 
		center += v.pos
		minX = math.min(minX, v.pos.x);
		minY = math.min(minY, v.pos.y);
		maxX = math.max(maxX, v.pos.x);
		maxY = math.max(maxY, v.pos.y);
	end

	center /= #vertices;
	
	return center
end

local function UpdateVertices(frame, vertices, engine)
	local corners = GetCorners(frame, engine)
	for i, vertex in ipairs(vertices) do 
		vertex.oldPos = corners[i]
		vertex.pos = corners[i]
	end
end

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
		support = false
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
		CanvasEdgeTouched = nil	
	}, RigidBody)
	
	if engine.path and engine.path.IgnoreGuiInset then 
		self.anchorPos = self.anchorPos and self.anchorPos + Globals.offset or nil
		self.center += Globals.offset
	end
	
	local touched = Instance.new("BindableEvent")
	touched.Name = "Touched"
	touched.Parent = self.frame
	
	local canvasEdgeTouched = Instance.new("BindableEvent")
	canvasEdgeTouched.Name = "CanvasEdgeTouched"
	canvasEdgeTouched.Parent = self.frame
	
	self.Touched = touched
	self.CanvasEdgeTouched = canvasEdgeTouched
	
	for _, edge in ipairs(edges) do
		edge.point1.Parent = edge
		edge.point2.Parent = edge
		edge.Parent = self
	end
	
	return self
end

function RigidBody:CreateProjection(Axis, Min, Max) 
	local DotP = Axis.x * self.vertices[1].pos.x + Axis.y * self.vertices[1].pos.y;
	Min, Max = DotP, DotP;

	for I = 2, #self.vertices, 1 do
		DotP = Axis.x * self.vertices[I].pos.x + Axis.y * self.vertices[I].pos.y;
		Min = math.min(DotP, Min)
		Max = math.max(DotP, Max)
	end

	return Min, Max
end

function RigidBody:DetectCollision(other)
	self.center = CalculateCenter(self.vertices)
	
	local minDist = math.huge
	local collision = {
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

	if collision.edge.Parent ~= other then
		local Temp = other
		other = self
		self = Temp
	end

	local centerDif = self.center - other.center
	local dot = collision.axis.x * centerDif.x + collision.axis.y * centerDif.y

	if dot < 0 then 
		collision.axis *= -1
	end	

	local minMag = math.huge 

	for i = 1, #self.vertices, 1 do
		local dif =  self.vertices[i].pos - other.center
		local dist = collision.axis.x * dif.x + collision.axis.y * dif.y

		if dist < minMag then
			minMag = dist
			collision.vertex = self.vertices[i]
		end
	end

	return { true, collision }; 
end

function RigidBody:ApplyForce(force: Vector2)
	if not typeof(force) == "Vector2" then error("Invalid Argument #1. 'force' must be a Vector2", 2) end
	
	for _, v in ipairs(self.vertices) do 
		v:ApplyForce(force)
	end
end

function RigidBody:Update()
	self.center = CalculateCenter(self.vertices)
	
	for i = 1, #self.vertices + #self.edges do 
		local edge = i > #self.vertices
		
		if edge then 
			self.edges[(#self.vertices + #self.edges) + 1 - i]:Constrain()
		else 
			self.vertices[i]:Update()
		end
	end
end

function RigidBody:Render()
	if self.lifeSpan and os.time() - self.spawnedAt >= self.lifeSpan then 
		self:Destroy()
	end
	
	for _, vertex in ipairs(self.vertices) do
		if not vertex.selectable then vertex.snap = self.anchored end
	end
	
	if self.anchored then 
		self:SetPosition(self.anchorPos)
		self:Rotate(self.anchorRotation)
	else 
		self.frame.Rotation = math.deg(math.atan2((self.vertices[1].pos - self.vertices[2].pos).y, (self.vertices[1].pos - self.vertices[2].pos).x))
		self.frame.Position = UDim2.new(0, self.center.x - self.frame.AbsoluteSize.x/2, 0, self.center.y - self.frame.AbsoluteSize.y/2)		
	end
end

function RigidBody:Destroy()
	for i, body in ipairs(self.engine.bodies) do
		if self.id == body.id then 
			self.frame:Destroy()
			table.remove(self.engine.bodies, i)
		end
	end
end

function RigidBody:Rotate(newRotation: number)
	if not typeof(newRotation) == "number" then error("Invalid Argument #1. 'newRotation' must be a number.") end
	
	local oldRotation = self.frame.Rotation
	self.frame.Position = self.anchored and UDim2.new(0, self.anchorPos.x, 0, self.anchorPos.y) or UDim2.new(0, self.center.x, 0, self.center.y)
	self.frame.Rotation = newRotation
	UpdateVertices(self.frame, self.vertices, self.engine)
	
	return oldRotation, newRotation
end

function RigidBody:SetPosition(newPosition: Vector2)
	if not typeof(newPosition) == "Vector2" then error("Invalid Argument #1. 'newPosition' must be a Vector2.") end
	
	if self.anchored and self.anchorRotation then 
		self.anchorRotation = newRotation
	end

	local oldPosition = self.frame.Position
	self.frame.Position = UDim2.new(0, newPosition.X, 0, newPosition.Y)
	UpdateVertices(self.frame, self.vertices, self.engine)
	
	return oldPosition, UDim2.new(0, newPosition.X, 0, newPosition.Y)
end

function RigidBody:SetSize(newSize: Vector2)
	if not typeof(newSize) == "Vector2" then error("Invalid Argument #1. 'newSize' must be a Vector2.") end

	local oldSize = self.frame.Size
	self.frame.Size = UDim2.new(0, newSize.X, 0, newSize.Y)
	UpdateVertices(self.frame, self.vertices, self.engine)

	return oldSize, UDim2.new(0, newSize.X, 0, newSize.Y)
end

function RigidBody:Anchor()
	self.anchored = true
	self.anchorRotation = self.frame.Rotation
	self.anchorPos = self.center
end

function RigidBody:Unanchor()
	self.anchored = false
	self.anchorRotation = nil
	self.anchorPos = nil
end

function RigidBody:CanCollide(collidable: boolean)
	if not typeof(collidable) == "boolean" then error("Invalid Argument #1. 'collidable' must be a boolean.") end
	self.collidable = collidable
end

function RigidBody:GetFrame()
	return self.frame
end

function RigidBody:GetId()
	return self.id
end

function RigidBody:GetVertices()
	return self.vertices
end

function RigidBody:GetConstraints()
	return self.edges
end

function RigidBody:SetLifeSpan(seconds: number)
	if not typeof(seconds) == "number" then error("Invalid Argument #1. 'seconds' must be a number.") end
	self.lifeSpan = seconds
end

function RigidBody:KeepInCanvas(keepInCanvas: boolean)
	if not typeof(keepInCanvas) == "boolean" then error("Invalid Argument #1. 'keepInCanvas' must be a number.") end
	for _, p in ipairs(self.vertices) do 
		p.keepInCanvas = keepInCanvas
	end
end

return RigidBody
