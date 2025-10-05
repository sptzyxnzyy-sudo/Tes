-- credit: Xraxor1 (Original GUI/Intro structure)
-- Modified by: Sptzyy
-- Features: Freeze Player, Auto Chat + Custom Messages, Label Owner, Hide Players (Switch Style)

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

-- STATUS FITUR
local isFreezeActive = false
local isAutoChatActive = false
local isLabelActive = false
local isHideActive = false
local autoChatConnection = nil
local freezeTouchConnection = nil
local ownerBillboard = nil

-- Daftar pemain yang dibekukan & pesan auto chat
local frozenPlayers = {}
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
frame.Size = UDim2.new(0, 270, 0, 430)
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
-- 🔹 FITUR 1: FREEZE PLAYER
------------------------------------------------------------
local function onFreezeTouch(otherPart)
	if not isFreezeActive or not otherPart or not otherPart.Parent then return end
	local targetPlayer = Players:GetPlayerFromCharacter(otherPart.Parent)
	if not targetPlayer or targetPlayer == player then return end

	local root = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
	if root and not frozenPlayers[targetPlayer.UserId] then
		root.Anchored = true
		frozenPlayers[targetPlayer.UserId] = root
		print("❄️ Membekukan:", targetPlayer.Name)
	end
end

local function unfreezeAll()
	for _, part in pairs(frozenPlayers) do
		if part and part.Parent then
			part.Anchored = false
		end
	end
	frozenPlayers = {}
end

local function toggleFreeze(state)
	isFreezeActive = state
	if state then
		local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if root then freezeTouchConnection = root.Touched:Connect(onFreezeTouch) end
		print("🧊 Freeze Player AKTIF.")
	else
		if freezeTouchConnection then freezeTouchConnection:Disconnect() end
		unfreezeAll()
		print("🧊 Freeze Player NONAKTIF.")
	end
end

------------------------------------------------------------
-- 🔹 FITUR 2: AUTO CHAT
------------------------------------------------------------
local function toggleAutoChat(state)
	isAutoChatActive = state
	if state then
		print("💬 Auto Chat AKTIF.")
		autoChatConnection = RunService.Heartbeat:Connect(function()
			if math.random(1, 100) < 2 then
				ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(
					chatMessages[math.random(1, #chatMessages)], "All"
				)
			end
		end)
	else
		if autoChatConnection then autoChatConnection:Disconnect() end
		print("💬 Auto Chat NONAKTIF.")
	end
end

------------------------------------------------------------
-- 🔹 FITUR 3: LABEL OWNER
------------------------------------------------------------
local function createOwnerLabel()
	local character = player.Character
	if not character then return end
	local head = character:FindFirstChild("Head")
	if not head then return end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "OwnerLabel"
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
	if state then
		createOwnerLabel()
		print("👑 Label Owner AKTIF.")
	else
		if ownerBillboard then ownerBillboard:Destroy() end
		print("👑 Label Owner NONAKTIF.")
	end
end

------------------------------------------------------------
-- 🔹 FITUR 4: SEMBUNYIKAN PEMAIN (HIDE PLAYERS)
------------------------------------------------------------
local function setPlayersVisible(visible)
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character then
			for _, part in pairs(plr.Character:GetDescendants()) do
				if part:IsA("BasePart") or part:IsA("Decal") then
					part.Transparency = visible and 0 or 1
					if part:IsA("Decal") then
						part.Transparency = visible and 0 or 1
					elseif part.Name == "Head" and plr.Character:FindFirstChild("face") then
						plr.Character.face.Transparency = visible and 0 or 1
					end
				end
			end
		end
	end
end

local function toggleHidePlayers(state)
	isHideActive = state
	if state then
		setPlayersVisible(false)
		print("👁️ Semua pemain disembunyikan (hanya kamu yang terlihat).")
	else
		setPlayersVisible(true)
		print("👁️ Semua pemain dimunculkan kembali.")
	end
end

------------------------------------------------------------
-- 🔹 SWITCH DAN UI CHAT
------------------------------------------------------------
local freezeSwitch = createSwitch("Freeze Player", false, toggleFreeze)
freezeSwitch.Position = UDim2.new(0, 15, 0, 40)

local chatSwitch = createSwitch("Auto Chat", false, toggleAutoChat)
chatSwitch.Position = UDim2.new(0, 15, 0, 85)

local labelSwitch = createSwitch("Label Owner", false, toggleOwnerLabel)
labelSwitch.Position = UDim2.new(0, 15, 0, 130)

local hideSwitch = createSwitch("Hide Players", false, toggleHidePlayers)
hideSwitch.Position = UDim2.new(0, 15, 0, 175)

------------------------------------------------------------
-- 🔹 TAMBAH PESAN AUTO CHAT
------------------------------------------------------------
local msgLabel = Instance.new("TextLabel")
msgLabel.Size = UDim2.new(1, -20, 0, 20)
msgLabel.Position = UDim2.new(0, 10, 0, 220)
msgLabel.Text = "Tambah Pesan Auto Chat:"
msgLabel.TextColor3 = Color3.new(1, 1, 1)
msgLabel.BackgroundTransparency = 1
msgLabel.Font = Enum.Font.GothamBold
msgLabel.TextSize = 12
msgLabel.TextXAlignment = Enum.TextXAlignment.Left
msgLabel.Parent = frame

local inputBox = Instance.new("TextBox")
inputBox.Size = UDim2.new(0, 170, 0, 25)
inputBox.Position = UDim2.new(0, 10, 0, 245)
inputBox.PlaceholderText = "Ketik pesan..."
inputBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
inputBox.TextColor3 = Color3.new(1, 1, 1)
inputBox.Font = Enum.Font.Gotham
inputBox.TextSize = 12
inputBox.Parent = frame

local cornerInput = Instance.new("UICorner")
cornerInput.CornerRadius = UDim.new(0, 8)
cornerInput.Parent = inputBox

local addButton = Instance.new("TextButton")
addButton.Size = UDim2.new(0, 60, 0, 25)
addButton.Position = UDim2.new(0, 190, 0, 245)
addButton.Text = "Add"
addButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
addButton.TextColor3 = Color3.new(1, 1, 1)
addButton.Font = Enum.Font.GothamBold
addButton.TextSize = 12
addButton.Parent = frame

local cornerAdd = Instance.new("UICorner")
cornerAdd.CornerRadius = UDim.new(0, 8)
cornerAdd.Parent = addButton

local messageList = Instance.new("TextLabel")
messageList.Size = UDim2.new(1, -20, 0, 150)
messageList.Position = UDim2.new(0, 10, 0, 275)
messageList.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
messageList.TextColor3 = Color3.new(1, 1, 1)
messageList.Font = Enum.Font.Code
messageList.TextSize = 11
messageList.TextYAlignment = Enum.TextYAlignment.Top
messageList.TextXAlignment = Enum.TextXAlignment.Left
messageList.TextWrapped = true
messageList.Text = "Pesan aktif:\n- " .. table.concat(chatMessages, "\n- ")
messageList.Parent = frame

local cornerList = Instance.new("UICorner")
cornerList.CornerRadius = UDim.new(0, 10)
cornerList.Parent = messageList

addButton.MouseButton1Click:Connect(function()
	local msg = inputBox.Text
	if msg ~= "" then
		table.insert(chatMessages, msg)
		inputBox.Text = ""
		messageList.Text = "Pesan aktif:\n- " .. table.concat(chatMessages, "\n- ")
	end
end)

------------------------------------------------------------
-- 🔹 CHARACTER HANDLER (RESPAWN SAFE)
------------------------------------------------------------
player.CharacterAdded:Connect(function(char)
	unfreezeAll()
	if isLabelActive then task.wait(1) createOwnerLabel() end
	if isFreezeActive then
		task.wait(1)
		local root = char:FindFirstChild("HumanoidRootPart")
		if root then freezeTouchConnection = root.Touched:Connect(onFreezeTouch) end
	end
	if isHideActive then
		task.wait(1)
		setPlayersVisible(false)
	end
end)