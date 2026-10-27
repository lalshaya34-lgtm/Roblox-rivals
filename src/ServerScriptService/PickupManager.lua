local ArenaBuilder = {}

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
    part.Color = color or Color3.fromRGB(30, 41, 59)
    part.Size = size or Vector3.new(1, 1, 1)
    part.CFrame = cframe or CFrame.new()
    part.Parent = parent
    return part
end

function ArenaBuilder.buildArena(Workspace, Config)
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

    local obstacleConfigs = {
        {"A1", Vector3.new(18, 16, 18), CFrame.new(-42, 8, -12)},
        {"A2", Vector3.new(18, 16, 18), CFrame.new(42, 8, -12)},
        {"A3", Vector3.new(18, 18, 18), CFrame.new(-42, 9, 32)},
        {"A4", Vector3.new(18, 18, 18), CFrame.new(42, 9, 32)},
        {"A5", Vector3.new(20, 12, 20), CFrame.new(0, 6, -38)},
        {"A6", Vector3.new(20, 12, 20), CFrame.new(0, 6, 38)},
    }

    for _, data in ipairs(obstacleConfigs) do
        ensurePart(arena, data[1], data[2], data[3], Config.Colors.AccentDark, Enum.Material.SmoothPlastic)
    end

    local neonRing = ensurePart(arena, "NeonRing", Vector3.new(218, 1, 218), CFrame.new(0, 1, 0), Config.Colors.Accent, Enum.Material.Neon)
    neonRing.Material = Enum.Material.Neon

    return arena
end

return ArenaBuilder
