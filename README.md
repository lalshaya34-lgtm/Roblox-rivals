local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RivalsHUD"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local uiPanel = Instance.new("Frame")
uiPanel.Size = UDim2.new(0.28, 0, 0.12, 0)
uiPanel.Position = UDim2.new(0.36, 0, 0.02, 0)
uiPanel.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
uiPanel.BackgroundTransparency = 0.15
uiPanel.BorderSizePixel = 0
uiPanel.Parent = screenGui

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0.5, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextScaled = true
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.Text = "LIVE"
statusLabel.Parent = uiPanel

local timerLabel = Instance.new("TextLabel")
timerLabel.Size = UDim2.new(1, 0, 0.5, 0)
timerLabel.Position = UDim2.new(0, 0, 0.5, 0)
timerLabel.BackgroundTransparency = 1
timerLabel.Font = Enum.Font.GothamSemibold
timerLabel.TextScaled = true
timerLabel.TextColor3 = Color3.fromRGB(191, 219, 254)
timerLabel.Text = "03:00"
timerLabel.Parent = uiPanel

local scorePanel = Instance.new("ScrollingFrame")
scorePanel.Size = UDim2.new(0.25, 0, 0.34, 0)
scorePanel.Position = UDim2.new(0.02, 0, 0.08, 0)
scorePanel.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
scorePanel.BackgroundTransparency = 0.14
scorePanel.BorderSizePixel = 0
scorePanel.ScrollBarThickness = 4
scorePanel.AutomaticCanvasSize = Enum.AutomaticSize.Y
scorePanel.Parent = screenGui

local crosshair = Instance.new("Frame")
crosshair.Size = UDim2.new(0, 22, 0, 22)
crosshair.Position = UDim2.new(0.5, -11, 0.5, -11)
crosshair.BackgroundTransparency = 1
crosshair.BorderSizePixel = 0
crosshair.Parent = screenGui

local lineH = Instance.new("Frame")
lineH.Size = UDim2.new(0, 2, 1, 0)
lineH.Position = UDim2.new(0.5, -1, 0.5, -11)
lineH.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
lineH.BorderSizePixel = 0
lineH.Parent = crosshair

local lineV = Instance.new("Frame")
lineV.Size = UDim2.new(1, 0, 0, 2)
lineV.Position = UDim2.new(0.5, -11, 0.5, -1)
lineV.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
lineV.BorderSizePixel = 0
lineV.Parent = crosshair

local function formatTime(value)
    local minutes = math.floor(value / 60)
    local seconds = value % 60
    return string.format("%02d:%02d", minutes, seconds)
end

local function renderPlayers(entries)
    for _, child in ipairs(scorePanel:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end

    for index, entry in ipairs(entries or {}) do
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -12, 0, 28)
        label.Position = UDim2.new(0, 6, 0, index * 30)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.Text = string.format("%s  %d / %d", entry.name, entry.kills, entry.deaths)
        label.Parent = scorePanel
    end
end

local function updateHud(data)
    if data and data.state then
        statusLabel.Text = tostring(data.state):upper()
    end

    if data and data.roundTime ~= nil then
        timerLabel.Text = formatTime(data.roundTime)
    end

    if data and data.players then
        renderPlayers(data.players)
    end
end

Remotes.Hud.OnClientEvent:Connect(function(data)
    updateHud(data)
end)

local function fireWeapon()
    local camera = Workspace.CurrentCamera
    if not camera then
        return
    end

    local look = camera.CFrame.LookVector
    Remotes.Shoot:FireServer(look)
end

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then
        return
    end

    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        fireWeapon()
    end
end)

updateHud({
    state = "Lobby",
    roundTime = 180,
    players = {}
})
