local Dependency = require(script.Parent.Parent.Dependency)
local World = require(script.Parent.Parent.World)

local Data = World.Data
local Value = World.Components.Value
local OldValue = World.Components.OldValue
local Chemical = World.Tags.Chemical
local Object = World.Components.Object

local module = {}

local ValueMethods = {
	get = function(self)
		Dependency.track(self.__entity)
		return Data:get(self.__entity, Value)
	end,
	set = function(self, value)
		local cachedValue = Data:get(self.__entity, Value)
		if value == cachedValue then return end
		
		Data:set(self.__entity, OldValue, cachedValue)
		Data:set(self.__entity, Value, value)
	end,
	key = function(self, key, value)
		local tbl = Data:get(self.__entity, Value)
		tbl[key] = value
		
		Data:set(self.__entity, Value, tbl)
	end,
	insert = function(self, value, keyValue)
		local tbl = Data:get(self.__entity, Value)
		table.insert(tbl, value)
		
		Data:set(self.__entity, Value, tbl)
	end,
	remove = function(self, value)
		local tbl = Data:get(self.__entity, Value)
		local index = table.find(tbl, value)
		if index then table.remove(tbl, index)
		else return	end

		Data:set(self.__entity, Value, tbl)
	end,
	toggle = function(self, value)
		if value == Data:get(self.__entity, Value) then return end

		Data:set(self.__entity, Value, value)
		Data:set(self.__entity, Value, not value)
	end,
	destroy = function(self)
		Data:delete(self.__entity)
		setmetatable(self, nil)
		table.clear(self)
	end,
}; ValueMethods.__index = ValueMethods

local ValueMethodsProtected = {
	key = function(self, value)
		warn("A Value attempted to use key on a non-table.")
	end,
	
	insert = function(self, value)
		warn("A Value attempted to insert into a non-table.")
	end,
	
	remove = function(self, value)
		warn("A Value attempted to remove from a non-table.")
	end,

	toggle = function(self, value)
		warn("A Value attempted to toggle a non-boolean.")
	end,
}

local function new<T>(default: T): Value<T>
	local valueE = Data:entity()
	local valueObject = setmetatable({
		__entity = valueE,
		get = ValueMethods.get, -- Explicitly expose get
		set = ValueMethods.set, -- And set, for some reason it bugged if i didnt do this... still debugging
		destroy = ValueMethods.destroy
	}, ValueMethods)
	if typeof(default) ~= "table" then 
		valueObject.key = ValueMethodsProtected.key; valueObject.insert = ValueMethodsProtected.insert; valueObject.remove = ValueMethodsProtected.remove; 
	end
	if typeof(default) ~= "boolean" then valueObject.toggle = ValueMethodsProtected.toggle end

	Data:set(valueE, Object, valueObject)

	Data:set(valueE, Value, default)
	Data:add(valueE, Chemical)

	return valueObject
end

return new
