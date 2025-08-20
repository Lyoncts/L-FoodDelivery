local QBCore = exports['qb-core']:GetCoreObject()
local Config = Config_FoodDelivery
local currentSpawnIndex = 1
local onDelivery = false
local deliveryPed = nil
local deliveryBlip = nil
local deliveryVehicle = nil
local ReturnZone = Config_FoodDelivery.ReturnZone

RegisterNetEvent("L-foodelivery:startDelivery", function()
    if not onDelivery then onDelivery = true end
    TriggerServerEvent("L-foodelivery:registerDelivery")
    QBCore.Functions.Notify("Picked up your food. Go deliver it!")

    local location = Config_FoodDelivery.DeliveryLocations[math.random(#Config_FoodDelivery.DeliveryLocations)]

    if deliveryBlip and DoesBlipExist(deliveryBlip) then RemoveBlip(deliveryBlip) end
    deliveryBlip = AddBlipForCoord(location.x, location.y, location.z)
    SetBlipSprite(deliveryBlip, 280)
    SetBlipColour(deliveryBlip, 5)
    SetBlipScale(deliveryBlip, 0.85)
    SetBlipAsShortRange(deliveryBlip, false)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Delivery Location")
    EndTextCommandSetBlipName(deliveryBlip)
    SetBlipRoute(deliveryBlip, true)
    SetBlipRouteColour(deliveryBlip, 5)

    CreateThread(function()
        RequestModel("a_m_y_hipster_01")
        while not HasModelLoaded("a_m_y_hipster_01") do Wait(10) end
        deliveryPed = CreatePed(4, "a_m_y_hipster_01", location.x, location.y, location.z, 0.0, false, true)
        SetEntityAsMissionEntity(deliveryPed, true, true)
        FreezeEntityPosition(deliveryPed, true)
        SetEntityInvincible(deliveryPed, true)
        TaskStartScenarioInPlace(deliveryPed, "WORLD_HUMAN_STAND_MOBILE", 0, true)

        StartDeliveryMonitor()
    end)
end)

function StartDeliveryMonitor()
    CreateThread(function()
        while onDelivery and deliveryPed do
            local player = PlayerPedId()
            local playerCoords = GetEntityCoords(player)
            local pedCoords = GetEntityCoords(deliveryPed)
            local dist = #(playerCoords - pedCoords)

            if dist < 2.0 and not IsPedInAnyVehicle(player, false) then
                DrawText3D(pedCoords.x, pedCoords.y, pedCoords.z + 1.0, "[E] Deliver Food")
                if IsControlJustReleased(0, 38) then
                    RequestAnimDict("misscarsteal4@actor")
                    while not HasAnimDictLoaded("misscarsteal4@actor") do Wait(10) end
                    TaskPlayAnim(player, "misscarsteal4@actor", "actor_berating_loop", 8.0, -8.0, 2000, 1, 0, false, false, false)

                    QBCore.Functions.Progressbar("deliver_burger", "Handing over the food...", 3000, false, true, {
                        disableMovement = true,
                        disableCarMovement = true,
                        disableMouse = false,
                        disableCombat = true,
                    }, {}, {}, {}, function()
                        TriggerServerEvent("L-foodelivery:tryDeliver")
                    end, function()
                        QBCore.Functions.Notify("You cancelled the delivery!", "error")
                    end)
                    break
                end
            elseif dist < 2.0 and IsPedInAnyVehicle(player, false) then
                DrawText3D(pedCoords.x, pedCoords.y, pedCoords.z + 1.0, "Get off the vehicle to deliver.")
            end

            Wait(dist < 10.0 and 0 or 1000)
        end
    end)
end

RegisterNetEvent("L-foodelivery:completeDelivery", function()
    QBCore.Functions.Notify("Delivery complete! Getting next order...")
    if deliveryPed and DoesEntityExist(deliveryPed) then DeletePed(deliveryPed) end
    if deliveryBlip and DoesBlipExist(deliveryBlip) then RemoveBlip(deliveryBlip) end
    deliveryPed, deliveryBlip = nil, nil
    Wait(2000)
    if onDelivery then TriggerEvent("L-foodelivery:startDelivery") end
end)

RegisterNetEvent("L-foodelivery:failDelivery", function()
    QBCore.Functions.Notify("You don’t have the item to deliver. Please get one or end the job manually.", "error")
end)

-- Spawn restaurant NPC and set target interaction
CreateThread(function()
    RequestModel(Config_FoodDelivery.RestaurantPed.model)
    while not HasModelLoaded(Config_FoodDelivery.RestaurantPed.model) do Wait(10) end

    local ped = CreatePed(0, Config_FoodDelivery.RestaurantPed.model, Config_FoodDelivery.RestaurantPed.coords.x, Config_FoodDelivery.RestaurantPed.coords.y, Config_FoodDelivery.RestaurantPed.coords.z - 1.0, Config_FoodDelivery.RestaurantPed.coords.w, false, true)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)

    AddTargetToEntity(ped, "Start Delivery Job", "fas fa-hamburger", function()
        if onDelivery then
            QBCore.Functions.Notify("You're already on a delivery!", "error")
            return
        end

        local spawn = Config_FoodDelivery.VehicleSpawns[currentSpawnIndex]
        currentSpawnIndex = currentSpawnIndex + 1
        if currentSpawnIndex > #Config_FoodDelivery.VehicleSpawns then currentSpawnIndex = 1 end

        RequestCollisionAtCoord(spawn.x, spawn.y, spawn.z)
        while not HasCollisionLoadedAroundEntity(PlayerPedId()) do Wait(10) end

        local vehModel = GetHashKey(Config_FoodDelivery.DeliveryVehicleModel)
        RequestModel(vehModel)
        while not HasModelLoaded(vehModel) do Wait(10) end

        deliveryVehicle = CreateVehicle(vehModel, spawn.x, spawn.y, spawn.z, spawn.w, true, false)
        SetVehicleOnGroundProperly(deliveryVehicle)
        SetEntityAsMissionEntity(deliveryVehicle, true, true)
        SetVehicleNumberPlateText(deliveryVehicle, "DELIVERY123")
        TaskWarpPedIntoVehicle(PlayerPedId(), deliveryVehicle, -1)
        -- TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(deliveryVehicle))
        if GetResourceState('qb-vehiclekeys') == 'started' then
            TriggerServerEvent("qb-vehiclekeys:server:AcquireVehicleKeys", GetVehicleNumberPlateText(deliveryVehicle))
        end

        local Player = QBCore.Functions.GetPlayerData()
        if Player and Player.charinfo then
            local gender = Player.charinfo.gender
            if gender == 0 then
                TriggerEvent("illenium-appearance:client:loadOutfit", Config.Clothes.male)
            else
                TriggerEvent("illenium-appearance:client:loadOutfit", Config.Clothes.female)
            end
        end

        TriggerEvent("L-foodelivery:startDelivery")
    end)
end)

CreateThread(function()
    while true do
        if onDelivery and deliveryVehicle and DoesEntityExist(deliveryVehicle) then
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            local dist = #(coords - ReturnZone)

            if dist < 25.0 then
                DrawMarker(1, ReturnZone.x, ReturnZone.y, ReturnZone.z - 1.0, 0, 0, 0, 0, 0, 0,
                    4.0, 4.0, 1.0, 0, 255, 0, 150, false, true, 2, nil, nil, false)

                if dist < 3.0 then
                    local veh = GetVehiclePedIsIn(ped, false)

                    if veh ~= 0 and veh == deliveryVehicle then
                        DrawText3D(ReturnZone.x, ReturnZone.y, ReturnZone.z + 1.0, "[E] Return Vehicle & End Job")

                        if IsControlJustReleased(0, 38) then
                            -- Ensure vehicle deletion
                            if NetworkHasControlOfEntity(veh) then
                                DeleteVehicle(veh)
                            else
                                NetworkRequestControlOfEntity(veh)
                                Wait(100)
                                DeleteVehicle(veh)
                            end

                            deliveryVehicle = nil

                            -- Cleanup
                            if deliveryPed and DoesEntityExist(deliveryPed) then DeletePed(deliveryPed) end
                            if deliveryBlip and DoesBlipExist(deliveryBlip) then RemoveBlip(deliveryBlip) end

                            deliveryPed, deliveryBlip = nil, nil
                            onDelivery = false

                            QBCore.Functions.Notify("You returned the vehicle and ended your job. Good work!", "success")
                        end
                    else
                        DrawText3D(ReturnZone.x, ReturnZone.y, ReturnZone.z + 1.0, "You must be in the delivery vehicle to return it.")
                    end
                end

                Wait(0)
            else
                Wait(1000)
            end
        else
            Wait(1000)
        end
    end
end)


function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextCentre(true)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(_x, _y)
end

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        if deliveryPed and DoesEntityExist(deliveryPed) then DeletePed(deliveryPed) end
        if deliveryBlip and DoesBlipExist(deliveryBlip) then RemoveBlip(deliveryBlip) end
        if deliveryVehicle and DoesEntityExist(deliveryVehicle) then DeleteVehicle(deliveryVehicle) end
        print("^1[INFO]^0 L-foodelivery client script stopped.")
    end
end)

-- AddEventHandler('onResourceStart', function(resource)
--     if resource == GetCurrentResourceName() then
--         print("^3[INFO]^0 L-foodelivery Job Script by Lcts (v3.0.0) started successfully.")
--     end
-- end)
