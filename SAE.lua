local TARGET_Y = 93.00
local FINAL_SAFE_ZONE = Vector3.new(549.39, TARGET_Y, -365.50)
local SAFE_ESCAPE_POS = Vector3.new(547.54, TARGET_Y, -364.99)

-- Tọa độ giới hạn 4 góc của Safe Zone (xử lý ngầm)
local SAFE_MIN_X = 365.20
local SAFE_MAX_X = 552.00
local SAFE_MIN_Z = -582.00
local SAFE_MAX_Z = -146.00

local ZONES = {
    {Name = "Lake", Position = Vector3.new(743.59, TARGET_Y, -396.95)},
    {Name = "Desert", Position = Vector3.new(949.93, TARGET_Y, -333.33)},
    {Name = "Jungle", Position = Vector3.new(1190.65, TARGET_Y, -397.29)},
    {Name = "Snow", Position = Vector3.new(1490.13, TARGET_Y, -326.33)},
    {Name = "Volcano", Position = Vector3.new(1883.90, TARGET_Y, -383.63)},
    {Name = "Abyss Ocean", Position = Vector3.new(2280.29, TARGET_Y, -335.18)},
    {Name = "Prehistoric", Position = Vector3.new(2816.63, TARGET_Y, -388.11)},
    {Name = "Cosmic", Position = Vector3.new(3391.44, TARGET_Y, -335.10)},
    {Name = "Cherry Blossom", Position = Vector3.new(4029.82, TARGET_Y, -388.07)},
    {Name = "Titan Temple", Position = Vector3.new(4797.82, TARGET_Y, -339.47)},
    {Name = "Angels/Demons", Position = Vector3.new(5658.86, TARGET_Y, -340.98)},
}

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local function modifyPrompt(prompt)
    if prompt:IsA("ProximityPrompt") then
        prompt.HoldDuration = 0
    end
end

for _, obj in ipairs(Workspace:GetDescendants()) do
    modifyPrompt(obj)
end
Workspace.DescendantAdded:Connect(modifyPrompt)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UnifiedScriptGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- ==================== NÚT STEAL ====================
local StealButton = Instance.new("TextButton")
StealButton.Name = "StealButton"
StealButton.Size = UDim2.new(0, 160, 0, 50)
StealButton.Position = UDim2.new(0.82, 0, 0.05, 0)
StealButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
StealButton.Text = "STEAL"
StealButton.TextColor3 = Color3.fromRGB(0, 191, 255)
StealButton.TextSize = 22
StealButton.Font = Enum.Font.GothamBold
StealButton.Active = true
StealButton.Draggable = true
StealButton.Parent = ScreenGui

local StealCorner = Instance.new("UICorner")
StealCorner.CornerRadius = UDim.new(0, 15)
StealCorner.Parent = StealButton

local StealStroke = Instance.new("UIStroke")
StealStroke.Color = Color3.fromRGB(0, 191, 255)
StealStroke.Thickness = 3
StealStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
StealStroke.Parent = StealButton

StealButton.MouseEnter:Connect(function()
    TweenService:Create(StealStroke, TweenInfo.new(0.2), {Thickness = 5, Color = Color3.fromRGB(0, 255, 255)}):Play()
    TweenService:Create(StealButton, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(0, 255, 255)}):Play()
end)

StealButton.MouseLeave:Connect(function()
    TweenService:Create(StealStroke, TweenInfo.new(0.2), {Thickness = 3, Color = Color3.fromRGB(0, 191, 255)}):Play()
    TweenService:Create(StealButton, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(0, 191, 255)}):Play()
end)

-- ==================== NÚT MỞ/ĐÓNG MENU TELEPORT ====================
local ToggleMenuButton = Instance.new("TextButton")
ToggleMenuButton.Name = "ToggleMenuButton"
ToggleMenuButton.Size = UDim2.new(0, 160, 0, 40)
ToggleMenuButton.Position = UDim2.new(0.82, 0, 0.18, 0)
ToggleMenuButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ToggleMenuButton.Text = "TELEPORT UI"
ToggleMenuButton.TextColor3 = Color3.fromRGB(0, 191, 255)
ToggleMenuButton.TextSize = 16
ToggleMenuButton.Font = Enum.Font.GothamBold
ToggleMenuButton.Active = true
ToggleMenuButton.Draggable = true
ToggleMenuButton.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 10)
ToggleCorner.Parent = ToggleMenuButton

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color = Color3.fromRGB(0, 191, 255)
ToggleStroke.Thickness = 2
ToggleStroke.Parent = ToggleMenuButton

-- ==================== BẢNG MENU TELEPORT ZONES ====================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 200, 0, 390)
MainFrame.Position = UDim2.new(0.82, 0, 0.28, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(0, 191, 255)
MainStroke.Thickness = 2
MainStroke.Parent = MainFrame

local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 12)
TopBarCorner.Parent = TopBar

local TopBarFix = Instance.new("Frame")
TopBarFix.Size = UDim2.new(1, 0, 0, 10)
TopBarFix.Position = UDim2.new(0, 0, 1, -10)
TopBarFix.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
TopBarFix.BorderSizePixel = 0
TopBarFix.Parent = TopBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -45, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "By GALAXY"
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.TextColor3 = Color3.fromRGB(0, 191, 255)
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Parent = TopBar

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Position = UDim2.new(1, -35, 0.5, -15)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MinimizeButton.Text = "-"
MinimizeButton.TextColor3 = Color3.fromRGB(0, 191, 255)
MinimizeButton.TextSize = 18
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.Parent = TopBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinimizeButton

local ContentScroll = Instance.new("ScrollingFrame")
ContentScroll.Name = "ContentScroll"
ContentScroll.Size = UDim2.new(1, 0, 1, -40)
ContentScroll.Position = UDim2.new(0, 0, 0, 40)
ContentScroll.BackgroundTransparency = 1
ContentScroll.BorderSizePixel = 0
ContentScroll.ClipsDescendants = true
ContentScroll.ScrollBarThickness = 6
ContentScroll.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.Parent = ContentScroll

local UIPadding = Instance.new("UIPadding")
UIPadding.PaddingTop = UDim.new(0, 10)
UIPadding.PaddingBottom = UDim.new(0, 10)
UIPadding.Parent = ContentScroll

-- Sự kiện ẩn hiện menu Teleport
ToggleMenuButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Kéo thả menu qua TopBar
local dragging, dragInput, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

RunService.RenderStepped:Connect(function()
    if dragging and dragInput then
        local delta = dragInput.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local isMinimized = false
MinimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MinimizeButton.Text = "+"
        TweenService:Create(MainFrame, TweenInfo.new(0.2), {Size = UDim2.new(0, 200, 0, 40)}):Play()
    else
        MinimizeButton.Text = "-"
        TweenService:Create(MainFrame, TweenInfo.new(0.2), {Size = UDim2.new(0, 200, 0, 390)}):Play()
    end
end)

local isTraveling = false
local groundPart = nil
local activeBV = nil
local activeBG = nil

local function isHoldingEgg(character)
    return character:FindFirstChildOfClass("Tool") ~= nil
end

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
    humanoid.WalkSpeed = enabled and 16 or 0
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

local function stopTravel()
    isTraveling = false
    if groundPart then groundPart:Destroy(); groundPart = nil end
    if activeBV then activeBV:Destroy(); activeBV = nil end
    if activeBG then activeBG:Destroy(); activeBG = nil end

    StealButton.Text = "STEAL"
    StealButton.TextColor3 = Color3.fromRGB(0, 191, 255)
    StealStroke.Color = Color3.fromRGB(0, 191, 255)

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

-- Vòng lặp bảo vệ trạng thái nhân vật
task.spawn(function()
    while true do
        task.wait(0.05)
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 and not isTraveling then
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

-- Hàm bay chuẩn hệ thống
local function executeFlight(destinationPos)
    local character = LocalPlayer.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return end

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
    activeBG.CFrame = CFrame.lookAt(hrp.Position, destinationPos)
    activeBG.Parent = hrp

    local moveSpeed = 285 -- Đã sửa lỗi cú pháp khai báo biến ở đây
    local startTime = tick()
    local targetFlat = Vector3.new(destinationPos.X, TARGET_Y, destinationPos.Z)
    local distance = (targetFlat - hrp.Position).Magnitude
    local estimatedTime = (distance / moveSpeed) + 0.4

    while isTraveling and character and hrp and humanoid.Health > 0 do
        setAnimationsEnabled(character, false)
        
        local currentFlatPos = Vector3.new(hrp.Position.X, TARGET_Y, hrp.Position.Z)
        
        if groundPart then
            groundPart.CFrame = CFrame.new(currentFlatPos.X, TARGET_Y - 3.5, currentFlatPos.Z)
        end

        local currentDist = (targetFlat - currentFlatPos).Magnitude
        if currentDist <= 5 or (tick() - startTime) > estimatedTime then
            break
        end

        local currentDir = (targetFlat - currentFlatPos).Unit
        activeBV.Velocity = Vector3.new(currentDir.X * moveSpeed, 0, currentDir.Z * moveSpeed)

        task.wait(0.015)
    end

    if activeBV then activeBV:Destroy(); activeBV = nil end
    if activeBG then activeBG:Destroy(); activeBG = nil end
    if groundPart then groundPart:Destroy(); groundPart = nil end
end

-- Hàm thực hiện hành trình chung cho cả nút Steal và Teleport Zones
local function moveToTarget(targetPosition, isStealAction)
    if isTraveling then
        stopTravel()
    end

    local character = LocalPlayer.Character
    if not character then return end

    local hrp = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    
    if not hrp or not humanoid or humanoid.Health <= 0 then return end

    isTraveling = true
    setAnimationsEnabled(character, false)

    if isStealAction then
        StealButton.Text = "STOP"
        StealButton.TextColor3 = Color3.fromRGB(255, 69, 0)
        StealStroke.Color = Color3.fromRGB(255, 69, 0)
    end

    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.CFrame = CFrame.new(hrp.Position.X, TARGET_Y, hrp.Position.Z)

    local currentPos = hrp.Position
    local isInSafeZone = (currentPos.X >= SAFE_MIN_X and currentPos.X <= SAFE_MAX_X) and 
                         (currentPos.Z >= SAFE_MIN_Z and currentPos.Z <= SAFE_MAX_Z)

    if isInSafeZone then
        executeFlight(SAFE_ESCAPE_POS)
    end

    if isTraveling then
        executeFlight(targetPosition)
    end

    groundPart = Instance.new("Part")
    groundPart.Name = "AntiCheatSafetyPlatform"
    groundPart.Size = Vector3.new(8, 1, 8)
    groundPart.Anchored = true
    groundPart.CanCollide = true
    groundPart.Transparency = 1
    groundPart.CFrame = CFrame.new(targetPosition.X, TARGET_Y - 3.5, targetPosition.Z)
    groundPart.Parent = workspace

    local finalCFrame = CFrame.new(targetPosition)
    local tpEndTime = tick() + 1.0

    while isTraveling and tick() < tpEndTime and character and hrp and humanoid.Health > 0 do
        setAnimationsEnabled(character, false)
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        hrp.CFrame = finalCFrame

        if groundPart then
            groundPart.CFrame = finalCFrame - Vector3.new(0, 3.5, 0)
        end
        RunService.Heartbeat:Wait()
    end

    stopTravel()
end

-- Nút Steal sự kiện
StealButton.MouseButton1Click:Connect(function()
    if isTraveling then
        stopTravel()
    else
        moveToTarget(FINAL_SAFE_ZONE, true)
    end
end)

-- Tạo các nút Teleport Zones trong menu
for _, zone in ipairs(ZONES) do
    local ZoneButton = Instance.new("TextButton")
    ZoneButton.Name = zone.Name .. "Button"
    ZoneButton.Size = UDim2.new(0, 180, 0, 35)
    ZoneButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    ZoneButton.Text = zone.Name
    ZoneButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ZoneButton.TextSize = 14
    ZoneButton.Font = Enum.Font.GothamSemibold
    ZoneButton.Parent = ContentScroll

    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 8)
    ButtonCorner.Parent = ZoneButton

    local ButtonStroke = Instance.new("UIStroke")
    ButtonStroke.Color = Color3.fromRGB(0, 191, 255)
    ButtonStroke.Thickness = 1.5
    ButtonStroke.Parent = ZoneButton

    ZoneButton.MouseButton1Click:Connect(function()
        moveToTarget(zone.Position, false)
    end)
end

ContentScroll.CanvasSize = UDim2.new(0, 0, 0, (#ZONES * 41) + 20)
