QBCore = exports['qb-core']:GetCoreObject()
local postals = LoadResourceFile(GetCurrentResourceName(), "new-postals.json") 
postals = json.decode(postals)

local drops = {}

local function GiveRewards(source, areaType)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end

    local areaConfig = Config.AreaTypes[areaType]
    if not areaConfig then return end

    local givenRewards = {}
    
    for _, item in ipairs(areaConfig.items) do
        local amount = math.random(item.amount.min, item.amount.max)
        
        if item.name == "money" then
            Player.Functions.AddMoney('cash', amount)
            table.insert(givenRewards, amount .. "$ Para")
        else
            Player.Functions.AddItem(item.name, amount)
            TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[item.name], "add")
            table.insert(givenRewards, amount .. "x " .. QBCore.Shared.Items[item.name].label)
        end
    end

    if #givenRewards > 0 then
        local rewardText = "Aldığın ödüller:\n" .. table.concat(givenRewards, "\n")
        TriggerClientEvent('QBCore:Notify', source, rewardText, "success", 5000)
    end
end

RegisterCommand(Config.Commands.create, function(source, args, rawCommand)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end

        if not Player.PlayerData.permission == 'admin' then
            TriggerClientEvent('QBCore:Notify', source, "Bu komutu kullanma yetkiniz yok!", "error")
            return
        end
    

    local parcelCode = args[1] 
    local targetPostal = args[2] 
    local areaType = string.lower(args[3] or "normal") 

    if not parcelCode or parcelCode == "" then
        TriggerClientEvent('QBCore:Notify', source, "Kullanım: /drop [parsel_kodu] [postal_kodu] [bölge_tipi]", "error")
        return
    end

    if not targetPostal then
        TriggerClientEvent('QBCore:Notify', source, "Lütfen bir postal kodu girin!", "error")
        return
    end

    if not Config.AreaTypes[areaType] then
        TriggerClientEvent('QBCore:Notify', source, "Geçersiz bölge tipi! (normal/orta/yuksek)", "error")
        return
    end

    if drops[parcelCode] then
        TriggerClientEvent('QBCore:Notify', source, "Bu parselde zaten bir drop var!", "error")
        return
    end

    local postalCoords = nil
    for _, postal in ipairs(postals) do
        if postal.code == targetPostal then
            postalCoords = vector3(postal.x, postal.y, 30.0) 
            break
        end
    end

    if not postalCoords then
        TriggerClientEvent('QBCore:Notify', source, "Geçersiz postal kodu!", "error")
        return
    end

    drops[parcelCode] = {
        coords = postalCoords,
        pickedUp = false,
        areaType = areaType
    }

    TriggerClientEvent("qb-drop:client:createDrop", -1, parcelCode, postalCoords)
    TriggerClientEvent('QBCore:Notify', source, "Parsel " .. parcelCode .. " postal " .. targetPostal .. " konumuna bırakıldı!", "success")
    print("[DROP] Parsel " .. parcelCode .. " postal " .. targetPostal .. " konumunda drop bırakıldı.")
end)

RegisterNetEvent("qb-drop:server:registerDrop", function(parcelCode, pos)
    if not parcelCode or not pos then return end

    drops[parcelCode] = {
        coords = pos,
        pickedUp = false
    }

    TriggerClientEvent("qb-drop:client:createDrop", -1, parcelCode, pos)
    print("[DROP] Parsel " .. parcelCode .. " konumunda drop bırakıldı.")
end)

RegisterNetEvent("qb-drop:server:pickup", function(parcelCode)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not drops[parcelCode] or drops[parcelCode].pickedUp then return end

    local areaType = drops[parcelCode].areaType or "normal"
    drops[parcelCode].pickedUp = true
    TriggerClientEvent("qb-drop:client:removeDrop", -1, parcelCode)
    GiveRewards(src, areaType)
end)
