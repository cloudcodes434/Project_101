local RootFolder = script.Parent
local ObjectsFolder = RootFolder.Objects
local PackagesFolder = RootFolder.Packages

local World = require(RootFolder.World)
local ObserverClass = require(ObjectsFolder.Observer)

local Data = World.Data
local Value = World.Components.Value
local Object = World.Components.Object
local Observer = World.Tags.Observer
local Computed = World.Tags.Computed
local Chemical = World.Tags.Chemical
local Callbacks = World.Components.Callbacks
local Cleanup = World.Components.Cleanup
local ScopeTag = World.Tags.ScopeTag
local DependentOn = World.Tags.DependentOn

local module = {}

local BIT = {
	VALUE = 2 ^ 0,
	COMPUTED = 2 ^ 1,
	OBSERVER = 2 ^ 2,
	EVENT = 2 ^ 3,
	REF = 2 ^ 4,
	CHANGE = 2 ^ 5,
}

local function isValue(obj: any): boolean
	return if typeof(obj) == "table" and obj.__entity then Data:has(obj.__entity, Value) else false
end

local function isComputed(obj: any): boolean
	return if typeof(obj) == "table" and obj.__entity then Data:has(obj.__entity, Computed) else false
end

local function isObserver(obj: any): boolean
	return if typeof(obj) == "table" and obj.__entity then Data:has(obj.__entity, Observer) else false
end

module.Ref = { T = BIT.REF, P = nil }

function module.onChange(property: string | Observer)
	--if isValue(property) or isComputed(property) then return ObserverClass(property) end
	return { T = BIT.CHANGE, P = property }
end

function module.onEvent(event: string)
	return { T = BIT.EVENT, P = event }
end

local TRAIT_HANDLERS = {
	[BIT.REF] = function(element: Instance, _, value: Value)
		if not isValue(value) then
			warn("Ref must be a Value object")
			return
		end
		value:set(element)
	end,

	[BIT.EVENT] = function(element: Instance, event: string, callback: any)
		if isValue(callback) then
			element[event]:Connect(function()
				callback:set(true)
			end)
		elseif typeof(callback) == "function" then
			element[event]:Connect(callback)
		else
			warn("onEvent requires function or Value object")
		end
	end,

	[BIT.CHANGE] = function(element: Instance, property: string, callback: any)

		if isValue(callback) then
			local signal = element:GetPropertyChangedSignal(property)
			signal:Connect(function()
				callback:set(element[property])
			end)
		elseif typeof(callback) == "function" then
			if isValue(property) or isComputed(property) then
				ObserverClass(property):onChange(function(new, old)
					callback(new, old)
				end)
			else
				local signal = element:GetPropertyChangedSignal(property)
				signal:Connect(function()
					callback(element[property])
				end)
			end
		else
			warn("onChange requires function or Value object")
		end
	end,

	Children = function(element: GuiObject, children: any)
		if isValue(children) or isComputed(children) then
			local function updateChildren(newChildren: {Instance})
				--for _, child in ipairs(element:GetChildren()) do
				--	if not table.find(newChildren, child) then
				--		child:Destroy()
				--	end
				--end

				for _, child in ipairs(newChildren) do
					child.Parent = element
				end
			end

			local observer = ObserverClass(children)
			observer:onChange(updateChildren)
			updateChildren(children:get())
		elseif type(children) == "table" then
			for _, child in ipairs(children) do
				child.Parent = element
			end
		else
			warn("Children must be table or reactive object")
		end
	end,

	Parent = function(element: Instance, parent: any)
		if isValue(parent) or isComputed(parent) then
			local function updateParent(newParent: Instance?)
				if typeof(newParent) == "Instance" then
					element.Parent = newParent
				end
			end

			local observer = ObserverClass(parent)
			observer:onChange(updateParent)
			updateParent(parent:get())
		elseif typeof(parent) == "Instance" then
			element.Parent = parent
		else
			warn("Parent must be Instance or reactive object")
		end
	end
}

local DEFERRED_PROPERTIES = {"Parent", "Children"}

local function Create(className: string, elementOverride: GuiObject?)
	local element = elementOverride or Instance.new(className)

	return function(properties: {[any]: any})
		local deferred = {}
		local observers = {}

		for propertyKey, value in pairs(properties) do
			if typeof(propertyKey) == "table" and propertyKey.T then
				local handler = TRAIT_HANDLERS[propertyKey.T]
				if handler then
					handler(element, propertyKey.P, value)
				end

				continue
			end

			local propName = propertyKey :: string
			local valueType = typeof(value)

			if isValue(value) or isComputed(value) then
				local function update()
					element[propName] = value:get()
				end

				local observer = ObserverClass(value)
				observer:onChange(update)
				update()
			elseif table.find(DEFERRED_PROPERTIES, propName) then
				deferred[propName] = value
			elseif valueType == "function" then
				element[propName]:Connect(value)
			else
				element[propName] = value
			end
		end

		for _, propName in ipairs(DEFERRED_PROPERTIES) do
			if deferred[propName] then
				TRAIT_HANDLERS[propName](element, deferred[propName])
			end
		end

		return element
	end
end

module.Method = Create

return module
