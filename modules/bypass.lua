-- modules/bypass.lua
-- Точечный обход найденных клиентских проверок из Client

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ScriptContext = game:GetService("ScriptContext")

local LocalPlayer = Players.LocalPlayer

local Bypass = {
    Connections = {},
    Original = {}
}

-- ====================== 1. БЛОКИРУЕМ ОТПРАВКУ ОШИБОК НА СЕРВЕР ======================
-- Events.HaIIoooooooooooo:FireServer(error, traceback)

local function HookErrorReporting()
    local success, err = pcall(function()
        -- Глушим ScriptContext.Error
        for _, conn in ipairs(getconnections(ScriptContext.Error)) do
            if conn.Function then
                conn:Disable()
            end
        end
    end)

    -- Дополнительно хукаем FireServer на этот remote, если он есть
    task.spawn(function()
        local events = ReplicatedStorage:FindFirstChild("Events")
        if not events then return end

        local targetRemote = events:FindFirstChild("HaIIoooooooooooo")
        if not targetRemote then return end

        local mt = getrawmetatable(game)
        local oldNamecall = mt.__namecall
        setreadonly(mt, false)

        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if self == targetRemote and (method == "FireServer" or method == "fireServer") then
                return -- просто ничего не отправляем
            end
            return oldNamecall(self, ...)
        end)

        setreadonly(mt, true)
    end)
end

-- ====================== 2. НОУКЛИП КИК (StrafingNoPhysics) ======================
-- player:Kick("\nNoclipping.")

local function HookNoclipKick()
    local oldKick
    oldKick = hookfunction(LocalPlayer.Kick, newcclosure(function(self, ...)
        local msg = tostring((...))
        if msg:find("Noclip") or msg:find("Noclipping") then
            return -- блокируем кик
        end
        return oldKick(self, ...)
    end))
end

-- Альтернатива / дополнение: не даём Humanoid застревать в StrafingNoPhysics
local function ProtectHumanoidState()
    local function onCharacter(char)
        local humanoid = char:WaitForChild("Humanoid", 5)
        if not humanoid then return end

        table.insert(Bypass.Connections, humanoid.StateChanged:Connect(function(_, newState)
            if newState == Enum.HumanoidStateType.StrafingNoPhysics then
                humanoid:ChangeState(Enum.HumanoidStateType.Running)
            end
        end))
    end

    if LocalPlayer.Character then
        onCharacter(LocalPlayer.Character)
    end

    table.insert(Bypass.Connections, LocalPlayer.CharacterAdded:Connect(onCharacter))
end

-- ====================== 3. КИК ЗА АММО ЧЕРЕЗ ParticleRemote ======================
-- ReplicatedStorage.Events.ParticleRemote:FireServer({ "kick", "error 2" })

local function HookParticleRemote()
    task.spawn(function()
        local events = ReplicatedStorage:WaitForChild("Events", 10)
        if not events then return end

        local particleRemote = events:FindFirstChild("ParticleRemote")
        if not particleRemote then return end

        local mt = getrawmetatable(game)
        local oldNamecall = mt.__namecall
        setreadonly(mt, false)

        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            local args = {...}

            if self == particleRemote and (method == "FireServer" or method == "fireServer") then
                if typeof(args[1]) == "table" and args[1][1] == "kick" then
                    return -- блокируем кик-пакет
                end
            end

            return oldNamecall(self, ...)
        end)

        setreadonly(mt, true)
    end)
end

-- ====================== INIT ======================

function Bypass.Init(shared)
    -- Важно: запускать как можно раньше
    HookErrorReporting()
    HookNoclipKick()
    ProtectHumanoidState()
    HookParticleRemote()

    print("[Bypass] Client checks hooked")
end

function Bypass.Unload()
    for _, conn in ipairs(Bypass.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    Bypass.Connections = {}
    print("[Bypass] Unloaded")
end

return Bypass
