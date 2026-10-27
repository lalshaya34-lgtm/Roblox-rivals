local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))

local function ensurePart(parent, name, size, cframe, color, material)
    local part = parent:FindFirstChild(name)
    if not part then
        part = Instance.new("Part")
        part.Name = name
        part.Anchored = true
        part.TopSurface = Enum.SurfaceType.Smooth
        part.BottomSurface = Enum.SurfaceType.Smooth
        part.Material = material or Enum.Material.SmoothPlastic
        part.Color = color or Config.ArenaColor
        part.Size = size or Vector3.new(1, 1, 1)
        part.CFrame = cframe or CFrame.new()
        part.Parent = parent
    end
    return part
end

local function ensureArena()
    local arena = Workspace:FindFirstChild("RivalsArena")
    if not arena then
        arena = Instance.new("Model")
        arena.Name = "RivalsArena"
        arena.Parent = Workspace
    end

    local base = ensurePart(arena, "Base", Vector3.new(200, 4, 200), CFrame.new(0, 0, 0), Config.FloorColor, Enum.Material.SmoothPlastic)
    base.Position = Vector3.new(0, 0, 0)

    local centerPad = ensurePart(arena, "CenterPad", Vector3.new(18, 1, 18), CFrame.new(0, 2, 0), Config.AccentColor, Enum.Material.Neon)
    centerPad.Position = Vector3.new(0, 2, 0)

    local wallOffset = 100
    local wallHeight = 18
    local wallThickness = 4

    local decorative = {
        {"NorthWall", Vector3.new(200, wallHeight, wallThickness), CFrame.new(0, wallHeight / 2, -wallOffset), Config.ArenaColor},
        {"SouthWall", Vector3.new(200, wallHeight, wallThickness), CFrame.new(0, wallHeight / 2, wallOffset), Config.ArenaColor},
        {"WestWall", Vector3.new(wallThickness, wallHeight, 200), CFrame.new(-wallOffset, wallHeight / 2, 0), Config.ArenaColor},
        {"EastWall", Vector3.new(wallThickness, wallHeight, 200), CFrame.new(wallOffset, wallHeight / 2, 0), Config.ArenaColor}
    }

    for _, data in ipairs(decorative) do
        local name, size, cframe, color = data[1], data[2], data[3], data[4]
        ensurePart(arena, name, size, cframe, color, Enum.Material.SmoothPlastic)
    end

    local obstacles = {
        {"BlockA", Vector3.new(18, 16, 18), CFrame.new(-42, 8, 0)},
        {"BlockB", Vector3.new(18, 16, 18), CFrame.new(42, 8, 0)},
        {"BlockC", Vector3.new(18, 22, 18), CFrame.new(0, 11, 36)},
        {"BlockD", Vector3.new(18, 22, 18), CFrame.new(0, 11, -36)}
    }

    for _, data in ipairs(obstacles) do
        local name, size, cframe = data[1], data[2], data[3]
        ensurePart(arena, name, size, cframe, Config.AccentDark, Enum.Material.SmoothPlastic)
    end
end

local function createLeaderstats(player)
    local folder = Instance.new("Folder")
    folder.Name = "leaderstats"
    folder.Parent = player

    local kills = Instance.new("IntValue")
    kills.Name = "Kills"
    kills.Value = 0
    kills.Parent = folder

    local deaths = Instance.new("IntValue")
    deaths.Name = "Deaths"
    deaths.Value = 0
    deaths.Parent = folder
end

local function getSpawnPoint(player)
    local index = (player.UserId % #Config.SpawnPoints) + 1
    return Config.SpawnPoints[index]
end

local function resetPlayer(player)
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local root = character:WaitForChild("HumanoidRootPart")

    root.CFrame = CFrame.new(getSpawnPoint(player))
    humanoid.Health = humanoid.MaxHealth
    humanoid.WalkSpeed = 16
    humanoid.JumpPower = 50
end

local currentState = "Lobby"
local roundTime = Config.MatchLength
local lastShotAt = {}
local roundInProgress = false

local function getPlayerTable()
    local players = {}
    for _, player in ipairs(Players:GetPlayers()) do
        local stats = player:FindFirstChild("leaderstats")
        local kills = stats and stats:FindFirstChild("Kills") and stats.Kills.Value or 0
        local deaths = stats and stats:FindFirstChild("Deaths") and stats.Deaths.Value or 0
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local alive = humanoid and humanoid.Health > 0 or false

        table.insert(players, {
            name = player.Name,
            kills = kills,
            deaths = deaths,
            alive = alive
        })
    end

    table.sort(players, function(a, b)
        return a.kills > b.kills
    end)

    return players
end

local function broadcastHud()
    local payload = {
        state = currentState,
        roundTime = roundTime,
        players = getPlayerTable()
    }

    for _, player in ipairs(Players:GetPlayers()) do
        Remotes.Hud:FireClient(player, payload)
    end
end

local function awardKill(killer, victim)
    if killer == victim then
        return
    end

    local stats = killer:FindFirstChild("leaderstats")
    if stats and stats:FindFirstChild("Kills") then
        stats.Kills.Value += 1
    end

    stats = victim:FindFirstChild("leaderstats")
    if stats and stats:FindFirstChild("Deaths") then
        stats.Deaths.Value += 1
    end
end

local function tryHitScan(player, direction)
    if not roundInProgress then
        return
    end

    local character = player.Character
    if not character then
        return
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root or humanoid.Health <= 0 then
        return
    end

    local now = os.clock()
    if lastShotAt[player] and now - lastShotAt[player] < Config.FireRate then
        return
    end
    lastShotAt[player] = now

    local origin = root.Position + Vector3.new(0, 2, 0)
    local directionVector = direction and direction.Unit or Vector3.new(0, 0, -1)
    local ray = Ray.new(origin, directionVector * Config.HitRange)
    local hitPart, hitPosition = Workspace:FindPartOnRayWithIgnoreList(ray, { character }, false, true)

    if not hitPart then
        return
    end

    local model = hitPart:FindFirstAncestorOfClass("Model")
    if not model then
        return
    end

    local targetPlayer = Players:GetPlayerFromCharacter(model)
    if not targetPlayer or targetPlayer == player then
        return
    end

    local targetHumanoid = model:FindFirstChildOfClass("Humanoid")
    if targetHumanoid and targetHumanoid.Health > 0 then
        targetHumanoid:TakeDamage(Config.Damage)
        if targetHumanoid.Health <= 0 then
            awardKill(player, targetPlayer)
            task.delay(Config.RespawnDelay, function()
                if targetPlayer and targetPlayer.Parent then
                    resetPlayer(targetPlayer)
                end
            end)
        end
    end

    broadcastHud()
end

Remotes.Shoot.OnServerEvent:Connect(function(player, direction)
    if typeof(direction) == "Vector3" then
        tryHitScan(player, direction)
    end
end)

local function startMatch()
    roundInProgress = true
    currentState = "Live"
    roundTime = Config.MatchLength
    broadcastHud()

    for _, player in ipairs(Players:GetPlayers()) do
        resetPlayer(player)
    end
    broadcastHud()
end

local function finishMatch()
    roundInProgress = false
    currentState = "Round Over"
    roundTime = 0
    broadcastHud()
end

local function lobbyTick()
    if not roundInProgress then
        currentState = "Lobby"
        roundTime = Config.LobbyLength
        broadcastHud()
        task.wait(Config.LobbyLength)
        startMatch()
    end
end

local function handlePlayer(player)
    createLeaderstats(player)

    player.CharacterAdded:Connect(function()
        task.wait(0.25)
        resetPlayer(player)
        broadcastHud()
    end)

    if player.Character then
        resetPlayer(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    handlePlayer(player)
    broadcastHud()
end)

for _, player in ipairs(Players:GetPlayers()) do
    handlePlayer(player)
end

ensureArena()
Lighting.TimeOfDay = 14
Lighting.Brightness = 2
Lighting.OutdoorAmbient = Color3.fromRGB(110, 128, 154)
Lighting.Ambient = Color3.fromRGB(70, 84, 104)

startMatch()

while true do
    task.wait(1)
    if roundInProgress then
        roundTime -= 1
        if roundTime <= 0 then
            finishMatch()
            task.wait(3)
            startMatch()
        else
            broadcastHud()
        end
    else
        broadcastHud()
    end
end
