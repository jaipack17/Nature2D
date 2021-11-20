# Releases

## v0.4 - Refactored Object Creation Completely

Major Release. 

* Removed `Engine:CreatePoint()`
* Removed `Engine:CreateConstraint()`
* Removed `Engine:CreateRigidBody()`
* Added `Engine:Create(objectName: string, propertyTable: table)`

Creating new Constraints, Points and RigidBodies is much simpler than before! You just need to care about 1 single method - `Engine:Create()`. This method takes in 2 parameters. The first parameter being the type of instance you are creating. This is either "Point", "Constraint" or "RigidBody". The second parameter consists of the properties you wish to assign to the object. 

Intellisense of VSCode and Studio's script editor will suggest these properties to you!

https://user-images.githubusercontent.com/74130881/142725251-577454d1-abdd-40af-bddf-db1d4c286b2b.mp4

* Changed how you require Nature2D.
   *  Earlier: `require(ReplicatedStorage.Nature2D.Engine)`
   * Now: `require(ReplicatedStorage.Nature2D)`
* Added "Snap" to a valid property of `Point`
* API cleanup
* Rewrote commented docs in the source code.
* Fixed `Point:Render()` - Set point's anchor point to 0.5, 0.5
* Fixed Rod Constraints and how I solve them - See issue [#8](https://github.com/jaipack17/Nature2D/issues/8)

## v0.3.6 - Basic Collision Filtering

Implemented basic collision filtering API for RigidBodies! You can now ignore collisions for 2 rigid bodies while still being able to let them collide with other rigid bodies!

* Added Collision Filtering to Engine
* Added new Methods to RigidBodies
  * `Engine:FilterCollisionsWith(otherRigidBody: RigidBody)`
  * `Engine:UnfilterCollisionsWith(otherRigidBody: RigidBody)`
  * `Engine:GetFilteredRigidBodies()`

## v0.3.4 - Anchor Point Support

* Added Anchor point support
* Added new methods to RigidBodies
   * `RigidBody:GetCenter()`
* Added new methods to Points
   * `Point:SetPosition(newPosition: Vector2)`
* Bug fixes
   * Fixed Parent hierarchy errors in Points. 
   * Fixed `Point:Update()` "Cannot read property 'Parent' of nil" errors.
   * Fixed `Point:KeepInCanvas()` "Cannot read property 'Parent' of nil" errors.

## v0.3.2 - Major Improvements to Frictional Forces

* Fixed a bug where changes to physical properties before creating any RigidBodies, Constraints or Points won't affect/apply to newly created objects.
* Friction only applies if RigidBodies collide with each other or the edges of the canvas. If none of those conditions are true, AirFriction is applied.
* Added AirFriction physical property to Engine, Points and RigidBodies. Frictional force applied when a RigidBody neither touches another body nor the edges of canvas.
   * `Engine:SetPhysicalProperty("AirFriction", 0.1)`
* Friction and AirFriction are set to 0.01 by default. (0.99 damping value).
* Changed how we pass parameters when initializing or updating friction of the engine or rigidbodies. The closer the friction to 1, the higher it is. The closer the friction to 0, the lower it is. Same applies for AirFriction. Values not in the range of 0-1 are automatically clamped down.
* Added new Methods to RigidBodies
  * `RigidBody:SetAirFriction(airfriction: number)`

## v0.3.1 - Fixes to Collision Detection & New Methods

* Made `restLength: number?` an optional parameter for `Engine:CreateConstraint()`.
* Fixes to Collision Detection - Collision detection is no longer skipped at low frame rates.
* Fixed how forces are applied to Points when the engine is framerate independent.
* Added new methods to Engine
   * `Engine:FrameRateIndependent(independent: boolean)` - Determines if Frame rate does not affect the simulation speed. By default set to true.
* Added new methods to Constraint
   * `Constraint:GetParent()`
* Added new methods to Point 
   * `Point:GetParent()`

## v0.3 - New Constraints: Ropes, Rods & Springs!

Major Release. 

* Checks to prevent division by 0. 
* Fix `Constraint:SetLength()`. Disregard invalid lengths. (length <= 0)
* Fix `Engine:CreateConstraint()`. Disregard invalid thickness and lengths. (length & thickness <= 0)
* Added new methods to `Constraint`
   * `Constraint:SetSpringConstant(k: number)`
   * `Constraint:GetId()`
* New "type" paramater to `Engine:CreateConstraint()`
* New "restLength" parameter to `Engine:CreateConstraint()`
   * `Engine:CreateConstraint(Type: string, point1: Point, point2: Point, visible: boolean, thickness: number, restLength: number)`
* Added rope constraint type
   * Constraints that have an upper constrain limit and exclusive of a lower limit. Similar to Roblox's 3D Rope Constraints.
* Added rod constraint type
   * These constraints are similar to how Rope constraints function. But unlike rope constraints, these constraints have a fixed amount of space between its points and aren't flexible. These constraints can move in all directions just how rope constraints can, but the space between them remains constant.
* Added spring constraint type
   * Spring constraints are elastic, wonky and flexible. Perfect for various simulations that require springs. Achieved using Hooke's Law.
* Type parameter in Engine:CreateConstraint() must be "SPRING", "ROD" or "ROPE" (text case does not matter).

## v0.2.4 - Improvements to Code

* Add type definitions & annotations 
* Type check everything (almost)
* Remove code redundancies 
* Replace deprecations
   * `Vector2.x` -> `Vector2.X`
   * `Vector2.y` -> `Vector2.Y`
   * `Vector2.magnitude` -> `Vector2.Magnitude`
   * `Vector2.unit` -> `Vector2.Unit`
   * ... etc

## v0.2.3 - State Management

Added state management for RigidBodies. Individual RigidBodies can have their own States/Custom Properties now!
* `RigidBody:SetState(state: string, value: any)`
* `RigidBody:GetState(state: string)`

Example usage:

```lua
local Body = Engine:CreateRigidBody(frame, true, false)
Body:SetState("Health", 100)

local Killbrick = Engine:CreateRigidBody(frame2, true, true)

Killbrick.Touched:Connect(function(bodyID)
    if Body:GetId() == bodyID then
        local oldHealth = Body:GetState("Health")
        Body:SetState("Health", oldHealth - 1)
        return
    end
end)
```

## v0.2.0 - Quadtrees in Collision Detection!

Quadtrees have now been implemented into the collision detection algorithm making the engine 10 times faster than before. Instead of wasting resources on wasted and unnecessary collision detection checks, RigidBodies are now distributed into different regions of a quadtree with a collision hit range. RigidBodies only in this hit range are processed with collision detection checks. This opens the gate for many new creations that required a larger amount of RigidBodies to be simulated!

Since Quadtrees are still in beta, there may occur bugs and unwanted behavior. If you encounter any, be sure to open an issue at the github repository. I'll be adding configuration methods for you to switch between traditional methods of collision detection or quadtrees.

## v0.1.2 - Quadtrees in the works!

* Collision Detection is now being re-written, with the addition of quadtrees! 
* Fixed `RigidBody:Destroy()` Connections are now destroyed when `RigidBody:Destroy()` is called.
* Added new methods to Points
  * `Point:Velocity()`
* Added new methods to RigidBodies
  * `RigidBody:AverageVelocity()`
* Added new methods to Constraints
  * `Constraint:GetPoints()`
  * `Constraint:GetFrame()`
* Fixed `Constraint:Destroy()`. Does not spam errors if connected to a RigidBody now.

<img src="https://user-images.githubusercontent.com/74130881/138874154-ea20396e-9a19-4d41-9925-3c3a008f4911.gif" alt="gif" width="500px" />
  

## v0.1.0 - Additions to Constraints, Engine and RigidBodies.

* Added new methods to Constraints
  * `Constraint:SetLength()` - [Documentation](https://github.com/jaipack17/Nature2D/tree/master/docs/api/constraint#constraintsetlength)
* Added new methods to RigidBodies
  * `RigidBody:IsInBounds()` - [Documentation](https://github.com/jaipack17/Nature2D/tree/master/docs/api/rigidbody#rigidbodyisinbounds)
* Added new events to Engine
  * `Engine.Started`
  * `Engine.Stopped`
```lua
engine.Started:Connect(function()
    -- fires when the engine starts
end)

engine.Stopped:Connect(function()
    -- fires when the engine stops
end)
```

## v0.0.5 - Fixes and New Stuff!

* The library now utilizes sleitnick's Signal class instead of bindable events.
  * `RigidBody.CanvasEdgeTouched:Connect()`
  * `RigidBody.Touched:Connect()`
* Bug Fixes
  * Error Handling
* Improved code - Removed bad practices 
* RigidBody.CanvasEdgeTouched event returns the edge the RigidBody collides with.
* Added new methods to Engine
  * Engine:GetCurrentCanvas() - [Documentation](https://github.com/jaipack17/Nature2D/blob/master/docs/api/engine/README.md#enginegetcurrentcanvas)
  
<hr/>

Added new example which covers the concept of creating Custom Constraints, where we create the following simulation of a RigidBody hanging from a rope, and wind forces being applied on it.

![rope](https://user-images.githubusercontent.com/74130881/138543851-c4871e17-f51e-4b5b-9d11-0fc63a32de02.gif)

## v0.0.4 - Engine:SetSimulationSpeed() & Documentation

* Updated API-References for RigidBodies, Constraints, Points and Engine in response to this and previous updates.
* Documented source code with comments.
* Better error handling and error messages
* Fixed Engine:SetPhysicalProperty() bug where updating a physical property before creating a rigidbody did not change the properties for the rigidbody.
* Added new Methods to Engine
   * `Engine:SetSimulationSpeed()`

## v0.0.3 - Frame-rate Independent!

**Earlier:** Simulations running on different frame rates had a difference in their speeds. A simulation running on 60fps would run faster than that of a simulation running at 30fps.

**Now:** Frame-rate no longer affects simulations. A RigidBody covering a distance of 10 units in a simulation running at 30fps and a simulation running 60fps will take almost the same time to reach the destination. 

## v0.0.2 - Custom Point Support, Configuration Methods and More!

* Installation through Wally! Nature2D can now be installed using [Wally](https://github.com/UpliftGames/wally), the package manager for Roblox. This requires wally to be installed on your device. In order to install Nature2D, add a dependency to your `wally.toml` file
   * ![dependency](https://doy2mn9upadnk.cloudfront.net/uploads/default/original/4X/3/4/8/348c3d6c9436a92cf44160b9e8aee5b2a5933193.png)

   * After you have added the dependency, run `wally install` in the command line. A "Packages" directory is created containing the library. You can now use Nature2D in your external editor using wally!

* Bug Fixes 
  * Linked Issue: [#1](https://github.com/jaipack17/Nature2D/issues/1)  
* `Engine:CreateCanvas()` now has an optional 'frame' parameter to help render custom points and constraints.
* Refactored certain segments of code for better readability. 
* Added Custom Point support to Engine
  * `Engine:CreatePoint()`
  * `Engine:GetPoints()` 
* Added new Configuration methods to Constraints
   * `Constraint:Stroke()` 
* Added new Configuration methods to Points
   * `Point:SetRadius()`
   * `Point:Stroke()`
   * `Point:Snap()`

## v0.0.1 - Improvements & New Methods

* Improved architecture for anchored RigidBodies.
* Constraints now have their own unique IDs like RigidBodies.
* Added new Methods to Constraints
   * `Constraint:GetLength()` 
   * `Constraint:Destroy()`
* Added new Methods to Engine
   * `Engine:GetConstraints()`
   * `Engine:GetConstraintById()`
* Added new Methods to RigidBodies
   * `RigidBody:SetFriction()`
   * `RigidBody:SetGravity()`
