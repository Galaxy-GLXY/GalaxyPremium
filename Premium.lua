local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

-- [BIẾN HỆ THỐNG]
local PlayerGui = LP:WaitForChild("PlayerGui")
local G = Instance.new("ScreenGui")
G.Name = "GalaxyMini_"..math.random(1000,9999)
G.ResetOnSpawn = false 
G.Parent = PlayerGui

local SavedPosition = nil
local LoopTPActive = false 
local LoopSpeedConnection = nil 
local SpeedVal = 25 

-- [ANTI-KICK CƠ BẢN (Bypass Local Script Kick)]
local rawMetatable = getrawmetatable or debug.getmetatable
if rawMetatable then
    setreadonly(rawMetatable(game), false)
    local oldNamecall = rawMetatable(game).__namecall
    rawMetatable(game).__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "Kick" or method == "kick" then
            return nil -- Chặn gọi hàm Kick từ Client
        end
        return oldNamecall(self, ...)
    end)
    setreadonly(rawMetatable(game), true)
end

local function Notify(msg)
    pcall(function()
        StarterGui:SetCore("SendNotification", {Title = "GALAXY Mini", Text = msg, Duration = 3})
    end)
end

-- [GUI THIẾT KẾ]
local MainFrame = Instance.new("Frame", G); MainFrame.Size = UDim2.new(0, 200, 0, 220); MainFrame.Position = UDim2.new(0.5, -100, 0.3, 0); MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10); MainFrame.Active = true; MainFrame.Draggable = true
local Stroke = Instance.new("UIStroke", MainFrame); Stroke.Color = Color3.fromRGB(255, 0, 0); Stroke.Thickness = 2

local Title = Instance.new("TextLabel", MainFrame); Title.Size = UDim2.new(1, 0, 0, 40); Title.Text = "GALAXY Mini"; Title.TextColor3 = Color3.fromRGB(255,0,0); Title.BackgroundTransparency = 1; Title.Font = Enum.Font.GothamBold; Title.TextSize = 20
local CloseBtn = Instance.new("TextButton", MainFrame); CloseBtn.Size = UDim2.new(0, 40, 0, 40); CloseBtn.Position = UDim2.new(1, -40, 0, 0); CloseBtn.Text = "X"; CloseBtn.TextColor3 = Color3.fromRGB(255,0,0); CloseBtn.BackgroundColor3 = Color3.fromRGB(30,0,0); CloseBtn.Font = Enum.Font.SourceSansBold; CloseBtn.TextSize = 20

CloseBtn.MouseButton1Click:Connect(function() 
    LoopTPActive = false
    if LoopSpeedConnection then LoopSpeedConnection:Disconnect(); LoopSpeedConnection = nil end
    G:Destroy() 
end)

local function CreateBtn(name, y)
    local b = Instance.new("TextButton", MainFrame); b.Size = UDim2.new(1, -20, 0, 45); b.Position = UDim2.new(0, 10, 0, y); b.BackgroundColor3 = Color3.fromRGB(20,20,20); b.Text = name; b.TextColor3 = Color3.fromRGB(255,0,0); b.Font = Enum.Font.GothamBold; b.TextSize = 16
    Instance.new("UIStroke", b).Color = Color3.fromRGB(150,0,0)
    return b
end

local SaveBtn = CreateBtn("LƯU VỊ TRÍ", 50)
local FlyBtn = CreateBtn("TP", 100)

-- [Ô NHẬP TỐC ĐỘ]
local SpeedInput = Instance.new("TextBox", MainFrame)
SpeedInput.Size = UDim2.new(1, -20, 0, 45); SpeedInput.Position = UDim2.new(0, 10, 0, 155)
SpeedInput.BackgroundColor3 = Color3.fromRGB(20, 20, 20); SpeedInput.PlaceholderText = "Nhập tốc độ..."; SpeedInput.Text = tostring(SpeedVal)
SpeedInput.TextColor3 = Color3.fromRGB(255, 255, 255); SpeedInput.Font = Enum.Font.GothamBold; SpeedInput.TextSize = 18
Instance.new("UIStroke", SpeedInput).Color = Color3.fromRGB(150,0,0)

SpeedInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local val = tonumber(SpeedInput.Text)
        if val then 
            SpeedVal = val
            if SpeedVal <= 0 then
                Notify("Đã tắt Loop Speed (Dùng tốc độ gốc)")
            else
                Notify("Tốc độ mới: " .. val)
            end
        else 
            SpeedInput.Text = tostring(SpeedVal) 
        end
    end
end)

-- [CHỨC NĂNG - LƯU VỊ TRÍ]
SaveBtn.MouseButton1Click:Connect(function()
    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        SavedPosition = LP.Character.HumanoidRootPart.CFrame
        Notify("Đã lưu vị trí!")
    end
end)

-- [CHỨC NĂNG - LOOP TELEPORT (CHỐNG RESET)]
FlyBtn.MouseButton1Click:Connect(function()
    if LoopTPActive then 
        LoopTPActive = false
        FlyBtn.Text = "TP"
        FlyBtn.TextColor3 = Color3.fromRGB(255, 0, 0)
        
        -- Bật lại CanCollide khi Dừng TP
        if LP.Character then
            for _, part in ipairs(LP.Character:GetDescendants()) do 
                if part:IsA("BasePart") then part.CanCollide = true end 
            end
        end
        return 
    end
    
    if not SavedPosition then Notify("Chưa có vị trí!"); return end
    
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        LoopTPActive = true
        FlyBtn.Text = "DỪNG TP"
        FlyBtn.TextColor3 = Color3.fromRGB(0, 255, 0)
        
        task.spawn(function()
            while LoopTPActive do
                RS.Heartbeat:Wait()
                pcall(function()
                    local char = LP.Character
                    if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and SavedPosition then
                        local root = char.HumanoidRootPart
                        local hum = char.Humanoid
                        
                        if hum.Health > 0 then
                            root.AssemblyLinearVelocity = Vector3.zero
                            root.AssemblyAngularVelocity = Vector3.zero
                            root.CFrame = SavedPosition
                        end
                    end
                end)
            end
        end)
    end
end)

-- [CHỨC NĂNG - LOOP SPEED (CÓ ĐIỀU KIỆN 0)]
LoopSpeedConnection = RS.Heartbeat:Connect(function()
    pcall(function()
        -- Kiểm tra nếu SpeedVal > 0 mới can thiệp tốc độ
        if SpeedVal > 0 then
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
