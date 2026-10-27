local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))
local WorldBuilder = require(script.Parent:WaitForChild("WorldBuilder"))

local roundState = "Lobby"
local roundTime = Config.LobbyLength
local currentWinner = nil
local currentMapIndex = 1
local killFeed = {}
local lastShotAt = {}
local weaponByPlayer = {}
local ammoByPlayer = {}
local reloadingByPlayer = {}
local teamByPlayer = {}
local matchStartedAt = 0

local function ensureTeams()
    local redTeam = Teams:FindFirstChild("Red") or Instance.new("Team")
    redTeam.Name = "Red"
    redTeam.TeamColor = BrickColor.new("Really red")
    redTeam.Parent = Teams

    local blueTeam = Teams:FindFirstChild("Blue") or Instance.new("Team")
    blueTeam.Name = "Blue"
    blueTeam.TeamColor = BrickColor.new("Really blue")
    blueTeam.Parent = Teams

    return redTeam, blueTeam
end

local function assignTeam(player)
    local redTeam, blueTeam = ensureTeams()

    local redCount = 0
    local blueCount = 0

    for _, other in ipairs(Players:GetPlayers()) do
        if other ~= player then
            if other.Team == redTeam then
                redCount += 1
            elseif other.Team == blueTeam then
                blueCount += 1
            end
        end
    end

    if redCount <= blueCount then
        player.Team = redTeam
        teamByPlayer[player] = "Red"
    else
        player.Team = blueTeam
        teamByPlayer[player] = "Blue"
    end
end

local function ensureLoadout(player, weaponName)
    weaponName = weaponName or "Rifle"
    local weaponStats = Config.Weapons[weaponName] or Config.Weapons.Rifle

    ammoByPlayer[player] = ammoByPlayer[player] or {
        weapon = weaponName,
        clip = weaponStats.clipSize,
        reserve = weaponStats.reserve,
        label = weaponStats.label,
    }

    ammoByPlayer[player].weapon = weaponName
    ammoByPlayer[player].clip = ammoByPlayer[player].clip or weaponStats.clipSize
    ammoByPlayer[player].reserve = ammoByPlayer[player].reserve or weaponStats.reserve
    ammoByPlayer[player].label = weaponStats.label

    if ammoByPlayer[player].clip <= 0 then
        ammoByPlayer[player].clip = 0
    end

    return ammoByPlayer[player]
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

local function setPlayerWeapon(player, weaponName)
    if weaponName and Config.Weapons[weaponName] then
        weaponByPlayer[player] = weaponName
    else
        weaponByPlayer[player] = "Rifle"
    end

    ensureLoadout(player, weaponByPlayer[player])
end

local function addKillFeed(text)
    table.insert(killFeed, { text = text, time = os.clock() })
    if #killFeed > 6 then
        table.remove(killFeed, 1)
    end
end

local function getSpawnPoint(player)
    local teamName = teamByPlayer[player] or "Red"
    local spawnList = Config.SpawnPoints[teamName] or Config.SpawnPoints.Red
    local index = (player.UserId % #spawnList) + 1
    return spawnList[index]
end

local function respawnPlayer(player)
    local character = player.Character or player.CharacterAdded:Wait()
    local root = character:WaitForChild("HumanoidRootPart")
    local humanoid = character:WaitForChild("Humanoid")

    root.CFrame = CFrame.new(getSpawnPoint(player))
    humanoid.WalkSpeed = Config.WalkSpeed
    humanoid.JumpPower = Config.JumpPower
    humanoid.Health = humanoid.MaxHealth
    humanoid.AutoRotate = true
end

local function getLoadoutForPlayer(player)
    local loadout = ensureLoadout(player, weaponByPlayer[player])
    if not loadout.label then
        loadout.label = Config.Weapons[weaponByPlayer[player] or "Rifle"].label
    end
    return loadout
end

local function getLeaderboardData()
    local data = {}

    for _, player in ipairs(Players:GetPlayers()) do
        local stats = player:FindFirstChild("leaderstats")
        local kills = stats and stats:FindFirstChild("Kills") and stats.Kills.Value or 0
        local deaths = stats and stats:FindFirstChild("Deaths") and stats.Deaths.Value or 0

        local alive = false
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            alive = humanoid and humanoid.Health > 0 or false
        end

        table.insert(data, {
            name = player.Name,
            kills = kills,
            deaths = deaths,
            alive = alive,
            team = teamByPlayer[player] or "Red",
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

local function broadcastHud()
    local payload = {
        state = roundState,
        roundTime = roundTime,
        players = getLeaderboardData(),
        killFeed = killFeed,
        winner = currentWinner,
        playerCount = #Players:GetPlayers(),
        readyCount = #Players:GetPlayers(),
        message = "",
        loadout = {},
        teams = {},
        reloading = {},
        currentMap = Config.Maps[currentMapIndex] or Config.Maps[1],
    }

    for _, player in ipairs(Players:GetPlayers()) do
        payload.loadout[player.Name] = getLoadoutForPlayer(player)
        payload.teams[player.Name] = teamByPlayer[player] or "Red"
        payload.reloading[player.Name] = reloadingByPlayer[player] == true
    end

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

local function computeWinner()
    local bestName = nil
    local bestKills = -1

    for _, player in ipairs(Players:GetPlayers()) do
        local stats = player:FindFirstChild("leaderstats")
        local kills = stats and stats:FindFirstChild("Kills") and stats.Kills.Value or 0

        if kills > bestKills then
            bestKills = kills
            bestName = player.Name
        end
    end

    return bestName
end

local function awardKill(killer, victim)
    if killer == victim then
        return
    end

    if killer.Team and victim.Team and killer.Team == victim.Team then
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

local function startLobby()
    roundState = "Lobby"
    roundTime = Config.LobbyLength
    currentWinner = nil
    killFeed = {}
    broadcastHud()
end

local function rotateMap()
    currentMapIndex = (currentMapIndex % #Config.Maps) + 1
    WorldBuilder.build(Workspace, Config, Config.Maps[currentMapIndex])
end

local function startMatch()
    roundState = "Live"
    roundTime = Config.MatchLength
    currentWinner = nil
    matchStartedAt = os.clock()
    rotateMap()
    broadcastHud()

    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            respawnPlayer(player)
        end
    end
end

local function finishMatch()
    roundState = "Round Over"
    roundTime = Config.RoundOverLength
    currentWinner = computeWinner()
    broadcastHud()
end

local function reloadWeapon(player)
    local weapon = weaponByPlayer[player] or "Rifle"
    local stats = Config.Weapons[weapon]
    local loadout = getLoadoutForPlayer(player)

    if reloadingByPlayer[player] then
        return
    end

    if loadout.clip >= stats.clipSize or loadout.reserve <= 0 then
        return
    end

    reloadingByPlayer[player] = true
    task.delay(stats.reloadTime, function()
        if player and player.Parent then
            local current = getLoadoutForPlayer(player)
            local needed = stats.clipSize - current.clip
            local amount = math.min(needed, current.reserve)
            current.clip += amount
            current.reserve -= amount
            reloadingByPlayer[player] = false
            broadcastHud()
        end
    end)

    broadcastHud()
end

local function handlePlayer(player)
    createLeaderstats(player)
    assignTeam(player)
    setPlayerWeapon(player, "Rifle")
    reloadingByPlayer[player] = false

    player.CharacterAdded:Connect(function()
        task.wait(0.2)
        respawnPlayer(player)
        broadcastHud()
    end)

    if player.Character then
        respawnPlayer(player)
    end
end

local function tryHitScan(player, weaponName, direction)
    if roundState ~= "Live" then
        return
    end

    if reloadingByPlayer[player] then
        return
    end

    if typeof(direction) ~= "Vector3" then
        return
    end

    if direction.Magnitude < 0.1 or direction.Magnitude > 1.5 then
        return
    end

    local character = player.Character
    if not character then
        return
    end

    local root = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid or humanoid.Health <= 0 then
        return
    end

    local loadout = getLoadoutForPlayer(player)
    if loadout.clip <= 0 then
        return
    end

    local weaponStats = Config.Weapons[weaponName] or Config.Weapons.Rifle
    local now = os.clock()
    if lastShotAt[player] and now - lastShotAt[player] < weaponStats.fireRate then
        return
    end
    lastShotAt[player] = now

    loadout.clip -= 1

    local lookVector = direction.Unit
    local jitter = (math.random() - 0.5) * weaponStats.spread
    local adjusted = (lookVector + Vector3.new(jitter, jitter * 0.5, 0)).Unit
    local origin = root.Position + Vector3.new(0, 2, 0)

    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = { character }

    local hit = Workspace:Raycast(origin, adjusted * 350, rayParams)
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

    if targetPlayer.Team and player.Team and targetPlayer.Team == player.Team then
        broadcastHud()
        return
    end

    local targetHumanoid = model:FindFirstChildOfClass("Humanoid")
    if not targetHumanoid or targetHumanoid.Health <= 0 then
        broadcastHud()
        return
    end

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

    broadcastHud()
end

Remotes.Shoot.OnServerEvent:Connect(function(player, weaponName, direction)
    if roundState ~= "Live" then
        return
    end

    if typeof(weaponName) ~= "string" or not Config.Weapons[weaponName] then
        return
    end

    setPlayerWeapon(player, weaponName)
    tryHitScan(player, weaponByPlayer[player], direction)
end)

Remotes.Reload.OnServerEvent:Connect(function(player)
    reloadWeapon(player)
end)

Remotes.MoveState.OnServerEvent:Connect(function(player, sprinting)
    local character = player.Character
    if not character then
        return
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        return
    end

    humanoid.WalkSpeed = sprinting and Config.SprintSpeed or Config.WalkSpeed
end)

Players.PlayerAdded:Connect(function(player)
    handlePlayer(player)
    broadcastHud()
end)

Players.PlayerRemoving:Connect(function(player)
    teamByPlayer[player] = nil
    weaponByPlayer[player] = nil
    ammoByPlayer[player] = nil
    reloadingByPlayer[player] = nil
end)

for _, player in ipairs(Players:GetPlayers()) do
    handlePlayer(player)
end

WorldBuilder.build(Workspace, Config, Config.Maps[currentMapIndex])
Lighting.TimeOfDay = 14
Lighting.Brightness = 2.5
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
