if not lib.checkDependency('stevo_lib', '1.7.1') then error('stevo_lib 1.7.1 required for stevo_trickortreat') end
lib.locale()
local config = require('config')
local stevo_lib = exports['stevo_lib']:import()
local progress = config.progressCircle and lib.progressCircle or lib.progressBar
local blips = {}
local textUI, knocking, trickPed = false, false, 0

local function trickPlayer(houseId, data)
    local ped = data.ped
    local weapon = data.weapon
    local location = config.houses[houseId]

    lib.requestModel(ped)

    trickPed = CreatePed(28, ped, location.x, location.y, location.z, 0.0, false, true)
    
    SetRelationshipBetweenGroups(5, GetPedRelationshipGroupHash(cache.ped), GetPedRelationshipGroupHash(trickPed))
    SetRelationshipBetweenGroups(5, GetPedRelationshipGroupHash(trickPed), GetPedRelationshipGroupHash(cache.ped))

    GiveWeaponToPed(trickPed, weapon, 250, false, true)
    TaskCombatPed(trickPed, cache.ped, 0, 16)

    stevo_lib.Notify(locale("notify.gotTricked"), 'error', 3000)   

    CreateThread(function()
        local pedAlive = 0
        while DoesEntityExist(trickPed) do 

            if IsPedFatallyInjured(trickPed) then 
                DeleteEntity(trickPed)
            end
            if #(GetEntityCoords(trickPed) - GetEntityCoords(cache.ped)) > 15 then 
                DeleteEntity(trickPed)
            end

            if pedAlive > 15000 then 
                DeleteEntity(trickPed)
            end

            pedAlive = pedAlive + 500

            Wait(500)
        end
    end)
end

local function trickOrTreat(houseId)
    local canKnock = lib.callback.await('stevo_trickortreat:canKnock', false, houseId)
    if not canKnock then 
        knocking = false
        stevo_lib.Notify(locale("notify.knockedRecently"), 'error', 3000)
        return 
    end
    if progress({
        duration = config.knockTime * 1000,
        position = 'bottom',
        label = locale('progress.knocking'),
        useWhileDead = false,
        anim = {
            dict = "timetable@jimmy@doorknock@",
            clip = "knockdoor_idle"
        },
        canCancel = true,
        disable = { move = true, car = true, mouse = false, combat = true, },
    }) then    
        local wasTricked = lib.callback.await('stevo_trickortreat:knockedOnDoor', false, houseId)

        knocking = false

        if not wasTricked then
            stevo_lib.Notify(locale("notify.receivedTreat"), 'success', 3000)   
        else 
            trickPlayer(houseId, wasTricked)    
        end    

    else
        knocking = false
        stevo_lib.Notify(locale("notify.stoppedKnocking"), 'error', 3000)
    end
end

local function nearby(self)

    if self.currentDistance < config.interactDistance and not textUI and not knocking then 
        lib.showTextUI(locale('textui.trickortreat')) 
        textUI = true
    end
    if self.currentDistance > config.interactDistance and textUI then 
        lib.hideTextUI()
        textUI = false 
    end
    if self.currentDistance < config.interactDistance and IsControlJustPressed(0, 38) then
        lib.hideTextUI()
        textUI = false 
        knocking = true
        trickOrTreat(self.houseId)               
    end
end

local function onExit(self)
    if textUI then 
        textUI = false
        lib.hideTextUI()
    end
end

local function initHouses()

    for locationId, location in pairs(config.houses) do 
        if config.interact == 'textui' then 

            lib.points.new({
                coords = location,
                distance = config.interactDistance,
                houseId = locationId,
                nearby = nearby,
                onExit = onExit
            })
        else 
            local options = {
                options = {
                    {
                        name = 'trickortreat',
                        type = "client",
                        action = function() 
                            trickOrTreat(locationId)   
                        end,
                        icon =  'fas fa-hand-fist',
                        label = locale("target.trickortreat"),
                    }
                },
                distance = config.interactDistance,
                rotation = 45
            }
            stevo_lib.target.AddBoxZone('stevotrickortreat'..locationId, location, vec3(3, 3, 3), options)  
        end 

        local blip = config.houseBlips
        if blip then 
            blips[locationId] = AddBlipForCoord(location.x, location.y, location.z)

            SetBlipAsShortRange(blips[locationId], true)
            SetBlipSprite(blips[locationId], blip.sprite) 
            SetBlipColour(blips[locationId], blip.color) 
            SetBlipScale(blips[locationId], blip.scale)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(locale("blips.house"))
            EndTextCommandSetBlipName(blips[locationId])

            SetBlipDisplay(blips[locationId], 4)
            SetBlipAsMissionCreatorBlip(blips[locationId], true)
        end
    end

    if config.candyBuyer then 
        local pedModel = config.candyBuyer.ped.model
        local pedCoords =  config.candyBuyer.ped.coords
        lib.requestModel(pedModel)

        local clown = CreatePed(28, pedModel, pedCoords.x, pedCoords.y, pedCoords.z, pedCoords.w, false, false)

        while not DoesEntityExist(clown) do Wait(50) end

        FreezeEntityPosition(clown, true)
        TaskStartScenarioInPlace(clown, 'WORLD_HUMAN_MUSICIAN', 0.0, true)
        SetModelAsNoLongerNeeded(pedModel)

        local vanModel = config.candyBuyer.van.model 
        local vanCoords = config.candyBuyer.van.coords
        lib.requestModel(vanModel)

        local van = CreateVehicle(vanModel, vanCoords.x, vanCoords.y, vanCoords.z, vanCoords.w, false, false)

        while not DoesEntityExist(van) do Wait(50) end

        FreezeEntityPosition(van, true)
        SetModelAsNoLongerNeeded(pedModel)
        SetVehicleDoorOpen(van, 2, false, false)
        SetVehicleDoorOpen(van, 3, false, false)
        SetVehicleDoorsLocked(van, 2)

        if config.interact == 'textui' then 
            lib.points.new({
                coords = pedCoords.xyz,
                distance = config.interactDistance,
                onExit = function(self)
                    lib.hideTextUI()
                end,
                onEnter = function(self)
                    lib.showTextUI(locale('textui.sellCandy')) 
                end,
                nearby = function(self)
                    if IsControlJustPressed(0, 38) then
                        local soldCandy, profit, candySold = lib.callback.await('stevo_trickortreat:sellCandy', false)

                        if soldCandy then 
                            stevo_lib.Notify(locale('notify.soldCandy', candySold, profit), 'success', 5000)
                        else 
                            stevo_lib.Notify(locale('notify.noCandy'), 'error', 3000)
                        end            
                    end
                end
            })
        else 
            local options = {
                options = {
                    {
                        name = 'trickortreat',
                        type = "client",
                        action = function() 
                            local soldCandy, profit, candySold = lib.callback.await('stevo_trickortreat:sellCandy', false)

                            if soldCandy then 
                                stevo_lib.Notify(locale('notify.soldCandy', candySold, profit), 'success', 5000)
                            else 
                                stevo_lib.Notify(locale('notify.noCandy'), 'error', 3000)
                            end
                        end,
                        icon =  'fas fa-handshake',
                        label = locale("target.sellcandy"),
                    }
                },
                distance = config.interactDistance,
                rotation = 45
            }
            stevo_lib.target.AddBoxZone('stevotrickortreatcandybuyer', pedCoords.xyz, vec3(3, 3, 3),  options) 
        end

        local blip = config.candyBuyer.blip
        if blip then 
            local clownBlip = AddBlipForCoord(vanCoords.x, vanCoords.y, vanCoords.z)

            SetBlipAsShortRange(clownBlip, true)
            SetBlipSprite(clownBlip, blip.sprite) 
            SetBlipColour(clownBlip, blip.color) 
            SetBlipScale(clownBlip, blip.scale)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(locale("blips.candyClown"))
            EndTextCommandSetBlipName(clownBlip)
            SetBlipDisplay(clownBlip, 4)
            SetBlipAsMissionCreatorBlip(clownBlip, true)
        end
    end

end

RegisterNetEvent('stevo_lib:playerLoaded', function()
    initHouses()
end)

AddEventHandler('onResourceStart', function(resource)
    if resource ~= cache.resource then return end

    initHouses()
end)

