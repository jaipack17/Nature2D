return {
	engineInit = {
		gravity = Vector2.new(0, .3),
		friction = 0.99,
		bounce = 0.8,
		timeSteps = 1,
		canvas = {
			topLeft = Vector2.new(0, 0),
			size = workspace.CurrentCamera.ViewportSize,
		},
	},
	universalMass = 1,
	speed = 55,
	properties = {
		"gravity",
		"friction",
		"collisionmultiplier",
	},
	constraint = {
		color = Color3.new(1, 1, 1),
		thickness = 4,
	},
	point = {
		radius = 2.5,
		color = Color3.new(1),
		uicRadius = UDim.new(1, 0),
	},
	offset = Vector2.new(0, 36),
}
