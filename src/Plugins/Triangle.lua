-- Returns a triangular structure for Custom RigidBodies given 3 points
return function (a: Vector2, b: Vector2, c: Vector2)
	return {
		{ a, b, false },
		{ a, c, false },
		{ b, c, false }
	}
end
