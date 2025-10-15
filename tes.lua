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
frame.Size = UDim2.new(0, 320, 0, 360)
frame.Position = UDim2.new(0.4, -160, 0.5, -180)
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
title.Text = "CORE FEATURES + CONSOLE"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = frame

-- Scrollable list untuk tombol
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1,-20,0,140)
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

-- TextBox console multi-line
local consoleBox = Instance.new("TextBox")
consoleBox.Size = UDim2.new(1,-20,1,-200)
consoleBox.Position = UDim2.new(0,10,0,180)
consoleBox.BackgroundColor3 = Color3.fromRGB(30,30,30)
consoleBox.TextColor3 = Color3.new(1,1,1)
consoleBox.Font = Enum.Font.SourceSans
consoleBox.TextSize = 14
consoleBox.MultiLine = true
consoleBox.ClearTextOnFocus = false
consoleBox.TextWrapped = true
consoleBox.TextXAlignment = Enum.TextXAlignment.Left
consoleBox.TextYAlignment = Enum.TextYAlignment.Top
consoleBox.Text = ""
consoleBox.ReadOnly = true -- user bisa copy tapi tidak bisa ketik
consoleBox.Parent = frame

local function appendConsole(text)
    consoleBox.Text = consoleBox.Text .. "\n" .. text
    consoleBox.CanvasPosition = Vector2.new(0, consoleBox.TextBounds.Y) -- auto scroll
end

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

local function notify(title,text)
    StarterGui:SetCore("SendNotification",{
        Title = title,
        Text = text,
        Duration = 3
    })
    appendConsole(title..": "..text)
end

-- =================================
-- 🔽 KOHL'S ADMIN TOOL FUNCTIONS 🔽
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
    if not root then 
        setStatus("Root not found")
        notify("Scan Remotes", "Root not found")
        return 
    end
    local found={}
    for _,v in ipairs(root:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then table.insert(found,v) end
    end
    setStatus("Scan complete. Check console.")
    notify("Scan Remotes", "Found "..#found.." remote(s). Check console.")
    appendConsole("==== Scan Results ====")
    for i,v in ipairs(found) do
        appendConsole(i..". "..v:GetFullName().." ("..v.ClassName..")")
    end
end

local function attachLogger(button)
    if attachedLogger then
        if loggerConnection then loggerConnection:Disconnect() end
        attachedLogger=false
        setStatus("Logger detached")
        notify("Logger", "Logger detached")
        return
    end
    local remote = findRemote()
    if not remote then 
        setStatus("Remote not found") 
        notify("Logger", "Remote not found")
        return 
    end
    loggerConnection = remote.OnClientEvent:Connect(function(...)
        appendConsole("VIPUGCMethod fired: "..table.concat({...},", "))
        setStatus("Event printed to console")
        notify("Logger Event", "VIPUGCMethod fired! Check console.")
    end)
    attachedLogger=true
    setStatus("Logger attached")
    notify("Logger", "Logger attached")
end

local function callVIPUGC(button)
    local now = tick()
    if now-lastCall<COOLDOWN then 
        setStatus(("Cooldown %.1fs"):format(COOLDOWN-(now-lastCall))) 
        notify("Call VIPUGCMethod","Cooldown active") 
        return 
    end
    local remote = findRemote()
    if not remote then 
        setStatus("Remote not found") 
        notify("Call VIPUGCMethod","Remote not found") 
        return 
    end
    local args = {92807314389236,"rbxassetid://89119211625300",true,"Gold Wings"} -- preset args
    local ok,err=pcall(function() remote:FireServer(unpack(args)) end)
    if ok then 
        setStatus("Call sent")
        notify("Call VIPUGCMethod","Call sent successfully")
    else 
        setStatus("Error: "..tostring(err))
        notify("Call VIPUGCMethod","Error sending call")
    end
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

-- Tambahkan tombol admin
makeButton("Scan Remotes", Color3.fromRGB(0,120,200), scanRemotes)
makeButton("Attach Logger", Color3.fromRGB(0,200,120), attachLogger)
makeButton("Call VIPUGCMethod", Color3.fromRGB(200,120,0), callVIPUGC)

setStatus("Ready")
notify("Core Features GUI", "Ready. Use the buttons to test features.")