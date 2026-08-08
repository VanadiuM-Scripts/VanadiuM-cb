-- modules/silent.lua
-- Silent Aim

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Silent = {
    Connections = {},
    Target = nil
}

local Utils

local function GetSilentTarget()
    if not Toggles or not Options then return nil end
    if not Toggles.SilentEnabled.Value then return nil end

    local bestTarget = nil
    local bestFov = Options.SilentFOV and Options.SilentFOV.Value or 80
    local hitPartSetting = Options.SilentHitPart and Options.SilentHitPart.Value or "Head"
    local teamCheck = Toggles.SilentTeamCheck and Toggles.SilentTeamCheck.Value
    local visibleCheck = Toggles.SilentVisibleCheck and Toggles.SilentVisibleCheck.Value
    local wallCheck = Toggles.SilentWallCheck and Toggles.SilentWallCheck.Value
    local chance = Options.SilentChance and Options.SilentChance.Value or 100

    if math.random(1, 100) > chance then return nil end

    local center = Camera.ViewportSize / 2
    local closestDist = bestFov

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not Utils.IsAlive(player) then continue end
        if teamCheck and Utils.IsTeammate(player) then continue end

        local character = player.Character
        local part = Utils.GetHitPart(character, hitPartSetting)
        if not part then continue end

        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
        if not onScreen then continue end

        local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
        if dist > closestDist then continue end

        if visibleCheck or wallCheck then
            local origin = Camera.CFrame.Position
            if not Utils.IsVisible(origin, part.Position, {character}) then
                continue
            end
        end

        closestDist = dist
        bestTarget = part
    end

    return bestTarget
end

function Silent.Init(shared)
    Utils = shared.Modules.utils

    -- Hook для Silent Aim (базовый вариант через __namecall / __index)
    -- Для Counter Blox обычно хукают FireBullet / GetMousePosition и т.д.
    -- Здесь базовая заготовка, которую нужно подстроить под актуальный код игры.

    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)

    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}

        if Toggles and Toggles.SilentEnabled and Toggles.SilentEnabled.Value then
            local target = GetSilentTarget()
            Silent.Target = target

            -- Пример: если игра использует что-то вроде :FireServer("Shoot", position)
            -- Нужно будет подстроить под актуальный remote Counter Blox
            if target and (method == "FireServer" or method == "InvokeServer") then
                -- Здесь можно модифицировать аргументы
                -- args[?] = target.Position
            end
        end

        return oldNamecall(self, unpack(args))
    end)

    setreadonly(mt, true)

    table.insert(Silent.Connections, RunService.RenderStepped:Connect(function()
        if Toggles and Toggles.SilentEnabled and Toggles.SilentEnabled.Value then
            Silent.Target = GetSilentTarget()
        else
            Silent.Target = nil
        end
    end))

    print("[Silent] Module initialized (базовая версия, нужно донастроить под CB)")
end

function Silent.Unload()
    for _, conn in ipairs(Silent.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    Silent.Connections = {}
    Silent.Target = nil
    print("[Silent] Module unloaded")
end

return Silent
