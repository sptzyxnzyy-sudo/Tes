-- Services
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

-- =================================
-- 🔽 ANIMASI "BY : Xraxor" 🔽
-- =================================
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

-- =================================
-- 🔽 GUI UTAMA (List-based Menu) 🔽
-- =================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KohlAdminListGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 260)
frame.Position = UDim2.new(0.4, -110, 0.5, -130)
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
title.Text = "KOHL'S ADMIN TOOLKIT"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = frame

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

-- =================================
-- 🔽 KOHL'S ADMIN TOOL FEATURES 🔽
-- =================================
local ROOT_NAME = "Kohl's Admin Source"
local REMOTE_NAME = "VIPUGCMethod"
local COOLDOWN = 1
local attachedLogger = false
local lastCall = 0
local loggerConnection

local function safeFindRoot()
    local ok, root = pcall(function()
        return ReplicatedStorage:FindFirstChild(ROOT_NAME)
    end)
    return ok and root or nil
end

local function findRemote()
    local root = safeFindRoot()
    if not root then return nil end
    local remoteContainer = root:FindFirstChild("Remote") or root:FindFirstChildWhichIsA("Folder")
    if not remoteContainer then return nil end
    return remoteContainer:FindFirstChild(REMOTE_NAME) or remoteContainer:FindFirstChildWhichIsA("RemoteEvent")
end

-- Fungsi buat tombol fitur
local function makeFeatureButton(name, color, callback)
    local featButton = Instance.new("TextButton")
    featButton.Size = UDim2.new(0, 180, 0, 40)
    featButton.BackgroundColor3 = color
    featButton.Text = name
    featButton.TextColor3 = Color3.new(1,1,1)
    featButton.Font = Enum.Font.GothamBold
    featButton.TextSize = 12
    featButton.Parent = featureScrollFrame

    local featCorner = Instance.new("UICorner")
    featCorner.CornerRadius = UDim.new(0, 10)
    featCorner.Parent = featButton

    featButton.MouseButton1Click:Connect(function()
        callback(featButton)
    end)
end

-- STATUS LABEL
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -10, 0, 24)
statusLabel.Position = UDim2.new(0, 5, 1, -28)
statusLabel.BackgroundTransparency = 0.3
statusLabel.BackgroundColor3 = Color3.fromRGB(30,30,30)
statusLabel.Text = "Status: Idle"
statusLabel.TextColor3 = Color3.new(1,1,1)
statusLabel.Font = Enum.Font.SourceSansBold
statusLabel.TextSize = 14
statusLabel.Parent = frame

local function setStatus(txt)
    statusLabel.Text = "Status: "..tostring(txt)
end

-- Inputs
local function makeLabelInput(text, y, default)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, 80, 0, 20)
    lbl.Position = UDim2.new(0, 5, 0, y)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.new(1,1,1)
    lbl.Font = Enum.Font.SourceSans
    lbl.TextSize = 14
    lbl.Parent = frame

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0, 120, 0, 20)
    box.Position = UDim2.new(0, 90, 0, y)
    box.Text = default or ""
    box.ClearTextOnFocus = false
    box.Font = Enum.Font.SourceSans
    box.TextSize = 14
    box.TextColor3 = Color3.new(0,0,0)
    box.Parent = frame

    return box
end

local idBox = makeLabelInput("ID:", 40, "92807314389236")
local assetBox = makeLabelInput("Asset URI:", 70, "rbxassetid://89119211625300")
local flagBox = makeLabelInput("Flag:", 100, "true")
local nameBox = makeLabelInput("Display:", 130, "Gold Wings")

-- Tombol fitur
makeFeatureButton("Scan Remotes", Color3.fromRGB(0,120,200), function()
    setStatus("Scanning...")
    local root = safeFindRoot()
    if not root then
        setStatus("Root not found")
        return
    end
    local found = {}
    for _,v in ipairs(root:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            table.insert(found, v)
        end
    end
    setStatus(("Found %d remote(s). Check console"):format(#found))
    print("==== Scan Results ====")
    for i,v in ipairs(found) do
        print(i,v:GetFullName(),v.ClassName)
    end
end)

makeFeatureButton("Attach Logger", Color3.fromRGB(0,200,120), function()
    if attachedLogger then
        if loggerConnection then loggerConnection:Disconnect() end
        attachedLogger = false
        setStatus("Logger detached")
        return
    end
    local remote = findRemote()
    if not remote then setStatus("Remote not found"); return end
    loggerConnection = remote.OnClientEvent:Connect(function(...)
        print("VIPUGCMethod OnClientEvent fired", ...)
        setStatus("Event printed to console")
    end)
    attachedLogger = true
    setStatus("Logger attached")
end)

makeFeatureButton("Call VIPUGCMethod", Color3.fromRGB(200,120,0), function()
    local now = tick()
    if now - lastCall < COOLDOWN then
        setStatus(("Cooldown: wait %.1fs"):format(COOLDOWN-(now-lastCall)))
        return
    end
    local remote = findRemote()
    if not remote then setStatus("Remote not found"); return end
    local args = {
        tonumber(idBox.Text) or idBox.Text,
        assetBox.Text,
        (flagBox.Text:lower()=="true"),
        nameBox.Text
    }
    local ok,err = pcall(function() remote:FireServer(unpack(args)) end)
    if ok then setStatus("Call sent")
    else setStatus("Error: "..tostring(err)) end
    lastCall = now
end)