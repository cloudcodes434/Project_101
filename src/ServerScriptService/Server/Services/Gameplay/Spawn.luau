--// Services -- \\ 
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage") 


local GameFolder = ReplicatedStorage:WaitForChild("Game")
local Libraries = GameFolder:WaitForChild("Libraries")
local Library = require(Libraries:WaitForChild("Library"))

local Enemy_Folder = ServerStorage:WaitForChild("Enemies") 
local Enemy_Spawn = workspace:WaitForChild("Enemy_Spawn") 
local S_1 = Enemy_Spawn.Spawn_1



local Service = { }


function Service:Enmy_Spawn_Location()
    local enemies = Enemy_Folder:GetChildren() 
    if #enemies == 0 then 
        warn("There's no enemies, found") 
        return 
    end  

    local chosen = enemies[math.random(1, #enemies)]:Clone()

    local SpawnCFrame = S_1.CFrame + Vector3.new(0, 3, 0) 

    if chosen.PrimaryPart then 
        chosen:SetPrimaryPartCFrame(SpawnCFrame) 
    else 
        warn("NPC has no root") 
    end  

    chosen.Parent = workspace 
    print(chosen.Name .. "Spawned At " .. S_1.Name)
end

function Service:Start()
    self:Enmy_Spawn_Location()
end

return Service