local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RivalsOriginalHUD"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

local lobbyPanel = Instance.new("Frame")
lobbyPanel.Size = UDim2.new(0.34, 0, 0.26, 0)
lobbyPanel.Position = UDim2.new(0.33, 0, 0.1, 0)
lobbyPanel.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
lobbyPanel.BackgroundTransparency = 0.2
lobbyPanel.BorderSizePixel = 0
lobbyPanel.Parent = screenGui

local lobbyTitle = Instance.new("TextLabel")
lobbyTitle.Size = UDim2.new(1, -20, 0, 28)
lobbyTitle.Position = UDim2.new(0, 10, 0, 6)
lobbyTitle.BackgroundTransparency = 1
lobbyTitle.Font = Enum.Font.GothamBold
lobbyTitle.Text = "LOBBY"
lobbyTitle.TextScaled = true
lobbyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
lobbyTitle.Parent = lobbyPanel

local classList = { "Scout", "Support", "Vanguard" }
local modeList = { "Casual", "Ranked" }
local classButtons = {}
local modeButtons = {}

local function createButton(parent, name, x, y, w, h, callback)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(w, 0, h, 0)
    button.Position = UDim2.new(x, 0, y, 0)
    button.BackgroundColor3 = Color3.fromRGB(31, 41, 55)
    button.BorderSizePixel = 0
    button.Font = Enum.Font.GothamBold
    button.Text = name
    button.TextScaled = true
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Parent = parent
    button.MouseButton1Click:Connect(callback)
    return button
end

for i, className in ipairs(classList) do
    local btn = createButton(lobbyPanel, className, (i - 1) * 0.3 + 0.06, 0.17, 0.24, 0.18, function()
        remotes.ClassSelect:FireServer(className)
    end)
    classButtons[className] = btn
end

for i, modeName in ipairs(modeList) do
    local btn = createButton(lobbyPanel, modeName, (i - 1) * 0.46 + 0.08, 0.42, 0.38, 0.18, function()
        remotes.ModeSelect:FireServer(modeName)
    end)
    modeButtons[modeName] = btn
end

local readyButton = createButton(lobbyPanel, "Ready", 0.34, 0.67, 0.32, 0.22, function()
    remotes.LobbyReady:FireServer(true)
end)

local shopButton = createButton(lobbyPanel, "Shop", 0.08, 0.67, 0.22, 0.22, function()
    -- future shop UI hook
end)

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(0.32, 0, 0.1, 0)
topBar.Position = UDim2.new(0.34, 0, 0.02, 0)
topBar.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
topBar.BackgroundTransparency = 0.15
topBar.BorderSizePixel = 0
topBar.Parent = screenGui

local teamLabel = Instance.new("TextLabel")
teamLabel.Size = UDim2.new(0.24, 0, 1, 0)
teamLabel.BackgroundTransparency = 1
teamLabel.Font = Enum.Font.GothamBold
teamLabel.Text = "RED"
teamLabel.TextScaled = true
teamLabel.TextColor3 = Color3.fromRGB(239, 68, 68)
teamLabel.Parent = topBar

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.38, 0, 1, 0)
statusLabel.Position = UDim2.new(0.25, 0, 0, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.GothamBold
statusLabel.Text = "READY"
statusLabel.TextScaled = true
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.Parent = topBar

local timerLabel = Instance.new("TextLabel")
timerLabel.Size = UDim2.new(0.34, 0, 1, 0)
timerLabel.Position = UDim2.new(0.66, 0, 0, 0)
timerLabel.BackgroundTransparency = 1
timerLabel.Font = Enum.Font.GothamSemibold
timerLabel.Text = "00:00"
timerLabel.TextScaled = true
timerLabel.TextColor3 = Color3.fromRGB(147, 197, 253)
timerLabel.Parent = topBar

local reloadLabel = Instance.new("TextLabel")
reloadLabel.Size = UDim2.new(0.18, 0, 0.04, 0)
reloadLabel.Position = UDim2.new(0.41, 0, 0.87, 0)
reloadLabel.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
reloadLabel.BackgroundTransparency = 0.15
reloadLabel.Font = Enum.Font.GothamBold
reloadLabel.Text = "READY"
reloadLabel.TextScaled = true
reloadLabel.TextColor3 = Color3.fromRGB(34, 197, 94)
reloadLabel.Parent = screenGui

local leaderboard = Instance.new("Frame")
leaderboard.Size = UDim2.new(0.22, 0, 0.34, 0)
leaderboard.Position = UDim2.new(0.02, 0, 0.08, 0)
leaderboard.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
leaderboard.BackgroundTransparency = 0.16
leaderboard.BorderSizePixel = 0
leaderboard.Parent = screenGui

local leaderboardTitle = Instance.new("TextLabel")
leaderboardTitle.Size = UDim2.new(1, -12, 0, 24)
leaderboardTitle.Position = UDim2.new(0, 6, 0, 6)
leaderboardTitle.BackgroundTransparency = 1
leaderboardTitle.Font = Enum.Font.GothamBold
leaderboardTitle.Text = "SCORE"
leaderboardTitle.TextColor3 = Color3.fromRGB(148, 163, 184)
leaderboardTitle.TextScaled = true
leaderboardTitle.Parent = leaderboard

local leaderboardList = Instance.new("ScrollingFrame")
leaderboardList.Size = UDim2.new(1, -12, 1, -36)
leaderboardList.Position = UDim2.new(0, 6, 0, 30)
leaderboardList.BackgroundTransparency = 1
leaderboardList.BorderSizePixel = 0
leaderboardList.ScrollBarThickness = 4
leaderboardList.Parent = leaderboard

local killFeedFrame = Instance.new("Frame")
killFeedFrame.Size = UDim2.new(0.25, 0, 0.18, 0)
killFeedFrame.Position = UDim2.new(0.75, 0, 0.12, 0)
killFeedFrame.BackgroundTransparency = 1
killFeedFrame.BorderSizePixel = 0
killFeedFrame.Parent = screenGui

local weaponFrame = Instance.new("Frame")
weaponFrame.Size = UDim2.new(0.18, 0, 0.08, 0)
weaponFrame.Position = UDim2.new(0.41, 0, 0.86, 0)
weaponFrame.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
weaponFrame.BackgroundTransparency = 0.18
weaponFrame.BorderSizePixel = 0
weaponFrame.Parent = screenGui

local weaponLabel = Instance.new("TextLabel")
weaponLabel.Size = UDim2.new(1, 0, 0.45, 0)
weaponLabel.BackgroundTransparency = 1
weaponLabel.Font = Enum.Font.GothamBlack
weaponLabel.Text = "RIFLE"
weaponLabel.TextScaled = true
weaponLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
weaponLabel.Parent = weaponFrame

local ammoLabel = Instance.new("TextLabel")
ammoLabel.Size = UDim2.new(1, 0, 0.45, 0)
ammoLabel.Position = UDim2.new(0, 0, 0.45, 0)
ammoLabel.BackgroundTransparency = 1
ammoLabel.Font = Enum.Font.GothamSemibold
ammoLabel.Text = "24 / 72"
ammoLabel.TextScaled = true
ammoLabel.TextColor3 = Color3.fromRGB(191, 219, 254)
ammoLabel.Parent = weaponFrame

local currentWeapon = "Rifle"
local currentAmmo = { weapon = "Rifle", clip = 24, reserve = 72 }
local recoilValue = 0
local weaponList = { "Rifle", "SMG", "Burst", "Shotgun", "DMR" }

local hitSound = Instance.new("Sound")
hitSound.SoundId = "rbxassetid://911903273"
hitSound.Volume = 0.4
hitSound.Parent = workspace

local killSound = Instance.new("Sound")
killSound.SoundId = "rbxassetid://911903273"
killSound.Volume = 0.55
killSound.Parent = workspace

local function formatTime(seconds)
    local minutes = math.floor(seconds / 60)
    local secs = seconds % 60
    return string.format("%02d:%02d", minutes, secs)
end

local function tweenIn(frame)
    local tween = TweenService:Create(frame, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = frame.Position + UDim2.new(0, 0, 0.02, 0),
        BackgroundTransparency = 0.12,
    })
    tween:Play()
end

local function tweenOut(frame)
    local tween = TweenService:Create(frame, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Position = frame.Position - UDim2.new(0, 0, 0.02, 0),
        BackgroundTransparency = 0.2,
    })
    tween:Play()
end

local function renderLeaderboard(entries)
    for _, child in ipairs(leaderboardList:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end

    local index = 0
    for _, entry in ipairs(entries or {}) do
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -8, 0, 22)
        label.Position = UDim2.new(0, 4, 0, index * 24)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.Text = string.format("%s  %d / %d", entry.name, entry.kills, entry.deaths)
        label.Parent = leaderboardList
        index += 1
    end
end

local function renderKillFeed(entries)
    for _, child in ipairs(killFeedFrame:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end

    local index = 0
    for _, entry in ipairs(entries or {}) do
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 22)
        label.Position = UDim2.new(0, 0, 0, index * 24)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.Gotham
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Text = entry.text
        label.Parent = killFeedFrame
        index += 1
    end
end

local function updateWeaponUI()
    weaponLabel.Text = string.upper(currentAmmo.weapon or "Rifle")
    ammoLabel.Text = string.format("%d / %d", currentAmmo.clip or 0, currentAmmo.reserve or 0)
end

local function updateHud(payload)
    if payload.state then
        statusLabel.Text = string.upper(tostring(payload.state))
    end

    if payload.roundTime ~= nil then
        timerLabel.Text = formatTime(payload.roundTime)
    end

    if payload.players then
        renderLeaderboard(payload.players)
    end

    if payload.killFeed then
        renderKillFeed(payload.killFeed)
    end

    if payload.teams and payload.teams[player.Name] then
        local teamName = payload.teams[player.Name]
        teamLabel.Text = string.upper(teamName)
        if teamName == "Blue" then
            teamLabel.TextColor3 = Color3.fromRGB(59, 130, 246)
        else
            teamLabel.TextColor3 = Color3.fromRGB(239, 68, 68)
        end
    end

    if payload.reloading and payload.reloading[player.Name] then
        reloadLabel.Text = "RELOADING"
        reloadLabel.TextColor3 = Color3.fromRGB(245, 158, 11)
    else
        reloadLabel.Text = "READY"
        reloadLabel.TextColor3 = Color3.fromRGB(34, 197, 94)
    end

    if payload.loadout and payload.loadout[player.Name] then
        currentAmmo = payload.loadout[player.Name]
        currentWeapon = currentAmmo.weapon or currentWeapon
        updateWeaponUI()
    end
end

remotes.Hud.OnClientEvent:Connect(function(payload)
    updateHud(payload)
end)

local function switchWeapon(nextWeapon)
    local valid = false
    for _, weapon in ipairs(weaponList) do
        if weapon == nextWeapon then
            valid = true
            break
        end
    end

    if not valid then
        return
    end

    currentWeapon = nextWeapon
    currentAmmo.weapon = nextWeapon
    updateWeaponUI()
end

local function fireWeapon()
    local camera = workspace.CurrentCamera
    if not camera then
        return
    end

    if (currentAmmo.clip or 0) <= 0 then
        return
    end

    recoilValue += 0.08
    remotes.Shoot:FireServer(currentWeapon, camera.CFrame.LookVector)
    hitSound:Play()
end

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then
        return
    end

    if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
        remotes.MoveState:FireServer(true)
    elseif input.KeyCode == Enum.KeyCode.Q then
        local index = 1
        for i, weapon in ipairs(weaponList) do
            if weapon == currentWeapon then
                index = i
                break
            end
        end

        index = index + 1
        if index > #weaponList then
            index = 1
        end
        switchWeapon(weaponList[index])
    elseif input.KeyCode == Enum.KeyCode.One then
        switchWeapon("Rifle")
    elseif input.KeyCode == Enum.KeyCode.Two then
        switchWeapon("SMG")
    elseif input.KeyCode == Enum.KeyCode.Three then
        switchWeapon("Burst")
    elseif input.KeyCode == Enum.KeyCode.Four then
        switchWeapon("Shotgun")
    elseif input.KeyCode == Enum.KeyCode.Five then
        switchWeapon("DMR")
    elseif input.KeyCode == Enum.KeyCode.R then
        remotes.Reload:FireServer()
    elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
        fireWeapon()
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
        remotes.MoveState:FireServer(false)
    end
end)

RunService.RenderStepped:Connect(function()
    local camera = workspace.CurrentCamera
    if camera and recoilValue > 0 then
        recoilValue = recoilValue * 0.82
        local cframe = camera.CFrame
        camera.CFrame = CFrame.new(cframe.Position) * CFrame.Angles(-recoilValue, 0, 0)
    end
end)

for _, button in pairs(classButtons) do
    button.MouseEnter:Connect(function()
        tweenIn(button)
    end)
    button.MouseLeave:Connect(function()
        tweenOut(button)
    end)
end

for _, button in pairs(modeButtons) do
    button.MouseEnter:Connect(function()
        tweenIn(button)
    end)
    button.MouseLeave:Connect(function()
        tweenOut(button)
    end)
end

readyButton.MouseEnter:Connect(function()
    tweenIn(readyButton)
end)
readyButton.MouseLeave:Connect(function()
    tweenOut(readyButton)
end)

updateWeaponUI()
