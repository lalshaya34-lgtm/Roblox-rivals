local TweenService = game:GetService("TweenService")

local Effects = {}

function Effects.spawnImpactBurst(parent, position, color)
    local burst = Instance.new("Part")
    burst.Name = "ImpactBurst"
    burst.Anchored = true
    burst.CanCollide = false
    burst.Transparency = 0.2
    burst.Material = Enum.Material.Neon
    burst.Color = color or Color3.fromRGB(255, 255, 255)
    burst.Shape = Enum.PartType.Cylinder
    burst.Size = Vector3.new(0.4, 0.4, 0.4)
    burst.CFrame = CFrame.new(position)
    burst.Parent = parent

    local tween = TweenService:Create(burst, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = Vector3.new(0.8, 0.8, 0.8),
        Transparency = 1,
    })
    tween:Play()

    task.delay(0.45, function()
        if burst and burst.Parent then
            burst:Destroy()
        end
    end)
end

function Effects.spawnFloatingText(parent, text, position, color)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "FloatingText"
    billboard.Size = UDim2.new(0, 160, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.Text = text
    label.TextScaled = true
    label.TextColor3 = color or Color3.fromRGB(255, 255, 255)
    label.TextStrokeTransparency = 0.35
    label.Parent = billboard

    billboard.Adornee = parent
    billboard.StudsOffsetWorldSpace = position

    local tween = TweenService:Create(billboard, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        StudsOffset = Vector3.new(0, 5, 0),
    })
    tween:Play()

    task.delay(0.8, function()
        if billboard and billboard.Parent then
            billboard:Destroy()
        end
    end)
end

return Effects
