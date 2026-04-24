
local ESX = nil
local QBCore = nil
local isAimbotEnabled = false
local aimbotSmooth = Config.DefaultSmooth
local aimbotFOV = Config.DefaultFOV
local aimbotBone = Config.DefaultBone

Citizen.CreateThread(function()
    if Config.Framework == "esx" then
        ESX = exports[Config.ESXExport]:getSharedObject()
    elseif Config.Framework == "qbcore" then
        QBCore = exports['qb-core']:GetCoreObject()
    end
end)

local function Notify(type, message)
    Config.NotifyFunction(type, message)
end

local function HasPermission()
    if not Config.UsePermissions then
        return true
    end

    if Config.Framework == "esx" and ESX then
        local xPlayer = ESX.GetPlayerData()
        if xPlayer and xPlayer.group then
            for _, group in ipairs(Config.AdminGroups) do
                if xPlayer.group == group then
                    return true
                end
            end
        end
    elseif Config.Framework == "qbcore" and QBCore then
        local PlayerData = QBCore.Functions.GetPlayerData()
        if PlayerData and PlayerData.job and PlayerData.job.name then
            for _, group in ipairs(Config.AdminGroups) do
                if PlayerData.job.name == group then
                    return true
                end
            end
        end
    else
        for _, ace in ipairs(Config.AdminAces) do
            if IsPlayerAceAllowed(PlayerId(), ace) then
                return true
            end
        end
    end

    return false
end

local function ValidateInput(value, min, max, valueName)
    local num = tonumber(value)
    
    if not num then
        Notify("error", Config.Messages["invalid_value"])
        return nil
    end
    
    if num < min then
        Notify("error", string.format(Config.Messages["value_too_low"], min))
        return nil
    end
    
    if num > max then
        Notify("error", string.format(Config.Messages["value_too_high"], max))
        return nil
    end
    
    return num
end

local function OpenAimbotMenu()
    if not HasPermission() then
        Notify("error", Config.Messages["no_permission"])
        return
    end

    if Config.Framework == "esx" and ESX and ESX.UI and ESX.UI.Menu then
        ESX.UI.Menu.Open("default", GetCurrentResourceName(), "aimbot_menu", {
            title = Config.MenuTitle,
            align = Config.MenuAlign,
            elements = {
                {label = "Aimbot", value = "aimbot"},
                {label = "Smoothness", value = "smoothness"},
                {label = "FOV", value = "fov"},
            },
        }, function(data, menu)
            if data.current.value == "aimbot" then
                isAimbotEnabled = not isAimbotEnabled
                Notify("info", isAimbotEnabled and Config.Messages["aimbot_enabled"] or Config.Messages["aimbot_disabled"])
            elseif data.current.value == "smoothness" then
                ESX.UI.Menu.Open("dialog", GetCurrentResourceName(), "smoothness", {
                    title = "Smoothness (0.0-1.0)",
                }, function(data2, menu2)
                    local smoothness = ValidateInput(data2.value, Config.MinSmooth, Config.MaxSmooth, "Smoothness")
                    if smoothness then
                        aimbotSmooth = smoothness
                        if aimbotSmooth == 0.0 then
                            Notify("info", Config.Messages["smoothness_disabled"])
                        else
                            Notify("info", string.format(Config.Messages["smoothness_set"], aimbotSmooth))
                        end
                    end
                    menu2.close()
                end, function(data2, menu2)
                    menu2.close()
                end)
            elseif data.current.value == "fov" then
                ESX.UI.Menu.Open("dialog", GetCurrentResourceName(), "fov", {
                    title = "FOV (5-180)",
                }, function(data2, menu2)
                    local fov = ValidateInput(data2.value, Config.MinFOV, Config.MaxFOV, "FOV")
                    if fov then
                        aimbotFOV = fov
                        Notify("info", string.format(Config.Messages["fov_set"], aimbotFOV))
                    end
                    menu2.close()
                end, function(data2, menu2)
                    menu2.close()
                end)
            end
        end, function(data, menu)
            menu.close()
        end)
    else
        Notify("info", "Aimbot: " .. (isAimbotEnabled and "AN" or "AUS") .. " | Smoothness: " .. aimbotSmooth .. " | FOV: " .. aimbotFOV)
        Notify("info", "Nutze: /aimbot toggle | /aimbot smooth [0.0-1.0] | /aimbot fov [5-180]")
    end
end

RegisterCommand(Config.MenuCommand, function()
    OpenAimbotMenu()
end, false)

RegisterCommand("aimbot", function(source, args)
    if not HasPermission() then
        Notify("error", Config.Messages["no_permission"])
        return
    end

    if args[1] == "toggle" then
        isAimbotEnabled = not isAimbotEnabled
        Notify("info", isAimbotEnabled and Config.Messages["aimbot_enabled"] or Config.Messages["aimbot_disabled"])
    elseif args[1] == "smooth" and args[2] then
        local smoothness = ValidateInput(args[2], Config.MinSmooth, Config.MaxSmooth, "Smoothness")
        if smoothness then
            aimbotSmooth = smoothness
            if aimbotSmooth == 0.0 then
                Notify("info", Config.Messages["smoothness_disabled"])
            else
                Notify("info", string.format(Config.Messages["smoothness_set"], aimbotSmooth))
            end
        end
    elseif args[1] == "fov" and args[2] then
        local fov = ValidateInput(args[2], Config.MinFOV, Config.MaxFOV, "FOV")
        if fov then
            aimbotFOV = fov
            Notify("info", string.format(Config.Messages["fov_set"], aimbotFOV))
        end
    else
        Notify("info", "Befehle: /aimbot toggle | /aimbot smooth [0.0-1.0] | /aimbot fov [5-180]")
    end
end, false)

if Config.ToggleKey then
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            if IsControlJustPressed(0, Config.ToggleKey) and HasPermission() then
                isAimbotEnabled = not isAimbotEnabled
                Notify("info", isAimbotEnabled and Config.Messages["aimbot_enabled"] or Config.Messages["aimbot_disabled"])
            end
        end
    end)
end

Citizen.CreateThread(function()
    while true do
        local waitTime = Config.IdleTickRate

        if isAimbotEnabled then 
            waitTime = Config.TickRate
            local playerPed = PlayerPedId()
            local playerId = PlayerId()
            local isAiming = Config.OnlyWhenAiming and IsPlayerFreeAiming(playerId) or true
    
            if isAiming then
                for _, targetPlayerId in ipairs(GetActivePlayers()) do
                    local targetPed = GetPlayerPed(targetPlayerId)
                    
                    if playerPed ~= targetPed and not IsPlayerDead(targetPed) then
                        if Config.IgnoreVehicles and IsPedInAnyVehicle(targetPed, false) then
                            goto continue
                        end

                        if IsTargetValid(targetPed) then
                            AimAtBone(targetPed, aimbotBone)
                            break
                        end
                    end
                    
                    ::continue::
                end
            end
        end

        Citizen.Wait(waitTime)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        if Config.ShowFOVCircle and isAimbotEnabled then
            DrawFOVCircle()
        end
    end
end)

function IsTargetValid(targetPed)
    if not IsTargetInFOV(targetPed) then
        return false
    end

    if Config.MaxDistance > 0 then
        local playerPos = GetEntityCoords(PlayerPedId())
        local targetPos = GetEntityCoords(targetPed)
        local distance = #(playerPos - targetPos)
        
        if distance > Config.MaxDistance then
            return false
        end
    end

    if Config.CheckLineOfSight then
        local playerPed = PlayerPedId()
        if not HasEntityClearLosToEntity(playerPed, targetPed, 17) then
            return false
        end
    end

    return true
end

function IsTargetInFOV(targetPed)
    local targetPos = GetEntityCoords(targetPed)
    local camPos = GetFinalRenderedCamCoord()
    local camRot = GetFinalRenderedCamRot(2)
    local direction = targetPos - camPos
    local distance = #direction
    
    if distance == 0 then
        return false
    end
    
    direction = direction / distance

    local forward = RotationToDirection(camRot)
    local dot = forward.x * direction.x + forward.y * direction.y + forward.z * direction.z
    
    if dot > 1.0 then dot = 1.0 end
    if dot < -1.0 then dot = -1.0 end
    
    local angle = math.deg(math.acos(dot))

    return angle <= aimbotFOV / 2
end

function RotationToDirection(rotation)
    local adjustedRotation = vector3(
        math.rad(rotation.x),
        math.rad(rotation.y),
        math.rad(rotation.z)
    )

    local direction = vector3(
        -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        math.sin(adjustedRotation.x)
    )

    return direction
end

function DrawFOVCircle()
    local screenX, screenY = GetActiveScreenResolution()
    local fovRadius = (aimbotFOV / GetGameplayCamFov()) * (screenX / 2)
    
    DrawMarker(28, 0.5, 0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, fovRadius, fovRadius, 0.1, 255, 0, 0, 100, false, true, 2, false, nil, nil, false)
end

function AimAtBone(targetPed, bone)
    local function lerp(a, b, t)
        return a + (b - a) * t
    end

    local bonePos = GetPedBoneCoords(targetPed, bone)
    local camPos = GetFinalRenderedCamCoord()
    local playerRot = GetEntityRotation(PlayerPedId(), 2)
    local deltaPos = bonePos - camPos
    local angleX, angleY, angleZ = deltaPos.x, deltaPos.y, deltaPos.z
    local targetRoll = -math.deg(math.atan2(angleX, angleY)) - playerRot.z
    local targetPitch = math.deg(math.atan2(angleZ, #vector2(angleX, angleY)))
    local yaw = 1.0

    if IsPedInAnyVehicle(targetPed, false) then
        targetRoll = targetRoll + GetEntityRoll(targetPed)
    end

    if aimbotSmooth > 0.0 then
        local currentRoll = GetGameplayCamRelativeHeading()
        local currentPitch = GetGameplayCamRelativePitch()
        local smoothedRoll = lerp(currentRoll, targetRoll, aimbotSmooth)
        local smoothedPitch = lerp(currentPitch, targetPitch, aimbotSmooth)

        if targetPed ~= PlayerPedId() and IsEntityOnScreen(targetPed) and IsAimCamActive() then
            SetGameplayCamRelativeRotation(smoothedRoll, smoothedPitch, yaw)
        end
    else
        if targetPed ~= PlayerPedId() and IsEntityOnScreen(targetPed) and IsAimCamActive() then
            SetGameplayCamRelativeRotation(targetRoll, targetPitch, yaw)
        end
    end
end
