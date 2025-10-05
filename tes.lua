-- credit: Xraxor1 (Original GUI/Intro structure)
-- Modified by: Sptzyy
-- Features: Label Owner, Hide Other Players, Escape, Light, Tampilkan Nama Part, Hapus Part, Besarkan Avatar

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
local deletePartName = ""
local avatarScale = 1

local ownerBillboard = nil
local escapeConnection = nil
local partBillboards = {}

-- SIMPAN SETTING LIGHT ASLI
local originalLighting = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    Ambient = Lighting.Ambient
}

------------------------------------------------------------
-- 🔹 GUI UTAMA
------------------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CoreFeaturesGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 340, 0, 650)
frame.Position = UDim2.new(0.3, 0, 0.15, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 15)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "CORE FEATURES"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = frame

------------------------------------------------------------
-- 🔹 TEMPLATE SWITCH BUTTON
------------------------------------------------------------
local function createSwitch(name, defaultState, onToggle)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(0, 300, 0, 40)
	container.BackgroundTransparency = 1
	container.Parent = frame

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.6, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = name
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = container

	local switch = Instance.new("TextButton")
	switch.Size = UDim2.new(0, 60, 0, 25)
	switch.Position = UDim2.new(0.75, 0, 0.15, 0)
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
-- 🔹 FITUR LABEL OWNER
------------------------------------------------------------
local function createOwnerLabel()
	local char = player.Character
	if not char then return end
	local head = char:FindFirstChild("Head")
	if not head then return end

	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(0, 100, 0, 30)
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
-- 🔹 FITUR HIDE OTHER PLAYERS
------------------------------------------------------------
local function toggleHidePlayers(state)
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character then
			plr.Character.Parent = state and nil or workspace
		end
	end
end

------------------------------------------------------------
-- 🔹 FITUR ESCAPE / ANTI-DISRUPT
------------------------------------------------------------
local function toggleEscape(state)
	if state then
		if escapeConnection then escapeConnection:Disconnect() end
		escapeConnection = RunService.Heartbeat:Connect(function()
			local char = player.Character
			if char and char:FindFirstChild("HumanoidRootPart") then
				char.HumanoidRootPart.Velocity = Vector3.new(0,char.HumanoidRootPart.Velocity.Y,0)
			end
		end)
	else
		if escapeConnection then
			escapeConnection:Disconnect()
			escapeConnection = nil
		end
	end
end

------------------------------------------------------------
-- 🔹 FITUR LIGHT / BRIGHT MAP
------------------------------------------------------------
local function toggleLight(state)
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
-- 🔹 FITUR TAMPILKAN NAMA SEMUA PART
------------------------------------------------------------
local partBillboards = {}
local function togglePartNames(state)
	for _, b in pairs(partBillboards) do
		if b and b.Parent then b:Destroy() end
	end
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

				table.insert(partBillboards, billboard)
			end
		end
	end
end

------------------------------------------------------------
-- 🔹 FITUR HAPUS PART
------------------------------------------------------------
local deleteFrame = Instance.new("Frame")
deleteFrame.Size = UDim2.new(0,280,0,60)
deleteFrame.BackgroundTransparency = 1
deleteFrame.Position = UDim2.new(0,20,0,400)
deleteFrame.Parent = frame

local deleteLabel = Instance.new("TextLabel")
deleteLabel.Size = UDim2.new(1,0,0,20)
deleteLabel.BackgroundTransparency = 1
deleteLabel.Text = "Nama Part untuk Hapus:"
deleteLabel.TextColor3 = Color3.fromRGB(255,255,255)
deleteLabel.Font = Enum.Font.GothamBold
deleteLabel.TextSize = 12
deleteLabel.TextXAlignment = Enum.TextXAlignment.Left
deleteLabel.Parent = deleteFrame

local deleteTextBox = Instance.new("TextBox")
deleteTextBox.Size = UDim2.new(1,0,0,25)
deleteTextBox.Position = UDim2.new(0,0,0,25)
deleteTextBox.BackgroundColor3 = Color3.fromRGB(30,30,30)
deleteTextBox.TextColor3 = Color3.fromRGB(255,255,255)
deleteTextBox.Font = Enum.Font.GothamBold
deleteTextBox.TextSize = 14
deleteTextBox.ClearTextOnFocus = false
deleteTextBox.PlaceholderText = "Masukkan nama part"
deleteTextBox.Parent = deleteFrame

deleteTextBox.FocusLost:Connect(function(enter)
	if enter then
		deletePartName = deleteTextBox.Text
		if isDeletePartActive then
			for _, obj in pairs(workspace:GetDescendants()) do
				if obj:IsA("BasePart") and obj.Name == deletePartName then
					obj:Destroy()
				end
			end
		end
	end
end)

local function toggleDeletePart(state)
	isDeletePartActive = state
	if state and deletePartName ~= "" then
		for _, obj in pairs(workspace:GetDescendants()) do
			if obj:IsA("BasePart") and obj.Name == deletePartName then
				obj:Destroy()
			end
		end
	end
end

------------------------------------------------------------
-- 🔹 FITUR BESARKAN AVATAR
------------------------------------------------------------
local scaleFrame = Instance.new("Frame")
scaleFrame.Size = UDim2.new(0,280,0,60)
scaleFrame.BackgroundTransparency = 1
scaleFrame.Position = UDim2.new(0,20,0,470)
scaleFrame.Parent = frame

local scaleLabel = Instance.new("TextLabel")
scaleLabel.Size = UDim2.new(1,0,0,20)
scaleLabel.BackgroundTransparency = 1
scaleLabel.Text = "Skala Avatar:"
scaleLabel.TextColor3 = Color3.fromRGB(255,255,255)
scaleLabel.Font = Enum.Font.GothamBold
scaleLabel.TextSize = 12
scaleLabel.TextXAlignment = Enum.TextXAlignment.Left
scaleLabel.Parent = scaleFrame

local scaleTextBox = Instance.new("TextBox")
scaleTextBox.Size = UDim2.new(1,0,0,25)
scaleTextBox.Position = UDim2.new(0,0,0,25)
scaleTextBox.BackgroundColor3 = Color3.fromRGB(30,30,30)
scaleTextBox.TextColor3 = Color3.fromRGB(255,255,255)
scaleTextBox.Font = Enum.Font.GothamBold
scaleTextBox.TextSize = 14
scaleTextBox.ClearTextOnFocus = false
scaleTextBox.PlaceholderText = "Masukkan skala (misal 2)"
scaleTextBox.Parent = scaleFrame

scaleTextBox.FocusLost:Connect(function(enter)
	if enter then
		local val = tonumber(scaleTextBox.Text)
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
-- 🔹 SWITCH BUTTONS
------------------------------------------------------------
local labelSwitch = createSwitch("Label Owner", false, toggleOwnerLabel)
labelSwitch.Position = UDim2.new(0,15,0,40)

local hideSwitch = createSwitch("Hide Other Players", false, toggleHidePlayers)
hideSwitch.Position = UDim2.new(0,15,0,85)

local escapeSwitch = createSwitch("Escape / Anti-Disrupt", false, toggleEscape)
escapeSwitch.Position = UDim2.new(0,15,0,130)

local lightSwitch = createSwitch("Light / Bright Map", false, toggleLight)
lightSwitch.Position = UDim2.new(0,15,0,175)

local partNameSwitch = createSwitch("Tampilkan Nama Part", false, togglePartNames)
partNameSwitch.Position = UDim2.new(0,15,0,220)

local deleteSwitch = createSwitch("Hapus Part", false, toggleDeletePart)
deleteSwitch.Position = UDim2.new(0,15,0,280)

local avatarSwitch = createSwitch("Besarkan Avatar", false, toggleAvatarScale)
avatarSwitch.Position = UDim2.new(0,15,0,350)

------------------------------------------------------------
-- 🔹 CHARACTER SAFE RELOAD
------------------------------------------------------------
player.CharacterAdded:Connect(function(char)
	if isLabelActive then task.wait(1) createOwnerLabel() end
	if isAvatarScaleActive then task.wait(1) toggleAvatarScale(true) end
end)