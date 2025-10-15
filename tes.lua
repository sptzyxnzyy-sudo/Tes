-- Services
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

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
frame.Size = UDim2.new(0, 360, 0, 500)
frame.Position = UDim2.new(0.5, -180, 0.5, -250)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0,15)
corner.Parent = frame

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Text = "KOHL'S ADMIN TOOLKIT"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = frame

-- ScrollFrame untuk tombol fitur
local featureScroll = Instance.new("ScrollingFrame")
featureScroll.Size = UDim2.new(1,-20,0,150)
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

-- Console di bawah
local consoleBox = Instance.new("TextBox")
consoleBox.Size = UDim2.new(1,-20,1,-210)
consoleBox.Position = UDim2.new(0,10,0,195)
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
consoleBox.ReadOnly = true
consoleBox.Parent = frame

-- Copy & Clear buttons
local copyBtn = Instance.new("TextButton")
copyBtn.Size = UDim2.new(0,80,0,28)
copyBtn.Position = UDim2.new(0,10,1,-30)
copyBtn.Text = "Copy All"
copyBtn.Font = Enum.Font.GothamBold
copyBtn.TextSize = 14
copyBtn.BackgroundColor3 = Color3.fromRGB(0,150,150)
copyBtn.TextColor3 = Color3.new(1,1,1)
copyBtn.Parent = frame

local clearBtn = Instance.new("TextButton")
clearBtn.Size = UDim2.new(0,80,0,28)
clearBtn.Position = UDim2.new(0,100,1,-30)
clearBtn.Text = "Clear"
clearBtn.Font = Enum.Font.GothamBold
clearBtn.TextSize = 14
clearBtn.BackgroundColor3 = Color3.fromRGB(150,50,50)
clearBtn.TextColor3 = Color3.new(1,1,1)
clearBtn.Parent = frame

local function appendConsole(text)
    consoleBox.Text = consoleBox.Text.."\n"..text
    consoleBox.CanvasPosition = Vector2.new(0, consoleBox.TextBounds.Y)
end

copyBtn.MouseButton1Click:Connect(function()
    setclipboard(consoleBox.Text)
    appendConsole("Console copied to clipboard!")
end)

clearBtn.MouseButton1Click:Connect(function()
    consoleBox.Text = ""
end)

-- Status label
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1,0,0,24)
statusLabel.Position = UDim2.new(0,0,1,-60)
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
    setStatus("Scanning...")
    local root = safeFindRoot()
    if not root then notify("Scan Remotes","Root not found") return end
    local found={}
    for _,v in ipairs(root:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then table.insert(found,v) end
    end
    setStatus("Scan complete.")
    notify("Scan Remotes","Found "..#found.." remote(s). Check console.")
    appendConsole("==== Scan Results ====")
    for i,v in ipairs(found) do
        appendConsole(i..". "..v:GetFullName().." ("..v.ClassName..")")
    end
end

local function attachLogger(active)
    local remote = findRemote()
    if not remote then notify("Logger","Remote not found") return end
    if active then
        if loggerConnection then loggerConnection:Disconnect() end
        loggerConnection = remote.OnClientEvent:Connect(function(...)
            appendConsole("VIPUGCMethod fired: "..table.concat({...},", "))
            setStatus("Event printed")
            notify("Logger Event","VIPUGCMethod fired! Check console.")
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

-- Initial status
setStatus("Ready")
notify("Core Features GUI","Ready. Toggle buttons to test features.")