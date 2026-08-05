local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("RunService")

_G.Active = true
_G.TargetName = ""
_G.Speed = 16
_G.LoopTP = false
_G.TPNearest = false
_G.ESP = false

for _, v in pairs(LP.PlayerGui:GetChildren()) do
    if v.Name:find("Galaxy") then v:Destroy() end
end

local G = Instance.new("ScreenGui")
G.Name = "Galaxy_"..math.random(1000,9999)
G.ResetOnSpawn = false
G.Parent = LP:WaitForChild("PlayerGui")

local NeonRed = Color3.fromRGB(255, 0, 0)

local Main = Instance.new("Frame", G)
Main.Visible = true
Main.Size = UDim2.new(0, 220, 0, 370)
Main.Position = UDim2.new(0.5, -110, 0.3, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.Active = true
Main.Draggable = true
Instance.new("UIStroke", Main).Color = NeonRed

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = NeonRed
Title.Text = "PLAYER TOOL"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16

local function GetPlayerSmart(name)
    if name == "" then return nil end
    name = name:lower()
    for _, v in pairs(Players:GetPlayers()) do
        if v.Name:lower():sub(1, #name) == name or v.DisplayName:lower():sub(1, #name) == name then return v end
    end
    return nil
end

local function GetNearestPlayer()
    local nearest = nil
    local shortestDistance = math.huge
    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        local myPos = LP.Character.HumanoidRootPart.Position
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character then
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hum and hum.Health > 0 and hrp then
                    local dist = (myPos - hrp.Position).Magnitude
                    if dist < shortestDistance then
                        shortestDistance = dist
                        nearest = p
                    end
                end
            end
        end
    end
    return nearest
end

local function AddBtn(n, y, c)
    local b = Instance.new("TextButton", Main)
    b.Size = UDim2.new(1, -20, 0, 42)
    b.Position = UDim2.new(0, 10, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    b.Text = n..": OFF"
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 14
    local s = false
    b.MouseButton1Click:Connect(function()
        s = not s
        b.Text = n..(s and ": ON" or ": OFF")
        b.TextColor3 = s and NeonRed or Color3.new(1, 1, 1)
        c(s)
    end)
end

local function applyEsp(player, character)
    if not character then return end
    local humanoid = character:WaitForChild("Humanoid", 10)
    local rootPart = character:WaitForChild("HumanoidRootPart", 10)
    if not humanoid or not rootPart then return end

    local highlight = character:FindFirstChild("EspBox") or Instance.new("Highlight")
    highlight.Name = "EspBox"
    highlight.FillTransparency = 1 
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0
    highlight.Adornee = character
    highlight.Enabled = _G.ESP
    highlight.Parent = character

    local bbGui = character:FindFirstChild("EspTextGui") or Instance.new("BillboardGui")
    bbGui.Name = "EspTextGui"
    bbGui.Size = UDim2.new(0, 200, 0, 60)
    bbGui.AlwaysOnTop = true
    bbGui.ExtentsOffset = Vector3.new(0, 3, 0)
    bbGui.Adornee = rootPart
    bbGui.Enabled = _G.ESP
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
    connection = RS.RenderStepped:Connect(function()
        if not character.Parent or not player.Parent or not _G.Active then
            if highlight then highlight:Destroy() end
            if bbGui then bbGui:Destroy() end
            connection:Disconnect()
            return
        end
        
        if _G.ESP and rootPart and humanoid and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
            local distance = math.floor((LP.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude)
            local hp = math.floor(humanoid.Health)
            infoLabel.Text = "Name: " .. tostring(player.Name) .. "\nHP: " .. tostring(hp) .. "\nDist: " .. tostring(distance) .. "m"
            highlight.Enabled = true
            bbGui.Enabled = true
            infoLabel.Visible = true
        else
            highlight.Enabled = false
            bbGui.Enabled = false
        end
    end)
end

local function createEsp(player)
    if player == LP then return end
    if player.Character then
        task.spawn(function() applyEsp(player, player.Character) end)
    end
    player.CharacterAdded:Connect(function(char)
        task.spawn(function() applyEsp(player, char) end)
    end)
end

for _, p in pairs(Players:GetPlayers()) do createEsp(p) end
Players.PlayerAdded:Connect(createEsp)

local NameBox = Instance.new("TextBox", Main)
NameBox.Size = UDim2.new(1, -20, 0, 40)
NameBox.Position = UDim2.new(0, 10, 0, 50)
NameBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
NameBox.PlaceholderText = "Target Name..."
NameBox.Text = ""
NameBox.TextColor3 = Color3.new(1, 1, 1)
NameBox.Font = Enum.Font.SourceSansBold
NameBox.TextSize = 14
Instance.new("UIStroke", NameBox).Color = NeonRed
NameBox.FocusLost:Connect(function()
    _G.TargetName = NameBox.Text
end)

AddBtn("LOOP TELEPORT", 100, function(v)
    _G.LoopTP = v
    task.spawn(function()
        while _G.LoopTP and _G.Active do
            task.wait()
            local t = GetPlayerSmart(_G.TargetName)
            if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                LP.Character.HumanoidRootPart.CFrame = t.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
            end
        end
    end)
end)

AddBtn("TP NEAREST PLAYER", 150, function(v)
    _G.TPNearest = v
    task.spawn(function()
        while _G.TPNearest and _G.Active do
            task.wait()
            local t = GetNearestPlayer()
            if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                LP.Character.HumanoidRootPart.CFrame = t.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
            end
        end
    end)
end)

AddBtn("ESP PLAYER", 200, function(v)
    _G.ESP = v
end)

local Inp = Instance.new("TextBox", Main)
Inp.Size = UDim2.new(1, -20, 0, 40)
Inp.Position = UDim2.new(0, 10, 0, 255)
Inp.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Inp.PlaceholderText = "SPEED..."
Inp.Text = "SPEED (16)"
Inp.TextColor3 = NeonRed
Inp.Font = Enum.Font.SourceSansBold
Inp.TextSize = 15
Instance.new("UIStroke", Inp).Color = NeonRed
Inp.FocusLost:Connect(function()
    local val = tonumber(Inp.Text)
    if val then
        _G.Speed = val
        Inp.Text = "SPEED ("..tostring(val)..")"
    else
        Inp.Text = "SPEED ("..tostring(_G.Speed)..")"
    end
end)

local Close = Instance.new("TextButton", Main)
Close.Size = UDim2.new(1, -20, 0, 38)
Close.Position = UDim2.new(0, 10, 0, 315)
Close.BackgroundColor3 = Color3.new(0.2, 0, 0)
Close.Text = "DESTROY SCRIPT"
Close.TextColor3 = Color3.new(1, 1, 1)
Close.Font = Enum.Font.SourceSansBold
Close.MouseButton1Click:Connect(function()
    _G.Active = false
    _G.ESP = false
    _G.LoopTP = false
    _G.TPNearest = false
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.WalkSpeed = 16
    end
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character then
            local box = p.Character:FindFirstChild("EspBox")
            local gui = p.Character:FindFirstChild("EspTextGui")
            if box then box:Destroy() end
            if gui then gui:Destroy() end
        end
    end
    G:Destroy()
end)

local ToggleBtn = Instance.new("TextButton", G)
ToggleBtn.Visible = true
ToggleBtn.Size = UDim2.new(0, 85, 0, 35)
ToggleBtn.Position = UDim2.new(0, 10, 0.5, 0)
ToggleBtn.BackgroundColor3 = Color3.new(0, 0, 0)
ToggleBtn.Text = "GALAXY"
ToggleBtn.TextColor3 = NeonRed
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 12
Instance.new("UIStroke", ToggleBtn).Color = NeonRed
ToggleBtn.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)

RS.Heartbeat:Connect(function()
    if not _G.Active then return end
    pcall(function()
        if LP.Character and LP.Character:FindFirstChild("Humanoid") then
            LP.Character.Humanoid.WalkSpeed = _G.Speed
        end
    end)
end)
