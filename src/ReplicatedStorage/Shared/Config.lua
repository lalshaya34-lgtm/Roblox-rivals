local Config = {
    MatchLength = 180,
    LobbyLength = 10,
    ArenaSize = 180,
    Damage = 25,
    FireRate = 0.12,
    HitRange = 300,
    RespawnDelay = 2,
    SpawnPoints = {
        Vector3.new(-36, 8, -34),
        Vector3.new(36, 8, -34),
        Vector3.new(-36, 8, 34),
        Vector3.new(36, 8, 34),
        Vector3.new(0, 8, -48),
        Vector3.new(0, 8, 48)
    },
    ArenaColor = Color3.fromRGB(31, 42, 58),
    FloorColor = Color3.fromRGB(15, 23, 42),
    AccentColor = Color3.fromRGB(59, 130, 246),
    AccentDark = Color3.fromRGB(37, 99, 235),
    PanelColor = Color3.fromRGB(15, 23, 42),
    TextColor = Color3.fromRGB(248, 250, 252),
    BorderColor = Color3.fromRGB(148, 163, 184)
}

return Config
