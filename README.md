<div align="center">
    <img src="https://doy2mn9upadnk.cloudfront.net/uploads/default/original/4X/e/7/0/e709b34f89add2336a7d74faee3b2a839a9391b0.png" width="480" /><br/><br/>
    <a href="https://github.com/jaipack17/Nature2D/releases"><img alt="version" src="https://img.shields.io/badge/v0.6.5--beta-version-%231FD67F"></img></a>
    <br/>
    <a href="https://devforum.roblox.com/t/physics-library-nature2d-bring-ui-elements-to-life/1510935/"><img alt="devforum" src="https://img.shields.io/badge/topic-devforum-white"></img></a>
    <a href="https://www.roblox.com/library/7625799164/Nature2D"><img alt="model" src="https://img.shields.io/badge/asset-roblox-white"></img></a>
    <a href="https://jaipack17.github.io/Nature2D/"><img alt="documentation" src="https://img.shields.io/badge/docs-website-white"></img></a>
</div>

## About

Nature2D is a 2D physics library designed for and on Roblox. Ever wanted to create 2D games but step back because Roblox doesn't have a built-in 2D physics engine? Use Nature2D to create versatile and smooth simulations and mechanics for your 2D games with minimum effort. Nature2D primarily uses methods of [Verlet Integration](https://en.wikipedia.org/wiki/Verlet_integration) and [Convex Hull collisions](https://en.wikipedia.org/wiki/Hyperplane_separation_theorem).

RigidBodies and constraints can potentially be made with almost all UI elements, from Frames to TextBoxes. Create almost anything you can imagine. From bouncy boxes to destructible structures, even character movement in no time. Here's a wrecking ball connected to an invisible constraint knocking a few boxes off of the blue platform.

## Showcase

Created something cool with Nature2D? Open an [issue](https://github.com/jaipack17/Nature2D/issues) or a [pull request](https://github.com/jaipack17/Nature2D/pulls) if you wish to showcase it here!

| <p>Rotating Objects</p> <img width="250px" src="https://github.com/jaipack17/Nature2D/blob/master/assets/spin.gif?raw=true"> | <p>Wrecking Ball</p> <img width="250px" src="https://doy2mn9upadnk.cloudfront.net/uploads/default/original/4X/c/9/d/c9d0129948912361012047ff2c507e42bd032dd1.gif"> | <p>Constraints</p> <img width="250px" src="https://github.com/jaipack17/Nature2D/blob/master/assets/constraints.gif?raw=true"> | <p>Smooth Collisions</p> <img width="270px" src="https://user-images.githubusercontent.com/74130881/142762580-b0bbba61-1a03-4d40-932c-f46344b78815.gif"> |
|-|-|-|-|
| <p align="center"><b>Double Pendulum</b></p> <img width="300px" src="https://user-images.githubusercontent.com/74130881/142763125-4c833456-013e-4eb4-9866-36f2eaa82db6.gif"> | <p align="center"><b>Inclined Plane</b></p> <img width="300px" src="https://user-images.githubusercontent.com/74130881/142762715-f17f53ae-a2c8-4ed0-b32e-cad0b72c63b8.gif"> | <p align="center"><b>Slingshot</b></p> <img width="300px" src="https://user-images.githubusercontent.com/74130881/142762938-699dea39-9c9f-417f-9b00-ed512ae1ccb7.gif"> | <p align="center"><b>Box Stack</b></p> <img width="300px" src="https://user-images.githubusercontent.com/74130881/142763023-1d5b6b1e-b93f-4026-806a-c9449b679b93.gif"> |

## Getting Started

**Using the CLI** - You can clone the repository on your local device and start experimenting.
```bash
$ git clone https://github.com/jaipack17/Nature2D.git
```

**Roblox Model** - Nature2D is available on the Roblox asset store for free. You can get the model through the following link.<br/>

https://www.roblox.com/library/7625799164/Nature2D

**Using .rbxm File** - Head over to the [Releases](https://github.com/jaipack17/Nature2D/releases) page on github, choose a version and download the `Nature2D@x.y.z.rbxm` file from its assets. Now right click in Roblox Studio's explorer, click Insert From File and select the file.

**Using wally** - Use [wally](https://github.com/UpliftGames/wally), a package manager for roblox to install Nature2D in your external code editor. This requires wally to be installed on your device. Then, add Nature2D to the dependencies listed in your `wally.toml` file.<br/>
```toml
[dependencies]
Nature2D = "jaipack17/nature2d@0.6.5"
```
After that, Run `wally install` in the cli. Nature2D should be installed in your root directory. If you encounter any errors or problems installing Nature2D using wally, [open an issue!](https://github.com/jaipack17/Nature2D/issues)

Require the library and start coding.

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Nature2D = require(ReplicatedStorage.Nature2D)

local World = Instance.new("ScreenGui")
World.IgnoreGuiInset = true
World.Parent = game.Players.LocalPlayer.PlayerGui

local engine = Nature2D.init(World)

-- code
```
To get familiar with the library, you can go through the documentation. Documentation is available at https://jaipack17.github.io/Nature2D/.

## Contribution

If you encounter bugs or would like to support this project by improving the code, adding new features or fixing bugs - Feel free to open issues and pull requests. Also read the [contribution guide](https://github.com/jaipack17/Nature2D/blob/master/CONTRIBUTING.md).
