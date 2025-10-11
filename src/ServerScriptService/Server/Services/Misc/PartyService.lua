
-- // Services -- \\
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // Variables -- \\ 
local GameFolder = ReplicatedStorage:WaitForChild("Game")
local Libraries = GameFolder:WaitForChild("Libraries")

-- // Modules -- \\
local Library = require(Libraries:WaitForChild("Library"))

local Service = {}
local DefaultPartySettings = {

}

function Service.slideDefaultPartySettings()
    return DefaultPartySettings
end

function Service:Start()
end

return Service
