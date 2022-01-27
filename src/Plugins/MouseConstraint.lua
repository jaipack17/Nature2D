local UserInputService = game:GetService("UserInputService")

return function (engine: { any }, range: number)
	local mousePoint = engine:Create("Point", {
		Position = UserInputService:GetMouseLocation(),
		Visible = false,
		Snap = true,
		KeepInCanvas = false
	})
	local held = nil
	local constraint = nil

	UserInputService.InputBegan:Connect(function(input, processedEvent)
		if processedEvent then return end

		if input.UserInputType == Enum.UserInputType.MouseButton1 and not held and not constraint then
			for _, b in ipairs(engine.bodies) do
				for _, p in ipairs(b.vertices) do
					if (p.pos - UserInputService:GetMouseLocation()).Magnitude <= range then
						p.selectable = true
						held = p
						constraint = engine:Create("Constraint", {
							Type = "Rod",
							Point1 = held,
							Point2 = mousePoint,
							RestLength = 1,
							Visible = false
						})
						break
					end
				end
				
				if held then
					break
				end
			end
		end
	end)

	UserInputService.InputEnded:Connect(function(input, processedEvent)
		if processedEvent then return end

		if input.UserInputType == Enum.UserInputType.MouseButton1 and held and constraint then
			held.selectable = false
			constraint:Destroy()
			held = nil
			constraint = nil
		end
	end)

	UserInputService.InputChanged:Connect(function(input, processedEvent)
		if processedEvent then return end

		if input.UserInputType == Enum.UserInputType.MouseMovement then
			local mouse = UserInputService:GetMouseLocation()
			mousePoint:SetPosition(mouse.X, mouse.Y)
		end
	end)
end
