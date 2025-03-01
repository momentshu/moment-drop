local drops = {}
local blips = {}

RegisterNetEvent("qb-drop:client:requestLocation", function(parcelCode)
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)

    TriggerServerEvent("qb-drop:server:registerDrop", parcelCode, pos)
    TriggerEvent('QBCore:Notify', "Parsel " .. parcelCode .. " konumunda drop oluşturuldu!", "success")
end)

RegisterNetEvent("qb-drop:client:createDrop", function(parcelCode, coords)
    local ground
    local maxAttempts = 100
    local groundFound = false
    local testZ = 1000.0
    local groundZ = coords.z

    while not groundFound and maxAttempts > 0 do
        local success, _groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, testZ, true)
        if success then
            groundZ = _groundZ
            groundFound = true
        else
            testZ = testZ - 10.0
        end
        maxAttempts = maxAttempts - 1
    end

    coords = vector3(coords.x, coords.y, groundZ + 1.0)
    drops[parcelCode] = coords
    
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, 501)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 1.0) 
    SetBlipColour(blip, 46)
    SetBlipAsShortRange(blip, false)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Drop: " .. parcelCode)
    EndTextCommandSetBlipName(blip)
    blips[parcelCode] = blip

    Citizen.CreateThread(function()
        while drops[parcelCode] do
            Citizen.Wait(0)
            local playerCoords = GetEntityCoords(PlayerPedId())
            local distance = #(playerCoords - coords)

            DrawMarker(1, 
                coords.x, coords.y, coords.z - 1.0, 
                0.0, 0.0, 0.0, 
                0.0, 0.0, 0.0,
                2.0, 2.0, 1.0,
                255, 215, 0, 150,
                false, false, 2, true, nil, nil, false)
            if distance < 3.0 then
                DrawText3D(coords.x, coords.y, coords.z + 0.5, "[E] Dropu Aç")

                if IsControlJustReleased(0, 38) then
                    TriggerServerEvent("qb-drop:server:pickup", parcelCode)
                end
            end
        end
    end)
end)

RegisterNetEvent("qb-drop:client:removeDrop", function(parcelCode)
    if blips[parcelCode] then
        RemoveBlip(blips[parcelCode])
        blips[parcelCode] = nil
    end
    drops[parcelCode] = nil
end)

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())

    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)

    local factor = (string.len(text)) / 370
    DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 0, 0, 0, 75)
end
