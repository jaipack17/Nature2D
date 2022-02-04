-- TODO: When Promise is on Wally, remove this in favor of just `script.Parent.Parent:FindFirstChild("Promise")`.
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local LOCATIONS_TO_SEARCH = {script.Parent.Parent, ReplicatedFirst, ReplicatedStorage, ServerScriptService, ServerStorage}

local function FindFirstDescendantWithNameAndClassName(Parent: Instance, Name: string, ClassName: string)
	for _, Descendant in ipairs(Parent:GetDescendants()) do
		if Descendant:IsA(ClassName) and Descendant.Name == Name then
			return Descendant
		end
	end

	return nil
end

local function GetPromiseLibrary()
	-- I'm not too keen on how this is done.
	-- It's better than the multiple if statements (probably).
	local Plugin = script:FindFirstAncestorOfClass("Plugin")
	if Plugin then
		local Promise = FindFirstDescendantWithNameAndClassName(Plugin, "Promise", "ModuleScript")
		if Promise then
			return true, require(Promise)
		else
			return false
		end
	end

	local Promise
	for _, Location in ipairs(LOCATIONS_TO_SEARCH) do
		Promise = FindFirstDescendantWithNameAndClassName(Location, "Promise", "ModuleScript")
		if Promise then
			break
		end
	end

	if Promise then
		return true, require(Promise)
	else
		return false
	end
end

return GetPromiseLibrary