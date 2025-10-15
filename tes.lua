-- FULL: Core Features + Global Boombox Interactive + Minimize/Restore + Notifications
-- Put this as a LocalScript (StarterPlayerScripts or StarterGui)

-- Services
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then return end

-- Cleanup any previous copies (avoid duplicates on reload)
pcall(function()
    local existing = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("CoreFeaturesGUI")
    if existing then existing:Destroy() end
    local anim = LocalPlayer.PlayerGui:FindFirstChild("AnimatedNotify")
    if anim then anim:Destroy() end
end)

-- Kohl's Admin Config
local ROOT_NAME = "Kohl's Admin Source"
local REMOTE_NAME = "VIPUGCMethod"
local COOLDOWN = 1
local lastCall = 0
local attachedLogger = false
local loggerConnection = nil

-- Helper: safe notify (SetCore may error in some environments)
local function notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "Notification",
            Text = text or "",
            Duration = duration or 3,
        })
    end)
end

-- Animated on-screen notification (custom)
local function animatedNotify(text)
    local gui = Instance.new("ScreenGui")
    gui.Name = "AnimatedNotify"
    gui.ResetOnSpawn = false
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0,320,0,48)
    label.Position = UDim2.new(0.5, -160, 0.12, 0)
    label.BackgroundTransparency = 0.25
    label.BackgroundColor3 = Color3.fromRGB(10,10,10)
    label.BorderSizePixel = 0
    label.Text = text or ""
    label.TextColor3 = Color3.new(1,1,1)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0,10)
    corner.Parent = label

    local enter = TweenService:Create(label, TweenInfo.new(0.4, Enum.EasingStyle.Sine), {Position = UDim2.new(0.5, -160, 0.08, 0)})
    enter:Play()
    task.wait(2)
    local exit = TweenService:Create(label, TweenInfo.new(0.4, Enum.EasingStyle.Sine), {TextTransparency = 1, BackgroundTransparency = 1, Position = UDim2.new(0.5, -160, 0.04, 0)})
    exit:Play()
    exit.Completed:Wait()
    gui:Destroy()
end

-- =================================
-- GUI MAIN
-- =================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CoreFeaturesGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Main frame
local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 320, 0, 280)
frame.Position = UDim2.new(0.6, -160, 0.4, -140)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local frameCorner = Instance.new("UICorner"); frameCorner.CornerRadius = UDim.new(0,12); frameCorner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -48, 0, 34)
title.Position = UDim2.new(0, 12, 0, 6)
title.BackgroundTransparency = 1
title.Text = "CORE FEATURES"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

-- Close / Minimize button top-right
local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseBtn"
closeBtn.Size = UDim2.new(0,28,0,28)
closeBtn.Position = UDim2.new(1, -36, 0, 6)
closeBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(230,80,80)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.Parent = frame
local closeCorner = Instance.new("UICorner"); closeCorner.CornerRadius = UDim.new(0,6); closeCorner.Parent = closeBtn

-- ScrollFrame for buttons
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -24, 1, -74)
scrollFrame.Position = UDim2.new(0,12,0,44)
scrollFrame.CanvasSize = UDim2.new(0,0,0,0)
scrollFrame.ScrollBarThickness = 6
scrollFrame.BackgroundTransparency = 1
scrollFrame.Parent = frame

local listLayout = Instance.new("UIListLayout")
listLayout.Parent = scrollFrame
listLayout.Padding = UDim.new(0,6)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.SortOrder = Enum.SortOrder.LayoutOrder

listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scrollFrame.CanvasSize = UDim2.new(0,0,0,listLayout.AbsoluteContentSize.Y + 10)
end)

-- Status bar bottom
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -24, 0, 28)
statusLabel.Position = UDim2.new(0,12,1,-36)
statusLabel.BackgroundTransparency = 0.3
statusLabel.BackgroundColor3 = Color3.fromRGB(30,30,30)
statusLabel.Text = "Status: Ready"
statusLabel.TextColor3 = Color3.new(1,1,1)
statusLabel.Font = Enum.Font.SourceSansBold
statusLabel.TextSize = 14
statusLabel.Parent = frame
local statusCorner = Instance.new("UICorner"); statusCorner.CornerRadius = UDim.new(0,8); statusCorner.Parent = statusLabel

local function setStatus(txt)
    statusLabel.Text = "Status: "..tostring(txt)
end

-- Mini icon (restore) - sits on screen corner by default bottom-right
local miniIcon = Instance.new("TextButton")
miniIcon.Name = "MiniIcon"
miniIcon.Size = UDim2.new(0,56,0,56)
miniIcon.Position = UDim2.new(1, -72, 1, -80) -- bottom-right offset
miniIcon.AnchorPoint = Vector2.new(0,0)
miniIcon.BackgroundColor3 = Color3.fromRGB(30,30,30)
miniIcon.Text = "🎵"
miniIcon.TextSize = 36
miniIcon.Parent = screenGui
local miniCorner = Instance.new("UICorner"); miniCorner.CornerRadius = UDim.new(0,12); miniCorner.Parent = miniIcon
miniIcon.Visible = false

-- Make all GUIs list to hide/show together if needed
local GUIsToManage = {frame}

-- =================================
-- CORE FEATURE FUNCTIONS
-- =================================
local function safeFindRoot()
    local ok, root = pcall(function() return ReplicatedStorage:FindFirstChild(ROOT_NAME) end)
    return ok and root or nil
end

local function findRemote()
    local root = safeFindRoot()
    if not root then return nil end
    local container = root:FindFirstChild("Remote") or root:FindFirstChildWhichIsA("Folder")
    if not container then return nil end
    return container:FindFirstChild(REMOTE_NAME) or container:FindFirstChildWhichIsA("RemoteEvent")
end

local function scanRemotes()
    setStatus("Scanning...")
    notify("Scan","Scanning remotes...")
    local root = safeFindRoot()
    if not root then
        setStatus("Root not found")
        notify("Scan","Root not found!",2)
        return
    end
    local found = {}
    for _,v in ipairs(root:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            table.insert(found, v:GetFullName().." ("..v.ClassName..")")
        end
    end
    setStatus("Scan complete")
    notify("Scan Complete","Found "..#found.." remotes.",2)
    -- also animated notify and compact list
    if #found > 0 then
        animatedNotify("Scan Complete: "..#found.." remotes")
        -- show up to first 8 in notifications to avoid spam
        for i = 1, math.min(8, #found) do
            local msg = found[i]
            notify("Remote "..i, msg, 3)
            task.wait(0.15)
        end
    end
end

local function attachLogger()
    if attachedLogger then
        if loggerConnection then loggerConnection:Disconnect() end
        attachedLogger = false
        setStatus("Logger detached")
        notify("Logger","Logger detached",2)
        return
    end
    local remote = findRemote()
    if not remote then
        setStatus("Remote not found")
        notify("Logger","Remote not found!",2)
        return
    end
    loggerConnection = remote.OnClientEvent:Connect(function(...)
        local args = {...}
        local out = {}
        for i,v in ipairs(args) do table.insert(out, tostring(v)) end
        setStatus("Event fired")
        animatedNotify("Remote Event Fired!")
        -- chunk notifs
        for i = 1, #out, 4 do
            local chunk = {}
            for j = i, math.min(i+3,#out) do table.insert(chunk, out[j]) end
            notify("Event", table.concat(chunk, ", "), 3)
            task.wait(0.1)
        end
    end)
    attachedLogger = true
    setStatus("Logger attached")
    notify("Logger","Logger attached",2)
end

local function callVIPUGC()
    local now = tick()
    if now - lastCall < COOLDOWN then
        local cd = COOLDOWN - (now - lastCall)
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
    local args = {92807314389236, "rbxassetid://89119211625300", true, "Gold Wings"}
    local ok, err = pcall(function() remote:FireServer(unpack(args)) end)
    if ok then
        setStatus("Call sent")
        notify("VIPUGCMethod","Call sent successfully!",2)
    else
        setStatus("Error: "..tostring(err))
        notify("VIPUGCMethod","Error: "..tostring(err),3)
    end
    lastCall = now
end

-- Button creator helper
local function makeButton(name, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 260, 0, 40)
    btn.BackgroundColor3 = color
    btn.Text = name
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Parent = scrollFrame
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0,8)
    btnCorner.Parent = btn
    btn.MouseButton1Click:Connect(function()
        pcall(callback)
    end)
    return btn
end

-- Add core buttons
makeButton("Scan Remotes", Color3.fromRGB(0,120,200), scanRemotes)
makeButton("Attach Logger", Color3.fromRGB(0,200,120), attachLogger)
makeButton("Call VIPUGCMethod", Color3.fromRGB(200,120,0), callVIPUGC)

-- =================================
-- BOOMBOX INTERACTIVE (GLOBAL)
-- =================================
-- We'll create a single Sound object under Workspace named "GlobalBoomboxSound"
-- NOTE: when a client creates a Sound in Workspace, it's local to them.
-- For full global replication across players, a server-side RemoteEvent/script is needed.
-- This client-side implementation makes it work for the local player and provides UI/behavior as requested.

local function GlobalBoomboxInteractive()
    -- If GUI already open, focus/return
    if screenGui:FindFirstChild("BoomboxInteractiveGUI") then
        screenGui:FindFirstChild("BoomboxInteractiveGUI"):Destroy()
    end

    local inputGui = Instance.new("ScreenGui")
    inputGui.Name = "BoomboxInteractiveGUI"
    inputGui.ResetOnSpawn = false
    inputGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    table.insert(GUIsToManage, inputGui)

    local inputFrame = Instance.new("Frame")
    inputFrame.Size = UDim2.new(0,420,0,240)
    inputFrame.Position = UDim2.new(0.5, -210, 0.4, -120)
    inputFrame.BackgroundColor3 = Color3.fromRGB(28,28,28)
    inputFrame.BorderSizePixel = 0
    inputFrame.Parent = inputGui
    inputFrame.Active = true
    inputFrame.Draggable = true
    local inputCorner = Instance.new("UICorner"); inputCorner.CornerRadius = UDim.new(0,12); inputCorner.Parent = inputFrame

    local header = Instance.new("TextLabel")
    header.Size = UDim2.new(1, -48, 0, 34)
    header.Position = UDim2.new(0,12,0,6)
    header.BackgroundTransparency = 1
    header.Text = "BOOMBOX PLAYER"
    header.TextColor3 = Color3.fromRGB(230,230,230)
    header.Font = Enum.Font.GothamBold
    header.TextSize = 18
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.Parent = inputFrame

    -- Close small for this boombox panel
    local bxClose = Instance.new("TextButton")
    bxClose.Size = UDim2.new(0,28,0,28)
    bxClose.Position = UDim2.new(1,-36,0,6)
    bxClose.Text = "X"
    bxClose.BackgroundColor3 = Color3.fromRGB(40,40,40)
    bxClose.TextColor3 = Color3.fromRGB(230,80,80)
    bxClose.Font = Enum.Font.GothamBold
    bxClose.TextSize = 16
    bxClose.Parent = inputFrame
    local bxCloseCorner = Instance.new("UICorner"); bxCloseCorner.CornerRadius = UDim.new(0,6); bxCloseCorner.Parent = bxClose

    bxClose.MouseButton1Click:Connect(function()
        inputGui.Enabled = false
        inputGui:Destroy()
    end)

    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(0,400,0,40)
    textBox.Position = UDim2.new(0,10,0,46)
    textBox.PlaceholderText = "Masukkan ID musik (pisahkan koma untuk playlist)"
    textBox.ClearTextOnFocus = false
    textBox.Text = ""
    textBox.TextColor3 = Color3.new(1,1,1)
    textBox.BackgroundColor3 = Color3.fromRGB(45,45,45)
    textBox.Parent = inputFrame
    local tbCorner = Instance.new("UICorner"); tbCorner.CornerRadius = UDim.new(0,8); tbCorner.Parent = textBox

    -- Buttons: Play Stop Next Prev Shuffle Loop
    local btnNames = {"Play","Stop","Next","Prev","Shuffle","Loop"}
    local btnColors = {
        Color3.fromRGB(60,180,80),
        Color3.fromRGB(200,60,60),
        Color3.fromRGB(60,120,200),
        Color3.fromRGB(60,120,200),
        Color3.fromRGB(200,180,60),
        Color3.fromRGB(180,80,200)
    }
    local controls = {}
    for i,name in ipairs(btnNames) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0,130,0,34)
        btn.Position = UDim2.new(0, 10 + ((i-1)%3) * 135, 0, 96 + math.floor((i-1)/3)*42)
        btn.BackgroundColor3 = btnColors[i]
        btn.Text = name
        btn.Font = Enum.Font.GothamBold
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Parent = inputFrame
        local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,8); c.Parent = btn
        controls[name] = btn
    end

    -- Volume and progress
    local volumeLabel = Instance.new("TextLabel")
    volumeLabel.Size = UDim2.new(0,120,0,20)
    volumeLabel.Position = UDim2.new(0,10,0,186)
    volumeLabel.BackgroundTransparency = 1
    volumeLabel.Text = "Volume: 1.0"
    volumeLabel.TextColor3 = Color3.new(1,1,1)
    volumeLabel.Font = Enum.Font.SourceSans
    volumeLabel.TextSize = 14
    volumeLabel.Parent = inputFrame

    local volumeBox = Instance.new("TextBox")
    volumeBox.Size = UDim2.new(0,84,0,20)
    volumeBox.Position = UDim2.new(0,130,0,186)
    volumeBox.PlaceholderText = "0-1"
    volumeBox.Text = "1"
    volumeBox.BackgroundColor3 = Color3.fromRGB(45,45,45)
    volumeBox.TextColor3 = Color3.new(1,1,1)
    local vbCorner = Instance.new("UICorner"); vbCorner.CornerRadius = UDim.new(0,6); vbCorner.Parent = volumeBox
    volumeBox.Parent = inputFrame

    local progressBar = Instance.new("Frame")
    progressBar.Size = UDim2.new(0, 400, 0, 12)
    progressBar.Position = UDim2.new(0,10,0,212)
    progressBar.BackgroundColor3 = Color3.fromRGB(70,70,70)
    progressBar.Parent = inputFrame
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0,0,1,0)
    fill.BackgroundColor3 = Color3.fromRGB(50,200,50)
    fill.Parent = progressBar
    local progCorner = Instance.new("UICorner"); progCorner.CornerRadius = UDim.new(0,6); progCorner.Parent = progressBar
    local fillCorner = Instance.new("UICorner"); fillCorner.CornerRadius = UDim.new(0,6); fillCorner.Parent = fill

    -- Create/find global sound in Workspace (client creates local sound)
    local sound = Workspace:FindFirstChild("GlobalBoomboxSound")
    if not sound then
        sound = Instance.new("Sound")
        sound.Name = "GlobalBoomboxSound"
        sound.Looped = false
        sound.Volume = 1
        sound.RollOffMode = Enum.RollOffMode.Linear
        sound.MaxDistance = 120
        sound.Parent = Workspace
    end

    -- Playlist logic
    local playlist = {}
    local currentIndex = 1
    local isLoop = false
    local isShuffle = false

    local function updateFill()
        if sound.TimeLength and sound.TimeLength > 0 then
            local ratio = math.clamp(sound.TimePosition / sound.TimeLength, 0, 1)
            fill.Size = UDim2.new(ratio, 0, 1, 0)
        else
            fill.Size = UDim2.new(0,0,1,0)
        end
    end

    local function playSong(index)
        if #playlist == 0 then
            notify("Boombox","Playlist kosong!",3)
            return
        end
        index = math.clamp(index, 1, #playlist)
        currentIndex = index
        local sid = tostring(playlist[currentIndex])
        sound.SoundId = "rbxassetid://"..sid
        local vol = tonumber(volumeBox.Text) or 1
        sound.Volume = math.clamp(vol, 0, 1)
        sound:Play()
        setStatus("Now Playing: "..sid)
        animatedNotify("Now Playing")
    end

    -- Buttons behaviour
    controls.Play.MouseButton1Click:Connect(function()
        local ids = {}
        for id in string.gmatch(textBox.Text, "[^,%s]+") do
            table.insert(ids, id)
        end
        if #ids == 0 then notify("Boombox","Masukkan minimal 1 ID!",3); return end
        playlist = ids
        currentIndex = 1
        playSong(currentIndex)
    end)

    controls.Stop.MouseButton1Click:Connect(function()
        if sound.IsPlaying then
            sound:Stop()
            setStatus("Stopped")
            animatedNotify("Stopped")
        end
    end)

    controls.Next.MouseButton1Click:Connect(function()
        if #playlist == 0 then return end
        if isShuffle then
            currentIndex = math.random(1,#playlist)
        else
            currentIndex = currentIndex + 1
            if currentIndex > #playlist then
                if isLoop then currentIndex = 1 else currentIndex = #playlist end
            end
        end
        playSong(currentIndex)
    end)

    controls.Prev.MouseButton1Click:Connect(function()
        if #playlist == 0 then return end
        if isShuffle then
            currentIndex = math.random(1,#playlist)
        else
            currentIndex = currentIndex - 1
            if currentIndex < 1 then
                if isLoop then currentIndex = #playlist else currentIndex = 1 end
            end
        end
        playSong(currentIndex)
    end)

    controls.Shuffle.MouseButton1Click:Connect(function()
        isShuffle = not isShuffle
        notify("Boombox","Shuffle: "..tostring(isShuffle),2)
    end)

    controls.Loop.MouseButton1Click:Connect(function()
        isLoop = not isLoop
        notify("Boombox","Loop: "..tostring(isLoop),2)
    end)

    -- Volume box update
    volumeBox.FocusLost:Connect(function(enter)
        local vol = tonumber(volumeBox.Text)
        if vol then
            sound.Volume = math.clamp(vol,0,1)
            volumeLabel.Text = "Volume: "..string.format("%.2f", sound.Volume)
        else
            volumeBox.Text = tostring(sound.Volume)
        end
    end)

    -- Auto next when ended
    sound.Ended:Connect(function()
        if #playlist == 0 then return end
        if isShuffle then
            currentIndex = math.random(1,#playlist)
        else
            currentIndex = currentIndex + 1
            if currentIndex > #playlist then
                if isLoop then currentIndex = 1 else return end
            end
        end
        playSong(currentIndex)
    end)

    -- Progress update and sound position follow local character
    local renderConn
    renderConn = RunService.RenderStepped:Connect(function()
        updateFill()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and sound then
            local hrp = LocalPlayer.Character.HumanoidRootPart
            sound.Position = hrp.Position
        end
    end)

    -- Cleanup on GUI removal
    inputGui.Destroying:Connect(function()
        if renderConn then renderConn:Disconnect(); renderConn = nil end
    end)
end

-- Add boombox button to main GUI
makeButton("Global Boombox Interactive", Color3.fromRGB(255,100,50), GlobalBoomboxInteractive)

-- =================================
-- MINIMIZE / RESTORE LOGIC
-- =================================
local function hideAllGUIs()
    for _,g in ipairs(GUIsToManage) do
        if g and g.Parent then
            g.Enabled = false
            if g:IsA("GuiObject") then g.Visible = false end
        end
    end
    -- show mini icon
    miniIcon.Visible = true
    setStatus("GUI minimized")
end

local function showAllGUIs()
    for _,g in ipairs(GUIsToManage) do
        if g and g.Parent then
            g.Enabled = true
            if g:IsA("GuiObject") then g.Visible = true end
        end
    end
    miniIcon.Visible = false
    setStatus("GUI restored")
end

closeBtn.MouseButton1Click:Connect(function()
    hideAllGUIs()
    animatedNotify("GUI Minimized (music tetap berjalan)")
end)

miniIcon.MouseButton1Click:Connect(function()
    showAllGUIs()
    animatedNotify("GUI Restored")
end)

-- Also allow clicking anywhere to restore if mini icon hidden? We'll restore only on miniIcon click to avoid accidental opens.

-- Add ability to minimize all when pressing Esc (optional)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Escape then
        if miniIcon.Visible then
            showAllGUIs()
        else
            hideAllGUIs()
        end
    end
end)

-- Ensure GUIsToManage contains boombox GUI if created later
-- (GlobalBoomboxInteractive inserts its GUI into GUIsToManage when created)

-- Final ready state
setStatus("Ready")
notify("Core Features", "GUI Ready!", 2)
animatedNotify("Core Features Ready")