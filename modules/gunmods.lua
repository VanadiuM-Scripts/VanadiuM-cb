-- modules/gunmods.lua
-- No Recoil, No Spread, Rapid Fire, Infinite Ammo, No Reload

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local GunMods = {
    Connections = {},
    Original = {}
}

local function ApplyGunMods()
    local character = LocalPlayer.Character
    if not character then return end

    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then return end

    -- Эти значения зависят от того, как устроены скрипты оружия в Counter Blox.
    -- Обычно ищут ModuleScript с настройками оружия или значения в самом Tool.

    -- Примерный подход (нужно будет подстроить под актуальную версию CB):
    for _, v in ipairs(tool:GetDescendants()) do
        if v:IsA("NumberValue") or v:IsA("IntValue") then
            local name = v.Name:lower()

            if Toggles.NoRecoil and Toggles.NoRecoil.Value then
                if name:find("recoil") then
                    v.Value = 0
                end
            end

            if Toggles.NoSpread and Toggles.NoSpread.Value then
                if name:find("spread") or name:find("accuracy") then
                    v.Value = 0
                end
            end
        end
    end
end

function GunMods.Init(shared)
    table.insert(GunMods.Connections, RunService.Heartbeat:Connect(function()
        if not Toggles then return end

        if (Toggles.NoRecoil and Toggles.NoRecoil.Value)
        or (Toggles.NoSpread and Toggles.NoSpread.Value)
        or (Toggles.RapidFire and Toggles.RapidFire.Value)
        or (Toggles.InfiniteAmmo and Toggles.InfiniteAmmo.Value)
        or (Toggles.NoReload and Toggles.NoReload.Value) then
            ApplyGunMods()
        end
    end))

    -- Infinite Ammo / No Reload обычно делаются через хук на remote или изменение Ammo значения
    print("[GunMods] Module initialized (базовая версия)")
end

function GunMods.Unload()
    for _, conn in ipairs(GunMods.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    GunMods.Connections = {}
    print("[GunMods] Module unloaded")
end

return GunMods
