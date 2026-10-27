local Config = {
    LobbyLength = 8,
    MatchLength = 150,
    RoundOverLength = 4,
    RespawnDelay = 1.5,
    WalkSpeed = 16,
    JumpPower = 50,

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

    Weapons = {
        Rifle = {
            damage = 26,
            fireRate = 0.12,
            spread = 0.03,
            recoil = 0.12,
            label = "Rifle"
        },
        SMG = {
            damage = 18,
            fireRate = 0.07,
            spread = 0.06,
            recoil = 0.18,
            label = "SMG"
        }
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
