-- modules/misc.lua
-- KillSay, AutoAccept, AntiAFK, Watermark, HitSound и т.д.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

local Misc = {
    Connections = {},
    WatermarkDrawing = nil
}

local Utils

-- ====================== ANTI AFK ======================

local function SetupAntiAFK()
    table.insert(Misc.Connections, LocalPlayer.Idled:Connect(function()
        if Toggles.AntiAFK and Toggles.AntiAFK.Value then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end
    end))
end

-- ====================== KILL SAY ======================

local DefaultKillMessages = {
    "ez",
    "too easy",
    "get good",
    "VanadiuM on top"
}

local RussianKillMessages = {
    "лёгкая",
    "изи",
    "отдых",
    "VanadiuM топ"
}

local function SetupKillSay()
    -- Нужно хукнуть событие убийства. В Counter Blox обычно есть remote или значение.
    -- Пока заготовка через CharacterRemoving / Humanoid.Died других игроков (не идеально)

    table.insert(Misc.Connections, Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(character)
            local humanoid = character:WaitForChild("Humanoid", 5)
            if humanoid then
                humanoid.Died:Connect(function()
                    if not Toggles.KillSay or not Toggles.KillSay.Value then return end

                    -- Проверяем, что убил именно LocalPlayer (нужно доработать)
                    local mode = Options.KillSayMode and Options.KillSayMode.Value or "Default"
                    local message = "ez"

                    if mode == "Custom" and Options.KillSayText then
                        message = Options.KillSayText.Value
                    elseif mode == "Russian" then
                        message = RussianKillMessages[math.random(1, #RussianKillMessages)]
                    else
                        message = DefaultKillMessages[math.random(1, #DefaultKillMessages)]
                    end

                    -- Отправка сообщения
                    pcall(function()
                        local chat = game:GetService("TextChatService")
                        if chat and chat.ChatInputBarConfiguration.Enabled then
                            chat.TextChannels.RBXGeneral:SendAsync(message)
                        else
                            StarterGui:SetCore("ChatMakeSystemMessage", {
                                Text = message
                            })
                        end
                    end)
                end)
            end
        end)
    end))
end

-- ====================== WATERMARK ======================

local function UpdateWatermark()
    if not Toggles or not Toggles.Watermark then return end

    if not Misc.WatermarkDrawing then
        Misc.WatermarkDrawing = Drawing.new("Text")
        Misc.WatermarkDrawing.Size = 16
        Misc.WatermarkDrawing.Outline = true
        Misc.WatermarkDrawing.Center = false
        Misc.WatermarkDrawing.Position = Vector2.new(15, 10)
        Misc.WatermarkDrawing.Color = Color3.fromRGB(255, 255, 255)
    end

    if Toggles.Watermark.Value then
        local fps = 0
        local ping = 0

        if Toggles.ShowFPS and Toggles.ShowFPS.Value then
            fps = math.floor(1 / RunService.RenderStepped:Wait())
        end

        pcall(function()
            ping = math.floor(LocalPlayer:GetNetworkPing() * 1000)
        end)

        local text = "VanadiuM"
        if Toggles.ShowFPS and Toggles.ShowFPS.Value then
            text = text .. " | FPS: " .. fps
        end
        if Toggles.ShowPing and Toggles.ShowPing.Value then
            text = text .. " | Ping: " .. ping .. "ms"
        end

        Misc.WatermarkDrawing.Text = text
        Misc.WatermarkDrawing.Visible = true
    else
        Misc.WatermarkDrawing.Visible = false
    end
end

-- ====================== PUBLIC FUNCTIONS ======================

function Misc.KillAll()
    -- Placeholder. В реальном CB это обычно делается через remote или уязвимость.
    Library:Notify("Kill All пока не реализован")
end

function Misc.TeleportToBomb()
    -- Ищем бомбу в Workspace
    local bomb = Workspace:FindFirstChild("Bomb") or Workspace:FindFirstChild("C4") or Workspace:FindFirstChild("BombModel")
    if bomb then
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = bomb:GetPivot() + Vector3.new(0, 3, 0)
            Library:Notify("Телепортирован к бомбе")
        end
    else
        Library:Notify("Бомба не найдена")
    end
end

-- ====================== MODULE API ======================

function Misc.Init(shared)
    Utils = shared.Modules.utils

    SetupAntiAFK()
    SetupKillSay()

    table.insert(Misc.Connections, RunService.RenderStepped:Connect(function()
        UpdateWatermark()
    end))

    print("[Misc] Module initialized")
end

function Misc.Unload()
    for _, conn in ipairs(Misc.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    Misc.Connections = {}

    if Misc.WatermarkDrawing then
        Misc.WatermarkDrawing:Remove()
        Misc.WatermarkDrawing = nil
    end

    print("[Misc] Module unloaded")
end

return Misc
