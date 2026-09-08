-- Target Safe Zone Coordinates
local FINAL_SAFE_ZONE = Vector3.new(549.39, 71.13, -365.50)

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

local BANNED_STATES = {
    [Enum.HumanoidStateType.Physics] = true,
}

pcall(function()
    if Enum.HumanoidStateType["FloatFormStanding"] then
        BANNED_STATES[Enum.HumanoidStateType["FloatFormStanding"]] = true
    end
end)

local function unblockHumanoid(humanoid)
    if not humanoid then return end
    
    if humanoid.PlatformStand then humanoid.PlatformStand = false end
    if humanoid.Sit then humanoid.Sit = false end

    -- Vô hiệu hóa các trạng thái gây ngã / ragdoll khi bị tấn công hoặc dính bẫy
    pcall(function()
        humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    end)
end

-- Hàm dọn dẹp và reset trạng thái an toàn
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
        end
    end
end

-- Monitor Loop (Giữ nhân vật luôn trong trạng thái chạy nhảy và chống ngắt quãng)
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
                
                -- Luôn ép nhân vật về trạng thái Running để không bị đứng hình khi tương tác/đánh
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
    -- Nếu đang chạy mà bấm lại thì sẽ TẮT NGAY LẬP TỨC
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

    -- Đổi giao diện nút thành trạng thái ĐANG CHẠY / CÓ THỂ TẮT
    StealButton.Text = "DỪNG LẠI"
    StealButton.TextColor3 = Color3.fromRGB(255, 69, 0)
    UIStroke.Color = Color3.fromRGB(255, 69, 0)

    -- Target safe zone với độ cao +10 Y
    local targetPosition = FINAL_SAFE_ZONE + Vector3.new(0, 10, 0)

    -- TẠO PART SÀN TÀNG HÌNH BÊN DƯỚI CHÂN
    groundPart = Instance.new("Part")
    groundPart.Name = "AntiCheatSafetyPlatform"
    groundPart.Size = Vector3.new(6, 1, 6)
    groundPart.Anchored = true
    groundPart.CanCollide = true
    groundPart.Transparency = 1
    groundPart.CFrame = hrp.CFrame - Vector3.new(0, 3.5, 0)
    groundPart.Parent = workspace

    humanoid.Sit = true
    humanoid:ChangeState(Enum.HumanoidStateType.Running)

    activeBV = Instance.new("BodyVelocity")
    activeBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    activeBV.Velocity = Vector3.zero
    activeBV.Parent = hrp

    activeBG = Instance.new("BodyGyro")
    activeBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    activeBG.P = 90000
    activeBG.CFrame = CFrame.lookAt(hrp.Position, Vector3.new(targetPosition.X, hrp.Position.Y, targetPosition.Z))
    activeBG.Parent = hrp

    local moveSpeed = 280
    local startTime = tick()
    local distance = (targetPosition - hrp.Position).Magnitude
    local estimatedTime = (distance / moveSpeed) + 0.4

    -- Step 1: Bay thẳng tới Safe Zone (+10 Y)
    while isStealing and character and hrp and humanoid.Health > 0 do
        humanoid.Sit = true
        humanoid:ChangeState(Enum.HumanoidStateType.Running)
        
        if groundPart then
            groundPart.CFrame = hrp.CFrame - Vector3.new(0, 3.5, 0)
        end

        local currentDist = (targetPosition - hrp.Position).Magnitude
        if currentDist <= 6 or (tick() - startTime) > estimatedTime then
            break
        end

        local currentDir = (targetPosition - hrp.Position).Unit
        activeBV.Velocity = currentDir * moveSpeed

        task.wait(0.015)
    end

    if activeBV then activeBV:Destroy(); activeBV = nil end
    if activeBG then activeBG:Destroy(); activeBG = nil end

    -- Step 2: Loop TP giữ vị trí tại Safe Zone (+10 Y) trong 2 giây
    local targetCFrame = CFrame.new(targetPosition)
    local tpEndTime = tick() + 2.0

    while isStealing and tick() < tpEndTime do
        local char = LocalPlayer.Character
        if char then
            local root = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if root and hum and hum.Health > 0 then
                hum.Sit = true
                hum:ChangeState(Enum.HumanoidStateType.Running)
                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
                root.CFrame = targetCFrame

                if groundPart then
                    groundPart.CFrame = targetCFrame - Vector3.new(0, 3.5, 0)
                end
            end
        end
        RunService.Heartbeat:Wait()
    end

    -- Hoàn tất quá trình và tự động trả về trạng thái ban đầu
    stopStealing()
end

StealButton.MouseButton1Click:Connect(triggerGroundVelocitySteal)
