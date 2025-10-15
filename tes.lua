-- Services
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Kohl's Admin Config
local ROOT_NAME = "Kohl's Admin Source"
local REMOTE_NAME = "VIPUGCMethod"
local COOLDOWN = 1
local lastCall = 0
local attachedLogger = false
local loggerConnection

-- =================================
-- 🔽 FUNCTION NOTIFIKASI 🔽
-- =================================
local function notify(title, text, duration)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title or "Notification",
            Text = text or "",
            Duration = duration or 3,
        })
    end)
end

-- =================================
-- 🔽 GUI UTAMA 🔽
-- =================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CoreFeaturesGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 320, 0, 400)
frame.Position = UDim2.new(0.5, -160, 0.45, -200)
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

local function notifyList(title, items)
    local chunkSize = 5
    for i = 1, #items, chunkSize do
        local chunk = {}
        for j = i, math.min(i + chunkSize - 1, #items) do
            table.insert(chunk, items[j])
        end
        notify(title, table.concat(chunk, "\n"), 4)
        task.wait(0.3)
    end
end

local function scanRemotes(button)
    setStatus("Scanning...")
    notify("Scan", "Scanning remotes...")
    local root = safeFindRoot()
    if not root then 
        setStatus("Root not found")
        notify("Scan", "Root not found!", 2)
        return 
    end
    local found={}
    for _,v in ipairs(root:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then 
            table.insert(found, v:GetFullName().." ("..v.ClassName..")") 
        end
    end
    setStatus("Scan complete. Check notifications.")
    notify("Scan Complete", "Found "..#found.." remotes.", 2)
    if #found > 0 then
        notifyList("Remotes List", found)
    end
end

local function attachLogger(button)
    if attachedLogger then
        if loggerConnection then loggerConnection:Disconnect() end
        attachedLogger=false
        setStatus("Logger detached")
        notify("Logger", "Logger detached", 2)
        return
    end
    local remote = findRemote()
    if not remote then 
        setStatus("Remote not found")
        notify("Logger", "Remote not found!", 2)
        return 
    end
    loggerConnection = remote.OnClientEvent:Connect(function(...)
        local args = {...}
        local display = {}
        for i,v in ipairs(args) do table.insert(display, tostring(v)) end
        setStatus("Event printed")
        notifyList("VIPUGCMethod Fired", display)
    end)
    attachedLogger=true
    setStatus("Logger attached")
    notify("Logger", "Logger attached successfully!", 2)
end

local function callVIPUGC(button)
    local now = tick()
    if now-lastCall<COOLDOWN then 
        local cd = COOLDOWN-(now-lastCall)
        setStatus(("Cooldown %.1fs"):format(cd))
        notify("VIPUGCMethod", ("Cooldown %.1fs"):format(cd), 2)
        return 
    end
    local remote = findRemote()
    if not remote then 
        setStatus("Remote not found")
        notify("VIPUGCMethod", "Remote not found!", 2)
        return 
    end
    local args = {92807314389236,"rbxassetid://89119211625300",true,"Gold Wings"}
    local ok,err=pcall(function() remote:FireServer(unpack(args)) end)
    if ok then 
        setStatus("Call sent")
        notify("VIPUGCMethod", "Call sent successfully!", 2)
    else 
        setStatus("Error: "..tostring(err))
        notify("VIPUGCMethod", "Error: "..tostring(err), 3)
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

-- =================================
-- 🔽 VIP BOOMBOX SPATIAL + REAL-TIME 🔽
-- =================================
local function VIPBoomboxFeature()
    local isVIP = true -- ganti dengan check GamePass/whitelist
    if not isVIP then
        setStatus("VIP required")
        notify("VIP Required","Fitur ini hanya untuk VIP!",4)
        return
    end

    -- GUI input musik
    local inputGui = Instance.new("ScreenGui")
    inputGui.Name = "BoomboxInputGUI"
    inputGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local inputFrame = Instance.new("Frame")
    inputFrame.Size = UDim2.new(0,300,0,120)
    inputFrame.Position = UDim2.new(0.5,-150,0.5,-60)
    inputFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
    inputFrame.BorderSizePixel = 0
    inputFrame.Parent = inputGui
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0,10)
    frameCorner.Parent = inputFrame

    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(0,280,0,40)
    textBox.Position = UDim2.new(0,10,0,10)
    textBox.PlaceholderText = "Masukkan ID musik"
    textBox.ClearTextOnFocus = false
    textBox.Text = ""
    textBox.TextColor3 = Color3.new(1,1,1)
    textBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
    textBox.Parent = inputFrame

    local playBtn = Instance.new("TextButton")
    playBtn.Size = UDim2.new(0,130,0,40)
    playBtn.Position = UDim2.new(0,10,0,60)
    playBtn.BackgroundColor3 = Color3.fromRGB(50,200,50)
    playBtn.Text = "Play"
    playBtn.TextColor3 = Color3.new(1,1,1)
    playBtn.Font = Enum.Font.GothamBold
    playBtn.TextSize = 14
    playBtn.Parent = inputFrame
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0,10)
    btnCorner.Parent = playBtn

    local stopBtn = Instance.new("TextButton")
    stopBtn.Size = UDim2.new(0,130,0,40)
    stopBtn.Position = UDim2.new(0,160,0,60)
    stopBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)
    stopBtn.Text = "Stop"
    stopBtn.TextColor3 = Color3.new(1,1,1)
    stopBtn.Font = Enum.Font.GothamBold
    stopBtn.TextSize = 14
    stopBtn.Parent = inputFrame
    local stopCorner = Instance.new("UICorner")
    stopCorner.CornerRadius = UDim.new(0,10)
    stopCorner.Parent = stopBtn

    -- buat Tool boombox
    local tool = LocalPlayer.Backpack:FindFirstChild("VIP Boombox")
    if not tool then
        tool = Instance.new("Tool")
        tool.Name = "VIP Boombox"
        tool.RequiresHandle = true
        tool.Parent = LocalPlayer.Backpack
        local handle = Instance.new("Part")
        handle.Name = "Handle"
        handle.Size = Vector3.new(1,1,1)
        handle.Transparency = 1
        handle.Parent = tool
        local sound = Instance.new("Sound")
        sound.Name = "BoomboxSound"
        sound.Looped = true
        sound.Volume = 1
        sound.PlaybackSpeed = 1
        sound.RollOffMode = Enum.RollOffMode.Linear
        sound.MaxDistance = 100
        sound.Parent = handle
    end
    local sound = tool.Handle:FindFirstChild("BoomboxSound")

    local updateVolume
    updateVolume = RunService.RenderStepped:Connect(function()
        if sound and sound.IsPlaying then
            local dist = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and
                (sound.Parent.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude) or 0
            sound.Volume = math.clamp(1 - dist/100,0,1)
        end
    end)

    playBtn.MouseButton1Click:Connect(function()
        local id = tonumber(textBox.Text)
        if id then
            sound.SoundId = "rbxassetid://"..id
            sound:Play()
            notify("VIP Boombox","Musik diputar, semua pemain mendengar!",3)
        else
            notify("VIP Boombox","Masukkan ID musik yang valid!",3)
        end
    end)

    stopBtn.MouseButton1Click:Connect(function()
        if sound.IsPlaying then
            sound:Stop()
            notify("VIP Boombox","Musik dihentikan!",2)
        end
    end)
end

-- Tambahkan tombol VIP Boombox ke GUI
makeButton("VIP Boombox", Color3.fromRGB(255,50,50), VIPBoomboxFeature)

-- Tambahkan tombol admin lainnya
makeButton("Scan Remotes", Color3.fromRGB(0,120,200), scanRemotes)
makeButton("Attach Logger", Color3.fromRGB(0,200,120), attachLogger)
makeButton("Call VIPUGCMethod", Color3.fromRGB(200,120,0), callVIPUGC)

setStatus("Ready")
notify("Core Features", "GUI Ready!", 2)