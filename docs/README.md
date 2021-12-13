# Documentation has been moved! https://jaipack17.github.io/Nature2D/

<hr/>

# Documentation

To get familiar with Nature2D and quickly adopt it into your codebase, you may go through the documentation which goes through how Nature2D works, its api, usage, examples and placefiles to give you a broad idea about the library. If you spot any errors in the documentation, please open an issue or a pull request with the fix! Thanks!

# Workflow

Before diving into the api, it is important to know how the library really comes together and do what its supposed to do. The library uses methods of [Verlet Integration](https://en.wikipedia.org/wiki/Verlet_integration) and Convex Hull Collisions (Separating Axis Theorem) to simulate physics. I have detailed the math and working of both of those methods on the Devforum and Github with code snippets! If you'd want to explore more about them, go through the following links!
* [Devforum - Verlet Integration](https://devforum.roblox.com/t/the-beauty-of-verlet-integration-2d-ragdolls/1467651/)
* [Github - Verlet Integration](https://github.com/jaipack17/write-ups/tree/main/Verlet%20Integration)
* [Devforum - 2D Collisions](https://devforum.roblox.com/t/detecting-and-responding-to-2d-collisions-fundamentals-techniques/1484368)
* [Github - 2D Collisions](https://github.com/jaipack17/write-ups/tree/main/2D%20Collisions)

Back to Nature2D. The library is divided into different segments. The core, which is the Engine. The physics based classes, which are the RigidBodies, Constraints and Points, utilities which consists of non inclusive modules to help render constraints and points on the screen and global constant values.

# `Engine`

The Engine or the core of the library handles all the RigidBodies, constraints and points. It's responsible for the simulation of these elements and handling all tasks related to the library. Physics is simulated every RenderStepped with the following structure:

![image](https://user-images.githubusercontent.com/74130881/136814983-b97705c5-2efe-4611-81db-30704b127b33.png)

All tasks are performed in order as seen in the picture above.

### API
* [`Engine.init()`](https://github.com/jaipack17/Nature2D/tree/master/docs/api/engine#engineinit)
* [`Engine:CreateCanvas()`](https://github.com/jaipack17/Nature2D/tree/master/docs/api/engine#enginecreatecanvas)
* [`Engine:CreateRigidBody()`](https://github.com/jaipack17/Nature2D/tree/master/docs/api/engine#enginecreaterigidbody)
* [`Engine:CreateConstraints()`](https://github.com/jaipack17/Nature2D/tree/master/docs/api/engine#enginecreateconstraint)
* [`Engine:SetPhysicalProperty()`](https://github.com/jaipack17/Nature2D/tree/master/docs/api/engine#enginesetphysicalproperty)
* [`Engine:Start()`](https://github.com/jaipack17/Nature2D/tree/master/docs/api/engine#enginestart)
* [`Engine:Stop()`](https://github.com/jaipack17/Nature2D/tree/master/docs/api/engine#enginestop)
* [`Engine:GetBodies()`](https://github.com/jaipack17/Nature2D/tree/master/docs/api/engine#enginegetbodies)
* [`Engine:GetBodyById()`](https://github.com/jaipack17/Nature2D/tree/master/docs/api/engine#enginegetbodybyid)

# `Point`

Points are what make the rigid bodies behave like real world entities! Points are responsible for the movement of the RigidBodies and Constraints! These points have a velocity and acceleration that make them move around a canvas! These points are not rendered on the screen by default and it is advisable to keep it that way. Points don't need to be created manually unless creating custom Constraints. By default points are handled by the core (Engine) itself!

### API

* [`Point.new()`](https://github.com/jaipack17/Nature2D/tree/master/docs/api/point#pointnew)
* [`Point:ApplyForce()`](https://github.com/jaipack17/Nature2D/tree/master/docs/api/point#pointapplyforce)
* [`Point:Update()`](https://github.com/jaipack17/Nature2D/tree/master/docs/api/point#pointupdate)
* [`Point:KeepInCanvas()`](https://github.com/jaipack17/Nature2D/tree/master/docs/api/point#pointkeepincanvas)
* [`Point:Render()`](https://github.com/jaipack17/Nature2D/tree/master/docs/api/point#pointrender)

# `Constraint`

Constraints keep two points together in place and maintain uniform distance between the two! Constraints and Points together join to keep a RigidBody in place hence making both Points and Constraints a vital part of the library. Custom constraints such as Ropes, Rods, Bridges and chains can also be made! Points of two rigid bodies can be connected with constraints, two individual points can also be connected with constraints to form Ropes etc. Although flexible API is not yet available to make these constraints, you can still use [`Engine:CreateConstraint()`]() which is still in Beta, to create constraints.

### API

* [`Constraint.new()`](https://github.com/jaipack17/Nature2D/tree/master/docs/api/constraint#constraintnew)
* [`Constraint:Constrain`](https://github.com/jaipack17/Nature2D/tree/master/docs/api/constraint#constraintconstrain)
* [`Constraint:Render()`](https://github.com/jaipack17/Nature2D/tree/master/docs/api/constraint#constraintrender)

# `RigidBody`

RigidBodies are formed by Constraints, Points and UI Elements! These RigidBodies are highly flexible to meet all your use cases! RigidBodies can be customized and custom physical properties can be defined for them. By default they abide by the universal physical properties of the engine. RigidBodies as of now cannot have different masses. An update has been planned to support this.

### API

* [`RigidBody.new()`](https://github.com/jaipack17/Nature2D/tree/master/docs/api/rigidbody#rigidbodynew)
* [`RigidBody:CreateProjection()`](https://github.com/jaipack17/Nature2D/tree/master/docs/api/rigidbody#rigidbodycreateprojection)
* [`RigidBody:DetectCollision()`](https://github.com/jaipack17/Nature2D/tree/master/docs/api/rigidbody#rigidbodydetectcollision)
* [`RigidBody:ApplyForce`](https://github.com/jaipack17/Nature2D/tree/master/docs/api/rigidbody#rigidbodyapplyforce)
* [`RigidBody:Update()`](https://github.com/jaipack17/Nature2D/tree/master/docs/api/rigidbody#rigidbodyupdate)
* [`RigidBody:Render()`](https://github.com/jaipack17/Nature2D/tree/master/docs/api/rigidbody#rigidbodyrender)
* [`RigidBody:Destroy()`](https://github.com/jaipack17/Nature2D/tree/master/docs/api/rigidbody#rigidbodydestroy)
* [`RigidBody:Rotate()`](https://github.com/jaipack17/Nature2D/tree/master/docs/api/rigidbody#rigidbodyrotate)
* [`RigidBody:SetPosition()`](https://github.com/jaipack17/Nature2D/tree/master/docs/api/rigidbody#rigidbodysetposition)
* [`RigidBody:SetSize()`](https://github.com/jaipack17/Nature2D/tree/master/docs/api/rigidbody#rigidbodysetsize)
* [`RigidBody:Anchor()`](https://github.com/jaipack17/Nature2D/tree/master/docs/api/rigidbody#rigidbodyanchor)
* [`RigidBody:Unanchor()`](https://github.com/jaipack17/Nature2D/tree/master/docs/api/rigidbody#rigidbodyunanchor)
* [`RigidBody:CanCollide()`](https://github.com/jaipack17/Nature2D/tree/master/docs/api/rigidbody#rigidbodycancollide)
* [`RigidBody:GetFrame()`](https://github.com/jaipack17/Nature2D/tree/master/docs/api/rigidbody#rigidbodygetframe)
* [`RigidBody:GetId()`](https://github.com/jaipack17/Nature2D/tree/master/docs/api/rigidbody#rigidbodygetid)
* [`RigidBody:GetVertices()`](https://github.com/jaipack17/Nature2D/tree/master/docs/api/rigidbody#rigidbodygetvertices)
* [`RigidBody:GetConstraints()`](https://github.com/jaipack17/Nature2D/tree/master/docs/api/rigidbody#rigidbodygetconstraints)
* [`RigidBody:SetLifeSpan()`](https://github.com/jaipack17/Nature2D/tree/master/docs/api/rigidbody#rigidbodysetlifespan)
* [`RigidBody:KeepInCanvas()`](https://github.com/jaipack17/Nature2D/tree/master/docs/api/rigidbody#rigidbodykeepincanvas)
* [`RigidBody.Touched`](https://github.com/jaipack17/Nature2D/tree/master/docs/api/rigidbody#rigidbodytouched)
* [`RigidBody.CanvasEdgeTouched`](https://github.com/jaipack17/Nature2D/tree/master/docs/api/rigidbody#rigidbodycanvasedgetouched)

<hr/>

This introduction should give you a brief understanding of how everything works. Continue reading furthur by clicking links above or exploring the API, examples and placefiles!
