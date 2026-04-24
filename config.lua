Config = {}

Config.Framework = "esx"
Config.ESXExport = "es_extended"

Config.UsePermissions = true
Config.AdminGroups = {"admin", "superadmin"}
Config.AdminAces = {"group.admin"}

Config.MenuCommand = "ab"
Config.ToggleKey = nil

Config.DefaultSmooth = 0.5
Config.DefaultFOV = 30
Config.DefaultBone = 31086

Config.MinSmooth = 0.0
Config.MaxSmooth = 1.0
Config.MinFOV = 5
Config.MaxFOV = 180
Config.MaxDistance = 250.0

Config.CheckLineOfSight = true
Config.ShowFOVCircle = true
Config.IgnoreTeam = false
Config.IgnoreVehicles = false
Config.OnlyWhenAiming = true

Config.TickRate = 0
Config.IdleTickRate = 1000

Config.UseCustomNotify = true
Config.NotifyResource = "hex_2_hud"
Config.NotifyFunction = function(type, message)
    if Config.UseCustomNotify and GetResourceState(Config.NotifyResource) == "started" then
        exports[Config.NotifyResource]:Notify("Silencemode", message, type, 5000)
    else
        SetNotificationTextEntry("STRING")
        AddTextComponentString(message)
        DrawNotification(false, false)
    end
end

Config.MenuTitle = "Silencemode"
Config.MenuAlign = "top-left"

Config.BoneList = {
    ["Head"] = 31086,
    ["Neck"] = 39317,
    ["Spine"] = 24816,
    ["Pelvis"] = 11816,
    ["LeftFoot"] = 14201,
    ["RightFoot"] = 52301,
    ["LeftHand"] = 18905,
    ["RightHand"] = 57005,
}

Config.Messages = {
    ["no_permission"] = "Du hast keine Berechtigung für diesen Befehl!",
    ["aimbot_enabled"] = "Aimbot aktiviert",
    ["aimbot_disabled"] = "Aimbot deaktiviert",
    ["smoothness_set"] = "Smoothness auf %s gesetzt",
    ["smoothness_disabled"] = "Smoothness deaktiviert",
    ["fov_set"] = "FOV auf %s gesetzt",
    ["invalid_value"] = "Ungültiger Wert",
    ["value_too_low"] = "Wert zu niedrig (Minimum: %s)",
    ["value_too_high"] = "Wert zu hoch (Maximum: %s)",
}
