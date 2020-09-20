local NPAS = false
local SC019 = false
local RCPU1 = false
local RCPU2 = false
local RCPU3 = false

local vNPAS = {
    "polmav"
}

local vSC019 = {
    "x5",
    "policeold2",
    "sheriff2",
    "E39ARV"
}

local vRCPU1 = {
    "police2"
}

local vRCPU2 = {
    "E39"
}

local vRCPU3 = {
    "V70"
}

local identifiers = {}
function ShowInfo(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentSubstringPlayerName(text)
    DrawNotification(false, false)
end

Citizen.CreateThread(function()
    local myIdss = GetPlayerIdentifiers(PlayerPedId())
    while true do 
        Citizen.Wait(10000)
        TriggerServerEvent("veh_whitelist:checkPerms")
    end
end)

Citizen.CreateThread(function()
    while true do
        local ped = GetPlayerPed(-1)
        local inVeh = IsPedInAnyVehicle(ped, false)
        local veh = GetVehiclePedIsIn(ped)
        local driver = GetPedInVehicleSeat(veh, -1)

        if inVeh then
            if driver == ped then
                TriggerServerEvent("veh_whitelist:checkPerms")
            end
        end
    end
end)

RegisterNetEvent("veh_whitelist:pullPerms")
AddEventHandler("veh_whitelist:pullPerms", function(perms)
    local al = LoadResourceFile(GetCurrentResourceName(), "whitelist.json")
    local cfg = json.decode(al)
    local ranks = {}
    local myIds = GetPlayerIdentifiers(PlayerPedId())
    for pair,_ in pairs(cfg) do 
        -- Checks through file for steamID of 'source' (client)
        if (pair == myIds[1]) then
            -- Looks through internal pairs for ranks
            for _,v in ipairs(cfg[pair]) do
                -- checks if rank is applied
                if (v.member) then
                    table.insert(ranks, v.rank)
                end
            end
        end
    end
    if #ranks == 0 then
        Wait(0)
    else
        for i = 1, ranks do
            if string.upper(ranks[i].rank) == string.upper("NPAS") then
                NPAS = true
                return;
            end
            if string.upper(ranks[i].rank) == string.upper("SC019") then
                SC019 = true
                return;
            end
            if string.upper(ranks[i].rank) == string.upper("RCPU1") then
                RCPU1 = true
                return;
            end
            if string.upper(ranks[i].rank) == string.upper("RCPU2") then
                RCPU2 = true
                return;
            end
            if string.upper(ranks[i].rank) == string.upper("RCPU3") then
                RCPU3 = true
                return;
            end
        end
    end

    local inVeh = IsPedInAnyVehicle(GetPlayerPed(-1), false)
    local veh = GetEntityModel(GetVehiclePedIsIn(GetPlayerPed(-1)))
    local driver = GetPedInVehicleSeat(veh)
    if inVeh then
        if driver == GetPlayerPed(-1) then
            if NPAS == false then
                for i = 1, vNPAS do
                    if string.upper(veh) == string.upper(vNPAS[i]) then
                        DeleteEntity(veh)
                        ClearPedTasksImmediately(ped)
                        TriggerClientEvent('chatMessage', source, prefix .. "You do not have perms to access this vehicle.")
                    end
                end
                return;
            end
            if SC019 == false then
                for i = 1, vSC019 do
                    if string.upper(veh) == string.upper(vSC019[i]) then
                        DeleteEntity(veh)
                        ClearPedTasksImmediately(ped)
                        TriggerClientEvent('chatMessage', source, prefix .. "You do not have perms to access this vehicle.")
                    end
                end
                return;
            end
            if RCPU1 == false then
                for i = 1, vRCPU1 do
                    if string.upper(veh) == string.upper(vRCPU1[i]) then
                        DeleteEntity(veh)
                        ClearPedTasksImmediately(ped)
                        TriggerClientEvent('chatMessage', source, prefix .. "You do not have perms to access this vehicle.")
                    end
                end
                return;
            end
            if RCPU2 == false then
                for i = 1, vRCPU2 do
                    if string.upper(veh) == string.upper(vRCPU2[i]) then
                        DeleteEntity(veh)
                        ClearPedTasksImmediately(ped)
                        TriggerClientEvent('chatMessage', source, prefix .. "You do not have perms to access this vehicle.")
                    end
                end
                return;
            end
            if RCPU3 == false then
                for i = 1, vRCPU3 do
                    if string.upper(veh) == string.upper(vRCPU3[i]) then
                        DeleteEntity(veh)
                        ClearPedTasksImmediately(ped)
                        TriggerClientEvent('chatMessage', source, prefix .. "You do not have perms to access this vehicle.")
                    end
                end
                return;
            end
        end
    end
end)