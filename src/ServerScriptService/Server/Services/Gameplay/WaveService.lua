
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

function Service.ReturnWaveStage(): number
    return 1
end

function Service:Start()
   
end

return Service
