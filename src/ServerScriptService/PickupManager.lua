local PickupManager = {}

local function createPickup(parent, name, color, position, size)
    local pickup = parent:FindFirstChild(name)
    if pickup then
        pickup.Position = position
        pickup.Size = size or Vector3.new(2, 2, 2)
        pickup.Color = color
        return pickup
    end

    pickup = Instance.new("Part")
    pickup.Name = name
    pickup.Shape = Enum.PartType.Cylinder
    pickup.Size = size or Vector3.new(2, 2, 2)
    pickup.Position = position
    pickup.Anchored = true
    pickup.Material = Enum.Material.Neon
    pickup.Color = color
    pickup.CanCollide = false
    pickup.Parent = parent
    return pickup
end

function PickupManager.spawnArenaPickups(parent, config)
    if not parent then
        return {}
    end

    local spawns = {
        { name = "HealthPack1", color = config.Pickups.Health.color, position = Vector3.new(-28, 3, -18) },
        { name = "HealthPack2", color = config.Pickups.Health.color, position = Vector3.new(28, 3, 18) },
        { name = "AmmoPack1", color = config.Pickups.Ammo.color, position = Vector3.new(0, 3, -32) },
        { name = "BoostPack1", color = config.Pickups.Boost.color, position = Vector3.new(-18, 3, 28) },
        { name = "BoostPack2", color = config.Pickups.Boost.color, position = Vector3.new(18, 3, -28) },
    }

    local created = {}
    for _, spawn in ipairs(spawns) do
        local pickup = createPickup(parent, spawn.name, spawn.color, spawn.position)
        table.insert(created, pickup)
    end

    return created
end

return PickupManager
