--[[
	This utility is used to render a constraint on the screen.
]]--


local Globals = require(script.Parent.Parent.constants.Globals)
local Math = require(script.Parent.Parent.Math)

local function draw(hyp: number, origin: Vector2, thickness: number, parent: Instance, color: Color3, l: Frame?) : Frame
	local line = l or Instance.new("Frame")
	line.Name = "Constraint"
	line.AnchorPoint = Vector2.new(.5, .5)
	line.Size = UDim2.new(0, hyp, 0, thickness or Globals.constraint.thickness)
	line.BackgroundColor3 = color or Globals.constraint.color
	line.BorderSizePixel = 0
	line.Position = UDim2.fromOffset(origin.X, origin.Y)
	line.ZIndex = 1
	line.Parent = parent

	return line
end

return function (origin: Vector2, endpoint: Vector2, parent: Instance, thickness: number, color: Color3, l: Frame?) : Frame
	local hyp = (endpoint - origin).Magnitude

	local line = draw(hyp, origin, thickness, parent, color, l)
	local mid = (origin + endpoint)/2
	local theta = Math.Vector.angle(endpoint, origin)	

	line.Position = UDim2.fromOffset(mid.X, mid.Y)
	line.Rotation = math.deg(theta)

	return line
end