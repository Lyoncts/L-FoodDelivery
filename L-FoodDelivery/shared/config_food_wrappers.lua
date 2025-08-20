local QBCore = exports['qb-core']:GetCoreObject()

function HasItem(src, item)
    if Config.UseOxInventory then
        return (exports.ox_inventory:Search(src, 'count', item) or 0) > 0
    else
        local Player = QBCore.Functions.GetPlayer(src)
        return Player and Player.Functions.GetItemByName(item)
    end
end

function RemoveItem(src, item, amount)
    if Config.UseOxInventory then
        return exports.ox_inventory:RemoveItem(src, item, amount or 1)
    else
        local Player = QBCore.Functions.GetPlayer(src)
        return Player and Player.Functions.RemoveItem(item, amount or 1)
    end
end

function AddCash(src, amount)
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        return Player.Functions.AddMoney("cash", amount, "food-delivery")
    end
end

function AddTargetToEntity(entity, label, icon, action)
    if Config.UseOxTarget and exports.ox_target then
        exports.ox_target:addLocalEntity(entity, {
            {
                name = "delivery_start",
                label = label,
                icon = icon,
                distance = 2.0,
                onSelect = action
            }
        })
    else
        exports['qb-target']:AddTargetEntity(entity, {
            options = {
                {
                    icon = icon,
                    label = label,
                    action = action
                }
            },
            distance = 2.0
        })
    end
end
