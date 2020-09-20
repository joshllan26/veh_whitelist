local chatprefix = "^0[^8SYSTEM^0] "


-- Pulls Data from json file
RegisterServerEvent("veh_whitelist:checkPerms")
AddEventHandler("veh_whitelist:checkPerms", function()
    local config = LoadResourceFile(GetCurrentResourceName(), "whitelist.json")
    local cfg = json.decode(config)
    TriggerClientEvent("veh_whitelist:pullPerms", source, cfg)
end)

-- Inserts data into json file
RegisterServerEvent("veh_whitelist:saveFile")
AddEventHandler("veh_whitelist:saveFile", function(data)
    SaveResourceFile(GetCurrentResourceName(), "whitelist.json", json.encode(data, { indent = true }), -1)
end)

-- Command for checking player ranks
RegisterCommand("veh-ranks", function(source, args, rawCommand)
    local al = LoadResourceFile(GetCurrentResourceName(), "whitelist.json")
    local cfg = json.decode(al)
    local ranks = {}
    local myIds = GetPlayerIdentifiers(source)
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
    if #ranks > 0 then
        TriggerClientEvent('chatMessage', source, prefix .. "You are a member of the following vehicle ranks:")
        TriggerClientEvent('chatMessage', source, "^0" .. table.concat(ranks, ', '))
    else
        TriggerClientEvent('chatMessage', source, prefix .. "You are not a member of any vehicle ranks.")
    end
end)

-- Command for adding manager's to ranks (e.g. department leads/management)
RegisterCommand("setManager", function(source, args, rawCommand)
    if IsPlayerAceAllowed(source, "VehWhitelist.SetManager.Command") then
        if #args < 2 then
            -- Too low args
            TriggerClientEvent('chatMessage', source, prefix .. "Not enough arguments have been provided. Usage: /setManager <id> <rank>")
            return;
        end
        local id = tonumber(args[1])
        if GetPlayerIdentifiers(id)[1] == nil then
            TriggerClientEvent('chatMessage', source, prefix .. "Invalid player ID.")
            return;
        end
        -- If all with command is in check
        local vrank = string.upper(args[2])
        local identifiers = GetPlayerIdentifiers(id)
        local steam = identifiers[1]
        local al = LoadResourceFile(GetPlayerIdentifiers(), "whitelist.json")
        local cfg = json.decode(al)

        local vehicleList = cfg[steam]
        if vehicleList == nil then
            cfg[steam] = {}
            vehicleList = {}
        end
        local hasValue = false
        local index = nil
        for i = 1, #vehicleList do
            if string.upper(vrank) == string.upper(vehicleList[i].rank) then
                hasValue = true
                index = i
            end
        end
        if not hasValue then
            table.insert(vehicleList, {
                manager=true,
                member=true,
                rank=vrank,
            })
        else
            vehicleList[index].manager = true
            vehicleList[index].member = true
        end
        cfg[steam] = vehicleList
        TriggerEvent("veh_whitelist:saveFile", cfg)
        TriggerClientEvent('chatMessage', source, prefix .. "Success: You have set " .. GetPlayerName(id) .. " as a manager of vehicle rank " .. vrank)
        TriggerClientEvent('chatMessage', id, prefix .. "You have been set as a manager of vehicle group " .. vrank .. " by " .. GetPlayerName(source))
    end
end)

-- Command to add a member to a vehicle rank group
RegisterCommand("addMember", function(source, args, rawCommand)
    local al = LoadResourceFile(GetCurrentResourceName(), "whitelist.json")
    local cfg = json.decode(al)
    -- changing args to vars
    local vrank = string.upper(args[2])
    local id = tonumber(args[1])
    -- Check number of args
    if #args < 2 then
        TriggerClientEvent('chatMessage', source, prefix .. "Incorrect usage. Usage: /addMember <id> <rank>")
        return;
    end
    -- Checks if id provided is valid
    if id == source then
        TriggerClientEvent('chatMessage', source, prefix .. "You can not add yourself as a member stupid!")
        return;
    end
    if GetPlayerIdentifiers(id)[1] == nil then
        TriggerClientEvent('chatMessage', source, prefix .. "That is not a valid player ID")
        return;
    end
    local steam = GetPlayerIdentifiers(id)[1]
    local rankManager = false
    -- check
    for pair,_ in pairs(cfg) do
        if tostring(GetPlayerIdentifiers(source)[1]) == tostring(pair) then
            for _,rk in ipairs(cfg[pair]) do
                if string.upper(rk.rank) == string.upper(vrank) then
                    if rk.manager == true then
                        rankManager = true
                    end
                end
            end
        end
    end
    if not rankManager then
        TriggerClientEvent('chatMessage', source, prefix .. "You are not a manager of this vehicle rank group.")
        return;
    end
    local vehicleList = cfg[steam]
    if vehicleList == nil then
        cfg[steam] = {}
        vehicleList = {}
    end
    local hasValue = false
    local index = nil
    for i = 1, #vehicleList do
        if string.upper(vrank) == string.upper(vehicleList[i].rank) then
            hasValue = true
            index = i 
        end
    end
    if not hasValue then
        table.insert(vehicleList, {
            manager=false,
            member=true,
            rank=vrank,
        })
    else
        vehicleList[index].manager = false
        vehicleList[index].member = true
    end
    cfg[steam] = vehicleList
    TriggerEvent("veh_whitelist:saveFile", cfg)
    TriggerClientEvent('chatMessage', source, prefix .. "You have successfully added " .. GetPlayerName(id) .. " to vehicle group " .. vrank .. " as a member.")
    TriggerClientEvent('chatMessage', id, prefix .. "You have been added as a member of vehicle rank " .. vrank .. " by " .. GetPlayerName(source))
end)

-- Command for removing members from vehicle group
RegisterCommand("removeMember", function(source, args, rawCommand)
    local al = LoadResourceFile(GetCurrentResourceName(), "whitelist.json")
    local cfg = json.decode(al)
    local vrank = string.upper(args[2])
    local id = tonumber(args[1])
    -- Check number of args
    if #args < 2 then
        TriggerClientEvent('chatMessage', source, prefix .. "Incorrect usage! Usage: /removeMember <id> <rank>")
        return;
    end
    -- Check if id actually exists
    if id == source then
        TriggerClientEvent('chatMessage', source, prefix .. "You can not remove yourself from a group idiot!")
        return;
    end
    if GetPlayerIdentifiers(id)[1] == nil then
        TriggerClientEvent('chatMessage', source, prefix .. "Invalid player ID.")
        return;
    end
    local steam = GetPlayerIdentifiers(id)[1]
    local rankManager = false
    -- Check if player is manager
    for pair,_ in pairs(cfg) do
        if tostring(GetPlayerIdentifiers(source)[1]) == tostring(pair) then
            for _,rk in ipairs(cfg[pair]) do
                if string.upper(rk.rank) == string.upper(vrank) then
                    if rk.manager == true then
                        rankManager = true
                    end
                end
            end
        end
    end
    if not rankManager then
        TriggerClientEvent('chatMessage', source, prefix .. "You do not have the required permissions to execute this command!")
        return;
    end
    local vehicleList = cfg[steam]
    if vehicleList == nil then
        cfg[steam] = {}
        vehicleList = {}
    end
    local hasValue = false
    local index = nil
    for i = 1, #vehicleList do
        if string.upper(vrank) == string.upper(vehicleList[i].rank) then
            hasValue = true
            index = i 
        end
    end
    if not hasValue then
        table.insert(vehicleList, {
            manager=false,
            member=false,
            rank=vrank,
        })
    else
        vehicleList[index].manager = false
        vehicleList[index].member = false
    end
    cfg[steam] = vehicleList
    TriggerEvent("veh_whitelist:saveFile", cfg)
    TriggerClientEvent('chatMessage', source, prefix .. "You removed " .. GetPlayerName(id) .. " from group " .. vrank)
    TriggerClientEvent('chatMessage', id, prefix.. "You were removed from group " .. vrank .. " by " .. GetPlayerName(source))
end)