model = nil
canspawn = true
hash = nil

------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------
-------------------------------------------- COMMANDS ------------------------------------------------
------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------

RegisterCommand('car', function(source, args)
    local ped = GetPlayerPed(-1)
    model = args[1]
    if model ~= nil then
        if not IsPedInAnyVehicle(ped, true) then
            TriggerEvent('cd_cartest:spawnCar', model)
        else
            TriggerEvent('cd_cartest:DeleteVehicle2', GetVehiclePedIsUsing(ped))
            Wait(1000)
            TriggerEvent('cd_cartest:spawnCar', model)
        end
    end
end)

RegisterCommand('carm', function(source, args)
    local ped = GetPlayerPed(-1)
    model = args[1]
    if model ~= nil then
        if not IsPedInAnyVehicle(ped, true) then
            TriggerEvent('cd_cartest:spawnCarMaxed', model)
        else
            TriggerEvent('cd_cartest:DeleteVehicle2', GetVehiclePedIsUsing(ped))
            Wait(1000)
            TriggerEvent('cd_cartest:spawnCarMaxed', model)
        end
    end
end)

RegisterCommand('dv', function()
    local ped = GetPlayerPed(-1)
    local coordA = GetEntityCoords(ped, 1)
    local coordB = GetOffsetFromEntityInWorldCoords(ped, 0.0, 5.0, 0.0)
    local vehicleinfront = getVehicleInDirection(coordA, coordB)

    TriggerEvent('cd_cartest:DeleteVehicle2', vehicleinfront)
    TriggerEvent('cd_cartest:DeleteVehicle2', GetVehiclePedIsUsing(ped))
end)

RegisterCommand('legion', function()
    local ped = GetPlayerPed(-1)
    local vehiclein = GetVehiclePedIsUsing(ped)
    local loc = vector3(232.56, -850.60, 29.39)
   
    if IsPedInAnyVehicle(ped, true) then
        SetEntityCoords(vehiclein, loc)
    else
        SetEntityCoords(ped, loc)
    end
end)

RegisterCommand('highway', function()
    local ped = GetPlayerPed(-1)
    local vehiclein = GetVehiclePedIsUsing(ped)
    local loc = vector3(2384.1853, 5748.9931, 44.765426)
   
    if IsPedInAnyVehicle(ped, true) then
        SetEntityCoords(vehiclein, loc)
    else
        SetEntityCoords(ped, loc)
    end
end)

RegisterCommand('setday', function()
    ExecuteCommand('time 12 00')
end)

RegisterCommand('setnight', function()
    ExecuteCommand('time 24 00')
end)

RegisterKeyMapping('dv', 'Delete Vehicle', 'KEYBOARD', 'G')
RegisterKeyMapping('setday', 'Set Day', 'KEYBOARD', 'F3')
RegisterKeyMapping('setnight', 'Set Night', 'KEYBOARD', 'F4')
RegisterKeyMapping('legion', 'TP Legion', 'KEYBOARD', 'F5')
RegisterKeyMapping('highway', 'TP Highway', 'KEYBOARD', 'F6')

------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------
------------------------------------------- MAIN THREAD ----------------------------------------------
------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------

RegisterNetEvent('cd_cartest:spawnCar')
AddEventHandler('cd_cartest:spawnCar', function(model)
    if canspawn then
        if model then
            local ped = GetPlayerPed(-1)
            local coords = GetEntityCoords(ped)
            local heading = GetEntityHeading(ped)
            TriggerEvent('cd_cartest:SpawnVehicle2',model, coords, heading, true, 'dt', 100, true, false)
        else
        end
    else
        ShowNotification('Wait for the chat message before spawning in cars')
    end
end)

RegisterNetEvent('cd_cartest:spawnCarMaxed')
AddEventHandler('cd_cartest:spawnCarMaxed', function(model)
    if canspawn then
        if model then
            local ped = GetPlayerPed(-1)
            local coords = GetEntityCoords(ped)
            local heading = GetEntityHeading(ped)
            TriggerEvent('cd_cartest:SpawnVehicle2',model, coords, heading, true, 'dt', 100, true, true)
        else
        end
    else
        ShowNotification('Wait for the chat message before spawning in cars')
    end
end)

------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------
--------------------------------------- MANAGING VEHICLES --------------------------------------------
------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------

RegisterNetEvent('cd_cartest:DeleteVehicle2')
AddEventHandler('cd_cartest:DeleteVehicle2', function(vehicle, checkforvehicle)
    if vehicle ~= nil then
        NetworkRequestControlOfEntity(vehicle)
        local timeout = 0
        local finaltimer = 0
        local dots = "."
        while not NetworkHasControlOfEntity(vehicle) and timeout <= 400 do 
            Citizen.Wait(5)
            timeout = timeout + 1
            for k, v in pairs (TimerTable) do
                if timeout == v.time then
                    finaltimer = finaltimer + 1
                    dots = DotMe(dots)
                end
            end
            NetworkRequestControlOfEntity(vehicle)
        end

        local timeout = 0
        local finaltimer = 0
        local dots = "."
        local netID = NetworkGetNetworkIdFromEntity(vehicle)
        while not NetworkHasControlOfNetworkId(netID) and timeout <= 400 do 
            Citizen.Wait(5)
            timeout = timeout + 1
            for k, v in pairs (TimerTable) do
                if timeout == v.time then
                    finaltimer = finaltimer + 1
                    dots = DotMe(dots)
                end
            end
            NetworkRequestControlOfNetworkId(netID)
        end

        if NetworkHasControlOfEntity(vehicle) then
            SetEntityAsMissionEntity(vehicle)
            SetVehicleHasBeenOwnedByPlayer(vehicle, true)
            NetworkFadeOutEntity(vehicle, true, true)
            Citizen.Wait(100)
            Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(vehicle))
            SetEntityAsNoLongerNeeded(vehicle)
            DeleteEntity(vehicle)
            DeleteVehicle(vehicle)
            print('VEHICLE DELETED')
        else
            TriggerServerEvent('cd_cartest:DeleteVehicleADV2', netID)
        end
    end
end)

RegisterNetEvent('cd_cartest:DeleteVehicleADV2')
AddEventHandler('cd_cartest:DeleteVehicleADV2', function(netID)
    local entID = NetworkGetEntityFromNetworkId(netID)
    if NetworkHasControlOfEntity(entID) then
        SetEntityAsNoLongerNeeded(entID)
        NetworkFadeOutEntity(entID, true, true)
        Citizen.Wait(100)
        Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(entID))
        DeleteEntity(entID)
        DeleteVehicle(entID)
        print('cd_cartest:DeleteVehicleADV2 - VEHICLE DELETED')
    else
        return
    end
end)

RegisterNetEvent('cd_cartest:SpawnVehicle2')
AddEventHandler('cd_cartest:SpawnVehicle2', function(modelName, coords, heading, ownedcar, changeplate, fuel, incar, max)

    local model = (type(modelName) == 'number' and modelName or GetHashKey(modelName))
    model = model
    if not IsModelValid(model) then
        return ShowNotification('Invalid vehicle name')
    end

    Citizen.CreateThread(function()
        if not HasModelLoaded(model) and IsModelInCdimage(model) then
            RequestModel(model)
            local timeout = 0
            local dots = "."
            while not HasModelLoaded(model) do
                timeout = timeout + 1
                for k, v in pairs (TimerTable2) do
                    if timeout == v.time then
                        dots = DotMe(dots)
                    end
                end
                Citizen.Wait(5)
                --DrawScreenText2("Loading Model : "..GetDisplayNameFromVehicleModel(model).." "..dots)
            end
        end

        local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, heading, true, false)
        lastVehicle = vehicle

        local timeout = 0
        local finaltimer = 0
        local dots = "."
        while not DoesEntityExist(vehicle) and timeout <= 400 do 
            Citizen.Wait(5)
            timeout = timeout + 1
            for k, v in pairs (TimerTable) do
                if timeout == v.time then
                    finaltimer = finaltimer + 1
                    dots = DotMe(dots)
                end
            end
            --DrawScreenText2("Registering Entity "..finaltimer.."/20".." "..dots)
        end
        if not DoesEntityExist(vehicle) then
            TriggerEvent('cd_cartest:DeleteVehicle2', vehicle)
            ShowNotification('Could not register the entity - please try again')
        end

        NetworkFadeInEntity(vehicle, true, true)
        SetVehicleOnGroundProperly(vehicle)

        if ownedcar then
            local timeout = 0
            local finaltimer = 0
            local dots = "."
            while not NetworkHasControlOfEntity(vehicle) and timeout <= 400 do 
                Citizen.Wait(5)
                timeout = timeout + 1
                for k, v in pairs (TimerTable) do
                    if timeout == v.time then
                        finaltimer = finaltimer + 1
                        dots = DotMe(dots)
                    end
                end
                NetworkRequestControlOfEntity(vehicle)
                DrawScreenText2("Requesting Network Control "..finaltimer.."/20".." "..dots)
            end
            if not NetworkHasControlOfEntity(vehicle) then
                TriggerEvent('cd_cartest:DeleteVehicle2', vehicle)
                ShowNotification('Could not request network control - please try again')
            end

            local timeout = 0
            local finaltimer = 0
            local dots = "."
            while not NetworkGetEntityIsNetworked(vehicle) and timeout <= 400 do 
                Citizen.Wait(5)
                timeout = timeout + 1
                for k, v in pairs (TimerTable) do
                    if timeout == v.time then
                        finaltimer = finaltimer + 1
                        dots = DotMe(dots)
                    end
                end
                NetworkRegisterEntityAsNetworked(vehicle)
                DrawScreenText2("Registering Entity as Networked "..finaltimer.."/20".." "..dots)
            end
            if not NetworkGetEntityIsNetworked(vehicle) then
                TriggerEvent('cd_cartest:DeleteVehicle2', vehicle)
                ShowNotification('Could not register the entity as networked - please try again')
            end            

            SetEntityAsMissionEntity(vehicle, true, true)
            SetVehicleHasBeenOwnedByPlayer(vehicle, true)
            local netid = NetworkGetNetworkIdFromEntity(vehicle)
            SetNetworkIdCanMigrate(netid, true)
            SetNetworkIdExistsOnAllMachines(netid, true)
            NetworkRequestControlOfEntity(vehicle)
        end
        
        SetModelAsNoLongerNeeded(vehicle)
        SetVehicleDirtLevel(vehicle)
        WashDecalsFromVehicle(vehicle, 1.0)
        SetVehicleExtraColours(vehicle, 0, 0)
        if changeplate ~= nil then
            local length = #changeplate
            local result = 8-length
            if result ~= 8 then
                aidsMaths(result)
                SetVehicleNumberPlateText(vehicle, changeplate..''..random)
            else
                SetVehicleNumberPlateText(vehicle, changeplate)
            end
        end

        if fuel ~= nil then
            DecorSetInt(vehicle, "_FUEL_LEVEL", math.ceil(100))
        else
            DecorSetInt(vehicle, "_FUEL_LEVEL", math.ceil(fuel))
        end
        if incar then
            SetPedIntoVehicle(GetPlayerPed(-1), vehicle, -1)
        end

        RequestCollisionAtCoord(coords.x, coords.y, coords.z)
        while not HasCollisionLoadedAroundEntity(vehicle) do
            RequestCollisionAtCoord(coords.x, coords.y, coords.z)
            Citizen.Wait(0)
        end

        SetVehRadioStation(vehicle, 'OFF')

        if max then
            Wait(500)
            SetVehicleMaxMods(vehicle)
        end
        SetModelAsNoLongerNeeded(model)
        --ShowNotification('Spawned vehicle - '..model)
        ShowNotification('Vehicle spawned')
    end)
end)

function ShowNotification(message)
    SetNotificationTextEntry('STRING')
	AddTextComponentSubstringWebsite(message)
    DrawNotification(false, true)
end