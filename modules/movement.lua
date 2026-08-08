-- modules/movement.lua
-- Fly, Speed, Noclip, Infinite Jump, BunnyHop, EdgeJump

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local Movement = {
    Connections = {},
    Flying = false,
    BodyVelocity = nil,
    BodyGyro = nil
}

local function GetHumanoid()
    local char = LocalPlayer.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function GetRoot()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- ====================== FLY ======================

local function StartFly()
    local root = GetRoot()
    local humanoid = GetHumanoid()
    if not root or not humanoid then return end

    Movement.Flying = true
    humanoid.PlatformStand = true

    Movement.BodyVelocity = Instance.new("BodyVelocity")
    Movement.BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    Movement.BodyVelocity.Velocity = Vector3.zero
    Movement.BodyVelocity.Parent = root

    Movement.BodyGyro = Instance.new("BodyGyro")
    Movement.BodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    Movement.BodyGyro.P = 3000
    Movement.BodyGyro.Parent = root
end

local function StopFly()
    Movement.Flying = false
    local humanoid = GetHumanoid()
    if humanoid then
        humanoid.PlatformStand = false
    end

    if Movement.BodyVelocity then
        Movement.BodyVelocity:Destroy()
        Movement.BodyVelocity = nil
    end
    if Movement.BodyGyro then
        Movement.BodyGyro:Destroy()
        Movement.BodyGyro = nil
    end
end

local function UpdateFly()
    if not Movement.Flying then return end

    local root = GetRoot()
    local camera = Workspace.CurrentCamera
    if not root or not camera or not Movement.BodyVelocity then return end

    local speed = Options.FlySpeed and Options.FlySpeed.Value or 50
    local direction = Vector3.zero

    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
        direction += camera.CFrame.LookVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
        direction -= camera.CFrame.LookVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
        direction -= camera.CFrame.RightVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
        direction += camera.CFrame.RightVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        direction += Vector3.new(0, 1, 0)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        direction -= Vector3.new(0, 1, 0)
    end

    if direction.Magnitude > 0 then
        direction = direction.Unit * speed
    end

    Movement.BodyVelocity.Velocity = direction
    Movement.BodyGyro.CFrame = camera.CFrame
end

-- ====================== SPEED ======================

local function UpdateSpeed()
    local humanoid = GetHumanoid()
    if not humanoid then return end

    if Toggles.Speed and Toggles.Speed.Value then
        humanoid.WalkSpeed = Options.WalkSpeed and Options.WalkSpeed.Value or 16
    else
        if humanoid.WalkSpeed ~= 16 then
            humanoid.WalkSpeed = 16
        end
    end
end

-- ====================== NOCLIP ======================

local NoclipConnection
local function UpdateNoclip()
    if not Toggles.Noclip or not Toggles.Noclip.Value then return end

    local character = LocalPlayer.Character
    if not character then return end

    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end

-- ====================== INFINITE JUMP ======================

local function SetupInfiniteJump()
    table.insert(Movement.Connections, UserInputService.JumpRequest:Connect(function()
        if Toggles.InfiniteJump and Toggles.InfiniteJump.Value then
            local humanoid = GetHumanoid()
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end))
end

-- ====================== BUNNY HOP ======================

local function UpdateBunnyHop()
    if not Toggles.BunnyHop or not Toggles.BunnyHop.Value then return end

    local humanoid = GetHumanoid()
    if humanoid and humanoid.FloorMaterial ~= Enum.Material.Air then
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end

-- ====================== EDGE JUMP ======================

local function UpdateEdgeJump()
    if not Toggles.EdgeJump or not Toggles.EdgeJump.Value then return end

    local humanoid = GetHumanoid()
    local root = GetRoot()
    if not humanoid or not root then return end

    if humanoid.FloorMaterial ~= Enum.Material.Air then
        local ray = Workspace:Raycast(root.Position, Vector3.new(0, -3.5, 0))
        if not ray then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end

-- ====================== MODULE API ======================

function Movement.Init(shared)
    SetupInfiniteJump()

    table.insert(Movement.Connections, RunService.Heartbeat:Connect(function()
        if not Toggles then return end

        -- Fly
        if Toggles.Fly and Toggles.Fly.Value then
            if not Movement.Flying then
                StartFly()
            end
            UpdateFly()
        else
            if Movement.Flying then
                StopFly()
            end
        end

        UpdateSpeed()
        UpdateNoclip()
        UpdateBunnyHop()
        UpdateEdgeJump()
    end))

    -- При респавне
    table.insert(Movement.Connections, LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.5)
        if Movement.Flying then
            StopFly()
            if Toggles.Fly and Toggles.Fly.Value then
                StartFly()
            end
        end
    end))

    print("[Movement] Module initialized")
end

function Movement.Unload()
    StopFly()

    for _, conn in ipairs(Movement.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    Movement.Connections = {}

    local humanoid = GetHumanoid()
    if humanoid then
        humanoid.WalkSpeed = 16
        humanoid.PlatformStand = false
    end

    print("[Movement] Module unloaded")
end

return Movement
