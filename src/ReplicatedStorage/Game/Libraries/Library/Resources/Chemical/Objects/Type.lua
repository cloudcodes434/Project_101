local RootFolder = script.Parent.Parent
local ObjectsFolder = RootFolder.Objects

local Types = require(RootFolder.Types)
local World = require(RootFolder.World)

local Data = World.Data
local Type = World.Components.Type

--Not in use just yet, will be in the future.
return function(chemical: Chemical, valueType: Types.ValueType)
	Data:set(chemical.__entity, Type, valueType)
	return chemical
end
