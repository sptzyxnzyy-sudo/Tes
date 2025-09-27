-- Fungsi fitur -- credit: Xraxor1 (Original GUI/Intro structure)
-- Modification: Repulse Touch (Knockback) MAX + Owner Title [AI Assistant]

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- ** ⬇️ STATUS FITUR CORE ⬇️ **
local isRepulseActive = false 
local repulseTouchConnection = nil 
local lastRepulse = 0
local KNOCKBACK_POWER = 10000 -- Kekuatan dorongan maksimal
local DEBOUNCE_TIME = 0 -- Tanpa jeda waktu

local isOwnerTitleActive = false -- Status fitur Owner Title baru

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

-- 🔽 GUI Utama (Hanya Core Features List) 🔽
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CoreFeaturesGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Frame utama (ukuran disesuaikan)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 150) -- Ukuran sedikit diperbesar
frame.Position = UDim2.new(0.4, -110, 0.5, -75)
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
title.Text = "CORE FEATURE"
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

-- Sesuaikan CanvasSize saat item ditambahkan
featureListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    featureScrollFrame.CanvasSize = UDim2.new(0, 0, 0, featureListLayout.AbsoluteContentSize.Y + 10)
end)


-- 🔽 FUNGSI UTILITY GLOBAL 🔽

local function updateButtonStatus(button, isActive, featureName)
    if not button or not button.Parent then return end
    local name = featureName or button.Name:gsub("Button", ""):gsub("_", " "):upper()
    if isActive then
        button.Text = name .. ": ON"
        button.BackgroundColor3 = Color3.fromRGB(0, 180, 0) -- Hijau
    else
        button.Text = name .. ": OFF"
        button.BackgroundColor3 = Color3.fromRGB(150, 0, 0) -- Merah
    end
end


-- 🔽 FUNGSI REPULSE TOUCH (KNOCKBACK) 🔽

local function repulseTouch(otherPart)
    if not isRepulseActive or (tick() - lastRepulse < DEBOUNCE_TIME) then return end
    if not otherPart or not otherPart.Parent then return end
    
    local otherCharacter = otherPart.Parent:FindFirstAncestorOfClass("Model")
    if not otherCharacter then return end
    
    local otherPlayer = Players:GetPlayerFromCharacter(otherCharacter)
    if not otherPlayer or otherPlayer == player then return end
    
    local otherRoot = otherCharacter:FindFirstChild("HumanoidRootPart")
    if not otherRoot then return end
    
    local localRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not localRoot then return end
    
    local direction = (otherRoot.Position - localRoot.Position).Unit
    local knockbackVector = direction * KNOCKBACK_POWER
    
    pcall(function()
        otherRoot:ApplyImpulse(knockbackVector)
    end)
    
    lastRepulse = tick()
    print("Player Repulsed: " .. otherPlayer.Name)
end

local function enableRepulseTouch(button)
    if isRepulseActive then return end
    isRepulseActive = true
    
    local character = player.Character or player.CharacterAdded:Wait()
    local rootPart = character:WaitForChild("HumanoidRootPart")
    
    updateButtonStatus(button, true, "REPULSE TOUCH")
    
    if repulseTouchConnection then repulseTouchConnection:Disconnect() end
    repulseTouchConnection = rootPart.Touched:Connect(repulseTouch)
    
    print("Repulse Touch AKTIF.")
end

local function disableRepulseTouch(button)
    if not isRepulseActive then return end
    isRepulseActive = false
    updateButtonStatus(button, false, "REPULSE TOUCH")
    
    if repulseTouchConnection then
        repulseTouchConnection:Disconnect()
        repulseTouchConnection = nil
    end
    print("Repulse Touch NONAKTIF.")
end


-- 🔽 FUNGSI OWNER TITLE 🔽

local function createOwnerTitle()
    local nameDisplay = player.Character:FindFirstChild("Head"):FindFirstChild("NameDisplay")
    if not nameDisplay then return end -- Memastikan display nama asli ada

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "OwnerTitleGUI"
    billboard.Size = UDim2.new(0, 150, 0, 50)
    billboard.Adornee = player.Character.Head
    billboard.AlwaysOnTop = true
    billboard.ExtentsOffset = Vector3.new(0, 1.5, 0) -- Posisikan di atas kepala

    local label = Instance.new("TextLabel")
    label.Name = "OwnerLabel"
    label.Size = UDim2.new(1, 0, 0.5, 0)
    label.Position = UDim2.new(0, 0, 0.5, 0) -- Posisikan di bawah nama asli (atau ganti jadi 0,0,0,0 utk di atas)
    label.BackgroundTransparency = 1
    label.Text = "[ OWNER ]"
    label.TextColor3 = Color3.fromRGB(255, 255, 0) -- Kuning terang
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    label.TextStrokeTransparency = 0
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 18
    label.Parent = billboard
    
    -- Sembunyikan Billboard ini dari player lokal agar tidak terlihat diri sendiri
    billboard.LocalTransparencyModifier = 1 -- Sembunyikan dari player lokal

    billboard.Parent = player.Character.Head
end

local function destroyOwnerTitle()
    local title = player.Character and player.Character:FindFirstChild("Head") and player.Character.Head:FindFirstChild("OwnerTitleGUI")
    if title then
        title:Destroy()
    end
end

local function toggleOwnerTitle(button)
    isOwnerTitleActive = not isOwnerTitleActive
    updateButtonStatus(button, isOwnerTitleActive, "OWNER TITLE")
    
    if isOwnerTitleActive then
        createOwnerTitle()
        print("Owner Title AKTIF.")
    else
        destroyOwnerTitle()
        print("Owner Title NONAKTIF.")
    end
end


-- 🔽 FUNGSI PEMBUAT TOMBOL FITUR 🔽

local function makeFeatureButton(name, color, callback)
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

    featButton.MouseButton1Click:Connect(function()
        callback(featButton)
    end)
    return featButton
end

-- 🔽 PENAMBAHAN TOMBOL KE FEATURE LIST 🔽

-- 1. Tombol REPULSE TOUCH (Knockback)
local repulseButton = makeFeatureButton("REPULSE TOUCH: OFF", Color3.fromRGB(150, 0, 0), function(button)
    if isRepulseActive then
        disableRepulseTouch(button)
    else
        enableRepulseTouch(button)
    end
end)

-- 2. Tombol OWNER TITLE
local ownerTitleButton = makeFeatureButton("OWNER TITLE: OFF", Color3.fromRGB(150, 0, 0), toggleOwnerTitle)


-- 🔽 LOGIKA CHARACTER ADDED (PENTING UNTUK MEMPERTAHANKAN STATUS) 🔽
player.CharacterAdded:Connect(function(char)
    local repulseBtn = featureScrollFrame:FindFirstChild("RepulseTouchButton")
    local titleBtn = featureScrollFrame:FindFirstChild("OwnerTitleButton")
    
    -- Pertahankan status Repulse Touch saat respawn
    if isRepulseActive and repulseBtn then
        enableRepulseTouch(repulseBtn) 
    end
    
    -- Pertahankan status Owner Title saat respawn
    if isOwnerTitleActive and titleBtn then
        -- Gunakan createOwnerTitle secara langsung karena toggleOwnerTitle tidak bisa dipanggil dari sini
        createOwnerTitle()
        updateButtonStatus(titleBtn, true, "OWNER TITLE")
    end
end)


-- Atur status awal tombol
updateButtonStatus(repulseButton, isRepulseActive, "REPULSE TOUCH")
updateButtonStatus(ownerTitleButton, isOwnerTitleActive, "OWNER TITLE")
