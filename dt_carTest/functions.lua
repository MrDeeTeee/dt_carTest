Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        SetTrafficDensity(0)
        SetPedDensity(0)
        for i=0,20 do
            EnableDispatchService(i, not true)
        end
        
    end
end)

function SetTrafficDensity(density)
    SetParkedVehicleDensityMultiplierThisFrame(density)
    SetVehicleDensityMultiplierThisFrame(density)
    SetRandomVehicleDensityMultiplierThisFrame(density)
end

function SetPedDensity(density)
    SetPedDensityMultiplierThisFrame(density)
    SetScenarioPedDensityMultiplierThisFrame(density, density)
end

function SetVehicleMaxMods(vehicle)
    local props = {
        modEngine       = 3,
        modBrakes       = 2,
        modTransmission = 2,
        modSuspension   = 3,
        modArmor        = 4,
        modTurbo        = true,
    }

    SetVehicleProperties(vehicle, props)
end

function DrawScreenText1(text)
    SetTextFont(4)
    SetTextScale(0.0, 0.8)
    SetTextColour(255, 255, 255, 150)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextCentre(true)
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(0.5, 0.9)
end

function DrawScreenText2(text)
    SetTextFont(4)
    SetTextScale(0.0, 0.5)
    SetTextColour(255, 255, 255, 150)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextCentre(true)
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(0.5, 0.5)
end

function Draw2DText(x, y, text)
    SetTextScale(0.25, 0.25)
    SetTextFont(9)
    SetTextProportional(1)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextEntry("STRING")
    SetTextCentre(1)
    SetTextOutline()
    AddTextComponentString(text)
    DrawText(x, y)
end

function GetVehicles()
    local vehicles = {}

    for vehicle in EnumerateVehicles() do
        table.insert(vehicles, vehicle)
    end

    return vehicles
end

function getVehicleInDirection(coordFrom, coordTo)
    local offset = 0
    local rayHandle
    local vehicle

    for i = 0, 100 do
        rayHandle = CastRayPointToPoint(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z + offset, 10, PlayerPedId(), 0)    
        a, b, c, d, vehicle = GetRaycastResult(rayHandle)
        
        offset = offset - 1

        if vehicle ~= 0 then break end
    end
    
    local distance = Vdist2(coordFrom, GetEntityCoords(vehicle))
    
    if distance > 25 then vehicle = nil end

    return vehicle ~= nil and vehicle or 0
end

function Round(value, numDecimalPlaces)
    return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", value))
end

local entityEnumerator = {
    __gc = function(enum)
        if enum.destructor and enum.handle then
            enum.destructor(enum.handle)
        end

        enum.destructor = nil
        enum.handle = nil
    end
}

local function EnumerateEntities(initFunc, moveFunc, disposeFunc)
    return coroutine.wrap(function()
        local iter, id = initFunc()
        if not id or id == 0 then
            disposeFunc(iter)
            return
        end

        local enum = {handle = iter, destructor = disposeFunc}
        setmetatable(enum, entityEnumerator)

        local next = true
        repeat
        coroutine.yield(id)
        next, id = moveFunc(iter)
        until not next

        enum.destructor, enum.handle = nil, nil
        disposeFunc(iter)
    end)
end

function EnumerateVehicles()
    return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
end

function SetVehicleProperties(vehicle, props)
    if DoesEntityExist(vehicle) then
        SetVehicleModKit(vehicle, 0)

        if props.plate then SetVehicleNumberPlateText(vehicle, props.plate) end
        if props.plateIndex then SetVehicleNumberPlateTextIndex(vehicle, props.plateIndex) end
        if props.bodyHealth then SetVehicleBodyHealth(vehicle, props.bodyHealth + 0.0) end
        if props.engineHealth then SetVehicleEngineHealth(vehicle, props.engineHealth + 0.0) end
        if props.fuelLevel then DecorSetInt(vehicle, "_FUEL_LEVEL", Round(props.fuelLevel)) end
        if props.dirtLevel then SetVehicleDirtLevel(vehicle, props.dirtLevel + 0.0) end
        if props.color1 then SetVehicleColours(vehicle, props.color1, props.color2) end
        if props.color2 then SetVehicleColours(vehicle, props.color1, props.color2) end
        if props.pearlescentColor then SetVehicleExtraColours(vehicle, props.pearlescentColor, props.wheelColor) end
        if props.wheelColor then SetVehicleExtraColours(vehicle, pearlescentColor, props.wheelColor) end
        if props.wheels then SetVehicleWheelType(vehicle, props.wheels) end
        if props.windowTint then SetVehicleWindowTint(vehicle, props.windowTint) end

        if props.neonEnabled then
            SetVehicleNeonLightEnabled(vehicle, 0, props.neonEnabled[1])
            SetVehicleNeonLightEnabled(vehicle, 1, props.neonEnabled[2])
            SetVehicleNeonLightEnabled(vehicle, 2, props.neonEnabled[3])
            SetVehicleNeonLightEnabled(vehicle, 3, props.neonEnabled[4])
        end

        if props.extras then
            for id,enabled in pairs(props.extras) do
                if enabled then
                    SetVehicleExtra(vehicle, tonumber(id), 0)
                else
                    SetVehicleExtra(vehicle, tonumber(id), 1)
                end
            end
        end

        if props.neonColor then SetVehicleNeonLightsColour(vehicle, props.neonColor[1], props.neonColor[2], props.neonColor[3]) end
        if props.xenonColor then SetVehicleXenonLightsColour(vehicle, props.xenonColor) end
        if props.modSmokeEnabled then ToggleVehicleMod(vehicle, 20, true) end
        if props.tyreSmokeColor then SetVehicleTyreSmokeColor(vehicle, props.tyreSmokeColor[1], props.tyreSmokeColor[2], props.tyreSmokeColor[3]) end
        if props.modSpoilers then SetVehicleMod(vehicle, 0, props.modSpoilers, false) end
        if props.modFrontBumper then SetVehicleMod(vehicle, 1, props.modFrontBumper, false) end
        if props.modRearBumper then SetVehicleMod(vehicle, 2, props.modRearBumper, false) end
        if props.modSideSkirt then SetVehicleMod(vehicle, 3, props.modSideSkirt, false) end
        if props.modExhaust then SetVehicleMod(vehicle, 4, props.modExhaust, false) end
        if props.modFrame then SetVehicleMod(vehicle, 5, props.modFrame, false) end
        if props.modGrille then SetVehicleMod(vehicle, 6, props.modGrille, false) end
        if props.modHood then SetVehicleMod(vehicle, 7, props.modHood, false) end
        if props.modFender then SetVehicleMod(vehicle, 8, props.modFender, false) end
        if props.modRightFender then SetVehicleMod(vehicle, 9, props.modRightFender, false) end
        if props.modRoof then SetVehicleMod(vehicle, 10, props.modRoof, false) end
        if props.modEngine then SetVehicleMod(vehicle, 11, props.modEngine, false) end
        if props.modBrakes then SetVehicleMod(vehicle, 12, props.modBrakes, false) end
        if props.modTransmission then SetVehicleMod(vehicle, 13, props.modTransmission, false) end
        if props.modHorns then SetVehicleMod(vehicle, 14, props.modHorns, false) end
        if props.modSuspension then SetVehicleMod(vehicle, 15, props.modSuspension, false) end
        if props.modArmor then SetVehicleMod(vehicle, 16, props.modArmor, false) end
        if props.modTurbo then ToggleVehicleMod(vehicle,  18, props.modTurbo) end
        if props.modXenon then ToggleVehicleMod(vehicle,  22, props.modXenon) end
        if props.modFrontWheels then SetVehicleMod(vehicle, 23, props.modFrontWheels, false) end
        if props.modBackWheels then SetVehicleMod(vehicle, 24, props.modBackWheels, false) end
        if props.modPlateHolder then SetVehicleMod(vehicle, 25, props.modPlateHolder, false) end
        if props.modVanityPlate then SetVehicleMod(vehicle, 26, props.modVanityPlate, false) end
        if props.modTrimA then SetVehicleMod(vehicle, 27, props.modTrimA, false) end
        if props.modOrnaments then SetVehicleMod(vehicle, 28, props.modOrnaments, false) end
        if props.modDashboard then SetVehicleMod(vehicle, 29, props.modDashboard, false) end
        if props.modDial then SetVehicleMod(vehicle, 30, props.modDial, false) end
        if props.modDoorSpeaker then SetVehicleMod(vehicle, 31, props.modDoorSpeaker, false) end
        if props.modSeats then SetVehicleMod(vehicle, 32, props.modSeats, false) end
        if props.modSteeringWheel then SetVehicleMod(vehicle, 33, props.modSteeringWheel, false) end
        if props.modShifterLeavers then SetVehicleMod(vehicle, 34, props.modShifterLeavers, false) end
        if props.modAPlate then SetVehicleMod(vehicle, 35, props.modAPlate, false) end
        if props.modSpeakers then SetVehicleMod(vehicle, 36, props.modSpeakers, false) end
        if props.modTrunk then SetVehicleMod(vehicle, 37, props.modTrunk, false) end
        if props.modHydrolic then SetVehicleMod(vehicle, 38, props.modHydrolic, false) end
        if props.modEngineBlock then SetVehicleMod(vehicle, 39, props.modEngineBlock, false) end
        if props.modAirFilter then SetVehicleMod(vehicle, 40, props.modAirFilter, false) end
        if props.modStruts then SetVehicleMod(vehicle, 41, props.modStruts, false) end
        if props.modArchCover then SetVehicleMod(vehicle, 42, props.modArchCover, false) end
        if props.modAerials then SetVehicleMod(vehicle, 43, props.modAerials, false) end
        if props.modTrimB then SetVehicleMod(vehicle, 44, props.modTrimB, false) end
        if props.modTank then SetVehicleMod(vehicle, 45, props.modTank, false) end
        if props.modWindows then SetVehicleMod(vehicle, 46, props.modWindows, false) end

        if props.modLivery then
            SetVehicleLivery(vehicle, props.modLivery)
        end
    end
end

function GetVehicleProperties(vehicle)
    if DoesEntityExist(vehicle) then
        local colorPrimary, colorSecondary = GetVehicleColours(vehicle)
        local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
        local extras = {}

        for id=0, 12 do
            if DoesExtraExist(vehicle, id) then
                local state = IsVehicleExtraTurnedOn(vehicle, id) == 1
                extras[tostring(id)] = state
            end
        end

        return {
            model             = GetEntityModel(vehicle),

            plate             = GetVehicleNumberPlateText(vehicle), 
            plateIndex        = GetVehicleNumberPlateTextIndex(vehicle),

            bodyHealth        = Round(GetVehicleBodyHealth(vehicle)),
            engineHealth      = Round(GetVehicleEngineHealth(vehicle)),
            --engine2             = (GetVehicleEngineHealth(vehicle)/10),
            --engine              = (GetVehicleBodyHealth(vehicle)/10),
            fuelLevel         = Round(DecorGetInt(vehicle, "_FUEL_LEVEL")),
            dirtLevel         = Round(GetVehicleDirtLevel(vehicle), 1),
            color1            = colorPrimary,
            color2            = colorSecondary,

            pearlescentColor  = pearlescentColor,
            wheelColor        = wheelColor,

            wheels            = GetVehicleWheelType(vehicle),
            windowTint        = GetVehicleWindowTint(vehicle),
            xenonColor        = GetVehicleXenonLightsColour(vehicle),

            neonEnabled       = {
                IsVehicleNeonLightEnabled(vehicle, 0),
                IsVehicleNeonLightEnabled(vehicle, 1),
                IsVehicleNeonLightEnabled(vehicle, 2),
                IsVehicleNeonLightEnabled(vehicle, 3)
            },

            neonColor         = table.pack(GetVehicleNeonLightsColour(vehicle)),
            extras            = extras,
            tyreSmokeColor    = table.pack(GetVehicleTyreSmokeColor(vehicle)),

            modSpoilers       = GetVehicleMod(vehicle, 0),
            modFrontBumper    = GetVehicleMod(vehicle, 1),
            modRearBumper     = GetVehicleMod(vehicle, 2),
            modSideSkirt      = GetVehicleMod(vehicle, 3),
            modExhaust        = GetVehicleMod(vehicle, 4),
            modFrame          = GetVehicleMod(vehicle, 5),
            modGrille         = GetVehicleMod(vehicle, 6),
            modHood           = GetVehicleMod(vehicle, 7),
            modFender         = GetVehicleMod(vehicle, 8),
            modRightFender    = GetVehicleMod(vehicle, 9),
            modRoof           = GetVehicleMod(vehicle, 10),

            modEngine         = GetVehicleMod(vehicle, 11),
            modBrakes         = GetVehicleMod(vehicle, 12),
            modTransmission   = GetVehicleMod(vehicle, 13),
            modHorns          = GetVehicleMod(vehicle, 14),
            modSuspension     = GetVehicleMod(vehicle, 15),
            modArmor          = GetVehicleMod(vehicle, 16),

            modTurbo          = IsToggleModOn(vehicle, 18),

            modSmokeEnabled   = IsToggleModOn(vehicle, 20),
            modXenon          = IsToggleModOn(vehicle, 22),

            modFrontWheels    = GetVehicleMod(vehicle, 23),
            modBackWheels     = GetVehicleMod(vehicle, 24),

            modPlateHolder    = GetVehicleMod(vehicle, 25),
            modVanityPlate    = GetVehicleMod(vehicle, 26),
            modTrimA          = GetVehicleMod(vehicle, 27),
            modOrnaments      = GetVehicleMod(vehicle, 28),
            modDashboard      = GetVehicleMod(vehicle, 29),
            modDial           = GetVehicleMod(vehicle, 30),
            modDoorSpeaker    = GetVehicleMod(vehicle, 31),
            modSeats          = GetVehicleMod(vehicle, 32),
            modSteeringWheel  = GetVehicleMod(vehicle, 33),
            modShifterLeavers = GetVehicleMod(vehicle, 34),
            modAPlate         = GetVehicleMod(vehicle, 35),
            modSpeakers       = GetVehicleMod(vehicle, 36),
            modTrunk          = GetVehicleMod(vehicle, 37),
            modHydrolic       = GetVehicleMod(vehicle, 38),
            modEngineBlock    = GetVehicleMod(vehicle, 39),
            modAirFilter      = GetVehicleMod(vehicle, 40),
            modStruts         = GetVehicleMod(vehicle, 41),
            modArchCover      = GetVehicleMod(vehicle, 42),
            modAerials        = GetVehicleMod(vehicle, 43),
            modTrimB          = GetVehicleMod(vehicle, 44),
            modTank           = GetVehicleMod(vehicle, 45),
            modWindows        = GetVehicleMod(vehicle, 46),
            modLivery         = GetVehicleLivery(vehicle)
        }
    else
        return
    end
end

function DotMe(dots)
    if dots == "." then
        dots = ".."
    elseif dots == ".." then
        dots = "..."
    elseif dots == "..." then
        dots = "."
    end
    return dots
end

function aidsMaths(result)
    random = 0
    if result == 8 then
        random = math.random(00000000,99999999)
    elseif result == 7 then
        random = math.random(0000000,9999999)
    elseif result == 6 then
        random = math.random(000000,999999)
    elseif result == 5 then
        random = math.random(00000,99999)
    elseif result == 4 then
        random = math.random(0000,9999)
    elseif result == 3 then
        random = math.random(000,999)
    elseif result == 2 then
        random = math.random(00,99)
    elseif result == 1 then
        random = math.random(0,9)
    end
    return(random)
end

function round( n )
    return math.floor( n + 0.5 )
end

TimerTable = {
    {time = 20},
    {time = 40},
    {time = 60},
    {time = 80},
    {time = 100},
    {time = 120},
    {time = 140},
    {time = 160},
    {time = 180},
    {time = 200},
    {time = 220},
    {time = 240},
    {time = 260},
    {time = 280},
    {time = 300},
    {time = 320},
    {time = 340},
    {time = 360},
    {time = 380},
    {time = 400},
}

TimerTable2 = {
    {time = 10},
    {time = 20},
    {time = 40},
    {time = 30},
    {time = 40},
    {time = 50},
    {time = 60},
    {time = 70},
    {time = 80},
    {time = 90},
    {time = 100},
    {time = 110},
    {time = 120},
    {time = 130},
    {time = 140},
    {time = 150},
    {time = 160},
    {time = 170},
    {time = 180},
    {time = 190},
    {time = 200},
    {time = 210},
    {time = 220},
    {time = 230},
    {time = 240},
    {time = 250},
    {time = 260},
    {time = 270},
    {time = 280},
    {time = 290},
    {time = 300},
    {time = 310},
    {time = 320},
    {time = 330},
    {time = 340},
    {time = 350},
    {time = 360},
    {time = 370},
    {time = 380},
    {time = 390},
    {time = 400},
}