-- Janitor
-- Original by Validark
-- Modifications by pobammer
-- roblox-ts support by OverHash and Validark
-- LinkToInstance fixed by Elttob.
-- Cleanup edge cases fixed by codesenseAye.

local GetPromiseLibrary = require(script.GetPromiseLibrary)
local Symbol = require(script.Symbol)
local FoundPromiseLibrary, Promise = GetPromiseLibrary()

local IndicesReference = Symbol("IndicesReference")
local LinkToInstanceIndex = Symbol("LinkToInstanceIndex")

local METHOD_NOT_FOUND_ERROR = "Object %s doesn't have method %s, are you sure you want to add it? Traceback: %s"
local NOT_A_PROMISE = "Invalid argument #1 to 'Janitor:AddPromise' (Promise expected, got %s (%s))"

--[=[
	Janitor is a light-weight, flexible object for cleaning up connections, instances, or anything. This implementation covers all use cases,
	as it doesn't force you to rely on naive typechecking to guess how an instance should be cleaned up.
	Instead, the developer may specify any behavior for any object.

	@class Janitor
]=]
local Janitor = {}
Janitor.ClassName = "Janitor"
Janitor.CurrentlyCleaning = true
Janitor[IndicesReference] = nil
Janitor.__index = Janitor

local TypeDefaults = {
	["function"] = true;
	RBXScriptConnection = "Disconnect";
}

--[=[
	Determines if the passed object is a Janitor. This checks the metatable directly.

	@param Object any -- The object you are checking.
	@return boolean -- `true` if `Object` is a Janitor.
]=]
function Janitor.Is(Object: any): boolean
	return type(Object) == "table" and getmetatable(Object) == Janitor
end

type StringOrTrue = string | boolean

--[=[
	Adds an `Object` to Janitor for later cleanup, where `MethodName` is the key of the method within `Object` which should be called at cleanup time.
	If the `MethodName` is `true` the `Object` itself will be called instead. If passed an index it will occupy a namespace which can be `Remove()`d or overwritten.
	Returns the `Object`.

	:::info
	Objects not given an explicit `MethodName` will be passed into the `typeof` function for a very naive typecheck.
	RBXConnections will be assigned to "Disconnect", functions will be assigned to `true`, and everything else will default to "Destroy".
	Not recommended, but hey, you do you.
	:::

	```lua
	local Workspace = game:GetService("Workspace")
	local TweenService = game:GetService("TweenService")

	local Obliterator = Janitor.new()
	local Part = Workspace.Part

	-- Queue the Part to be Destroyed at Cleanup time
	Obliterator:Add(Part, "Destroy")

	-- Queue function to be called with `true` MethodName
	Obliterator:Add(print, true)

	-- This implementation allows you to specify behavior for any object
	Obliterator:Add(TweenService:Create(Part, TweenInfo.new(1), {Size = Vector3.new(1, 1, 1)}), "Cancel")

	-- By passing an Index, the Object will occupy a namespace
	-- If "CurrentTween" already exists, it will call :Remove("CurrentTween") before writing
	Obliterator:Add(TweenService:Create(Part, TweenInfo.new(1), {Size = Vector3.new(1, 1, 1)}), "Destroy", "CurrentTween")
	```

	```ts
	import { Workspace, TweenService } from "@rbxts/services";
	import { Janitor } from "@rbxts/janitor";

	const Obliterator = new Janitor<{ CurrentTween: Tween }>();
	const Part = Workspace.FindFirstChild("Part") as Part;

	// Queue the Part to be Destroyed at Cleanup time
	Obliterator.Add(Part, "Destroy");

	// Queue function to be called with `true` MethodName
	Obliterator.Add(print, true);

	// This implementation allows you to specify behavior for any object
	Obliterator.Add(TweenService.Create(Part, new TweenInfo(1), {Size: new Vector3(1, 1, 1)}), "Cancel");

	// By passing an Index, the Object will occupy a namespace
	// If "CurrentTween" already exists, it will call :Remove("CurrentTween") before writing
	Obliterator.Add(TweenService.Create(Part, new TweenInfo(1), {Size: new Vector3(1, 1, 1)}), "Destroy", "CurrentTween");
	```

	@param Object T -- The object you want to clean up.
	@param MethodName? string|true -- The name of the method that will be used to clean up. If not passed, it will first check if the object's type exists in TypeDefaults, and if that doesn't exist, it assumes `Destroy`.
	@param Index? any -- The index that can be used to clean up the object manually.
	@return T -- The object that was passed as the first argument.
]=]
function Janitor:Add(Object: any, MethodName: StringOrTrue?, Index: any?): any
	if Index then
		self:Remove(Index)

		local This = self[IndicesReference]
		if not This then
			This = {}
			self[IndicesReference] = This
		end

		This[Index] = Object
	end

	MethodName = MethodName or TypeDefaults[typeof(Object)] or "Destroy"
	if type(Object) ~= "function" and not Object[MethodName] then
		warn(string.format(METHOD_NOT_FOUND_ERROR, tostring(Object), tostring(MethodName), debug.traceback(nil :: any, 2)))
	end

	self[Object] = MethodName
	return Object
end

--[=[
	Adds a [Promise](https://github.com/evaera/roblox-lua-promise) to the Janitor. If the Janitor is cleaned up and the Promise is not completed, the Promise will be cancelled.

	```lua
	local Obliterator = Janitor.new()
	Obliterator:AddPromise(Promise.delay(3)):andThenCall(print, "Finished!"):catch(warn)
	task.wait(1)
	Obliterator:Cleanup()
	```

	```ts
	import { Janitor } from "@rbxts/janitor";

	const Obliterator = new Janitor();
	Obliterator.AddPromise(Promise.delay(3)).andThenCall(print, "Finished!").catch(warn);
	task.wait(1);
	Obliterator.Cleanup();
	```

	@param PromiseObject Promise -- The promise you want to add to the Janitor.
	@return Promise
]=]
function Janitor:AddPromise(PromiseObject)
	if FoundPromiseLibrary then
		if not Promise.is(PromiseObject) then
			error(string.format(NOT_A_PROMISE, typeof(PromiseObject), tostring(PromiseObject)))
		end

		if PromiseObject:getStatus() == Promise.Status.Started then
			local Id = newproxy(false)
			local NewPromise = self:Add(Promise.new(function(Resolve, _, OnCancel)
				if OnCancel(function()
					PromiseObject:cancel()
				end) then
					return
				end

				Resolve(PromiseObject)
			end), "cancel", Id)

			NewPromise:finallyCall(self.Remove, self, Id)
			return NewPromise
		else
			return PromiseObject
		end
	else
		return PromiseObject
	end
end

--[=[
	Cleans up whatever `Object` was set to this namespace by the 3rd parameter of [Janitor.Add](#Add).

	```lua
	local Obliterator = Janitor.new()
	Obliterator:Add(workspace.Baseplate, "Destroy", "Baseplate")
	Obliterator:Remove("Baseplate")
	```

	```ts
	import { Workspace } from "@rbxts/services";
	import { Janitor } from "@rbxts/janitor";

	const Obliterator = new Janitor<{ Baseplate: Part }>();
	Obliterator.Add(Workspace.FindFirstChild("Baseplate") as Part, "Destroy", "Baseplate");
	Obliterator.Remove("Baseplate");
	```

	@param Index any -- The index you want to remove.
	@return Janitor
]=]
function Janitor:Remove(Index: any)
	local This = self[IndicesReference]

	if This then
		local Object = This[Index]

		if Object then
			local MethodName = self[Object]

			if MethodName then
				if MethodName == true then
					Object()
				else
					local ObjectMethod = Object[MethodName]
					if ObjectMethod then
						ObjectMethod(Object)
					end
				end

				self[Object] = nil
			end

			This[Index] = nil
		end
	end

	return self
end

--[=[
	Gets whatever object is stored with the given index, if it exists. This was added since Maid allows getting the task using `__index`.

	```lua
	local Obliterator = Janitor.new()
	Obliterator:Add(workspace.Baseplate, "Destroy", "Baseplate")
	print(Obliterator:Get("Baseplate")) -- Returns Baseplate.
	```

	```ts
	import { Workspace } from "@rbxts/services";
	import { Janitor } from "@rbxts/janitor";

	const Obliterator = new Janitor<{ Baseplate: Part }>();
	Obliterator.Add(Workspace.FindFirstChild("Baseplate") as Part, "Destroy", "Baseplate");
	print(Obliterator.Get("Baseplate")); // Returns Baseplate.
	```

	@param Index any -- The index that the object is stored under.
	@return any? -- This will return the object if it is found, but it won't return anything if it doesn't exist.
]=]
function Janitor:Get(Index: any): any?
	local This = self[IndicesReference]
	if This then
		return This[Index]
	else
		return nil
	end
end

local function GetFenv(self)
	return function()
		for Object, MethodName in pairs(self) do
			if Object ~= IndicesReference then
				return Object, MethodName
			end
		end
	end
end

--[=[
	Calls each Object's `MethodName` (or calls the Object if `MethodName == true`) and removes them from the Janitor. Also clears the namespace.
	This function is also called when you call a Janitor Object (so it can be used as a destructor callback).

	```lua
	Obliterator:Cleanup() -- Valid.
	Obliterator() -- Also valid.
	```

	```ts
	Obliterator.Cleanup()
	```
]=]
function Janitor:Cleanup()
	if not self.CurrentlyCleaning then
		self.CurrentlyCleaning = nil

		local Get = GetFenv(self)
		local Object, MethodName = Get()

		while Object and MethodName do -- changed to a while loop so that if you add to the janitor inside of a callback it doesn't get untracked (instead it will loop continuously which is a lot better than a hard to pindown edgecase)
			if MethodName == true then
				Object()
			else
				local ObjectMethod = Object[MethodName]
				if ObjectMethod then
					ObjectMethod(Object)
				end
			end

			self[Object] = nil
			Object, MethodName = Get()
		end

		local This = self[IndicesReference]
		if This then
			table.clear(This)
			self[IndicesReference] = {}
		end

		self.CurrentlyCleaning = false
	end
end

--[=[
	Calls [Janitor.Cleanup](#Cleanup) and renders the Janitor unusable.

	:::warning
	Running this will make any attempts to call a function of Janitor error.
	:::
]=]
function Janitor:Destroy()
	self:Cleanup()
	table.clear(self)
	setmetatable(self, nil)
end

Janitor.__call = Janitor.Cleanup

--[=[
	A wrapper for an `RBXScriptConnection`. Makes the Janitor clean up when the instance is destroyed. This was created by Corecii.

	@class RbxScriptConnection
	@__index RbxScriptConnection
]=]
local RbxScriptConnection = {}
RbxScriptConnection.Connected = true
RbxScriptConnection.__index = RbxScriptConnection

--[=[
	Disconnects the Signal.
]=]
function RbxScriptConnection:Disconnect()
	if self.Connected then
		self.Connected = false
		self.Connection:Disconnect()
	end
end

function RbxScriptConnection._new(RBXScriptConnection: RBXScriptConnection)
	return setmetatable({
		Connection = RBXScriptConnection;
	}, RbxScriptConnection)
end

function RbxScriptConnection:__tostring()
	return "RbxScriptConnection<" .. tostring(self.Connected) .. ">"
end

type RbxScriptConnection = typeof(RbxScriptConnection._new(game:GetPropertyChangedSignal("ClassName"):Connect(function() end)))

--[=[
	"Links" this Janitor to an Instance, such that the Janitor will `Cleanup` when the Instance is `Destroyed()` and garbage collected.
	A Janitor may only be linked to one instance at a time, unless `AllowMultiple` is true. When called with a truthy `AllowMultiple` parameter,
	the Janitor will "link" the Instance without overwriting any previous links, and will also not be overwritable.
	When called with a falsy `AllowMultiple` parameter, the Janitor will overwrite the previous link which was also called with a falsy `AllowMultiple` parameter, if applicable.

	```lua
	local Obliterator = Janitor.new()

	Obliterator:Add(function()
		print("Cleaning up!")
	end, true)

	do
		local Folder = Instance.new("Folder")
		Obliterator:LinkToInstance(Folder)
		Folder:Destroy()
	end
	```

	```ts
	import { Janitor } from "@rbxts/janitor";

	const Obliterator = new Janitor();
	Obliterator.Add(() => print("Cleaning up!"), true);

	{
		const Folder = new Instance("Folder");
		Obliterator.LinkToInstance(Folder, false);
		Folder.Destroy();
	}
	```

	This returns a mock `RBXScriptConnection` (see: [RbxScriptConnection](#RbxScriptConnection)).

	@param Object Instance -- The instance you want to link the Janitor to.
	@param AllowMultiple? boolean -- Whether or not to allow multiple links on the same Janitor.
	@return RbxScriptConnection -- A pseudo RBXScriptConnection that can be disconnected to prevent the cleanup of LinkToInstance.
]=]
function Janitor:LinkToInstance(Object: Instance, AllowMultiple: boolean?): RbxScriptConnection
	local Connection
	local IndexToUse = AllowMultiple and newproxy(false) or LinkToInstanceIndex
	local IsNilParented = Object.Parent == nil
	local ManualDisconnect = setmetatable({}, RbxScriptConnection)

	local function ChangedFunction(_DoNotUse, NewParent)
		if ManualDisconnect.Connected then
			_DoNotUse = nil
			IsNilParented = NewParent == nil

			if IsNilParented then
				task.defer(function()
					if not ManualDisconnect.Connected then
						return
					elseif not Connection.Connected then
						self:Cleanup()
					else
						while IsNilParented and Connection.Connected and ManualDisconnect.Connected do
							task.wait()
						end

						if ManualDisconnect.Connected and IsNilParented then
							self:Cleanup()
						end
					end
				end)
			end
		end
	end

	Connection = Object.AncestryChanged:Connect(ChangedFunction)
	ManualDisconnect.Connection = Connection

	if IsNilParented then
		ChangedFunction(nil, Object.Parent)
	end

	Object = nil :: any
	return self:Add(ManualDisconnect, "Disconnect", IndexToUse)
end

--[=[
	Links several instances to a new Janitor, which is then returned.

	@param ... Instance -- All the Instances you want linked.
	@return Janitor -- A new Janitor that can be used to manually disconnect all LinkToInstances.
]=]
function Janitor:LinkToInstances(...: Instance)
	local ManualCleanup = Janitor.new()
	for _, Object in ipairs({...}) do
		ManualCleanup:Add(self:LinkToInstance(Object, true), "Disconnect")
	end

	return ManualCleanup
end

--[=[
	Instantiates a new Janitor object.
	@return Janitor
]=]
function Janitor.new()
	return setmetatable({
		CurrentlyCleaning = false;
		[IndicesReference] = nil;
	}, Janitor)
end

export type Janitor = typeof(Janitor.new())
return Janitor