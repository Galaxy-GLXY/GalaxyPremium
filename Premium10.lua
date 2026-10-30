local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("RunService")
local VIM = game:GetService("VirtualInputManager")
local TS = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local HttpService = game:GetService("HttpService")

for _, v in pairs(LP.PlayerGui:GetChildren()) do
    if v.Name:find("Galaxy") then v:Destroy() end
end

local ConfigFileName = "GALAXY_PREMIUM_CONFIG.json"
local Config = {
    MainPos = {0.5, -200, 0.3, 0},
    SubMenuPos = {0.5, 205, 0.3, 0},
    TPMenuPos = {0.5, 205, 0.52, 0},
    VoidMenuPos = {0.5, 205, 0.74, 0},
    Speed = 16,
    Aim = false,
    Fly = false,
    ESP = false,
    TPNearest = false,
    PlayerTool = false,
    VoidActive = false,
    LoopTP = false,
    Bring = false,
    VoidPanelOpen = false,
    PlayerPanelOpen = false,
    NearestPanelOpen = false
}

local function SaveConfig()
    pcall(function()
        if writefile then
            local data = HttpService:JSONEncode(Config)
            writefile(ConfigFileName, data)
        end
    end)
end

local function LoadConfig()
    pcall(function()
        if readfile and isfile and isfile(ConfigFileName) then
            local content = readfile(ConfigFileName)
            local data = HttpService:JSONDecode(content)
            for k, v in pairs(data) do
                Config[k] = v
            end
        end
    end)
end

LoadConfig()

local function ApplyFFlags()
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    end)
    Lighting.GlobalShadows = false
    Lighting.OutdoorAmbient = Color3.fromRGB(100, 100, 100)
    Lighting.ExposureCompensation = -0.5
    Lighting.FogEnd = 9e9
    local function Optimize(obj)
        if obj:IsA("BasePart") or obj:IsA("MeshPart") then
            obj.Material = Enum.Material.SmoothPlastic
            obj.CastShadow = false
            if obj.Name:lower():find("effect") or (obj.Parent and obj.Parent.Name:lower():find("fx")) then
                obj.Transparency = 0.7
            end
        end
        if obj:IsA("Decal") or obj:IsA("Texture") then obj:Destroy() end
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Explosion") then
            obj.Enabled = false
        end
    end
    for _, v in pairs(workspace:GetDescendants()) do Optimize(v) end
    workspace.DescendantAdded:Connect(Optimize)
end

local G = Instance.new("ScreenGui")
G.Name = "Galaxy_"..math.random(1000,9999)
G.ResetOnSpawn = false
G.Parent = LP:WaitForChild("PlayerGui")

local NeonRed = Color3.fromRGB(255, 0, 0)

_G.Active = true
_G.TargetName = "" 
_G.Speed = Config.Speed 
_G.Fly = false 
_G.TPNearest = false 
_G.Aim = false 
_G.ESP = false
_G.LoopTP = false 
_G.Bring = false 
_G.VoidActive = false

local LastPosBeforeVoid = nil
local CurrentVoidPlate = nil

local function GiveNoclip()
    if not _G.Active then return end
    local Tool = Instance.new("Tool")
    Tool.Name = "Noclip"
    Tool.RequiresHandle = false
    Tool.CanBeDropped = false
    Tool.ToolTip = "Cầm trên tay để đi xuyên tường"
    Tool.Parent = LP:WaitForChild("Backpack")
end

local steppedConnection = RS.Stepped:Connect(function()
    if _G.Active and LP.Character then
        if LP.Character:FindFirstChild("Noclip") then
            for _, part in pairs(LP.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end
end)

local charAddedConnection = LP.CharacterAdded:Connect(function()
    task.wait(0.5)
    GiveNoclip()
end)

local introFinished = false

local function StartIntro()
    local Overlay = Instance.new("Frame", G); Overlay.Size = UDim2.new(1, 0, 1, 0); Overlay.BackgroundColor3 = Color3.new(0, 0, 0); Overlay.BackgroundTransparency = 1; Overlay.ZIndex = 100
    local IntroBox = Instance.new("Frame", Overlay); IntroBox.Size = UDim2.new(0, 400, 0, 100); IntroBox.Position = UDim2.new(0.5, -200, 0.5, -50); IntroBox.BackgroundColor3 = Color3.fromRGB(10, 10, 10); IntroBox.BackgroundTransparency = 1
    local BoxStroke = Instance.new("UIStroke", IntroBox); BoxStroke.Color = NeonRed; BoxStroke.Thickness = 2; BoxStroke.Transparency = 1
    local IntroText = Instance.new("TextLabel", IntroBox); IntroText.Size = UDim2.new(1, 0, 1, 0); IntroText.BackgroundTransparency = 1; IntroText.Text = "GALAXY Premium Loading..."; IntroText.TextColor3 = NeonRed; IntroText.Font = Enum.Font.SourceSansBold; IntroText.TextSize = 25; IntroText.TextTransparency = 1
    TS:Create(Overlay, TweenInfo.new(0.5), {BackgroundTransparency = 0.4}):Play()
    task.wait(0.5)
    TS:Create(IntroBox, TweenInfo.new(0.8), {BackgroundTransparency = 0.2}):Play()
    TS:Create(BoxStroke, TweenInfo.new(0.8), {Transparency = 0}):Play()
    TS:Create(IntroText, TweenInfo.new(0.8), {TextTransparency = 0}):Play()
    task.wait(2.2)
    TS:Create(Overlay, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    TS:Create(IntroBox, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    TS:Create(BoxStroke, TweenInfo.new(0.5), {Transparency = 1}):Play()
    TS:Create(IntroText, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
    task.wait(0.6); Overlay:Destroy()
    ApplyFFlags()
    GiveNoclip()
    introFinished = true
end

local Main = Instance.new("Frame", G)
Main.Visible = false
Main.Size = UDim2.new(0, 400, 0, 275)
Main.Position = UDim2.new(Config.MainPos[1], Config.MainPos[2], Config.MainPos[3], Config.MainPos[4])
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
local MainRainbowStroke = Instance.new("UIStroke", Main)
MainRainbowStroke.Thickness = 3

Main:GetPropertyChangedSignal("Position"):Connect(function()
    Config.MainPos = {Main.Position.X.Scale, Main.Position.X.Offset, Main.Position.Y.Scale, Main.Position.Y.Offset}
    SaveConfig()
end)

task.spawn(function()
    local hue = 0
    while Main and Main.Parent do
        hue = (hue + 0.005) % 1
        MainRainbowStroke.Color = Color3.fromHSV(hue, 1, 1)
        task.wait(0.03)
    end
end)

local SubMenu = Instance.new("Frame", G)
SubMenu.Visible = Config.PlayerPanelOpen
SubMenu.Size = UDim2.new(0, 200, 0, 185)
SubMenu.Position = UDim2.new(Config.SubMenuPos[1], Config.SubMenuPos[2], Config.SubMenuPos[3], Config.SubMenuPos[4])
SubMenu.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
SubMenu.Active = true
SubMenu.Draggable = true
Instance.new("UICorner", SubMenu).CornerRadius = UDim.new(0, 10)
local SubRainbowStroke = Instance.new("UIStroke", SubMenu)
SubRainbowStroke.Thickness = 3

SubMenu:GetPropertyChangedSignal("Position"):Connect(function()
    Config.SubMenuPos = {SubMenu.Position.X.Scale, SubMenu.Position.X.Offset, SubMenu.Position.Y.Scale, SubMenu.Position.Y.Offset}
    SaveConfig()
end)

task.spawn(function()
    local hue = 0
    while SubMenu and SubMenu.Parent do
        hue = (hue + 0.005) % 1
        SubRainbowStroke.Color = Color3.fromHSV(hue, 1, 1)
        task.wait(0.03)
    end
end)

local TPMenu = Instance.new("Frame", G)
TPMenu.Visible = Config.NearestPanelOpen
TPMenu.Size = UDim2.new(0, 200, 0, 100)
TPMenu.Position = UDim2.new(Config.TPMenuPos[1], Config.TPMenuPos[2], Config.TPMenuPos[3], Config.TPMenuPos[4])
TPMenu.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
TPMenu.Active = true
TPMenu.Draggable = true
Instance.new("UICorner", TPMenu).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", TPMenu).Color = NeonRed

TPMenu:GetPropertyChangedSignal("Position"):Connect(function()
    Config.TPMenuPos = {TPMenu.Position.X.Scale, TPMenu.Position.X.Offset, TPMenu.Position.Y.Scale, TPMenu.Position.Y.Offset}
    SaveConfig()
end)

local VoidMenu = Instance.new("Frame", G)
VoidMenu.Visible = Config.VoidPanelOpen
VoidMenu.Size = UDim2.new(0, 200, 0, 100)
VoidMenu.Position = UDim2.new(Config.VoidMenuPos[1], Config.VoidMenuPos[2], Config.VoidMenuPos[3], Config.VoidMenuPos[4])
VoidMenu.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
VoidMenu.Active = true
VoidMenu.Draggable = true
Instance.new("UICorner", VoidMenu).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", VoidMenu).Color = NeonRed

VoidMenu:GetPropertyChangedSignal("Position"):Connect(function()
    Config.VoidMenuPos = {VoidMenu.Position.X.Scale, VoidMenu.Position.X.Offset, VoidMenu.Position.Y.Scale, VoidMenu.Position.Y.Offset}
    SaveConfig()
end)

local function CreateTitle(p, txt)
    local T = Instance.new("TextLabel", p)
    T.Size = UDim2.new(1, 0, 0, 32)
    T.BackgroundColor3 = NeonRed
    T.Text = txt
    T.TextColor3 = Color3.new(1,1,1)
    T.Font = Enum.Font.SourceSansBold
    T.TextSize = 14
    Instance.new("UICorner", T).CornerRadius = UDim.new(0, 10)
end

CreateTitle(Main, "GALAXY Premium")
CreateTitle(SubMenu, "PLAYER TOOL")
CreateTitle(TPMenu, "TP NEAREST TOOL")
CreateTitle(VoidMenu, "TP TO VOID TOOL")

local LeftContainer = Instance.new("Frame", Main)
LeftContainer.Size = UDim2.new(0, 115, 1, -72)
LeftContainer.Position = UDim2.new(0, 8, 0, 38)
LeftContainer.BackgroundTransparency = 1

local Inp = Instance.new("TextBox", LeftContainer)
Inp.Size = UDim2.new(1, 0, 0, 38)
Inp.Position = UDim2.new(0, 0, 0, 8)
Inp.BackgroundColor3 = Color3.fromRGB(30,30,30)
Inp.PlaceholderText = "TỐC ĐỘ..."
Inp.Text = "TỐC ĐỘ ("..tostring(Config.Speed)..")"
Inp.TextColor3 = NeonRed
Inp.Font = Enum.Font.SourceSansBold
Inp.TextSize = 13
Instance.new("UIStroke", Inp).Color = NeonRed
Instance.new("UICorner", Inp).CornerRadius = UDim.new(0, 6)

Inp.FocusLost:Connect(function(enterPressed)
    local val = tonumber(Inp.Text)
    if val then
        _G.Speed = val
        Config.Speed = val
        SaveConfig()
        Inp.Text = "TỐC ĐỘ ("..tostring(val)..")"
    else
        Inp.Text = "TỐC ĐỘ ("..tostring(_G.Speed)..")"
    end
end)

local RightContainer = Instance.new("Frame", Main)
RightContainer.Size = UDim2.new(0, 260, 1, -72)
RightContainer.Position = UDim2.new(0, 130, 0, 38)
RightContainer.BackgroundTransparency = 1

local function AddMainBtn(n, y, initialState, c)
    local b = Instance.new("TextButton", RightContainer)
    b.Size = UDim2.new(1, 0, 0, 31)
    b.Position = UDim2.new(0, 0, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(30,30,30)
    b.Text = n..(initialState and ": ON" or ": OFF")
    b.TextColor3 = initialState and NeonRed or Color3.new(1,1,1)
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 13
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", b).Color = Color3.fromRGB(50,50,50)
    
    local s = initialState
    b.MouseButton1Click:Connect(function()
        s = not s
        b.Text = n..(s and ": ON" or ": OFF")
        b.TextColor3 = s and NeonRed or Color3.new(1,1,1)
        c(s)
    end)
    return b
end

AddMainBtn("SMART AIM", 0, Config.Aim, function(v) _G.Aim = v Config.Aim = v SaveConfig() end)
AddMainBtn("FLY MODE", 35, Config.Fly, function(v) _G.Fly = v Config.Fly = v SaveConfig() end)
AddMainBtn("PLAYER ESP", 70, Config.ESP, function(v) _G.ESP = v Config.ESP = v SaveConfig() end)
AddMainBtn("PLAYER NEAREST", 105, Config.NearestPanelOpen, function(v) 
    TPMenu.Visible = v 
    Config.NearestPanelOpen = v 
    SaveConfig() 
end)
AddMainBtn("PLAYER TOOL", 140, Config.PlayerPanelOpen, function(v) 
    SubMenu.Visible = v 
    Config.PlayerPanelOpen = v 
    SaveConfig() 
end)
AddMainBtn("TP TO VOID", 175, Config.VoidPanelOpen, function(v) 
    VoidMenu.Visible = v 
    Config.VoidPanelOpen = v 
    SaveConfig() 
end)

local Close = Instance.new("TextButton", Main)
Close.Size = UDim2.new(1, -16, 0, 28)
Close.Position = UDim2.new(0, 8, 1, -32)
Close.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
Close.Text = "HỦY SCRIPT"
Close.TextColor3 = Color3.new(1,1,1)
Close.Font = Enum.Font.SourceSansBold
Close.TextSize = 13
Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 6)

local NameBox = Instance.new("TextBox", SubMenu)
NameBox.Size = UDim2.new(1, -16, 0, 32)
NameBox.Position = UDim2.new(0, 8, 0, 38)
NameBox.BackgroundColor3 = Color3.fromRGB(30,30,30)
NameBox.PlaceholderText = "Tên người chơi..."
NameBox.Text = ""
NameBox.TextColor3 = Color3.new(1,1,1)
NameBox.Font = Enum.Font.SourceSansBold
NameBox.TextSize = 12
Instance.new("UIStroke", NameBox).Color = NeonRed
Instance.new("UICorner", NameBox).CornerRadius = UDim.new(0, 6)
NameBox.FocusLost:Connect(function() _G.TargetName = NameBox.Text end)

local function AddSubBtn(n, y, initialState, c)
    local b = Instance.new("TextButton", SubMenu)
    b.Size = UDim2.new(1, -16, 0, 38)
    b.Position = UDim2.new(0, 8, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(30,30,30)
    b.Text = n..(initialState and ": ON" or ": OFF")
    b.TextColor3 = initialState and NeonRed or Color3.new(1,1,1)
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 13
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", b).Color = Color3.fromRGB(50,50,50)
    
    local s = initialState
    b.MouseButton1Click:Connect(function()
        s = not s
        b.Text = n..(s and ": ON" or ": OFF")
        b.TextColor3 = s and NeonRed or Color3.new(1,1,1)
        c(s)
    end)
end

AddSubBtn("LOOP TELEPORT", 75, Config.LoopTP, function(v) _G.LoopTP = v Config.LoopTP = v SaveConfig() end)
AddSubBtn("BRING PLAYER", 118, Config.Bring, function(v) _G.Bring = v Config.Bring = v SaveConfig() end)

local TPBtnInMenu = Instance.new("TextButton", TPMenu)
TPBtnInMenu.Size = UDim2.new(1, -16, 0, 38)
TPBtnInMenu.Position = UDim2.new(0, 8, 0, 45)
TPBtnInMenu.BackgroundColor3 = Color3.fromRGB(30,30,30)
TPBtnInMenu.Text = "TP NEAREST: "..(Config.TPNearest and "ON" or "OFF")
TPBtnInMenu.TextColor3 = Config.TPNearest and NeonRed or Color3.new(1,1,1)
TPBtnInMenu.Font = Enum.Font.SourceSansBold
TPBtnInMenu.TextSize = 13
Instance.new("UICorner", TPBtnInMenu).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", TPBtnInMenu).Color = Color3.fromRGB(50,50,50)

TPBtnInMenu.MouseButton1Click:Connect(function()
    Config.TPNearest = not Config.TPNearest
    _G.TPNearest = Config.TPNearest
    SaveConfig()
    TPBtnInMenu.Text = "TP NEAREST: " .. (Config.TPNearest and "ON" or "OFF")
    TPBtnInMenu.TextColor3 = Config.TPNearest and NeonRed or Color3.new(1,1,1)
end)

local VoidBtnInMenu = Instance.new("TextButton", VoidMenu)
VoidBtnInMenu.Size = UDim2.new(1, -16, 0, 38)
VoidBtnInMenu.Position = UDim2.new(0, 8, 0, 45)
VoidBtnInMenu.BackgroundColor3 = Color3.fromRGB(30,30,30)
VoidBtnInMenu.Text = "TP TO VOID: "..(Config.VoidActive and "ON" or "OFF")
VoidBtnInMenu.TextColor3 = Config.VoidActive and NeonRed or Color3.new(1,1,1)
VoidBtnInMenu.Font = Enum.Font.SourceSansBold
VoidBtnInMenu.TextSize = 13
Instance.new("UICorner", VoidBtnInMenu).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", VoidBtnInMenu).Color = Color3.fromRGB(50,50,50)

VoidBtnInMenu.MouseButton1Click:Connect(function()
    Config.VoidActive = not Config.VoidActive
    _G.VoidActive = Config.VoidActive
    SaveConfig()
    VoidBtnInMenu.Text = "TP TO VOID: " .. (Config.VoidActive and "ON" or "OFF")
    VoidBtnInMenu.TextColor3 = Config.VoidActive and NeonRed or Color3.new(1,1,1)
    
    if Config.VoidActive and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then 
        LastPosBeforeVoid = LP.Character.HumanoidRootPart.CFrame
        if not CurrentVoidPlate then
            CurrentVoidPlate = Instance.new("Part", workspace); CurrentVoidPlate.Name = "Galaxy_Void"; CurrentVoidPlate.Size = Vector3.new(2048, 1, 2048); CurrentVoidPlate.Anchored = true; CurrentVoidPlate.Transparency = 0.5; CurrentVoidPlate.Color = NeonRed; CurrentVoidPlate.Material = Enum.Material.ForceField
        end
        CurrentVoidPlate.Position = Vector3.new(LP.Character.HumanoidRootPart.Position.X, -501, LP.Character.HumanoidRootPart.Position.Z)
        LP.Character.HumanoidRootPart.CFrame = CFrame.new(CurrentVoidPlate.Position + Vector3.new(0, 5, 0))
    elseif not Config.VoidActive and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then 
        LP.Character.HumanoidRootPart.CFrame = LastPosBeforeVoid or CFrame.new(0, 50, 0)
    end
end)

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

local renderSteppedConnection = nil
local heartbeatConnection = nil

Close.MouseButton1Click:Connect(function()
    _G.Active = false
    _G.TPNearest = false
    _G.LoopTP = false
    _G.Bring = false
    _G.ESP = false
    _G.Aim = false
    _G.Fly = false
    _G.Speed = 16

    Config.TPNearest = false
    Config.LoopTP = false
    Config.Bring = false
    Config.ESP = false
    Config.Aim = false
    Config.Fly = false
    Config.VoidActive = false
    SaveConfig()

    if renderSteppedConnection then renderSteppedConnection:Disconnect() end
    if heartbeatConnection then heartbeatConnection:Disconnect() end
    if steppedConnection then steppedConnection:Disconnect() end
    if charAddedConnection then charAddedConnection:Disconnect() end

    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.WalkSpeed = 16
        for _, part in pairs(LP.Character:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = true end end
    end
    local t1 = LP.Backpack:FindFirstChild("Noclip")
    local t2 = LP.Character:FindFirstChild("Noclip")
    if t1 then t1:Destroy() end if t2 then t2:Destroy() end
    for _, p in pairs(Players:GetPlayers()) do if p.Character and p.Character:FindFirstChild("Head") then local tag = p.Character.Head:FindFirstChild("G_Tag") if tag then tag:Destroy() end end end
    if CurrentVoidPlate then CurrentVoidPlate:Destroy() end
    G:Destroy()
end)

local ToggleBtn = Instance.new("TextButton", G)
ToggleBtn.Visible = false
ToggleBtn.Size = UDim2.new(0, 45, 0, 45)
ToggleBtn.Position = UDim2.new(0, 110, 0, 15)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
ToggleBtn.Text = "G"
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 24
ToggleBtn.Active = true
ToggleBtn.Draggable = true

local ToggleStroke = Instance.new("UIStroke", ToggleBtn)
ToggleStroke.Color = NeonRed
ToggleStroke.Thickness = 2
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 8)

ToggleBtn.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)

local function GetDirection()
    local moveVector = Vector3.zero
    if UIS:IsKeyDown(Enum.KeyCode.W) or UIS:IsKeyDown(Enum.KeyCode.Up) then
        moveVector = moveVector + Vector3.new(0, 0, -1)
    end
    if UIS:IsKeyDown(Enum.KeyCode.S) or UIS:IsKeyDown(Enum.KeyCode.Down) then
        moveVector = moveVector + Vector3.new(0, 0, 1)
    end
    if UIS:IsKeyDown(Enum.KeyCode.A) or UIS:IsKeyDown(Enum.KeyCode.Left) then
        moveVector = moveVector + Vector3.new(-1, 0, 0)
    end
    if UIS:IsKeyDown(Enum.KeyCode.D) or UIS:IsKeyDown(Enum.KeyCode.Right) then
        moveVector = moveVector + Vector3.new(1, 0, 0)
    end

    if LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
        local hum = LP.Character:FindFirstChildOfClass("Humanoid")
        if hum.MoveDirection.Magnitude > 0 and moveVector.Magnitude == 0 then
            return hum.MoveDirection
        end
    end

    if moveVector.Magnitude > 0 then
        moveVector = moveVector.Unit
        local camCFrame = Camera.CFrame
        local forward = Vector3.new(camCFrame.LookVector.X, 0, camCFrame.LookVector.Z).Unit
        local right = Vector3.new(camCFrame.RightVector.X, 0, camCFrame.RightVector.Z).Unit
        return (forward * -moveVector.Z + right * moveVector.X).Unit
    end

    return Vector3.zero
end

renderSteppedConnection = RS.RenderStepped:Connect(function(deltaTime)
    if not _G.Active or not introFinished then return end
    pcall(function()
        local myChar = LP.Character
        if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
        local myHRP = myChar.HumanoidRootPart
        local hum = myChar:FindFirstChildOfClass("Humanoid")

        if _G.Speed > 16 then
            if hum then hum.WalkSpeed = 16 end
            local moveDirection = GetDirection()
            if moveDirection.Magnitude > 0 then
                local moveDelta = moveDirection * (_G.Speed - 16) * deltaTime
                myHRP.CFrame = myHRP.CFrame + moveDelta
            end
        end

        if _G.TPNearest then
            local t = GetNearestPlayer()
            if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
                local targetHRP = t.Character.HumanoidRootPart
                myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 3)
            end
        end

        if _G.LoopTP then
            local t = GetPlayerSmart(_G.TargetName)
            if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
                local targetHRP = t.Character.HumanoidRootPart
                myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 3)
            end
        end

        if _G.Bring then
            local t = GetPlayerSmart(_G.TargetName)
            if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
                t.Character.HumanoidRootPart.CFrame = myHRP.CFrame * CFrame.new(0, 0, -3)
            end
        end
    end)
end)

heartbeatConnection = RS.Heartbeat:Connect(function()
    if not _G.Active or not introFinished then return end
    pcall(function()
        if _G.Fly and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then 
            LP.Character.HumanoidRootPart.Velocity = Vector3.new(0, 50, 0) 
        end
        
        if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
        local myHRP = LP.Character.HumanoidRootPart
        local targetHRP = nil
        local closestDist = 1000

        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LP and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                local head = v.Character:FindFirstChild("Head")
                local hum = v.Character:FindFirstChild("Humanoid")
                local hrp = v.Character.HumanoidRootPart

                if _G.ESP and head and hum then
                    local tag = head:FindFirstChild("G_Tag")
                    if not tag then
                        tag = Instance.new("BillboardGui", head); tag.Name = "G_Tag"; tag.Size = UDim2.new(0, 200, 0, 100); tag.AlwaysOnTop = true; tag.StudsOffset = Vector3.new(0, 3, 0)
                        local l = Instance.new("TextLabel", tag); l.Size = UDim2.new(1,0,1,0); l.BackgroundTransparency = 1; l.TextColor3 = NeonRed; l.Font = Enum.Font.SourceSansBold; l.TextSize = 16
                    end
                    tag.TextLabel.Text = v.Name.."\nHP: "..math.floor(hum.Health).."\n"..math.floor((myHRP.Position - hrp.Position).Magnitude).."m"
                elseif not _G.ESP and head and head:FindFirstChild("G_Tag") then
                    head.G_Tag:Destroy()
                end

                if _G.Aim and hum and hum.Health > 0 then
                    local dist = (myHRP.Position - hrp.Position).Magnitude
                    if dist < closestDist then closestDist = dist; targetHRP = hrp end
                end
            end
        end

        if _G.Aim and targetHRP then
            local lookPos = Vector3.new(targetHRP.Position.X, myHRP.Position.Y, targetHRP.Position.Z)
            myHRP.CFrame = CFrame.new(myHRP.Position, lookPos)
        end
    end)
end)

task.spawn(function()
    StartIntro()
    Main.Visible = true
    ToggleBtn.Visible = true

    -- Áp dụng trạng thái Config đã lưu sau khi Intro kết thúc
    _G.Aim = Config.Aim
    _G.Fly = Config.Fly
    _G.ESP = Config.ESP
    _G.TPNearest = Config.TPNearest
    _G.LoopTP = Config.LoopTP
    _G.Bring = Config.Bring
    _G.VoidActive = Config.VoidActive

    if Config.VoidActive and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then 
        LastPosBeforeVoid = LP.Character.HumanoidRootPart.CFrame
        if not CurrentVoidPlate then
            CurrentVoidPlate = Instance.new("Part", workspace); CurrentVoidPlate.Name = "Galaxy_Void"; CurrentVoidPlate.Size = Vector3.new(2048, 1, 2048); CurrentVoidPlate.Anchored = true; CurrentVoidPlate.Transparency = 0.5; CurrentVoidPlate.Color = NeonRed; CurrentVoidPlate.Material = Enum.Material.ForceField
        end
        CurrentVoidPlate.Position = Vector3.new(LP.Character.HumanoidRootPart.Position.X, -501, LP.Character.HumanoidRootPart.Position.Z)
        LP.Character.HumanoidRootPart.CFrame = CFrame.new(CurrentVoidPlate.Position + Vector3.new(0, 5, 0))
    end
end)
