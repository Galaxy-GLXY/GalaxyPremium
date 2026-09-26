pcall(function()
    loadstring(GetScript("Features/BypassAntiCheat.lua"))()
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = Workspace.CurrentCamera

local TARGET_Y = 85.00
local FLY_Y = 85.00
local CUSTOM_SPEED = 300.0
local FLY_SPEED = 600.0
local TARGET_ANIMATION_ID = "rbxassetid://180435571"

local FINAL_SAFE_ZONE = Vector3.new(549.39, TARGET_Y, -365.50)
local SAFE_ESCAPE_POS = Vector3.new(547.54, TARGET_Y, -364.99)

local SAFE_MIN_X = 365.20
local SAFE_MAX_X = 552.00
local SAFE_MIN_Z = -582.00
local SAFE_MAX_Z = -146.00

local SAFE_ZONE_DATA = {Name = "Safe Zone (Steal)", Position = FINAL_SAFE_ZONE, IsSafeZone = true}

local OTHER_ZONES = {
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

local currentHoldingEgg = nil
local isTraveling = false
local activeButton = nil
local originalText = ""

local attachedPart = nil
local activeBV = nil
local activeBG = nil
local currentAnimTrack = nil
local HumanoidProxy = nil

local EGG_OFFSET = CFrame.new(0, -1, -2)
local ANTI_TP_FORCE = true

local function clearServerConstraints(eggPart)
    if not eggPart then return end
    for _, c in ipairs(eggPart:GetChildren()) do
        if c:IsA("WeldConstraint")
            or c:IsA("Weld")
            or c:IsA("BodyPosition")
            or c:IsA("BodyGyro")
            or c:IsA("BodyVelocity")
            or c:IsA("AlignPosition")
            or c:IsA("AlignOrientation")
            or c:IsA("ManualWeld")
            or c:IsA("Motor6D") then
            if c.Name ~= "EggWeld" then
                pcall(function() c:Destroy() end)
            end
        end
    end
end

local function setupProximityPrompt(prompt)
    if not prompt:IsA("ProximityPrompt") then return end
    prompt.HoldDuration = 0
    prompt.Triggered:Connect(function(player)
        if player == LocalPlayer then
            local character = player.Character
            local eggPart = prompt.Parent

            if character and character:FindFirstChild("HumanoidRootPart") and eggPart and eggPart:IsA("BasePart") then
                currentHoldingEgg = eggPart

                local oldWeld = eggPart:FindFirstChild("EggWeld")
                if oldWeld then oldWeld:Destroy() end

                clearServerConstraints(eggPart)

                eggPart.CanCollide = false
                eggPart.Massless = true

                -- Đặt vị trí Egg mượt mà theo nhân vật trước khi Weld
                eggPart.CFrame = character.HumanoidRootPart.CFrame * EGG_OFFSET

                local weld = Instance.new("WeldConstraint")
                weld.Name = "EggWeld"
                weld.Part0 = character.HumanoidRootPart
                weld.Part1 = eggPart
                weld.Parent = eggPart
            end
        end
    end)
end

for _, obj in ipairs(Workspace:GetDescendants()) do setupProximityPrompt(obj) end
Workspace.DescendantAdded:Connect(setupProximityPrompt)

-- MƯỢT MÀ KHÔNG GIẬT: Chỉ kiểm tra & duy trì Weld, không ép CFrame mỗi frame
RunService.RenderStepped:Connect(function()
    if not ANTI_TP_FORCE then return end
    if not currentHoldingEgg or type(currentHoldingEgg) ~= "userdata" or not currentHoldingEgg.Parent then return end

    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Triệt tiêu lực đẩy bất thường tác động lên Egg
    currentHoldingEgg.AssemblyLinearVelocity = Vector3.zero
    currentHoldingEgg.AssemblyAngularVelocity = Vector3.zero

    -- Kiểm tra nếu Weld bị mất thì mới tạo lại và reset vị trí
    local weld = currentHoldingEgg:FindFirstChild("EggWeld")
    if not weld or weld.Part0 ~= hrp or weld.Part1 ~= currentHoldingEgg then
        if weld then weld:Destroy() end
        clearServerConstraints(currentHoldingEgg)

        currentHoldingEgg.CFrame = hrp.CFrame * EGG_OFFSET

        local newWeld = Instance.new("WeldConstraint")
        newWeld.Name = "EggWeld"
        newWeld.Part0 = hrp
        newWeld.Part1 = currentHoldingEgg
        newWeld.Parent = currentHoldingEgg
    end

    -- Dọn dẹp các constraint do Server tự thêm vào
    for _, c in ipairs(currentHoldingEgg:GetChildren()) do
        if c.Name ~= "EggWeld" and (c:IsA("BodyPosition") or c:IsA("AlignPosition") or c:IsA("BodyVelocity") or c:IsA("Weld") or c:IsA("Motor6D")) then
            pcall(function() c:Destroy() end)
        end
    end
end)

local oldGui = PlayerGui:FindFirstChild("UnifiedScriptGui")
if oldGui then oldGui:Destroy() end

local function getCharacter()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart", 5)
    local hum = char:FindFirstChildOfClass("Humanoid")
    return char, hrp, hum
end

local function setAnimateEnabled(character, enabled)
    local animateScript = character:FindFirstChild("Animate")
    if animateScript and animateScript:IsA("LocalScript") then
        animateScript.Disabled = not enabled
    end
end

local function playFixedAnimation(humanoid)
    if not humanoid then return end
    local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
    if not currentAnimTrack or not currentAnimTrack.IsPlaying then
        for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
            if track.Animation and track.Animation.AnimationId ~= TARGET_ANIMATION_ID then
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

local function applyBypass(character)
    if not character then return end
    local oldHumanoid = character:FindFirstChildOfClass("Humanoid")
    if not oldHumanoid or HumanoidProxy then return end

    HumanoidProxy = oldHumanoid:Clone()
    HumanoidProxy.Name = "HumanoidProxy"
    HumanoidProxy.Parent = character
    oldHumanoid:Destroy()

    if hookmetamethod then
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            if self == HumanoidProxy and (method == "GetState" or method == "getState") then
                return Enum.HumanoidStateType.Running
            end
            return oldNamecall(self, ...)
        end)
    end

    LocalPlayer.Character = nil
    LocalPlayer.Character = character
    Camera.CameraSubject = HumanoidProxy

    RunService.RenderStepped:Connect(function(dt)
        if not HumanoidProxy or HumanoidProxy.Health <= 0 or isTraveling then return end
        local _, hrp, _ = getCharacter()
        if not hrp then return end

        HumanoidProxy.Health = HumanoidProxy.MaxHealth

        local moveDir = HumanoidProxy.MoveDirection
        if moveDir.Magnitude > 0 then
            hrp.CFrame = hrp.CFrame + (moveDir * CUSTOM_SPEED * dt)
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.Space) and hrp.Position.Y <= TARGET_Y + 5 then
            hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 50, hrp.AssemblyLinearVelocity.Z)
        end

        HumanoidProxy:ChangeState(Enum.HumanoidStateType.Running)
        playFixedAnimation(HumanoidProxy)
    end)
end

if LocalPlayer.Character then applyBypass(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(applyBypass)

local function stopTravel()
    isTraveling = false

    if attachedPart then attachedPart:Destroy(); attachedPart = nil end
    if activeBV then activeBV:Destroy(); activeBV = nil end
    if activeBG then activeBG:Destroy(); activeBG = nil end

    if currentAnimTrack then currentAnimTrack:Stop(0); currentAnimTrack = nil end

    local char, hrp, hum = getCharacter()
    if char then setAnimateEnabled(char, true) end
    if hrp then
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end

    if activeButton then
        activeButton.Text = originalText
        if activeButton.Name == "SafeZoneButton" then
            activeButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
        else
            activeButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        end
        activeButton = nil
    end
end

local function executeFlight(destinationPos)
    local char, hrp, hum = getCharacter()
    if not char or not hrp or not hum then return end

    setAnimateEnabled(char, false)

    attachedPart = Instance.new("Part")
    attachedPart.Name = "FootSafetyPlatform"
    attachedPart.Size = Vector3.new(5, 1, 5)
    attachedPart.Anchored = false
    attachedPart.CanCollide = true
    attachedPart.Transparency = 1
    attachedPart.CFrame = hrp.CFrame - Vector3.new(0, 3.2, 0)

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = attachedPart
    weld.Part1 = hrp
    weld.Parent = attachedPart
    attachedPart.Parent = Workspace

    activeBV = Instance.new("BodyVelocity")
    activeBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    activeBV.Velocity = Vector3.zero
    activeBV.Parent = hrp

    local targetFlat = Vector3.new(destinationPos.X, TARGET_Y, destinationPos.Z)
    local flyDir = (targetFlat - Vector3.new(hrp.Position.X, TARGET_Y, hrp.Position.Z)).Unit

    activeBG = Instance.new("BodyGyro")
    activeBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    activeBG.P = 90000
    activeBG.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + Vector3.new(flyDir.X, 0, flyDir.Z))
    activeBG.Parent = hrp

    local moveSpeed = FLY_SPEED
    local startTime = tick()
    local distance = (targetFlat - hrp.Position).Magnitude
    local estimatedTime = (distance / moveSpeed) + 0.3

    while isTraveling and char and hrp do
        playFixedAnimation(hum)

        local currentFlatPos = Vector3.new(hrp.Position.X, TARGET_Y, hrp.Position.Z)
        local currentDist = (targetFlat - currentFlatPos).Magnitude

        if currentDist <= 10 or (tick() - startTime) > estimatedTime then
            break
        end

        local currentDir = (targetFlat - currentFlatPos).Unit
        activeBV.Velocity = Vector3.new(currentDir.X * moveSpeed, 0, currentDir.Z * moveSpeed)

        RunService.Heartbeat:Wait()
    end

    if activeBV then activeBV:Destroy(); activeBV = nil end
    if activeBG then activeBG:Destroy(); activeBG = nil end
    if attachedPart then attachedPart:Destroy(); attachedPart = nil end

    if isTraveling and hrp then
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        
        local lockEndTime = tick() + 0.3
        local targetCFrame = CFrame.new(targetFlat)
        while isTraveling and tick() < lockEndTime do
            hrp.CFrame = targetCFrame
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            RunService.Heartbeat:Wait()
        end
    end
end

local function moveToTarget(targetPosition, clickedButton, zoneName)
    if isTraveling then
        stopTravel()
        return
    end

    local _, hrp, _ = getCharacter()
    if not hrp then return end

    isTraveling = true
    activeButton = clickedButton
    originalText = zoneName

    clickedButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    clickedButton.Text = "STOP"

    task.spawn(function()
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

        stopTravel()
    end)
end

local function sendEggToSafeZone()
    if currentHoldingEgg and type(currentHoldingEgg) == "userdata" and currentHoldingEgg.Parent then
        local weld = currentHoldingEgg:FindFirstChild("EggWeld")
        if weld then weld:Destroy() end
        currentHoldingEgg.CFrame = CFrame.new(FINAL_SAFE_ZONE)
        currentHoldingEgg = nil
    end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UnifiedScriptGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 480, 0, 220)
MainFrame.Position = UDim2.new(0.5, -240, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local stroke = Instance.new("UIStroke", MainFrame)
stroke.Color = Color3.fromRGB(0, 191, 255)
stroke.Thickness = 2

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 12)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -45, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Script By GALAXY"
TitleLabel.TextColor3 = Color3.fromRGB(0, 191, 255)
TitleLabel.TextSize = 16
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
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
Instance.new("UICorner", MinimizeButton).CornerRadius = UDim.new(0, 6)

local BodyContainer = Instance.new("Frame")
BodyContainer.Size = UDim2.new(1, -20, 1, -50)
BodyContainer.Position = UDim2.new(0, 10, 0, 45)
BodyContainer.BackgroundTransparency = 1
BodyContainer.Parent = MainFrame

local isMinimized = false
MinimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MinimizeButton.Text = "+"
        MainFrame.Size = UDim2.new(0, 480, 0, 40)
        BodyContainer.Visible = false
    else
        MinimizeButton.Text = "-"
        MainFrame.Size = UDim2.new(0, 480, 0, 220)
        BodyContainer.Visible = true
    end
end)

local SafeZoneBtn = Instance.new("TextButton")
SafeZoneBtn.Name = "SafeZoneButton"
SafeZoneBtn.Size = UDim2.new(0, 110, 1, 0)
SafeZoneBtn.Position = UDim2.new(0, 0, 0, 0)
SafeZoneBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
SafeZoneBtn.Text = SAFE_ZONE_DATA.Name
SafeZoneBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SafeZoneBtn.TextSize = 13
SafeZoneBtn.Font = Enum.Font.GothamBold
SafeZoneBtn.TextWrapped = true
SafeZoneBtn.Parent = BodyContainer

Instance.new("UICorner", SafeZoneBtn).CornerRadius = UDim.new(0, 10)
local safeStroke = Instance.new("UIStroke", SafeZoneBtn)
safeStroke.Color = Color3.fromRGB(255, 100, 100)
safeStroke.Thickness = 1.5

SafeZoneBtn.MouseButton1Click:Connect(function()
    if currentHoldingEgg and type(currentHoldingEgg) == "userdata" and currentHoldingEgg.Parent then
        sendEggToSafeZone()
    else
        moveToTarget(SAFE_ZONE_DATA.Position, SafeZoneBtn, SAFE_ZONE_DATA.Name)
    end
end)

local Separator = Instance.new("Frame")
Separator.Size = UDim2.new(0, 2, 1, 0)
Separator.Position = UDim2.new(0, 122, 0, 0)
Separator.BackgroundColor3 = Color3.fromRGB(0, 191, 255)
Separator.BorderSizePixel = 0
Separator.Parent = BodyContainer

local GridFrame = Instance.new("Frame")
GridFrame.Size = UDim2.new(1, -136, 1, 0)
GridFrame.Position = UDim2.new(0, 136, 0, 0)
GridFrame.BackgroundTransparency = 1
GridFrame.Parent = BodyContainer

local UIGridLayout = Instance.new("UIGridLayout")
UIGridLayout.CellSize = UDim2.new(0, 100, 0, 48)
UIGridLayout.CellPadding = UDim2.new(0, 8, 0, 8)
UIGridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
UIGridLayout.VerticalAlignment = Enum.VerticalAlignment.Top
UIGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIGridLayout.Parent = GridFrame

for _, zone in ipairs(OTHER_ZONES) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.Text = zone.Name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamSemibold
    btn.TextWrapped = true
    btn.Parent = GridFrame

    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local bStroke = Instance.new("UIStroke", btn)
    bStroke.Color = Color3.fromRGB(0, 191, 255)
    bStroke.Thickness = 1.5

    btn.MouseButton1Click:Connect(function()
        moveToTarget(zone.Position, btn, zone.Name)
    end)
end

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
