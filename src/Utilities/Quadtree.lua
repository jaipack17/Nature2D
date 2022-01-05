-- This utility is used in Collision Detection
-- Quadtree data structure

-- Services and utilities
local Types = require(script.Parent.Parent.Types)

local Quadtree = {}
Quadtree.__index = Quadtree

-- Calculate sub-divisions of a node
local function GetDivisions(position: Vector2, size: Vector2)
	return {
		position,
		position + Vector2.new(size.X/2, 0),
		position + Vector2.new(0, size.Y/2),
		position + Vector2.new(size.X/2, size.Y/2),
	}
end

-- Check if a range overlaps a node of the quadtree
local function RangeOverlapsNode(node: Types.Quadtree<Types.RigidBody>, range: Types.Range) : boolean
	local ap1 = range.position
	local as1 = range.size
	local sum = ap1 + as1

	local ap2 = node.position
	local as2 = node.size
	local sum2 = ap2 + as2

	-- Detect overlapping
	return (ap1.x < sum2.x and sum.x > ap2.x) and (ap1.y < sum2.y and sum.y > ap2.y)
end

-- Check if a point lies within a range
local function RangeHasPoint(range: Types.Range, obj: Types.RigidBody) : boolean
	local p = obj.center

	return (
		(p.X > range.position.X) and (p.X < (range.position.X + range.size.X)) and
		(p.Y > range.position.Y) and (p.Y < (range.position.Y + range.size.Y))
	)
end

-- Merge two arrays
local function merge<T>(array1: {T}, array2: {T}) : {T}
	if #array2 > 0 then
		for _, v in ipairs(array2) do
			table.insert(array1, v)
		end
	end

	return array1
end

-- Initialize a new quadtree
function Quadtree.new(_position: Vector2, _size: Vector2, _capacity: number)
	return setmetatable({
		position = _position,
		size = _size,
		capacity = _capacity,
		objects = {},
		divided = false,
	}, Quadtree)
end

-- Insert a RigidBody in the quadtree
function Quadtree:Insert(body: Types.RigidBody)
	if not self:HasObject(body.center) then return end

	if #self.objects < self.capacity then
		self.objects[#self.objects + 1] = body
	else
		-- Subdivide if not already
		if not self.divided then
			self:SubDivide()
			self.divided = true
		end

		-- Insert the RigidBody in the subdivisions if possible
		self.topLeft:Insert(body)
		self.topRight:Insert(body)
		self.bottomLeft:Insert(body)
		self.bottomRight:Insert(body)
	end
end

function Quadtree:HasObject(p: Vector2) : boolean
	return (
		(p.X > self.position.X) and (p.X < (self.position.X + self.size.X)) and
		(p.Y > self.position.Y) and (p.Y < (self.position.Y + self.size.Y))
	)
end

-- Create subdivisions of a node
function Quadtree:SubDivide()
	local divisions = GetDivisions(self.position, self.size)

	self.topLeft = Quadtree.new(divisions[1], self.size/2, self.capacity)
	self.topRight = Quadtree.new(divisions[2], self.size/2, self.capacity)
	self.bottomLeft = Quadtree.new(divisions[3], self.size/2, self.capacity)
	self.bottomRight = Quadtree.new(divisions[4], self.size/2, self.capacity)
end

-- Search through the nodes, given a range query.
-- Returns any rigidbody that lies within the range.
function Quadtree:Search(range: Types.Range, objects: { Types.RigidBody })
	if not objects then
		objects = {}
	end

	if not RangeOverlapsNode(self, range) then
		return objects
	end

	for _, obj in ipairs(self.objects) do
		if RangeHasPoint(range, obj) then
			objects[#objects + 1] = obj
		end
	end

	if self.divided then
		self.topLeft:Search(range, objects)
		self.topRight:Search(range, objects)
		self.bottomLeft:Search(range, objects)
		self.bottomRight:Search(range, objects)
	end

	return objects
end

return Quadtree