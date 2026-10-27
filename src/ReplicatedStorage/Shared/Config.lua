local Config = {
    LobbyLength = 8,
    MatchLength = 120,
    RoundOverLength = 4,
    RespawnDelay = 1.4,

    WalkSpeed = 16,
    SprintSpeed = 20,
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

    Weapons = {
        Rifle = {
            damage = 26,
            fireRate = 0.12,
            spread = 0.03,
            recoil = 0.12,
            clipSize = 24,
            reserve = 72,
            reloadTime = 1.4,
            label = "Rifle"
        },
        SMG = {
            damage = 18,
            fireRate = 0.07,
            spread = 0.06,
            recoil = 0.18,
            clipSize = 32,
            reserve = 96,
            reloadTime = 1.1,
            label = "SMG"
        }
    },

    Pickups = {
        Health = {
            color = Color3.fromRGB(34, 197, 94),
            respawn = 8,
            amount = 25
        },
        Boost = {
            color = Color3.fromRGB(59, 130, 246),
            respawn = 8,
            speed = 22,
            duration = 4
        },
        Ammo = {
            color = Color3.fromRGB(245, 158, 11),
            respawn = 8,
            bonus = 16
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
