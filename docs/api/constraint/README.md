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
