-- // Services -- \\
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Services = script:WaitForChild("Services")

local Library = require(ReplicatedStorage.Game.Libraries.Library)
Library:Init(Services):andThen(function()
	Library:Debug("Game has loaded")
end)