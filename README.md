local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local currentWeapon = "Rifle"
local recoilValue = 0

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RivalsHUD"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(0.28, 0, 0.1, 0)
topBar.Position = UDim2.new(0.36, 0, 0.02, 0)
topBar.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
topBar.BackgroundTransparency = 0.18
topBar.BorderSizePixel = 0
topBar.Parent = screenGui

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.45, 0, 1, 0)
statusLabel.Position = UDim2.new(0, 0, 0, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextScaled = true
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.Text = "LIVE"
statusLabel.Parent = topBar

local timerLabel = Instance.new("TextLabel")
timerLabel.Size = UDim2.new(0.45, 0, 1, 0)
timerLabel.Position = UDim2.new(0.55, 0, 0, 0)
timerLabel.BackgroundTransparency = 1
timerLabel.Font = Enum.Font.GothamSemibold
timerLabel.TextScaled = true
timerLabel.TextColor3 = Color3.fromRGB(191, 219, 254)
timerLabel.Text = "02:30"
timerLabel.Parent = topBar

local weaponLabel = Instance.new("TextLabel")
weaponLabel.Size = UDim2.new(0.12, 0, 0.04, 0)
weaponLabel.Position = UDim2.new(0.86, 0, 0.02, 0)
weaponLabel.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
weaponLabel.BackgroundTransparency = 0.18
weaponLabel.BorderSizePixel = 0
weaponLabel.Font = Enum.Font.GothamBold
weaponLabel.Text = "RIFLE"
weaponLabel.TextScaled = true
weaponLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
weaponLabel.Parent = screenGui

local leaderboard = Instance.new("Frame")
leaderboard.Size = UDim2.new(0.22, 0, 0.36, 0)
leaderboard.Position = UDim2.new(0.02, 0, 0.08, 0)
leaderboard.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
leaderboard.BackgroundTransparency = 0.18
leaderboard.BorderSizePixel = 0
leaderboard.Parent = screenGui

local boardTitle = Instance.new("TextLabel")
boardTitle.Size = UDim2.new(1, -12, 0, 24)
boardTitle.Position = UDim2.new(0, 6, 0, 4)
boardTitle.BackgroundTransparency = 1
boardTitle.Font = Enum.Font.GothamBold
boardTitle.Text = "SCORE"
boardTitle.TextScaled = true
boardTitle.TextColor3 = Color3.fromRGB(148, 163, 184)
boardTitle.Parent = leaderboard

local boardList = Instance.new("ScrollingFrame")
boardList.Size = UDim2.new(1, -12, 1, -34)
boardList.Position = UDim2.new(0, 6, 0, 30)
boardList.BackgroundTransparency = 1
boardList.BorderSizePixel = 0
boardList.ScrollBarThickness = 4
boardList.AutomaticCanvasSize = Enum.AutomaticSize.Y
boardList.Parent = leaderboard

local lobbyPanel = Instance.new("Frame")
lobbyPanel.Size = UDim2.new(0.24, 0, 0.08, 0)
lobbyPanel.Position = UDim2.new(0.38, 0, 0.18, 0)
lobbyPanel.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
lobbyPanel.BackgroundTransparency = 0.18
lobbyPanel.BorderSizePixel = 0
lobbyPanel.Visible = false
lobbyPanel.Parent = screenGui

local lobbyText = Instance.new("TextLabel")
lobbyText.Size = UDim2.new(1, 0, 1, 0)
lobbyText.BackgroundTransparency = 1
lobbyText.Font = Enum.Font.GothamBold
lobbyText.TextScaled = true
lobbyText.TextColor3 = Color3.fromRGB(255, 255, 255)
lobbyText.Text = "READY 0 / 0"
lobbyText.Parent = lobbyPanel

local announcement = Instance.new("TextLabel")
announcement.Size = UDim2.new(0.42, 0, 0.055, 0)
announcement.Position = UDim2.new(0.29, 0, 0.12, 0)
announcement.BackgroundTransparency = 1
announcement.Font = Enum.Font.GothamBold
announcement.TextScaled = true
announcement.TextColor3 = Color3.fromRGB(255, 255, 255)
announcement.Text = "READY"
announcement.Parent = screenGui

local killFeedFrame = Instance.new("Frame")
killFeedFrame.Size = UDim2.new(0.24, 0, 0.18, 0)
killFeedFrame.Position = UDim2.new(0.75, 0, 0.12, 0)
killFeedFrame.BackgroundTransparency = 1
killFeedFrame.BorderSizePixel = 0
killFeedFrame.Parent = screenGui

local winnerFrame = Instance.new("Frame")
winnerFrame.Size = UDim2.new(0.4, 0, 0.16, 0)
winnerFrame.Position = UDim2.new(0.3, 0, 0.42, 0)
winnerFrame.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
winnerFrame.BackgroundTransparency = 0.12
winnerFrame.BorderSizePixel = 0
winnerFrame.Visible = false
winnerFrame.Parent = screenGui

local winnerLabel = Instance.new("TextLabel")
winnerLabel.Size = UDim2.new(1, -20, 1, -20)
winnerLabel.Position = UDim2.new(0, 10, 0, 10)
winnerLabel.BackgroundTransparency = 1
winnerLabel.Font = Enum.Font.GothamBlack
winnerLabel.TextScaled = true
winnerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
winnerLabel.Text = "WINNER: Player"
winnerLabel.Parent = winnerFrame

local crosshair = Instance.new("Frame")
crosshair.Size = UDim2.new(0, 22, 0, 22)
crosshair.Position = UDim2.new(0.5, -11, 0.5, -11)
crosshair.BackgroundTransparency = 1
crosshair.BorderSizePixel = 0
crosshair.Parent = screenGui

local horizontalLine = Instance.new("Frame")
horizontalLine.Size = UDim2.new(0, 2, 1, 0)
horizontalLine.Position = UDim2.new(0.5, -1, 0.5, -11)
horizontalLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
horizontalLine.BorderSizePixel = 0
horizontalLine.Parent = crosshair

local verticalLine = Instance.new("Frame")
verticalLine.Size = UDim2.new(1, 0, 0, 2)
verticalLine.Position = UDim2.new(0.5, -11, 0.5, -1)
verticalLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
verticalLine.BorderSizePixel = 0
verticalLine.Parent = crosshair

local function formatTime(seconds)
    local minutes = math.floor(seconds / 60)
    local secondsLeft = seconds % 60
    return string.format("%02d:%02d", minutes, secondsLeft)
end

local function renderLeaderboard(entries)
    for _, child in ipairs(boardList:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end

    local index = 0
    for _, entry in ipairs(entries or {}) do
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -8, 0, 24)
        label.Position = UDim2.new(0, 4, 0, index * 26)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.Text = string.format("%s  %d / %d", entry.name, entry.kills, entry.deaths)
        label.Parent = boardList
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
        label.Size = UDim2.new(1, 0, 0, 24)
        label.Position = UDim2.new(0, 0, 0, index * 26)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.Gotham
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Text = entry.text
        label.Parent = killFeedFrame
        index += 1
    end
end

local function updateHud(payload)
    if payload.state then
        statusLabel.Text = tostring(payload.state):upper()
    end

    if payload.roundTime ~= nil then
        timerLabel.Text = formatTime(payload.roundTime)
    end

    if payload.message then
        announcement.Text = tostring(payload.message):upper()
    end

    if payload.players then
        renderLeaderboard(payload.players)
    end

    if payload.killFeed then
        renderKillFeed(payload.killFeed)
    end

    if payload.playerCount ~= nil and payload.readyCount ~= nil then
        lobbyPanel.Visible = payload.state == "Lobby"
        lobbyText.Text = string.format("READY %d / %d", payload.readyCount, payload.playerCount)
    end

    if payload.winner then
        winnerFrame.Visible = true
        winnerLabel.Text = "WINNER: " .. tostring(payload.winner)
    else
        winnerFrame.Visible = false
    end

    if payload.weapon and payload.weapon[player.Name] then
        currentWeapon = payload.weapon[player.Name]
        weaponLabel.Text = currentWeapon:upper()
    end
end

Remotes.Hud.OnClientEvent:Connect(function(payload)
    updateHud(payload)
end)

local function switchWeapon(newWeapon)
    if newWeapon == "Rifle" or newWeapon == "SMG" then
        currentWeapon = newWeapon
        weaponLabel.Text = currentWeapon:upper()
    end
end

local function fireWeapon()
    local camera = Workspace.CurrentCamera
    if not camera then
        return
    end

    local lookVector = camera.CFrame.LookVector
    recoilValue += 0.08
    Remotes.Shoot:FireServer(currentWeapon, lookVector)
end

RunService.RenderStepped:Connect(function()
    local camera = Workspace.CurrentCamera
    if camera and recoilValue > 0 then
        recoilValue = recoilValue * 0.82
        local cframe = camera.CFrame
        camera.CFrame = CFrame.new(cframe.Position) * CFrame.Angles(-recoilValue, 0, 0)
    end
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then
        return
    end

    if input.KeyCode == Enum.KeyCode.Q then
        if currentWeapon == "Rifle" then
            switchWeapon("SMG")
        else
            switchWeapon("Rifle")
        end
    elseif input.KeyCode == Enum.KeyCode.One then
        switchWeapon("Rifle")
    elseif input.KeyCode == Enum.KeyCode.Two then
        switchWeapon("SMG")
    elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
        fireWeapon()
    end
end)

updateHud({
    state = "Lobby",
    roundTime = 8,
    message = "READY",
    players = {},
    killFeed = {},
    playerCount = 0,
    readyCount = 0,
    winner = nil,
    weapon = { [player.Name] = currentWeapon }
})
