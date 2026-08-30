local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")

-- [TẠO SCREEN GUI BAN ĐẦU]
local SelectorGui = Instance.new("ScreenGui")
SelectorGui.Name = "GalaxySelector_"..math.random(1000, 9999)
SelectorGui.ResetOnSpawn = false
SelectorGui.Parent = PlayerGui

-- [KHUNG NỀN CHÍNH - GIỮA MÀN HÌNH]
local MainFrame = Instance.new("Frame", SelectorGui)
MainFrame.Size = UDim2.new(0, 380, 0, 160)
MainFrame.Position = UDim2.new(0.5, -190, 0.5, -80) -- Căn chính giữa màn hình
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.Active = true
MainFrame.Draggable = true

-- Bo tròn góc khung nền
local FrameCorner = Instance.new("UICorner", MainFrame)
FrameCorner.CornerRadius = UDim.new(0, 12)

-- Viền ngoài màu trắng phát sáng
local FrameStroke = Instance.new("UIStroke", MainFrame)
FrameStroke.Color = Color3.fromRGB(255, 255, 255)
FrameStroke.Thickness = 2.5
FrameStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- [TIÊU ĐỀ]
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Position = UDim2.new(0, 0, 0, 5)
Title.Text = "GALAXY Bay/TP đến vị trí"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18

-- [KHUNG CHỨA 2 NÚT BẤM (SẮP XẾP TRÁI SANG PHẢI)]
local ButtonContainer = Instance.new("Frame", MainFrame)
ButtonContainer.Size = UDim2.new(1, -30, 0, 70)
ButtonContainer.Position = UDim2.new(0, 15, 0, 65)
ButtonContainer.BackgroundTransparency = 1

local UIListLayout = Instance.new("UIListLayout", ButtonContainer)
UIListLayout.FillDirection = Enum.FillDirection.Horizontal
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
UIListLayout.Padding = UDim.new(0, 15)

-- [HÀM TẠO NÚT BẤM CÓ BO GÓC VÀ VIỀN PHÁT SÁNG]
local function CreateOptionButton(text, color)
    local btn = Instance.new("TextButton", ButtonContainer)
    btn.Size = UDim2.new(0, 160, 0, 55)
    btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    btn.Text = text
    btn.TextColor3 = color
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 15

    -- Bo tròn góc cho nút
    local BtnCorner = Instance.new("UICorner", btn)
    BtnCorner.CornerRadius = UDim.new(0, 8)

    -- Viền phát sáng cho nút
    local BtnStroke = Instance.new("UIStroke", btn)
    BtnStroke.Color = color
    BtnStroke.Thickness = 2
    BtnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    return btn
end

-- [TẠO 2 NÚT TRÁI - PHẢI]
local FlyBtn = CreateOptionButton("LƯU & BAY", Color3.fromRGB(0, 150, 255)) -- Xanh dương
local TpBtn = CreateOptionButton("LƯU & TP", Color3.fromRGB(255, 50, 50))    -- Đỏ

-- [XỬ LÝ SỰ KIỆN KHI NHẤN NÚT]

-- 1. Nút LƯU & BAY
FlyBtn.MouseButton1Click:Connect(function()
    SelectorGui:Destroy() -- Tắt và xóa bảng chọn
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Galaxy-GLXY/GalaxyPremium/refs/heads/main/Premium1.lua"))()
end)

-- 2. Nút LƯU & TP
TpBtn.MouseButton1Click:Connect(function()
    SelectorGui:Destroy() -- Tắt và xóa bảng chọn
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Galaxy-GLXY/GalaxyPremium/refs/heads/main/Premium.lua"))()
end)
