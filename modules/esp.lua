local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local ESP = {
    Drawings = {},
    Connections = {},
    Enabled = false
}

local Utils

-- ====================== DRAWING HELPERS ======================

local function CreateDrawing(class, props)
    local drawing = Drawing.new(class)
    for prop, value in pairs(props or {}) do
        drawing[prop] = value
    end
    return drawing
end

local function RemoveDrawings(player)
    local data = ESP.Drawings[player]
    if not data then return end

    for _, drawing in pairs(data) do
        if typeof(drawing) == "table" then
            for _, d in pairs(drawing) do
                pcall(function() d:Remove() end)
            end
        else
            pcall(function() drawing:Remove() end)
        end
    end

    ESP.Drawings[player] = nil
end

local function CreatePlayerDrawings(player)
    if ESP.Drawings[player] then return end

    ESP.Drawings[player] = {
        Box = CreateDrawing("Square", {
            Thickness = 1,
            Filled = false,
            Visible = false
        }),
        BoxOutline = CreateDrawing("Square", {
            Thickness = 3,
            Filled = false,
            Color = Color3.new(0, 0, 0),
            Visible = false
        }),
        Name = CreateDrawing("Text", {
            Size = 14,
            Center = true,
            Outline = true,
            Visible = false
        }),
        Distance = CreateDrawing("Text", {
            Size = 12,
            Center = true,
            Outline = true,
            Visible = false
        }),
        HealthBar = CreateDrawing("Square", {
            Thickness = 1,
            Filled = true,
            Visible = false
        }),
        HealthBarOutline = CreateDrawing("Square", {
            Thickness = 1,
            Filled = false,
            Color = Color3.new(0, 0, 0),
            Visible = false
        }),
        Tracer = CreateDrawing("Line", {
            Thickness = 1,
            Visible = false
        }),
        Weapon = CreateDrawing("Text", {
            Size = 12,
            Center = true,
            Outline = true,
            Visible = false
        }),
        -- Skeleton lines
        Skeleton = {
            HeadToTorso = CreateDrawing("Line", { Thickness = 1.5, Visible = false }),
            TorsoToLeftArm = CreateDrawing("Line", { Thickness = 1.5, Visible = false }),
            TorsoToRightArm = CreateDrawing("Line", { Thickness = 1.5, Visible = false }),
            TorsoToLeftLeg = CreateDrawing("Line", { Thickness = 1.5, Visible = false }),
            TorsoToRightLeg = CreateDrawing("Line", { Thickness = 1.5, Visible = false }),
            LeftArm = CreateDrawing("Line", { Thickness = 1.5, Visible = false }),
            RightArm = CreateDrawing("Line", { Thickness = 1.5, Visible = false }),
            LeftLeg = CreateDrawing("Line", { Thickness = 1.5, Visible = false }),
            RightLeg = CreateDrawing("Line", { Thickness = 1.5, Visible = false }),
        }
    }
end

-- ====================== MAIN UPDATE ======================

local function UpdateESP()
    if not ESP.Enabled then
        for player in pairs(ESP.Drawings) do
            RemoveDrawings(player)
        end
        return
    end

    local toggles = Toggles
    local options = Options
    if not toggles or not options then return end

    local maxDist = options.ESPMaxDistance and options.ESPMaxDistance.Value or 1000
    local enemyColor = options.ESPEnemyColor and options.ESPEnemyColor.Value or Color3.fromRGB(255, 50, 50)
    local teamColor = options.ESPTeamColor and options.ESPTeamColor.Value or Color3.fromRGB(50, 255, 50)
    local teamCheck = toggles.ESPTeamCheck and toggles.ESPTeamCheck.Value

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then
            RemoveDrawings(player)
            continue
        end

        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        local head = character and character:FindFirstChild("Head")

        if not character or not humanoid or not rootPart or humanoid.Health <= 0 then
            RemoveDrawings(player)
            continue
        end

        -- Team check
        if teamCheck and Utils and Utils.IsTeammate(player) then
            RemoveDrawings(player)
            continue
        end

        local distance = (rootPart.Position - (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position or Camera.CFrame.Position)).Magnitude
        if distance > maxDist then
            RemoveDrawings(player)
            continue
        end

        CreatePlayerDrawings(player)
        local drawings = ESP.Drawings[player]

        local pos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
        local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
        local legPos = Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0))

        local color = (Utils and Utils.IsTeammate(player)) and teamColor or enemyColor

        -- ========== BOX ==========
        if toggles.ESPBoxes and toggles.ESPBoxes.Value and onScreen then
            local height = math.abs(headPos.Y - legPos.Y)
            local width = height / 2

            drawings.BoxOutline.Size = Vector2.new(width, height)
            drawings.BoxOutline.Position = Vector2.new(pos.X - width / 2, headPos.Y)
            drawings.BoxOutline.Visible = true

            drawings.Box.Size = Vector2.new(width, height)
            drawings.Box.Position = Vector2.new(pos.X - width / 2, headPos.Y)
            drawings.Box.Color = color
            drawings.Box.Visible = true
        else
            drawings.Box.Visible = false
            drawings.BoxOutline.Visible = false
        end

        -- ========== NAME ==========
        if toggles.ESPNames and toggles.ESPNames.Value and onScreen then
            drawings.Name.Text = player.Name
            drawings.Name.Position = Vector2.new(pos.X, headPos.Y - 16)
            drawings.Name.Color = color
            drawings.Name.Visible = true
        else
            drawings.Name.Visible = false
        end

        -- ========== DISTANCE ==========
        if toggles.ESPDistance and toggles.ESPDistance.Value and onScreen then
            drawings.Distance.Text = math.floor(distance) .. "m"
            drawings.Distance.Position = Vector2.new(pos.X, legPos.Y + 2)
            drawings.Distance.Color = Color3.new(1, 1, 1)
            drawings.Distance.Visible = true
        else
            drawings.Distance.Visible = false
        end

        -- ========== HEALTH BAR ==========
        if toggles.ESPHealth and toggles.ESPHealth.Value and onScreen then
            local healthPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
            local height = math.abs(headPos.Y - legPos.Y)
            local barHeight = height * healthPercent
            local barWidth = 3

            drawings.HealthBarOutline.Size = Vector2.new(barWidth + 2, height + 2)
            drawings.HealthBarOutline.Position = Vector2.new(pos.X - (height / 2) - 8, headPos.Y - 1)
            drawings.HealthBarOutline.Visible = true

            drawings.HealthBar.Size = Vector2.new(barWidth, barHeight)
            drawings.HealthBar.Position = Vector2.new(pos.X - (height / 2) - 7, headPos.Y + (height - barHeight))
            drawings.HealthBar.Color = Color3.fromRGB(255 - (255 * healthPercent), 255 * healthPercent, 0)
            drawings.HealthBar.Visible = true
        else
            drawings.HealthBar.Visible = false
            drawings.HealthBarOutline.Visible = false
        end

        -- ========== TRACER ==========
        if toggles.ESPTracers and toggles.ESPTracers.Value and onScreen then
            drawings.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            drawings.Tracer.To = Vector2.new(pos.X, legPos.Y)
            drawings.Tracer.Color = color
            drawings.Tracer.Visible = true
        else
            drawings.Tracer.Visible = false
        end

        -- ========== WEAPON ==========
        if toggles.ESPWeapon and toggles.ESPWeapon.Value and onScreen then
            local tool = character:FindFirstChildOfClass("Tool")
            drawings.Weapon.Text = tool and tool.Name or ""
            drawings.Weapon.Position = Vector2.new(pos.X, legPos.Y + 16)
            drawings.Weapon.Color = Color3.new(1, 1, 0.5)
            drawings.Weapon.Visible = tool ~= nil
        else
            drawings.Weapon.Visible = false
        end

        -- ========== SKELETON ==========
        if toggles.ESPSkeleton and toggles.ESPSkeleton.Value and onScreen then
            local function getPoint(partName)
                local part = character:FindFirstChild(partName)
                if part then
                    local p, on = Camera:WorldToViewportPoint(part.Position)
                    if on then return Vector2.new(p.X, p.Y) end
                end
                return nil
            end

            local headP = getPoint("Head")
            local torsoP = getPoint("UpperTorso") or getPoint("Torso")
            local leftUpperArm = getPoint("LeftUpperArm")
            local rightUpperArm = getPoint("RightUpperArm")
            local leftLowerArm = getPoint("LeftLowerArm") or getPoint("Left Arm")
            local rightLowerArm = getPoint("RightLowerArm") or getPoint("Right Arm")
            local leftUpperLeg = getPoint("LeftUpperLeg")
            local rightUpperLeg = getPoint("RightUpperLeg")
            local leftLowerLeg = getPoint("LeftLowerLeg") or getPoint("Left Leg")
            local rightLowerLeg = getPoint("RightLowerLeg") or getPoint("Right Leg")

            local sk = drawings.Skeleton
            local function setLine(line, from, to)
                if from and to then
                    line.From = from
                    line.To = to
                    line.Color = color
                    line.Visible = true
                else
                    line.Visible = false
                end
            end

            setLine(sk.HeadToTorso, headP, torsoP)
            setLine(sk.TorsoToLeftArm, torsoP, leftUpperArm)
            setLine(sk.TorsoToRightArm, torsoP, rightUpperArm)
            setLine(sk.TorsoToLeftLeg, torsoP, leftUpperLeg)
            setLine(sk.TorsoToRightLeg, torsoP, rightUpperLeg)
            setLine(sk.LeftArm, leftUpperArm, leftLowerArm)
            setLine(sk.RightArm, rightUpperArm, rightLowerArm)
            setLine(sk.LeftLeg, leftUpperLeg, leftLowerLeg)
            setLine(sk.RightLeg, rightUpperLeg, rightLowerLeg)
        else
            for _, line in pairs(drawings.Skeleton) do
                line.Visible = false
            end
        end
    end
end

-- ====================== CHAMS (Highlight) ======================

local function UpdateChams()
    if not Toggles or not Toggles.ESPChams then return end

    local chamsEnabled = Toggles.ESPEnabled.Value and Toggles.ESPChams.Value
    local teamCheck = Toggles.ESPTeamCheck and Toggles.ESPTeamCheck.Value
    local enemyColor = Options.ESPEnemyColor and Options.ESPEnemyColor.Value or Color3.fromRGB(255, 50, 50)
    local teamColor = Options.ESPTeamColor and Options.ESPTeamColor.Value or Color3.fromRGB(50, 255, 50)

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end

        local character = player.Character
        if not character then continue end

        local highlight = character:FindFirstChild("VanadiuMChams")

        if chamsEnabled and Utils.IsAlive(player) then
            if teamCheck and Utils.IsTeammate(player) then
                if highlight then highlight:Destroy() end
                continue
            end

            if not highlight then
                highlight = Instance.new("Highlight")
                highlight.Name = "VanadiuMChams"
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlight.Parent = character
            end

            local color = Utils.IsTeammate(player) and teamColor or enemyColor
            highlight.FillColor = color
            highlight.OutlineColor = color
        else
            if highlight then
                highlight:Destroy()
            end
        end
    end
end

-- ====================== MODULE API ======================

function ESP.Init(shared)
    Utils = shared.Modules.utils
    ESP.Enabled = true

    -- Главный цикл
    table.insert(ESP.Connections, RunService.RenderStepped:Connect(function()
        if Toggles and Toggles.ESPEnabled then
            ESP.Enabled = Toggles.ESPEnabled.Value
        end
        UpdateESP()
        UpdateChams()
    end))

    -- Очистка при выходе игрока
    table.insert(ESP.Connections, Players.PlayerRemoving:Connect(function(player)
        RemoveDrawings(player)
    end))

    print("[ESP] Module initialized")
end

function ESP.Unload()
    ESP.Enabled = false

    for _, conn in ipairs(ESP.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    ESP.Connections = {}

    for player in pairs(ESP.Drawings) do
        RemoveDrawings(player)
    end

    -- Удаляем все Chams
    for _, player in ipairs(Players:GetPlayers()) do
        local character = player.Character
        if character then
            local highlight = character:FindFirstChild("VanadiuMChams")
            if highlight then highlight:Destroy() end
        end
    end

    print("[ESP] Module unloaded")
end

return ESP
