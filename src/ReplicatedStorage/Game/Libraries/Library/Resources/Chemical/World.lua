local Packages = script.Parent.Packages

local ECS = require(Packages.ECS)
local LinkedList = require(Packages.LinkedList)

local Data = ECS.world()

local Name: ECS.Entity<string> = ECS.Name
local KeyPath: ECS.Entity<{ number }> = Data:component()
local Callback: ECS.Entity<()->()> = Data:component()
local Callbacks: ECS.Entity<LinkedList.List<() -> ()>> = Data:component()
local Cleanup: ECS.Entity<(T)->()> = Data:component()

local Object: ECS.Entity<Value | Computed | Observer> = Data:component()
local Value: ECS.Entity<any> = Data:component()
local OldValue: ECS.Entity<any> = Data:component()
local Replicated: ECS.Entity<number> = Data:component()
local Type: ECS.Entity<string> = Data:component()
local Element: ECS.Entity<GuiObject> = Data:component()
local Params: ECS.Enity<{any}> = Data:component()

local Computed: ECS.Entity = Data:entity()
local Observer: ECS.Entity = Data:entity()
local Chemical: ECS.Entity = Data:entity()
local Tag: ECS.Entity = Data:entity()
local Replicate: ECS.Entity = Data:entity()
local DependentOn: ECS.Entity = Data:entity()
local ScopeTag = Data:entity()


local module = {
	Tags = {
		Tag = Tag,
		Computed = Computed,
		Observer = Observer,
		Chemical = Chemical,
		DependentOn = DependentOn,
		ScopeTag = ScopeTag,
		Replicate = Replicate
	},
	
	Components = {
		Name = Name,
		KeyPath = KeyPath,
		Callback = Callback,
		Callbacks = Callbacks,
		Cleanup = Cleanup,
		Object = Object,
		Value = Value,
		OldValue = OldValue,
		Replicated = Replicated,
		Type = Type,
		Element = Element,
		Params = Params,
	}
}

Data:set(Value, ECS.OnChange, function(entity, _, value)
	for e in Data:query(ECS.pair(DependentOn, entity)):iter() do
		if Data:has(e, Computed) then
			local oldValue = Data:get(e, Value)
			local newValue = Data:get(e, Callback)()

			if typeof(newValue) == "table" or newValue ~= oldValue then
				if Data:has(e, Cleanup) then Data:get(e, Cleanup)(oldValue) end
				
				Data:set(e, OldValue, oldValue)
				Data:set(e, Value, newValue)
			end
		end

		if Data:has(e, Observer) then
			local callbacks = Data:get(e, Callbacks)
			for _, callback in callbacks:IterateForward() do
				callback(value, Data:get(entity, OldValue))
			end
		end
	end

	if Data:has(entity, Replicated) then
		Data:add(entity, Replicate)
	end
end)

Data:set(Value, ECS.OnRemove, function(entity)
	for e in Data:query(ECS.pair(DependentOn, entity)):iter() do
		local object = Data:get(e, Object)

		object:destroy()
	end
end)

export type Destroyable = Computed | Value | Observer | { destroy: (self: {}) -> () } | Instance | RBXScriptConnection | { Destroyable } | () -> () | thread
function module.Destroy(subject: Destroyable )
	if typeof(subject) == "table" then
		if subject.destroy then
			subject:destroy()
			return 
		end

		if getmetatable(subject) then
			setmetatable(subject, nil)
			table.clear(subject)

			return
		end

		for _, value in subject do
			module.Destroy(value)
		end
	elseif typeof(subject) == "userdata" and subject:IsA("Instance") then
		subject:Destroy()
	elseif typeof(subject) == "RBXScriptConnection" then
		subject:Disconnect()
	elseif typeof(subject) == "function" then
		subject()
	elseif typeof(subject) == "thread" then
		task.cancel(subject)
	end
end

module.JECS = ECS
module.Data = Data

return module