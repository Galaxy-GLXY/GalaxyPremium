-- Target Safe Zone Coordinates (X, Z giữ nguyên, Y nâng lên = 93.00)
local TARGET_Y = 93.00
local FINAL_SAFE_ZONE = Vector3.new(549.39, TARGET_Y, -365.50)

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- UI Construction
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "StealButtonGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local StealButton = Instance.new("TextButton")
StealButton.Name = "StealButton"
StealButton.Size = UDim2.new(0, 160, 0, 50)
StealButton.Position = UDim2.new(0.85, 0, 0.75, 0)
StealButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
StealButton.Text = "STEAL"
StealButton.TextColor3 = Color3.fromRGB(0, 191, 255)
StealButton.TextSize = 22
StealButton.Font = Enum.Font.GothamBold
StealButton.Active = true
StealButton.Draggable = true
StealButton.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 15)
UICorner.Parent = StealButton

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(0, 191, 255)
UIStroke.Thickness = 3
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke.Parent = StealButton

-- Hover Animations
StealButton.MouseEnter:Connect(function()
    TweenService:Create(UIStroke, TweenInfo.new(0.2), {Thickness = 5, Color = Color3.fromRGB(0, 255, 255)}):Play()
    TweenService:Create(StealButton, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(0, 255, 255)}):Play()
end)

StealButton.MouseLeave:Connect(function()
    TweenService:Create(UIStroke, TweenInfo.new(0.2), {Thickness = 3, Color = Color3.fromRGB(0, 191, 255)}):Play()
    TweenService:Create(StealButton, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(0, 191, 255)}):Play()
end)

-- Variables
local isStealing = false
local groundPart = nil
local activeBV = nil
local activeBG = nil

local function isHoldingEgg(character)
    return character:FindFirstChildOfClass("Tool") ~= nil
end

-- Hàm dừng/bật hoạt ảnh (Animation)
local function setAnimationsEnabled(character, enabled)
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    local animator = humanoid:FindFirstChildOfClass("Animator")
    if animator then
        for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
            if enabled then
                track:AdjustSpeed(1)
            else
                track:Stop(0)
            end
        end
    end

    if not enabled then
        humanoid.WalkSpeed = 0
    else
        humanoid.WalkSpeed = 16
    end
end

local function unblockHumanoid(humanoid)
    if not humanoid then return end
    
    if humanoid.PlatformStand then humanoid.PlatformStand = false end
    if humanoid.Sit then humanoid.Sit = false end

    pcall(function()
        humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    end)
end

-- Dọn dẹp object và khôi phục trạng thái ban đầu
local function stopStealing()
    isStealing = false
    
    if groundPart then
        groundPart:Destroy()
        groundPart = nil
    end
    if activeBV then
        activeBV:Destroy()
        activeBV = nil
    end
    if activeBG then
        activeBG:Destroy()
        activeBG = nil
    end

    StealButton.Text = "STEAL"
    StealButton.TextColor3 = Color3.fromRGB(0, 191, 255)
    UIStroke.Color = Color3.fromRGB(0, 191, 255)

    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            unblockHumanoid(humanoid)
            humanoid:ChangeState(Enum.HumanoidStateType.Running)
        end
        setAnimationsEnabled(character, true)
    end
end

-- Vòng lặp duy trì trạng thái nhân vật
task.spawn(function()
    while true do
        task.wait(0.05)
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 and not isStealing then
                if isHoldingEgg(character) then
                    humanoid.WalkSpeed = 16
                end
                
                unblockHumanoid(humanoid)
                
                if humanoid:GetState() ~= Enum.HumanoidStateType.Running and not humanoid.Sit then
                    pcall(function()
                        humanoid:ChangeState(Enum.HumanoidStateType.Running)
                    end)
                end
            end
        end
    end
end)

local function triggerGroundVelocitySteal()
    if isStealing then
        stopStealing()
        return
    end

    local character = LocalPlayer.Character
    if not character then return end

    local hrp = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    
    if not hrp or not humanoid or humanoid.Health <= 0 then return end

    isStealing = true

    -- 1. Tắt động tác chạy
    setAnimationsEnabled(character, false)

    StealButton.Text = "STOP"
    StealButton.TextColor3 = Color3.fromRGB(255, 69, 0)
    UIStroke.Color = Color3.fromRGB(255, 69, 0)

    -- 2. TELEPORT LÊN ĐỘ CAO Y = 93.00 NGAY TẠI TỌA ĐỘ HIỆN TẠI
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.CFrame = CFrame.new(hrp.Position.X, TARGET_Y, hrp.Position.Z)

    -- 3. TẠO SÀN ĐỠ TÀNG HÌNH DƯỚI CHÂN ĐỂ TRÁNH ANTI-CHEAT RESET
    groundPart = Instance.new("Part")
    groundPart.Name = "AntiCheatSafetyPlatform"
    groundPart.Size = Vector3.new(8, 1, 8)
    groundPart.Anchored = true
    groundPart.CanCollide = true
    groundPart.Transparency = 1
    groundPart.CFrame = CFrame.new(hrp.Position.X, TARGET_Y - 3.5, hrp.Position.Z)
    groundPart.Parent = workspace

    activeBV = Instance.new("BodyVelocity")
    activeBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    activeBV.Velocity = Vector3.zero
    activeBV.Parent = hrp

    activeBG = Instance.new("BodyGyro")
    activeBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    activeBG.P = 90000
    activeBG.CFrame = CFrame.lookAt(hrp.Position, FINAL_SAFE_ZONE)
    activeBG.Parent = hrp

    local moveSpeed = 280
    local startTime = tick()
    local distance = (FINAL_SAFE_ZONE - hrp.Position).Magnitude
    local estimatedTime = (distance / moveSpeed) + 0.4

    -- 4. BAY LƯỚT NGANG BẰNG ĐỘ CAO Y = 93.00 VỀ SAFE ZONE
    while isStealing and character and hrp and humanoid.Health > 0 do
        setAnimationsEnabled(character, false)
        
        local currentFlatPos = Vector3.new(hrp.Position.X, TARGET_Y, hrp.Position.Z)
        
        if groundPart then
            groundPart.CFrame = CFrame.new(currentFlatPos.X, TARGET_Y - 3.5, currentFlatPos.Z)
        end

        local currentDist = (FINAL_SAFE_ZONE - currentFlatPos).Magnitude
        if currentDist <= 5 or (tick() - startTime) > estimatedTime then
            break
        end

        local currentDir = (FINAL_SAFE_ZONE - currentFlatPos).Unit
        activeBV.Velocity = Vector3.new(currentDir.X * moveSpeed, 0, currentDir.Z * moveSpeed)

        task.wait(0.015)
    end

    if activeBV then activeBV:Destroy(); activeBV = nil end
    if activeBG then activeBG:Destroy(); activeBG = nil end

    -- 5. GIỮ VỊ TRÍ TẠI SAFE ZONE TRONG 1.5S ĐỂ HOÀN TẤT CƯỚP
    local finalCFrame = CFrame.new(FINAL_SAFE_ZONE)
    local tpEndTime = tick() + 1.5

    while isStealing and tick() < tpEndTime do
        local char = LocalPlayer.Character
        if char then
            local root = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if root and hum and hum.Health > 0 then
                setAnimationsEnabled(char, false)
                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
                root.CFrame = finalCFrame

                if groundPart then
                    groundPart.CFrame = finalCFrame - Vector3.new(0, 3.5, 0)
                end
            end
        end
        RunService.Heartbeat:Wait()
    end

    -- Khôi phục trạng thái di chuyển bình thường
    stopStealing()
end

StealButton.MouseButton1Click:Connect(triggerGroundVelocitySteal)
