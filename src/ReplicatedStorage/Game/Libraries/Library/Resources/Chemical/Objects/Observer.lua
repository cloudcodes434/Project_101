local RootFolder = script.Parent.Parent
local ObjectsFolder = RootFolder.Objects
local PackagesFolder = RootFolder.Packages

local LinkedList = require(PackagesFolder.LinkedList)
local ECS = require(PackagesFolder.ECS)

local World = require(RootFolder.World)
local ValueClass = require(ObjectsFolder.Value)

local Data = World.Data
local Value = World.Components.Value
local Object = World.Components.Object
local Observer = World.Tags.Observer
local Chemical = World.Tags.Chemical
local Callbacks = World.Components.Callbacks
local Cleanup = World.Components.Cleanup
local ScopeTag = World.Tags.ScopeTag
local DependentOn = World.Tags.DependentOn

local module = {}

local function getObserver(chemical: Value | Computed): Observer
	local existingObserver = Data:get(Observer, ECS.pair(DependentOn, chemical.__entity))
	return existingObserver and Data:get(existingObserver, Object) or nil
end

local ObserverMethods = {
	onChange = function(self, callback)
		local callbacks = Data:get(self.__entity, Callbacks)
		callbacks:InsertBack(callback)

		return function()
			if not self or not self.__entity then return end
			callbacks:Remove(callback)
		end
	end,
	destroy = function(self)
		local callbacks = Data:get(self.__entity, Callbacks)
		callbacks:Destroy()
		Data:remove(self.__entity, Callbacks)
		Data:delete(self.__entity)
		setmetatable(self, nil)
		table.clear(self)
	end,
}; ObserverMethods.__index = ObserverMethods

return function (subject: Computed | Value): Observer
	local existingObserver = getObserver(subject)
	if existingObserver then return existingObserver end
	
	local observerE = Data:entity()
	local observerObject = setmetatable({
		__entity = observerE,
		__subject = subject.__entity,
	}, ObserverMethods)
	Data:set(observerE, Object, observerObject)
	Data:add(observerE, Observer)
	Data:add(observerE, Chemical)

	Data:add(observerObject.__entity, ECS.pair(DependentOn, subject.__entity))
	Data:set(observerE, Callbacks, LinkedList.new())

	return observerObject
end