if game.CoreGui:FindFirstChild("FloatMenu") then
    game.CoreGui.FloatMenu:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FloatMenu"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local FloatFrame = Instance.new("Frame")
FloatFrame.Name = "FloatFrame"
FloatFrame.Size = UDim2.new(0, 240, 0, 75)
FloatFrame.Position = UDim2.new(0.5, -120, 0.4, -37.5)
FloatFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
FloatFrame.BorderSizePixel = 0
FloatFrame.Active = true
FloatFrame.Draggable = true
FloatFrame.Parent = ScreenGui

local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(0, 22)
FloatCorner.Parent = FloatFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(255, 0, 0)
UIStroke.Thickness = 2.5
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke.Parent = FloatFrame

local FloatText = Instance.new("TextLabel")
FloatText.Size = UDim2.new(0, 90, 0, 40)
FloatText.Position = UDim2.new(0, 20, 0.5, -15)
FloatText.BackgroundTransparency = 1
FloatText.Text = "Float"
FloatText.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatText.TextSize = 26
FloatText.Font = Enum.Font.FredokaOne
FloatText.TextXAlignment = Enum.TextXAlignment.Left
FloatText.Parent = FloatFrame

local TextStroke = Instance.new("UIStroke")
TextStroke.Color = Color3.fromRGB(255, 0, 0)
TextStroke.Thickness = 2
TextStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
TextStroke.Parent = FloatText

local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0, 85, 0, 36)
ToggleButton.Position = UDim2.new(0, 110, 0.5, -13)
ToggleButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
ToggleButton.Text = "OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 15
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Parent = FloatFrame

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 10)
ToggleCorner.Parent = ToggleButton

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 24, 0, 24)
CloseButton.Position = UDim2.new(1, -32, 0, 10)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 70, 70)
CloseButton.TextSize = 18
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = FloatFrame

local LocalPlayer = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local floating = false
local floatPart = nil
local floatConnection = nil

local function toggleFloat()
    floating = not floating
    if floating then
        ToggleButton.Text = "ON"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            floatPart = Instance.new("Part")
            floatPart.Size = Vector3.new(6, 0.5, 6)
            floatPart.Transparency = 1
            floatPart.Anchored = true
            floatPart.Parent = workspace
            floatConnection = RunService.RenderStepped:Connect(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and floatPart then
                    local rootPart = LocalPlayer.Character.HumanoidRootPart
                    floatPart.CFrame = CFrame.new(rootPart.Position.X, rootPart.Position.Y - 3.25, rootPart.Position.Z)
                end
            end)
        end
    else
        ToggleButton.Text = "OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        if floatConnection then
            floatConnection:Disconnect()
            floatConnection = nil
        end
        if floatPart then
            floatPart:Destroy()
            floatPart = nil
        end
    end
end

ToggleButton.MouseButton1Click:Connect(toggleFloat)

CloseButton.MouseButton1Click:Connect(function()
    if floating then
        toggleFloat()
    end
    ScreenGui:Destroy()
end)
