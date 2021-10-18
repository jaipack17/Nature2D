<div align="center">
    <img src="https://github.com/jaipack17/Nature2D/blob/master/Nature2D_LOGO.png?raw=true" />
</div>

# About

Nature2D is a 2D physics library designed for and on Roblox! Ever wanted to create 2D games but step back because Roblox doesn't have a built-in 2D physics engine? Use Nature2D to create versatile and smooth simulations and mechanics for your 2D games with minimum effort! Nature2D primarily uses methods of [Verlet Integration](https://en.wikipedia.org/wiki/Verlet_integration) and [Convex Hull collisions](https://en.wikipedia.org/wiki/Hyperplane_separation_theorem).

It's user friendly and supports all UI Elements. RigidBodies and constraints can potentially be made with almost all UI elements, from Frames to TextBoxes. Collision detection and response are also handled for all UI elements by default.

Create almost anything you can imagine. From bouncy boxes to destructible structures, even character movement in no time. Here's a wrecking ball connected to an invisible constraint knocking a few boxes off of the blue platform.

<img src="https://github.com/jaipack17/Nature2D/blob/master/wrecking%20ball%20example.gif?raw=true" />

# Configuration

* **Using the CLI** - You can clone the repository on your local device and start experimenting!
```bash
$ git clone https://github.com/jaipack17/Nature2D.git
```
* **Roblox Model** - Nature2D is available on the Roblox asset store for free. You can get the model through the following link.<br/>

https://www.roblox.com/library/7625799164/Nature2D

* **Using wally** - Use [wally](https://github.com/UpliftGames/wally), the package manager for roblox to install Nature2D in your external code editor! This requires wally to be installed on your device.
Example: `wally.toml`:
```toml
[package]
name = "scope/name"
version = "0.1.0"
registry = "https://github.com/UpliftGames/wally-index"
realm = "shared"

[dependencies]
Nature2D = "jaipack17/nature2d@0.0.1" # replace 0.0.1 with the latest version of Nature2D!
```
Run `wally install` in the CLI!


To get started:
```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Nature2D = require(ReplicatedStorage.Nature2D.Engine)

local engine = Nature2D.init(screenGuiInstance)
--[[
   Code here, check out the API and examples under docs/api and docs/examples!
]]--
```

# Documentation 

To get familiar with the library, you can go through the documentation.

[docs](https://github.com/jaipack17/Nature2D/tree/master/docs)<br/>
  * [getting started](https://github.com/jaipack17/Nature2D/blob/master/docs/README.md)<br/>
  * [api](https://github.com/jaipack17/Nature2D/tree/master/docs/api)<br/>
  * [examples](https://github.com/jaipack17/Nature2D/tree/master/docs/examples)<br/>
  * [placefiles](https://github.com/jaipack17/Nature2D/tree/master/docs/placefiles)<br/>

# Contributions

If you encounter bugs or would like to support this project by improving the code, adding new features or fixing bugs - Feel free to open issues and pull requests!
