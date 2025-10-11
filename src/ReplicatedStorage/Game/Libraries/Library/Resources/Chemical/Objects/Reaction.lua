local RunService = game:GetService("RunService")

local RootFolder = script.Parent.Parent

local ECS = require(RootFolder.Packages.ECS)
local Packet = require(RootFolder.Packages.Packet)

if not RootFolder.Configuration.UseReactions.Value then return function() warn("You did not enable Reactions in configuration.") end end

local Construct = Packet("ConstructReaction", Packet.String, Packet.NumberU8, Packet.Any, Packet.Any)
local Deconstruct = Packet("DeconstructReaction", Packet.NumberU8)
local UpdateRoot = Packet("UpdateReactionRoot", Packet.NumberU8, Packet.NumberU8, Packet.Any)
local UpdateNested = Packet("UpdateReactionNested", Packet.NumberU8, Packet.NumberU8, Packet.NumberU8, Packet.Any)
local Ready = Packet("ReadyReaction")
local Hydrate = Packet("Hydrate", Packet.Any, Packet.Any, Packet.Any)

local ValueClass = require(RootFolder.Objects.Value)

local World = require(RootFolder.World)

local Data = World.Data
local Value = World.Components.Value
local Object = World.Components.Object
local Replicated = World.Components.Replicated
local KeyPath = World.Components.KeyPath


local function getChemical(value: any): ECS.Entity | false
	return typeof(value) == "table" and value.__entity
end

local function destroyChemicals(kvs, ignorePatch: boolean?)
	for key, value in kvs do
		local entity = getChemical(value)
		if not entity then if typeof(value) == "table" then destroyChemicals(value, ignorePatch) end continue end
		local object = Data:get(entity, Object)
		if not object then return end
		object:destroy(ignorePatch)
	end
end


local reactionNames = {}
local keyNames = {}

if RunService:IsServer() then
	local rawReactions = {}

	local Server = {}

	Data:set(World.Tags.Replicate, ECS.OnAdd, function(entity)
		local reaction = Data:get(entity, Replicated)
		local keypath = Data:get(entity, KeyPath)
		local value = Data:get(entity, Value)

		Server:Update(reaction, keypath, value)
		Data:remove(entity, World.Tags.Replicate)
	end)

	local function tokenizeName(name: string): number
		local exists = table.find(reactionNames, name) --Fast until reactions exceed 500 entries
		if exists then return exists end

		table.insert(reactionNames, name)
		return #reactionNames
	end

	local function tokenizeKey(key: string): number
		local exists = table.find(keyNames, key) --Fast until reactions exceed 500 entries
		if exists then return exists end

		table.insert(keyNames, key)
		return #keyNames
	end

	local function track(token, e)
		local object = Data:get(e, Object)
		local original = object.destroy
		object.destroy = function(self, ignorePatch: boolean?)
			if ignorePatch then original(object) return end

			local keys = Data:get(e, KeyPath)
			if keys[2] then UpdateNested:Fire(token, keys[1], keys[2], Enum.HumanoidStateType.Dead);
			else UpdateRoot:Fire(token, keys[1], Enum.HumanoidStateType.Dead) end

			original(object)
		end
	end

	local function new(name: string, keyValues: { [string]: any | { [string]: any } })
		local token = tokenizeName(name)
		local keyTokens = {}
		local keyValuesRaw = {}

		for key, value in keyValues do
			keyValuesRaw[key] = value
			if typeof(value) ~= "table" then continue end

			local entity = getChemical(value)
			local keyToken = tokenizeKey(key)

			if entity then
				keyTokens[key] = keyToken
				Data:set(entity, KeyPath, { keyToken })
				Data:set(entity, Replicated, token)
				keyValuesRaw[key] = { V = value:get(), T = true }
				track(token, entity)
			else
				keyValuesRaw[key] = {}
				for nestedKey, nestedValue in value do
					keyValuesRaw[key][nestedKey] = nestedValue
					local nestedEntity = getChemical(nestedValue)
					if not nestedEntity then continue end

					local nKeyToken = tokenizeKey(nestedKey)
					keyTokens[nestedKey] = nKeyToken
					Data:set(nestedEntity, KeyPath, { keyToken, nKeyToken })
					Data:set(nestedEntity, Replicated, token)
					keyValuesRaw[key][nestedKey] = { V = nestedValue:get(), T = true}
					track(token, nestedEntity)
				end
			end
		end

		Construct:Fire(name, token, keyTokens, keyValuesRaw)

		rawReactions[name] = keyValues

		local reaction = table.clone(keyValues)
		reaction.destroy = function(self)
			destroyChemicals(keyValues, true)
			setmetatable(self, nil)
			table.clear(self)
			rawReactions[name] = nil
			Deconstruct:Fire(token)
		end

		return reaction
	end

	function Server:Update(token: number, keys: { number }, value: any)
		if keys[2] then UpdateNested:Fire(token, keys[1], keys[2], value); return end
		UpdateRoot:Fire(token, keys[1], value)
	end

	Ready.OnServerEvent:Connect(function(player: Player)
		local rawKeyValues = {}
		for name, reaction in rawReactions do
			rawKeyValues[name] = {}

			for key, value in reaction do
				if getChemical(value) then
					rawKeyValues[name][key] = { V = value:get(), T = true }
				elseif typeof(value) == "table" then
					rawKeyValues[name][key] = {}
					for nKey, nValue in value do
						if getChemical(nValue) then
							rawKeyValues[name][key][nKey] = { V = nValue:get(), T = true }
						else
							rawKeyValues[name][key][nKey] = nValue
						end
					end
				else
					rawKeyValues[name][key] = value
				end
			end
		end

		Hydrate:FireClient(player, reactionNames, keyNames, rawKeyValues)
	end)

	return new
elseif RunService:IsClient() then
	local awaitReactions = {}

	local reactions = {}

	local function storeKeyTokens(tokens: { [string]: number | { [string]: number } })
		for key, token in tokens do
			if typeof(token) == "table" then
				storeKeyTokens(token)
				continue
			end

			keyNames[token] = key
		end
	end

	local Client = {}

	local function new(name: string)
		if reactions[name] then
			return reactions[name]
		end

		local await = Instance.new("BindableEvent")
		if not awaitReactions[name] then awaitReactions[name] = {} end
		table.insert(awaitReactions[name], await)

		return await.Event:Wait()
	end

	local function construct(name: string, token: number, tokenizedKeys, keyValuesRaw)
		reactionNames[token] = name
		if tokenizedKeys ~= nil then storeKeyTokens(tokenizedKeys) end

		local reaction = {}

		for key, value in keyValuesRaw do
			if typeof(value) == "table" then
				if value.T then
					reaction[key] = ValueClass(value.V)
				else
					reaction[key] = {}
					for nKey, nValue in value do
						if typeof(nValue) == "table" and nValue.T then
							reaction[key][nKey] = ValueClass(nValue.V)
						else
							reaction[key][nKey] = nValue
						end
					end
				end
			else
				reaction[key] = value
			end
		end

		reactions[name] = reaction
		if awaitReactions[name] then
			for _, await in awaitReactions[name] do
				await:Fire(reaction)
				await:Destroy()
			end

			table.clear(awaitReactions[name])
		end
	end
	Construct.OnClientEvent:Connect(construct)

	Deconstruct.OnClientEvent:Connect(function(token: number)  
		local name = reactionNames[token]
		local reaction = reactions[name]
		if not reaction then return end

		destroyChemicals(reaction)
		reactions[name] = nil
		reactionNames[token] = Enum.HumanoidStateType.Dead
	end)

	UpdateRoot.OnClientEvent:Connect(function(token: number, keyToken: number, value: any)
		local name = reactionNames[token]
		local key = keyNames[keyToken]
		local reaction = reactions[name]
		if not reaction then return end

		if value == Enum.HumanoidStateType.Dead then reaction[key]:destroy(); reaction[key] = nil; return end
		reaction[key]:set(value)
	end)

	UpdateNested.OnClientEvent:Connect(function(token: number, keyToken: number, nestedKeyToken: number, value: any)
		local name = reactionNames[token]
		local key = keyNames[keyToken]
		local nestedKey = keyNames[nestedKeyToken]
		local reaction = reactions[name]
		if not reaction then return end


		if value == Enum.HumanoidStateType.Dead then reaction[key][nestedKey]:destroy(); reaction[key][nestedKey] = nil; return end
		reaction[key][nestedKey]:set(value)
	end)

	Hydrate.OnClientEvent:Once(function(reactionTokensAndNames, keyTokensAndNames, rawReactionsAndRawData)
		keyNames = keyTokensAndNames

		for token, name in reactionTokensAndNames do
			if reactions[name] then continue end

			construct(name, token, nil, rawReactionsAndRawData[name])
		end
	end)

	Ready:Fire()

	return new
end
