--[[
    Skrip Local Features dan Trolling yang Ditingkatkan (Final)
    
    Fitur:
    1. Animasi Pembukaan (Kredit: Xraxor1)
    2. Local Feature: Speed Boost
    3. Jahilan Tingkat Lanjut: Gravitasi Paksa (GRAVITY FORCE) - Mendorong pemain target ke bawah dengan gaya besar untuk Fall Damage tanpa visual.
    4. Jahilan Non-Visual: Ping Palsu
    5. Jahilan Non-Visual: Auto Chat
    
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
local isGravityForceActive = false -- Menggantikan JumpBoost
local isFakePingActive = false 
local isAutoChatActive = false

-- Nilai asli pemain
local DEFAULT_WALKSPEED = 16
local BOOST_WALKSPEED = 40

-- Nilai untuk Gravitasi Paksa
local GRAVITY_FORCE_MAGNITUDE = 50000 -- Kekuatan dorongan ke bawah (disesuaikan berdasarkan game)
local TROLL_DELAY_PART = nil -- Part pemicu (jika dibutuhkan)

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

-- Frame utama (ukuran untuk 4 tombol)
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

local function getHumanoid(target)
    local char = target.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end


-- --- FUNGSI LOCAL FITUR (Hanya Klien) ---

-- 🔽 1. SPEED BOOST 🔽
local function toggleSpeedBoost(button)
    isSpeedBoostActive = not isSpeedBoostActive
    updateButtonStatus(button, isSpeedBoostActive, "SPEED BOOST", false)
    
    local humanoid = getHumanoid(player)
    if humanoid then
        humanoid.WalkSpeed = isSpeedBoostActive and BOOST_WALKSPEED or DEFAULT_WALKSPEED
    end
end


-- --- FUNGSI JAHIL (Trolling) ---

-- 🔽 2. GRAVITASI PAKSA (FORCED GRAVITY) 🔽
local function applyForcedGravity(targetPlayer)
    if not targetPlayer or targetPlayer == player then return end
    
    local char = targetPlayer.Character
    local rootPart = char and char:FindFirstChild("HumanoidRootPart")
    
    if rootPart then
        -- 1. Buat VectorForce untuk dorongan ke bawah sesaat
        local force = Instance.new("VectorForce")
        force.Force = Vector3.new(0, -GRAVITY_FORCE_MAGNITUDE, 0)
        
        -- Gunakan Attachment untuk menghubungkan force
        local attachment = Instance.new("Attachment", rootPart)
        force.Attachment0 = attachment
        force.Parent = rootPart
        
        -- 2. Hancurkan VectorForce dengan cepat (Simulasi kejutan/gaya tarik cepat)
        task.delay(0.1, function()
            force:Destroy()
            attachment:Destroy()
        end)
        
        print("Forced Gravity diterapkan ke: " .. targetPlayer.Name)
    end
end

local function toggleForcedGravity(button)
    isGravityForceActive = not isGravityForceActive
    updateButtonStatus(button, isGravityForceActive, "GRAVITASI PAKSA", true)
    
    if isGravityForceActive then
        print("Gravitasi Paksa AKTIF.")
        
        -- Terapkan pada semua pemain di server kecuali diri sendiri (metode jahil cepat)
        task.spawn(function()
            while isGravityForceActive do
                for _, targetP in ipairs(Players:GetPlayers()) do
                    if targetP ~= player and targetP.Character then
                        applyForcedGravity(targetP)
                    end
                end
                task.wait(math.random(5, 15)) -- Jeda acak 5-15 detik
            end
        end)
    else
        print("Gravitasi Paksa NONAKTIF.")
    end
end

-- 🔽 3. Laporan Ping Palsu (Fake Latency Indicator) 🔽
local function findPingDisplay()
    return nil -- Placeholder
end

local function toggleFakePing(button)
    isFakePingActive = not isFakePingActive
    updateButtonStatus(button, isFakePingActive, "PING PALSU", true)
    
    local pingLabel = findPingDisplay()
    
    if isFakePingActive and pingLabel and pingLabel:IsA("TextLabel") then
        local originalPingText = pingLabel.Text
        task.spawn(function()
            while isFakePingActive and pingLabel and pingLabel:IsA("TextLabel") do
                local fakePing = math.random(700, 1000)
                pingLabel.Text = "Ping: " .. fakePing .. " ms"
                task.wait(math.random(0.1, 0.5))
            end
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
        
        StarterGui:SetCore("ChatMakeSystemMessage", {
            Text = "[AKU]: " .. message, 
            Color = Color3.fromRGB(255, 255, 255), 
            Font = Enum.Font.SourceSansBold,
            FontSize = Enum.FontSize.Size14,
        })
        
        task.wait(math.random(120, 300)) 
    end
end

local function toggleAutoChat(button)
    isAutoChatActive = not isAutoChatActive
    updateButtonStatus(button, isAutoChatActive, "AUTO CHAT", true)
    
    if isAutoChatActive then
        task.spawn(autoChatLoop)
    end
end


-- 🔽 FUNGSI PEMBUAT TOMBOL FITUR 🔽

local function makeFeatureButton(name, color, callback, isTrolling, currentStatus)
    local featButton = Instance.new("TextButton")
    featButton.Name = name:gsub(" ", "") .. "Button"
    featButton.Size = UDim2.new(0, 180, 0, 40)
    featButton.BackgroundColor3 = color
    featButton.Text = name
    featButton.TextColor3 = Color3.new(1, 1, 1)
    featButton.Font = Enum.Font.GothamBold
    featButton.TextSize = 12
    featButton.Parent = featureScrollFrame

    Instance.new("UICorner", featButton).CornerRadius = UDim.new(0, 10)

    -- Setup Status Awal
    updateButtonStatus(featButton, currentStatus, name, isTrolling)

    featButton.MouseButton1Click:Connect(function()
        callback(featButton)
    end)
    return featButton
end

-- 🔽 PENAMBAHAN TOMBOL KE FEATURE LIST 🔽

-- LOCAL FEATURE
local speedButton = makeFeatureButton("SPEED BOOST", Color3.fromRGB(150, 0, 0), toggleSpeedBoost, false, isSpeedBoostActive)

-- TROLLING FEATURE: GRAVITASI PAKSA (Ganti JUMP BOOST)
local gravityButton = makeFeatureButton("GRAVITASI PAKSA", Color3.fromRGB(150, 0, 0), toggleForcedGravity, true, isGravityForceActive)

-- TROLLING FEATURE: PING PALSU
local fakePingButton = makeFeatureButton("PING PALSU", Color3.fromRGB(150, 0, 0), toggleFakePing, true, isFakePingActive)

-- TROLLING FEATURE: AUTO CHAT
local autoChatButton = makeFeatureButton("AUTO CHAT", Color3.fromRGB(150, 0, 0), toggleAutoChat, true, isAutoChatActive)


-- 🔽 LOGIKA CHARACTER ADDED (PENTING UNTUK MEMPERTAHANKAN STATUS) 🔽
player.CharacterAdded:Connect(function(char)
    local humanoid = char:WaitForChild("Humanoid")
    
    -- Pertahankan Speed Boost
    humanoid.WalkSpeed = isSpeedBoostActive and BOOST_WALKSPEED or DEFAULT_WALKSPEED
    
    -- Update GUI status setelah respawn
    updateButtonStatus(speedButton, isSpeedBoostActive, "SPEED BOOST", false)
    updateButtonStatus(gravityButton, isGravityForceActive, "GRAVITASI PAKSA", true)
    updateButtonStatus(fakePingButton, isFakePingActive, "PING PALSU", true)
    updateButtonStatus(autoChatButton, isAutoChatActive, "AUTO CHAT", true)
end)
