# API - `Point`

> **NOTE:**<br/>
> Points are handled by the Engine by default. Points are created for RigidBodies on creation. This class should only be used to create custom constraints and rigid bodies.

## Types

```lua
type engineConfig = {
	gravity: Vector2,
	friction: number,
	bounce: number
}

type canvas = {
	topLeft: Vector2,
	size: Vector2,
	frame: Frame
}

type pointConfig = {
	snap: boolean, 
	selectable: boolean, 
	render: boolean,
	keepInCanvas: boolean
}
```

## `Point.new()`

This method is used to initialize a new Point.

* parameters - `pos: Vector2, canvas: canvas, engine: engineConfig, config: pointConfig`
* returns - `Point`

## `Point:ApplyForce()`

This method is used to apply a force to the Point. (Automatically handled by the engine for RigidBodies and constraints)

* parameters - `force: Vector2`
* returns - `nil`

## `Point:Update()`

This method is used to apply external forces like gravity and is responsible for moving the point. (Automatically handled by the engine for RigidBodies and constraints)

* parameters - `dt: number`
* returns - `nil`

## `Point:KeepInCanvas()`

This method is used to keep the point in the engine's canvas. Any point that goes past the canvas, is positioned correctly and the direction of its flipped is reversed accordingly. 

* parameters - `none`
* returns - `nil`

## `Point:Render()`

This method is used to update the position and appearance of the Point on screen.

* parameters - `none`
* returns - `nil`

## `Point:SetRadius()`

This method is used to determine the radius of the point.

* parameters - `radius: number`
* returns `nil`

## `Point:Stroke()`

This method is used to determine the color of the point on screen. By default this is set to (RED) Color3.new(1, 0, 0).

* parameters - `color: Color3`
* returns `nil`

## `Point:Snap()`

This method determines if the point remains anchored. If set to false, the point is unanchored.

* parameters - `snap: boolean`
* returns `nil`

## `Point:Velocity()`

Returns the velocity of the Point.

* parameters - `none`
* returns `velocity: Vector2`