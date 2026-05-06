--[[ 
    GALAXY PREMIUM v5.4.2 - FIXED SPEED DISPLAY
    - FIX: Hiển thị tốc độ ngay sau khi nhập.
    - FIX: Ép xung WalkSpeed trong Heartbeat để đảm bảo tốc độ chạy ổn định.
]]

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("RunService")
local VIM = game:GetService("VirtualInputManager")
local TS = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Camera = workspace.CurrentCamera

-- [FFLAG DARK POTATO STYLE]
local function ApplyFFlags()
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    Lighting.GlobalShadows = false
    Lighting.Brightness = 0.5
    Lighting.OutdoorAmbient = Color3.fromRGB(100, 100, 100)
    Lighting.ClockTime = 0
    Lighting.ExposureCompensation = -0.5
    Lighting.FogEnd = 9e9
    local function Optimize(obj)
        if obj:IsA("BasePart") or obj:IsA("MeshPart") then
            obj.Material = Enum.Material.SmoothPlastic
            obj.CastShadow = false
            if obj.Name:lower():find("effect") or obj.Parent.Name:lower():find("fx") then
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

-- DỌN DẸP UI CŨ
for _, v in pairs(LP.PlayerGui:GetChildren()) do
    if v.Name:find("Galaxy") then v:Destroy() end
end

local G = Instance.new("ScreenGui", LP.PlayerGui)
G.Name = "Galaxy_"..math.random(1000,9999); G.ResetOnSpawn = false
local NeonRed = Color3.fromRGB(255, 0, 0)

-- BIẾN HỆ THỐNG
_G.Active = true
_G.TargetName = ""; _G.Speed = 16; _G.Fly = false; _G.AutoBlock = false; _G.Aim = false; _G.ESP = false
_G.LoopTP = false; _G.Bring = false; _G.VoidActive = false
local blockTick = 0
local LastPosBeforeVoid = nil
local CurrentVoidPlate = nil

-- [HỆ THỐNG NOCLIP TOOL TỰ ĐỘNG]
local function GiveNoclip()
    if not _G.Active then return end
    local Tool = Instance.new("Tool")
    Tool.Name = "Noclip"
    Tool.RequiresHandle = false
    Tool.CanBeDropped = false
    Tool.ToolTip = "Cầm trên tay để đi xuyên tường"
    Tool.Parent = LP.Backpack
end

RS.Stepped:Connect(function()
    if _G.Active and LP.Character then
        if LP.Character:FindFirstChild("Noclip") then
            for _, part in pairs(LP.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end
end)

LP.CharacterAdded:Connect(function()
    task.wait(0.5)
    GiveNoclip()
end)

-- [INTRO]
local function StartIntro()
    local Overlay = Instance.new("Frame", G); Overlay.Size = UDim2.new(1, 0, 1, 0); Overlay.BackgroundColor3 = Color3.new(0, 0, 0); Overlay.BackgroundTransparency = 1; Overlay.ZIndex = 100
    local IntroBox = Instance.new("Frame", Overlay); IntroBox.Size = UDim2.new(0, 400, 0, 100); IntroBox.Position = UDim2.new(0.5, -200, 0.5, -50); IntroBox.BackgroundColor3 = Color3.fromRGB(10, 10, 10); IntroBox.BackgroundTransparency = 1
    local BoxStroke = Instance.new("UIStroke", IntroBox); BoxStroke.Color = NeonRed; BoxStroke.Thickness = 2; BoxStroke.Transparency = 1
    local IntroText = Instance.new("TextLabel", IntroBox); IntroText.Size = UDim2.new(1, 0, 1, 0); IntroText.BackgroundTransparency = 1; IntroText.Text = "GALAXY Premium By LeDangKhoi"; IntroText.TextColor3 = NeonRed; IntroText.Font = Enum.Font.SourceSansBold; IntroText.TextSize = 25; IntroText.TextTransparency = 1
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
end

-- [MAIN MENU]
local Main = Instance.new("Frame", G); Main.Visible = false; Main.Size = UDim2.new(0, 220, 0, 520); Main.Position = UDim2.new(0.5, -230, 0.3, 0); Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15); Main.Active = true; Main.Draggable = true; Instance.new("UIStroke", Main).Color = NeonRed
local SubMenu = Instance.new("Frame", G); SubMenu.Visible = false; SubMenu.Size = UDim2.new(0, 200, 0, 260); SubMenu.Position = UDim2.new(0.5, 10, 0.3, 0); SubMenu.BackgroundColor3 = Color3.fromRGB(15, 15, 15); SubMenu.Active = true; SubMenu.Draggable = true; Instance.new("UIStroke", SubMenu).Color = NeonRed

local function CreateTitle(p, txt)
    local T = Instance.new("TextLabel", p); T.Size = UDim2.new(1, 0, 0, 40); T.BackgroundColor3 = NeonRed; T.Text = txt; T.TextColor3 = Color3.new(1,1,1); T.Font = Enum.Font.SourceSansBold; T.TextSize = 16
end
CreateTitle(Main, "GALAXY Premium - LeDangKhoi")
CreateTitle(SubMenu, "PLAYER TOOL")

local function AddSubBtn(n, y, c)
    local b = Instance.new("TextButton", SubMenu); b.Size = UDim2.new(1, -20, 0, 45); b.Position = UDim2.new(0, 10, 0, y); b.BackgroundColor3 = Color3.fromRGB(30,30,30); b.Text = n..": OFF"; b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.SourceSansBold; b.TextSize = 14
    local s = false; b.MouseButton1Click:Connect(function() s = not s; b.Text = n..(s and ": ON" or ": OFF"); b.TextColor3 = s and NeonRed or Color3.new(1,1,1); c(s) end)
end

local function AddMainBtn(n, y, c)
    local b = Instance.new("TextButton", Main); b.Size = UDim2.new(1, -20, 0, 45); b.Position = UDim2.new(0, 10, 0, y); b.BackgroundColor3 = Color3.fromRGB(30,30,30); b.Text = n..": OFF"; b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.SourceSansBold; b.TextSize = 18
    local s = false; b.MouseButton1Click:Connect(function() s = not s; b.Text = n..(s and ": ON" or ": OFF"); b.TextColor3 = s and NeonRed or Color3.new(1,1,1); c(s) end)
end

local NameBox = Instance.new("TextBox", SubMenu); NameBox.Size = UDim2.new(1, -20, 0, 40); NameBox.Position = UDim2.new(0, 10, 0, 50); NameBox.BackgroundColor3 = Color3.fromRGB(30,30,30); NameBox.PlaceholderText = "Tên người chơi..."; NameBox.Text = ""; NameBox.TextColor3 = Color3.new(1,1,1); NameBox.Font = Enum.Font.SourceSansBold; NameBox.TextSize = 14; Instance.new("UIStroke", NameBox).Color = NeonRed
NameBox.FocusLost:Connect(function() _G.TargetName = NameBox.Text end)

local function GetPlayerSmart(name)
    if name == "" then return nil end
    name = name:lower()
    for _, v in pairs(Players:GetPlayers()) do
        if v.Name:lower():sub(1, #name) == name or v.DisplayName:lower():sub(1, #name) == name then return v end
    end
    return nil
end

AddSubBtn("LOOP TELEPORT", 105, function(v) _G.LoopTP = v; task.spawn(function() while _G.LoopTP and _G.Active do task.wait(); local t = GetPlayerSmart(_G.TargetName); if t and t.Character and LP.Character then LP.Character.HumanoidRootPart.CFrame = t.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3) end end end) end)
AddSubBtn("BRING PLAYER", 160, function(v) _G.Bring = v; task.spawn(function() while _G.Bring and _G.Active do task.wait(); local t = GetPlayerSmart(_G.TargetName); if t and t.Character and LP.Character then t.Character.HumanoidRootPart.CFrame = LP.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3) end end end) end)
AddMainBtn("SMART AIM", 50, function(v) _G.Aim = v end)
AddMainBtn("AUTO BLOCK", 105, function(v) _G.AutoBlock = v end)
AddMainBtn("FLY MODE", 160, function(v) _G.Fly = v end)
AddMainBtn("PLAYER ESP", 215, function(v) _G.ESP = v end)
AddMainBtn("PLAYER TOOL", 270, function(v) SubMenu.Visible = v end)

AddMainBtn("TP TO VOID", 325, function(v) 
    _G.VoidActive = v 
    if v and LP.Character then 
        LastPosBeforeVoid = LP.Character.HumanoidRootPart.CFrame
        if not CurrentVoidPlate then
            CurrentVoidPlate = Instance.new("Part", workspace); CurrentVoidPlate.Name = "Galaxy_Void"; CurrentVoidPlate.Size = Vector3.new(2048, 1, 2048); CurrentVoidPlate.Anchored = true; CurrentVoidPlate.Transparency = 0.5; CurrentVoidPlate.Color = NeonRed; CurrentVoidPlate.Material = Enum.Material.ForceField
        end
        CurrentVoidPlate.Position = Vector3.new(LP.Character.HumanoidRootPart.Position.X, -500, LP.Character.HumanoidRootPart.Position.Z)
        LP.Character.HumanoidRootPart.CFrame = CFrame.new(CurrentVoidPlate.Position + Vector3.new(0, 5, 0))
    elseif not v and LP.Character then 
        LP.Character.HumanoidRootPart.CFrame = LastPosBeforeVoid or CFrame.new(0, 50, 0)
    end 
end)

-- [CHỈNH SỬA PHẦN TỐC ĐỘ]
local Inp = Instance.new("TextBox", Main);
Inp.Size = UDim2.new(1, -20, 0, 45);
Inp.Position = UDim2.new(0, 10, 0, 380);
Inp.BackgroundColor3 = Color3.fromRGB(30,30,30);
Inp.PlaceholderText = "NHẬP TỐC ĐỘ...";
Inp.Text = "TỐC ĐỘ (16)";
Inp.TextColor3 = NeonRed;
Inp.Font = Enum.Font.SourceSansBold;
Inp.TextSize = 18;
Instance.new("UIStroke", Inp).Color = NeonRed

Inp.FocusLost:Connect(function(enterPressed)
    local val = tonumber(Inp.Text)
    if val then
        _G.Speed = val
        Inp.Text = "TỐC ĐỘ ("..tostring(val)..")"
    else
        Inp.Text = "TỐC ĐỘ ("..tostring(_G.Speed)..")"
    end
end)

-- [HỆ THỐNG HỦY SCRIPT]
local Close = Instance.new("TextButton", Main); Close.Size = UDim2.new(1,-20,0,40); Close.Position = UDim2.new(0,10,0,435); Close.BackgroundColor3 = Color3.new(0.2,0,0); Close.Text = "HỦY SCRIPT"; Close.TextColor3 = Color3.new(1,1,1); Close.Font = Enum.Font.SourceSansBold
Close.MouseButton1Click:Connect(function()
    _G.Active = false
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.WalkSpeed = 16
        for _, part in pairs(LP.Character:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = true end end
    end
    local t1 = LP.Backpack:FindFirstChild("GALAXY_NOCLIP")
    local t2 = LP.Character:FindFirstChild("GALAXY_NOCLIP")
    if t1 then t1:Destroy() end if t2 then t2:Destroy() end
    for _, p in pairs(Players:GetPlayers()) do if p.Character and p.Character:FindFirstChild("Head") then local tag = p.Character.Head:FindFirstChild("G_Tag") if tag then tag:Destroy() end end end
    G:Destroy()
end)

local ToggleBtn = Instance.new("TextButton", G); ToggleBtn.Visible = false; ToggleBtn.Size = UDim2.new(0, 85, 0, 35); ToggleBtn.Position = UDim2.new(0, 10, 0.5, 0); ToggleBtn.BackgroundColor3 = Color3.new(0,0,0); ToggleBtn.Text = "GALAXY"; ToggleBtn.TextColor3 = NeonRed; ToggleBtn.Font = Enum.Font.SourceSansBold; ToggleBtn.TextSize = 12; Instance.new("UIStroke", ToggleBtn).Color = NeonRed
ToggleBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

-- [HEARTBEAT CORE]
RS.Heartbeat:Connect(function()
    if not _G.Active then return end
    pcall(function()
        -- Luôn ép WalkSpeed theo biến _G.Speed
        if LP.Character and LP.Character:FindFirstChild("Humanoid") then
            LP.Character.Humanoid.WalkSpeed = _G.Speed
        end
        
        if _G.Fly then LP.Character.HumanoidRootPart.Velocity = Vector3.new(0, 50, 0) end
        
        local myHRP = LP.Character.HumanoidRootPart
        local targetHRP = nil
        local closestDist = 1000

        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LP and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                local head = v.Character:FindFirstChild("Head")
                local hum = v.Character:FindFirstChild("Humanoid")
                local hrp = v.Character.HumanoidRootPart

                -- ESP
                if _G.ESP and head then
                    local tag = head:FindFirstChild("G_Tag")
                    if not tag then
                        tag = Instance.new("BillboardGui", head); tag.Name = "G_Tag"; tag.Size = UDim2.new(0, 200, 0, 100); tag.AlwaysOnTop = true; tag.StudsOffset = Vector3.new(0, 3, 0)
                        local l = Instance.new("TextLabel", tag); l.Size = UDim2.new(1,0,1,0); l.BackgroundTransparency = 1; l.TextColor3 = NeonRed; l.Font = Enum.Font.SourceSansBold; l.TextSize = 16
                    end
                    tag.TextLabel.Text = v.Name.."\nHP: "..math.floor(hum.Health).."\n"..math.floor((myHRP.Position - hrp.Position).Magnitude).."m"
                elseif not _G.ESP and head and head:FindFirstChild("G_Tag") then
                    head.G_Tag:Destroy()
                end

                -- AIM
                if _G.Aim and hum.Health > 0 then
                    local dist = (myHRP.Position - hrp.Position).Magnitude
                    if dist < closestDist then closestDist = dist; targetHRP = hrp end
                end

                -- AUTO BLOCK
                if _G.AutoBlock and (myHRP.Position - hrp.Position).Magnitude < 25 then
                    local anim = hum:FindFirstChildOfClass("Animator")
                    if anim then
                        for _, t in pairs(anim:GetPlayingAnimationTracks()) do
                            if t.IsPlaying and t.Speed > 1.1 then
                                VIM:SendKeyEvent(true, Enum.KeyCode.F, false, game);
                                blockTick = tick()
                                break
                            end
                        end
                    end
                end
            end
        end

        if _G.Aim and targetHRP then
            local lookPos = Vector3.new(targetHRP.Position.X, myHRP.Position.Y, targetHRP.Position.Z)
            myHRP.CFrame = CFrame.new(myHRP.Position, lookPos)
        end
        if _G.AutoBlock and tick() - blockTick > 0.4 then
            VIM:SendKeyEvent(false, Enum.KeyCode.F, false, game)
        end
    end)
end)

task.spawn(function()
    StartIntro();
    Main.Visible = true;
    ToggleBtn.Visible = true;
end)
