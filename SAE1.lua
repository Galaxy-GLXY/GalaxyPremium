local TARGET_Y = 93;
local FINAL_SAFE_ZONE = Vector3.new(549.39, TARGET_Y, -365.5);
local SAFE_ESCAPE_POS = Vector3.new(547.54, TARGET_Y, -364.99);
local SAFE_MIN_X = 365.2;
local SAFE_MAX_X = 552;
local SAFE_MIN_Z = -582;
local SAFE_MAX_Z = -146;
local ZONES = {{Name="Safe Zone (Steal)",Position=FINAL_SAFE_ZONE,IsSpecial=true},{Name="Jungle",Position=Vector3.new(1190.65, TARGET_Y, -397.29)},{Name="Snow",Position=Vector3.new(1490.13, TARGET_Y, -326.33)},{Name="Volcano",Position=Vector3.new(1883.9, TARGET_Y, -383.63)},{Name="Abyss Ocean",Position=Vector3.new(2280.29, TARGET_Y, -335.18)},{Name="Prehistoric",Position=Vector3.new(2816.63, TARGET_Y, -388.11)},{Name="Cosmic",Position=Vector3.new(3391.44, TARGET_Y, -335.1)},{Name="Cherry Blossom",Position=Vector3.new(4029.82, TARGET_Y, -388.07)},{Name="Titan Temple",Position=Vector3.new(4797.82, TARGET_Y, -339.47)},{Name="Angels/Demons",Position=Vector3.new(5658.86, TARGET_Y, -340.98)}};
local Workspace = game:GetService("Workspace");
local Players = game:GetService("Players");
local TweenService = game:GetService("TweenService");
local RunService = game:GetService("RunService");
local LocalPlayer = Players.LocalPlayer;
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui");
local SPEED_BYPASS_ENABLED = true;
local CUSTOM_SPEED = 275;
local NO_ANIM_ENABLED = true;
local function modifyPrompt(prompt)
	if prompt:IsA("ProximityPrompt") then
		prompt.HoldDuration = 0;
	end
end
for _, obj in ipairs(Workspace:GetDescendants()) do
	modifyPrompt(obj);
end
Workspace.DescendantAdded:Connect(modifyPrompt);
local ScreenGui = Instance.new("ScreenGui");
ScreenGui.Name = "UnifiedScriptGui";
ScreenGui.ResetOnSpawn = false;
ScreenGui.Parent = PlayerGui;
local MainFrame = Instance.new("Frame");
MainFrame.Name = "MainFrame";
MainFrame.Size = UDim2.new(0, 200, 0, 390);
MainFrame.Position = UDim2.new(0.82, 0, 0.15, 0);
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20);
MainFrame.BorderSizePixel = 0;
MainFrame.Visible = true;
MainFrame.Parent = ScreenGui;
local MainCorner = Instance.new("UICorner");
MainCorner.CornerRadius = UDim.new(0, 12);
MainCorner.Parent = MainFrame;
local MainStroke = Instance.new("UIStroke");
MainStroke.Color = Color3.fromRGB(0, 191, 255);
MainStroke.Thickness = 2;
MainStroke.Parent = MainFrame;
local TopBar = Instance.new("Frame");
TopBar.Name = "TopBar";
TopBar.Size = UDim2.new(1, 0, 0, 40);
TopBar.BackgroundColor3 = Color3.fromRGB(10, 10, 10);
TopBar.BorderSizePixel = 0;
TopBar.Parent = MainFrame;
local TopBarCorner = Instance.new("UICorner");
TopBarCorner.CornerRadius = UDim.new(0, 12);
TopBarCorner.Parent = TopBar;
local TopBarFix = Instance.new("Frame");
TopBarFix.Size = UDim2.new(1, 0, 0, 10);
TopBarFix.Position = UDim2.new(0, 0, 1, -10);
TopBarFix.BackgroundColor3 = Color3.fromRGB(10, 10, 10);
TopBarFix.BorderSizePixel = 0;
TopBarFix.Parent = TopBar;
local TitleLabel = Instance.new("TextLabel");
TitleLabel.Size = UDim2.new(1, -45, 1, 0);
TitleLabel.Position = UDim2.new(0, 10, 0, 0);
TitleLabel.BackgroundTransparency = 1;
TitleLabel.Text = "By GALAXY";
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left;
TitleLabel.TextColor3 = Color3.fromRGB(0, 191, 255);
TitleLabel.TextSize = 14;
TitleLabel.Font = Enum.Font.GothamBold;
TitleLabel.Parent = TopBar;
local MinimizeButton = Instance.new("TextButton");
MinimizeButton.Name = "MinimizeButton";
MinimizeButton.Size = UDim2.new(0, 30, 0, 30);
MinimizeButton.Position = UDim2.new(1, -35, 0.5, -15);
MinimizeButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30);
MinimizeButton.Text = "-";
MinimizeButton.TextColor3 = Color3.fromRGB(0, 191, 255);
MinimizeButton.TextSize = 18;
MinimizeButton.Font = Enum.Font.GothamBold;
MinimizeButton.Parent = TopBar;
local MinCorner = Instance.new("UICorner");
MinCorner.CornerRadius = UDim.new(0, 6);
MinCorner.Parent = MinimizeButton;
local ContentScroll = Instance.new("ScrollingFrame");
ContentScroll.Name = "ContentScroll";
ContentScroll.Size = UDim2.new(1, 0, 1, -40);
ContentScroll.Position = UDim2.new(0, 0, 0, 40);
ContentScroll.BackgroundTransparency = 1;
ContentScroll.BorderSizePixel = 0;
ContentScroll.ClipsDescendants = true;
ContentScroll.ScrollBarThickness = 6;
ContentScroll.Parent = MainFrame;
local UIListLayout = Instance.new("UIListLayout");
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center;
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder;
UIListLayout.Padding = UDim.new(0, 6);
UIListLayout.Parent = ContentScroll;
local UIPadding = Instance.new("UIPadding");
UIPadding.PaddingTop = UDim.new(0, 10);
UIPadding.PaddingBottom = UDim.new(0, 10);
UIPadding.Parent = ContentScroll;
local dragging, dragInput, dragStart, startPos;
TopBar.InputBegan:Connect(function(input)
	if ((input.UserInputType == Enum.UserInputType.MouseButton1) or (input.UserInputType == Enum.UserInputType.Touch)) then
		local FlatIdent_95CAC = 0;
		while true do
			if (FlatIdent_95CAC == 1) then
				startPos = MainFrame.Position;
				input.Changed:Connect(function()
					if (input.UserInputState == Enum.UserInputState.End) then
						dragging = false;
					end
				end);
				break;
			end
			if (FlatIdent_95CAC == 0) then
				dragging = true;
				dragStart = input.Position;
				FlatIdent_95CAC = 1;
			end
		end
	end
end);
TopBar.InputChanged:Connect(function(input)
	if ((input.UserInputType == Enum.UserInputType.MouseMovement) or (input.UserInputType == Enum.UserInputType.Touch)) then
		dragInput = input;
	end
end);
RunService.RenderStepped:Connect(function()
	if (dragging and dragInput) then
		local FlatIdent_8D327 = 0;
		local delta;
		while true do
			if (FlatIdent_8D327 == 0) then
				delta = dragInput.Position - dragStart;
				MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y);
				break;
			end
		end
	end
end);
local isMinimized = false;
MinimizeButton.MouseButton1Click:Connect(function()
	local FlatIdent_24A02 = 0;
	while true do
		if (FlatIdent_24A02 == 0) then
			isMinimized = not isMinimized;
			if isMinimized then
				local FlatIdent_7126A = 0;
				while true do
					if (FlatIdent_7126A == 0) then
						MinimizeButton.Text = "+";
						TweenService:Create(MainFrame, TweenInfo.new(0.2), {Size=UDim2.new(0, 200, 0, 40)}):Play();
						break;
					end
				end
			else
				local FlatIdent_12703 = 0;
				while true do
					if (FlatIdent_12703 == 0) then
						MinimizeButton.Text = "-";
						TweenService:Create(MainFrame, TweenInfo.new(0.2), {Size=UDim2.new(0, 200, 0, 390)}):Play();
						break;
					end
				end
			end
			break;
		end
	end
end);
local isTraveling = false;
local groundPart = nil;
local activeBV = nil;
local activeBG = nil;
local activeZoneButton = nil;
local originalButtonText = "";
local function isHoldingEgg(character)
	return character:FindFirstChildOfClass("Tool") ~= nil;
end
local function setAnimationsEnabled(character, enabled)
	local FlatIdent_2BD95 = 0;
	local humanoid;
	local animator;
	while true do
		if (FlatIdent_2BD95 == 0) then
			if not character then
				return;
			end
			humanoid = character:FindFirstChildOfClass("Humanoid");
			FlatIdent_2BD95 = 1;
		end
		if (FlatIdent_2BD95 == 2) then
			if animator then
				for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
					if enabled then
						track:AdjustSpeed(1);
					else
						track:Stop(0);
					end
				end
			end
			if not SPEED_BYPASS_ENABLED then
				humanoid.WalkSpeed = (enabled and 16) or 0;
			end
			break;
		end
		if (FlatIdent_2BD95 == 1) then
			if not humanoid then
				return;
			end
			animator = humanoid:FindFirstChildOfClass("Animator");
			FlatIdent_2BD95 = 2;
		end
	end
end
local function unblockHumanoid(humanoid)
	if not humanoid then
		return;
	end
	if humanoid.PlatformStand then
		humanoid.PlatformStand = false;
	end
	if humanoid.Sit then
		humanoid.Sit = false;
	end
	pcall(function()
		local FlatIdent_43862 = 0;
		while true do
			if (0 == FlatIdent_43862) then
				humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false);
				humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false);
				break;
			end
		end
	end);
end
local function stopTravel()
	isTraveling = false;
	if groundPart then
		groundPart:Destroy();
		groundPart = nil;
	end
	if activeBV then
		local FlatIdent_8F047 = 0;
		while true do
			if (FlatIdent_8F047 == 0) then
				activeBV:Destroy();
				activeBV = nil;
				break;
			end
		end
	end
	if activeBG then
		local FlatIdent_31905 = 0;
		while true do
			if (0 == FlatIdent_31905) then
				activeBG:Destroy();
				activeBG = nil;
				break;
			end
		end
	end
	if activeZoneButton then
		local FlatIdent_51F42 = 0;
		local stroke;
		while true do
			if (FlatIdent_51F42 == 2) then
				activeZoneButton = nil;
				break;
			end
			if (FlatIdent_51F42 == 1) then
				stroke = activeZoneButton:FindFirstChildOfClass("UIStroke");
				if (stroke and activeZoneButton.Name:find("Safe Zone")) then
					stroke.Color = Color3.fromRGB(255, 255, 255);
				elseif stroke then
					stroke.Color = Color3.fromRGB(0, 191, 255);
				end
				FlatIdent_51F42 = 2;
			end
			if (FlatIdent_51F42 == 0) then
				activeZoneButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30);
				activeZoneButton.Text = originalButtonText;
				FlatIdent_51F42 = 1;
			end
		end
	end
	local character = LocalPlayer.Character;
	if character then
		local FlatIdent_946F = 0;
		local humanoid;
		while true do
			if (FlatIdent_946F == 0) then
				humanoid = character:FindFirstChildOfClass("Humanoid");
				if humanoid then
					local FlatIdent_49AED = 0;
					while true do
						if (FlatIdent_49AED == 0) then
							unblockHumanoid(humanoid);
							humanoid:ChangeState(Enum.HumanoidStateType.Running);
							break;
						end
					end
				end
				FlatIdent_946F = 1;
			end
			if (FlatIdent_946F == 1) then
				setAnimationsEnabled(character, true);
				break;
			end
		end
	end
end
local function setupCharacterFeatures(character)
	local FlatIdent_99389 = 0;
	local hrp;
	local humanoid;
	local animateScript;
	while true do
		if (FlatIdent_99389 == 1) then
			humanoid = character:WaitForChild("Humanoid", 5);
			animateScript = character:WaitForChild("Animate", 5);
			FlatIdent_99389 = 2;
		end
		if (FlatIdent_99389 == 2) then
			if (not hrp or not humanoid) then
				return;
			end
			if (NO_ANIM_ENABLED and animateScript and animateScript:IsA("LocalScript")) then
				animateScript.Disabled = true;
			end
			FlatIdent_99389 = 3;
		end
		if (FlatIdent_99389 == 3) then
			humanoid.StateChanged:Connect(function(oldState, newState)
				local FlatIdent_12544 = 0;
				while true do
					if (FlatIdent_12544 == 0) then
						if isTraveling then
							return;
						end
						if ((newState == Enum.HumanoidStateType.Physics) or (newState == Enum.HumanoidStateType.Ragdoll) or (newState == Enum.HumanoidStateType.FallingDown) or (newState == Enum.HumanoidStateType.Flying)) then
							pcall(function()
								humanoid:ChangeState(Enum.HumanoidStateType.Running);
							end);
						end
						break;
					end
				end
			end);
			RunService.RenderStepped:Connect(function(dt)
				if (character and character.Parent and (humanoid.Health > 0) and not isTraveling) then
					hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0);
					hrp.AssemblyAngularVelocity = Vector3.zero;
					if SPEED_BYPASS_ENABLED then
						local FlatIdent_29B3D = 0;
						local moveDir;
						while true do
							if (FlatIdent_29B3D == 1) then
								if (moveDir.Magnitude > 0) then
									local FlatIdent_759F1 = 0;
									local targetLookAt;
									while true do
										if (FlatIdent_759F1 == 1) then
											if (targetLookAt.Magnitude > 0) then
												local FlatIdent_6B983 = 0;
												local currentCF;
												local newCF;
												while true do
													if (FlatIdent_6B983 == 1) then
														hrp.CFrame = currentCF:Lerp(newCF, 0.3);
														break;
													end
													if (FlatIdent_6B983 == 0) then
														currentCF = hrp.CFrame;
														newCF = CFrame.new(currentCF.Position, currentCF.Position + targetLookAt);
														FlatIdent_6B983 = 1;
													end
												end
											end
											break;
										end
										if (0 == FlatIdent_759F1) then
											hrp.CFrame = hrp.CFrame + (moveDir * CUSTOM_SPEED * dt);
											targetLookAt = Vector3.new(moveDir.X, 0, moveDir.Z);
											FlatIdent_759F1 = 1;
										end
									end
								end
								break;
							end
							if (FlatIdent_29B3D == 0) then
								humanoid.WalkSpeed = 0;
								moveDir = humanoid.MoveDirection;
								FlatIdent_29B3D = 1;
							end
						end
					end
				end
			end);
			break;
		end
		if (FlatIdent_99389 == 0) then
			if not character then
				return;
			end
			hrp = character:WaitForChild("HumanoidRootPart", 5);
			FlatIdent_99389 = 1;
		end
	end
end
if LocalPlayer.Character then
	setupCharacterFeatures(LocalPlayer.Character);
end
LocalPlayer.CharacterAdded:Connect(setupCharacterFeatures);
task.spawn(function()
	while true do
		local FlatIdent_287B5 = 0;
		local character;
		while true do
			if (FlatIdent_287B5 == 0) then
				task.wait(0.05);
				character = LocalPlayer.Character;
				FlatIdent_287B5 = 1;
			end
			if (FlatIdent_287B5 == 1) then
				if character then
					local humanoid = character:FindFirstChildOfClass("Humanoid");
					if (humanoid and (humanoid.Health > 0) and not isTraveling) then
						local FlatIdent_D79D = 0;
						while true do
							if (0 == FlatIdent_D79D) then
								unblockHumanoid(humanoid);
								if ((humanoid:GetState() ~= Enum.HumanoidStateType.Running) and not humanoid.Sit) then
									pcall(function()
										humanoid:ChangeState(Enum.HumanoidStateType.Running);
									end);
								end
								break;
							end
						end
					end
				end
				break;
			end
		end
	end
end);
local function executeFlight(destinationPos)
	local FlatIdent_40B41 = 0;
	local character;
	local hrp;
	local humanoid;
	local moveSpeed;
	local startTime;
	local targetFlat;
	local distance;
	local estimatedTime;
	while true do
		if (0 == FlatIdent_40B41) then
			character = LocalPlayer.Character;
			if not character then
				return;
			end
			hrp = character:FindFirstChild("HumanoidRootPart");
			humanoid = character:FindFirstChildOfClass("Humanoid");
			if (not hrp or not humanoid) then
				return;
			end
			groundPart = Instance.new("Part");
			FlatIdent_40B41 = 1;
		end
		if (FlatIdent_40B41 == 4) then
			targetFlat = Vector3.new(destinationPos.X, TARGET_Y, destinationPos.Z);
			distance = (targetFlat - hrp.Position).Magnitude;
			estimatedTime = (distance / moveSpeed) + 0.4;
			while isTraveling and character and hrp and (humanoid.Health > 0) do
				setAnimationsEnabled(character, false);
				local currentFlatPos = Vector3.new(hrp.Position.X, TARGET_Y, hrp.Position.Z);
				if groundPart then
					groundPart.CFrame = CFrame.new(currentFlatPos.X, TARGET_Y - 3.5, currentFlatPos.Z);
				end
				local currentDist = (targetFlat - currentFlatPos).Magnitude;
				if ((currentDist <= 5) or ((tick() - startTime) > estimatedTime)) then
					break;
				end
				local currentDir = (targetFlat - currentFlatPos).Unit;
				activeBV.Velocity = Vector3.new(currentDir.X * moveSpeed, 0, currentDir.Z * moveSpeed);
				task.wait(0.015);
			end
			if activeBV then
				local FlatIdent_206F8 = 0;
				while true do
					if (0 == FlatIdent_206F8) then
						activeBV:Destroy();
						activeBV = nil;
						break;
					end
				end
			end
			if activeBG then
				local FlatIdent_3CF36 = 0;
				while true do
					if (0 == FlatIdent_3CF36) then
						activeBG:Destroy();
						activeBG = nil;
						break;
					end
				end
			end
			FlatIdent_40B41 = 5;
		end
		if (3 == FlatIdent_40B41) then
			activeBG.MaxTorque = Vector3.new(8999999488, 8999999488, 8999999488);
			activeBG.P = 90000;
			activeBG.CFrame = CFrame.lookAt(hrp.Position, destinationPos);
			activeBG.Parent = hrp;
			moveSpeed = 2500;
			startTime = tick();
			FlatIdent_40B41 = 4;
		end
		if (2 == FlatIdent_40B41) then
			groundPart.Parent = workspace;
			activeBV = Instance.new("BodyVelocity");
			activeBV.MaxForce = Vector3.new(8999999488, 8999999488, 8999999488);
			activeBV.Velocity = Vector3.zero;
			activeBV.Parent = hrp;
			activeBG = Instance.new("BodyGyro");
			FlatIdent_40B41 = 3;
		end
		if (1 == FlatIdent_40B41) then
			groundPart.Name = "AntiCheatSafetyPlatform";
			groundPart.Size = Vector3.new(8, 1, 8);
			groundPart.Anchored = true;
			groundPart.CanCollide = true;
			groundPart.Transparency = 1;
			groundPart.CFrame = CFrame.new(hrp.Position.X, TARGET_Y - 3.5, hrp.Position.Z);
			FlatIdent_40B41 = 2;
		end
		if (FlatIdent_40B41 == 5) then
			if groundPart then
				local FlatIdent_4D434 = 0;
				while true do
					if (FlatIdent_4D434 == 0) then
						groundPart:Destroy();
						groundPart = nil;
						break;
					end
				end
			end
			break;
		end
	end
end
local function moveToTarget(targetPosition, clickedButton, zoneName)
	local FlatIdent_45D37 = 0;
	local character;
	local hrp;
	local humanoid;
	local stroke;
	local currentPos;
	local isInSafeZone;
	while true do
		if (FlatIdent_45D37 == 1) then
			humanoid = character:FindFirstChildOfClass("Humanoid");
			if (not hrp or not humanoid or (humanoid.Health <= 0)) then
				return;
			end
			isTraveling = true;
			activeZoneButton = clickedButton;
			FlatIdent_45D37 = 2;
		end
		if (FlatIdent_45D37 == 5) then
			if isTraveling then
				local FlatIdent_32B97 = 0;
				local finalCFrame;
				local tpEndTime;
				while true do
					if (FlatIdent_32B97 == 1) then
						groundPart.Anchored = true;
						groundPart.CanCollide = true;
						groundPart.Transparency = 1;
						FlatIdent_32B97 = 2;
					end
					if (FlatIdent_32B97 == 2) then
						groundPart.CFrame = CFrame.new(targetPosition.X, TARGET_Y - 3.5, targetPosition.Z);
						groundPart.Parent = workspace;
						finalCFrame = CFrame.new(targetPosition);
						FlatIdent_32B97 = 3;
					end
					if (FlatIdent_32B97 == 3) then
						tpEndTime = tick() + 0.3;
						while isTraveling and (tick() < tpEndTime) and character and hrp and (humanoid.Health > 0) do
							local FlatIdent_272FB = 0;
							while true do
								if (FlatIdent_272FB == 2) then
									if groundPart then
										groundPart.CFrame = finalCFrame - Vector3.new(0, 3.5, 0);
									end
									RunService.Heartbeat:Wait();
									break;
								end
								if (FlatIdent_272FB == 0) then
									setAnimationsEnabled(character, false);
									hrp.AssemblyLinearVelocity = Vector3.zero;
									FlatIdent_272FB = 1;
								end
								if (1 == FlatIdent_272FB) then
									hrp.AssemblyAngularVelocity = Vector3.zero;
									hrp.CFrame = finalCFrame;
									FlatIdent_272FB = 2;
								end
							end
						end
						break;
					end
					if (FlatIdent_32B97 == 0) then
						groundPart = Instance.new("Part");
						groundPart.Name = "AntiCheatSafetyPlatform";
						groundPart.Size = Vector3.new(8, 1, 8);
						FlatIdent_32B97 = 1;
					end
				end
			end
			stopTravel();
			break;
		end
		if (FlatIdent_45D37 == 0) then
			if isTraveling then
				stopTravel();
				return;
			end
			character = LocalPlayer.Character;
			if not character then
				return;
			end
			hrp = character:FindFirstChild("HumanoidRootPart");
			FlatIdent_45D37 = 1;
		end
		if (FlatIdent_45D37 == 2) then
			originalButtonText = zoneName;
			clickedButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0);
			clickedButton.Text = "STOP";
			stroke = clickedButton:FindFirstChildOfClass("UIStroke");
			FlatIdent_45D37 = 3;
		end
		if (FlatIdent_45D37 == 3) then
			if stroke then
				stroke.Color = Color3.fromRGB(255, 69, 0);
			end
			setAnimationsEnabled(character, false);
			hrp.AssemblyLinearVelocity = Vector3.zero;
			hrp.CFrame = CFrame.new(hrp.Position.X, TARGET_Y, hrp.Position.Z);
			FlatIdent_45D37 = 4;
		end
		if (FlatIdent_45D37 == 4) then
			currentPos = hrp.Position;
			isInSafeZone = (currentPos.X >= SAFE_MIN_X) and (currentPos.X <= SAFE_MAX_X) and (currentPos.Z >= SAFE_MIN_Z) and (currentPos.Z <= SAFE_MAX_Z);
			if isInSafeZone then
				executeFlight(SAFE_ESCAPE_POS);
			end
			if isTraveling then
				executeFlight(targetPosition);
			end
			FlatIdent_45D37 = 5;
		end
	end
end
for _, zone in ipairs(ZONES) do
	local FlatIdent_521D6 = 0;
	local ZoneButton;
	local ButtonCorner;
	local ButtonStroke;
	while true do
		if (FlatIdent_521D6 == 3) then
			ButtonCorner = Instance.new("UICorner");
			ButtonCorner.CornerRadius = UDim.new(0, 8);
			ButtonCorner.Parent = ZoneButton;
			FlatIdent_521D6 = 4;
		end
		if (FlatIdent_521D6 == 0) then
			ZoneButton = Instance.new("TextButton");
			ZoneButton.Name = zone.Name .. "Button";
			ZoneButton.Size = UDim2.new(0, 180, 0, 35);
			FlatIdent_521D6 = 1;
		end
		if (FlatIdent_521D6 == 1) then
			ZoneButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30);
			ZoneButton.Text = zone.Name;
			ZoneButton.TextColor3 = Color3.fromRGB(255, 255, 255);
			FlatIdent_521D6 = 2;
		end
		if (FlatIdent_521D6 == 5) then
			ButtonStroke.Parent = ZoneButton;
			if zone.IsSpecial then
				local FlatIdent_2DA99 = 0;
				while true do
					if (FlatIdent_2DA99 == 1) then
						task.spawn(function()
							while ZoneButton and ZoneButton.Parent do
								if (not isTraveling or (activeZoneButton ~= ZoneButton)) then
									for i = 0, 1, 0.01 do
										if (not ZoneButton or not ZoneButton.Parent or (isTraveling and (activeZoneButton == ZoneButton))) then
											break;
										end
										ButtonStroke.Color = Color3.fromHSV(i, 1, 1);
										task.wait(0.05);
									end
								else
									task.wait(0.2);
								end
							end
						end);
						break;
					end
					if (FlatIdent_2DA99 == 0) then
						ZoneButton.TextColor3 = Color3.fromRGB(255, 255, 255);
						ZoneButton.Font = Enum.Font.GothamBold;
						FlatIdent_2DA99 = 1;
					end
				end
			end
			ZoneButton.MouseButton1Click:Connect(function()
				moveToTarget(zone.Position, ZoneButton, zone.Name);
			end);
			break;
		end
		if (FlatIdent_521D6 == 4) then
			ButtonStroke = Instance.new("UIStroke");
			ButtonStroke.Color = Color3.fromRGB(0, 191, 255);
			ButtonStroke.Thickness = 1.5;
			FlatIdent_521D6 = 5;
		end
		if (FlatIdent_521D6 == 2) then
			ZoneButton.TextSize = 14;
			ZoneButton.Font = Enum.Font.GothamSemibold;
			ZoneButton.Parent = ContentScroll;
			FlatIdent_521D6 = 3;
		end
	end
end
ContentScroll.CanvasSize = UDim2.new(0, 0, 0, (#ZONES * 41) + 20);
