-- Written By Sovereignty (Discord: sov_dev)
-- undocumented at its current stage
-- VERSION =[0.0.9b]= ALPHA (5/27/2025)
-- Networking is NOT Optomized perfectly just yet. Will add batching and better buffer work in the future.

--Brief Documentation found inside of script.Examples, as well as examples for Reaction.

local Promise = require(script.Packages.Promise)
local ECS = require(script.Packages.ECS)

local World = require(script.World)
local Types = require(script.Types)
local Create = require(script.Create)

local Value = require(script.Objects.Value)
local Computed = require(script.Objects.Computed)
local Observer = require(script.Objects.Observer)
local Reaction = require(script.Objects.Reaction)
local Type = require(script.Objects.Type)
local Watch = require(script.Objects.Watch)

type Chemical = {
	Value: Types.ValueConstructor,
	Computed: Types.ComputedConstructor,
	Observer: Types.ObserverConstructor,
	Reaction: Types.ReactionConstructor,
	Watch: Types.Watch,
	Type: <T>(chemical: T, valueType: Types.ValueType) -> (T),
	Destroy: (thing: World.Destroyable) -> (),

	Await: (chemical: Computed | Value) -> (),
}

export type Value<T> = Types.Value<T>
export type Computed<T> = Types.Computed<T>
export type Observer = Types.Observer
export type Reaction<T> = Types.Reaction<T>


local module = {}

module.Value = Value
module.Computed = Computed
module.Observer = Observer
module.Reaction = Reaction
module.Watch = Watch

module.Type = Type

module.Ref = Create.Ref
module.onChange = Create.onChange
module.onEvent = Create.onEvent
module.Create = Create.Method
module.Give = function<T>(element: T)
	return Create.Method(element.ClassName, element)
end
module.Destroy = World.Destroy

function module.Await(chemical: Value | Computed)
	local observer = Observer(chemical)
	return Promise.new(function(resolve: (...any) -> (), reject: (...any) -> (), onCancel: (abortHandler: (() -> ())?) -> boolean)  
		local disconnect; disconnect = observer:onChange(function()
			disconnect()
			resolve()
		end)
	end):await()
end

local GuiTypes = require(script.Types.Gui)
local TypeOverrides = require(script.Types.Gui.Overrides)
return module :: 
	Chemical & {
	Create: TypeOverrides.CreateFunction,
	Give: TypeOverrides.GiveFunction,

	Ref: {},
	onChange: (property: GuiTypes.PropertyNames | Observer) -> (),
	onEvent: (event: GuiTypes.EventNames) -> (),
}
