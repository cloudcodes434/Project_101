--// Services -- \\ 

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage") 
local Debris = game:GetService("Debris")

local GameFolder = ReplicatedStorage:WaitForChild("Game")
local Libraries = GameFolder:WaitForChild("Libraries")
local Library = require(Libraries:WaitForChild("Library"))



local waveConfigureModule = script:WaitForChild("WaveConfig")
local WaveModule = require(waveConfigureModule)

local Enemy_Folder = ServerStorage:WaitForChild("Enemies")
local Wave_1_folder = Enemy_Folder:WaitForChild("Wave_1")  
local Enemy_Spawn = workspace:WaitForChild("Enemy_Spawn")
local NPC_SPAWNED = workspace:WaitForChild("NPC_SPAWNED")

local S_1 = Enemy_Spawn:FindFirstChild("Spawn_1")
local Service = { }

local _NPC_COUNT = 0 

local Wave_Status = { 
    WaveModule.Wave_1, 
    WaveModule.Wave_2
}

local DETECTION_RADIUS = 100
local ATTACK_RANGE = 3
local CHASE_INTERVAL = 0.6 
local CLEANUP_DELAY = 8

local function getNearestPlayerWithin(position, radius)
    local closestPlayer, bestDist = nil, math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        local char = player.Character
        local hrp = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChildWhichIsA("BasePart"))
        if hrp then
            local d = (hrp.Position - position).Magnitude
            if d <= radius and d < bestDist then
                closestPlayer = player
                bestDist = d
            end
        end
    end
    return closestPlayer, bestDist
end

local function hasLineOfSight(fromPos, targetPart, ignoreList)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = ignoreList or {}
    params.IgnoreWater = true

    local direction = targetPart.Position - fromPos
    local result = workspace:Raycast(fromPos, direction, params)
    if not result then
        return true
    end

    return result.Instance and result.Instance:IsDescendantOf(targetPart.Parent)
end

local function attachAI(enemy)
    local humanoid = enemy:FindFirstChildWhichIsA("Humanoid")
    local root = enemy.PrimaryPart or enemy:FindFirstChild("HumanoidRootPart") or enemy:FindFirstChildWhichIsA("BasePart")
    if not humanoid or not root then
        return
    end

    local ignoreList = {enemy, NPC_SPAWNED}

    task.spawn(function()
        while enemy.Parent and humanoid.Health > 0 do
            local player = getNearestPlayerWithin(root.Position, DETECTION_RADIUS)
            if player and player.Character then
                local hrp = player.Character:FindFirstChild("HumanoidRootPart") or player.Character:FindFirstChildWhichIsA("BasePart")
                if hrp and hasLineOfSight(root.Position, hrp, ignoreList) then
                    while enemy.Parent and humanoid.Health > 0 and hrp.Parent and (root.Position - hrp.Position).Magnitude > ATTACK_RANGE do
                        humanoid:MoveTo(hrp.Position)
                        task.wait(CHASE_INTERVAL)
                    end
                end
            end
            task.wait(0.5)
        end
    end)
end

function Service:Enmy_Spawn_Location(waveCfg)
    waveCfg = waveCfg or WaveModule.Wave_1
    local maxN = tonumber(waveCfg._MAX_NPC) or 0
    local spawnDelay = tonumber(waveCfg._TIME) or 1

    local MIN_DELAY = 0.2
    spawnDelay = math.max(spawnDelay, MIN_DELAY)

    local template
    if Wave_1_folder:IsA("Model") then
        template = Wave_1_folder
    else
        template = Wave_1_folder:FindFirstChildWhichIsA("Model") or Wave_1_folder:GetChildren()[1]
    end
    if not template then
        warn("No enemy template found in Wave_1_folder")
        return
    end

    local originPart = (S_1 and S_1:IsA("BasePart")) and S_1 or Enemy_Spawn:FindFirstChildWhichIsA("BasePart")
    local originPos = originPart and originPart.Position

    local spawnedThisWave = 0
    local rnd = Random.new()

    while spawnedThisWave < maxN do
        if originPos then
            local nearest = getNearestPlayerWithin(originPos, DETECTION_RADIUS)
            if not nearest then
                task.wait(1) 
                continue
            end
        end

        local enemy = template:Clone()
        enemy.Name = ("%s_%d"):format(template.Name, _NPC_COUNT + 1)
        enemy.Parent = NPC_SPAWNED

        if not enemy.PrimaryPart then
            enemy.PrimaryPart = enemy:FindFirstChild("HumanoidRootPart") or enemy:FindFirstChildWhichIsA("BasePart")
        end

        local SPAWN_RADIUS = 6
        local MIN_CLEAR = 2.5
        local origin = originPos or (enemy.PrimaryPart and enemy.PrimaryPart.Position) or Vector3.new()
        local spawnPos = origin + Vector3.new(0, 5, 0)
        do
            local attempts = 0
            local found = false
            while attempts < 12 and not found do
                attempts = attempts + 1
                local offset = Vector3.new(
                    rnd:NextNumber(-SPAWN_RADIUS, SPAWN_RADIUS),
                    5,
                    rnd:NextNumber(-SPAWN_RADIUS, SPAWN_RADIUS)
                )
                local candidate = origin + offset
                local ok = true
                for _, other in ipairs(NPC_SPAWNED:GetChildren()) do
                    if other ~= enemy and other.PrimaryPart then
                        if (other.PrimaryPart.Position - candidate).Magnitude < MIN_CLEAR then
                            ok = false
                            break
                        end
                    end
                end
                if ok then
                    spawnPos = candidate
                    found = true
                end
            end
        end

        enemy:PivotTo(CFrame.new(spawnPos))

        _NPC_COUNT = _NPC_COUNT + 1
        spawnedThisWave = spawnedThisWave + 1

        local humanoid = enemy:FindFirstChildWhichIsA("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = tonumber(waveCfg._WALK_SPEED) or 8
            humanoid.JumpPower = tonumber(waveCfg._JUMP_POWER) or 50

            humanoid.Died:Connect(function()
                _NPC_COUNT = math.max(0, _NPC_COUNT - 1)

                task.delay(CLEANUP_DELAY, function()
                    if enemy and enemy.Parent then
                        enemy:Destroy()
                    end
                end)
            end)
        else
            enemy.AncestryChanged:Connect(function(_, parent)
                if not parent then
                    _NPC_COUNT = math.max(0, _NPC_COUNT - 1)
                end
            end)
        end

        attachAI(enemy)

        task.wait(spawnDelay)
    end
end

function Service:Start()
    task.spawn(function()
        local waveIndex = 1
        local totalWaves = #Wave_Status
        while waveIndex <= totalWaves do
            local cfg = Wave_Status[waveIndex]
            if not cfg then break end

            self:Enmy_Spawn_Location(cfg)

            while _NPC_COUNT > 0 do
                task.wait(1)
            end

            waveIndex = waveIndex + 1
        end
    end)
end

return Service
