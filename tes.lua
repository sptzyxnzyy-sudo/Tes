-- credit: Xraxor1 (Original GUI/Intro structure)
-- Modification: ESP + Toggle + Speed Hack

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- 🔽 ANIMASI "BY : Xraxor" 🔽
do
    local introGui = Instance.new("ScreenGui")
    introGui.Name = "IntroAnimation"
    introGui.ResetOnSpawn = false
    introGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local introLabel = Instance.new("TextLabel")
    introLabel.Size = UDim2.new(0, 300, 0, 50)
    introLabel.Position = UDim2.new(0.5, -150, 0.4, 0)
    introLabel.BackgroundTransparency = 1
    introLabel.Text = "By : Xraxor"
    introLabel.TextColor3 = Color3.fromRGB(40, 40, 40)
    introLabel.TextScaled = true
    introLabel.Font = Enum.Font.GothamBold
    introLabel.Parent = introGui

    local tweenInfoMove = TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
    local tweenMove = TweenService:Create(introLabel, tweenInfoMove, {Position = UDim2.new(0.5, -150, 0.42, 0)})

    local tweenInfoColor = TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
    local tweenColor = TweenService:Create(introLabel, tweenInfoColor, {TextColor3 = Color3.fromRGB(0, 0, 0)})

    tweenMove:Play()
    tweenColor:Play()

    task.wait(2)
    local fadeOut = TweenService:Create(introLabel, TweenInfo.new(0.5), {TextTransparency = 1})
    fadeOut:Play()
    fadeOut.Completed:Connect(function()
        introGui:Destroy()
    end)
end

-- 🔽 MENU GUI 🔽
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HackMenu"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0,200,0,200)
mainFrame.Position = UDim2.new(0,20,0,100)
mainFrame.BackgroundColor3 = Color3.fromRGB(40,40,40)
mainFrame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,30)
title.BackgroundColor3 = Color3.fromRGB(20,20,20)
title.Text = "Menu Hack"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = mainFrame

-- 🔽 ESP BUTTON 🔽
local espButton = Instance.new("TextButton")
espButton.Size = UDim2.new(1,-10,0,30)
espButton.Position = UDim2.new(0,5,0,40)
espButton.BackgroundColor3 = Color3.fromRGB(60,60,60)
espButton.Text = "ESP: OFF"
espButton.TextColor3 = Color3.new(1,1,1)
espButton.Font = Enum.Font.GothamBold
espButton.TextSize = 16
espButton.Parent = mainFrame

-- 🔽 SPEED TEXTBOX 🔽
local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(1,-10,0,30)
speedBox.Position = UDim2.new(0,5,0,80)
speedBox.BackgroundColor3 = Color3.fromRGB(60,60,60)
speedBox.Text = "50" -- default speed value
speedBox.TextColor3 = Color3.new(1,1,1)
speedBox.Font = Enum.Font.GothamBold
speedBox.TextSize = 16
speedBox.Parent = mainFrame

-- 🔽 SPEED BUTTON 🔽
local speedButton = Instance.new("TextButton")
speedButton.Size = UDim2.new(1,-10,0,30)
speedButton.Position = UDim2.new(0,5,0,120)
speedButton.BackgroundColor3 = Color3.fromRGB(60,60,60)
speedButton.Text = "Speed: OFF"
speedButton.TextColor3 = Color3.new(1,1,1)
speedButton.Font = Enum.Font.GothamBold
speedButton.TextSize = 16
speedButton.Parent = mainFrame

-- ====== ESP SYSTEM ======
local ESP_ENABLED = false
local tracers = {}

local function addESP(player)
	if player == LocalPlayer or not player.Character then return end
	if not player.Character:FindFirstChild("ESP_Highlight") then
		local h = Instance.new("Highlight")
		h.Name = "ESP_Highlight"
		h.FillColor = Color3.fromRGB(0,255,0)
		h.OutlineColor = Color3.fromRGB(255,255,255)
		h.FillTransparency = 0.6
		h.OutlineTransparency = 0
		h.Parent = player.Character
	end
	if not player.Character:FindFirstChild("ESP_NameTag") and player.Character:FindFirstChild("Head") then
		local tag = Instance.new("BillboardGui")
		tag.Name = "ESP_NameTag"
		tag.Adornee = player.Character.Head
		tag.Size = UDim2.new(0,150,0,20)
		tag.StudsOffset = Vector3.new(0,2.5,0)
		tag.AlwaysOnTop = true
		tag.Parent = player.Character
		local text = Instance.new("TextLabel")
		text.Size = UDim2.new(1,0,1,0)
		text.BackgroundTransparency = 1
		text.Text = player.Name
		text.TextColor3 = Color3.fromRGB(255,255,255)
		text.Font = Enum.Font.GothamBold
		text.TextSize = 14
		text.Parent = tag
	end
	if not tracers[player] then
		local line = Drawing.new("Line")
		line.Color = Color3.fromRGB(0,255,0)
		line.Thickness = 1.8
		line.Visible = false
		tracers[player] = line
	end
end

local function removeESP(player)
	if player.Character then
		if player.Character:FindFirstChild("ESP_Highlight") then player.Character.ESP_Highlight:Destroy() end
		if player.Character:FindFirstChild("ESP_NameTag") then player.Character.ESP_NameTag:Destroy() end
	end
	if tracers[player] then
		tracers[player]:Remove()
		tracers[player] = nil
	end
end

espButton.MouseButton1Click:Connect(function()
	ESP_ENABLED = not ESP_ENABLED
	if ESP_ENABLED then
		espButton.Text = "ESP: ON"
		espButton.BackgroundColor3 = Color3.fromRGB(0,170,0)
		for _,p in pairs(Players:GetPlayers()) do
			if p ~= LocalPlayer then addESP(p) end
		end
	else
		espButton.Text = "ESP: OFF"
		espButton.BackgroundColor3 = Color3.fromRGB(60,60,60)
		for _,p in pairs(Players:GetPlayers()) do
			if p ~= LocalPlayer then removeESP(p) end
		end
	end
end)

RunService.RenderStepped:Connect(function()
	if not ESP_ENABLED then
		for _,line in pairs(tracers) do line.Visible = false end
		return
	end
	if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
	local myPos, onScreen = Camera:WorldToViewportPoint(LocalPlayer.Character.HumanoidRootPart.Position)
	for _,p in pairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and tracers[p] then
			local targetPos, onScr = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
			if onScreen and onScr then
				tracers[p].From = Vector2.new(myPos.X, myPos.Y)
				tracers[p].To = Vector2.new(targetPos.X, targetPos.Y)
				tracers[p].Visible = true
			else
				tracers[p].Visible = false
			end
		end
	end
end)

Players.PlayerAdded:Connect(function(p)
	p.CharacterAdded:Connect(function()
		if ESP_ENABLED then
			task.wait(1)
			addESP(p)
		end
	end)
end)
Players.PlayerRemoving:Connect(function(p) removeESP(p) end)

-- ====== SPEED SYSTEM ======
local SPEED_ENABLED = false
local DEFAULT_SPEED = 16

speedButton.MouseButton1Click:Connect(function()
	SPEED_ENABLED = not SPEED_ENABLED
	if SPEED_ENABLED then
		speedButton.Text = "Speed: ON"
		speedButton.BackgroundColor3 = Color3.fromRGB(0,170,0)
		local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if hum then
			local spd = tonumber(speedBox.Text) or 50
			hum.WalkSpeed = spd
		end
	else
		speedButton.Text = "Speed: OFF"
		speedButton.BackgroundColor3 = Color3.fromRGB(60,60,60)
		local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.WalkSpeed = DEFAULT_SPEED
		end
	end
end)

-- update kalau speedBox diganti saat aktif
speedBox.FocusLost:Connect(function()
	if SPEED_ENABLED then
		local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if hum then
			local spd = tonumber(speedBox.Text) or 50
			hum.WalkSpeed = spd
		end
	end
end)