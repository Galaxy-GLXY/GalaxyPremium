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
local TARGET_ANIMATION_ID = "rbxassetid://180435571"

local SAFE_ZONE_WALK_SPEED = 600.0
local OTHER_ZONE_WALK_SPEED = 600.0

local FINAL_SAFE_ZONE = Vector3.new(549.39, TARGET_Y, -365.50)
local SAFE_ESCAPE_POS = Vector3.new(547.54, TARGET_Y, -364.99)

local SAFE_MIN_X = 365.20
local SAFE_MAX_X = 552.00
local SAFE_MIN_Z = -582.00
local SAFE_MAX_Z = -146.00

local AUTO_STEAL_SAFE_POS = Vector3.new(549.39, TARGET_Y, -365.50)
local AUTO_STEAL_RETURN_DELAY = 0.3

local SAFE_MODE_Y_MIN = 110.00
local SAFE_MODE_Y_MAX = 120.00
local SAFE_MODE_SPEED = 1.0  

local SAFE_ZONE_DATA = {Name = "Safe Zone", Position = FINAL_SAFE_ZONE, IsSafeZone = true}

local OTHER_ZONES = {
    {Name = "Jungle",          Position = Vector3.new(1188.33, TARGET_Y, -411.97)},
    {Name = "Snow",            Position = Vector3.new(1491.05, TARGET_Y, -311.35)},
    {Name = "Volcano",         Position = Vector3.new(1878.24, TARGET_Y, -402.08)},
    {Name = "Abyss Ocean",     Position = Vector3.new(2281.41, TARGET_Y, -322.72)},
    {Name = "Prehistoric",     Position = Vector3.new(2812.95, TARGET_Y, -402.20)},
    {Name = "Cosmic",          Position = Vector3.new(3392.38, TARGET_Y, -320.73)},
    {Name = "Cherry Blossom",  Position = Vector3.new(4028.07, TARGET_Y, -400.72)},
    {Name = "Titan Temple",    Position = Vector3.new(4797.41, TARGET_Y, -324.84)},
    {Name = "Angels/Demons",   Position = Vector3.new(5661.74, TARGET_Y, -324.21)},
}

local currentHoldingEgg = nil
local isTraveling = false
local activeButton = nil
local originalText = ""

local currentAnimTrack = nil
local HumanoidProxy = nil

local EGG_OFFSET = CFrame.new(0, -1, -2)
local ANTI_TP_FORCE = true

local autoStealActive = false
local autoStealBusy = false
local processedEggs = setmetatable({}, { __mode = "k" })

-- Safe Mode variables
local safeModeActive = false
local safeModePart = nil
local safeModeConnection = nil
local safeModeY = SAFE_MODE_Y_MIN
local safeModeDir = 1

local function enforceSafeAttributes(char)
    if not char then return end
    if char:GetAttribute("Ragdoll") ~= false then char:SetAttribute("Ragdoll", false) end
    if char:GetAttribute("IsRagdolled") ~= false then char:SetAttribute("IsRagdolled", false) end
    if char:GetAttribute("RagdollEndTime") ~= 0 then char:SetAttribute("RagdollEndTime", 0) end
end

local function applyAntiHit(character)
    if not character then return end
    enforceSafeAttributes(character)
    character.AttributeChanged:Connect(function(attr)
        if attr == "Ragdoll" or attr == "IsRagdolled" or attr == "RagdollEndTime" then
            enforceSafeAttributes(character)
        end
    end)
end

if LocalPlayer.Character then applyAntiHit(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(applyAntiHit)

RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    if char then enforceSafeAttributes(char) end
end)

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

RunService.RenderStepped:Connect(function()
    if not ANTI_TP_FORCE then return end
    if not currentHoldingEgg or type(currentHoldingEgg) ~= "userdata" or not currentHoldingEgg.Parent then return end

    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    currentHoldingEgg.AssemblyLinearVelocity = Vector3.zero
    currentHoldingEgg.AssemblyAngularVelocity = Vector3.zero

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

local function playRunAnimation(humanoid)
    if not humanoid then return end
    local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
    if not currentAnimTrack or not currentAnimTrack.IsPlaying then
        for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
            if track.Animation and track.Animation.AnimationId ~= TARGET_ANIMATION_ID then
                track:Stop(0)
            end
        end
        local anim = Instance.new("Animation")
        anim.Name = "Animation1"
        anim.AnimationId = TARGET_ANIMATION_ID
        currentAnimTrack = animator:LoadAnimation(anim)
        currentAnimTrack.Looped = true
        currentAnimTrack.Priority = Enum.AnimationPriority.Movement
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
        if not HumanoidProxy or HumanoidProxy.Health <= 0 then return end
        if autoStealBusy then return end
        local _, hrp, _ = getCharacter()
        if not hrp then return end

        HumanoidProxy.Health = HumanoidProxy.MaxHealth
        HumanoidProxy:ChangeState(Enum.HumanoidStateType.Running)
        playRunAnimation(HumanoidProxy)
    end)
end

if LocalPlayer.Character then applyBypass(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(applyBypass)

local function stopTravel()
    isTraveling = false

    if currentAnimTrack then currentAnimTrack:Stop(0); currentAnimTrack = nil end

    if activeButton and activeButton.Name ~= "AutoStealButton" then
        activeButton.Text = originalText
        if activeButton.Name == "SafeZoneButton" then
            activeButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
        else
            activeButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        end
        activeButton = nil
    elseif activeButton then
        activeButton.Text = originalText
        activeButton = nil
    end
end

local function walkToTarget(destinationPos, speed)
    local char, hrp, hum = getCharacter()
    if not char or not hrp or not hum then return end

    local walkHum = HumanoidProxy or hum
    if not walkHum then return end

    speed = speed or OTHER_ZONE_WALK_SPEED

    local targetFlat = Vector3.new(destinationPos.X, TARGET_Y, destinationPos.Z)

    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
    hrp.CFrame = CFrame.new(hrp.Position.X, TARGET_Y, hrp.Position.Z)

    local platform = Instance.new("Part")
    platform.Name = "WalkPlatform"
    platform.Size = Vector3.new(20, 4, 20)
    platform.Anchored = true
    platform.CanCollide = true
    platform.CanQuery = false
    platform.CanTouch = false
    platform.Transparency = 1
    platform.Material = Enum.Material.SmoothPlastic
    platform.CFrame = CFrame.new(hrp.Position.X, TARGET_Y - 5, hrp.Position.Z)
    platform.Parent = Workspace

    local loopConn = RunService.RenderStepped:Connect(function(dt)
        if not hrp or not hrp.Parent then return end
        if not platform or not platform.Parent then return end

        platform.CFrame = CFrame.new(hrp.Position.X, TARGET_Y - 5, hrp.Position.Z)

        local currentPos = hrp.Position
        local deltaX = targetFlat.X - currentPos.X
        local deltaZ = targetFlat.Z - currentPos.Z
        local distToTarget = math.sqrt(deltaX * deltaX + deltaZ * deltaZ)

        if distToTarget > 0.1 then
            local dirX = deltaX / distToTarget
            local dirZ = deltaZ / distToTarget
            local stepDist = math.min(speed * dt, distToTarget)
            local newX = currentPos.X + dirX * stepDist
            local newZ = currentPos.Z + dirZ * stepDist

            local rot = hrp.CFrame - hrp.CFrame.Position
            hrp.CFrame = CFrame.new(newX, TARGET_Y, newZ) * rot
        end

        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end)

    local startTime = tick()

    while isTraveling and char and hrp and walkHum.Health > 0 do
        if currentAnimTrack then
            currentAnimTrack:Stop(0)
            currentAnimTrack = nil
        end

        local currentPos = Vector3.new(hrp.Position.X, TARGET_Y, hrp.Position.Z)
        local dist = (targetFlat - currentPos).Magnitude
        if dist <= 3 then break end
        if tick() - startTime > 90 then break end

        RunService.Heartbeat:Wait()
    end

    local stopEnd = tick() + 0.2
    while tick() < stopEnd do
        if hrp and hrp.Parent then
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            local rot = hrp.CFrame - hrp.CFrame.Position
            hrp.CFrame = CFrame.new(hrp.Position.X, TARGET_Y, hrp.Position.Z) * rot
        end
        RunService.Heartbeat:Wait()
    end

    loopConn:Disconnect()
    if platform then platform:Destroy() end
end

local function moveToTarget(targetPosition, clickedButton, zoneName, speed)
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
        hrp.AssemblyAngularVelocity = Vector3.zero
        hrp.CFrame = CFrame.new(hrp.Position.X, TARGET_Y, hrp.Position.Z)

        local currentPos = hrp.Position
        local isInSafeZone = (currentPos.X >= SAFE_MIN_X and currentPos.X <= SAFE_MAX_X) and
                             (currentPos.Z >= SAFE_MIN_Z and currentPos.Z <= SAFE_MAX_Z)

        if isInSafeZone then
            walkToTarget(SAFE_ESCAPE_POS, speed)
        end

        if isTraveling then
            walkToTarget(targetPosition, speed)
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

local AutoStealBtn = Instance.new("TextButton")
AutoStealBtn.Name = "AutoStealButton"
AutoStealBtn.Size = UDim2.new(0, 110, 0.5, -2)
AutoStealBtn.Position = UDim2.new(0, 0, 0, 0)
AutoStealBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 60)
AutoStealBtn.Text = "Auto Steal"
AutoStealBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoStealBtn.TextSize = 13
AutoStealBtn.Font = Enum.Font.GothamBold
AutoStealBtn.TextWrapped = true
AutoStealBtn.Parent = BodyContainer

Instance.new("UICorner", AutoStealBtn).CornerRadius = UDim.new(0, 10)
local autoStealStroke = Instance.new("UIStroke", AutoStealBtn)
autoStealStroke.Color = Color3.fromRGB(100, 255, 120)
autoStealStroke.Thickness = 1.5

AutoStealBtn.MouseButton1Click:Connect(function()
    autoStealActive = not autoStealActive
    if autoStealActive then
        AutoStealBtn.BackgroundColor3 = Color3.fromRGB(220, 40, 40)
        autoStealStroke.Color = Color3.fromRGB(255, 100, 100)
        AutoStealBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        AutoStealBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 60)
        autoStealStroke.Color = Color3.fromRGB(100, 255, 120)
        processedEggs = setmetatable({}, { __mode = "k" })
    end
end)

task.spawn(function()
    local hue = 0
    while AutoStealBtn and AutoStealBtn.Parent do
        if not autoStealActive then
            hue = (hue + 0.008) % 1
            AutoStealBtn.TextColor3 = Color3.fromHSV(hue, 1, 1)
        end
        task.wait(0.03)
    end
end)

local SafeZoneBtn = Instance.new("TextButton")
SafeZoneBtn.Name = "SafeZoneButton"
SafeZoneBtn.Size = UDim2.new(0, 110, 0.5, -2)
SafeZoneBtn.Position = UDim2.new(0, 0, 0.5, 2)
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

task.spawn(function()
    local hue = 0
    while SafeZoneBtn and SafeZoneBtn.Parent do
        if activeButton ~= SafeZoneBtn then
            hue = (hue + 0.008) % 1
            SafeZoneBtn.TextColor3 = Color3.fromHSV(hue, 1, 1)
        end
        task.wait(0.03)
    end
end)

SafeZoneBtn.MouseButton1Click:Connect(function()
    if currentHoldingEgg and type(currentHoldingEgg) == "userdata" and currentHoldingEgg.Parent then
        sendEggToSafeZone()
    else
        moveToTarget(SAFE_ZONE_DATA.Position, SafeZoneBtn, SAFE_ZONE_DATA.Name, SAFE_ZONE_WALK_SPEED)
    end
end)

-- ============================================================
-- =============== SAFE MODE BUTTON (Draggable) ==============
-- ============================================================
local SafeModeContainer = Instance.new("Frame")
SafeModeContainer.Name = "SafeModeContainer"
SafeModeContainer.Size = UDim2.new(0, 150, 0, 40)
SafeModeContainer.Position = UDim2.new(0, 20, 0, 130)   -- ✅ Góc chat (dưới icon chat)
SafeModeContainer.BackgroundTransparency = 1
SafeModeContainer.Parent = ScreenGui
SafeModeContainer.ZIndex = 10

local safeModeContainerStroke = Instance.new("UIStroke", SafeModeContainer)
safeModeContainerStroke.Color = Color3.fromRGB(0, 255, 0)
safeModeContainerStroke.Thickness = 3

local SafeModeBtn = Instance.new("TextButton")
SafeModeBtn.Name = "SafeModeBtn"
SafeModeBtn.Size = UDim2.new(1, -10, 1, -10)
SafeModeBtn.Position = UDim2.new(0, 5, 0, 5)
SafeModeBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 60)
SafeModeBtn.Text = "An Toàn"
SafeModeBtn.TextColor3 = Color3.new(1, 1, 1)
SafeModeBtn.TextSize = 12
SafeModeBtn.Font = Enum.Font.GothamBold
SafeModeBtn.TextWrapped = true
SafeModeBtn.Parent = SafeModeContainer
SafeModeBtn.ZIndex = 11

Instance.new("UICorner", SafeModeBtn).CornerRadius = UDim.new(0, 6)

-- Drag by border
local safeModeDragging = false
local safeModeDragStart = nil
local safeModeStartPos = nil

SafeModeContainer.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local mousePos = Vector2.new(input.Position.X, input.Position.Y)
        local innerPos = SafeModeBtn.AbsolutePosition
        local innerSize = SafeModeBtn.AbsoluteSize

        local isOnBorder = (mousePos.X < innerPos.X) or (mousePos.X > innerPos.X + innerSize.X)
                          or (mousePos.Y < innerPos.Y) or (mousePos.Y > innerPos.Y + innerSize.Y)

        if isOnBorder then
            safeModeDragging = true
            safeModeDragStart = input.Position
            safeModeStartPos = SafeModeContainer.Position
        end
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if safeModeDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - safeModeDragStart
        SafeModeContainer.Position = UDim2.new(
            safeModeStartPos.X.Scale, safeModeStartPos.X.Offset + delta.X,
            safeModeStartPos.Y.Scale, safeModeStartPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        safeModeDragging = false
    end
end)

-- Safe Mode functions
local function startSafeMode()
    if safeModeActive then return end
    local char, hrp = getCharacter()
    if not hrp then return end

    safeModeActive = true
    safeModeY = SAFE_MODE_Y_MIN
    safeModeDir = 1

    -- Lift to Y=100 instantly
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
    hrp.CFrame = CFrame.new(hrp.Position.X, safeModeY, hrp.Position.Z)

    -- ✅ Part trong suốt hoàn toàn (extends to ground)
    safeModePart = Instance.new("Part")
    safeModePart.Name = "SafeModePart_Local"
    safeModePart.Size = Vector3.new(20, 150, 20)   -- ✅ Dài hơn để luôn chạm đất
    safeModePart.Anchored = true
    safeModePart.CanCollide = false
    safeModePart.CanQuery = false
    safeModePart.CanTouch = false
    safeModePart.Transparency = 1                  -- ✅ Trong suốt
    safeModePart.Material = Enum.Material.SmoothPlastic
    safeModePart.CFrame = CFrame.new(hrp.Position.X, safeModeY - 75, hrp.Position.Z)
    safeModePart.Parent = Workspace

    -- Oscillate Y between 100 and 120 at 1 stud/s
    safeModeConnection = RunService.Heartbeat:Connect(function(dt)
        if not safeModeActive then return end
        if isTraveling or autoStealBusy then return end

        local char, hrp = getCharacter()
        if not hrp then return end

        safeModeY = safeModeY + safeModeDir * SAFE_MODE_SPEED * dt
        if safeModeY >= SAFE_MODE_Y_MAX then safeModeY = SAFE_MODE_Y_MAX; safeModeDir = -1 end
        if safeModeY <= SAFE_MODE_Y_MIN then safeModeY = SAFE_MODE_Y_MIN; safeModeDir = 1 end

        local curX = hrp.Position.X
        local curZ = hrp.Position.Z

        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        hrp.CFrame = CFrame.new(curX, safeModeY, curZ)

        if safeModePart and safeModePart.Parent then
            safeModePart.CFrame = CFrame.new(curX, safeModeY - 75, curZ)
        end
    end)
end

local function stopSafeMode()
    if not safeModeActive then return end
    safeModeActive = false

    if safeModeConnection then
        safeModeConnection:Disconnect()
        safeModeConnection = nil
    end

    if safeModePart then
        safeModePart:Destroy()
        safeModePart = nil
    end

    local char, hrp = getCharacter()
    if hrp then
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end
end

SafeModeBtn.MouseButton1Click:Connect(function()
    if safeModeActive then
        stopSafeMode()
        SafeModeBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 60)
        safeModeContainerStroke.Color = Color3.fromRGB(0, 255, 0)
        SafeModeBtn.Text = "An Toàn"
    else
        startSafeMode()
        SafeModeBtn.BackgroundColor3 = Color3.fromRGB(220, 40, 40)
        safeModeContainerStroke.Color = Color3.fromRGB(255, 100, 100)
        SafeModeBtn.Text = "An Toàn: ON"
    end
end)
-- ============================================================
-- =============== END SAFE MODE BUTTON ======================
-- ============================================================

-- ===== AUTO STEAL =====
task.spawn(function()
    while task.wait(0.1) do
        if not autoStealActive then continue end
        if autoStealBusy then continue end
        if isTraveling then continue end
        if not currentHoldingEgg or type(currentHoldingEgg) ~= "userdata" or not currentHoldingEgg.Parent then continue end
        if processedEggs[currentHoldingEgg] then continue end

        processedEggs[currentHoldingEgg] = true
        autoStealBusy = true

        local char, hrp = getCharacter()
        if hrp then
            local savedHRPCF = hrp.CFrame
            local savedCamCF = Camera.CFrame
            local savedCamSubject = Camera.CameraSubject

            Camera.CameraType = Enum.CameraType.Scriptable
            Camera.CFrame = savedCamCF
            Camera.CameraSubject = nil

            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            hrp.CFrame = CFrame.new(AUTO_STEAL_SAFE_POS)

            task.wait(AUTO_STEAL_RETURN_DELAY)

            if hrp and hrp.Parent then
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
                hrp.CFrame = savedHRPCF
            end

            Camera.CameraSubject = HumanoidProxy or char:FindFirstChildOfClass("Humanoid")
            Camera.CameraType = Enum.CameraType.Custom
        end

        task.wait(0.3)
        autoStealBusy = false
    end
end)
-- ===== END AUTO STEAL =====

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
        moveToTarget(zone.Position, btn, zone.Name, OTHER_ZONE_WALK_SPEED)
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
