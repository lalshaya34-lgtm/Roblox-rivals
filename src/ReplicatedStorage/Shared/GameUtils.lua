local GameUtils = {}

function GameUtils.clamp(value, min, max)
    if value < min then
        return min
    end
    if value > max then
        return max
    end
    return value
end

function GameUtils.round(value, digits)
    digits = digits or 0
    local factor = 10 ^ digits
    return math.floor(value * factor + 0.5) / factor
end

function GameUtils.lerp(startValue, endValue, t)
    return startValue + (endValue - startValue) * t
end

function GameUtils.randomChoice(list)
    if not list or #list == 0 then
        return nil
    end

    return list[math.random(1, #list)]
end

function GameUtils.getArenaSpawn(index, count, radius)
    local angle = (index / count) * math.pi * 2
    local x = math.cos(angle) * radius
    local z = math.sin(angle) * radius
    return Vector3.new(x, 8, z)
end

return GameUtils
