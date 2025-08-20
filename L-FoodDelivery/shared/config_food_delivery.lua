Config_FoodDelivery = {}

Config_FoodDelivery.UseOxInventory = false   -- true = ox_inventory, false = qb-inventory
Config_FoodDelivery.UseOxTarget = false      -- true = ox_target, false = qb-target

Config_FoodDelivery.DeliveryItem = "burgerkambingapek"   -- change your delivery item as your please
Config_FoodDelivery.DeliveryReward = math.random(550, 600)

Config_FoodDelivery.DeliveryLocations = {
    vector4(-1019.25, -1018.49, 1.15, 33.08),
    vector4(-948.55, -951.81, 1.15, 125.08),
    vector4(-984.2, -889.49, 1.15, 213.93),
    vector4(-1093.91, -941.12, 1.36, 120.16),
    vector4(-1286.04, -1267.84, 3.04, 200.26),
    vector4(-1308.22, -1227.89, 3.9, 113.31),
    vector4(-1319.24, -907.79, 10.31, 202.04),
    vector4(-668.37, -971.45, 21.34, 5.24),
    vector4(-699.69, -1032.55, 15.1, 129.05),
    vector4(-952.06, -1552.66, 4.17, 25.17),
    vector4(-1037.15, -1605.3, 3.97, 36.83),
    vector4(-1147.4, -1577.83, 3.43, 219.32),
    vector4(-1097.52, -1679.54, 3.36, 132.11)
}

Config_FoodDelivery.RestaurantPed = {
    coords = vector4(78.62, 289.22, 110.21, 69.87),
    model = "s_m_m_linecook"
}

Config_FoodDelivery.VehicleSpawns = {
    vector4(95.82, 308.47, 110.02, 162.11),
    vector4(92.34, 309.36, 110.02, 159.26),
    vector4(99.43, 307.17, 110.02, 156.5)
}

Config_FoodDelivery.DeliveryVehicleModel = "aerox155" -- change your vehicles as your please with correct spawn name

Config_FoodDelivery.Clothes = {
    male = {
        outfitData = {
            ['t-shirt'] = {item = 15, texture = 0},
            ['torso2']  = {item = 336, texture = 0},
            ['arms']    = {item = 11, texture = 0},
            ['pants']   = {item = 51, texture = 0},
            ['shoes']   = {item = 129, texture = 0}
        }
    },
    female = {
        outfitData = {
            ['t-shirt'] = {item = 14, texture = 0},
            ['torso2']  = {item = 500, texture = 0},
            ['arms']    = {item = 49, texture = 0},
            ['pants']   = {item = 199, texture = 2},
            ['shoes']   = {item = 422, texture = 0}
        }
    }
}

Config_FoodDelivery.ReturnZone = vector3(106.28, 304.86, 110.03)
