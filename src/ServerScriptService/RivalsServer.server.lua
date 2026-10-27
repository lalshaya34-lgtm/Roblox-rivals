local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))
local PickupManager = require(script.Parent:WaitForChild("PickupManager"))

local roundState = "Lobby"
local roundTime = (Config.Match and Config.Match.LobbyLength) or (Config.LobbyLength or 12)
local roundActive = false
local killFeed = {}
local currentWinner = nil
local currentMode = "Casual"
local lastShotAt = {}
local weaponByPlayer = {}
local ammoByPlayer = {}
local reloadByPlayer = {}
local sprintByPlayer = {}
local teamByPlayer = {}
local readyByPlayer = {}
local healthByPlayer = {}

local function setPlayerWeapon(player, weaponName)
    local stats = Config.Weapons[weaponName] or Config.Weapons.Rifle
    weaponByPlayer[player] = weaponName or "Rifle"
    ammoByPlayer[player] = ammoByPlayer[player] or {
        weapon = weaponName or "Rifle",
        clip = stats.clipSize,
        reserve = stats.reserve,
    }

    local ammo = ammoByPlayer[player]
    ammo.weapon = weaponName or "Rifle"
    ammo.clip = math.max(0, ammo.clip or stats.clipSize)
    ammo.reserve = math.max(0, ammo.reserve or stats.reserve)
end

local function getPlayerAmmo(player)
    local currentWeaponName = weaponByPlayer[player] or "Rifle"
    local stats = Config.Weapons[currentWeaponName] or Config.Weapons.Rifle
    local ammo = ammoByPlayer[player]
    if not ammo then
        ammo = {
            weapon = currentWeaponName,
            clip = stats.clipSize,
            reserve = stats.reserve,
        }
        ammoByPlayer[player] = ammo
    end
    if ammo.weapon ~= currentWeaponName then
        ammo.weapon = currentWeaponName
        ammo.clip = stats.clipSize
        ammo.reserve = stats.reserve
    end
    return ammo
end

local function getPlayerTeam(player)
    return teamByPlayer[player] or "Red"
end

local function assignTeams()
    local players = Players:GetPlayers()
    table.sort(players, function(a, b)
        return a.UserId < b.UserId
    end)

    for index, player in ipairs(players) do
        teamByPlayer[player] = index % 2 == 1 and "Red" or "Blue"
    end
end

local function addKillFeed(text)
    table.insert(killFeed, { text = text, time = os.clock() })
    if #killFeed > 6 then
        table.remove(killFeed, 1)
    end
end

local function createLeaderstats(player)
    local folder = player:FindFirstChild("leaderstats")
    if folder then
        return folder
    end

    folder = Instance.new("Folder")
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

    return folder
end

local function getSpawnPoint(player)
    local team = getPlayerTeam(player)
    local spawnList = Config.SpawnPoints[team] or Config.SpawnPoints.Red
    local index = (player.UserId % #spawnList) + 1
    return spawnList[index]
end

local function respawnPlayer(player)
    local character = player.Character or player.CharacterAdded:Wait()
    local root = character:WaitForChild("HumanoidRootPart")
    local humanoid = character:WaitForChild("Humanoid")

    root.CFrame = CFrame.new(getSpawnPoint(player))
    humanoid.WalkSpeed = Config.Player and Config.Player.WalkSpeed or Config.WalkSpeed or 16
    humanoid.JumpPower = Config.Player and Config.Player.JumpPower or Config.JumpPower or 50
    humanoid.Health = humanoid.MaxHealth
    healthByPlayer[player] = humanoid.MaxHealth
end

local function getLeaderboardData()
    local data = {}

    for _, player in ipairs(Players:GetPlayers()) do
        local stats = player:FindFirstChild("leaderstats")
        local kills = stats and stats:FindFirstChild("Kills") and stats.Kills.Value or 0
        local deaths = stats and stats:FindFirstChild("Deaths") and stats.Deaths.Value or 0

        local character = player.Character
        local alive = false
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            alive = humanoid and humanoid.Health > 0 or false
        end

        table.insert(data, {
            name = player.Name,
            kills = kills,
            deaths = deaths,
            alive = alive,
        })
    end

    table.sort(data, function(a, b)
        if a.kills == b.kills then
            return a.deaths < b.deaths
        end
        return a.kills > b.kills
    end)

    return data
end

local function setPlayerSpeed(player, isSprinting)
    local character = player.Character
    if not character then
        return
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        return
    end

    local targetSpeed = (isSprinting and ((Config.Player and Config.Player.SprintSpeed) or (Config.SprintSpeed or 22))) or ((Config.Player and Config.Player.WalkSpeed) or (Config.WalkSpeed or 16))
    humanoid.WalkSpeed = targetSpeed
    sprintByPlayer[player] = isSprinting
end

local function getRoundWinner()
    local highestKills = -1
    local winnerName = nil

    for _, player in ipairs(Players:GetPlayers()) do
        local stats = player:FindFirstChild("leaderstats")
        local kills = stats and stats:FindFirstChild("Kills") and stats.Kills.Value or 0

        if kills > highestKills then
            highestKills = kills
            winnerName = player.Name
        end
    end

    if highestKills >= 0 then
        return winnerName
    end

    return nil
end

local function startLobby()
    roundActive = false
    roundState = "Lobby"
    roundTime = (Config.Match and Config.Match.LobbyLength) or (Config.LobbyLength or 12)
    currentWinner = nil
    killFeed = {}
    readyByPlayer = {}
    broadcastHud()
end

local function startMatch()
    if #Players:GetPlayers() < ((Config.Match and Config.Match.MinPlayers) or 2) then
        return
    end

    assignTeams()
    roundActive = true
    roundState = "Live"
    roundTime = (Config.Match and Config.Match.MatchLength) or (Config.MatchLength or 150)
    currentWinner = nil
    broadcastHud()

    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            respawnPlayer(player)
        end
    end
end

local function finishMatch()
    roundActive = false
    roundState = "Round Over"
    roundTime = (Config.Match and Config.Match.RoundOverLength) or (Config.RoundOverLength or 6)
    currentWinner = getRoundWinner()
    broadcastHud()
end

local function broadcastHud()
    local payload = {
        state = roundState,
        roundTime = roundTime,
        players = getLeaderboardData(),
        killFeed = killFeed,
        winner = currentWinner,
        teams = teamByPlayer,
        ready = readyByPlayer,
        loadout = {},
        reloading = reloadByPlayer,
        sprinting = sprintByPlayer,
        health = healthByPlayer,
    }

    for _, player in ipairs(Players:GetPlayers()) do
        local currentAmmoState = getPlayerAmmo(player)
        payload.loadout[player.Name] = currentAmmoState
        if player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                healthByPlayer[player] = humanoid.Health
            end
        end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        Remotes.Hud:FireClient(player, payload)
    end
end

local function awardKill(killer, victim)
    if killer == victim then
        return
    end

    local killerStats = killer:FindFirstChild("leaderstats")
    if killerStats and killerStats:FindFirstChild("Kills") then
        killerStats.Kills.Value += 1
    end

    local victimStats = victim:FindFirstChild("leaderstats")
    if victimStats and victimStats:FindFirstChild("Deaths") then
        victimStats.Deaths.Value += 1
    end

    addKillFeed(killer.Name .. " eliminated " .. victim.Name)
end

local function reloadPlayer(player)
    local weaponName = weaponByPlayer[player] or "Rifle"
    local stats = Config.Weapons[weaponName] or Config.Weapons.Rifle
    local ammo = getPlayerAmmo(player)

    if reloadByPlayer[player] or ammo.clip >= stats.clipSize or ammo.reserve <= 0 then
        return
    end

    reloadByPlayer[player] = true
    broadcastHud()

    task.delay(stats.reloadTime, function()
        local currentAmmoState = getPlayerAmmo(player)
        local needed = stats.clipSize - currentAmmoState.clip
        local loaded = math.min(needed, currentAmmoState.reserve)
        currentAmmoState.clip += loaded
        currentAmmoState.reserve -= loaded
        reloadByPlayer[player] = false
        broadcastHud()
    end)
end

local function handlePlayer(player)
    createLeaderstats(player)
    setPlayerWeapon(player, "Rifle")
    teamByPlayer[player] = teamByPlayer[player] or "Red"
    readyByPlayer[player] = false
    sprintByPlayer[player] = false
    reloadByPlayer[player] = false
    healthByPlayer[player] = 100

    player.CharacterAdded:Connect(function()
        task.wait(0.2)
        respawnPlayer(player)
        setPlayerSpeed(player, sprintByPlayer[player] == true)
        broadcastHud()
    end)

    if player.Character then
        respawnPlayer(player)
    end
end

local function tryHitScan(player, weaponName, direction)
    if not roundActive then
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

    local ammo = getPlayerAmmo(player)
    if ammo.clip <= 0 then
        reloadPlayer(player)
        return
    end

    local weaponStats = Config.Weapons[weaponName] or Config.Weapons.Rifle
    local now = os.clock()
    if lastShotAt[player] and now - lastShotAt[player] < weaponStats.fireRate then
        return
    end
    lastShotAt[player] = now

    ammo.clip -= 1
    if ammo.clip < 0 then
        ammo.clip = 0
    end

    local lookVector = direction and direction.Unit or Vector3.new(0, 0, -1)
    local yawJitter = (math.random() - 0.5) * weaponStats.spread
    local pitchJitter = (math.random() - 0.5) * weaponStats.spread
    local adjustedLook = (lookVector + Vector3.new(yawJitter, pitchJitter, 0)).Unit
    local origin = root.Position + Vector3.new(0, 2, 0)

    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = { character }

    local hit = Workspace:Raycast(origin, adjustedLook * 340, rayParams)
    if not hit or not hit.Instance then
        broadcastHud()
        return
    end

    local model = hit.Instance:FindFirstAncestorOfClass("Model")
    if not model then
        broadcastHud()
        return
    end

    local targetPlayer = Players:GetPlayerFromCharacter(model)
    if not targetPlayer or targetPlayer == player then
        broadcastHud()
        return
    end

    local targetHumanoid = model:FindFirstChildOfClass("Humanoid")
    if not targetHumanoid or targetHumanoid.Health <= 0 then
        broadcastHud()
        return
    end

    if getPlayerTeam(player) == getPlayerTeam(targetPlayer) then
        broadcastHud()
        return
    end

    targetHumanoid:TakeDamage(weaponStats.damage)
    healthByPlayer[targetPlayer] = targetHumanoid.Health

    if targetHumanoid.Health <= 0 then
        awardKill(player, targetPlayer)
        task.delay(Config.Match and Config.Match.RespawnDelay or Config.RespawnDelay or 1.5, function()
            if targetPlayer and targetPlayer.Character then
                respawnPlayer(targetPlayer)
                broadcastHud()
            end
        end)
    end

    broadcastHud()
end

Remotes.Shoot.OnServerEvent:Connect(function(player, weaponName, direction)
    if typeof(weaponName) == "string" and Config.Weapons[weaponName] then
        setPlayerWeapon(player, weaponName)
    end

    if typeof(direction) == "Vector3" then
        local selectedWeapon = weaponByPlayer[player] or "Rifle"
        tryHitScan(player, selectedWeapon, direction)
    end
end)

Remotes.MoveState.OnServerEvent:Connect(function(player, isSprinting)
    setPlayerSpeed(player, isSprinting == true)
    broadcastHud()
end)

Remotes.Reload.OnServerEvent:Connect(function(player)
    reloadPlayer(player)
end)

Remotes.LobbyReady.OnServerEvent:Connect(function(player)
    readyByPlayer[player] = true
    broadcastHud()
end)

Remotes.ClassSelect.OnServerEvent:Connect(function(player, className)
    if className and Config.Classes[className] then
        -- class selection stored, ready for future upgrades
    end
end)

Remotes.ModeSelect.OnServerEvent:Connect(function(player, modeName)
    if modeName and Config.Modes[modeName] then
        currentMode = modeName
    end
end)

Players.PlayerAdded:Connect(function(player)
    handlePlayer(player)
    broadcastHud()
end)

for _, player in ipairs(Players:GetPlayers()) do
    handlePlayer(player)
end

local function buildArena()
    if not Workspace:FindFirstChild("RivalsArena") then
        local arena = Instance.new("Model")
        arena.Name = "RivalsArena"
        arena.Parent = Workspace
    end

    local arena = Workspace:FindFirstChild("RivalsArena")
    local function ensurePart(name, size, cframe, color, material)
        local existing = arena:FindFirstChild(name)
        if existing then
            existing.Size = size
            existing.CFrame = cframe
            existing.Color = color
            existing.Material = material or Enum.Material.SmoothPlastic
            return existing
        end

        local part = Instance.new("Part")
        part.Name = name
        part.Anchored = true
        part.TopSurface = Enum.SurfaceType.Smooth
        part.BottomSurface = Enum.SurfaceType.Smooth
        part.Material = material or Enum.Material.SmoothPlastic
        part.Color = color or Config.Colors.Arena
        part.Size = size or Vector3.new(1, 1, 1)
        part.CFrame = cframe or CFrame.new()
        part.Parent = arena
        return part
    end

    ensurePart("Base", Vector3.new(220, 4, 220), CFrame.new(0, 0, 0), Config.Colors.Floor, Enum.Material.SmoothPlastic)
    ensurePart("CenterPad", Vector3.new(20, 1, 20), CFrame.new(0, 2, 0), Config.Colors.Accent, Enum.Material.Neon)

    local wallSize = 220
    local wallHeight = 20
    local wallThickness = 4
    local wallOffset = 110

    ensurePart("NorthWall", Vector3.new(wallSize, wallHeight, wallThickness), CFrame.new(0, wallHeight / 2, -wallOffset), Config.Colors.Arena, Enum.Material.SmoothPlastic)
    ensurePart("SouthWall", Vector3.new(wallSize, wallHeight, wallThickness), CFrame.new(0, wallHeight / 2, wallOffset), Config.Colors.Arena, Enum.Material.SmoothPlastic)
    ensurePart("WestWall", Vector3.new(wallThickness, wallHeight, wallSize), CFrame.new(-wallOffset, wallHeight / 2, 0), Config.Colors.Arena, Enum.Material.SmoothPlastic)
    ensurePart("EastWall", Vector3.new(wallThickness, wallHeight, wallSize), CFrame.new(wallOffset, wallHeight / 2, 0), Config.Colors.Arena, Enum.Material.SmoothPlastic)

    local obstacleConfigs = {
        { "A1", Vector3.new(18, 16, 18), CFrame.new(-42, 8, -12) },
        { "A2", Vector3.new(18, 16, 18), CFrame.new(42, 8, -12) },
        { "A3", Vector3.new(18, 18, 18), CFrame.new(-42, 9, 32) },
        { "A4", Vector3.new(18, 18, 18), CFrame.new(42, 9, 32) },
        { "A5", Vector3.new(20, 12, 20), CFrame.new(0, 6, -38) },
        { "A6", Vector3.new(20, 12, 20), CFrame.new(0, 6, 38) },
    }

    for _, data in ipairs(obstacleConfigs) do
        ensurePart(data[1], data[2], data[3], Config.Colors.AccentDark, Enum.Material.SmoothPlastic)
    end

    local neonRing = ensurePart("NeonRing", Vector3.new(218, 1, 218), CFrame.new(0, 1, 0), Config.Colors.Accent, Enum.Material.Neon)
    neonRing.Material = Enum.Material.Neon

    local pickupFolder = Workspace:FindFirstChild("Pickups") or Instance.new("Folder")
    pickupFolder.Name = "Pickups"
    pickupFolder.Parent = Workspace
    PickupManager.spawnArenaPickups(pickupFolder, Config)
end

buildArena()
Lighting.TimeOfDay = 14
Lighting.Brightness = 2
Lighting.OutdoorAmbient = Color3.fromRGB(120, 135, 160)
Lighting.Ambient = Color3.fromRGB(70, 90, 120)

startLobby()

while true do
    task.wait(1)

    if #Players:GetPlayers() == 0 then
        startLobby()
    elseif roundState == "Lobby" then
        roundTime -= 1
        if roundTime <= 0 then
            startMatch()
        else
            broadcastHud()
        end
    elseif roundState == "Live" then
        roundTime -= 1
        if roundTime <= 0 then
            finishMatch()
        else
            broadcastHud()
        end
    elseif roundState == "Round Over" then
        roundTime -= 1
        if roundTime <= 0 then
            startLobby()
        else
            broadcastHud()
        end
    end
end
