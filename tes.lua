-- credit: Xraxor1
-- Modified by: Sptzyy
-- Features: Label Owner, Hide Players, Escape, Light, Show Part Names, Delete Part, Resize Avatar, Fly

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer

-- STATUS FITUR
local isLabelActive = false
local isHideActive = false
local isEscapeActive = false
local isLightActive = false
local isPartNameActive = false
local isDeletePartActive = false
local isAvatarScaleActive = false
local flyActive = false
local deletePartName = ""
local avatarScale = 1
local flyVelocity = Vector3.new(0,0,0)
local flySpeed = 50

local ownerBillboard = nil
local escapeConnection = nil
local partBillboards = {}
local flyGui, flyButtons, flyBV

-- SIMPAN SETTING LIGHT ASLI
local originalLighting = {Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime, Ambient = Lighting.Ambient}

------------------------------------------------------------
-- GUI UTAMA
------------------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CoreFeaturesGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 360, 0, 800)
frame.Position = UDim2.new(0.3,0,0.1,0)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0,15)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Text = "CORE FEATURES"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = frame

------------------------------------------------------------
-- TEMPLATE SWITCH
------------------------------------------------------------
local function createSwitch(name, defaultState, onToggle)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(0,300,0,40)
	container.BackgroundTransparency = 1
	container.Parent = frame

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.6,0,1,0)
	label.BackgroundTransparency = 1
	label.Text = name
	label.TextColor3 = Color3.new(1,1,1)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = container

	local switch = Instance.new("TextButton")
	switch.Size = UDim2.new(0,60,0,25)
	switch.Position = UDim2.new(0.75,0,0.15,0)
	switch.BackgroundColor3 = defaultState and Color3.fromRGB(0,180,0) or Color3.fromRGB(150,0,0)
	switch.Text = defaultState and "ON" or "OFF"
	switch.TextColor3 = Color3.new(1,1,1)
	switch.Font = Enum.Font.GothamBold
	switch.TextSize = 12
	switch.Parent = container

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0,10)
	corner.Parent = switch

	switch.MouseButton1Click:Connect(function()
		defaultState = not defaultState
		switch.Text = defaultState and "ON" or "OFF"
		switch.BackgroundColor3 = defaultState and Color3.fromRGB(0,180,0) or Color3.fromRGB(150,0,0)
		onToggle(defaultState)
	end)
	return container
end

------------------------------------------------------------
-- LABEL OWNER
------------------------------------------------------------
local function createOwnerLabel()
	if ownerBillboard then ownerBillboard:Destroy() end
	local char = player.Character
	if not char then return end
	local head = char:FindFirstChild("Head")
	if not head then return end
	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(0,100,0,30)
	billboard.StudsOffset = Vector3.new(0,2.5,0)
	billboard.AlwaysOnTop = true
	billboard.Parent = head
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1,0,1,0)
	label.BackgroundTransparency = 1
	label.Text = "👑 OWNER"
	label.TextColor3 = Color3.fromRGB(255,255,0)
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.Parent = billboard
	ownerBillboard = billboard
end

local function toggleOwnerLabel(state)
	isLabelActive = state
	if state then createOwnerLabel() else if ownerBillboard then ownerBillboard:Destroy() end end
end

------------------------------------------------------------
-- HIDE PLAYERS
------------------------------------------------------------
local function toggleHidePlayers(state)
	isHideActive = state
	for _, plr in pairs(Players:GetPlayers()) do
		if plr~=player and plr.Character then
			plr.Character.Parent = state and nil or workspace
		end
	end
end

------------------------------------------------------------
-- ESCAPE / ANTI-DISRUPT
------------------------------------------------------------
local function toggleEscape(state)
	isEscapeActive = state
	if state then
		if escapeConnection then escapeConnection:Disconnect() end
		escapeConnection = RunService.Heartbeat:Connect(function()
			local char = player.Character
			if char and char:FindFirstChild("HumanoidRootPart") then
				char.HumanoidRootPart.Velocity = Vector3.new(0,char.HumanoidRootPart.Velocity.Y,0)
			end
		end)
	else
		if escapeConnection then escapeConnection:Disconnect() escapeConnection=nil end
	end
end

------------------------------------------------------------
-- LIGHT / BRIGHT MAP
------------------------------------------------------------
local function toggleLight(state)
	isLightActive = state
	if state then
		Lighting.Brightness = 2
		Lighting.ClockTime = 14
		Lighting.Ambient = Color3.fromRGB(255,255,255)
	else
		Lighting.Brightness = originalLighting.Brightness
		Lighting.ClockTime = originalLighting.ClockTime
		Lighting.Ambient = originalLighting.Ambient
	end
end

------------------------------------------------------------
-- TAMPILKAN NAMA PART
------------------------------------------------------------
local function togglePartNames(state)
	isPartNameActive = state
	for _, b in pairs(partBillboards) do if b and b.Parent then b:Destroy() end end
	partBillboards = {}
	if state then
		for _, obj in pairs(workspace:GetDescendants()) do
			if obj:IsA("BasePart") then
				local billboard = Instance.new("BillboardGui")
				billboard.Size = UDim2.new(0,100,0,30)
				billboard.StudsOffset = Vector3.new(0,obj.Size.Y/2+0.5,0)
				billboard.AlwaysOnTop = true
				billboard.Parent = obj
				local label = Instance.new("TextLabel")
				label.Size = UDim2.new(1,0,1,0)
				label.BackgroundTransparency = 1
				label.TextColor3 = Color3.fromRGB(0,255,0)
				label.Font = Enum.Font.GothamBold
				label.TextScaled = true
				label.Text = obj.Name
				label.Parent = billboard
				table.insert(partBillboards,billboard)
			end
		end
	end
end

------------------------------------------------------------
-- HAPUS PART
------------------------------------------------------------
local deletePartNameBox = Instance.new("TextBox")
deletePartNameBox.Size = UDim2.new(0,280,0,25)
deletePartNameBox.Position = UDim2.new(0,20,0,500)
deletePartNameBox.BackgroundColor3 = Color3.fromRGB(30,30,30)
deletePartNameBox.TextColor3 = Color3.fromRGB(255,255,255)
deletePartNameBox.Font = Enum.Font.GothamBold
deletePartNameBox.PlaceholderText = "Nama Part untuk Hapus"
deletePartNameBox.Parent = frame

deletePartNameBox.FocusLost:Connect(function(enter)
	if enter then
		deletePartName = deletePartNameBox.Text
		if isDeletePartActive then
			for _, obj in pairs(workspace:GetDescendants()) do
				if obj:IsA("BasePart") and obj.Name == deletePartName then obj:Destroy() end
			end
		end
	end
end)

local function toggleDeletePart(state)
	isDeletePartActive = state
	if state and deletePartName~="" then
		for _, obj in pairs(workspace:GetDescendants()) do
			if obj:IsA("BasePart") and obj.Name==deletePartName then obj:Destroy() end
		end
	end
end

------------------------------------------------------------
-- BESARKAN AVATAR
------------------------------------------------------------
local avatarScaleBox = Instance.new("TextBox")
avatarScaleBox.Size = UDim2.new(0,280,0,25)
avatarScaleBox.Position = UDim2.new(0,20,0,540)
avatarScaleBox.BackgroundColor3 = Color3.fromRGB(30,30,30)
avatarScaleBox.TextColor3 = Color3.fromRGB(255,255,255)
avatarScaleBox.Font = Enum.Font.GothamBold
avatarScaleBox.PlaceholderText = "Skala Avatar (misal 2)"
avatarScaleBox.Parent = frame

avatarScaleBox.FocusLost:Connect(function(enter)
	if enter then
		local val = tonumber(avatarScaleBox.Text)
		if val then
			avatarScale = val
			if isAvatarScaleActive then
				local char = player.Character
				if char then
					for _, part in pairs(char:GetChildren()) do
						if part:IsA("BasePart") then
							part.Size = part.Size * avatarScale
						end
					end
				end
			end
		end
	end
end)

local function toggleAvatarScale(state)
	isAvatarScaleActive = state
	if state then
		local char = player.Character
		if char then
			for _, part in pairs(char:GetChildren()) do
				if part:IsA("BasePart") then
					part.Size = part.Size * avatarScale
				end
			end
		end
	end
end

------------------------------------------------------------
-- FITUR FLY
------------------------------------------------------------
local function createFlyGui()
	if flyGui then flyGui:Destroy() end
	flyGui = Instance.new("ScreenGui")
	flyGui.Name = "FlyControlsGUI"
	flyGui.ResetOnSpawn=false
	flyGui.Parent = player:WaitForChild("PlayerGui")

	local panel = Instance.new("Frame")
	panel.Size = UDim2.new(0,180,0,180)
	panel.Position = UDim2.new(0.8,0,0.7,0)
	panel.BackgroundColor3 = Color3.fromRGB(30,30,30)
	panel.BorderSizePixel = 0
	panel.Parent = flyGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0,15)
	corner.Parent = panel

	local directions = {
		Up = Vector3.new(0,1,0),
		Down = Vector3.new(0,-1,0),
		Forward = Vector3.new(0,0,-1),
		Backward = Vector3.new(0,0,1),
		Left = Vector3.new(-1,0,0),
		Right = Vector3.new(1,0,0)
	}

	local positions = {
		Up = UDim2.new(0.35,0,0,10),
		Down = UDim2.new(0.35,0,0,120),
		Forward = UDim2.new(0.35,0,0,60),
		Backward = UDim2.new(0.35,0,0,80),
		Left = UDim2.new(0.1,0,0,60),
		Right = UDim2.new(0.6,0,0,60)
	}

	flyButtons = {}
	for dir, vec in pairs(directions) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0,50,0,20)
		btn.Position = positions[dir]
		btn.Text = dir
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 12
		btn.TextColor3 = Color3.new(1,1,1)
		btn.BackgroundColor3 = Color3.fromRGB(0,180,0)
		btn.Parent = panel
		btn.MouseButton1Click:Connect(function() flyVelocity = vec*flySpeed end)
		flyButtons[dir]=btn
	end
end

local function toggleFly(state)
	flyActive = state
	local char = player.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	if state then
		createFlyGui()
		if flyBV then flyBV:Destroy() end
		flyBV = Instance.new("BodyVelocity")
		flyBV.MaxForce = Vector3.new(1e5,1e5,1e5)
		flyBV.Velocity = Vector3.new(0,0,0)
		flyBV.Parent = root

		RunService.Heartbeat:Connect(function()
			if flyActive and flyBV then
				flyBV.Velocity = flyVelocity
			end
		end)
	else
		if flyBV then flyBV:Destroy() flyBV=nil end
		if flyGui then flyGui:Destroy() flyGui=nil end
	end
end

------------------------------------------------------------
-- SWITCH BUTTONS
------------------------------------------------------------
createSwitch("Label Owner",false,toggleOwnerLabel).Position=UDim2.new(0,15,0,40)
createSwitch("Hide Other Players",false,toggleHidePlayers).Position=UDim2.new(0,15,0,85)
createSwitch("Escape / Anti-Disrupt",false,toggleEscape).Position=UDim2.new(0,15,0,130)
createSwitch("Light / Bright Map",false,toggleLight).Position=UDim2.new(0,15,0,175)
createSwitch("Tampilkan Nama Part",false,togglePartNames).Position=UDim2.new(0,15,0,220)
createSwitch("Hapus Part",false,toggleDeletePart).Position=UDim2.new(0,15,0,280)
createSwitch("Besarkan Avatar",false,toggleAvatarScale).Position=UDim2.new(0,15,0,350)
createSwitch("Fly",false,toggleFly).Position=UDim2.new(0,15,0,410)

------------------------------------------------------------
-- CHARACTER SAFE RELOAD
------------------------------------------------------------
player.CharacterAdded:Connect(function(char)
	if isLabelActive then task.wait(1) createOwnerLabel() end
	if isAvatarScaleActive then task.wait(1) toggleAvatarScale(true) end
end)