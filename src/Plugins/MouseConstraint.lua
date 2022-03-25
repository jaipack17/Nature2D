local UserInputService = game:GetService("UserInputService")

return function (engine: { any }, range: number)
	local held = nil

	UserInputService.InputBegan:Connect(function(input, processedEvent)
		if processedEvent then return end

		if input.UserInputType == Enum.UserInputType.MouseButton1 and not held then
			for _, b in ipairs(engine.bodies) do
				for _, p in ipairs(b.vertices) do
					if (p.pos - UserInputService:GetMouseLocation()).Magnitude <= range then
						p.selectable = true
						held = p
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

		if input.UserInputType == Enum.UserInputType.MouseButton1 and held then
			held.selectable = false
			held = nil
		end
	end)

	UserInputService.InputChanged:Connect(function(input, processedEvent)
		if processedEvent then return end

		if input.UserInputType == Enum.UserInputType.MouseMovement and held then
			local mouse = UserInputService:GetMouseLocation()
			held:SetPosition(mouse.X, mouse.Y)
		end
	end)
end
