
export type Party = {
    Players: {},
    Owner: string,
    Info: {}
}

-- // Services -- \\
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // Variables -- \\ 
local GameFolder = ReplicatedStorage:WaitForChild("Game")
local Libraries = GameFolder:WaitForChild("Libraries")
local Packages = Libraries:WaitForChild("Packages")

-- // Modules -- \\
local Library = require(Libraries:WaitForChild("Library"))
local ZonePlus = require(Packages:WaitForChild("Zone"))

local Service = {}
local Zones = {
}
function Service.CanJoin(): boolean
    
end
function Service.CreateZone(colliderPart: BasePart)
    Zones[tonumber(colliderPart.Name)] = {
        Players = {},
        Owner = "Invalid",
        Info = Service.PartyService.slideDefaultPartySettings()
    }

    local ZoneContainer = ZonePlus.new(colliderPart)

    ZoneContainer.playerEntered:Connect(function(player: Player)
        print(string.format("%s has entered", player.Name))
    end)
end

function Service:Start()
    Service.PartyService = Library:GetService("PartyService", true)

    for _, ZonePart: BasePart in workspace.Zones:GetChildren() do
        Service.CreateZone(ZonePart)
    end

    print(Zones)
end

return Service
