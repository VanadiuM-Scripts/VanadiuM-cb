-- modules/triggerbot.lua

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")

local TriggerBot = {
    Connections = {},
    LastShot = 0
}

local Utils

local function IsMouseOverEnemy()
    if not Toggles or not Options then return false end

    local teamCheck = Toggles.TriggerTeamCheck and Toggles.TriggerTeamCheck.Value
    local visibleCheck = Toggles.TriggerVisibleCheck and Toggles.TriggerVisibleCheck.Value

    local mousePos = UserInputService:GetMouseLocation()
    local ray = Camera:ViewportPointToRay(mousePos.X, mousePos.Y)

    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
    rayParams.IgnoreWater = true

    local result = Workspace:Raycast(ray.Origin, ray.Direction * 1000, rayParams)
    if not result then return false end

    local hitPart = result.Instance
    local character = hitPart:FindFirstAncestorOfClass("Model")
    if not character then return false end

    local player = Players:GetPlayerFromCharacter(character)
    if not player or player == LocalPlayer then return false end
    if not Utils.IsAlive(player) then return false end
    if teamCheck and Utils.IsTeammate(player) then return false end

    if visibleCheck then
        if not Utils.IsVisible(Camera.CFrame.Position, hitPart.Position, {character}) then
            return false
        end
    end

    return true
end

function TriggerBot.Init(shared)
    Utils = shared.Modules.utils

    table.insert(TriggerBot.Connections, RunService.RenderStepped:Connect(function()
        if not Toggles or not Toggles.TriggerEnabled then return end
        if not Toggles.TriggerEnabled.Value then return end

        local keybind = Options.TriggerKey
        if keybind and keybind.Value ~= "None" and not keybind:GetState() then
            return
        end

        local delay = Options.TriggerDelay and Options.TriggerDelay.Value or 0.05
        local now = tick()

        if now - TriggerBot.LastShot < delay then return end

        if IsMouseOverEnemy() then
            -- Симуляция клика
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            task.wait(0.01)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            TriggerBot.LastShot = now
        end
    end))

    print("[TriggerBot] Module initialized")
end

function TriggerBot.Unload()
    for _, conn in ipairs(TriggerBot.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    TriggerBot.Connections = {}
    print("[TriggerBot] Module unloaded")
end

return TriggerBot
