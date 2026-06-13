local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

-- [BIẾN HỆ THỐNG]
local G = Instance.new("ScreenGui", LP:WaitForChild("PlayerGui")); G.Name = "GalaxyMini_"..math.random(1000,9999)
local SavedPosition = nil
local CurrentTween = nil
local SpeedVal = 25 

local function Notify(msg)
    StarterGui:SetCore("SendNotification", {Title = "GALAXY Mini", Text = msg, Duration = 3})
end

-- [GUI THIẾT KẾ - ĐÃ TĂNG KÍCH THƯỚC CHỮ]
local MainFrame = Instance.new("Frame", G); MainFrame.Size = UDim2.new(0, 200, 0, 220); MainFrame.Position = UDim2.new(0.5, -100, 0.3, 0); MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10); MainFrame.Active = true; MainFrame.Draggable = true
local Stroke = Instance.new("UIStroke", MainFrame); Stroke.Color = Color3.fromRGB(255, 0, 0); Stroke.Thickness = 2

-- Tiêu đề lớn hơn
local Title = Instance.new("TextLabel", MainFrame); Title.Size = UDim2.new(1, 0, 0, 40); Title.Text = "GALAXY Mini"; Title.TextColor3 = Color3.fromRGB(255,0,0); Title.BackgroundTransparency = 1; Title.Font = Enum.Font.GothamBold; Title.TextSize = 20
local CloseBtn = Instance.new("TextButton", MainFrame); CloseBtn.Size = UDim2.new(0, 40, 0, 40); CloseBtn.Position = UDim2.new(1, -40, 0, 0); CloseBtn.Text = "X"; CloseBtn.TextColor3 = Color3.fromRGB(255,0,0); CloseBtn.BackgroundColor3 = Color3.fromRGB(30,0,0); CloseBtn.Font = Enum.Font.SourceSansBold; CloseBtn.TextSize = 20
CloseBtn.MouseButton1Click:Connect(function() G:Destroy() end)

local function CreateBtn(name, y)
    local b = Instance.new("TextButton", MainFrame); b.Size = UDim2.new(1, -20, 0, 45); b.Position = UDim2.new(0, 10, 0, y); b.BackgroundColor3 = Color3.fromRGB(20,20,20); b.Text = name; b.TextColor3 = Color3.fromRGB(255,0,0); b.Font = Enum.Font.GothamBold; b.TextSize = 18
    Instance.new("UIStroke", b).Color = Color3.fromRGB(150,0,0)
    return b
end

local SaveBtn = CreateBtn("LƯU VỊ TRÍ", 50)
local FlyBtn = CreateBtn("BAY ĐẾN VỊ TRÍ", 100)

-- [Ô NHẬP TỐC ĐỘ LỚN HƠN]
local SpeedInput = Instance.new("TextBox", MainFrame)
SpeedInput.Size = UDim2.new(1, -20, 0, 45); SpeedInput.Position = UDim2.new(0, 10, 0, 155)
SpeedInput.BackgroundColor3 = Color3.fromRGB(20, 20, 20); SpeedInput.PlaceholderText = "Nhập tốc độ..."; SpeedInput.Text = tostring(SpeedVal)
SpeedInput.TextColor3 = Color3.fromRGB(255, 255, 255); SpeedInput.Font = Enum.Font.GothamBold; SpeedInput.TextSize = 18
Instance.new("UIStroke", SpeedInput).Color = Color3.fromRGB(150,0,0)

SpeedInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local val = tonumber(SpeedInput.Text)
        if val then SpeedVal = val; Notify("Tốc độ mới: " .. val) else SpeedInput.Text = tostring(SpeedVal) end
    end
end)

-- [CHỨC NĂNG]
SaveBtn.MouseButton1Click:Connect(function()
    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        SavedPosition = LP.Character.HumanoidRootPart.CFrame
        Notify("Đã lưu!")
    end
end)

FlyBtn.MouseButton1Click:Connect(function()
    if CurrentTween then CurrentTween:Cancel(); CurrentTween = nil; FlyBtn.Text = "BAY ĐẾN VỊ TRÍ"; return end
    if not SavedPosition then Notify("Chưa có vị trí!"); return end
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        for _, part in pairs(LP.Character:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end
        local dist = (hrp.Position - SavedPosition.Position).Magnitude
        CurrentTween = TS:Create(hrp, TweenInfo.new(dist/173, Enum.EasingStyle.Linear), {CFrame = SavedPosition})
        FlyBtn.Text = "DỪNG BAY"
        CurrentTween.Completed:Connect(function() 
            CurrentTween = nil; FlyBtn.Text = "BAY ĐẾN VỊ TRÍ"
            for _, part in pairs(LP.Character:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = true end end
        end)
        CurrentTween:Play()
    end
end)

RS.Heartbeat:Connect(function()
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        local hum = LP.Character.Humanoid
        local hrp = LP.Character.HumanoidRootPart
        hum.WalkSpeed = 16
        if hum.MoveDirection.Magnitude > 0 then
            hrp.AssemblyLinearVelocity = Vector3.new(hum.MoveDirection.X * SpeedVal, hrp.AssemblyLinearVelocity.Y, hum.MoveDirection.Z * SpeedVal)
        end
    end
end)
