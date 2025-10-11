--// Services -- \\ 
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage") 


local GameFolder = ReplicatedStorage:WaitForChild("Game")
local Libraries = GameFolder:WaitForChild("Libraries")


local Library = require(Libraries:WaitForChild("Library"))


local Enmy_Rig = ServerStorage.Enmies

local Service = { }


function Service:Enmy_Spawn_Location()
 
end 

function Service:Start()
    for _, v in ipairs(Enmy_Rig:GetChildren()) do 
       print(v.Name)
    end
end