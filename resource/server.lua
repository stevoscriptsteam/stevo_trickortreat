if not lib.checkDependency('stevo_lib', '1.7.1') then error('stevo_lib 1.7.1 required for stevo_trickortreat') end
lib.versionCheck('stevoscriptsteam/stevo_trickortreat')
lib.locale()
local config = require('config')
local stevo_lib = exports['stevo_lib']:import()
local activeCooldowns = {}

lib.callback.register('stevo_trickortreat:canKnock', function(source, houseId)
    if activeCooldowns[source] then 
        if activeCooldowns[source][houseId] then 
            if activeCooldowns[source][houseId] > os.time() then 
                return false
            end 
        end
    end

    return true
end)


lib.callback.register('stevo_trickortreat:knockedOnDoor', function(source, houseId)

    local location = config.houses[houseId]
    local playerPed = GetPlayerPed(source)
    local playerCoords = GetEntityCoords(playerPed)
    math.randomseed(os.time())

    if #(playerCoords - location) > config.interactDistance then 
        local name = GetPlayerName(source)
        local identifier = stevo_lib.GetIdentifier(source)

        lib.print.info(('User: %s (%s) tried to exploit stevo_trickortreat'):format(name, identifier))
        if config.dropCheaters then 
            DropPlayer(source, 'Trying to exploit stevo_trickortreat')
        end

        return false
    end

    local cooldown = os.time() + config.knockCooldown * 60

    if not activeCooldowns[source] then 
        activeCooldowns[source] = {}
    end
        
    activeCooldowns[source][houseId] = cooldown

    local trickChance = math.random(1, 100)
             
    if trickChance <= config.trickChance then 
        local ped = math.random(1, #config.trickPeds)
        local weapon = math.random(1, #config.trickWeapons)

        return {ped = config.trickPeds[ped], weapon = config.trickWeapons[weapon]}
    end


    local treatAmount = math.random(config.treatAmount.min, config.treatAmount.max)
    local treat = math.random(1, #config.treats)
    stevo_lib.AddItem(source, config.treats[treat], treatAmount)

    return false
end)

lib.callback.register('stevo_trickortreat:sellCandy', function(source)
    local candySold = 0 
    local profit = 0
    local soldCandy = false

    for _, candy in pairs(config.treats) do 
        local amount = stevo_lib.HasItem(source, candy)

        if amount > 1 then 
            local payout = amount * math.random(config.candyBuyer.candySellPrice.min, config.candyBuyer.candySellPrice.max)

            stevo_lib.RemoveItem(source, candy, amount)

            candySold = candySold + amount 
            profit = profit + payout
            soldCandy = true
        end
    end

    if soldCandy then 
        stevo_lib.AddItem(source, 'money', profit)
    end

    return soldCandy, profit, candySold
end)