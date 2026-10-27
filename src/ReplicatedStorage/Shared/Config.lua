local Config = {
    MatchLength = 150,
    LobbyLength = 8,
    RespawnDelay = 1.6,
    Damage = 25,
    FireRate = 0.12,
    HitRange = 360,
    WalkSpeed = 16,
    JumpPower = 50,
    ArenaSize = 220,
    SpawnPoints = {
        Vector3.new(-42, 8, -34),
        Vector3.new(42, 8, -34),
        Vector3.new(-42, 8, 34),
        Vector3.new(42, 8, 34),
        Vector3.new(0, 8, -52),
        Vector3.new(0, 8, 52),
        Vector3.new(-56, 8, 0),
        Vector3.new(56, 8, 0)
    },
    Colors = {
        Floor = Color3.fromRGB(15, 23, 42),
        Arena = Color3.fromRGB(30, 41, 59),
        Accent = Color3.fromRGB(59, 130, 246),
        AccentDark = Color3.fromRGB(30, 64, 175),
        Border = Color3.fromRGB(148, 163, 184),
        Panel = Color3.fromRGB(15, 23, 42),
        Text = Color3.fromRGB(248, 250, 252),
        Muted = Color3.fromRGB(148, 163, 184),
        Warning = Color3.fromRGB(245, 158, 11)
    }
}

return Config
