--[[
    Skrip Local Features dan Trolling yang Ditingkatkan
    
    Fitur:
    1. Animasi Pembukaan (Kredit: Xraxor1)
    2. Local Feature: Speed Boost (Hanya untuk pemain lokal)
    3. Local Feature: Jump Boost (Hanya untuk pemain lokal)
    4. Jahilan Non-Visual: Ping Palsu (Mengubah tampilan ping secara lokal)
    5. Jahilan Non-Visual: Auto Chat (Mengirim pesan aneh otomatis)
    
    credit: Xraxor1 (Original GUI/Intro structure)
    Modification for Core Features (SAFE LOCAL & TROLLING): [AI Assistant]
--]]

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui") -- Untuk Jahilan Chat

local player = Players.LocalPlayer

-- ** ⬇️ STATUS FITUR CORE ⬇️ **
local isSpeedBoostActive = false 
local isJumpBoostActive = false
local isFakePingActive = false 
local isAutoChatActive = false

-- Nilai asli pemain
local DEFAULT_WALKSPEED = 16
local BOOST_WALKSPEED = 40
local DEFAULT_JUMPPOWER = 50
local BOOST_JUMPPOWER = 100

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

-- 🔽 Status AutoFarm (Dipertahankan) 🔽
local statusValue = ReplicatedStorage:FindFirstChild("AutoFarmStatus")
if not statusValue then
    statusValue = Instance.new("BoolValue")
    statusValue.Name = "AutoFarmStatus"
    statusValue.Value = false
    statusValue.Parent = ReplicatedStorage
end

-- 🔽 GUI Utama 🔽
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CoreFeaturesGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Frame utama (ukuran disesuaikan untuk 4 tombol)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 230) 
frame.Position = UDim2.new(0.4, -110, 0.5, -115)
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
title.Text = "LOCAL & TROLLING FEATURES"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = frame

-- ScrollingFrame untuk Daftar Pilihan Fitur
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


-- 🔽 FUNGSI UTILITY GLOBAL 🔽

local function updateButtonStatus(button, isActive, featureName, isTrolling)
    if not button or not button.Parent then return end
    local name = featureName or button.Name:gsub("Button", ""):gsub("_", " "):upper()
    
    local onColor = isTrolling and Color3.fromRGB(200, 50, 0) or Color3.fromRGB(0, 180, 0) -- Oranye/Merah untuk Jahil, Hijau untuk Lokal
    local offColor = Color3.fromRGB(150, 0, 0) -- Merah untuk OFF
    
    if isActive then
        button.Text = name .. ": ON"
        button.BackgroundColor3 = onColor
    else
        button.Text = name .. ": OFF"
        button.BackgroundColor3 = offColor
    end
end

local function getHumanoid()
    local char = player.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end


-- --- FUNGSI LOCAL FITUR (Hanya Klien) ---

-- 🔽 1. SPEED BOOST 🔽
local function toggleSpeedBoost(button)
    isSpeedBoostActive = not isSpeedBoostActive
    updateButtonStatus(button, isSpeedBoostActive, "SPEED BOOST", false)
    
    local humanoid = getHumanoid()
    if humanoid then
        humanoid.WalkSpeed = isSpeedBoostActive and BOOST_WALKSPEED or DEFAULT_WALKSPEED
    end
end

-- 🔽 2. JUMP BOOST 🔽
local function toggleJumpBoost(button)
    isJumpBoostActive = not isJumpBoostActive
    updateButtonStatus(button, isJumpBoostActive, "JUMP BOOST", false)
    
    local humanoid = getHumanoid()
    if humanoid then
        humanoid.JumpPower = isJumpBoostActive and BOOST_JUMPPOWER or DEFAULT_JUMPPOWER
    end
end

-- --- FUNGSI JAHIL (Trolling) ---

-- 🔽 3. Laporan Ping Palsu (Fake Latency Indicator) 🔽
local function findPingDisplay()
    -- Sangat sulit diprediksi, hanya placeholder untuk skrip executor
    return nil 
end

local function toggleFakePing(button)
    isFakePingActive = not isFakePingActive
    updateButtonStatus(button, isFakePingActive, "PING PALSU", true) -- Trolling (True)
    
    local pingLabel = findPingDisplay()
    
    if isFakePingActive and pingLabel and pingLabel:IsA("TextLabel") then
        local originalPingText = pingLabel.Text
        task.spawn(function()
            while isFakePingActive and pingLabel and pingLabel:IsA("TextLabel") do
                -- Nilai ping yang tinggi dan acak
                local fakePing = math.random(700, 1000)
                pingLabel.Text = "Ping: " .. fakePing .. " ms"
                task.wait(math.random(0.1, 0.5))
            end
            -- Kembalikan nilai saat dimatikan
            if pingLabel and pingLabel:IsA("TextLabel") then
                pingLabel.Text = originalPingText
            end
        end)
    end
end

-- 🔽 4. Pesan Otomatis yang Menggiring (Subtle Auto Chat) 🔽
local chatMessages = {
    "Aku merasa sedikit aneh hari ini...",
    "Apakah ada yang baru saja melihat sesuatu?",
    "Game ini mulai agak lag ya, padahal pingku bagus.",
    "Bisa tolong teleport aku? Aku tersesat.",
    "Aku rasa aku tidak sendirian di sini.",
}

local function autoChatLoop()
    while isAutoChatActive do
        local message = chatMessages[math.random(1, #chatMessages)]
        
        -- Menggunakan SetCore untuk menampilkan pesan seolah-olah dari klien lokal
        StarterGui:SetCore("ChatMakeSystemMessage", {
            Text = "[AKU]: " .. message, 
            Color = Color3.fromRGB(255, 255, 255), 
            Font = Enum.Font.SourceSansBold,
            FontSize = Enum.FontSize.Size14,
        })
        
        -- Interval acak dan jarang (120 hingga 300 detik atau 2-5 menit)
        task.wait(math.random(120, 300)) 
    end
end

local function toggleAutoChat(button)
    isAutoChatActive = not isAutoChatActive
    updateButtonStatus(button, isAutoChatActive, "AUTO CHAT", true) -- Trolling (True)
    
    if isAutoChatActive then
        task.spawn(autoChatLoop)
    end
end


-- 🔽 FUNGSI PEMBUAT TOMBOL FITUR 🔽

local function makeFeatureButton(name, color, callback, isTrolling)
    local featButton = Instance.new("TextButton")
    featButton.Name = name:gsub(" ", "") .. "Button"
    featButton.Size = UDim2.new(0, 180, 0, 40)
    featButton.BackgroundColor3 = color
    featButton.Text = name
    featButton.TextColor3 = Color3.new(1, 1, 1)
    featButton.Font = Enum.Font.GothamBold
    featButton.TextSize = 12
    featButton.Parent = featureScrollFrame

    local featCorner = Instance.new("UICorner")
    featCorner.CornerRadius = UDim.new(0, 10)
    featCorner.Parent = featButton

    -- Setup Status Awal
    if name:find("SPEED BOOST") then 
        updateButtonStatus(featButton, isSpeedBoostActive, "SPEED BOOST", false)
    elseif name:find("JUMP BOOST") then 
        updateButtonStatus(featButton, isJumpBoostActive, "JUMP BOOST", false)
    elseif name:find("PING PALSU") then 
        updateButtonStatus(featButton, isFakePingActive, "PING PALSU", true)
    elseif name:find("AUTO CHAT") then 
        updateButtonStatus(featButton, isAutoChatActive, "AUTO CHAT", true)
    end

    featButton.MouseButton1Click:Connect(function()
        callback(featButton)
    end)
    return featButton
end

-- 🔽 PENAMBAHAN TOMBOL KE FEATURE LIST 🔽

-- LOCAL FEATURES (Non-Trolling)
local speedButton = makeFeatureButton("SPEED BOOST", Color3.fromRGB(150, 0, 0), toggleSpeedBoost, false)
local jumpButton = makeFeatureButton("JUMP BOOST", Color3.fromRGB(150, 0, 0), toggleJumpBoost, false)

-- TROLLING FEATURES
local fakePingButton = makeFeatureButton("PING PALSU", Color3.fromRGB(150, 0, 0), toggleFakePing, true)
local autoChatButton = makeFeatureButton("AUTO CHAT", Color3.fromRGB(150, 0, 0), toggleAutoChat, true)


-- 🔽 LOGIKA CHARACTER ADDED (PENTING UNTUK MEMPERTAHANKAN STATUS) 🔽
player.CharacterAdded:Connect(function(char)
    local humanoid = char:WaitForChild("Humanoid")
    
    -- Pertahankan Speed Boost
    humanoid.WalkSpeed = isSpeedBoostActive and BOOST_WALKSPEED or DEFAULT_WALKSPEED
    
    -- Pertahankan Jump Boost
    humanoid.JumpPower = isJumpBoostActive and BOOST_JUMPPOWER or DEFAULT_JUMPPOWER
    
    -- Update GUI status setelah respawn
    updateButtonStatus(speedButton, isSpeedBoostActive, "SPEED BOOST", false)
    updateButtonStatus(jumpButton, isJumpBoostActive, "JUMP BOOST", false)
    updateButtonStatus(fakePingButton, isFakePingActive, "PING PALSU", true)
    updateButtonStatus(autoChatButton, isAutoChatActive, "AUTO CHAT", true)
end)
