--// Fling by danya23131 + Neon Toggle UI by Sptzyy
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local mouse = player:GetMouse()

--// Fungsi notifikasi
local function send(text)
	StarterGui:SetCore("SendNotification", {
		Title = "Fling by danya23131",
		Text = text,
		Duration = 5
	})
end

--// GUI Neon Switch
local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
ScreenGui.Name = "FlingNeonSwitch"

local ToggleButton = Instance.new("TextButton", ScreenGui)
ToggleButton.Size = UDim2.new(0, 100, 0, 35)
ToggleButton.Position = UDim2.new(1, -120, 0, 30)
ToggleButton.BackgroundTransparency = 0.3
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
ToggleButton.Text = "FLING: OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255,255,255)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 18
ToggleButton.BorderSizePixel = 0
ToggleButton.AutoButtonColor = false
ToggleButton.Draggable = true

-- Efek neon-glow
local UIStroke = Instance.new("UIStroke", ToggleButton)
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(255, 70, 70)
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local UICorner = Instance.new("UICorner", ToggleButton)
UICorner.CornerRadius = UDim.new(0, 8)

-- Efek hover animasi
ToggleButton.MouseEnter:Connect(function()
	TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
		BackgroundTransparency = 0.1
	}):Play()
end)
ToggleButton.MouseLeave:Connect(function()
	TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
		BackgroundTransparency = 0.3
	}):Play()
end)

--// Variabel utama
local flingEnabled = false
local fakepart, att1, att2, body, partic

--// Fungsi aktifkan fling
local function startFling()
	if flingEnabled then return end
	flingEnabled = true
	ToggleButton.Text = "FLING: ON"
	UIStroke.Color = Color3.fromRGB(0,255,100)
	ToggleButton.BackgroundColor3 = Color3.fromRGB(50,255,100)
	send("⚡ Fling Mode Activated")

	fakepart = Instance.new("Part", workspace)
	att1 = Instance.new("Attachment", fakepart)
	att2 = Instance.new("Attachment", player.Character.HumanoidRootPart)
	body = Instance.new("AlignPosition", fakepart)
	body.Attachment0 = att2
	body.Attachment1 = att1
	body.RigidityEnabled = true
	body.Responsiveness = math.huge
	body.MaxForce = math.huge
	body.MaxVelocity = math.huge
	body.MaxAxesForce = Vector3.new(math.huge, math.huge, math.huge)
	body.Mode = Enum.PositionAlignmentMode.TwoAttachment

	fakepart.Anchored = true
	fakepart.Size = Vector3.new(5,5,5)
	fakepart.Position = player.Character.HumanoidRootPart.Position
	fakepart.CanCollide = false
	fakepart.Transparency = 0.5
	fakepart.Material = Enum.Material.ForceField

	partic = Instance.new("ParticleEmitter", fakepart)
	partic.Texture = "rbxassetid://15273937357"
	partic.SpreadAngle = Vector2.new(-180,180)
	partic.Rate = 45
	partic.Size = NumberSequence.new(1,0)
	partic.Transparency = NumberSequence.new(0.9)
	partic.Lifetime = NumberRange.new(0.7,1)
	partic.RotSpeed = NumberRange.new(-45,45)

	RunService.Heartbeat:Connect(function()
		if not flingEnabled then return end
		player.Character.HumanoidRootPart.Velocity = Vector3.new(
			math.random(-250,250),
			math.random(-500,500),
			math.random(-250,250)
		)
	end)
end

--// Fungsi matikan fling
local function stopFling()
	if not flingEnabled then return end
	flingEnabled = false
	ToggleButton.Text = "FLING: OFF"
	UIStroke.Color = Color3.fromRGB(255,70,70)
	ToggleButton.BackgroundColor3 = Color3.fromRGB(255,50,50)
	send("⛔ Fling Mode Deactivated")

	if fakepart then fakepart:Destroy() end
	if partic then partic:Destroy() end
end

--// Tombol toggle
ToggleButton.MouseButton1Click:Connect(function()
	if flingEnabled then
		stopFling()
	else
		startFling()
	end
end)

--// Pesan awal
send("Klik tombol neon kanan atas untuk ON/OFF fling mode ⚙️")