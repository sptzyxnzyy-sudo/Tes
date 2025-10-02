-- credit: Xraxor1 (Original GUI/Intro structure)
-- Modification & Features by Sptzyy

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

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

-- ScrollingFrame untuk daftar fitur
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

-- ================= FEATURE: ESP =================
local ESP_ENABLED = false
local tracers = {}
local function addESP(p)
    if p == player or not p.Character then return end
    if not p.Character:FindFirstChild("ESP_Highlight") then
        local h = Instance.new("Highlight")
        h.Name = "ESP_Highlight"
        h.FillColor = Color3.fromRGB(0,255,0)
        h.OutlineColor = Color3.fromRGB(255,255,255)
        h.FillTransparency = 0.6
        h.Parent = p.Character
    end
    if not p.Character:FindFirstChild("ESP_Name") and p.Character:FindFirstChild("Head") then
        local tag = Instance.new("BillboardGui")
        tag.Name = "ESP_Name"
        tag.Adornee = p.Character.Head
        tag.Size = UDim2.new(0,120,0,20)
        tag.StudsOffset = Vector3.new(0,2.5,0)
        tag.AlwaysOnTop = true
        tag.Parent = p.Character
        local txt = Instance.new("TextLabel")
        txt.Size = UDim2.new(1,0,1,0)
        txt.BackgroundTransparency = 1
        txt.Text = p.Name
        txt.TextColor3 = Color3.new(1,1,1)
        txt.Font = Enum.Font.GothamBold
        txt.TextSize = 14
        txt.Parent = tag
    end
    if not tracers[p] then
        local line = Drawing.new("Line")
        line.Color = Color3.fromRGB(0,255,0)
        line.Thickness = 2
        line.Visible = false
        tracers[p] = line
    end
end
local function removeESP(p)
    if p.Character then
        if p.Character:FindFirstChild("ESP_Highlight") then p.Character.ESP_Highlight:Destroy() end
        if p.Character:FindFirstChild("ESP_Name") then p.Character.ESP_Name:Destroy() end
    end
    if tracers[p] then tracers[p]:Remove() tracers[p]=nil end
end
RunService.RenderStepped:Connect(function()
    if not ESP_ENABLED or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        for _,line in pairs(tracers) do line.Visible=false end
        return
    end
    local myPos = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and tracers[p] then
            local pos,onScr = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
            if onScr then
                tracers[p].From = Vector2.new(myPos.X,myPos.Y)
                tracers[p].To = Vector2.new(pos.X,pos.Y)
                tracers[p].Visible = true
            else tracers[p].Visible=false end
        end
    end
end)
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function() if ESP_ENABLED then task.wait(1) addESP(p) end end)
end)
Players.PlayerRemoving:Connect(removeESP)

createToggle("ESP", featureScrollFrame, function(state)
    ESP_ENABLED = state
    if state then for _,pl in ipairs(Players:GetPlayers()) do if pl~=player then addESP(pl) end end
    else for _,pl in ipairs(Players:GetPlayers()) do if pl~=player then removeESP(pl) end end end
end)

-- ================= FEATURE: SPEED =================
local SPEED_ENABLED = false
local DEFAULT_SPEED = 16
local speedValue = 50
local function setSpeed(val)
    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = val end
end
createToggle("Speed", featureScrollFrame, function(state)
    SPEED_ENABLED = state
    if state then setSpeed(speedValue) else setSpeed(DEFAULT_SPEED) end
end)
local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(1, -10, 0, 35)
speedBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
speedBox.Text = tostring(speedValue)
speedBox.TextColor3 = Color3.new(1, 1, 1)
speedBox.Font = Enum.Font.GothamBold
speedBox.TextSize = 14
speedBox.ClearTextOnFocus = false
speedBox.Parent = featureScrollFrame
speedBox.FocusLost:Connect(function()
    local val = tonumber(speedBox.Text)
    if val then
        speedValue = val
        if SPEED_ENABLED then setSpeed(speedValue) end
    else
        speedBox.Text = tostring(speedValue)
    end
end)

-- ================= FEATURE: AURA =================
local AURA_ENABLED = false
local auraEffect
createToggle("Aura", featureScrollFrame, function(state)
    AURA_ENABLED = state
    if state then
        if player.Character and not auraEffect then
            auraEffect = Instance.new("ParticleEmitter")
            auraEffect.Rate = 50
            auraEffect.Texture = "rbxassetid://241594440" -- aura keren
            auraEffect.Lifetime = NumberRange.new(1,2)
            auraEffect.Speed = NumberRange.new(0,0)
            auraEffect.Rotation = NumberRange.new(0,360)
            auraEffect.RotSpeed = NumberRange.new(-90,90)
            auraEffect.Size = NumberSequence.new(1.5)
            auraEffect.Parent = player.Character:FindFirstChild("HumanoidRootPart")
        end
    else
        if auraEffect then auraEffect:Destroy() auraEffect=nil end
    end
end)

-- ================= FEATURE: INFINITE JUMP =================
local INFJUMP_ENABLED = false
createToggle("Infinite Jump", featureScrollFrame, function(state)
    INFJUMP_ENABLED = state
end)
UserInputService.JumpRequest:Connect(function()
    if INFJUMP_ENABLED and player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
        player.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

-- ================= FEATURE: FLY =================
local FLY_ENABLED = false
local flyVelocity
createToggle("Fly", featureScrollFrame, function(state)
    FLY_ENABLED = state
    if state then
        if player.Character and not flyVelocity then
            flyVelocity = Instance.new("BodyVelocity")
            flyVelocity.Velocity = Vector3.new(0,0,0)
            flyVelocity.MaxForce = Vector3.new(4000,4000,4000)
            flyVelocity.Parent = player.Character:FindFirstChild("HumanoidRootPart")
        end
    else
        if flyVelocity then flyVelocity:Destroy() flyVelocity=nil end
    end
end)
RunService.RenderStepped:Connect(function()
    if FLY_ENABLED and flyVelocity then
        local move = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move=move+Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move=move-Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move=move-Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move=move+Camera.CFrame.RightVector end
        flyVelocity.Velocity = move*50
    end
end)