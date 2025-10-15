-- Services
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- Core Status
local isTetherActive = false
local tetherTouchConnection = nil
local activeTethers = {}

-- Kohl's Admin Config
local ROOT_NAME = "Kohl's Admin Source"
local REMOTE_NAME = "VIPUGCMethod"
local COOLDOWN = 1
local lastCall = 0
local attachedLogger = false
local loggerConnection

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
screenGui.Name = "CoreFeaturesGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 280, 0, 400)
frame.Position = UDim2.new(0.4, -140, 0.5, -200)
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
title.Text = "CORE FEATURES"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = frame

-- Scrollable list
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1,-20,1,-60)
scrollFrame.Position = UDim2.new(0,10,0,35)
scrollFrame.CanvasSize = UDim2.new(0,0,0,0)
scrollFrame.ScrollBarThickness = 6
scrollFrame.BackgroundTransparency = 1
scrollFrame.Parent = frame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0,5)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = scrollFrame

listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scrollFrame.CanvasSize = UDim2.new(0,0,0,listLayout.AbsoluteContentSize.Y+10)
end)

-- Status bar
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1,0,0,24)
statusLabel.Position = UDim2.new(0,0,1,-24)
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

-- =================================
-- 🔽 FUNGSI FITUR UTILITY 🔽
-- =================================
local function updateButtonStatus(button,isActive,name)
    if not button then return end
    local n = name or button.Name:gsub("Button",""):gsub("_"," "):upper()
    if isActive then
        button.Text = n..": ON"
        button.BackgroundColor3 = Color3.fromRGB(0,180,0)
    else
        button.Text = n..": OFF"
        button.BackgroundColor3 = Color3.fromRGB(150,0,0)
    end
end

-- =================================
-- 🔽 PLAYER TETHER 🔽
-- =================================
local function onTetherTouch(otherPart)
    if not isTetherActive or not otherPart or not otherPart.Parent then return end
    local targetPlayer = Players:GetPlayerFromCharacter(otherPart.Parent)
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local targetRoot = targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot or not targetRoot or targetPlayer==LocalPlayer then return end
    if not activeTethers[targetPlayer.UserId] then
        local weld = Instance.new("WeldConstraint")
        weld.Part0 = myRoot
        weld.Part1 = targetRoot
        weld.Parent = targetRoot
        activeTethers[targetPlayer.UserId]=weld
        print("Tether Aktif: "..targetPlayer.Name)
    end
end

local function releaseAllTethers()
    for _,weld in pairs(activeTethers) do if weld and weld.Parent then weld:Destroy() end end
    activeTethers = {}
end

local function activateTether(button)
    if isTetherActive then return end
    local rootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not rootPart then warn("HumanoidRootPart tidak ditemukan"); return end
    isTetherActive = true
    updateButtonStatus(button,true,"PLAYER TETHER")
    if tetherTouchConnection then tetherTouchConnection:Disconnect() end
    tetherTouchConnection=rootPart.Touched:Connect(onTetherTouch)
end

local function deactivateTether(button)
    if not isTetherActive then return end
    isTetherActive=false
    if tetherTouchConnection then tetherTouchConnection:Disconnect() tetherTouchConnection=nil end
    releaseAllTethers()
    updateButtonStatus(button,false,"PLAYER TETHER")
end

-- =================================
-- 🔽 KOHL'S ADMIN TOOL FUNCTIONS (PRESET) 🔽
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

local function scanRemotes(button)
    setStatus("Scanning...")
    local root = safeFindRoot()
    if not root then setStatus("Root not found"); return end
    local found={}
    for _,v in ipairs(root:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then table.insert(found,v) end
    end
    setStatus("Scan complete. Check console.")
    print("==== Scan Results ====")
    for i,v in ipairs(found) do print(i,v:GetFullName(),v.ClassName) end
end

local function attachLogger(button)
    if attachedLogger then
        if loggerConnection then loggerConnection:Disconnect() end
        attachedLogger=false
        setStatus("Logger detached")
        return
    end
    local remote = findRemote()
    if not remote then setStatus("Remote not found"); return end
    loggerConnection = remote.OnClientEvent:Connect(function(...)
        print("VIPUGCMethod fired:", ...)
        setStatus("Event printed to console")
    end)
    attachedLogger=true
    setStatus("Logger attached")
end

local function callVIPUGC(button)
    local now = tick()
    if now-lastCall<COOLDOWN then setStatus(("Cooldown %.1fs"):format(COOLDOWN-(now-lastCall))) return end
    local remote = findRemote()
    if not remote then setStatus("Remote not found"); return end
    local args = {92807314389236,"rbxassetid://89119211625300",true,"Gold Wings"} -- preset args
    local ok,err=pcall(function() remote:FireServer(unpack(args)) end)
    if ok then setStatus("Call sent")
    else setStatus("Error: "..tostring(err)) end
    lastCall=now
end

-- =================================
-- 🔽 PEMBUAT TOMBOL FITUR 🔽
-- =================================
local function makeButton(name,color,callback)
    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(0,240,0,40)
    btn.BackgroundColor3=color
    btn.Text=name
    btn.TextColor3=Color3.new(1,1,1)
    btn.Font=Enum.Font.GothamBold
    btn.TextSize=14
    btn.Parent=scrollFrame
    local corner=Instance.new("UICorner")
    corner.CornerRadius=UDim.new(0,10)
    corner.Parent=btn
    btn.MouseButton1Click:Connect(function() callback(btn) end)
    return btn
end

-- Tambahkan tombol
local tetherBtn = makeButton("PLAYER TETHER: OFF", Color3.fromRGB(150,0,0), function(btn)
    if isTetherActive then deactivateTether(btn)
    else activateTether(btn) end
end)

makeButton("Scan Remotes", Color3.fromRGB(0,120,200), scanRemotes)
makeButton("Attach Logger", Color3.fromRGB(0,200,120), attachLogger)
makeButton("Call VIPUGCMethod", Color3.fromRGB(200,120,0), callVIPUGC)

-- =================================
-- 🔽 MAINTAIN STATUS CHARACTER ADDED 🔽
-- =================================
LocalPlayer.CharacterAdded:Connect(function(char)
    releaseAllTethers()
    if isTetherActive then
        char:WaitForChild("HumanoidRootPart",5)
        local btn=scrollFrame:FindFirstChild("PLAYER TETHERButton")
        if btn then activateTether(btn) end
    end
end)

-- =================================
-- 🔽 TOGGLE GUI