--EXAMPLES AT THE BOTTOM

--Brief Documentation
--[[
	local number = Value(0)
	
	local numberPlusOne = Computed(function() -- A computed can contain any number of Value or Computed objects
		return number:get() + 1
	end)
	
	print(numberPlusOne:get()) -- 1
	
	number:set(1)
	
	print(numberPlusOne:get()) -- 2
	
	number:destroy()
	
	print(numberPlusOne:get()) -- ERROR, the computed was cleaned because its dependency no longer exists.
]]

--[[
	Version 0.4
	
	local number = Value(0)

	Observer(number) --Observers can observe Value and Computed objects
		:onChange(function() print(number:get()) end)
		
	number:set(1)
	--print 1
	
	number:set(3)
	--print 3
]]

--[[
	In Version 0.6, the Give function has been introduced.
	
	This function can also be called Hydrate/Infuse.
	What does it do?
	Provided a GuiElement, it returns a function which accepts intellisense supported properties of said GuiElement.
	Give, aka Infuse, will bind Chemical Objects to the GuiElement's property, approriately changing it
	when the Computed/Value changes.
	
	You can use a Chemical Objects initiated outside of the Infuse to bind it to a property within Infuse.
	Once Infuse and its returned function are called, a table of methods is provided; destroy and disconnect.
	disconnect will only unbind these Chemical Objects.
	destroy will, as it says, unbind and destroy the Chemical objects as well as the GuiObject and its children.
	
	Give(someFrame) {
		Transparency = Computed(function()
			return isOpen:get() and 0 or 1
		end)
	}
	
	Upon binding, it will retrieve the computed value and apply it to the property.
	Subsequent changes will propagate when the computed is recomputed.
]]

--[[
	Introduced in Version 0.7, expanded in v0.8, the Create functionality.
	As well, both Give and Create have access to GuiObject traits; onEvent, Ref, and onChange.
	
	The key difference between Give and Create is that Create will create a new GuiObject from scratch.
	You may provide static properties or Chemical Object properties.
	You may also provide Children, though these must be other Create()'d children.
	They will be automatically parented to the root GuiObject.
	
	Just like Give, Create returns the same methods which do the same functionality, 
	though in v0.7, both Give and Create will also disconnect event connections.
	
	Create("Frame") {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromScale(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		
		Visible = showFrame, --Value Object
		
		[onChange "Visible"] = print, --Both onChange and onEvent can either be a ValueObject or a function! 
										In the event of Value Object, for onEvent,
										the arguement sent will always be a single true boolean.
		
		BackgroundColor3 = Computed(function()  
			return stage:get() > 2 and Color3.fromRGB(1, 1, 1) or Color3.fromRGB(255, 255, 255)
		end),
		
		Children = {
			Create("TextButton") {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 0.9,
				
				[onEvent "MouseEnter"] = function()
					print('entered')
				end,
				
				[Ref] = someValueObject --So that we can save a reference to the newly created TextButton nested within our frame.
			}
		},
		
		Parent = CultivationStats,
	} --Returns the frame instance
]]


--Reaction
--[[
	Updated in v0.0.9 -> Rewrite internally as well as major optomization improvements through deeper tokening.
	
	Reaction is a unique method to Chemical. It allows for the automated replication of Chemical objects as well as initial replication for static values.
	
	In its easiest form, Reaction needs a key. This key is what will be used to identify and sync the state from server to client.
	The next arguement, only on the server, is the state value of the reaction. This can be any form of data.
	
	Everything will be tokenized and interpreted internally, so don't worry about that.
	
	I recommend creating a type file for your Reaction because, while the server has automatic intellisense, the client would not otherwise have type support.
]]
local Chemical = require(script.Parent)

local Value = Chemical.Value
local Computed = Chemical.Computed
local Observer = Chemical.Observer
local Reaction = Chemical.Reaction

export type Type = Chemical.Reaction<{
	Instance: Player,

	CharacterName: Chemical.Value<string>,
	Age: Chemical.Value<number>,
	Lifespan: Chemical.Value<number>,

	Cultivation: {
		Qi: Chemical.Value<number>,

		Dao: Chemical.Value<number>,
	},
}>


return function(player: Player): Type
	if game:GetService("RunService"):IsServer() then

		local Name = Value("")
		local Age = Value(0)
		local Lifespan = Value(99)

		local state = {
			Instance = player,

			CharacterName = Name,
			Age = Age,
			Lifespan = Lifespan,

			Cultivation = {
				Qi = Value(1),
				Dao = Value(1),
			},

		}

		return Reaction(tostring(player.UserId), state)
	else
		return Reaction(tostring(player.UserId))
	end
end