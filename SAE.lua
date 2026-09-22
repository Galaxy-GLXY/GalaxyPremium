local TARGET_Y = 80.00
local FINAL_SAFE_ZONE = Vector3.new(549.39, TARGET_Y, -365.50)
local SAFE_ESCAPE_POS = Vector3.new(547.54, TARGET_Y, -364.99)

local SAFE_MIN_X = 365.20
local SAFE_MAX_X = 552.00
local SAFE_MIN_Z = -582.00
local SAFE_MAX_Z = -146.00

local ZONES = {
    {Name = "Safe Zone (Steal)", Position = FINAL_SAFE_ZONE, IsSpecial = true},
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
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = Workspace.CurrentCamera

local CUSTOM_SPEED = 270.0
local TARGET_ANIMATION_ID = "rbxassetid://180435571"

for _, obj in ipairs(Workspace:GetDescendants()) do
    if obj:IsA("ProximityPrompt") then
        obj.HoldDuration = 0
    end
end

Workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("ProximityPrompt") then
        obj.HoldDuration = 0
    end
end)

local existingGui = PlayerGui:FindFirstChild("UnifiedScriptGui")
if existingGui then
    existingGui:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UnifiedScriptGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 200, 0, 390)
MainFrame.Position = UDim2.new(0.82, 0, 0.15, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(0, 191, 255)
MainStroke.Thickness = 2
MainStroke.Parent = MainFrame

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 12)
TopBarCorner.Parent = TopBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -45, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "By GALAXY"
TitleLabel.TextColor3 = Color3.fromRGB(0, 191, 255)
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Parent = TopBar

local MinimizeButton = Instance.new("TextButton")
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
ContentScroll.Size = UDim2.new(1, 0, 1, -40)
ContentScroll.Position = UDim2.new(0, 0, 0, 40)
ContentScroll.BackgroundTransparency = 1
ContentScroll.BorderSizePixel = 0
ContentScroll.ScrollBarThickness = 6
ContentScroll.CanvasSize = UDim2.new(0, 0, 0, (#ZONES * 42) + 20)
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

local dragging, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

local isMinimized = false
MinimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MinimizeButton.Text = "+"
        MainFrame.Size = UDim2.new(0, 200, 0, 40)
        ContentScroll.Visible = false
    else
        MinimizeButton.Text = "-"
        MainFrame.Size = UDim2.new(0, 200, 0, 390)
        ContentScroll.Visible = true
    end
end)

local isTraveling = false
local groundPlatform = nil
local activeZoneButton = nil
local originalButtonText = ""
local currentAnimTrack = nil

local function setAnimateScriptEnabled(character, enabled)
    local animateScript = character:FindFirstChild("Animate")
    if animateScript and animateScript:IsA("LocalScript") then
        animateScript.Disabled = not enabled
    end
end

local function forceAnimation(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
    
    setAnimateScriptEnabled(character, false)
    
    if not currentAnimTrack or not currentAnimTrack.IsPlaying then
        for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
            if track.Animation.AnimationId ~= TARGET_ANIMATION_ID then
                track:Stop(0)
            end
        end
        local anim = Instance.new("Animation")
        anim.AnimationId = TARGET_ANIMATION_ID
        currentAnimTrack = animator:LoadAnimation(anim)
        currentAnimTrack.Looped = true
        currentAnimTrack:Play()
    end
end

local function unblockHumanoid(humanoid)
    if not humanoid then return end
    if humanoid.PlatformStand then humanoid.PlatformStand = false end
    if humanoid.Sit then humanoid.Sit = false end
    pcall(function()
        humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
    end)
end

local previousCharacter = nil

local function applyBypass(character)
    if not character then return end
    previousCharacter = character
    local oldHumanoid = character:FindFirstChildOfClass("Humanoid")
    if oldHumanoid and not character:FindFirstChild("HumanoidProxy") then
        local cloneHum = oldHumanoid:Clone()
        cloneHum.Name = "HumanoidProxy"
        cloneHum.Parent = character
        oldHumanoid:Destroy()
        
        LocalPlayer.Character = nil
        LocalPlayer.Character = character
        Camera.CameraSubject = cloneHum

        RunService.RenderStepped:Connect(function(dt)
            if character and character.Parent and not isTraveling then
                if cloneHum.Health < cloneHum.MaxHealth then
                    cloneHum.Health = cloneHum.MaxHealth
                end
                
                local hrp = character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.AssemblyAngularVelocity = Vector3.zero

                    cloneHum.WalkSpeed = 0
                    local moveDir = cloneHum.MoveDirection
                    if moveDir.Magnitude > 0 then
                        hrp.CFrame = hrp.CFrame + (moveDir * (CUSTOM_SPEED * dt))
                        local targetLookAt = Vector3.new(moveDir.X, 0, moveDir.Z)
                        if targetLookAt.Magnitude > 0 then
                            local currentCF = hrp.CFrame
                            local newCF = CFrame.new(currentCF.Position, currentCF.Position + targetLookAt)
                            hrp.CFrame = currentCF:Lerp(newCF, 0.3)
                        end
                    end

                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) or cloneHum.Jump then
                        if hrp.Position.Y <= (TARGET_Y + 5) then
                            hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 50, hrp.AssemblyLinearVelocity.Z)
                        end
                    end
                end
            end
        end)
    end
end

if LocalPlayer.Character then
    applyBypass(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(applyBypass)

task.spawn(function()
    while true do
        task.wait(0.05)
        local character = LocalPlayer.Character
        local cloneHum = character and character:FindFirstChild("HumanoidProxy")
        local root = character and character:FindFirstChild("HumanoidRootPart")
        
        if character == previousCharacter and cloneHum and cloneHum.Health > 0
            and root and not root.Anchored and not cloneHum.PlatformStand and not cloneHum.Sit
            and cloneHum:GetState() == Enum.HumanoidStateType.Physics
            and (tonumber(LocalPlayer:GetAttribute("RagdollEndTime")) or 0) <= workspace:GetServerTimeNow()
            and #character:QueryDescendants("BallSocketConstraint") == 0 then
            cloneHum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end
end)

local function stopTravel()
    isTraveling = false
    if groundPlatform then groundPlatform:Destroy(); groundPlatform = nil end

    if activeZoneButton then
        activeZoneButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        activeZoneButton.Text = originalButtonText
        activeZoneButton = nil
    end

    local character = LocalPlayer.Character
    if character then
        if currentAnimTrack then
            currentAnimTrack:Stop(0)
            currentAnimTrack = nil
        end
        setAnimateScriptEnabled(character, true)
        
        local cloneHum = character:FindFirstChild("HumanoidProxy")
        if cloneHum then
            unblockHumanoid(cloneHum)
            cloneHum:ChangeState(Enum.HumanoidStateType.Running)
        end
    end
end

local function executeFlight(destinationPos)
    local character = LocalPlayer.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local cloneHum = character:FindFirstChild("HumanoidProxy")
    if not hrp or not cloneHum then return end

    groundPlatform = Instance.new("Part")
    groundPlatform.Name = "FakeGroundPlatform"
    groundPlatform.Size = Vector3.new(10, 1, 10)
    groundPlatform.Anchored = true
    groundPlatform.CanCollide = true
    groundPlatform.Transparency = 1
    groundPlatform.Material = Enum.Material.SmoothPlastic
    groundPlatform.Parent = workspace

    local flySpeed = 420.0
    local targetFlat = Vector3.new(destinationPos.X, TARGET_Y, destinationPos.Z)

    while isTraveling and character and hrp and cloneHum.Health > 0 do
        forceAnimation(character)
        cloneHum:ChangeState(Enum.HumanoidStateType.Running)

        local currentPos = hrp.Position
        local currentFlatPos = Vector3.new(currentPos.X, TARGET_Y, currentPos.Z)
        local distance = (targetFlat - currentFlatPos).Magnitude

        if distance <= 4 then
            break
        end

        local direction = (targetFlat - currentFlatPos).Unit
        local dt = RunService.Heartbeat:Wait()
        local moveStep = direction * (flySpeed * dt)
        local nextPos = currentPos + moveStep

        groundPlatform.CFrame = CFrame.new(nextPos.X, TARGET_Y - 3.2, nextPos.Z)
        hrp.CFrame = CFrame.new(nextPos, nextPos + direction)
        hrp.AssemblyLinearVelocity = direction * flySpeed
    end

    if groundPlatform then groundPlatform:Destroy(); groundPlatform = nil end
end

local function moveToTarget(targetPosition, clickedButton, zoneName)
    if isTraveling then
        stopTravel()
        return
    end

    local character = LocalPlayer.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local cloneHum = character:FindFirstChild("HumanoidProxy")
    if not hrp or not cloneHum then return end

    isTraveling = true
    activeZoneButton = clickedButton
    originalButtonText = zoneName

    clickedButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    clickedButton.Text = "STOP"

    forceAnimation(character)
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

    if isTraveling then
        local finalCFrame = CFrame.new(targetPosition)
        local endTime = tick() + 0.15
        while isTraveling and tick() < endTime and character and hrp do
            forceAnimation(character)
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.CFrame = finalCFrame
            if cloneHum then
                cloneHum:ChangeState(Enum.HumanoidStateType.Running)
            end
            RunService.Heartbeat:Wait()
        end
    end

    stopTravel()
end

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
        moveToTarget(zone.Position, ZoneButton, zone.Name)
    end)
end
