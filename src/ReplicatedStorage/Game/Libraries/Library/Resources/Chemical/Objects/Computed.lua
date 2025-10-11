local RootFolder = script.Parent.Parent
local ObjectsFolder = RootFolder.Objects

local World = require(RootFolder.World)
local Dependency = require(RootFolder.Dependency)
local ValueClass = require(ObjectsFolder.Value)

local Data = World.Data
local Value = World.Components.Value
local Object = World.Components.Object
local Computed = World.Tags.Computed
local Chemical = World.Tags.Chemical
local Callback = World.Components.Callback
local Cleanup = World.Components.Cleanup
local ScopeTag = World.Tags.ScopeTag

local module = {}

local ComputeMethods = {
	get = function(self)
		Dependency.track(self.__entity)
		return Data:get(self.__entity, Value)
	end,
	destroy = function(self)
		Data:remove(self.__entity, Callback)
		Data:delete(self.__entity)
		setmetatable(self, nil)
		table.clear(self)
	end,
}; ComputeMethods.__index = ComputeMethods

return function <T>(callback: () -> (T), cleanup: (T) -> ()?): Computed<T>
	local computedE = Data:entity()

	local computedObject = setmetatable({
		__entity = computedE,
	}, ComputeMethods)
	Data:set(computedE, Object, computedObject)
	Data:add(computedE, Computed)
	Data:add(computedE, Chemical)
	

	Dependency.scope(computedE)
	Data:set(computedE, Value, callback())
	Dependency.scope(nil)
	
	
	Data:set(computedE, Callback, callback)
	if cleanup then Data:set(computedE, Cleanup, cleanup) end

	return computedObject
end
