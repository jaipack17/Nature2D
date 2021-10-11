local Globals = require(script.Parent.Parent.constants.Globals)

local function draw(hyp, origin, thickness, parent, color, l) 
	local line = l or Instance.new("Frame")
	line.Name = "Constraint"
	line.AnchorPoint = Vector2.new(.5, .5)
	line.Size = UDim2.new(0, hyp, 0, thickness or Globals.constraint.thickness)
	line.BackgroundColor3 = color or Globals.constraint.color
	line.BorderSizePixel = 0
	line.Position = UDim2.fromOffset(origin.x, origin.y)
	line.ZIndex = 1
	line.Parent = parent

	return line
end

return function (origin, endpoint, parent, thickness, color, l)
	local adj = (Vector2.new(endpoint.x, origin.y) - Vector2.new(origin.x, origin.y)).Magnitude
	local opp = (Vector2.new(endpoint.x, origin.y) - Vector2.new(endpoint.x, endpoint.y)).Magnitude
	local hyp = math.sqrt(adj^2 + opp^2)

	local line = l and draw(hyp, origin, thickness, parent, color, l) or draw(hyp, origin, thickness, parent, color)		
	local mid = Vector2.new((origin.x + endpoint.x)/2, (origin.y + endpoint.y)/2)

	local theta = math.atan2(origin.y - endpoint.y, origin.x - endpoint.x)
	theta /= math.pi
	theta *= 180

	line.Position = UDim2.fromOffset(mid.x, mid.y)
	line.Rotation = theta

	return line
end
