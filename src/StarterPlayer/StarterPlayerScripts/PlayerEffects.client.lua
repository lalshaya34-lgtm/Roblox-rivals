local PickupManager = {}
PickupManager.__index = PickupManager

function PickupManager.new(Workspace, Config, onPickup)
    local instance = {
        Workspace = Workspace,
        Config = Config,
        OnPickup = onPickup,
        Active = true,
        Pickups = {},
    }

    return setmetatable(instance, PickupManager)
end

local function createPickup(kind, config, position)
    local pickup = Instance.new("Part")
    pickup.Name = kind .. "Pickup"
    pickup.Shape = Enum.PartType.Ball
    pickup.Size = Vector3.new(2.4, 2.4, 2.4)
    pickup.Material = Enum.Material.Neon
    pickup.Color = config.color
    pickup.Anchored = true
    pickup.CanCollide = false
    pickup.CFrame = CFrame.new(position)
    pickup.Parent = workspace

    local pointLight = Instance.new("PointLight")
    pointLight.Brightness = 1.2
    pointLight.Color = config.color
    pointLight.Range = 10
    pointLight.Parent = pickup

    return pickup
end

function PickupManager:_spawnPickup(kind)
    local config = self.Config.Pickups[kind]
    if not config then
        return
    end

    local position = Vector3.new(
        math.random(-80, 80),
        5,
        math.random(-80, 80)
    )

    local pickup = createPickup(kind, config, position)
    self.Pickups[#self.Pickups + 1] = pickup

    local connection
    connection = pickup.Touched:Connect(function(hit)
        local model = hit.Parent
        if not model then
            return
        end

        local player = game.Players:GetPlayerFromCharacter(model)
        if not player then
            return
        end

        if self.OnPickup then
            self.OnPickup(player, kind)
        end

        if connection then
            connection:Disconnect()
        end

        pickup:Destroy()

        task.delay(config.respawn or 8, function()
            if self.Active then
                self:_spawnPickup(kind)
            end
        end)
    end)
end

function PickupManager:Start()
    self.Active = true
    for kind, _ in pairs(self.Config.Pickups) do
        self:_spawnPickup(kind)
    end
end

function PickupManager:Stop()
    self.Active = false
    for _, pickup in ipairs(self.Pickups) do
        if pickup and pickup.Parent then
            pickup:Destroy()
        end
    end
    self.Pickups = {}
end

return PickupManager
