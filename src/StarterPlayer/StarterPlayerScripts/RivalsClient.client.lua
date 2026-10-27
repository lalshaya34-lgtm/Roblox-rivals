local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))

local roundState = "Lobby"
local roundTime = Config.LobbyLength
local roundActive = false
local lastShotAt = {}
local killFeed = {}
local currentWinner = nil
local ammoState = {}
local reloadTimers = {}
local boostEnds = {}
local sprintingPlayers = {}
local pickupParts = {}

local function ensureLoadout(player)
    if not ammoState[player] then
        ammoState[player] = {
            weapon = "Rifle",
            Rifle = { clip = Config.Weapons.Rifle.clipSize, reserve = Config.Weapons.Rifle.reserve },
            SMG = { clip = Config.Weapons.SMG.clipSize, reserve = Config.Weapons.SMG.reserve },
            Burst = { clip = Config.Weapons.Burst.clipSize, reserve = Config.Weapons.Burst.reserve },
            Shotgun = { clip = Config.Weapons.Shotgun.clipSize, reserve = Config.Weapons.Shotgun.reserve },
            DMR = { clip = Config.Weapons.DMR.clipSize, reserve = Config.Weapons.DMR.reserve }
        }
    end

    return ammoState[player]
end

local function setWeapon(player, weaponName)
    local loadout = ensureLoadout(player)
    local valid = Config.Weapons[weaponName]
    if not valid then
        weaponName = "Rifle"
    end

    loadout.weapon = weaponName
    if not loadout[weaponName] then
        loadout[weaponName] = {
            clip = valid.clipSize,
            reserve = valid.reserve,
        }
    end
end

local function getWeaponStats(player)
    local loadout = ensureLoadout(player)
    return Config.Weapons[loadout.weapon] or Config.Weapons.Rifle
end

local function resetPlayerLoadout(player)
    local loadout = ensureLoadout(player)
    loadout.Rifle = { clip = Config.Weapons.Rifle.clipSize, reserve = Config.Weapons.Rifle.reserve }
    loadout.SMG = { clip = Config.Weapons.SMG.clipSize, reserve = Config.Weapons.SMG.reserve }
    loadout.Burst = { clip = Config.Weapons.Burst.clipSize, reserve = Config.Weapons.Burst.reserve }
    loadout.Shotgun = { clip = Config.Weapons.Shotgun.clipSize, reserve = Config.Weapons.Shotgun.reserve }
    loadout.DMR = { clip = Config.Weapons.DMR.clipSize, reserve = Config.Weapons.DMR.reserve }
    loadout.weapon = "Rifle"
    reloadTimers[player] = false
    sprintingPlayers[player] = false
end

local function addKillFeed(text)
    table.insert(killFeed, { text = text, time = os.clock() })
    if #killFeed > 6 then
        table.remove(killFeed, 1)
    end
end

local function ensurePart(parent, name, size, cframe, color, material)
    local existing = parent:FindFirstChild(name)
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
    part.Parent = parent
    return part
end

local function buildArena()
    local arena = Workspace:FindFirstChild("RivalsArena")
    if not arena then
        arena = Instance.new("Model")
        arena.Name = "RivalsArena"
        arena.Parent = Workspace
    end

    ensurePart(arena, "Base", Vector3.new(220, 4, 220), CFrame.new(0, 0, 0), Config.Colors.Floor, Enum.Material.SmoothPlastic)
    ensurePart(arena, "CenterPad", Vector3.new(20, 1, 20), CFrame.new(0, 2, 0), Config.Colors.Accent, Enum.Material.Neon)

    local wallSize = 220
    local wallHeight = 20
    local wallThickness = 4
    local wallOffset = 110

    ensurePart(arena, "NorthWall", Vector3.new(wallSize, wallHeight, wallThickness), CFrame.new(0, wallHeight / 2, -wallOffset), Config.Colors.Arena, Enum.Material.SmoothPlastic)
    ensurePart(arena, "SouthWall", Vector3.new(wallSize, wallHeight, wallThickness), CFrame.new(0, wallHeight / 2, wallOffset), Config.Colors.Arena, Enum.Material.SmoothPlastic)
    ensurePart(arena, "WestWall", Vector3.new(wallThickness, wallHeight, wallSize), CFrame.new(-wallOffset, wallHeight / 2, 0), Config.Colors.Arena, Enum.Material.SmoothPlastic)
    ensurePart(arena, "EastWall", Vector3.new(wallThickness, wallHeight, wallSize), CFrame.new(wallOffset, wallHeight / 2, 0), Config.Colors.Arena, Enum.Material.SmoothPlastic)

    local coverConfigs = {
        {"CoverA", Vector3.new(22, 10, 12), CFrame.new(-30, 5, -18)},
        {"CoverB", Vector3.new(22, 10, 12), CFrame.new(30, 5, -18)},
        {"CoverC", Vector3.new(22, 10, 12), CFrame.new(-30, 5, 18)},
        {"CoverD", Vector3.new(22, 10, 12), CFrame.new(30, 5, 18)},
        {"CoverE", Vector3.new(16, 10, 16), CFrame.new(0, 5, -38)},
        {"CoverF", Vector3.new(16, 10, 16), CFrame.new(0, 5, 38)},
        {"CoverG", Vector3.new(10, 8, 28), CFrame.new(-52, 4, 0)},
        {"CoverH", Vector3.new(10, 8, 28), CFrame.new(52, 4, 0)}
    }

    for _, data in ipairs(coverConfigs) do
        ensurePart(arena, data[1], data[2], data[3], Config.Colors.AccentDark, Enum.Material.SmoothPlastic)
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
    local index = (player.UserId % #Config.SpawnPoints) + 1
    return Config.SpawnPoints[index]
end

local function respawnPlayer(player)
    local character = player.Character or player.CharacterAdded:Wait()
    local root = character:WaitForChild("HumanoidRootPart")
    local humanoid = character:WaitForChild("Humanoid")

    root.CFrame = CFrame.new(getSpawnPoint(player))
    humanoid.WalkSpeed = Config.WalkSpeed
    humanoid.JumpPower = Config.JumpPower
    humanoid.Health = humanoid.MaxHealth
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
            alive = alive
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

local function getLoadoutMap()
    local map = {}
    for _, player in ipairs(Players:GetPlayers()) do
        local state = ensureLoadout(player)
        local weaponName = state.weapon
        map[player.Name] = {
            weapon = weaponName,
            clip = state[weaponName].clip,
            reserve = state[weaponName].reserve,
            label = Config.Weapons[weaponName].label
        }
    end
    return map
end

local function broadcastHud()
    local payload = {
        state = roundState,
        roundTime = roundTime,
        players = getLeaderboardData(),
        message = "",
        killFeed = killFeed,
        winner = currentWinner,
        playerCount = #Players:GetPlayers(),
        readyCount = #Players:GetPlayers(),
        loadout = getLoadoutMap(),
    }

    if roundState == "Lobby" then
        payload.message = "READY"
    elseif roundState == "Live" then
        payload.message = "LIVE"
    elseif roundState == "Round Over" then
        payload.message = currentWinner and ("WINNER: " .. currentWinner) or "ROUND OVER"
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

local function computeRoundWinner()
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
    roundTime = Config.LobbyLength
    currentWinner = nil
    killFeed = {}
    broadcastHud()
end

local function startMatch()
    roundActive = true
    roundState = "Live"
    roundTime = Config.MatchLength
    currentWinner = nil

    for _, player in ipairs(Players:GetPlayers()) do
        resetPlayerLoadout(player)
        if player.Character then
            respawnPlayer(player)
        end
    end

    broadcastHud()
end

local function finishMatch()
    roundActive = false
    roundState = "Round Over"
    roundTime = Config.RoundOverLength
    currentWinner = computeRoundWinner()
    broadcastHud()
end

local function attemptReload(player)
    local state = ensureLoadout(player)
    local weaponName = state.weapon
    local ammo = state[weaponName]
    local stats = Config.Weapons[weaponName]

    if reloadTimers[player] then
        return
    end

    if ammo.clip >= stats.clipSize or ammo.reserve <= 0 then
        return
    end

    reloadTimers[player] = true

    task.delay(stats.reloadTime, function()
        if not player.Parent then
            reloadTimers[player] = false
            return
        end

        local currentState = ensureLoadout(player)
        local currentWeapon = currentState.weapon
        local currentAmmo = currentState[currentWeapon]
        local currentStats = Config.Weapons[currentWeapon]

        local needed = currentStats.clipSize - currentAmmo.clip
        local inserted = math.min(needed, currentAmmo.reserve)
        currentAmmo.clip += inserted
        currentAmmo.reserve -= inserted
        reloadTimers[player] = false
        broadcastHud()
    end)
end

local function handlePickup(player, kind)
    local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        return
    end

    if kind == "Health" then
        humanoid.Health = math.min(humanoid.MaxHealth, humanoid.Health + Config.Pickups.Health.amount)
    elseif kind == "Boost" then
        boostEnds[player] = os.clock() + Config.Pickups.Boost.duration
        humanoid.WalkSpeed = Config.SprintSpeed
        task.delay(Config.Pickups.Boost.duration, function()
            if player.Parent and player.Character then
                local currentHumanoid = player.Character:FindFirstChildOfClass("Humanoid")
                if currentHumanoid then
                    if sprintingPlayers[player] then
                        currentHumanoid.WalkSpeed = Config.SprintSpeed
                    else
                        currentHumanoid.WalkSpeed = Config.WalkSpeed
                    end
                end
            end
        end)
    elseif kind == "Ammo" then
        local state = ensureLoadout(player)
        local weaponName = state.weapon
        local ammo = state[weaponName]
        ammo.reserve += Config.Pickups.Ammo.bonus
    end
end

local function spawnPickup(kind, position)
    local data = Config.Pickups[kind]
    if not data then
        return
    end

    local pickup = Instance.new("Part")
    pickup.Name = "Pickup"
    pickup.Shape = Enum.PartType.Cylinder
    pickup.Size = Vector3.new(2.2, 2.2, 2.2)
    pickup.Color = data.color
    pickup.Material = Enum.Material.Neon
    pickup.Anchored = true
    pickup.CFrame = CFrame.new(position)
    pickup.Parent = Workspace

    local touchedConn
    touchedConn = pickup.Touched:Connect(function(hit)
        local character = hit.Parent
        local player = character and Players:GetPlayerFromCharacter(character)
        if player then
            handlePickup(player, kind)
        end

        if touchedConn then
            touchedConn:Disconnect()
        end

        pickup:Destroy()
        task.delay(data.respawn, function()
            spawnPickup(kind, position)
        end)
    end)

    pickupParts[#pickupParts + 1] = pickup
end

local function makePickups()
    local positions = {
        Vector3.new(-40, 3, 0),
        Vector3.new(40, 3, 0),
        Vector3.new(0, 3, -40),
        Vector3.new(0, 3, 40),
        Vector3.new(-25, 3, 25),
        Vector3.new(25, 3, -25),
        Vector3.new(-55, 3, 0),
        Vector3.new(55, 3, 0),
        Vector3.new(0, 3, 0)
    }

    local cycle = {"Health", "Boost", "Ammo", "Health", "Ammo", "Boost", "Health", "Ammo", "Boost"}
    for i, pos in ipairs(positions) do
        spawnPickup(cycle[i], pos)
    end
end

local function handlePlayer(player)
    createLeaderstats(player)
    resetPlayerLoadout(player)

    player.CharacterAdded:Connect(function()
        task.wait(0.2)
        respawnPlayer(player)
        broadcastHud()
    end)

    if player.Character then
        respawnPlayer(player)
    end
end

local function applyMovementState(player, sprinting)
    sprintingPlayers[player] = sprinting
    local character = player.Character
    if not character then
        return
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        return
    end

    if sprinting then
        humanoid.WalkSpeed = Config.SprintSpeed
    else
        humanoid.WalkSpeed = Config.WalkSpeed
    end
end

local function firePelletShot(player, weaponName, direction)
    local character = player.Character
    if not character then
        return
    end

    local root = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid or humanoid.Health <= 0 then
        return
    end

    local weaponStats = Config.Weapons[weaponName] or Config.Weapons.Rifle
    local origin = root.Position + Vector3.new(0, 2, 0)
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = { character }

    local pellets = weaponStats.pellets or 1
    for i = 1, pellets do
        local jitter = Vector3.new(
            (math.random() - 0.5) * weaponStats.spread * 3,
            (math.random() - 0.5) * weaponStats.spread * 3,
            0
        )
        local adjusted = (direction + jitter).Unit
        local hit = Workspace:Raycast(origin, adjusted * 340, rayParams)
        if hit and hit.Instance then
            local model = hit.Instance:FindFirstAncestorOfClass("Model")
            if model then
                local targetPlayer = Players:GetPlayerFromCharacter(model)
                if targetPlayer and targetPlayer ~= player then
                    local targetHumanoid = model:FindFirstChildOfClass("Humanoid")
                    if targetHumanoid and targetHumanoid.Health > 0 then
                        targetHumanoid:TakeDamage(weaponStats.damage)
                        if targetHumanoid.Health <= 0 then
                            awardKill(player, targetPlayer)
                            task.delay(Config.RespawnDelay, function()
                                if targetPlayer and targetPlayer.Character then
                                    respawnPlayer(targetPlayer)
                                    broadcastHud()
                                end
                            end)
                        end
                    end
                end
            end
        end
    end

    broadcastHud()
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

    local state = ensureLoadout(player)
    if state.weapon ~= weaponName then
        state.weapon = weaponName
    end

    local ammo = state[weaponName]
    if not ammo then
        return
    end

    local stats = Config.Weapons[weaponName] or Config.Weapons.Rifle

    if reloadTimers[player] then
        return
    end

    if ammo.clip <= 0 then
        attemptReload(player)
        return
    end

    local now = os.clock()
    if lastShotAt[player] and now - lastShotAt[player] < stats.fireRate then
        return
    end
    lastShotAt[player] = now

    ammo.clip -= 1

    if weaponName == "Shotgun" then
        firePelletShot(player, weaponName, direction or Vector3.new(0, 0, -1))
        return
    end

    local lookVector = direction and direction.Unit or Vector3.new(0, 0, -1)
    local yawJitter = (math.random() - 0.5) * stats.spread
    local pitchJitter = (math.random() - 0.5) * stats.spread
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

    local damage = stats.damage
    if boostEnds[player] and boostEnds[player] > os.clock() then
        damage = damage + 4
    end

    targetHumanoid:TakeDamage(damage)

    if targetHumanoid.Health <= 0 then
        awardKill(player, targetPlayer)
        task.delay(Config.RespawnDelay, function()
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
        setWeapon(player, weaponName)
    else
        weaponName = ensureLoadout(player).weapon
    end

    if typeof(direction) == "Vector3" then
        tryHitScan(player, ensureLoadout(player).weapon, direction)
    end
end)

Remotes.Reload.OnServerEvent:Connect(function(player)
    attemptReload(player)
end)

Remotes.MoveState.OnServerEvent:Connect(function(player, sprinting)
    if typeof(sprinting) == "boolean" then
        applyMovementState(player, sprinting)
    end
end)

Players.PlayerAdded:Connect(function(player)
    handlePlayer(player)
    broadcastHud()
end)

for _, player in ipairs(Players:GetPlayers()) do
    handlePlayer(player)
end

buildArena()
makePickups()

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
