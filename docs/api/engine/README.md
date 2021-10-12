# API - `Engine`
## `Engine.init()`

This method is used to initialize basic configurations of the engine and allocate memory for future tasks. The function takes in 1 parameter, a ScreenGui. It is a must, in order to handle Offsets produced by ScreenGui.IgnoreGuiInset without any visual bugs.

* parameters - `screengui: ScreenGui`
* returns - `metatable`

## `Engine:CreateCanvas()`

This function is used to initialize boundaries to which all bodies and constraints obey. An object cannot go past this boundary. By default this canvas is set to the initial screen size (workspace.CurrentCamera.ViewportSize). In order to let bodies go past this boundary use the [`Engine:KeepInCanvas()`]() method. If you wish to render Constraints and Points on screen. Set a frame with the same size as the canvas to `engine.canvas.frame`.

* parameters - `topLeft: AbsolutePosition (Vector2), size: AbsoluteSize (Vector2)`
* returns - `nil`

Also check out:
* [`Engine:KeepInCanvas`]()
* [`[EVENT] RigidBody.CanvasEdgeTouched`]()

## `Engine:CreateRigidBody()`

This method is used to turn a normal UI element into a physical entity.
