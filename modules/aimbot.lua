local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Aimbot = {
    Connections = {},
    Active = false
}

local Utils

local function GetTarget()
    if not Toggles or not Options then return nil end
    if not Toggles.AimbotEnabled.Value then return nil end

    local bestTarget = nil
    local bestFov = Options.FOVSize and Options.FOVSize.Value or 120
    local hitPartSetting = Options.AimbotHitPart and Options.AimbotHitPart.Value or "Head"
    local teamCheck = Toggles.AimbotTeamCheck and Toggles.AimbotTeamCheck.Value
    local visibleCheck = Toggles.AimbotVisibleCheck and Toggles.AimbotVisibleCheck.Value
    local wallCheck = Toggles.AimbotWallCheck and Toggles.AimbotWallCheck.Value
    local prediction = Options.AimbotPrediction and Options.AimbotPrediction.Value or 0

    local mousePos = UserInputService:GetMouseLocation()
    local closestDist = bestFov

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not Utils.IsAlive(player) then continue end
        if teamCheck and Utils.IsTeammate(player) then continue end

        local character = player.Character
        local part = Utils.GetHitPart(character, hitPartSetting)
        if not part then continue end

        local position = part.Position
        if prediction > 0 then
            position = Utils.PredictPosition(part, prediction)
        end

        local screenPos, onScreen = Camera:WorldToViewportPoint(position)
        if not onScreen then continue end

        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
        if dist > closestDist then continue end

        if visibleCheck or wallCheck then
            local origin = Camera.CFrame.Position
            if not Utils.IsVisible(origin, position, {character}) then
                continue
            end
        end

        closestDist = dist
        bestTarget = part
    end

    return bestTarget
end

local function AimAt(part)
    if not part then return end

    local smoothness = Options.AimbotSmoothness and Options.AimbotSmoothness.Value or 5
    local prediction = Options.AimbotPrediction and Options.AimbotPrediction.Value or 0

    local position = part.Position
    if prediction > 0 then
        position = Utils.PredictPosition(part, prediction)
    end

    local screenPos = Camera:WorldToViewportPoint(position)
    local mousePos = UserInputService:GetMouseLocation()

    local delta = Vector2.new(screenPos.X, screenPos.Y) - mousePos
    delta = delta / math.max(smoothness, 1)

    mousemoverel(delta.X, delta.Y)
end

function Aimbot.Init(shared)
    Utils = shared.Modules.utils

    table.insert(Aimbot.Connections, RunService.RenderStepped:Connect(function()
        if not Toggles or not Toggles.AimbotEnabled then return end
        if not Toggles.AimbotEnabled.Value then return end

        local keybind = Options.AimbotKey
        if keybind and not keybind:GetState() then return end

        local target = GetTarget()
        if target then
            AimAt(target)
        end
    end))

    print("[Aimbot] Module initialized")
end

function Aimbot.Unload()
    for _, conn in ipairs(Aimbot.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    Aimbot.Connections = {}
    print("[Aimbot] Module unloaded")
end

return Aimbot
