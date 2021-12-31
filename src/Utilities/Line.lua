-- This utility is used to render a constraint on the screen.

-- Services and utilities
local Globals = require(script.Parent.Parent.Constants.Globals)

-- Create the constraint's instance and apply properties
local function draw(hyp: number, origin: Vector2, thickness: number, parent: Instance, color: Color3, l: Frame?, image: string?) : Frame
	local line = l or (image and Instance.new("ImageLabel") or Instance.new("Frame"))
	line.Name = "Constraint"
	line.AnchorPoint = Vector2.new(.5, .5)
	line.Size = UDim2.new(0, hyp, 0, (thickness or Globals.constraint.thickness) + (image and 15 or 0))
	line.BackgroundTransparency = image and 1 or 0
	line.BorderSizePixel = 0
	line.Position = UDim2.fromOffset(origin.X, origin.Y)
	line.ZIndex = 1

	if image then 
		line.Image = image
		line.ImageColor3 = color or Globals.constraint.color
	else 
		line.BackgroundColor3 = color or Globals.constraint.color
	end

	line.Parent = parent
	
	return line
end

return function (origin: Vector2, endpoint: Vector2, parent: Instance, thickness: number, color: Color3, l: Frame?, image: string?) : Frame
	-- Calculate magnitude between the constraint's points
	-- Draw the constraint
	-- Calculate rotation
	local hyp = (endpoint - origin).Magnitude
	local line = draw(hyp, origin, thickness, parent, color, l, image)
	local mid = (origin + endpoint)/2
	local theta = math.atan2((origin - endpoint).Y, (origin - endpoint).X)	
	
	-- Apply rotation and update position
	line.Position = UDim2.fromOffset(mid.x, mid.y)
	line.Rotation = math.deg(theta)

	return line
end
