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
* [`Engine.init()`]()
* [`Engine:CreateCanvas()`]()
* [`Engine:CreateRigidBody()`]()
* [`Engine:CreateConstraints()`]()
* [`Engine:SetPhysicalProperty()`]()
* [`Engine:Start()`]()
* [`Engine:Stop()`]()
* [`Engine:GetBodies()`]()
* [`Engine:GetBodyById()`]()

# `Point`

Points are what make the rigid bodies behave like real world entities! Points are responsible for the movement of the RigidBodies and Constraints! These points have a velocity and acceleration that make them move around a canvas! These points are not rendered on the screen by default and it is advisable to keep it that way. Points don't need to be created manually unless creating custom Constraints. By default points are handled by the core (Engine) itself!

### API

* [`Point.new()`]()
* [`Point:ApplyForce()`]()
* [`Point:Update()`]()
* [`Point:KeepInCanvas()`]()
* [`Point:Render()`]()
* [`Point:SetConfig()`]()

# `Constraint`

Constraints keep two points together in place and maintain uniform distance between the two! Constraints and Points together join to keep a RigidBody in place hence making both Points and Constraints a vital part of the library. Custom constraints such as Ropes, Rods, Bridges and chains can also be made! Points of two rigid bodies can be connected with constraints, two individual points can also be connected with constraints to form Ropes etc. Although flexible API is not yet available to make these constraints, you can still use [`Engine:CreateConstraint()`]() which is still in Beta, to create constraints.

### API

* [`Constraint.new()`]()
* [`Constraint:Constrain`]()
* [`Constraint:Render()`]()
