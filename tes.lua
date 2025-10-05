-- credit: Xraxor1 (Original GUI/Intro structure)
-- Modified by: Sptzyy
-- Features: Launch Player (Touch to Fly), Auto Chat + Custom Messages, Label Owner, Hide Other Players, Spin Other Players

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

-- STATUS FITUR
local isLaunchActive = false
local isAutoChatActive = false
local isLabelActive = false
local isHideActive = false
local isSpinActive = false

local autoChatConnection = nil
local launchTouchConnection = nil
local spinConnection = nil
local ownerBillboard = nil

local chatMessages = { "🔥 Auto chat aktif!", "😎 Chat by Sptzyy & Xraxor", "🚀 Roblox moment!" }

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
frame.Size = UDim2.new(0, 270, 0, 460)
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
-- 🔹 FITUR 1: LAUNCH PLAYER
------------------------------------------------------------
local function onLaunchTouch(otherPart)
	if not isLaunchActive or not otherPart or not otherPart.Parent then return end
	local targetPlayer = Players:GetPlayerFromCharacter(otherPart.Parent)
	if not targetPlayer or targetPlayer == player then return end

	local targetHumanoidRoot = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
	if targetHumanoidRoot then
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.Velocity = Vector3.new(0, 250, 0)
		bodyVelocity.MaxForce = Vector3.new(0, 1e5, 0)
		bodyVelocity.Parent = targetHumanoidRoot
		game:GetService("Debris"):AddItem(bodyVelocity, 0.5)
		print("🚀 Meluncurkan:", targetPlayer.Name)
	end
end

local function toggleLaunch(state)
	isLaunchActive = state
	if state then
		local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if root then launchTouchConnection = root.Touched:Connect(onLaunchTouch) end
		print("🚀 Launch Player AKTIF.")
	else
		if launchTouchConnection then launchTouchConnection:Disconnect() end
		print("🚀 Launch Player NONAKTIF.")
	end
end

------------------------------------------------------------
-- 🔹 FITUR 2: AUTO CHAT
------------------------------------------------------------
local function toggleAutoChat(state)
	isAutoChatActive = state
	if state then
		autoChatConnection = RunService.Heartbeat:Connect(function()
			if math.random(1, 100) < 2 then
				ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(
					chatMessages[math.random(1, #chatMessages)], "All"
				)
			end
		end)
	else
		if autoChatConnection then autoChatConnection:Disconnect() end
	end
end

------------------------------------------------------------
-- 🔹 FITUR 3: LABEL OWNER
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
-- 🔹 FITUR 4: SEMBUNYIKAN PEMAIN LAIN
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
-- 🔹 FITUR 5: SPIN PEMAIN LAIN (REAL)
------------------------------------------------------------
local function toggleSpinPlayers(state)
	isSpinActive = state
	if state then
		spinConnection = RunService.Heartbeat:Connect(function(dt)
			for _, plr in pairs(Players:GetPlayers()) do
				if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
					local hrp = plr.Character.HumanoidRootPart
					hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(180 * dt), 0)
				end
			end
		end)
		print("🌀 Spin pemain lain AKTIF (terlihat semua pemain).")
	else
		if spinConnection then spinConnection:Disconnect() spinConnection = nil end
		print("🌀 Spin pemain lain NONAKTIF.")
	end
end

------------------------------------------------------------
-- 🔹 SWITCH BUTTONS
------------------------------------------------------------
local launchSwitch = createSwitch("Launch Player", false, toggleLaunch)
launchSwitch.Position = UDim2.new(0, 15, 0, 40)

local chatSwitch = createSwitch("Auto Chat", false, toggleAutoChat)
chatSwitch.Position = UDim2.new(0, 15, 0, 85)

local labelSwitch = createSwitch("Label Owner", false, toggleOwnerLabel)
labelSwitch.Position = UDim2.new(0, 15, 0, 130)

local hideSwitch = createSwitch("Hide Other Players", false, toggleHidePlayers)
hideSwitch.Position = UDim2.new(0, 15, 0, 175)

local spinSwitch = createSwitch("Spin Other Players", false, toggleSpinPlayers)
spinSwitch.Position = UDim2.new(0, 15, 0, 220)

------------------------------------------------------------
-- 🔹 CHARACTER SAFE RELOAD
------------------------------------------------------------
player.CharacterAdded:Connect(function(char)
	if isLabelActive then task.wait(1) createOwnerLabel() end
	if isLaunchActive then
		task.wait(1)
		local root = char:FindFirstChild("HumanoidRootPart")
		if root then launchTouchConnection = root.Touched:Connect(onLaunchTouch) end
	end
end)