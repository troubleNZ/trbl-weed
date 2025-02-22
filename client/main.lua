local QBCore = exports['qb-core']:GetCoreObject()
local housePlants = {}
local outdoorPlants = {}
local insideHouse = false
local currentHouse = nil
local citizenid = nil
local plantSpawned = false
local outsideplantSpawned = false
local isLoggedIn
--local PlayerData = QBCore.Functions.GetPlayerData()

DrawText3Ds = function(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

RegisterNetEvent('qb-weed:client:getHousePlants', function(house)
    QBCore.Functions.TriggerCallback('qb-weed:server:getBuildingPlants', function(plants)
        currentHouse = house
        housePlants[currentHouse] = plants
        insideHouse = true
        spawnHousePlants()
    end, house)
end)

function spawnHousePlants()
    CreateThread(function()
        if not plantSpawned then
            for k, _ in pairs(housePlants[currentHouse]) do
                local plantData = {
                    ["plantCoords"] = {["x"] = json.decode(housePlants[currentHouse][k].coords).x, ["y"] = json.decode(housePlants[currentHouse][k].coords).y, ["z"] = json.decode(housePlants[currentHouse][k].coords).z},
                    ["plantProp"] = GetHashKey(QBWeed.Plants[housePlants[currentHouse][k].sort]["stages"][housePlants[currentHouse][k].stage]),
                }

                local plantProp = CreateObject(plantData["plantProp"], plantData["plantCoords"]["x"], plantData["plantCoords"]["y"], plantData["plantCoords"]["z"], false, false, false)
                while not plantProp do Wait(0) end
                PlaceObjectOnGroundProperly(plantProp)
                Wait(10)
                FreezeEntityPosition(plantProp, true)
                SetEntityAsMissionEntity(plantProp, false, false)
            end
            plantSpawned = true
        end
    end)
end

function despawnHousePlants()
    CreateThread(function()
        if plantSpawned then
            for k, _ in pairs(housePlants[currentHouse]) do
                local plantData = {
                    ["plantCoords"] = {["x"] = json.decode(housePlants[currentHouse][k].coords).x, ["y"] = json.decode(housePlants[currentHouse][k].coords).y, ["z"] = json.decode(housePlants[currentHouse][k].coords).z},
                }

                for _, stage in pairs(QBWeed.Plants[housePlants[currentHouse][k].sort]["stages"]) do
                    local closestPlant = GetClosestObjectOfType(plantData["plantCoords"]["x"], plantData["plantCoords"]["y"], plantData["plantCoords"]["z"], 3.5, GetHashKey(stage), false, false, false)
                    if closestPlant ~= 0 then
                        DeleteObject(closestPlant)
                    end
                end
            end
            plantSpawned = false
        end
    end)
end

local ClosestTarget = 0

CreateThread(function()
    while true do
        Wait(0)
        if insideHouse then
            if plantSpawned then
                local ped = PlayerPedId()
                for k, _ in pairs(housePlants[currentHouse]) do
                    local gender = "M"
                    if housePlants[currentHouse][k].gender == "woman" then gender = "F" end

                    local plantData = {
                        ["plantCoords"] = {["x"] = json.decode(housePlants[currentHouse][k].coords).x, ["y"] = json.decode(housePlants[currentHouse][k].coords).y, ["z"] = json.decode(housePlants[currentHouse][k].coords).z},
                        ["plantStage"] = housePlants[currentHouse][k].stage,
                        ["plantProp"] = GetHashKey(QBWeed.Plants[housePlants[currentHouse][k].sort]["stages"][housePlants[currentHouse][k].stage]),
                        ["plantSort"] = {
                            ["name"] = housePlants[currentHouse][k].sort,
                            ["label"] = QBWeed.Plants[housePlants[currentHouse][k].sort]["label"],
                        },
                        ["plantStats"] = {
                            ["food"] = housePlants[currentHouse][k].food,
                            ["health"] = housePlants[currentHouse][k].health,
                            ["progress"] = housePlants[currentHouse][k].progress,
                            ["stage"] = housePlants[currentHouse][k].stage,
                            ["highestStage"] = QBWeed.Plants[housePlants[currentHouse][k].sort]["highestStage"],
                            ["gender"] = gender,
                            ["plantId"] = housePlants[currentHouse][k].plantid,
                        }
                    }

                    local plyDistance = #(GetEntityCoords(ped) - vector3(plantData["plantCoords"]["x"], plantData["plantCoords"]["y"], plantData["plantCoords"]["z"]))

                    if plyDistance < 0.8 then

                        ClosestTarget = k
                        if plantData["plantStats"]["health"] > 0 then
                            if plantData["plantStage"] ~= plantData["plantStats"]["highestStage"] then
                                DrawText3Ds(plantData["plantCoords"]["x"], plantData["plantCoords"]["y"], plantData["plantCoords"]["z"],  Lang:t('text.sort') .. plantData["plantSort"]["label"]..'~w~ ['..plantData["plantStats"]["gender"]..'] | '..Lang:t('text.nutrition')..' ~b~'..plantData["plantStats"]["food"]..'% ~w~ | '..Lang:t('text.health')..' ~b~'..plantData["plantStats"]["health"]..'%')
                            else
                                DrawText3Ds(plantData["plantCoords"]["x"], plantData["plantCoords"]["y"], plantData["plantCoords"]["z"] + 0.2, Lang:t('text.harvest_plant'))
                                DrawText3Ds(plantData["plantCoords"]["x"], plantData["plantCoords"]["y"], plantData["plantCoords"]["z"],  Lang:t('text.sort')..' ~g~'..plantData["plantSort"]["label"]..'~w~ ['..plantData["plantStats"]["gender"]..'] | '..Lang:t('text.nutrition')..' ~b~'..plantData["plantStats"]["food"]..'% ~w~ | '..Lang:t('text.health')..' ~b~'..plantData["plantStats"]["health"]..'%')
                                if IsControlJustPressed(0, 38) then
                                    QBCore.Functions.Progressbar("remove_weed_plant", Lang:t('text.harvesting_plant'), 8000, false, true, {
                                        disableMovement = true,
                                        disableCarMovement = true,
                                        disableMouse = false,
                                        disableCombat = true,
                                    }, {
                                        animDict = "amb@world_human_gardener_plant@male@base",
                                        anim = "base",
                                        flags = 16,
                                    }, {}, {}, function() -- Done
                                        ClearPedTasks(ped)
                                        local amount = math.random(1, 6)
                                        if plantData["plantStats"]["gender"] == "M" then
                                            amount = math.random(1, 2)
                                        end
                                        TriggerServerEvent('qb-weed:server:harvestPlant', currentHouse, amount, plantData["plantSort"]["name"], plantData["plantStats"]["plantId"])
                                    end, function() -- Cancel
                                        ClearPedTasks(ped)
                                        QBCore.Functions.Notify("Process Canceled", "error")
                                    end)
                                end
                            end
                        elseif plantData["plantStats"]["health"] == 0 then
                            DrawText3Ds(plantData["plantCoords"]["x"], plantData["plantCoords"]["y"], plantData["plantCoords"]["z"], Lang:t('error.plant_has_died'))
                            if IsControlJustPressed(0, 38) then
                                QBCore.Functions.Progressbar("remove_weed_plant", Lang:t('text.removing_the_plant'), 8000, false, true, {
                                    disableMovement = true,
                                    disableCarMovement = true,
                                    disableMouse = false,
                                    disableCombat = true,
                                }, {
                                    animDict = "amb@world_human_gardener_plant@male@base",
                                    anim = "base",
                                    flags = 16,
                                }, {}, {}, function() -- Done
                                    ClearPedTasks(ped)
                                    TriggerServerEvent('qb-weed:server:removeDeathPlant', currentHouse, plantData["plantStats"]["plantId"])
                                end, function() -- Cancel
                                    ClearPedTasks(ped)
                                    QBCore.Functions.Notify( Lang:t('error.process_canceled'), "error")
                                end)
                            end
                        end
                    end
                end
            end
        end

        if not insideHouse then
            Wait(5000)
        end
    end
end)

CreateThread(function()     -- outdoor plant loop
    while true do
        Wait(0)
        local result = QBCore.Functions.HasItem('gardengloves')
        if result then

            if outsideplantSpawned then
                local ped = PlayerPedId()
                for k, _ in pairs(outdoorPlants[citizenid]) do
                    local gender = "M"
                    if outdoorPlants[citizenid][k].gender == "woman" then gender = "F" end

                    local plantData = {
                        ["plantCoords"] = {["x"] = json.decode(outdoorPlants[citizenid][k].coords).x, ["y"] = json.decode(outdoorPlants[citizenid][k].coords).y, ["z"] = json.decode(outdoorPlants[citizenid][k].coords).z},
                        ["plantStage"] = outdoorPlants[citizenid][k].stage,
                        ["plantProp"] = GetHashKey(QBWeed.Plants[outdoorPlants[citizenid][k].sort]["stages"][outdoorPlants[citizenid][k].stage]),
                        ["plantSort"] = {
                            ["name"] = outdoorPlants[citizenid][k].sort,
                            ["label"] = QBWeed.Plants[outdoorPlants[citizenid][k].sort]["label"],
                        },
                        ["plantStats"] = {
                            ["food"] = outdoorPlants[citizenid][k].food,
                            ["health"] = outdoorPlants[citizenid][k].health,
                            ["progress"] = outdoorPlants[citizenid][k].progress,
                            ["stage"] = outdoorPlants[citizenid][k].stage,
                            ["highestStage"] = QBWeed.Plants[outdoorPlants[citizenid][k].sort]["highestStage"],
                            ["gender"] = gender,
                            ["plantId"] = outdoorPlants[citizenid][k].plantid,
                        }
                    }

                    local plyDistance = #(GetEntityCoords(ped) - vector3(plantData["plantCoords"]["x"], plantData["plantCoords"]["y"], plantData["plantCoords"]["z"]))

                    if plyDistance < 0.8 then

                        ClosestTarget = k
                        if plantData["plantStats"]["health"] > 0 then
                            if plantData["plantStage"] ~= plantData["plantStats"]["highestStage"] then
                                DrawText3Ds(plantData["plantCoords"]["x"], plantData["plantCoords"]["y"], plantData["plantCoords"]["z"],  Lang:t('text.sort') .. plantData["plantSort"]["label"]..'~w~ ['..plantData["plantStats"]["gender"]..'] | '..Lang:t('text.nutrition')..' ~b~'..plantData["plantStats"]["food"]..'% ~w~ | '..Lang:t('text.health')..' ~b~'..plantData["plantStats"]["health"]..'%')
                            else
                                DrawText3Ds(plantData["plantCoords"]["x"], plantData["plantCoords"]["y"], plantData["plantCoords"]["z"] + 0.2, Lang:t('text.harvest_plant'))
                                DrawText3Ds(plantData["plantCoords"]["x"], plantData["plantCoords"]["y"], plantData["plantCoords"]["z"],  Lang:t('text.sort')..' ~g~'..plantData["plantSort"]["label"]..'~w~ ['..plantData["plantStats"]["gender"]..'] | '..Lang:t('text.nutrition')..' ~b~'..plantData["plantStats"]["food"]..'% ~w~ | '..Lang:t('text.health')..' ~b~'..plantData["plantStats"]["health"]..'%')
                                if IsControlJustPressed(0, 38) then
                                    QBCore.Functions.Progressbar("remove_weed_plant", Lang:t('text.harvesting_plant'), 8000, false, true, {
                                        disableMovement = true,
                                        disableCarMovement = true,
                                        disableMouse = false,
                                        disableCombat = true,
                                    }, {
                                        animDict = "amb@world_human_gardener_plant@male@base",
                                        anim = "base",
                                        flags = 16,
                                    }, {}, {}, function() -- Done
                                        ClearPedTasks(ped)
                                        local amount = math.random(1, 6)
                                        if plantData["plantStats"]["gender"] == "M" then
                                            amount = math.random(1, 2)
                                        end
                                        TriggerServerEvent('trbl-weed:server:harvest-HYH-Plant', citizenid, amount, plantData["plantSort"]["name"], plantData["plantStats"]["plantId"])
                                    end, function() -- Cancel
                                        ClearPedTasks(ped)
                                        QBCore.Functions.Notify("Process Canceled", "error")
                                    end)
                                end
                            end
                        elseif plantData["plantStats"]["health"] == 0 then
                            DrawText3Ds(plantData["plantCoords"]["x"], plantData["plantCoords"]["y"], plantData["plantCoords"]["z"], Lang:t('error.plant_has_died'))
                            if IsControlJustPressed(0, 38) then
                                QBCore.Functions.Progressbar("remove_weed_plant", Lang:t('text.removing_the_plant'), 8000, false, true, {
                                    disableMovement = true,
                                    disableCarMovement = true,
                                    disableMouse = false,
                                    disableCombat = true,
                                }, {
                                    animDict = "amb@world_human_gardener_plant@male@base",
                                    anim = "base",
                                    flags = 16,
                                }, {}, {}, function() -- Done
                                    ClearPedTasks(ped)
                                    TriggerServerEvent('qb-weed:server:removeDeathPlant', citizenid, plantData["plantStats"]["plantId"])
                                end, function() -- Cancel
                                    ClearPedTasks(ped)
                                    QBCore.Functions.Notify( Lang:t('error.process_canceled'), "error")
                                end)
                            end
                        end
                    end
                end
            end


        end


    end

    if not result then
        Wait(5000)
    end
end)

RegisterNetEvent('qb-weed:client:refreshHousePlants', function(house)
    if currentHouse ~= nil and currentHouse == house then
        despawnHousePlants()
        SetTimeout(100, function()
            QBCore.Functions.TriggerCallback('qb-weed:server:getBuildingPlants', function(plants)
                currentHouse = house
                housePlants[currentHouse] = plants
                spawnHousePlants()
            end, house)
        end)
    end
end)

RegisterNetEvent('qb-weed:client:refreshPlantStats', function()
    if insideHouse then
        despawnHousePlants()
        SetTimeout(100, function()
            QBCore.Functions.TriggerCallback('qb-weed:server:getBuildingPlants', function(plants)
                housePlants[currentHouse] = plants
                spawnHousePlants()
            end, currentHouse)
        end)
    end
end)

RegisterNetEvent('qb-weed:client:placePlant', function(type, item)
    local ped = PlayerPedId()
    local plyCoords = GetOffsetFromEntityInWorldCoords(ped, 0, 0.75, 0)
    local plantData = {
        ["plantCoords"] = {["x"] = plyCoords.x, ["y"] = plyCoords.y, ["z"] = plyCoords.z},
        ["plantModel"] = QBWeed.Plants[type]["stages"]["stage-a"],
        ["plantLabel"] = QBWeed.Plants[type]["label"]
    }
    local ClosestPlant = 0
    for _, v in pairs(QBWeed.Props) do
        if ClosestPlant == 0 then
            ClosestPlant = GetClosestObjectOfType(plyCoords.x, plyCoords.y, plyCoords.z, 0.8, GetHashKey(v), false, false, false)
        end
    end

    if currentHouse ~= nil then
        if ClosestPlant == 0 then
	LocalPlayer.state:set("inv_busy", true, true)
            QBCore.Functions.Progressbar("plant_weed_plant", Lang:t('text.planting'), 8000, false, true, {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            }, {
                animDict = "amb@world_human_gardener_plant@male@base",
                anim = "base",
                flags = 16,
		LocalPlayer.state:set("inv_busy", false, true)
            }, {}, {}, function() -- Done
                ClearPedTasks(ped)
                TriggerServerEvent('qb-weed:server:placePlant', json.encode(plantData["plantCoords"]), type, currentHouse)
                TriggerServerEvent('qb-weed:server:removeSeed', item.slot, type)
            end, function() -- Cancel
                ClearPedTasks(ped)
                QBCore.Functions.Notify(Lang:t('error.process_canceled'), "error")
		LocalPlayer.state:set("inv_busy", false, true)
            end)
        else
            QBCore.Functions.Notify(Lang:t('error.cant_place_here'), 'error', 3500)
        end
    else
        QBCore.Functions.Notify(Lang:t('error.not_safe_here'), 'error', 3500)
    end
end)

RegisterNetEvent('qb-weed:client:foodPlant', function()
    if currentHouse ~= nil then
        if ClosestTarget ~= 0 then
            local ped = PlayerPedId()
            local gender = "M"
            if housePlants[currentHouse][ClosestTarget].gender == "woman" then
                gender = "F"
            end

            local plantData = {
                ["plantCoords"] = {["x"] = json.decode(housePlants[currentHouse][ClosestTarget].coords).x, ["y"] = json.decode(housePlants[currentHouse][ClosestTarget].coords).y, ["z"] = json.decode(housePlants[currentHouse][ClosestTarget].coords).z},
                ["plantStage"] = housePlants[currentHouse][ClosestTarget].stage,
                ["plantProp"] = GetHashKey(QBWeed.Plants[housePlants[currentHouse][ClosestTarget].sort]["stages"][housePlants[currentHouse][ClosestTarget].stage]),
                ["plantSort"] = {
                    ["name"] = housePlants[currentHouse][ClosestTarget].sort,
                    ["label"] = QBWeed.Plants[housePlants[currentHouse][ClosestTarget].sort]["label"],
                },
                ["plantStats"] = {
                    ["food"] = housePlants[currentHouse][ClosestTarget].food,
                    ["health"] = housePlants[currentHouse][ClosestTarget].health,
                    ["progress"] = housePlants[currentHouse][ClosestTarget].progress,
                    ["stage"] = housePlants[currentHouse][ClosestTarget].stage,
                    ["highestStage"] = QBWeed.Plants[housePlants[currentHouse][ClosestTarget].sort]["highestStage"],
                    ["gender"] = gender,
                    ["plantId"] = housePlants[currentHouse][ClosestTarget].plantid,
                }
            }
            local plyDistance = #(GetEntityCoords(ped) - vector3(plantData["plantCoords"]["x"], plantData["plantCoords"]["y"], plantData["plantCoords"]["z"]))

            if plyDistance < 1.0 then
                if plantData["plantStats"]["food"] == 100 then
                    QBCore.Functions.Notify(Lang:t('error.not_need_nutrition'), 'error', 3500)
                else
		            LocalPlayer.state:set("inv_busy", true, true)
                    QBCore.Functions.Progressbar("plant_weed_plant", Lang:t('text.feeding_plant'), math.random(4000, 8000), false, true, {
                        disableMovement = true,
                        disableCarMovement = true,
                        disableMouse = false,
                        disableCombat = true,
                    }, {
                        animDict = "timetable@gardener@filling_can",
                        anim = "gar_ig_5_filling_can",
                        flags = 16,

                        LocalPlayer.state:set("inv_busy", false, true)
                    }, {}, {}, function() -- Done
                        ClearPedTasks(ped)
                        local newFood = math.random(40, 60)
                        TriggerServerEvent('qb-weed:server:foodPlant', currentHouse, newFood, plantData["plantSort"]["name"], plantData["plantStats"]["plantId"])
                    end, function() -- Cancel
                        ClearPedTasks(ped)
			            LocalPlayer.state:set("inv_busy", false, true)
                        QBCore.Functions.Notify(Lang:t('error.process_canceled'), "error")
                    end)
                end
            else
                QBCore.Functions.Notify(Lang:t('error.cant_place_here'), "error")
            end
        else
            QBCore.Functions.Notify(Lang:t('error.cant_place_here'), "error")
        end
    end
end)


-- #trbl events

RegisterNetEvent('trbl-weed:client:logOut', function()
    despawnOutDoorPlants()
    SetTimeout(1000, function()
        if currentHouse ~= nil then
            insideHouse = false
            outdoorPlants[citizenid] = nil
            citizenid = nil
        end
    end)
end)

RegisterNetEvent('trbl-weed:client:getOutDoorPlants', function(cid)
    QBCore.Functions.TriggerCallback('trbl-weed:server:getCitizenPlants', function(plants)
        citizenid = cid
        outdoorplants[citizenid] = plants
        spawnOutDoorPlants()
    end, cid)
end)

RegisterNetEvent('trbl-weed:client:place-HYH-Plant', function(type, item)
    local ped = PlayerPedId()
    local Player = QBCore.Functions.GetPlayerData()
    local cid = Player.citizenid
    local plyCoords = GetOffsetFromEntityInWorldCoords(ped, 0, 0.75, 0)
    local plantData = {
        ["plantCoords"] = {["x"] = plyCoords.x, ["y"] = plyCoords.y, ["z"] = plyCoords.z},
        ["plantModel"] = QBWeed.Plants[type]["stages"]["stage-a"],
        ["plantLabel"] = QBWeed.Plants[type]["label"]
    }
    local ClosestPlant = 0
    for _, v in pairs(QBWeed.Props) do
        if ClosestPlant == 0 then
            ClosestPlant = GetClosestObjectOfType(plyCoords.x, plyCoords.y, plyCoords.z, 0.8, GetHashKey(v), false, false, false)
        end
    end

    --if currentHouse ~= nil then
        if ClosestPlant == 0 then
	        LocalPlayer.state:set("inv_busy", true, true)
            QBCore.Functions.Progressbar("plant_weed_plant", Lang:t('text.planting'), 8000, false, true, {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            }, {
                animDict = "amb@world_human_gardener_plant@male@base",
                anim = "base",
                flags = 16,
		        LocalPlayer.state:set("inv_busy", false, true)
            }, {}, {}, function() -- Done
                ClearPedTasks(ped)
                TriggerServerEvent('trbl-weed:server:place-HYH-Plant', json.encode(plantData["plantCoords"]), type, cid)
                TriggerServerEvent('qb-weed:server:removeSeed', item.slot, type)
            end, function() -- Cancel
                ClearPedTasks(ped)
                QBCore.Functions.Notify(Lang:t('error.process_canceled'), "error")
		        LocalPlayer.state:set("inv_busy", false, true)
            end)
        else
            QBCore.Functions.Notify(Lang:t('error.cant_place_here'), 'error', 3500)
        end
    --else
    --    QBCore.Functions.Notify(Lang:t('error.not_safe_here'), 'error', 3500)
    --end
end)

RegisterNetEvent('trbl-weed:client:refreshOutDoorPlants', function(cid)
    local PlayerData = QBCore.Functions.GetPlayerData()
    citizenid = PlayerData.citizenid
    if citizenid ~= nil and citizenid == cid then
        despawnOutDoorPlants()
        SetTimeout(100, function()
            QBCore.Functions.TriggerCallback('trbl-weed:server:getCitizenPlants', function(plants)
                citizenid = cid
                outdoorPlants[citizenid] = plants
                spawnOutDoorPlants()
            end, cid)
        end)
    end
end)

RegisterNetEvent('trbl-weed:client:refreshOutdoorPlantStats', function()
    if isLoggedIn then
        despawnOutDoorPlants()
        SetTimeout(100, function()
            QBCore.Functions.TriggerCallback('trbl-weed:server:getCitizenPlants', function(plants)
                outdoorPlants[citizenid] = plants
                spawnOutDoorPlants()
            end, citizenid)
        end)
    end
end)

--  #trbl functions

function despawnOutDoorPlants()
    CreateThread(function()
        if plantSpawned then
            for k, _ in pairs(outdoorPlants[citizenid]) do
                local plantData = {
                    ["plantCoords"] = {["x"] = json.decode(outdoorPlants[citizenid][k].coords).x, ["y"] = json.decode(outdoorPlants[citizenid][k].coords).y, ["z"] = json.decode(outdoorPlants[citizenid][k].coords).z},
                }

                for _, stage in pairs(QBWeed.Plants[outdoorPlants[citizenid][k].sort]["stages"]) do
                    local closestPlant = GetClosestObjectOfType(plantData["plantCoords"]["x"], plantData["plantCoords"]["y"], plantData["plantCoords"]["z"], 3.5, GetHashKey(stage), false, false, false)
                    if closestPlant ~= 0 then
                        DeleteObject(closestPlant)
                    end
                end
            end
            plantSpawned = false
        end
    end)
end

function spawnOutDoorPlants()
    CreateThread(function()
        if not outsideplantSpawned then
            for k, _ in pairs(outdoorPlants[citizenid]) do
                local plantData = {
                    ["plantCoords"] = {["x"] = json.decode(outdoorPlants[citizenid][k].coords).x, ["y"] = json.decode(outdoorPlants[citizenid][k].coords).y, ["z"] = json.decode(outdoorPlants[citizenid][k].coords).z},
                    ["plantProp"] = GetHashKey(QBWeed.Plants[outdoorPlants[citizenid][k].sort]["stages"][outdoorPlants[citizenid][k].stage]),
                }

                local plantProp = CreateObject(plantData["plantProp"], plantData["plantCoords"]["x"], plantData["plantCoords"]["y"], plantData["plantCoords"]["z"], false, false, false)
                while not plantProp do Wait(0) end
                --PlaceObjectOnGroundProperly(plantProp)
                Wait(10)
                FreezeEntityPosition(plantProp, true)
                SetEntityCoords(plantProp, plantData["plantCoords"]["x"], plantData["plantCoords"]["y"], plantData["plantCoords"]["z"], false,false,false,false)
                SetEntityAsMissionEntity(plantProp, false, false)
            end
            outsideplantSpawned = true
        end
    end)
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    isLoggedIn = true
    Wait(500)
    local PlayerData = QBCore.Functions.GetPlayerData()
    TriggerEvent("trbl-weed:client:refreshOutDoorPlants", PlayerData.citizenid)
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload')
AddEventHandler('QBCore:Client:OnPlayerUnload', function()
    isLoggedIn = false
    TriggerEvent("trbl-weed:client:logOut")
   
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        Wait(200)
        local PlayerData = QBCore.Functions.GetPlayerData()
        isLoggedIn = true
    end
    while not PlayerData do
    Wait(100)
    end
    TriggerEvent("trbl-weed:client:refreshOutDoorPlants", PlayerData.citizenid)
  end)
  