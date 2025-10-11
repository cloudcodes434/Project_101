local ECS = require(script.Parent.Packages.ECS)

local module = {}

export type Value<T> = {
	__entity: ECS.Entity,

	get: (Value<T>) -> (T),
	set: (Value<T>, T) -> (),
	toggle: (Value<T>, boolean) -> (),
	key: (Value<T>, key: any, any) -> (),
	insert: (Value<T>, any) -> (),
	remove: (Value<T>, any) -> (),
	destroy: (Value<T>) -> (),
}
export type ValueConstructor = <T>(value: T) -> (Value<T>)

export type Computed<T> = {
	__entity: ECS.Entity,

	get: (Computed<T>) -> (T),
	destroy: (Computed<T>) -> (),
}
export type ComputedConstructor = <T>(func: () -> (T), cleanup: (T) -> ()?) -> (Computed<T>)

export type Reaction<T> = {
	destroy: (Reaction<T>) -> ()
} & T
export type ReactionConstructor = ((key: string) -> ( { [string]: any } )) & (<T>(key: string, state: T) -> ( Reaction<T> ))

export type Observer = {
	__entity: ECS.Entity,
	__subject: ECS.Entity,

	onChange: (Observer, callback: (new: any?, old: any?) -> ()) -> (),
	destroy: (Observer) -> (),
}
export type ObserverConstructor = (chemical: Value | Computed) -> Observer

export type Watch = (target: () -> ({}, string), callback: (new: any?, old: any?) -> ()) -> ()

export type ChemicalObject = Value<any> | Computed<any> | Observer


export type ValueType = 
	"Any" | "Nil" | "NumberS8" | "NumberS16" | "NumberS24" | "NumberS32" |
"NumberU8" | "NumberU16" | "NumberU24" | "NumberU32" | "NumberF16" |
"NumberF24" | "NumberF32" | "NumberF64" | "String" | "Buffer" | "Instance" |
"Boolean8" | "NumberRange" | "BrickColor" | "Color3" | "UDim" | "UDim2" |
"Rect" | "Vector2S16" | "Vector2F24" | "Vector2F32" | "Vector3S16" |
"Vector3F24" | "Vector3F32" | "NumberU4" | "BooleanNumber" | "Boolean1" |
"CFrameF24U8" | "CFrameF32U8" | "CFrameF32U16" | "Region3" | "NumberSequence" |
"ColorSequence" | "EnumItem" | "Characters"

local characters = {[0] = -- Recommended character array lengths: 2, 4, 8, 16, 32, 64, 128, 256
	" ", ".", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D",
	"E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T",
	"U", "V", "W", "X", "Y", "Z", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j",
	"k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
}

function module.Guess(value: any): string
	local valueType = typeof(value)

	-- Special nil case
	if value == nil then return "Nil" end

	-- Roblox object types
	if valueType == "userdata" then
		if value:IsA("NumberSequence") then return "NumberSequence" end
		if value:IsA("ColorSequence") then return "ColorSequence" end
		if value:IsA("BrickColor") then return "BrickColor" end
		if value:IsA("UDim") then return "UDim" end
		if value:IsA("UDim2") then return "UDim2" end
		if value:IsA("NumberRange") then return "NumberRange" end
		if value:IsA("Rect") then return "Rect" end
		if value:IsA("Region3") then return "Region3" end
		if value:IsA("CFrame") then
			return "CFrame" -- Fallback
		end
		if value:IsA("Vector3") then
			-- Check if components are integers
			if math.floor(value.X) == value.X and
				math.floor(value.Y) == value.Y and
				math.floor(value.Z) == value.Z then
				return "Vector3S16"
			end
			return "Vector3F32"
		end
		if value:IsA("Vector2") then
			if math.floor(value.X) == value.X and
				math.floor(value.Y) == value.Y then
				return "Vector2S16"
			end
			return "Vector2F32"
		end
		if value:IsA("EnumItem") then return "EnumItem" end
	end

	-- Special table formats
	if valueType == "table" then
		-- Boolean1 (8 booleans)
		if #value == 8 and typeof(value[1]) == "boolean" then
			return "Boolean1"
		end

		-- NumberU4 (two 4-bit numbers)
		if #value == 2 and value[1] >= 0 and value[1] <= 15 and
			value[2] >= 0 and value[2] <= 15 then
			return "NumberU4"
		end

		-- BooleanNumber format
		if value.Boolean ~= nil and value.Number ~= nil then
			return "BooleanNumber"
		end

		---- Static tables
		--if table.find(statics, value) then
		--	if table.find(statics[1], value) then return "Static1" end
		--	if table.find(statics[2], value) then return "Static2" end
		--	if table.find(statics[3], value) then return "Static3" end
		--end
	end

	-- String types
	if valueType == "string" then
		if #value > 0 and characters[string.sub(value, 1, 1)] then
			return "Characters"
		end
		return "String"
	end

	-- Number types
	if valueType == "number" then
		if value ~= value then return "NumberF32" end -- NaN

		if value % 1 == 0 then -- Integer type
			if value >= -128 and value <= 127 then return "NumberS8" end
			if value >= 0 and value <= 255 then return "NumberU8" end
			if value >= -32768 and value <= 32767 then return "NumberS16" end
			if value >= 0 and value <= 65535 then return "NumberU16" end
			if value >= -8388608 and value <= 8388607 then return "NumberS24" end
			if value >= 0 and value <= 16777215 then return "NumberU24" end
			return "NumberS32"
		else -- Floating point
			local absVal = math.abs(value)
			if absVal <= 65504 then return "NumberF16" end
			if absVal <= 16777216 then return "NumberF24" end
			if absVal <= 3.4028235e38 then return "NumberF32" end
			return "NumberF64"
		end
	end

	-- Remaining basic types
	if valueType == "boolean" then return "Boolean8" end
	if valueType == "buffer" then return "Buffer" end
	if valueType == "Instance" then return "Instance" end

	-- Fallback for unknown types
	return "Any"
end

return module
