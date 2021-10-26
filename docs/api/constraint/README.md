# API - `Constraint`

>**NOTE:**<br/>
>Constraints are handled by the Engine by default. Constraints are created for RigidBodies on creation. This class should only be used to create custom constraints and rigid bodies.

## Types
```lua
type canvas = {
	topLeft: Vector2,
	size: Vector2,
	frame: Frame
}

type segmentConfig = {	
	restLength: number?, 
	render: boolean, 
	thickness: number,
	support: boolean
}
```

## `Constraint.new()`

This method is used to initialize a constraint.

* parameters - `p1: Point, p2: Point, canvas: canvas, config: segmentConfig`
* returns - `Constraint`

## `Constraint:Constrain()`

This method is used to keep uniform distance between the constraint's points, i.e. constrain.

* parameters - `none`
* returns - `nil`

## `Constraint:Render()`

This method is used to update the position and appearance of the constraint on screen.

* parameters - `none`
* returns - `nil`

## `Constraint:SetLength()`

Used to set the minimum constrained distance between two points. By default, the initial distance between the two points.

* parameters - `newLength: number`
* returns - `nil`

## `Constraint:GetLength()`

This method returns the current distance between the two points of a constraint.

* parameters - `none`
* returns - `distance: number`

## `Constraint:Stroke()`

This method is used to change the color of a constraint. By default a constraint's color is set to the default value of (WHITE) Color3.new(1, 1, 1).

* parameters - `color: Color3`
* returns - `nil`

## `Constraint:Destroy()`

This method destroys the constraint. Its UI element is no longer rendered on screen and the constraint is removed from the engine. This is irreversible.

* parameters - `none`
* returns - `nil`

## `Constraint:GetPoints()`

Returns the constraints points.

* parameters - `none`
* returns - `point1: Point, point2: Point`