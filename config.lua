return {
    dropCheaters = true,
    interact = 'target', -- Can choose target or textui
    interactDistance = 3.0,
    knockTime = 2, -- Seconds player will knock for
    knockCooldown = 5, -- Cooldown for knocking on the same door (minutes)
    progressCircle = false, -- If lib progressCircle should be used instead of progressBar

    

    treatAmount = { min = 1, max = 3 },
    treats = {
        'pinkcandy',
        'goldcandy',
        'bluecandy'
    },

    trickChance = 30, -- Chance out of 100 that player will be tricked (30 = 30%)
    trickPeds = {
        `u_m_y_zombie_01`,
        `u_m_m_prolsec_01`,
        `s_m_y_clown_01`
    },
    trickWeapons = {
        `weapon_bat`,
        `weapon_knife`
    },
   
    houses = {
        vec3(997.2715, -729.3481, 57.8157), 
        vec3(979.4079, -715.9713, 58.1953), 
        vec3(970.8149, -701.0120, 58.4819), 
        vec3(960.0812, -669.7868, 58.4497), 
        vec3(943.2621, -653.2900, 58.6245), 
        vec3(929.1337, -639.5745, 58.2423), 
        vec3(903.1448, -615.7040, 58.4533), 
        vec3(887.0035, -607.9677, 58.4452), 
        vec3(861.8168, -583.4221, 58.1565),
        vec3(844.0830, -563.1010, 57.8330), 
        vec3(850.6271, -532.6888, 57.9254),
        vec3(862.6976, -510.0627, 57.3290),
        vec3(878.5829, -498.3254, 58.0508),
        vec3(906.1165, -489.5460, 59.4363), 
        vec3(921.9830, -478.7280, 61.0751),
        vec3(892.7626, -540.4281, 58.5064),
        vec3(946.1136, -518.7518, 60.6285),
        vec3(970.4336, -502.4149, 62.1409),
        vec3(1013.6656, -468.2202, 64.2866),
        vec3(988.0172, -433.1499, 63.8900),
        vec3(1010.9377, -422.9984, 64.9527),
        vec3(1029.2578, -408.8338, 65.9493),
        vec3(1060.8857, -378.5012, 68.2313),
        vec3(967.3074, -451.9421, 62.8147),
        vec3(944.1469, -463.4460, 61.3957),
        vec3(924.2523, -525.7071, 59.7968)
    },

    candyBuyer = { -- Set to false for no candy buyer
        van = {
            model = `speedo2`,
            coords = vec4(212.2630, -167.5856, 55.0984, 71.6239)
        },
        ped = {
            model = `s_m_y_clown_01`,
            coords = vec4(215.7366, -169.3589, 55.3346, 270.7649)
        },
        blip = {
            sprite = 102, -- https://docs.fivem.net/docs/game-references/blips/#blips
            color = 17, -- https://docs.fivem.net/docs/game-references/blips/#blip-colors
            scale = 0.6 -- float
        },
        candySellPrice = { min = 50, max = 300 },
    },

    houseBlips = {
        sprite = 40, -- https://docs.fivem.net/docs/game-references/blips/#blips
        color = 17, -- https://docs.fivem.net/docs/game-references/blips/#blip-colors
        scale = 0.6 -- float
    },

    
}