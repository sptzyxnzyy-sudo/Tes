-- credit: Xraxor1 (Original GUI/Intro structure)
-- Modified by: Sptzyy
-- Features: Label Owner, Hide Other Players, Escape, Player Check (ESP + Nama), Light/Bright Map, Tampilkan Nama Part

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer

-- STATUS FITUR
local isLabelActive = false
local isHideActive = false
local isEscapeActive = false
local isESPActive = false
local isLightActive = false
local isPartNameActive = false

local ownerBillboard = nil
local escapeConnection = nil
local espConnections = {}
local partBillboards = {}

-- SIMPAN SETTING LIGHT ASLI
local originalLighting = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    Ambient = Lighting.Ambient
}

------------------------------------------------------------
-- 🔹 INTRO ANIMATION “BY : XRAXOR”
------------------------------------------------------------
do
	local introGui = Instance.new("ScreenGui")
	introGui.Name = "IntroAnimation"
	introGui.ResetOnSpawn = false
	introGui.Parent = player:WaitForChild("PlayerGui")

	local introLabel = Instance.new("TextLabel")
	introLabel.Size = UDim2.new(0, 300, 0, 50)
	introLabel.Position = UDim2.new(0.5, -150, 0.4, 0)
	introLabel.BackgroundTransparency = 1
	introLabel.Text = "By : Xraxor"
	introLabel.TextColor3 = Color3.fromRGB(40, 40, 40)
	introLabel.TextScaled = true
	introLabel.Font = Enum.Font.GothamBold
	introLabel.Parent = introGui

	local tweenMove = TweenService:Create(introLabel, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Position = UDim2.new(0.5, -150, 0.42, 0)})
	local tweenColor = TweenService:Create(introLabel, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {TextColor3 = Color3.fromRGB(0, 0, 0)})
	tweenMove:Play()
	tweenColor:Play()

	task.wait(2)
	local fadeOut = TweenService:Create(introLabel, TweenInfo.new(0.5), {TextTransparency = 1})
	fadeOut:Play()
	fadeOut.Completed:Connect(function() introGui:Destroy() end)
end

------------------------------------------------------------
-- 🔹 GUI UTAMA
------------------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CoreFeaturesGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 270, 0, 450)
frame.Position = UDim2.new(0.38, 0, 0.35, 0)
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
	container.Size = UDim2.new(0, 240, 0, 40)
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
	switch.BackgroundColor3 = defaultState and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(150, 0, 0)
	switch.Text = defaultState and "ON" or "OFF"
	switch.TextColor3 = Color3.new(1, 1, 1)
	switch.Font = Enum.Font.GothamBold
	switch.TextSize = 12
	switch.Parent = container

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = switch

	switch.MouseButton1Click:Connect(function()
		defaultState = not defaultState
		switch.Text = defaultState and "ON" or "OFF"
		switch.BackgroundColor3 = defaultState and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(150, 0, 0)
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
	billboard.StudsOffset = Vector3.new(0, 2.5, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = head

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = "👑 OWNER"
	label.TextColor3 = Color3.fromRGB(255, 255, 0)
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
	isHideActive = state
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character then
			plr.Character.Parent = state and nil or workspace
		end
	end
	print(state and "🙈 Pemain lain disembunyikan" or "👁️ Pemain lain ditampilkan")
end

------------------------------------------------------------
-- 🔹 FITUR ESCAPE / ANTI-DISRUPT
------------------------------------------------------------
local function toggleEscape(state)
	isEscapeActive = state
	if state then
		escapeConnection = RunService.Heartbeat:Connect(function()
			local char = player.Character
			if char and char:FindFirstChild("HumanoidRootPart") then
				local hrp = char.HumanoidRootPart
				local pos = hrp.Position
				hrp.Velocity = Vector3.new(0, hrp.Velocity.Y, 0)
				hrp.Position = Vector3.new(pos.X, hrp.Position.Y, pos.Z)
			end
		end)
		print("🛡️ Escape AKTIF")
	else
		if escapeConnection then escapeConnection:Disconnect() escapeConnection = nil end
		print("🛡️ Escape NONAKTIF")
	end
end

------------------------------------------------------------
-- 🔹 FITUR CEK PEMAIN / ESP LINES + NAMA
------------------------------------------------------------
local function toggleESP(state)
	isESPActive = state
	for _, conn in pairs(espConnections) do
		conn:Disconnect()
	end
	espConnections = {}
	
	if state then
		local function createESPLine(targetPlayer)
			if targetPlayer == player then return end
			if not targetPlayer.Character then return end

			local line = Instance.new("Part")
			line.Anchored = true
			line.CanCollide = false
			line.Material = Enum.Material.Neon
			line.Color = Color3.fromRGB(255, 0, 0)
			line.Transparency = 0.5
			line.Size = Vector3.new(0.1, 0.1, 0.1)
			line.Parent = workspace

			local head = targetPlayer.Character:FindFirstChild("Head")
			if head then
				local nameBillboard = Instance.new("BillboardGui")
				nameBillboard.Size = UDim2.new(0,100,0,30)
				nameBillboard.StudsOffset = Vector3.new(0,3,0)
				nameBillboard.AlwaysOnTop = true
				nameBillboard.Parent = head

				local nameLabel = Instance.new("TextLabel")
				nameLabel.Size = UDim2.new(1,0,1,0)
				nameLabel.BackgroundTransparency = 1
				nameLabel.TextColor3 = Color3.fromRGB(255,0,0)
				nameLabel.Font = Enum.Font.GothamBold
				nameLabel.TextScaled = true
				nameLabel.Text = targetPlayer.Name
				nameLabel.Parent = nameBillboard
			end

			local conn
			conn = RunService.RenderStepped:Connect(function()
				if not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
					line:Destroy()
					if head and head:FindFirstChildOfClass("BillboardGui") then
						head:FindFirstChildOfClass("BillboardGui"):Destroy()
					end
					if conn then conn:Disconnect() end
					return
				end
				local startPos = player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.HumanoidRootPart.Position
				local endPos = targetPlayer.Character.HumanoidRootPart.Position
				if startPos then
					local dir = endPos - startPos
					line.CFrame = CFrame.new(startPos, endPos) * CFrame.new(0,0,-dir.Magnitude/2)
					line.Size = Vector3.new(0.05,0.05,dir.Magnitude)
				end
			end)
			table.insert(espConnections, conn)
		end

		for _, plr in pairs(Players:GetPlayers()) do
			createESPLine(plr)
			plr.CharacterAdded:Connect(function()
				createESPLine(plr)
			end)
		end
	end
end

------------------------------------------------------------
-- 🔹 FITUR LIGHT / BRIGHT MAP
------------------------------------------------------------
local function toggleLight(state)
	isLightActive = state
	if state then
		Lighting.Brightness = 2
		Lighting.ClockTime = 14
		Lighting.Ambient = Color3.fromRGB(255, 255, 255)
		print("💡 Light AKTIF: Map terang")
	else
		Lighting.Brightness = originalLighting.Brightness
		Lighting.ClockTime = originalLighting.ClockTime
		Lighting.Ambient = originalLighting.Ambient
		print("💡 Light NONAKTIF: Map kembali normal")
	end
end

------------------------------------------------------------
-- 🔹 FITUR TAMPILKAN NAMA SEMUA PART
------------------------------------------------------------
local function togglePartNames(state)
	isPartNameActive = state
	-- Hapus billboards lama
	for _, b in pairs(partBillboards) do
		if b and b.Parent then
			b:Destroy()
		end
	end
	partBillboards = {}

	if state then
		for _, obj in pairs(workspace:GetDescendants()) do
			if obj:IsA("BasePart") then
				local billboard = Instance.new("BillboardGui")
				billboard.Size = UDim2.new(0, 100, 0, 30)
				billboard.StudsOffset = Vector3.new(0, obj.Size.Y/2 + 0.5, 0)
				billboard.AlwaysOnTop = true
				billboard.Parent = obj

				local label = Instance.new("TextLabel")
				label.Size = UDim2.new(1, 0, 1, 0)
				label.BackgroundTransparency = 1
				label.TextColor3 = Color3.fromRGB(0, 255, 0)
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
-- 🔹 SWITCH BUTTONS
------------------------------------------------------------
local labelSwitch = createSwitch("Label Owner", false, toggleOwnerLabel)
labelSwitch.Position = UDim2.new(0, 15, 0, 40)

local hideSwitch = createSwitch("Hide Other Players", false, toggleHidePlayers)
hideSwitch.Position = UDim2.new(0, 15, 0, 85)

local escapeSwitch = createSwitch("Escape / Anti-Disrupt", false, toggleEscape)
escapeSwitch.Position = UDim2.new(0, 15, 0, 130)

local espSwitch = createSwitch("Player Check / ESP", false, toggleESP)
espSwitch.Position = UDim2.new(0, 15, 0, 175)

local lightSwitch = createSwitch("Light / Bright Map", false, toggleLight)
lightSwitch.Position = UDim2.new(0, 15, 0, 220)

local partNameSwitch = createSwitch("Tampilkan Nama Part", false, togglePartNames)
partNameSwitch.Position = UDim2.new(0, 15, 0, 265)

------------------------------------------------------------
-- 🔹 CHARACTER SAFE RELOAD
------------------------------------------------------------
player.CharacterAdded:Connect(function(char)
	if isLabelActive then task.wait(1) createOwnerLabel() end
end)