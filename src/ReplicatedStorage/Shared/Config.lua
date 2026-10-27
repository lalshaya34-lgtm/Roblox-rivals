local Config = {
    LobbyLength = 12,
    MatchLength = 150,
    RoundOverLength = 6,
    RespawnDelay = 1.5,

    WalkSpeed = 16,
    SprintSpeed = 22,
    JumpPower = 50,
    ArenaSize = 220,

    Maps = {
        "Lattice",
        "Crimson",
        "Nightfall"
    },

    TeamColors = {
        Red = Color3.fromRGB(239, 68, 68),
        Blue = Color3.fromRGB(59, 130, 246),
    },

    SpawnPoints = {
        Red = {
            Vector3.new(-42, 8, -34),
            Vector3.new(-42, 8, 34),
            Vector3.new(-18, 8, 0),
            Vector3.new(0, 8, -52),
        },
        Blue = {
            Vector3.new(42, 8, -34),
            Vector3.new(42, 8, 34),
            Vector3.new(18, 8, 0),
            Vector3.new(0, 8, 52),
        }
    },

    Weapons = {
        Rifle = {
            damage = 26,
            fireRate = 0.12,
            spread = 0.04,
            recoil = 0.12,
            clipSize = 24,
            reserve = 96,
            reloadTime = 1.2,
            label = "Rifle",
            color = Color3.fromRGB(96, 165, 250)
        },
        SMG = {
            damage = 18,
            fireRate = 0.08,
            spread = 0.08,
            recoil = 0.16,
            clipSize = 32,
            reserve = 120,
            reloadTime = 1.05,
            label = "SMG",
            color = Color3.fromRGB(52, 211, 153)
        },
        Burst = {
            damage = 22,
            fireRate = 0.15,
            spread = 0.054,
            recoil = 0.17,
            clipSize = 18,
            reserve = 72,
            reloadTime = 1.3,
            label = "Burst",
            color = Color3.fromRGB(251, 191, 36)
        },
        Shotgun = {
            damage = 12,
            fireRate = 0.72,
            spread = 0.18,
            recoil = 0.22,
            clipSize = 6,
            reserve = 30,
            reloadTime = 1.8,
            label = "Shotgun",
            pellets = 7,
            color = Color3.fromRGB(240, 128, 128)
        },
        DMR = {
            damage = 38,
            fireRate = 0.28,
            spread = 0.03,
            recoil = 0.14,
            clipSize = 12,
            reserve = 48,
            reloadTime = 1.5,
            label = "DMR",
            color = Color3.fromRGB(168, 85, 247)
        }
    },

    Pickups = {
        Health = {
            color = Color3.fromRGB(34, 197, 94),
            respawn = 9,
            amount = 28
        },
        Boost = {
            color = Color3.fromRGB(59, 130, 246),
            respawn = 8,
            speedBoost = 6,
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
        Accent = Color3.fromRGB(56, 189, 248),
        AccentDark = Color3.fromRGB(29, 78, 216),
        Border = Color3.fromRGB(148, 163, 184),
        Panel = Color3.fromRGB(15, 23, 42),
        Text = Color3.fromRGB(248, 250, 252),
        Muted = Color3.fromRGB(148, 163, 184),
        Warning = Color3.fromRGB(245, 158, 11),
        Victory = Color3.fromRGB(250, 204, 21)
    }
}

return Config
