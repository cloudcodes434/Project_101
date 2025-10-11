
-- // Services -- \\
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // Variables -- \\ 
local GameFolder = ReplicatedStorage:WaitForChild("Game")
local Libraries = GameFolder:WaitForChild("Libraries")
-- // Modules -- \\
local Library = require(Libraries:WaitForChild("Library"))
local Service = {}

function Service:Spawn()
    
end

function Service.GetWave(): number
    return Service.WaveService:ReturnWaveStage()
end

function Service:Start()
    Service.WaveService = Library:GetService("WaveService", true)
end

return Service
