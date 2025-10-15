-- Services
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

-- Kohl's Admin Config
local ROOT_NAME = "Kohl's Admin Source"
local REMOTE_NAME = "VIPUGCMethod"
local COOLDOWN = 1
local lastCall = 0
local attachedLogger = false
local loggerConnection

-- =================================
-- 🔽 ANIMASI INTRO 🔽
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

    local tweenMove = TweenService:Create(introLabel, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Position = UDim2.new(0.5, -150, 0.42, 0)})
    local tweenColor = TweenService:Create(introLabel, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {TextColor3 = Color3.fromRGB(0,0,0)})

    tweenMove:Play()
    tweenColor:Play()
    task.wait(2)
    TweenService:Create(introLabel, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
    task.wait(0.5)
    introGui:Destroy()
end

-- =================================
-- 🔽 GUI UTAMA 🔽
-- =================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KohlsAdminGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 360, 0, 250)
frame.Position = UDim2.new(0.5, -180, 0.5, -125)
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
title.Text = "KOHL'S ADMIN TOOLKIT"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = frame

local featureScroll = Instance.new("ScrollingFrame")
featureScroll.Size = UDim2.new(1,-20,1,-40)
featureScroll.Position = UDim2.new(0,10,0,35)
featureScroll.CanvasSize = UDim2.new(0,0,0,0)
featureScroll.ScrollBarThickness = 6
featureScroll.BackgroundTransparency = 1
featureScroll.Parent = frame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0,5)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = featureScroll

listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    featureScroll.CanvasSize = UDim2.new(0,0,0,listLayout.AbsoluteContentSize.Y+10)
end)

-- Notifikasi helper
local function notify(title,text)
    StarterGui:SetCore("SendNotification",{
        Title = title,
        Text = text,
        Duration = 3
    })
end

-- =================================
-- 🔽 FUNGSI KOHL'S ADMIN 🔽
-- =================================
local function safeFindRoot()
    local ok,root=pcall(function() return ReplicatedStorage:FindFirstChild(ROOT_NAME) end)
    return ok and root or nil
end

local function findRemote()
    local root = safeFindRoot()
    if not root then return nil end
    local container = root:FindFirstChild("Remote") or root:FindFirstChildWhichIsA("Folder")
    if not container then return nil end
    return container:FindFirstChild(REMOTE_NAME) or container:FindFirstChildWhichIsA("RemoteEvent")
end

-- Toggle button helper
local function makeFeatureButton(name, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,240,0,40)
    btn.BackgroundColor3 = Color3.fromRGB(150,0,0)
    btn.Text = name..": OFF"
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Parent = featureScroll
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0,10)
    corner.Parent = btn

    local active = false
    btn.MouseButton1Click:Connect(function()
        active = not active
        if active then
            btn.Text = name..": ON"
            btn.BackgroundColor3 = Color3.fromRGB(0,180,0)
        else
            btn.Text = name..": OFF"
            btn.BackgroundColor3 = Color3.fromRGB(150,0,0)
        end
        callback(active)
    end)
end

-- Feature functions
local function scanRemotes(active)
    if not active then return end
    local root = safeFindRoot()
    if not root then notify("Scan Remotes","Root not found") return end
    local found={}
    for _,v in ipairs(root:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then table.insert(found,v) end
    end
    notify("Scan Remotes","Found "..#found.." remote(s).")
end

local function attachLogger(active)
    local remote = findRemote()
    if not remote then notify("Logger","Remote not found") return end
    if active then
        if loggerConnection then loggerConnection:Disconnect() end
        loggerConnection = remote.OnClientEvent:Connect(function(...)
            local args={...}
            notify("Logger Event","VIPUGCMethod fired! Args: "..table.concat(args,", "))
        end)
        notify("Logger","Logger attached")
    else
        if loggerConnection then loggerConnection:Disconnect() end
        notify("Logger","Logger detached")
    end
end

local function callVIPUGC(active)
    if not active then return end
    local now = tick()
    if now-lastCall<COOLDOWN then notify("VIPUGCMethod","Cooldown active") return end
    local remote = findRemote()
    if not remote then notify("VIPUGCMethod","Remote not found") return end
    local args = {92807314389236,"rbxassetid://89119211625300",true,"Gold Wings"}
    local ok,err=pcall(function() remote:FireServer(unpack(args)) end)
    if ok then notify("VIPUGCMethod","Call sent successfully") else notify("VIPUGCMethod","Error sending call") end
    lastCall=now
end

-- Add buttons
makeFeatureButton("Scan Remotes", scanRemotes)
makeFeatureButton("Attach Logger", attachLogger)
makeFeatureButton("Call VIPUGCMethod", callVIPUGC)

-- Initial notification
notify("Core Features GUI","Ready. Toggle buttons to test features.")