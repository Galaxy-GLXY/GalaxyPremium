local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local TS = game:GetService("TweenService")
local RS = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

-- [BIẾN HỆ THỐNG]
local TargetPosition = nil
local IsFlying = false
local TweenTrack = nil

local LoopSpeedConnection = nil 
local SpeedVal = 25 -- Tốc độ chạy mặc định

local PlayerGui = LP:WaitForChild("PlayerGui")
local G = Instance.new("ScreenGui")
G.Name = "GalaxyFlyTarget_"..math.random(1000,9999)
G.ResetOnSpawn = false 
G.Parent = PlayerGui

local function Notify(msg)
    pcall(function()
        StarterGui:SetCore("SendNotification", {Title = "GALAXY FLY", Text = msg, Duration = 3})
    end)
end

-- [GUI THIẾT KẾ]
local MainFrame = Instance.new("Frame", G)
MainFrame.Size = UDim2.new(0, 200, 0, 215)
MainFrame.Position = UDim2.new(0.5, 110, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.Active = true
MainFrame.Draggable = true
local Stroke = Instance.new("UIStroke", MainFrame); Stroke.Color = Color3.fromRGB(0, 150, 255); Stroke.Thickness = 2

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "BAY ĐẾN ĐIỂM"
Title.TextColor3 = Color3.fromRGB(0, 150, 255)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18

local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -35, 0, 0)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(30, 0, 0)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 18

CloseBtn.MouseButton1Click:Connect(function() 
    IsFlying = false
    if TweenTrack then TweenTrack:Cancel() end
    if LoopSpeedConnection then LoopSpeedConnection:Disconnect(); LoopSpeedConnection = nil end
    G:Destroy() 
end)

local function CreateBtn(name, y, color)
    local b = Instance.new("TextButton", MainFrame)
    b.Size = UDim2.new(1, -20, 0, 40)
    b.Position = UDim2.new(0, 10, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    b.Text = name
    b.TextColor3 = color
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    Instance.new("UIStroke", b).Color = color
    return b
end

local SetPosBtn = CreateBtn("1. ĐẶT VỊ TRÍ", 45, Color3.fromRGB(0, 200, 255))
local FlyToPosBtn = CreateBtn("2. BAY ĐẾN VỊ TRÍ", 90, Color3.fromRGB(255, 200, 0))

-- [Ô NHẬP TỐC ĐỘ DI CHUYỂN (LOOP SPEED)]
local SpeedInput = Instance.new("TextBox", MainFrame)
SpeedInput.Size = UDim2.new(1, -20, 0, 40)
SpeedInput.Position = UDim2.new(0, 10, 0, 135)
SpeedInput.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
SpeedInput.PlaceholderText = "Nhập tốc độ..."
SpeedInput.Text = tostring(SpeedVal)
SpeedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedInput.Font = Enum.Font.GothamBold
SpeedInput.TextSize = 16
Instance.new("UIStroke", SpeedInput).Color = Color3.fromRGB(0, 150, 255)

SpeedInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local val = tonumber(SpeedInput.Text)
        if val then 
            SpeedVal = val
            if SpeedVal <= 0 then
                Notify("Đã tắt Loop Speed (Dùng tốc độ gốc)")
            else
                Notify("Tốc độ di chuyển mới: " .. val)
            end
        else 
            SpeedInput.Text = tostring(SpeedVal) 
        end
    end
end)

-- [NÚT 1: ĐẶT VỊ TRÍ]
SetPosBtn.MouseButton1Click:Connect(function()
    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        TargetPosition = LP.Character.HumanoidRootPart.CFrame
        Notify("Đã đặt vị trí đích thành công!")
    else
        Notify("Không thể lấy vị trí nhân vật!")
    end
end)

-- [NÚT 2: BAY TỐC ĐỘ CAO ĐẾN VỊ TRÍ 1 - CHỐNG GIẬT LẠI]
FlyToPosBtn.MouseButton1Click:Connect(function()
    if IsFlying then
        IsFlying = false
        if TweenTrack then TweenTrack:Cancel() end
        FlyToPosBtn.Text = "2. BAY ĐẾN VỊ TRÍ"
        FlyToPosBtn.TextColor3 = Color3.fromRGB(255, 200, 0)
        Notify("Đã hủy bay!")
        return
    end

    if not TargetPosition then
        Notify("Chưa nhấn [1. ĐẶT VỊ TRÍ]!")
        return
    end

    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")

    if hrp and hum and hum.Health > 0 then
        IsFlying = true
        FlyToPosBtn.Text = "DỪNG BAY"
        FlyToPosBtn.TextColor3 = Color3.fromRGB(255, 0, 0)

        -- Tốc độ bay cố định cực nhanh (300 studs/s)
        local distance = (hrp.Position - TargetPosition.Position).Magnitude
        local flySpeed = 1000 
        local duration = math.max(distance / flySpeed, 0.1)

        -- Chuyển trạng thái Physics để không bị Server giật lại khi bay nhanh
        hum:ChangeState(Enum.HumanoidStateType.Physics)

        local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
        TweenTrack = TS:Create(hrp, tweenInfo, {CFrame = TargetPosition})

        -- Vòng lặp Noclip và khóa vận tốc khi đang bay
        local flyLoop
        flyLoop = RS.Stepped:Connect(function()
            if IsFlying and char and hrp then
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
                
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then 
                        part.CanCollide = false 
                    end
                end
            else
                flyLoop:Disconnect()
            end
        end)

        TweenTrack:Play()

        TweenTrack.Completed:Connect(function()
            IsFlying = false
            FlyToPosBtn.Text = "2. BAY ĐẾN VỊ TRÍ"
            FlyToPosBtn.TextColor3 = Color3.fromRGB(255, 200, 0)
            
            if char and hrp and hum then
                hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
                
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then 
                        part.CanCollide = true 
                    end
                end
            end
            Notify("Đã đến vị trí!")
        end)
    end
end)

-- [CHỨC NĂNG - LOOP SPEED DI CHUYỂN (TỰ ĐỘNG CHẠY BẰNG BÀN PHÍM)]
LoopSpeedConnection = RS.Heartbeat:Connect(function()
    pcall(function()
        -- Chỉ kích hoạt tăng tốc di chuyển khi SpeedVal > 0 và không trong trạng thái bay
        if SpeedVal > 0 and not IsFlying then
            if LP.Character and LP.Character:FindFirstChild("Humanoid") and LP.Character:FindFirstChild("HumanoidRootPart") then
                local hum = LP.Character.Humanoid
                local hrp = LP.Character.HumanoidRootPart
                
                if hum.Health > 0 and hum.MoveDirection.Magnitude > 0 then
                    local currentY = hrp.AssemblyLinearVelocity.Y
                    local moveDir = hum.MoveDirection * SpeedVal
                    hrp.AssemblyLinearVelocity = Vector3.new(moveDir.X, currentY, moveDir.Z)
                end
            end
        end
    end)
end)
