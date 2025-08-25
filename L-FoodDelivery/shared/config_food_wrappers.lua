local QBCore = exports['qb-core']:GetCoreObject()

local function usingOxInv()    return Config_FoodDelivery.UseOxInventory == true end
local function usingOxTarget() return Config_FoodDelivery.UseOxTarget == true end

function HasItem(src, item)
    if usingOxInv() then
        return (exports.ox_inventory:Search(src, 'count', item) or 0) > 0
    else
        local Player = QBCore.Functions.GetPlayer(src)
        return Player and Player.Functions.GetItemByName(item) ~= nil
    end
end

function RemoveItem(src, item, amount)
    amount = amount or 1
    if usingOxInv() then
        return exports.ox_inventory:RemoveItem(src, item, amount, nil, src)
    else
        local Player = QBCore.Functions.GetPlayer(src)
        if not Player then return false end
        return Player.Functions.RemoveItem(item, amount)
    end
end

function AddItem(src, item, amount, meta)
    amount = amount or 1
    if usingOxInv() then
        return exports.ox_inventory:AddItem(src, item, amount, meta or {}, false, src)
    else
        local Player = QBCore.Functions.GetPlayer(src)
        if not Player then return false end
        return Player.Functions.AddItem(item, amount, false, meta)
    end
end

function AddMoney(src, account, amount, reason)
    account = account or 'bank'
    amount = math.floor(tonumber(amount) or 0)
    if amount <= 0 then return false end
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return false end
    Player.Functions.AddMoney(account, amount, reason or 'food_delivery')
    return true
end

-- Target helpers
function AddTargetToEntity(entity, label, icon, action)
    if usingOxTarget() and GetResourceState('ox_target') == 'started' then
        exports.ox_target:addLocalEntity(entity, {
            {
                name = 'l_fd_start',
                label = label or 'Start Delivery',
                icon = icon or 'fa-solid fa-box',
                distance = 2.0,
                onSelect = action
            }
        })
    else
        exports['qb-target']:AddTargetEntity(entity, {
            options = {{
                icon  = icon or 'fa-solid fa-box',
                label = label or 'Start Delivery',
                action = action
            }},
            distance = 2.0
        })
    end
end

function RemoveTargetFromEntity(entity)
    if usingOxTarget() and GetResourceState('ox_target') == 'started' then
        exports.ox_target:removeLocalEntity(entity, 'l_fd_start')
    else
        exports['qb-target']:RemoveTargetEntity(entity)
    end
end
