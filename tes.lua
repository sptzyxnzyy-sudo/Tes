-- credit: Xraxor1 (Original GUI/Intro structure)
-- Modification: Tambah ESP + Speed Feature dengan toggle

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local player = Players.LocalPlayer

-- 🔽 ANIMASI "BY : Xraxor" 🔽
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

-- 🔽 GUI Utama 🔽
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CoreFeaturesGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Frame utama
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 120) 
frame.Position = UDim2.new(0.4, -110, 0.5, -60)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 15)
corner.Parent = frame

-- Judul GUI
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "CORE FEATURES"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = frame

-- ScrollingFrame untuk daftar fitur
local featureScrollFrame = Instance.new("ScrollingFrame")
featureScrollFrame.Name = "FeatureList"
featureScrollFrame.Size = UDim2.new(1, -20, 1, -40)
featureScrollFrame.Position = UDim2.new(0.5, -100, 0, 35)
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

-- 🔽 FUNGSI BUAT TOGGLE 🔽
local function createToggle(text, parent, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.Text = text .. ": OFF"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Parent = parent

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        if state then
            btn.Text = text .. ": ON"
            btn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        else
            btn.Text = text .. ": OFF"
            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        end
        callback(state)
    end)

    return btn
end

-- 🔽 FITUR ESP 🔽
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
    p.CharacterAdded:Connect(function()
        if ESP_ENABLED then task.wait(1) addESP(p) end
    end)
end)
Players.PlayerRemoving:Connect(removeESP)

-- 🔽 FITUR SPEED 🔽
local SPEED_ENABLED = false
local DEFAULT_SPEED = 16
local speedValue = 50

local function setSpeed(val)
    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = val end
end

-- 🔽 TAMBAHKAN TOGGLE KE MENU 🔽
createToggle("ESP", featureScrollFrame, function(state)
    ESP_ENABLED = state
    if state then
        for _,pl in ipairs(Players:GetPlayers()) do if pl~=player then addESP(pl) end end
    else
        for _,pl in ipairs(Players:GetPlayers()) do if pl~=player then removeESP(pl) end end
    end
end)

createToggle("Speed", featureScrollFrame, function(state)
    SPEED_ENABLED = state
    if state then
        setSpeed(speedValue)
    else
        setSpeed(DEFAULT_SPEED)
    end
end)

-- 🔽 INPUT SPEED 🔽
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