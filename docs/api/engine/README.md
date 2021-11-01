# API - `Engine`
## `Engine.init()`

This method is used to initialize basic configurations of the engine and allocate memory for future tasks. The function takes in 1 parameter, a ScreenGui. It is a must, in order to handle Offsets produced by ScreenGui.IgnoreGuiInset without any visual bugs.

* parameters - `screengui: ScreenGui`
* returns - `Engine`

## `Engine:CreateCanvas()`

This function is used to initialize boundaries to which all bodies and constraints obey. An object cannot go past this boundary. By default this canvas is set to the initial screen size (workspace.CurrentCamera.ViewportSize). In order to let bodies go past this boundary use the [`RigidBody:KeepInCanvas()`](https://github.com/jaipack17/Nature2D/tree/master/docs/api/rigidbody#rigidbodykeepincanvas) method. If you wish to render Constraints and Points on screen. Set a frame with the same size as the canvas to `engine.canvas.frame`.

* parameters - `topLeft: AbsolutePosition (Vector2), size: AbsoluteSize (Vector2)`
* returns - `nil`
* Also check out:
  * [`RigidBody:KeepInCanvas`](https://github.com/jaipack17/Nature2D/tree/master/docs/api/rigidbody#rigidbodykeepincanvas)
  * [`[EVENT] RigidBody.CanvasEdgeTouched`](https://github.com/jaipack17/Nature2D/blob/master/docs/api/rigidbody/README.md#rigidbodycanvasedgetouched)

## `Engine:CreateRigidBody()`

This method is used to turn a normal UI element into a physical entity.

* parameters - `frame: GuiObject, collidable: boolean, anchored: boolean`
* returns - `RigidBody`
* Supported UI Elements
  * Frame
  * ScrollingFrame
  * ImageButton
  * ImageLabel
  * TextLabel
  * TextBox
  * TextButton
  * VideoFrame
  * ViewportFrame
* Also Check out:
  * [API - RigidBody](https://github.com/jaipack17/Nature2D/tree/master/docs/api/rigidbody)

## `Engine:CreatePoint()`

This method is used to create a custom point in the Engine. It can be used to create custom constraints.

* parameters - `position: Vector2, visible: boolean`
* returns - `Point`
* Also Check out:
  * [API - Point](https://github.com/jaipack17/Nature2D/tree/master/docs/api/point)

## `Engine:CreateConstraint()`

This method is used to create non collidable constraints that hold together two points. This can be used to create ropes or hold two rigid bodies together. In order to create a constraint, it is a must to have 2 points to connect the constraint with.

* parameters - `point1: Point, point2: Point, visible: boolean, thickness: number`
* returns - `Constraint`
* Also Check out:
  * [API - Point](https://github.com/jaipack17/Nature2D/tree/master/docs/api/point)

## `Engine:Start()`

This method is used to start simulating rigid bodies and constraints. This method is responsible for updating rigid bodies' and constraints' positions along with collision detection and response according to different configurations. If no rigid bodies or constraints are found when this method is called, a warning is sent in the console.

* parameters - `none`
* returns - `nil`

## `Engine:Stop()`

This method is used to stop simulating rigid bodies and constraints. All connections created when [`Engine:Start()`](#enginestart) is called, are disconnected.

## `Engine:SetPhysicalProperty()`

This method is used to configure universal physical properties possessed by all rigid bodies and constraints. Properties like Gravity, Friction and CollisionMultiplier can be set using this method.

* parameters - `property: string, value`
* returns - `nil`
* valid properties - `"Gravity": Vector2, "Friction": number, "CollisionMultiplier": number`

## `Engine:SetSimulationSpeed`

This method is used to determine the simulation speed of the engine. By default the simulation speed is set to 55.

* parameters - `speed: number`
* returns `nil`

## `Engine:GetBodies()`

This method is used to fetch all RigidBodies that have been created. Ones that have been destroyed, won't be fetched.

* parameters - `none`
* returns - `RigidBodies: table`

## `Engine:GetConstraints()`

This method is used to fetch all Constraints that have been created. Ones that have been destroyed, won't be fetched.

* parameters - `none`
* returns - `Constraints: table`

## `Engine:GetPoints()`

This method is used to fetch all Points that have been created. 

* parameters - `none`
* returns - `Points: table`

## `Engine:GetBodyById()`

This method is used to fetch an individual rigid body from its ID. Every RigidBody has a unique ID which can be fetched using [`RigidBody:GetId()`]() or `RigidBody.id`.

* parameters - `id: string`
* returns - `RigidBody`
* Also Check out:
  * [`RigidBody:GetId()`](https://github.com/jaipack17/Nature2D/tree/master/docs/api/rigidbody#rigidbodygetid)

## `Engine:GetConstraintById()`

This method is used to fetch an individual constraint body from its ID. 

* parameters - `id: string`
* returns - `Constraint`

## `Engine:GetCurrentCanvas()`

Returns current canvas the engine adheres to.

* parameters - `none`
* returns - `{ frame: Frame, topLeft: Vector2, size: Vector2 }`

## `Engine:UseQuadtrees()`

Determines if Quadtrees will be used in collision detection

* parameters - `use: boolean`
* returns - `nil`

## `Engine.Started`

This event is fired when the engine starts the simulation.

## `Engine.Stopped`

This event is fired when the engine stops the simulation.
