-- modules/utils.lua
-- Общие полезные функции

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Utils = {}

-- Получить всех игроков кроме себя
function Utils.GetPlayers(includeLocal)
    local list = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if includeLocal or player ~= LocalPlayer then
            table.insert(list, player)
        end
    end
    return list
end

-- Получить Character игрока
function Utils.GetCharacter(player)
    return player and player.Character
end

-- Получить Humanoid
function Utils.GetHumanoid(player)
    local char = Utils.GetCharacter(player)
    return char and char:FindFirstChildOfClass("Humanoid")
end

-- Получить RootPart
function Utils.GetRootPart(player)
    local char = Utils.GetCharacter(player)
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- Жив ли игрок
function Utils.IsAlive(player)
    local humanoid = Utils.GetHumanoid(player)
    return humanoid and humanoid.Health > 0
end

-- Проверка на тиммейта
function Utils.IsTeammate(player)
    if not player or not LocalPlayer then return false end
    return player.Team == LocalPlayer.Team
end

-- Получить позицию части
function Utils.GetPartPosition(part)
    return part and part.Position
end

-- Visible Check (простая версия)
function Utils.IsVisible(origin, targetPos, ignoreList)
    ignoreList = ignoreList or {}
    table.insert(ignoreList, LocalPlayer.Character)

    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = ignoreList
    rayParams.IgnoreWater = true

    local direction = (targetPos - origin)
    local result = Workspace:Raycast(origin, direction, rayParams)

    if result then
        -- Если попали во что-то до цели — не видимо
        local distanceToHit = (result.Position - origin).Magnitude
        local distanceToTarget = direction.Magnitude
        return distanceToHit >= distanceToTarget - 1.5
    end

    return true
end

-- Получить ближайшую часть тела
function Utils.GetClosestPart(character, partsList)
    partsList = partsList or {"Head", "UpperTorso", "LowerTorso", "HumanoidRootPart"}
    local closest = nil
    local closestDist = math.huge
    local mousePos = Camera.ViewportSize / 2

    for _, partName in ipairs(partsList) do
        local part = character:FindFirstChild(partName)
        if part then
            local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
            if onScreen then
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closest = part
                end
            end
        end
    end

    return closest
end

-- Получить Hit Part по настройке
function Utils.GetHitPart(character, hitPartSetting)
    if not character then return nil end

    if hitPartSetting == "Head" then
        return character:FindFirstChild("Head")
    elseif hitPartSetting == "Torso" then
        return character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso") or character:FindFirstChild("HumanoidRootPart")
    elseif hitPartSetting == "Closest" then
        return Utils.GetClosestPart(character)
    end

    return character:FindFirstChild("Head")
end

-- Расстояние между двумя игроками
function Utils.GetDistance(player1, player2)
    local root1 = Utils.GetRootPart(player1)
    local root2 = Utils.GetRootPart(player2)
    if root1 and root2 then
        return (root1.Position - root2.Position).Magnitude
    end
    return math.huge
end

-- FOV Check
function Utils.IsInFOV(position, fovSize)
    local screenPos, onScreen = Camera:WorldToViewportPoint(position)
    if not onScreen then return false end

    local center = Camera.ViewportSize / 2
    local distance = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
    return distance <= fovSize
end

-- Простое предсказание позиции
function Utils.PredictPosition(part, prediction)
    if not part then return nil end
    local velocity = part.AssemblyLinearVelocity or Vector3.zero
    return part.Position + (velocity * prediction)
end

-- Безопасный вызов
function Utils.SafeCall(fn, ...)
    local success, result = pcall(fn, ...)
    if not success then
        warn("[Utils] Error:", result)
    end
    return success, result
end

return Utils
