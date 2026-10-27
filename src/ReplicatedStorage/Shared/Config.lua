local Config = {
    LobbyLength = 8,
    MatchLength = 120,
    RoundOverLength = 5,
    RespawnDelay = 1.4,

    WalkSpeed = 16,
    SprintSpeed = 22,
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
        Vector3.new(56, 8, 0),
        Vector3.new(-18, 8, 0),
        Vector3.new(18, 8, 0)
    },

    Weapons = {
        Rifle = {
            damage = 26,
            fireRate = 0.12,
            spread = 0.04,
            recoil = 0.12,
            clipSize = 24,
            reserve = 84,
            reloadTime = 1.25,
            label = "Rifle"
        },
        SMG = {
            damage = 17,
            fireRate = 0.07,
            spread = 0.08,
            recoil = 0.18,
            clipSize = 32,
            reserve = 96,
            reloadTime = 1.1,
            label = "SMG"
        },
        Burst = {
            damage = 22,
            fireRate = 0.16,
            spread = 0.05,
            recoil = 0.15,
            clipSize = 18,
            reserve = 54,
            reloadTime = 1.3,
            label = "Burst"
        },
        Shotgun = {
            damage = 12,
            fireRate = 0.7,
            spread = 0.18,
            recoil = 0.22,
            clipSize = 6,
            reserve = 30,
            reloadTime = 1.7,
            label = "Shotgun",
            pellets = 7
        },
        DMR = {
            damage = 34,
            fireRate = 0.25,
            spread = 0.03,
            recoil = 0.14,
            clipSize = 12,
            reserve = 42,
            reloadTime = 1.45,
            label = "DMR"
        }
    },

    Pickups = {
        Health = {
            color = Color3.fromRGB(34, 197, 94),
            respawn = 9,
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
