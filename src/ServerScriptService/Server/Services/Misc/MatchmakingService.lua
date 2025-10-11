
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

function Service.JoinParty(Player: Player, zoneIndex: number)
    local ZoneInfo = Zones[zoneIndex] :: Party

    if ZoneInfo.Owner == "None" then
        ZoneInfo.Owner = Player.Name
        --> Prompts player selection
    end
end

function Service.CanJoin(zoneIndex: number): boolean
    local ZoneInfo: Party = Zones[zoneIndex]
    if ZoneInfo.Owner == "None" then
        return true
    end

    local ownerUser = Players:FindFirstChild(ZoneInfo.Owner)
    if not ownerUser then
        return false
    end


end
function Service.CreateZone(colliderPart: BasePart)
    local zoneIndex = tonumber(colliderPart.Name)
    Zones[zoneIndex] = {
        Players = {},
        Owner = "Invalid",
        Info = Service.PartyService.slideDefaultPartySettings()
    }

    local ZoneContainer = ZonePlus.new(colliderPart)

    ZoneContainer.playerEntered:Connect(function(player: Player)
        print(string.format("%s has entered", player.Name))

        if Service.CanJoin(zoneIndex) then
            Service.JoinParty(player, zoneIndex)
        end
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
