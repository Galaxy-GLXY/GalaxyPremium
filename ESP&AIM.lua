local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

-- --- [[ TẠO MENU GIAO DIỆN CHÍNH ]] ---
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AimEspMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 180)
MainFrame.Position = UDim2.new(0.5, -110, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(255, 255, 255)
MainStroke.Thickness = 2
MainStroke.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.Text = "AIM & ESP SYSTEM"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.Parent = MainFrame

-- Nút bấm Aim Camera
local AimButton = Instance.new("TextButton")
AimButton.Size = UDim2.new(0, 180, 0, 35)
AimButton.Position = UDim2.new(0.5, -90, 0, 45)
AimButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
AimButton.Text = "AIM CAMERA: OFF"
AimButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AimButton.Font = Enum.Font.SourceSansBold
AimButton.TextSize = 14
AimButton.Parent = MainFrame
Instance.new("UICorner", AimButton).CornerRadius = UDim.new(0, 6)

-- Nút bấm ESP
local EspButton = Instance.new("TextButton")
EspButton.Size = UDim2.new(0, 180, 0, 35)
EspButton.Position = UDim2.new(0.5, -90, 0, 95)
EspButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
EspButton.Text = "ESP: OFF"
EspButton.TextColor3 = Color3.fromRGB(255, 255, 255)
EspButton.Font = Enum.Font.SourceSansBold
EspButton.TextSize = 14
EspButton.Parent = MainFrame
Instance.new("UICorner", EspButton).CornerRadius = UDim.new(0, 6)

-- Nút Thu nhỏ / Ẩn Menu
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 180, 0, 25)
MinimizeButton.Position = UDim2.new(0.5, -90, 0, 140)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MinimizeButton.Text = "ẨN MENU"
MinimizeButton.TextColor3 = Color3.fromRGB(200, 200, 200)
MinimizeButton.Font = Enum.Font.SourceSans
MinimizeButton.TextSize = 12
MinimizeButton.Parent = MainFrame
Instance.new("UICorner", MinimizeButton).CornerRadius = UDim.new(0, 4)

-- --- [[ LOGIC CẤU HÌNH CHỨC NĂNG ]] ---
local aimEnabled = false
local espEnabled = false
local FOV_RADIUS = 150

-- Tạo Vòng Tròn FOV
local FovCircle = Instance.new("ImageLabel")
FovCircle.Size = UDim2.new(0, FOV_RADIUS * 2, 0, FOV_RADIUS * 2)
FovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FovCircle.BackgroundTransparency = 1
FovCircle.Image = "rbxassetid://12502604677"
FovCircle.ImageColor3 = Color3.fromRGB(255, 255, 255)
FovCircle.Visible = false
FovCircle.Parent = ScreenGui

RunService.RenderStepped:Connect(function()
    FovCircle.Position = UDim2.new(0, Camera.ViewportSize.X / 2, 0, Camera.ViewportSize.Y / 2)
end)

-- Hàm kiểm tra xem mục tiêu có bị khuất sau tường/vật cản không
local function isVisible(targetPart, enemyCharacter)
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin)
    
    local raycastParams = RaycastParams.new()
    -- Bỏ qua nhân vật của chính mình và nhân vật của kẻ địch để tia kiểm tra va chạm chính xác vào tường
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, enemyCharacter}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.IgnoreWater = true
    
    local raycastResult = Workspace:Raycast(origin, direction, raycastParams)
    
    -- Nếu không chạm vào bất kỳ vật gì trên đường đi -> Không có vật cản (Nhìn thấy rõ)
    if not raycastResult then
        return true
    end
    return false -- Bị chặn bởi tường hoặc vật cản khác
end

-- Hàm tìm kẻ địch gần tâm màn hình nhất, nằm trong FOV và KHÔNG bị cản
local function getClosestPlayerInFOV()
    local closestPlayer = nil
    local shortestDistance = FOV_RADIUS

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChildOfClass("Humanoid") and player.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
            local head = player.Character.Head
            
            -- Bước 1: Kiểm tra xem có nằm trong vòng tròn FOV màn hình không
            local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
            if onScreen then
                local mousePos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                local playerPos = Vector2.new(screenPos.X, screenPos.Y)
                local distanceToCenter = (playerPos - mousePos).Magnitude

                if distanceToCenter < shortestDistance then
                    -- Bước 2: Cảm biến kiểm tra xem có bị chắn bởi tường/vật cản không
                    if isVisible(head, player.Character) then
                        shortestDistance = distanceToCenter
                        closestPlayer = player
                    end
                end
            end
        end
    end
    return closestPlayer
end

-- Vòng lặp khóa mục tiêu Camera
RunService.RenderStepped:Connect(function()
    if aimEnabled then
        local target = getClosestPlayerInFOV()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
        end
    end
end)

AimButton.MouseButton1Click:Connect(function()
    aimEnabled = not aimEnabled
    if aimEnabled then
        AimButton.Text = "AIM CAMERA: ON"
        AimButton.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
        FovCircle.Visible = true
    else
        AimButton.Text = "AIM CAMERA: OFF"
        AimButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        FovCircle.Visible = false
    end
end)

-- --- [[ LOGIC XỬ LÝ ESP TRẮNG CHUẨN ]] ---
local function createEsp(player)
    if player == LocalPlayer then return end

    local function applyEsp(character)
        if not character then return end
        local humanoid = character:WaitForChild("Humanoid", 10)
        local rootPart = character:WaitForChild("HumanoidRootPart", 10)
        if not humanoid or not rootPart then return end

        -- 1. Tạo viền Box Trắng quanh người
        local highlight = character:FindFirstChild("EspBox") or Instance.new("Highlight")
        highlight.Name = "EspBox"
        highlight.FillTransparency = 1 
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.OutlineTransparency = 0
        highlight.Adornee = character
        highlight.Enabled = espEnabled
        highlight.Parent = character

        -- 2. Tạo bảng hiển thị chữ (BillboardGui)
        local bbGui = character:FindFirstChild("EspTextGui") or Instance.new("BillboardGui")
        bbGui.Name = "EspTextGui"
        bbGui.Size = UDim2.new(0, 200, 0, 60)
        bbGui.AlwaysOnTop = true
        bbGui.ExtentsOffset = Vector3.new(0, 3, 0)
        bbGui.Adornee = rootPart
        bbGui.Enabled = espEnabled
        bbGui.Parent = character

        local infoLabel = bbGui:FindFirstChild("InfoLabel") or Instance.new("TextLabel")
        infoLabel.Name = "InfoLabel"
        infoLabel.Size = UDim2.new(1, 0, 1, 0)
        infoLabel.BackgroundTransparency = 1
        infoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        infoLabel.Font = Enum.Font.SourceSansBold
        infoLabel.TextSize = 13
        infoLabel.TextStrokeTransparency = 0
        infoLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        infoLabel.Text = "" 
        infoLabel.Parent = bbGui

        local connection
        connection = RunService.RenderStepped:Connect(function()
            if not character.Parent or not player.Parent then
                connection:Disconnect()
                return
            end
            
            if espEnabled and rootPart and humanoid and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local distance = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude)
                local hp = math.floor(humanoid.Health)
                infoLabel.Text = "Name: " .. tostring(player.Name) .. "\nHP: " .. tostring(hp) .. "\nDist: " .. tostring(distance) .. "m"
                bbGui.Enabled = true
                infoLabel.Visible = true
            else
                bbGui.Enabled = false
            end
        end)
    end

    if player.Character then applyEsp(player.Character) end
    player.CharacterAdded:Connect(applyEsp)
end

for _, p in pairs(Players:GetPlayers()) do createEsp(p) end
Players.PlayerAdded:Connect(createEsp)

EspButton.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    if espEnabled then
        EspButton.Text = "ESP: ON"
        EspButton.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
    else
        EspButton.Text = "ESP: OFF"
        EspButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            local box = player.Character:FindFirstChild("EspBox")
            local gui = player.Character:FindFirstChild("EspTextGui")
            if box then box.Enabled = espEnabled end
            if gui then gui.Enabled = espEnabled end
        end
    end
end)

-- --- [[ LOGIC DI CHUYỂN MENU & ẨN HIỆN ]] ---
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local minimized = false
MinimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        MainFrame:TweenSize(UDim2.new(0, 220, 0, 35), "Out", "Quad", 0.2, true)
        AimButton.Visible = false
        EspButton.Visible = false
        MinimizeButton.Text = "HIỆN MENU"
        MinimizeButton.Position = UDim2.new(0.5, -90, 0, 5)
        MinimizeButton.Size = UDim2.new(0, 180, 0, 25)
    else
        MainFrame:TweenSize(UDim2.new(0, 220, 0, 180), "Out", "Quad", 0.2, true)
        AimButton.Visible = true
        EspButton.Visible = true
        MinimizeButton.Text = "ẨN MENU"
        MinimizeButton.Position = UDim2.new(0.5, -90, 0, 140)
    end
end)
