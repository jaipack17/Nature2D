-- List of commonly used variables all across the library

return {
	engineInit = {
		gravity = Vector2.new(0, .3),
		friction = 0.9,
		airfriction = 0.98,
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
		"airfriction",
		"universalmass"
	},
	rigidbody = {
		props = {
			"Object",
			"Collidable",
			"Anchored",
			"LifeSpan",
			"KeepInCanvas",
			"Gravity",
			"Friction",
			"AirFriction",
			"Structure",
			"Mass",
			"CanRotate"
		},
		must_have = {
			"Object"
		}
	},
	constraint = {
		color = Color3.new(1, 1, 1),
		thickness = 4,
		types = {
			"rope",
			"spring",
			"rod"
		},
		props = {
			"Type",
			"Point1",
			"Point2",
			"Visible",
			"Thickness",
			"RestLength",
			"SpringConstant",
			"Color",
		},
		must_have = {
			"Type",
			"Point1",
			"Point2",
		}
	},
	point = {
		radius = 2.5,
		color = Color3.new(1),
		uicRadius = UDim.new(1, 0),
		props = {
			"Position",
			"Visible",
			"Snap",
			"KeepInCanvas",
			"Radius",
			"Color"
		},
		must_have = {
			"Position"
		}
	},
	offset = Vector2.new(0, 36),

	VALID_OBJECT_PROPS = {
		"Position",
		"Visible",
		"Snap",
		"KeepInCanvas",
		"Radius",
		"Color",
		"Type",
		"Point1",
		"Point2",
		"Thickness",
		"RestLength",
		"SpringConstant",
		"Object",
		"Collidable",
		"Anchored",
		"LifeSpan",
		"Gravity",
		"Friction",
		"AirFriction",
		"Structure",
		"Mass",
		"CanRotate"
	},

	OBJECT_PROPS_TYPES = {
		Position = "Vector2",
		Visible = "boolean",
		Snap = "boolean",
		KeepInCanvas = "boolean",
		Radius = "number",
		Color = "Color3",
		Type = "string",
		Thickness = "number",
		RestLength = "number",
		SpringConstant = "number",
		Object = "Instance",
		Collidable = "boolean",
		Anchored = "boolean",
		LifeSpan = "number",
		Gravity = "Vector2",
		Friction = "number",
		AirFriction = "number",
		Structure = "table",
		Mass = "number",
		CanRotate = "boolean"
	},
}
