local RootFolder = script.Parent
local ObjectsFolder = RootFolder.Objects

local ECS = require(RootFolder.Packages.ECS)

local World = require(RootFolder.World)

local Data = World.Data
local DependentOn = World.Tags.DependentOn

local module = {}

local current_scope = nil

function module.track(entity: ECS.Entity)
	if not current_scope then return end
	
	Data:add(current_scope, ECS.pair(DependentOn, entity))
end

function module.scope(entity: ECS.Entity?)
	current_scope = entity
end

return module
