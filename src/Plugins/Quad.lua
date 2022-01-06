-- Returns a quadrilateral structure for Custom RigidBodies given 4 points
return function (a: Vector2, b: Vector2, c: Vector2, d: Vector2)
	return {
		{ a, b, false },
		{ b, c, false },
		{ c, d, false },
		{ d, a, false },
		{ a, c, true },
		{ b, d, true }
	}
end
