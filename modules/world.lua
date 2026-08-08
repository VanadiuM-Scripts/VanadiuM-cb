-- modules/world.lua
-- Fullbright, No Fog, No Shadows, Brightness, Ambient

local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

local World = {
    Connections = {},
    Original = {
        Brightness = Lighting.Brightness,
        FogEnd = Lighting.FogEnd,
        FogStart = Lighting.FogStart,
        GlobalShadows = Lighting.GlobalShadows,
        Ambient = Lighting.Ambient,
        OutdoorAmbient = Lighting.OutdoorAmbient,
        ClockTime = Lighting.ClockTime
    }
}

local function ApplyWorld()
    if not Toggles then return end

    -- Fullbright
    if Toggles.Fullbright and Toggles.Fullbright.Value then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(200, 200, 200)
    else
        -- No Fog
        if Toggles.NoFog and Toggles.NoFog.Value then
            Lighting.FogEnd = 100000
            Lighting.FogStart = 0
        else
            Lighting.FogEnd = World.Original.FogEnd
            Lighting.FogStart = World.Original.FogStart
        end

        -- No Shadows
        if Toggles.NoShadows and Toggles.NoShadows.Value then
            Lighting.GlobalShadows = false
        else
            Lighting.GlobalShadows = World.Original.GlobalShadows
        end

        -- Brightness
        if Options.Brightness then
            Lighting.Brightness = Options.Brightness.Value
        end

        -- Ambient
        if Toggles.Ambient and Toggles.Ambient.Value and Options.AmbientColor then
            Lighting.Ambient = Options.AmbientColor.Value
            Lighting.OutdoorAmbient = Options.AmbientColor.Value
        else
            Lighting.Ambient = World.Original.Ambient
            Lighting.OutdoorAmbient = World.Original.OutdoorAmbient
        end
    end
end

function World.Init(shared)
    table.insert(World.Connections, RunService.Heartbeat:Connect(function()
        ApplyWorld()
    end))

    print("[World] Module initialized")
end

function World.Unload()
    -- Восстанавливаем оригинальные значения
    Lighting.Brightness = World.Original.Brightness
    Lighting.FogEnd = World.Original.FogEnd
    Lighting.FogStart = World.Original.FogStart
    Lighting.GlobalShadows = World.Original.GlobalShadows
    Lighting.Ambient = World.Original.Ambient
    Lighting.OutdoorAmbient = World.Original.OutdoorAmbient
    Lighting.ClockTime = World.Original.ClockTime

    for _, conn in ipairs(World.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    World.Connections = {}

    print("[World] Module unloaded")
end

return World
