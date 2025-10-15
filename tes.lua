-- Services
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

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
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title or "Notification",
        Text = text or "",
        Duration = duration or 3,
    })
end

local function animatedNotify(text)
    local gui = Instance.new("ScreenGui")
    gui.Name = "AnimatedNotify"
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0,300,0,50)
    label.Position = UDim2.new(0.5,-150,0.2,0)
    label.BackgroundTransparency = 0.5
    label.BackgroundColor3 = Color3.fromRGB(20,20,20)
    label.Text = text
    label.TextColor3 = Color3.new(1,1,1)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = gui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0,10)
    corner.Parent = label
    
    TweenService:Create(label, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position=UDim2.new(0.5,-150,0.25,0)}):Play()
    task.wait(2)
    TweenService:Create(label, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {Position=UDim2.new(0.5,-150,0.15,0), TextTransparency=1}):Play()
    task.wait(0.5)
    gui:Destroy()
end

-- =================================
-- 🔽 GUI UTAMA 🔽
-- =================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CoreFeaturesGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 280, 0, 240)
frame.Position = UDim2.new(0.4, -140, 0.5, -120)
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
-- 🔽 GLOBAL BOOMBOX INTERAKTIF 🔽
-- =================================
local function GlobalBoomboxInteractive()
    -- GUI Input
    local inputGui = Instance.new("ScreenGui")
    inputGui.Name = "BoomboxInteractiveGUI"
    inputGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local inputFrame = Instance.new("Frame")
    inputFrame.Size = UDim2.new(0,400,0,220)
    inputFrame.Position = UDim2.new(0.5,-200,0.5,-110)
    inputFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
    inputFrame.BorderSizePixel = 0
    inputFrame.Parent = inputGui
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0,12)
    frameCorner.Parent = inputFrame

    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(0,380,0,40)
    textBox.Position = UDim2.new(0,10,0,10)
    textBox.PlaceholderText = "Masukkan ID musik (pisahkan koma)"
    textBox.ClearTextOnFocus = false
    textBox.TextColor3 = Color3.new(1,1,1)
    textBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
    textBox.Parent = inputFrame

    -- Tombol Control
    local btnNames = {"Play","Stop","Next","Prev","Shuffle","Loop"}
    local btnColors = {Color3.fromRGB(50,200,50), Color3.fromRGB(200,50,50), Color3.fromRGB(0,120,255),
                       Color3.fromRGB(0,120,255), Color3.fromRGB(200,200,0), Color3.fromRGB(200,0,200)}
    local buttons = {}
    for i,name in ipairs(btnNames) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0,120,0,30)
        btn.Position = UDim2.new(0,10+((i-1)%3)*130,0,60+math.floor((i-1)/3)*40)
        btn.BackgroundColor3 = btnColors[i]
        btn.Text = name
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 14
        btn.Parent = inputFrame
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0,8)
        corner.Parent = btn
        buttons[name] = btn
    end

    -- Volume Slider
    local volumeLabel = Instance.new("TextLabel")
    volumeLabel.Size = UDim2.new(0,120,0,20)
    volumeLabel.Position = UDim2.new(0,10,0,140)
    volumeLabel.BackgroundTransparency = 1
    volumeLabel.Text = "Volume: 1.0"
    volumeLabel.TextColor3 = Color3.new(1,1,1)
    volumeLabel.Font = Enum.Font.GothamBold
    volumeLabel.TextSize = 14
    volumeLabel.Parent = inputFrame

    local volumeSlider = Instance.new("TextBox")
    volumeSlider.Size = UDim2.new(0,260,0,20)
    volumeSlider.Position = UDim2.new(0,130,0,140)
    volumeSlider.PlaceholderText = "0-1"
    volumeSlider.Text = "1"
    volumeSlider.TextColor3 = Color3.new(1,1,1)
    volumeSlider.BackgroundColor3 = Color3.fromRGB(50,50,50)
    volumeSlider.Parent = inputFrame

    -- Progress Bar
    local progressBar = Instance.new("Frame")
    progressBar.Size = UDim2.new(0,360,0,10)
    progressBar.Position = UDim2.new(0,20,0,175)
    progressBar.BackgroundColor3 = Color3.fromRGB(80,80,80)
    progressBar.Parent = inputFrame
    local progressFill = Instance.new("Frame")
    progressFill.Size = UDim2.new(0,0,1,0)
    progressFill.BackgroundColor3 = Color3.fromRGB(50,200,50)
    progressFill.Parent = progressBar

    -- Sound global
    local sound = Workspace:FindFirstChild("GlobalBoomboxSound")
    if not sound then
        sound = Instance.new("Sound")
        sound.Name = "GlobalBoomboxSound"
        sound.Looped = false
        sound.Volume = 1
        sound.RollOffMode = Enum.RollOffMode.Linear
        sound.MaxDistance = 100
        sound.Parent = Workspace
    end

    -- Playlist
    local playlist = {}
    local currentIndex = 1
    local isLoop = false
    local isShuffle = false

    -- Play helper
    local function playSong(index)
        if #playlist == 0 then
            notify("Boombox","Playlist kosong!",3)
            return
        end
        index = math.clamp(index,1,#playlist)
        currentIndex = index
        sound.SoundId = "rbxassetid://"..playlist[currentIndex]
        sound.Volume = tonumber(volumeSlider.Text) or 1
        sound:Play()
        setStatus("Now Playing: "..playlist[currentIndex])
        animatedNotify("Now Playing Music!")
    end

    -- Update volume dynamically
    volumeSlider.FocusLost:Connect(function(enter)
        local vol = tonumber(volumeSlider.Text)
        if vol then
            sound.Volume = math.clamp(vol,0,1)
            volumeLabel.Text = "Volume: "..sound.Volume
        else
            volumeSlider.Text = sound.Volume
        end
    end)

    -- Button events
    buttons.Play.MouseButton1Click:Connect(function()
        local ids = {}
        for id in string.gmatch(textBox.Text,"[^,%s]+") do
            table.insert(ids,id)
        end
        if #ids == 0 then
            notify("Boombox","Masukkan minimal 1 ID musik!",3)
            return
        end
        playlist = ids
        currentIndex = 1
        playSong(currentIndex)
    end)

    buttons.Stop.MouseButton1Click:Connect(function()
        if sound.IsPlaying then
            sound:Stop()
            setStatus("Music Stopped")
            animatedNotify("Music Stopped!")
        end
    end)

    buttons.Next.MouseButton1Click:Connect(function()
        if #playlist == 0 then return end
        if isShuffle then
            currentIndex = math.random(1,#playlist)
        else
            currentIndex = currentIndex + 1
            if currentIndex > #playlist then
                currentIndex = isLoop and 1 or #playlist
            end
        end
        playSong(currentIndex)
    end)

    buttons.Prev.MouseButton1Click:Connect(function()
        if #playlist == 0 then return end
        if isShuffle then
            currentIndex = math.random(1,#playlist)
        else
            currentIndex = currentIndex - 1
            if currentIndex < 1 then
                currentIndex = isLoop and #playlist or 1
            end
        end
        playSong(currentIndex)
    end)

    buttons.Shuffle.MouseButton1Click:Connect(function()
        isShuffle = not isShuffle
        notify("Boombox","Shuffle: "..tostring(isShuffle),2)
    end)

    buttons.Loop.MouseButton1Click:Connect(function()
        isLoop = not isLoop
        notify("Boombox","Loop: "..tostring(isLoop),2)
    end)

    -- Auto next on song end
    sound.Ended:Connect(function()
        if #playlist == 0 then return end
        if isShuffle then
            currentIndex = math.random(1,#playlist)
        else
            currentIndex = currentIndex + 1
            if currentIndex > #playlist then
                if isLoop then
                    currentIndex = 1
                else
                    return
                end
            end
        end
        playSong(currentIndex)
    end)

    -- Posisi sound mengikuti karakter
    RunService.RenderStepped:Connect(function()
        if LocalPlayer.Character and sound then
            local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                sound.Position = hrp.Position
            end
        end
        -- Update progress bar
        if sound.TimeLength > 0 then
            local ratio = math.clamp(sound.TimePosition/sound.TimeLength,0,1)
            progressFill.Size = UDim2.new(ratio,0,1,0)
        end
    end)
end

-- Tambahkan tombol Global Boombox Interaktif
makeButton("Global Boombox Interactive", Color3.fromRGB(255,100,50), GlobalBoomboxInteractive)

setStatus("Ready")
notify("Core Features", "GUI Ready!", 2)