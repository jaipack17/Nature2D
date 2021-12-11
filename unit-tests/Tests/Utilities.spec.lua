return function ()
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local line = require(ReplicatedStorage.Nature2D.Utilities.Line)
	local canvas = game.Players.LocalPlayer.PlayerGui:WaitForChild("Tests").Canvas
	
	describe("Draw Line", function ()
		it("should draw a line given two points on the screen", function ()
			local newLine = line(Vector2.new(0, 0), Vector2.new(10, 10), canvas, 1, Color3.new(1, 1, 1))
			expect(typeof(newLine) == "Instance").to.be.ok()
		end)
	end)
end