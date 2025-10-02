-- credit: Xraxor1 (Original GUI/Intro structure)
-- Modification & Features by Sptzyy
-- Features: ESP, Speed, Aura, Infinite Jump, Auto Big Fish Catch

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ================= INTRO ANIMATION =================
do
    local introGui = Instance.new("ScreenGui")
    introGui.Name = "IntroAnimation"
    introGui.ResetOnSpawn = false
    introGui.Parent = player:WaitForChild("PlayerGui")

    local introLabel = Instance.new("TextLabel")
    introLabel.Size = UDim2.new(0, 300, 0, 50)
    introLabel.Position = UDim2.new(0.5, -150, 0.4, 0)
    introLabel.BackgroundTransparency = 1
    introLabel.Text = "By : Sptzyy"
    introLabel.TextColor3 = Color3.fromRGB(40, 40, 40)
    introLabel.TextScaled = true
    introLabel.Font = Enum.Font.GothamBold
    introLabel.Parent = introGui

    local tweenInfoMove = TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
    local tweenMove = TweenService:Create(introLabel, tweenInfoMove, {Position = UDim2.new(0.5, -150, 0.42, 0)})

    tweenMove:Play()

    task.wait(2)
    local fadeOut = TweenService:Create(introLabel, TweenInfo.new(0.5), {TextTransparency = 1})
    fadeOut:Play()
    fadeOut.Completed:Connect(function()
        introGui:Destroy()
    end)
end

-- ================= CORE GUI =================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CoreFeaturesGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 350)
frame.Position = UDim2.new(0.4, -125, 0.5, -175)
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

-- ❌ Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(1, -30, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.Parent = frame

local cornerClose = Instance.new("UICorner")
cornerClose.CornerRadius = UDim.new(1, 0)
cornerClose.Parent = closeBtn

-- Tombol kecil buat buka menu lagi
local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 40, 0, 40)
openBtn.Position = UDim2.new(0, 10, 1, -50)
openBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
openBtn.Text = "≡"
openBtn.TextColor3 = Color3.new(1, 1, 1)
openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = 20
openBtn.Visible = false
openBtn.Parent = screenGui

local cornerOpen = Instance.new("UICorner")
cornerOpen.CornerRadius = UDim.new(1, 0)
cornerOpen.Parent = openBtn

closeBtn.MouseButton1Click:Connect(function()
    frame.Visible = false
    openBtn.Visible = true
end)
openBtn.MouseButton1Click:Connect(function()
    frame.Visible = true
    openBtn.Visible = false
end)

-- Scroll fitur
local featureScrollFrame = Instance.new("ScrollingFrame")
featureScrollFrame.Name = "FeatureList"
featureScrollFrame.Size = UDim2.new(1, -20, 1, -40)
featureScrollFrame.Position = UDim2.new(0, 10, 0, 35)
featureScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
featureScrollFrame.ScrollBarThickness = 6
featureScrollFrame.BackgroundTransparency = 1
featureScrollFrame.Parent = frame

local featureListLayout = Instance.new("UIListLayout")
featureListLayout.Padding = UDim.new(0, 5)
featureListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
featureListLayout.SortOrder = Enum.SortOrder.LayoutOrder
featureListLayout.Parent = featureScrollFrame
featureListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    featureScrollFrame.CanvasSize = UDim2.new(0, 0, 0, featureListLayout.AbsoluteContentSize.Y + 10)
end)

-- ================= TOGGLE CREATOR =================
local function createToggle(name, parent, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.Text = name .. ": OFF"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Parent = parent

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        if state then
            btn.Text = name .. ": ON"
            btn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        else
            btn.Text = name .. ": OFF"
            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        end
        callback(state)
    end)
    return btn
end

--------------------------------------------------------
-- FEATURE 1: ESP
--------------------------------------------------------
local ESP_ENABLED = false
local tracers = {}

local function createESP(target)
    if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local billboard = Instance.new("BillboardGui")
        billboard.Adornee = target.Character.HumanoidRootPart
        billboard.Size = UDim2.new(0, 100, 0, 50)
        billboard.AlwaysOnTop = true
        billboard.Name = "ESP_" .. target.Name

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 0, 20)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = target.Name
        nameLabel.TextColor3 = Color3.new(1, 1, 0)
        nameLabel.TextScaled = true
        nameLabel.Parent = billboard

        billboard.Parent = target.Character

        local line = Drawing.new("Line")
        line.Color = Color3.fromRGB(0,255,0)
        line.Thickness = 2
        line.Visible = true
        tracers[target] = line
    end
end

local function removeESP(target)
    if target.Character then
        local esp = target.Character:FindFirstChild("ESP_" .. target.Name)
        if esp then esp:Destroy() end
    end
    if tracers[target] then
        tracers[target]:Remove()
        tracers[target] = nil
    end
end

createToggle("Player ESP", featureScrollFrame, function(state)
    ESP_ENABLED = state
    if not state then
        for _,p in pairs(Players:GetPlayers()) do
            if p ~= player then removeESP(p) end
        end
    else
        for _,p in pairs(Players:GetPlayers()) do
            if p ~= player then createESP(p) end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if ESP_ENABLED then
        for target,line in pairs(tracers) do
            if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = target.Character.HumanoidRootPart
                local pos,vis = Camera:WorldToViewportPoint(hrp.Position)
                if vis then
                    line.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                    line.To = Vector2.new(pos.X, pos.Y)
                    line.Visible = true
                else
                    line.Visible = false
                end
            end
        end
    end
end)

--------------------------------------------------------
-- FEATURE 2: SPEED
--------------------------------------------------------
local SPEED_ENABLED = false
local SpeedValue = 50

local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(1, -10, 0, 30)
speedBox.PlaceholderText = "Speed Value (50)"
speedBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
speedBox.TextColor3 = Color3.new(1,1,1)
speedBox.Font = Enum.Font.GothamBold
speedBox.TextSize = 14
speedBox.Parent = featureScrollFrame

speedBox.FocusLost:Connect(function()
    local val = tonumber(speedBox.Text)
    if val then SpeedValue = val end
end)

createToggle("Speed Hack", featureScrollFrame, function(state)
    SPEED_ENABLED = state
end)

RunService.Stepped:Connect(function()
    if SPEED_ENABLED and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = SpeedValue
    elseif player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = 16
    end
end)

--------------------------------------------------------
-- FEATURE 3: AURA EFFECT
--------------------------------------------------------
local AURA_ENABLED = false
local auraPart = nil

createToggle("Aura Effect", featureScrollFrame, function(state)
    AURA_ENABLED = state
    if state then
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            auraPart = Instance.new("ParticleEmitter")
            auraPart.Texture = "rbxassetid://3018122091"
            auraPart.Rate = 15
            auraPart.Lifetime = NumberRange.new(1)
            auraPart.Speed = NumberRange.new(2)
            auraPart.Parent = player.Character.HumanoidRootPart
        end
    else
        if auraPart then
            auraPart:Destroy()
            auraPart = nil
        end
    end
end)

--------------------------------------------------------
-- FEATURE 4: INFINITE JUMP
--------------------------------------------------------
local INFJUMP_ENABLED = false

createToggle("Infinite Jump", featureScrollFrame, function(state)
    INFJUMP_ENABLED = state
end)

UserInputService.JumpRequest:Connect(function()
    if INFJUMP_ENABLED and player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
        player.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

--------------------------------------------------------
-- FEATURE 5: AUTO BIG FISH
--------------------------------------------------------
local AUTOFISH_ENABLED = false
local BigFishList = {"Shark","Whale","GoldenFish","LegendaryTuna"}

local function autoFish()
    while AUTOFISH_ENABLED do
        task.wait(2)
        -- cari pancing
        local rod = player.Backpack:FindFirstChild("FishingRod") or (player.Character and player.Character:FindFirstChild("FishingRod"))
        if rod then
            local fishName = BigFishList[math.random(1,#BigFishList)]
            print("[AUTO BIG FISH] Menangkap: " .. fishName)

            -- cari remote yang biasa dipakai untuk pancing
            local catchRemote = ReplicatedStorage:FindFirstChild("CatchFish") or ReplicatedStorage:FindFirstChild("RemoteEvent") 
            if catchRemote and catchRemote:IsA("RemoteEvent") then
                catchRemote:FireServer(fishName,true) -- true = langsung sukses
            end
        end
    end
end

createToggle("Auto Big Fish", featureScrollFrame, function(state)
    AUTOFISH_ENABLED = state
    if state then
        task.spawn(autoFish)
    end
end)