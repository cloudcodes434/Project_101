local RootFolder = script.Parent.Parent
local ObjectsFolder = RootFolder.Objects

local ECS = require(RootFolder.Packages.ECS)

local World = require(RootFolder.World)
local Dependency = require(RootFolder.Dependency)
local ObserverObject = require(RootFolder.Objects.Observer)

local Data = World.Data
local Object = World.Components.Object
local Chemical = World.Tags.Chemical
local DependentOn = World.Tags.DependentOn

return function (target: () -> ({}, string), callback: (new: any?, old: any?) -> ())
	local watchE = Data:entity()
	Data:add(watchE, Chemical)

	Dependency.scope(watchE)
	local _, key = target()
	Dependency.scope(nil)
	
	local subject = Data:target(watchE, DependentOn)
	if not subject then error("Could not locate the dependency between Watch subject and Watch.") end

	local disconnect = ObserverObject(Data:get(subject, Object)):onChange(function(new, old)
		if old == nil then old = {} end
		if new[key] == old[key] then return end
		
		callback(new[key], old[key])
	end)

	return function()
		disconnect()
		
		Data:delete(watchE)
	end
end

