-- // Services -- \\
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Controllers = script:WaitForChild("Controllers")
local MadworkClient = ReplicatedStorage:WaitForChild("MadworkClient")

local Library = require(ReplicatedStorage.Game.Libraries.Library)
local ReplicaController = require(MadworkClient.ReplicaController)

for _, v in ipairs(script.Components:GetChildren()) do
	if v:IsA("ModuleScript") then
		task.spawn(require(v))
	end
end

Library:Init(Controllers):andThen(function()
	Library:InitDataLoad()
	ReplicaController.RequestData()
	Library:Fire("LoadedData", nil)
end)
