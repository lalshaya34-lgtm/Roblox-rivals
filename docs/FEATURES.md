local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RivalsEffects"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

local crosshair = Instance.new("Frame")
crosshair.Size = UDim2.new(0, 20, 0, 20)
crosshair.BackgroundTransparency = 1
crosshair.Position = UDim2.new(0.5, -10, 0.5, -10)
crosshair.Parent = screenGui

local horizontal = Instance.new("Frame")
horizontal.Size = UDim2.new(0, 2, 1, 0)
horizontal.Position = UDim2.new(0.5, -1, 0.5, -10)
horizontal.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
horizontal.BorderSizePixel = 0
horizontal.Parent = crosshair

local vertical = Instance.new("Frame")
vertical.Size = UDim2.new(1, 0, 0, 2)
vertical.Position = UDim2.new(0.5, -10, 0.5, -1)
vertical.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
vertical.BorderSizePixel = 0
vertical.Parent = crosshair

local function pulseCrosshair()
    local tweenIn = TweenService:Create(crosshair, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 24, 0, 24),
    })
    local tweenOut = TweenService:Create(crosshair, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 20, 0, 20),
    })

    tweenIn:Play()
    tweenIn.Completed:Wait()
    tweenOut:Play()
end

local function createHitMarker()
    local marker = Instance.new("TextLabel")
    marker.Size = UDim2.new(0, 26, 0, 26)
    marker.Position = UDim2.new(0.5, -13, 0.5, -13)
    marker.BackgroundTransparency = 1
    marker.Font = Enum.Font.GothamBold
    marker.Text = "+"
    marker.TextColor3 = Color3.fromRGB(56, 189, 248)
    marker.TextStrokeTransparency = 0.3
    marker.TextScaled = true
    marker.Parent = screenGui

    local entering = TweenService:Create(marker, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        TextTransparency = 0,
        Position = UDim2.new(0.5, -13, 0.5, -15),
    })
    local leaving = TweenService:Create(marker, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        TextTransparency = 1,
        Position = UDim2.new(0.5, -13, 0.5, -18),
    })

    entering:Play()
    entering.Completed:Wait()
    leaving:Play()
    task.delay(0.2, function()
        if marker.Parent then
            marker:Destroy()
        end
    end)
end

local function onTick()
    pulseCrosshair()
end

task.spawn(function()
    while true do
        task.wait(3)
        onTick()
    end
end)

-- Example polish hook for future event-driven usage
player.CharacterAdded:Connect(function()
    task.wait(0.25)
    createHitMarker()
end)

createHitMarker()
