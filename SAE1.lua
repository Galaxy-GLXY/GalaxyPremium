local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = Workspace.CurrentCamera

local TARGET_ANIMATION_ID = "rbxassetid://180435571"

local TELEPORT_LOOP_DURATION = 0.7
local ATTRACT_SPEED = 2500

local SUPPORT_GROUND_Y = 70.00
local SUPPORT_FEET_OFFSET = 3.00

local FINAL_SAFE_ZONE = Vector3.new(549.39, 85, -365.5)
local SAFE_ESCAPE_POS = Vector3.new(547.54, 85, -364.99)

local SAFE_MIN_X = 365.2
local SAFE_MAX_X = 552
local SAFE_MIN_Z = -582
local SAFE_MAX_Z = -146

local AUTO_STEAL_SAFE_POS = Vector3.new(549.39, 85, -365.5)
local AUTO_STEAL_RETURN_DELAY = 0.5

local SAFE_MODE_Y_MIN = 110
local SAFE_MODE_Y_MAX = 120
local SAFE_MODE_SPEED = 1

local SAFE_ZONE_DATA = {Name = "Safe Zone", Position = FINAL_SAFE_ZONE, IsSafeZone = true}

local OTHER_ZONES = {
    {Name = "Jungle",           Position = Vector3.new(1188.33, 85, -411.97)},
    {Name = "Snow",             Position = Vector3.new(1491.05, 85, -311.35)},
    {Name = "Volcano",          Position = Vector3.new(1878.24, 85, -402.08)},
    {Name = "Abyss Ocean",      Position = Vector3.new(2281.41, 85, -322.72)},
    {Name = "Prehistoric",      Position = Vector3.new(2812.95, 85, -402.2)},
    {Name = "Cosmic",           Position = Vector3.new(3392.38, 85, -320.73)},
    {Name = "Cherry Blossom",   Position = Vector3.new(4028.07, 85, -400.72)},
    {Name = "Titan Temple",     Position = Vector3.new(4797.41, 85, -324.84)},
    {Name = "Angels/Demons",    Position = Vector3.new(5661.74, 85, -324.21)},
    {Name = "Enchanted Forest", Position = Vector3.new(6697.23, 85, -348.52)},
}

local currentHoldingEgg = nil
local isTraveling = false
local activeButton = nil
local originalText = ""

local currentAnimTrack = nil
local HumanoidProxy = nil

local autoStealActive = false
local autoStealBusy = false
local processedEggs = setmetatable({}, { __mode = "k" })

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

local function setupProximityPrompt(prompt)
    if not prompt:IsA("ProximityPrompt") then return end
    prompt.HoldDuration = 0
    prompt.Triggered:Connect(function(player)
        if player == LocalPlayer then
            local eggPart = prompt.Parent
            if eggPart and eggPart:IsA("BasePart") then
                currentHoldingEgg = eggPart
            end
        end
    end)
end

for _, obj in ipairs(Workspace:GetDescendants()) do setupProximityPrompt(obj) end
Workspace.DescendantAdded:Connect(setupProximityPrompt)

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
    local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 5)
    if not humanoid then return end

    HumanoidProxy = humanoid

    RunService.RenderStepped:Connect(function(dt)
        if not HumanoidProxy or HumanoidProxy.Health <= 0 then return end
        if autoStealBusy then return end
        local _, hrp, _ = getCharacter()
        if not hrp then return end

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

local function createSupportPart()
    local part = Instance.new("Part")
    part.Name = "GroundSupport"
    part.Anchored = true
    part.CanCollide = false
    part.CanQuery = false
    part.CanTouch = false
    part.Transparency = 1
    part.Material = Enum.Material.SmoothPlastic
    part.Size = Vector3.new(20, 12, 20)
    part.Parent = Workspace
    return part
end

local function updateSupportPart(part, hrp)
    if not part or not part.Parent then return end
    if not hrp or not hrp.Parent then return end

    local topY = hrp.Position.Y - SUPPORT_FEET_OFFSET
    local bottomY = SUPPORT_GROUND_Y
    local height = math.max(topY - bottomY, 1)
    local centerY = (topY + bottomY) / 2

    part.Size = Vector3.new(20, height, 20)
    part.CFrame = CFrame.new(hrp.Position.X, centerY, hrp.Position.Z)
end

local function loopTeleportTo(targetPos, duration)
    local char, hrp = getCharacter()
    if not char or not hrp then return end

    duration = duration or TELEPORT_LOOP_DURATION

    local anchor = Instance.new("Part")
    anchor.Name = "TPAnchor"
    anchor.Size = Vector3.new(2, 2, 2)
    anchor.Anchored = true
    anchor.CanCollide = false
    anchor.CanQuery = false
    anchor.CanTouch = false
    anchor.Transparency = 1
    anchor.Material = Enum.Material.SmoothPlastic
    anchor.CFrame = CFrame.new(targetPos)
    anchor.Parent = Workspace

    local support = createSupportPart()

    local startTime = tick()
    local conn = RunService.RenderStepped:Connect(function()
        if not isTraveling then return end
        if not hrp or not hrp.Parent then return end
        if not anchor or not anchor.Parent then return end
        if tick() - startTime > duration then return end

        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        hrp.CFrame = anchor.CFrame

        updateSupportPart(support, hrp)
    end)

    local endTime = tick() + duration
    while isTraveling and tick() < endTime do
        RunService.Heartbeat:Wait()
    end

    if conn then conn:Disconnect() end
    if anchor then anchor:Destroy() end
    if support then support:Destroy() end

    if hrp and hrp.Parent then
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end
end

local function attractToPos(targetPos)
    local char, hrp, hum = getCharacter()
    if not char or not hrp then return end

    local anchor = Instance.new("Part")
    anchor.Name = "AttractAnchor"
    anchor.Size = Vector3.new(6, 6, 6)
    anchor.Anchored = true
    anchor.CanCollide = false
    anchor.CanQuery = false
    anchor.CanTouch = false
    anchor.Transparency = 1
    anchor.Material = Enum.Material.SmoothPlastic
    anchor.CFrame = CFrame.new(targetPos)
    anchor.Parent = Workspace

    local support = createSupportPart()

    local savedWS = nil
    local wsConn = nil
    if hum then
        savedWS = hum.WalkSpeed
        hum.WalkSpeed = 0
        wsConn = hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
            if hum.WalkSpeed ~= 0 then
                hum.WalkSpeed = 0
            end
        end)
    end

    local reached = false

    local conn = RunService.RenderStepped:Connect(function(dt)
        if not isTraveling or reached then return end
        if not hrp or not hrp.Parent then return end
        if not anchor or not anchor.Parent then return end

        local cur = hrp.Position
        local diff = targetPos - cur
        local dist = diff.Magnitude

        if dist <= 3 then
            reached = true
            return
        end

        local dir = diff.Unit
        local stepDist = math.min(ATTRACT_SPEED * dt, dist)
        hrp.CFrame = CFrame.new(cur + dir * stepDist) * (hrp.CFrame - hrp.CFrame.Position)
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero

        updateSupportPart(support, hrp)
    end)

    local startTime = tick()
    while isTraveling and not reached and tick() - startTime < 5 do
        RunService.Heartbeat:Wait()
    end

    if conn then conn:Disconnect() end
    if wsConn then wsConn:Disconnect() end
    if hum and hum.Parent and savedWS then
        hum.WalkSpeed = savedWS
    end
    if anchor then anchor:Destroy() end
    if support then support:Destroy() end
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
        local currentPos = hrp.Position
        local isInSafeZone = (currentPos.X >= SAFE_MIN_X and currentPos.X <= SAFE_MAX_X) and
                             (currentPos.Z >= SAFE_MIN_Z and currentPos.Z <= SAFE_MAX_Z)

        if isInSafeZone then
            attractToPos(SAFE_ESCAPE_POS)
        end

        if isTraveling then
            loopTeleportTo(targetPosition, TELEPORT_LOOP_DURATION)
        end

        stopTravel()
    end)
end

local function sendEggToSafeZone()
    if currentHoldingEgg and type(currentHoldingEgg) == "userdata" and currentHoldingEgg.Parent then
        currentHoldingEgg.CFrame = CFrame.new(FINAL_SAFE_ZONE)
        currentHoldingEgg = nil
    end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UnifiedScriptGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 420, 0, 340)
MainFrame.Position = UDim2.new(0.5, -210, 0.3, 0)
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
        MainFrame.Size = UDim2.new(0, 420, 0, 40)
        BodyContainer.Visible = false
    else
        MinimizeButton.Text = "-"
        MainFrame.Size = UDim2.new(0, 420, 0, 340)
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
        moveToTarget(SAFE_ZONE_DATA.Position, SafeZoneBtn, SAFE_ZONE_DATA.Name)
    end
end)

local SafeModeBtn = Instance.new("TextButton")
SafeModeBtn.Name = "SafeModeBtn"
SafeModeBtn.Size = UDim2.new(0, 150, 0, 40)
SafeModeBtn.Position = UDim2.new(0, 20, 0, 130)
SafeModeBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 60)
SafeModeBtn.Text = "Safe Mode"
SafeModeBtn.TextColor3 = Color3.new(1, 1, 1)
SafeModeBtn.TextSize = 12
SafeModeBtn.Font = Enum.Font.GothamBold
SafeModeBtn.TextWrapped = true
SafeModeBtn.Parent = ScreenGui

Instance.new("UICorner", SafeModeBtn).CornerRadius = UDim.new(0, 6)
local safeModeStroke = Instance.new("UIStroke", SafeModeBtn)
safeModeStroke.Color = Color3.fromRGB(0, 255, 0)
safeModeStroke.Thickness = 3

local function startSafeMode()
    if safeModeActive then return end
    local char, hrp = getCharacter()
    if not hrp then return end

    safeModeActive = true
    safeModeY = SAFE_MODE_Y_MIN
    safeModeDir = 1

    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
    hrp.CFrame = CFrame.new(hrp.Position.X, safeModeY, hrp.Position.Z)

    safeModePart = Instance.new("Part")
    safeModePart.Name = "SafeModePart_Local"
    safeModePart.Size = Vector3.new(20, 150, 20)
    safeModePart.Anchored = true
    safeModePart.CanCollide = false
    safeModePart.CanQuery = false
    safeModePart.CanTouch = false
    safeModePart.Transparency = 1
    safeModePart.Material = Enum.Material.SmoothPlastic
    safeModePart.CFrame = CFrame.new(hrp.Position.X, safeModeY - 75, hrp.Position.Z)
    safeModePart.Parent = Workspace

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
        safeModeStroke.Color = Color3.fromRGB(0, 255, 0)
        SafeModeBtn.Text = "Safe Mode"
    else
        startSafeMode()
        SafeModeBtn.BackgroundColor3 = Color3.fromRGB(220, 40, 40)
        safeModeStroke.Color = Color3.fromRGB(255, 100, 100)
        SafeModeBtn.Text = "Safe Mode: ON"
    end
end)

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

            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                Camera.CameraSubject = hum
            end
            Camera.CameraType = Enum.CameraType.Custom
        end

        task.wait(0.3)
        autoStealBusy = false
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
UIGridLayout.CellSize = UDim2.new(0.5, -4, 0, 48)
UIGridLayout.CellPadding = UDim2.new(0, 8, 0, 8)
UIGridLayout.FillDirectionMaxCells = 2
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

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "ToggleMenuBtn"
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(0, 20, 0, 20)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ToggleBtn.Text = ""
ToggleBtn.TextSize = 1
ToggleBtn.AutoButtonColor = false
ToggleBtn.Parent = ScreenGui
ToggleBtn.ZIndex = 100

Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 12)

local toggleStroke = Instance.new("UIStroke", ToggleBtn)
toggleStroke.Thickness = 3
toggleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
toggleStroke.Color = Color3.fromRGB(255, 0, 0)

local GLabel = Instance.new("TextLabel")
GLabel.Name = "GLabel"
GLabel.Size = UDim2.new(1, 0, 1, 0)
GLabel.Position = UDim2.new(0, 0, 0, 0)
GLabel.BackgroundTransparency = 1
GLabel.Text = "G"
GLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
GLabel.TextSize = 30
GLabel.Font = Enum.Font.GothamBlack
GLabel.TextXAlignment = Enum.TextXAlignment.Center
GLabel.TextYAlignment = Enum.TextYAlignment.Center
GLabel.Parent = ToggleBtn
GLabel.ZIndex = 101

local gStroke = Instance.new("UIStroke", GLabel)
gStroke.Thickness = 2
gStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
gStroke.Color = Color3.fromRGB(255, 0, 0)

task.spawn(function()
    local hue = 0
    while ToggleBtn and ToggleBtn.Parent do
        hue = (hue + 0.012) % 1
        local color = Color3.fromHSV(hue, 1, 1)
        toggleStroke.Color = color
        gStroke.Color = color
        task.wait(0.03)
    end
end)

local menuVisible = true
ToggleBtn.MouseButton1Click:Connect(function()
    menuVisible = not menuVisible
    MainFrame.Visible = menuVisible
end)

local toggleDragging = false
local toggleDragStart = nil
local toggleStartPos = nil

ToggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        toggleDragging = true
        toggleDragStart = input.Position
        toggleStartPos = ToggleBtn.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if toggleDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - toggleDragStart
        ToggleBtn.Position = UDim2.new(
            toggleStartPos.X.Scale, toggleStartPos.X.Offset + delta.X,
            toggleStartPos.Y.Scale, toggleStartPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        toggleDragging = false
    end
end)

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
