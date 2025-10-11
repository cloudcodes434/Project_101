local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local GameFolder = ReplicatedStorage:WaitForChild("Game")
local Libraries = GameFolder:WaitForChild("Libraries")
local Packages = Libraries:WaitForChild("Packages")

local ServerFramework = ServerScriptService:WaitForChild("Server")
local MadworkServer = ServerFramework:WaitForChild("MadworkServer")

-- // Modules
local Signal = require(Packages.Signal)
local Promise = require(Packages.Promise)
local Library = require(Libraries:WaitForChild("Library"))
local ReplicaService = require(MadworkServer:WaitForChild("ReplicaService"))
local ProfileService = require(MadworkServer:WaitForChild("ProfileService"))

-- // Data Template
local DataTemplate = Library.Modules.Data["Template"]
local GlobalDataVersion = Library.Modules.Data["Version"]

-- Constants
local PLAYER_PROFILE_TOKEN = ReplicaService.NewClassToken("PlayerProfile")

local ProfileStore = ProfileService.GetProfileStore(GlobalDataVersion, DataTemplate)

-- Lists & Tables
local Profiles = {}
local DataReplicas = {}
local Listeners = {}

local DataService = {}

DataService.ProfileLoaded = Signal.new()

local function DeepCopy(tbl, copies)
	copies = copies or {} -- Keep track of copied tables to handle circular references

	if type(tbl) ~= "table" then
		return tbl
	elseif copies[tbl] then
		return copies[tbl]
	end

	local copy = {}
	copies[tbl] = copy

	for key, value in pairs(tbl) do
		copy[DeepCopy(key, copies)] = DeepCopy(value, copies)
	end

	return copy
end

local function PlayerAdded(player: Player)
	local playerProfile = ProfileStore:LoadProfileAsync("Player_" .. player.UserId, "ForceLoad")

	if playerProfile ~= nil then
		-- Player Profile Could Be Loaded
		playerProfile:ListenToRelease(function()
			Profiles[player] = nil
			DataReplicas[player] = nil
		end)

		if player:IsDescendantOf(Players) then
			playerProfile:Reconcile()
			Profiles[player] = playerProfile

			local DataReplica = ReplicaService.NewReplica({
				ClassToken = PLAYER_PROFILE_TOKEN,
				Data = playerProfile.Data,
				Tags = { Player = player },
				Replication = "All",
			})
			DataReplicas[player] = DataReplica
			print(DataReplica)
			DataService.ProfileLoaded:Fire(player, playerProfile)
		else
			playerProfile:Release()
		end
	else
		-- Player Profile Could Not Be Loaded
		player:Kick("Unable to load your data. Please Rejoin!")
	end
end

local function PlayerRemoved(player: Player)
	local playerProfile = Profiles[player]

	if playerProfile then
		playerProfile:Release()
	end
end

local function FetchData(self, player)
	return Promise.new(function(resolve)
		local connection
		connection = self.ProfileLoaded:Connect(function(loadedPlayer, loadedProfile)
			if player == loadedPlayer then
				loadedPlayer:SetAttribute("DataLoaded", true)
				connection:Disconnect()
				resolve(loadedProfile.Data)
			end
		end)
	end)
end

function DataService:SetStats(player: Player, Stat: string, Amount: number)
	
end



function DataService:GetData(player: Player, ignoreQueue)
	local playerProfile = Profiles[player]
	if not player:IsDescendantOf(Players) then
		return nil
	end

	if playerProfile or ignoreQueue then
		if ignoreQueue and not playerProfile then
			return
		end
		return playerProfile.Data
	else
		local state, data = FetchData(self, player):await()
		return data
	end
end

-- Sets A Particular Key To Given Data
function DataService:SetData(player: Player, path, newValue)
	local playerData = self:GetData(player)
	local dataReplica = DataReplicas[player]

	if not playerData or not dataReplica then return end

	if type(path) == "string" then
		path = {path}
	end

	dataReplica:SetValue(path, newValue)
	local lastKey = path[#path]
	if Listeners[player] and Listeners[player][lastKey] then
		for _, func in ipairs(Listeners[player][lastKey]) do
			task.spawn(func, newValue)
		end
	end
end

-- Update a Key
function DataService:Update(player: Player, path, callback)
	local playerData = self:GetData(player)
	local value = playerData
	if playerData then
		if type(path) == "string" then
			value = playerData[path]
		else
			for i = 1, #path do
				value = value[path[i]]
			end
		end

		local newData = callback(value)

		self:SetData(player, path, newData)
	end
end

function DataService:ListenForChange(player: Player, key: string, func)
	Listeners[player] = Listeners[player] or {}
	Listeners[player][key] = Listeners[player][key] or {}
	table.insert(Listeners[player][key], func)
end

function DataService:Start()
	-- If A Player Loads, Pre-KnitStart
	for _, player in pairs(Players:GetPlayers()) do
		if not Profiles[player] then
			PlayerAdded(player)
		end
	end

	-- Setup
	Players.PlayerAdded:Connect(PlayerAdded)
	Players.PlayerRemoving:Connect(PlayerRemoved)
end

return DataService
