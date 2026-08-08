local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/SaveManager.lua"))()
local Window = Library:CreateWindow({
    Title = "VanadiuM | Counter blox free",
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})
-- Tabs
local Tabs = {
    Combat = Window:AddTab("Combat"),
    Visual = Window:AddTab("Visual"),
    Exploits = Window:AddTab("Exploits"),
    Settings = Window:AddTab("Settings"),
}
--// Combat
local AimbotGroup = Tabs.Combat:AddLeftGroupbox("Aimbot")
local SilentGroup = Tabs.Combat:AddRightGroupbox("Silent Aim")
local FOVGroup = Tabs.Combat:AddLeftGroupbox("FOV")
local TriggerGroup = Tabs.Combat:AddRightGroupbox("Trigger Bot")
local BulletGroup = Tabs.Combat:AddLeftGroupbox("Bullet Modification")
local GunGroup = Tabs.Combat:AddRightGroupbox("Gun Modification")
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
    Default = 0.1,
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
SilentGroup:AddToggle("SilentAutoShoot", { Text = "Auto Shoot", Default = false })
-- FOV (общая)
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
TriggerGroup:AddLabel("Keybind"):AddKeyPicker("TriggerKey", {
    Default = "None",
    Text = "Trigger Key",
    Mode = "Toggle"
})
-- Bullet Modification
BulletGroup:AddToggle("Wallshot", { Text = "Wallshot / Wallbang", Default = false })
BulletGroup:AddToggle("InstantBullet", { Text = "Instant Bullet", Default = false })
-- Gun Modification
GunGroup:AddToggle("NoRecoil", { Text = "No Recoil", Default = false })
GunGroup:AddToggle("NoSpread", { Text = "No Spread", Default = false })
GunGroup:AddToggle("RapidFire", { Text = "Rapid Fire", Default = false })
GunGroup:AddToggle("InfiniteAmmo", { Text = "Infinite Ammo", Default = false })
--// Visual
local PlayerESP = Tabs.Visual:AddLeftGroupbox("Player ESP")
local OtherESP = Tabs.Visual:AddRightGroupbox("Other ESP")
local World = Tabs.Visual:AddLeftGroupbox("World")
-- Player ESP
PlayerESP:AddToggle("ESPEnabled", { Text = "Enabled", Default = false })
PlayerESP:AddToggle("ESPBoxes", { Text = "Boxes", Default = true })
PlayerESP:AddToggle("ESPNames", { Text = "Names", Default = true })
PlayerESP:AddToggle("ESPHealth", { Text = "Health Bar", Default = true })
PlayerESP:AddToggle("ESPDistance", { Text = "Distance", Default = true })
PlayerESP:AddToggle("ESPTracers", { Text = "Tracers", Default = false })
PlayerESP:AddToggle("ESPChams", { Text = "Chams", Default = false })
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
-- Other ESP
OtherESP:AddToggle("BombESP", { Text = "Bomb ESP", Default = false })
OtherESP:AddToggle("DroppedWeapons", { Text = "Dropped Weapons", Default = false })
OtherESP:AddToggle("DroppedItems", { Text = "Dropped Items", Default = false })
OtherESP:AddToggle("GrenadeESP", { Text = "Grenades", Default = false })
-- World
World:AddToggle("Fullbright", { Text = "Fullbright", Default = false })
World:AddToggle("NoFog", { Text = "No Fog", Default = false })
World:AddToggle("NoShadows", { Text = "No Shadows", Default = false })
World:AddSlider("Brightness", {
    Text = "Brightness",
    Default = 1,
    Min = 0,
    Max = 5,
    Rounding = 1
})
--// Exploits
local ExploitsGroup = Tabs.Exploits:AddLeftGroupbox("Movement")
local MiscExploits = Tabs.Exploits:AddRightGroupbox("Misc")
ExploitsGroup:AddToggle("Fly", { Text = "Fly", Default = false })
ExploitsGroup:AddSlider("FlySpeed", {
    Text = "Fly Speed",
    Default = 50,
    Min = 10,
    Max = 200,
    Rounding = 0
})
ExploitsGroup:AddToggle("Speed", { Text = "Speed Hack", Default = false })
ExploitsGroup:AddSlider("WalkSpeed", {
    Text = "Walk Speed",
    Default = 16,
    Min = 16,
    Max = 100,
    Rounding = 0
})
ExploitsGroup:AddToggle("Noclip", { Text = "Noclip", Default = false })
ExploitsGroup:AddToggle("InfiniteJump", { Text = "Infinite Jump", Default = false })
MiscExploits:AddToggle("NoClipWeapons", { Text = "No Clip Weapons", Default = false })
MiscExploits:AddToggle("AutoBuy", { Text = "Auto Buy", Default = false })
MiscExploits:AddButton("Kill All", function()
    -- placeholder
end)
--// Settings
local MenuGroup = Tabs.Settings:AddLeftGroupbox("Menu")
local ConfigGroup = Tabs.Settings:AddRightGroupbox("Config")
MenuGroup:AddLabel("Menu Keybind"):AddKeyPicker("MenuKeybind", {
    Default = "RightControl",
    Text = "Menu Keybind",
    NoUI = false
})
MenuGroup:AddToggle("Keybinds", { Text = "Show Keybinds", Default = true })
MenuGroup:AddButton("Unload", function()
    Library:Unload()
end)
-- Theme & Save
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
    print("VanadiuM unloaded")
end)
