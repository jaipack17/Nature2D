<div align="center">
    <img src="https://github.com/jaipack17/Nature2D/blob/master/assets/Nature2D_LOGO.png?raw=true" /><br/>
    <a href="https://devforum.roblox.com/t/physics-library-nature2d-bring-ui-elements-to-life/1510935/27"><img alt="version" src="https://img.shields.io/badge/v0.2.0--beta-version-green"></img></a>
    <br/>
    <a href="https://devforum.roblox.com/t/physics-library-nature2d-bring-ui-elements-to-life/1510935/"><img alt="devforum" src="https://img.shields.io/badge/post-devforum-blue"></img></a>
    <a href="https://www.roblox.com/library/7625799164/Nature2D"><img alt="model" src="https://img.shields.io/badge/asset-roblox-%23FF0000"></img></a>
    <a href="https://github.com/jaipack17/Nature2D/tree/master/docs/"><img alt="documentation" src="https://img.shields.io/badge/getting--started-docs-orange"></img></a>
    <a href="https://github.com/jaipack17/Nature2D/tree/master/docs/api"><img alt="api" src="https://img.shields.io/badge/api-docs-orange"></img></a>
    <a href="https://github.com/jaipack17/Nature2D/tree/master/docs/examples"><img alt="api" src="https://img.shields.io/badge/examples-docs-orange"></img></a>
</div>

# About

Nature2D is a 2D physics library designed for and on Roblox! Ever wanted to create 2D games but step back because Roblox doesn't have a built-in 2D physics engine? Use Nature2D to create versatile and smooth simulations and mechanics for your 2D games with minimum effort! Nature2D primarily uses methods of [Verlet Integration](https://en.wikipedia.org/wiki/Verlet_integration) and [Convex Hull collisions](https://en.wikipedia.org/wiki/Hyperplane_separation_theorem).

It's user friendly and supports all UI Elements. RigidBodies and constraints can potentially be made with almost all UI elements, from Frames to TextBoxes. Collision detection and response are also handled for all UI elements by default.

Create almost anything you can imagine. From bouncy boxes to destructible structures, even character movement in no time. Here's a wrecking ball connected to an invisible constraint knocking a few boxes off of the blue platform.

<img src="https://github.com/jaipack17/Nature2D/blob/master/assets/wrecking%20ball%20example.gif?raw=true" />

# Configuration

* **Using the CLI** - You can clone the repository on your local device and start experimenting!
```bash
$ git clone https://github.com/jaipack17/Nature2D.git
```
* **Roblox Model** - Nature2D is available on the Roblox asset store for free. You can get the model through the following link.<br/>

https://www.roblox.com/library/7625799164/Nature2D

* **Using wally** - Use [wally](https://github.com/UpliftGames/wally), a package manager for roblox to install Nature2D in your external code editor! This requires wally to be installed on your device. Then, add Nature2D to the dependencies listed in your `wally.toml` file!<br/>
```toml
[dependencies]
Nature2D = "jaipack17/nature2d@0.2.0
```
After that, Run `wally install` in the CLI! Nature2D should be installed in your root directory. If you encounter any errors or problems installing Nature2D using wally, [open an issue!](https://github.com/jaipack17/Nature2D/issues)

<hr/>

**To get started:**
```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Nature2D = require(ReplicatedStorage.Nature2D.Engine)

local engine = Nature2D.init(screenGuiInstance)
--[[
   Code here, check out the API and examples under docs/api and docs/examples!
]]--
```
To get familiar with the library, you can go through the documentation.

[Documentation](https://github.com/jaipack17/Nature2D/tree/master/docs)<br/>
[Getting Started](https://github.com/jaipack17/Nature2D/blob/master/docs/README.md)<br/>
[API Reference](https://github.com/jaipack17/Nature2D/tree/master/docs/api)<br/>
[Examples & Tutorials](https://github.com/jaipack17/Nature2D/tree/master/docs/examples)<br/>
[Example Placefiles](https://github.com/jaipack17/Nature2D/tree/master/docs/placefiles)<br/>

# Showcase

### Rotating RigidBodies

https://user-images.githubusercontent.com/74130881/139102128-2293b268-d4d9-440a-b961-cb377b050c3f.mp4

### Smooth Collisions

https://user-images.githubusercontent.com/74130881/139102559-132aef05-fb09-4e30-8844-226758839ad3.mp4

### Destructible Structures

https://user-images.githubusercontent.com/74130881/139103050-d6774bfb-789c-4f64-a4dd-e3d3d73bfda7.mp4

### Inclined Plane

https://user-images.githubusercontent.com/74130881/139103207-e6e13e5e-8e4c-4da1-9cce-432f91554433.mp4

### Ragdolls

https://user-images.githubusercontent.com/74130881/139103375-3580265a-06e7-49e8-9947-c9a666ca7d8b.mp4

### Constraints

https://user-images.githubusercontent.com/74130881/139103515-588a0211-c7d7-44d2-9667-4467e5aad245.mp4

# Performance

Regarding performance, Nature2D does just fine for almost any game. Every RenderStepped event, actions take place, as described above. Performance varies according to the amount of RigidBodies and constraints being simulated. It also depends upon how many collisions take place in between 'n' number of RigidBodies. 

It runs at 60fps with an average of 100 collisions every frame. Frames may drop, if RigidBodies are used as particle emitters or large scale simulations. Its advisable to use custom 2D Particle Emitters instead of RigidBodies due to frame drops.

# Accuracy 

In terms of physical accuracy, Nature2D does well. It's not and isn't meant to be completely physically accurate since that's near to impossible but I do plan on improving a lot of things that make it resemble the real world much better. Few things that I would improve is the friction. Friction currently is just a damping value, I do plan on refactoring it.

Collisions are not necessarily physically accurate. They are meant to have a game-like vibe. I do plan on refactoring it as well.

# Contribution

If you encounter bugs or would like to support this project by improving the code, adding new features or fixing bugs - Feel free to open issues and pull requests! Also read the [contribution guide](https://github.com/jaipack17/Nature2D/blob/master/CONTRIBUTING.md)!
