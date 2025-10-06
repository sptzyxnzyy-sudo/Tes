-- credit: Xraxor1
-- Diubah oleh: Sptzyy
-- Fitur: Label Pemilik, Sembunyikan Pemain, Hapus Part saat Disentuh oleh Pemain Lain, Dibawa Pemain Lain

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local player = Players.LocalPlayer

-- STATUS FITUR
local isLabelActive = false
local isHideActive = false
local isDeletePartActive = false
local isCarryActive = false

local ownerBillboard = nil
local escapeConnection = nil
local partBillboards = {}

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
frame.Size = UDim2.new(0, 360, 0, 700)
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
title.Text = "FITUR UTAMA"
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
-- LABEL PEMILIK
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
	label.Text = "👑 PEMILIK"
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
-- SEMBUNYIKAN PEMAIN
------------------------------------------------------------
local function toggleHidePlayers(state)
	isHideActive = state
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character then
			-- Sembunyikan karakter pemain lain jika state aktif
			plr.Character.Parent = state and nil or workspace
		end
	end
end

------------------------------------------------------------
-- HAPUS PART SAAT DISENTUH
------------------------------------------------------------
local function onPartTouched(part, otherPlayer)
	-- Hapus part jika pemain lain menyentuhnya
	if isDeletePartActive and otherPlayer and otherPlayer ~= player then
		-- Efek suara saat part dihancurkan
		local sound = Instance.new("Sound")
		sound.SoundId = "rbxassetid://12345678" -- Ganti dengan ID suara yang sesuai
		sound.Parent = part
		sound:Play()

		-- Efek visual (menghilangkan part dengan tween)
		local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
		local tweenGoal = {Transparency = 1}
		local tween = TweenService:Create(part, tweenInfo, tweenGoal)
		tween:Play()

		-- Menunggu tween selesai dan kemudian menghancurkan part
		tween.Completed:Connect(function()
			part:Destroy()
		end)
	end
end

local function toggleDeletePart(state)
	isDeletePartActive = state
	if state then
		for _, obj in pairs(workspace:GetDescendants()) do
			if obj:IsA("BasePart") then
				-- Tambahkan event Touched hanya untuk part
				obj.Touched:Connect(function(hit)
					onPartTouched(obj, hit.Parent)  -- Memeriksa siapa yang menyentuh part
				end)
			end
		end
	end
end

------------------------------------------------------------
-- DIBAWA PEMAIN LAIN
------------------------------------------------------------
local function toggleCarry(state)
	isCarryActive = state
	local char = player.Character
	if not char then return end
	local humanoidRootPart = char:FindFirstChild("HumanoidRootPart")
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not humanoidRootPart or not humanoid then return end
	
	if state then
		RunService.Heartbeat:Connect(function()
			for _, otherPlayer in pairs(Players:GetPlayers()) do
				if otherPlayer ~= player and otherPlayer.Character then
					local otherHumanoidRootPart = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
					if otherHumanoidRootPart and (otherHumanoidRootPart.Position - humanoidRootPart.Position).Magnitude < 5 then
						-- Dibawa oleh pemain lain
						humanoidRootPart.CFrame = otherHumanoidRootPart.CFrame * CFrame.new(0, 5, 0)  -- Sesuaikan offset jika perlu
					end
				end
			end
		end)
	else
		-- Reset posisi ke default jika fitur dibawa dimatikan
		humanoidRootPart.CFrame = humanoidRootPart.CFrame
	end
end

------------------------------------------------------------
-- SWITCH BUTTONS
------------------------------------------------------------
createSwitch("Label Pemilik", false, toggleOwnerLabel).Position = UDim2.new(0, 15, 0, 40)
createSwitch("Sembunyikan Pemain Lain", false, toggleHidePlayers).Position = UDim2.new(0, 15, 0, 85)
createSwitch("Hapus Part Saat Disentuh", false, toggleDeletePart).Position = UDim2.new(0, 15, 0, 130)
createSwitch("Dibawa Pemain Lain", false, toggleCarry).Position = UDim2.new(0, 15, 0, 175)

------------------------------------------------------------
-- CHARACTER SAFE RELOAD
------------------------------------------------------------
player.CharacterAdded:Connect(function(char)
	if isLabelActive then task.wait(1) createOwnerLabel() end
end)
