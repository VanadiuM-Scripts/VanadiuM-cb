local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/SaveManager.lua"))()

local Window = Library:CreateWindow({
    Title = "VanadiuM | Counter Blox",
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

-- ====================== TABS ======================
local Tabs = {
    Combat   = Window:AddTab("Combat"),
    Visual   = Window:AddTab("Visual"),
    Exploits = Window:AddTab("Exploits"),
    Misc     = Window:AddTab("Misc"),
    Settings = Window:AddTab("Settings"),
}

-- ====================== LOAD MODULES ======================
local Modules = {}
local baseUrl = "https://raw.githubusercontent.com/VanadiuM-Scripts/VanadiuM-cb/main/modules/"

local function LoadModule(name)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(baseUrl .. name .. ".lua"))()
    end)

    if success and result then
        Modules[name] = result
        print("[VanadiuM] Loaded:", name)
        return true
    else
        warn("[VanadiuM] Failed to load module:", name, result)
        return false
    end
end

-- Загружаем модули (bypass самым первым)
LoadModule("bypass")
LoadModule("utils")
LoadModule("esp")
LoadModule("aimbot")
LoadModule("silent")
LoadModule("triggerbot")
LoadModule("gunmods")
LoadModule("movement")
LoadModule("world")
LoadModule("misc")

-- ====================== UI ======================

-- Combat
local AimbotGroup   = Tabs.Combat:AddLeftGroupbox("Aimbot")
local SilentGroup   = Tabs.Combat:AddRightGroupbox("Silent Aim")
local FOVGroup      = Tabs.Combat:AddLeftGroupbox("FOV")
local TriggerGroup  = Tabs.Combat:AddRightGroupbox("Trigger Bot")
local BulletGroup   = Tabs.Combat:AddLeftGroupbox("Bullet Modification")
local GunGroup      = Tabs.Combat:AddRightGroupbox("Gun Modification")

-- Visual
local PlayerESP     = Tabs.Visual:AddLeftGroupbox("Player ESP")
local OtherESP      = Tabs.Visual:AddRightGroupbox("Other ESP")
local WorldGroup    = Tabs.Visual:AddLeftGroupbox("World")
local ExtraVisual   = Tabs.Visual:AddRightGroupbox("Extra")

-- Exploits
local MovementGroup = Tabs.Exploits:AddLeftGroupbox("Movement")
local MiscExploits  = Tabs.Exploits:AddRightGroupbox("Misc")

-- Misc
local MiscGroup     = Tabs.Misc:AddLeftGroupbox("General")
local ChatGroup     = Tabs.Misc:AddRightGroupbox("Chat / Killsay")

-- Settings
local MenuGroup     = Tabs.Settings:AddLeftGroupbox("Menu")

-- ====================== COMBAT UI ======================

-- Aimbot
AimbotGroup:AddToggle("AimbotEnabled", { Text = "Enabled", Default = false })
AimbotGroup:AddToggle("AimbotTeamCheck", { Text = "Team Check", Default = true })
AimbotGroup:AddToggle("AimbotVisibleCheck", { Text = "Visible Check", Default = true })
AimbotGroup:AddToggle("AimbotWallCheck", { Text = "Wall Check", Default = false })
AimbotGroup:AddDropdown("AimbotHitPart", {
    Values = {"Head", "Torso", "Closest"},
    Default = 1,
    Multi = false,
    Text = "Hit Part"
})
AimbotGroup:AddSlider("AimbotSmoothness", {
    Text = "Smoothness",
    Default = 5,
    Min = 1,
    Max = 20,
    Rounding = 0
})
AimbotGroup:AddSlider("AimbotPrediction", {
    Text = "Prediction",
    Default = 0.12,
    Min = 0,
    Max = 1,
    Rounding = 2
})
AimbotGroup:AddLabel("Keybind"):AddKeyPicker("AimbotKey", {
    Default = "MB2",
    Text = "Aimbot Key",
    Mode = "Hold"
})

-- Silent Aim
SilentGroup:AddToggle("SilentEnabled", { Text = "Enabled", Default = false })
SilentGroup:AddToggle("SilentTeamCheck", { Text = "Team Check", Default = true })
SilentGroup:AddToggle("SilentVisibleCheck", { Text = "Visible Check", Default = true })
SilentGroup:AddToggle("SilentWallCheck", { Text = "Wall Check", Default = false })
SilentGroup:AddDropdown("SilentHitPart", {
    Values = {"Head", "Torso", "Closest"},
    Default = 1,
    Multi = false,
    Text = "Hit Part"
})
SilentGroup:AddSlider("SilentChance", {
    Text = "Hit Chance",
    Default = 100,
    Min = 1,
    Max = 100,
    Rounding = 0,
    Suffix = "%"
})
SilentGroup:AddSlider("SilentFOV", {
    Text = "Silent FOV",
    Default = 80,
    Min = 10,
    Max = 400,
    Rounding = 0
})
SilentGroup:AddToggle("SilentAutoShoot", { Text = "Auto Shoot", Default = false })
SilentGroup:AddToggle("SilentResolver", { Text = "Resolver", Default = false })

-- FOV
FOVGroup:AddToggle("ShowFOV", { Text = "Show FOV Circle", Default = true })
FOVGroup:AddSlider("FOVSize", {
    Text = "FOV Size",
    Default = 120,
    Min = 20,
    Max = 500,
    Rounding = 0
})
FOVGroup:AddLabel("FOV Color"):AddColorPicker("FOVColor", {
    Default = Color3.fromRGB(255, 255, 255),
    Title = "FOV Color"
})
FOVGroup:AddToggle("FOVFilled", { Text = "Filled", Default = false })
FOVGroup:AddSlider("FOVTransparency", {
    Text = "Transparency",
    Default = 0.5,
    Min = 0,
    Max = 1,
    Rounding = 2
})
FOVGroup:AddToggle("ShowSilentFOV", { Text = "Show Silent FOV", Default = false })

-- Trigger Bot
TriggerGroup:AddToggle("TriggerEnabled", { Text = "Enabled", Default = false })
TriggerGroup:AddSlider("TriggerDelay", {
    Text = "Delay",
    Default = 0.05,
    Min = 0,
    Max = 0.5,
    Rounding = 2,
    Suffix = "s"
})
TriggerGroup:AddToggle("TriggerTeamCheck", { Text = "Team Check", Default = true })
TriggerGroup:AddToggle("TriggerVisibleCheck", { Text = "Visible Check", Default = true })
TriggerGroup:AddLabel("Keybind"):AddKeyPicker("TriggerKey", {
    Default = "None",
    Text = "Trigger Key",
    Mode = "Toggle"
})

-- Bullet Modification
BulletGroup:AddToggle("Wallshot", { Text = "Wallshot / Wallbang", Default = false })
BulletGroup:AddToggle("InstantBullet", { Text = "Instant Bullet", Default = false })
BulletGroup:AddToggle("NoBulletDrop", { Text = "No Bullet Drop", Default = false })

-- Gun Modification
GunGroup:AddToggle("NoRecoil", { Text = "No Recoil", Default = false })
GunGroup:AddToggle("NoSpread", { Text = "No Spread", Default = false })
GunGroup:AddToggle("RapidFire", { Text = "Rapid Fire", Default = false })
GunGroup:AddToggle("InfiniteAmmo", { Text = "Infinite Ammo", Default = false })
GunGroup:AddToggle("NoReload", { Text = "No Reload", Default = false })

-- ====================== VISUAL UI ======================

PlayerESP:AddToggle("ESPEnabled", { Text = "Enabled", Default = false })
PlayerESP:AddToggle("ESPBoxes", { Text = "Boxes", Default = true })
PlayerESP:AddToggle("ESPNames", { Text = "Names", Default = true })
PlayerESP:AddToggle("ESPHealth", { Text = "Health Bar", Default = true })
PlayerESP:AddToggle("ESPDistance", { Text = "Distance", Default = true })
PlayerESP:AddToggle("ESPTracers", { Text = "Tracers", Default = false })
PlayerESP:AddToggle("ESPSkeleton", { Text = "Skeleton", Default = false })
PlayerESP:AddToggle("ESPChams", { Text = "Chams", Default = false })
PlayerESP:AddToggle("ESPWeapon", { Text = "Weapon", Default = false })
PlayerESP:AddToggle("ESPTeamCheck", { Text = "Team Check", Default = true })
PlayerESP:AddSlider("ESPMaxDistance", {
    Text = "Max Distance",
    Default = 1000,
    Min = 100,
    Max = 3000,
    Rounding = 0
})
PlayerESP:AddLabel("Enemy Color"):AddColorPicker("ESPEnemyColor", {
    Default = Color3.fromRGB(255, 50, 50),
    Title = "Enemy Color"
})
PlayerESP:AddLabel("Team Color"):AddColorPicker("ESPTeamColor", {
    Default = Color3.fromRGB(50, 255, 50),
    Title = "Team Color"
})

OtherESP:AddToggle("BombESP", { Text = "Bomb ESP", Default = false })
OtherESP:AddToggle("BombTimer", { Text = "Bomb Timer", Default = true })
OtherESP:AddToggle("DroppedWeapons", { Text = "Dropped Weapons", Default = false })
OtherESP:AddToggle("DroppedItems", { Text = "Dropped Items", Default = false })
OtherESP:AddToggle("GrenadeESP", { Text = "Grenades", Default = false })
OtherESP:AddToggle("GrenadeTrajectory", { Text = "Grenade Trajectory", Default = false })

WorldGroup:AddToggle("Fullbright", { Text = "Fullbright", Default = false })
WorldGroup:AddToggle("NoFog", { Text = "No Fog", Default = false })
WorldGroup:AddToggle("NoShadows", { Text = "No Shadows", Default = false })
WorldGroup:AddSlider("Brightness", {
    Text = "Brightness",
    Default = 1,
    Min = 0,
    Max = 5,
    Rounding = 1
})
WorldGroup:AddToggle("Ambient", { Text = "Custom Ambient", Default = false })
WorldGroup:AddLabel("Ambient Color"):AddColorPicker("AmbientColor", {
    Default = Color3.fromRGB(255, 255, 255),
    Title = "Ambient Color"
})

ExtraVisual:AddToggle("OutOfFOVArrows", { Text = "OOF Arrows", Default = false })
ExtraVisual:AddToggle("HitMarker", { Text = "Hit Marker", Default = false })
ExtraVisual:AddToggle("HitSound", { Text = "Hit Sound", Default = false })
ExtraVisual:AddToggle("ThirdPerson", { Text = "Third Person", Default = false })
ExtraVisual:AddSlider("ThirdPersonDistance", {
    Text = "TP Distance",
    Default = 8,
    Min = 3,
    Max = 20,
    Rounding = 0
})

-- ====================== EXPLOITS UI ======================

MovementGroup:AddToggle("Fly", { Text = "Fly", Default = false })
MovementGroup:AddSlider("FlySpeed", {
    Text = "Fly Speed",
    Default = 50,
    Min = 10,
    Max = 200,
    Rounding = 0
})
MovementGroup:AddToggle("Speed", { Text = "Speed Hack", Default = false })
MovementGroup:AddSlider("WalkSpeed", {
    Text = "Walk Speed",
    Default = 16,
    Min = 16,
    Max = 100,
    Rounding = 0
})
MovementGroup:AddToggle("Noclip", { Text = "Noclip", Default = false })
MovementGroup:AddToggle("InfiniteJump", { Text = "Infinite Jump", Default = false })
MovementGroup:AddToggle("BunnyHop", { Text = "Bunny Hop", Default = false })
MovementGroup:AddToggle("EdgeJump", { Text = "Edge Jump", Default = false })

MiscExploits:AddToggle("NoClipWeapons", { Text = "No Clip Weapons", Default = false })
MiscExploits:AddToggle("AutoBuy", { Text = "Auto Buy", Default = false })
MiscExploits:AddToggle("ForceBuy", { Text = "Force Buy", Default = false })
MiscExploits:AddButton("Kill All", function()
    if Modules.misc and Modules.misc.KillAll then
        Modules.misc.KillAll()
    end
end)
MiscExploits:AddButton("Teleport to Bomb", function()
    if Modules.misc and Modules.misc.TeleportToBomb then
        Modules.misc.TeleportToBomb()
    end
end)

-- ====================== MISC UI ======================

MiscGroup:AddToggle("AutoAccept", { Text = "Auto Accept", Default = false })
MiscGroup:AddToggle("AntiAFK", { Text = "Anti AFK", Default = true })
MiscGroup:AddToggle("SpectateList", { Text = "Spectator List", Default = false })
MiscGroup:AddButton("Rejoin", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
end)
MiscGroup:AddButton("Copy Game ID", function()
    setclipboard(tostring(game.JobId))
    Library:Notify("JobId скопирован")
end)

ChatGroup:AddToggle("KillSay", { Text = "Kill Say", Default = false })
ChatGroup:AddDropdown("KillSayMode", {
    Values = {"Default", "Custom", "Russian"},
    Default = 1,
    Multi = false,
    Text = "Mode"
})
ChatGroup:AddInput("KillSayText", {
    Default = "ez",
    Numeric = false,
    Finished = false,
    Text = "Custom Text",
    Placeholder = "Текст после килла"
})

-- ====================== SETTINGS UI ======================

MenuGroup:AddLabel("Menu Keybind"):AddKeyPicker("MenuKeybind", {
    Default = "RightControl",
    Text = "Menu Keybind",
    NoUI = false
})
MenuGroup:AddToggle("Keybinds", { Text = "Show Keybinds", Default = true })
MenuGroup:AddToggle("Watermark", { Text = "Watermark", Default = true })
MenuGroup:AddToggle("ShowFPS", { Text = "Show FPS", Default = true })
MenuGroup:AddToggle("ShowPing", { Text = "Show Ping", Default = true })
MenuGroup:AddButton("Unload", function()
    Library:Unload()
end)
MenuGroup:AddLabel("Panic Key"):AddKeyPicker("PanicKey", {
    Default = "End",
    Text = "Panic Key",
    Mode = "Toggle"
})

-- ====================== INIT MODULES ======================

local function InitModules()
    local shared = {
        Library = Library,
        Toggles = Toggles,
        Options = Options,
        Tabs = Tabs,
        Modules = Modules
    }

    for name, module in pairs(Modules) do
        if type(module) == "table" and module.Init then
            local success, err = pcall(function()
                module.Init(shared)
            end)
            if not success then
                warn("[VanadiuM] Error init module", name, err)
            end
        end
    end
end

-- Ждём пока Linoria создаст Toggles и Options
task.spawn(function()
    repeat task.wait() until Toggles and Options
    InitModules()
end)

-- ====================== THEME & SAVE ======================
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
ThemeManager:SetFolder("VanadiuM")
SaveManager:SetFolder("VanadiuM/CounterBlox")
SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:ApplyToTab(Tabs.Settings)

Library.KeybindFrame.Visible = true

Library:OnUnload(function()
    for name, module in pairs(Modules) do
        if type(module) == "table" and module.Unload then
            pcall(module.Unload)
        end
    end
    print("VanadiuM unloaded")
end)
