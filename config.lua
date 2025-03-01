Config = {}

Config.DropSettings = {
    BlipSprite = 501,
    BlipColor = 46,
    BlipScale = 1.0,
    MarkerColor = {r = 255, g = 215, b = 0},
    MarkerSize = {
        cylinder = {x = 2.0, y = 2.0, z = 1.0},
        arrow = {x = 1.5, y = 1.5, z = 1.5}
    }
}

Config.AreaTypes = {
    ["normal"] = {
        items = {
            {name = "water_bottle", amount = {min = 1, max = 2}},
            {name = "burger", amount = {min = 1, max = 2}},
            {name = "money", amount = {min = 100, max = 500}}
        }
    },
    ["orta"] = {
        items = {
            {name = "water_bottle", amount = {min = 1, max = 3}},
            {name = "burger", amount = {min = 1, max = 3}},
            {name = "money", amount = {min = 500, max = 1000}},
            {name = "lockpick", amount = {min = 1, max = 2}}
        }
    },
    ["yuksek"] = {
        items = {
            {name = "water_bottle", amount = {min = 2, max = 4}},
            {name = "burger", amount = {min = 2, max = 4}},
            {name = "money", amount = {min = 1000, max = 2000}},
            {name = "lockpick", amount = {min = 1, max = 3}},
            {name = "phone", amount = {min = 1, max = 1}}
        }
    }
}

Config.Commands = {
    create = "drop"
} 