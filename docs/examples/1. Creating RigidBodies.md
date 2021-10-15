# Creating RigidBodies

Creating rigidbodies in the engine is fairly simple, just configure the engine and use `Engine:CreateRigidBody()` method! When a RigidBody is created, a unique ID is assigned to it, Points are created for its vertices and these points are connected with Constraints! 

RigidBodies support the following UI elements. 
* Frame
* ScrollingFrame
* ImageButton
* ImageLabel
* TextLabel
* TextBox
* TextButton
* VideoFrame
* ViewportFrame

In this example, we create the following simulation:

https://user-images.githubusercontent.com/74130881/137440874-5af0adc0-0b7f-4d3e-afd0-7505cda7fb1a.mp4

<hr/>

The first step would be the create a frame which will be an anchored RigidBody.

<img src="https://user-images.githubusercontent.com/74130881/137439187-c4f7b98a-7efb-4c86-9f51-d18e93813df5.png" width="500px" />

Next we'll create separate ImageLabels for each box, you can do this using a script as well! For the boxes, I used the following image:

![crate](https://user-images.githubusercontent.com/74130881/137439711-2dc81369-99db-4a43-9cdf-cf89d492af2b.png)

I spread the boxes around and group them inside a single folder!

<img src="https://user-images.githubusercontent.com/74130881/137439856-f7c24950-55fc-4c96-99fa-26891fcfe1f9.png" width="500px" /><img align="right" src="https://user-images.githubusercontent.com/74130881/137439959-cb0d4feb-1839-4a9a-a534-6ca2d2b0f3c1.png" width="200px" />

Let's bring our boxes to life! Firstly we start by initializing our engine.

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Nature2D = require(ReplicatedStorage:FindFirstChild("Nature2D").Engine)

local ScreenGui = script.Parent
local Canvas = ScreenGui.Canvas

local engine = Nature2D.init(ScreenGui)
```

Next we make the Anchored base an anchored rigidbody!

```lua
engine:CreateRigidBody(Canvas.AnchoredPart, true, true) -- [[collidable: true, anchored: true]]
```

We now loop through each box in the 'Boxes' folder and make it an unanchored rigid body! Lastly, we start the engine and boom! You have the simulation ready.

```lua
for _, box in ipairs(Canvas.Boxes:GetChildren()) do
	engine:CreateRigidBody(box, true, false) -- [[collidable: true, anchored: false]]
end

engine:Start()
```

This is how easily you can create RigidBodies for your games with potentially any UI element. You can try replacing them with textboxes, viewportframes etc! The placefile for this example is available in docs/placefiles.
