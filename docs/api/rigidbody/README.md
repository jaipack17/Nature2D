# API - `RigidBody`

## Types 

```lua
type info: {
  axis: Vector2,
  depth: number,
  edge: Constraint,
  vertex: Point,
}
```

## `RigidBody.new()`

This method is used to initialize a new RigidBody.

* parameters - `frame: GuiObject, collidable: boolean, anchored: boolean, engine: Engine`
* returns - `RigidBody`

## `RigidBody:CreateProjection()`

This method projects the RigidBody on an axis. Used for collision detection.

* parameters - `axis: Vector2, min, max`
* returns - `min: number, max: number`

## `RigidBody:DetectCollision()`

This method detects collision between two RigidBodies.

* parameters - `body: RigidBody`
* returns - `{ colliding: boolean, collision: info }`

## `RigidBody:ApplyForce()`

This method is used to apply an external force on the rigid body.

* parameters - `force: Vector2`
* returns - `nil`

## `RigidBody:Update()`

This method updates the positions of the RigidBody's points and constraints.

* parameters - `dt: number`
* returns - `nil`

## `RigidBody:Render()`

This method updates the positions and appearance of the RigidBody on screen.

* parameters - `none`
* returns - `nil`

## `RigidBody:Destroy()`

This method is used to destroy the RigidBody. The body's UI element is destroyed, its connections are disconnected and the body is removed from the engine.

* parameters - `none`
* returns - `nil`

## `RigidBody:Rotate()`

This method is used to rotate the RigidBody's UI element. After rotation the positions of its points and constraints are automatically updated.

* parameters - `newRotation: number`
* returns - `oldRotation: number, newRotation: number`

## `RigidBody:SetPosition()`

This method is used to set a new position of the RigidBody's UI element. After updating the position, the positions of its points and constraints are automatically updated.

* parameters - `newPosition: Vector2`
* returns - `oldPosition: UDim2, newPosition: UDim2`

## `RigidBody:SetSize()`

This method is used to set a new size of the RigidBody's UI element. After updating the size, the positions of its points and constraints are automatically updated.

* parameters - `newSize: Vector2`
* returns - `oldSize: UDim2, newSize: UDim2`

## `RigidBody:Anchor()`

This method is used to anchor the RigidBody. Its position will no longer change. It will still be able to collide with other RigidBodies. It will act the same as an anchored BasePart. Rotate(), SetPosition() and SetSize() can still be called.

* parameters - `none`
* returns - `nil`

## `RigidBody:Unanchor()`

This method is used to unachor and anchored RigidBody.

* parameters - `none`
* returns - `nil`

## `RigidBody:CanCollide()`

This method is used to determine whether the RigidBody will collide with other RigidBodies. If set to false, collision detection and response will be skipped. Similar to how BasePart.CanCollide functions.

* parameters - `collidable: boolean`
* returns - `nil`

## `RigidBody:GetFrame()`

The RigidBody's UI Element can be fetched using this method.

* parameters - `none`
* returns - `UIElement: GuiObject`

## `RigidBody:GetId()`

The RigidBody's unique ID can be fetched using this method.

* parameters - `none`
* returns - `id: string`

## `RigidBody:GetVertices()`

The RigidBody's Points can be fetched using this method.

* parameters - `none`
* returns - `points: table`

## `RigidBody:GetConstraints()`

The RigidBody's Constraints can be fetched using this method.

* parameters - `none`
* returns - `constraints: table`

## `RigidBody:SetLifeSpan()`

This method is used to set the RigidBody's life span. Life span is determined by 'seconds'. After this time in seconds has been passed after the RigidBody is created, the RigidBody is automatically destroyed and removed from the engine.

* parameters - `seconds: number`
* returns - `nil`

## `RigidBody:KeepInCanvas()`

This method determines if the RigidBody stays inside the engine's canvas at all times. If set to false, the RigidBody will be able to go past the engine's canvas (boundaries).

* parameters - `keepInCanvas: boolean`
* returns - `nil`

## `RigidBody:SetFriction()`

This method sets a custom frictional damp value just for the RigidBody. The RigidBody no longer abides by the engine's universal friction.

* parameters - `friction: number`
* returns - `nil`

## `RigidBody:SetGravity()`

This method sets a custom gravitational force just for the RigidBody. The RigidBody no longer abides by the engine's universal gravity.

* parameters - `gravity: Vector2`
* returns - `nil`

## `RigidBody:IsInBounds()`

Returns true if the RigidBody lies within the boundaries of the canvas, else false.

* parameters - `none`
* returns - `isInBounds: boolean`

## `RigidBody.Touched`

This event is fired when the RigidBody collides with another RigidBody. This event returns the unique ID of the other RigidBody.

* returns - `RigidBodyID: number`
* Also Check out:
  * [`Engine:GetBodyById()`](https://github.com/jaipack17/Nature2D/tree/master/docs/api/engine#enginegetbodybyid)

## `RigidBody.CanvasEdgeTouched`

This event is fired when the RigidBody collides with the engine's canvas' boundary. 

* returns - `edge: string`
