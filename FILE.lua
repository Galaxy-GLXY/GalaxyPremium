local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local TS = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

local SavedPosition = nil
local CurrentTween = nil

-- Hàm hiển thị thông báo
local function Notify(msg)
    StarterGui:SetCore("SendNotification", {
        Title = "GALAXY SYSTEM",
        Text = msg,
        Duration = 3
    })
end

-- Tạo GUI (Tông màu đen chủ đạo, viền đỏ Neon)
local Screen = Instance.new("ScreenGui", LP:WaitForChild("PlayerGui"))
Screen.Name = "GalaxyMini"

local MainFrame = Instance.new("Frame", Screen)
MainFrame.Size = UDim2.new(0, 160, 0, 110)
MainFrame.Position = UDim2.new(0.5, -80, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10) -- Màu đen
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Cho phép di chuyển menu

local FrameStroke = Instance.new("UIStroke", MainFrame)
FrameStroke.Color = Color3.fromRGB(255, 0, 0) -- Viền đỏ
FrameStroke.Thickness = 2

-- Hàm tạo nút phong cách Neon Red
local function CreateButton(text, pos)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 0, 0) -- Chữ màu đỏ
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 16
    
    local txtStroke = Instance.new("UIStroke", btn) -- Làm chữ phát sáng
    txtStroke.Color = Color3.fromRGB(150, 0, 0)
    txtStroke.Thickness = 1
    
    return btn
end

local SaveBtn = CreateButton("LƯU VỊ TRÍ", UDim2.new(0, 5, 0, 10))
local FlyBtn = CreateButton("BAY ĐẾN VỊ TRÍ", UDim2.new(0, 5, 0, 60))

-- XỬ LÝ CHỨC NĂNG
SaveBtn.MouseButton1Click:Connect(function()
    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        SavedPosition = LP.Character.HumanoidRootPart.CFrame
        Notify("Lưu vị trí thành công!")
    end
end)

FlyBtn.MouseButton1Click:Connect(function()
    if CurrentTween then 
        CurrentTween:Cancel()
        CurrentTween = nil
        FlyBtn.Text = "BAY ĐẾN VỊ TRÍ"
        Notify("Đã dừng bay!")
        return 
    end
    
    if not SavedPosition then Notify("Chưa có vị trí lưu!"); return end
    
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        -- Vô hiệu hóa va chạm để xuyên tường
        for _, part in pairs(LP.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
        
        local distance = (hrp.Position - SavedPosition.Position).Magnitude
        local speed = 200 -- Tốc độ stud/s
        local time = distance / speed
        
        FlyBtn.Text = "DỪNG BAY"
        local info = TweenInfo.new(time, Enum.EasingStyle.Linear)
        CurrentTween = TS:Create(hrp, info, {CFrame = SavedPosition})
        
        CurrentTween.Completed:Connect(function()
            CurrentTween = nil
            FlyBtn.Text = "BAY ĐẾN VỊ TRÍ"
            for _, part in pairs(LP.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end)
        
        CurrentTween:Play()
        Notify("Đang bay đến vị trí...")
    end
end)
