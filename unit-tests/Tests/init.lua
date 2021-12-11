return function ()
	local Tests = Instance.new("ScreenGui")
	Tests.Name = "Tests"
	Tests.Parent = game.Players.LocalPlayer.PlayerGui
	
	local Canvas = Instance.new("Frame")
	Canvas.Name = "Canvas"
	Canvas.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
	Canvas.BorderSizePixel = 0
	Canvas.Size = UDim2.fromScale(1, 1)
	Canvas.Parent = Tests
	
	local TestEZ = require(game.ReplicatedStorage.TestEZ)
	TestEZ.TestBootstrap:run({
		script.Utilities
	})
end