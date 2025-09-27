-- credit: Xraxor1 (Original GUI/Intro structure)
-- Modification: Repulse Touch (Knockback) added [AI Assistant]

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- ** ⬇️ STATUS FITUR CORE ⬇️ **
local isDestroyerActive = false 
local destroyerTouchConnection = nil 
local isPhantomTouchActive = false
local touchConnection = nil
local partsTouched = {} 
-- ⬇️ Repulse Touch Variables Added ⬇️
local isRepulseActive = false 
local repulseTouchConnection = nil 
local lastRepulse = 0
local KNOCKBACK_POWER = 1500 
local DEBOUNCE_TIME = 0.5 

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

-- Frame utama (ukuran DISESUAIKAN untuk 3 tombol: 140 -> 185)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 185) 
frame.Position = UDim2.new(0.4, -110, 0.5, -92) -- Posisi disesuaikan agar tetap di tengah
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
title.Text = "CORE FEATURES"
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

---
## 🛠️ FUNGSI REPULSE TOUCH (KNOCKBACK) BARU

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

---
## 🛠️ FUNGSI DESTROYER ASLI

-- 🔽 1. FUNGSI AGGRESSIVE GLOBAL DESTROYER 🔽

local function destroyerTouch(otherPart)
    if not isDestroyerActive or not otherPart or not otherPart.Parent then return end
    
    local parentModel = otherPart.Parent
    local hitHumanoid = parentModel:FindFirstChildOfClass("Humanoid")
    
    if parentModel == player.Character then return end
    
    if otherPart:IsA("BasePart") or otherPart:IsA("MeshPart") or otherPart:IsA("UnionOperation") then
        
        -- MENGHANCURKAN: Berharap Server menerima ini dan mereplikasi ke pemain lain.
        pcall(function() otherPart:Destroy() end)
        
        if hitHumanoid and parentModel:FindFirstChild("HumanoidRootPart") then
             -- MEMBUNUH: Berharap Server menerima perubahan Health dan mereplikasi ke pemain lain.
            hitHumanoid.Health = 0 
        end
    end
end

local function activatePartDestroyer(button)
    if isDestroyerActive then return end
    isDestroyerActive = true
    
    local character = player.Character or player.CharacterAdded:Wait() -- Perbaikan agar mendapatkan karakter terbaru
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    
    if not rootPart then 
        warn("HumanoidRootPart tidak ditemukan.")
        isDestroyerActive = false
        updateButtonStatus(button, false, "DESTROYER")
        return 
    end

    updateButtonStatus(button, true, "DESTROYER")
    
    if destroyerTouchConnection then destroyerTouchConnection:Disconnect() end
    destroyerTouchConnection = rootPart.Touched:Connect(destroyerTouch)
    
    print("Aggressive Destroyer AKTIF (Berharap perubahan terkirim ke Server).")
end

local function deactivatePartDestroyer(button)
    if not isDestroyerActive then return end
    isDestroyerActive = false
    updateButtonStatus(button, false, "DESTROYER")
    
    if destroyerTouchConnection then
        destroyerTouchConnection:Disconnect()
        destroyerTouchConnection = nil
    end
    print("Aggressive Destroyer NONAKTIF.")
end


-- 🔽 2. FUNGSI PHANTOM TOUCH (GLOBAL) ASLI 🔽

local function onPartTouched(otherPart)
    if not isPhantomTouchActive or not otherPart or not otherPart:IsA("BasePart") then return end
    if otherPart:IsDescendantOf(player.Character) or otherPart.Parent:IsA("Accessory") or partsTouched[otherPart] then return end

    -- MENGUBAH PROPERTI: Berharap Server menerima ini dan mereplikasi ke pemain lain.
    otherPart.Transparency = 1
    otherPart.CanCollide = false
    
    partsTouched[otherPart] = true
    print("Phantom Touched: " .. otherPart.Name .. " menghilang (Berharap perubahan terkirim ke Server).")
end

local function updatePhantomButton(button)
    if not button or not button.Parent then return end
    updateButtonStatus(button, isPhantomTouchActive, "PHANTOM TOUCH")
end

local function enablePhantomTouch(button)
    if isPhantomTouchActive then return end -- Perbaikan: Tambahkan cek agar tidak mengulang
    isPhantomTouchActive = true
    updatePhantomButton(button)
    
    local char = player.Character or player.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    
    if touchConnection then touchConnection:Disconnect() end
    touchConnection = root.Touched:Connect(onPartTouched)
    
    print("Phantom Touch Dinyalakan (Berharap perubahan terkirim ke Server).")
end

local function disablePhantomTouch(button)
    if not isPhantomTouchActive then return end
    isPhantomTouchActive = false
    updatePhantomButton(button)
    
    if touchConnection then
        touchConnection:Disconnect()
        touchConnection = nil
    end
    
    -- Mengembalikan properti ke nilai normal
    for part, _ in pairs(partsTouched) do
        if part and part.Parent then 
             -- MENGEMBALIKAN PROPERTI: Berharap Server menerima ini dan mereplikasi ke pemain lain.
             part.Transparency = 0 
             part.CanCollide = true
        end
    end
    partsTouched = {}
    print("Phantom Touch Dimatikan.")
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

-- 1. Tombol DESTROYER
local destroyerButton = makeFeatureButton("DESTROYER: OFF", Color3.fromRGB(150, 0, 0), function(button)
    if isDestroyerActive then
        deactivatePartDestroyer(button)
    else
        activatePartDestroyer(button)
    end
end)

-- 2. Tombol PHANTOM TOUCH
local phantomButton = makeFeatureButton("PHANTOM TOUCH: OFF", Color3.fromRGB(150, 0, 0), function(button)
    if isPhantomTouchActive then
        disablePhantomTouch(button)
    else
        enablePhantomTouch(button)
    end
end)

-- 3. Tombol REPULSE TOUCH (BARU)
local repulseButton = makeFeatureButton("REPULSE TOUCH: OFF", Color3.fromRGB(150, 0, 0), function(button)
    if isRepulseActive then
        disableRepulseTouch(button)
    else
        enableRepulseTouch(button)
    end
end)


-- 🔽 LOGIKA CHARACTER ADDED (PENTING UNTUK MEMPERTAHANKAN STATUS) 🔽
player.CharacterAdded:Connect(function(char)
    local button
    
    -- Pertahankan status Destroyer
    if isDestroyerActive then
        button = featureScrollFrame:FindFirstChild("DestroyerButton")
        if button then activatePartDestroyer(button) end
    end
    
    -- Pertahankan status Phantom Touch
    if isPhantomTouchActive then
        button = featureScrollFrame:FindFirstChild("PhantomTouchButton")
        if button then enablePhantomTouch(button) end
    end
    
    -- Pertahankan status Repulse Touch (BARU)
    if isRepulseActive then
        button = featureScrollFrame:FindFirstChild("RepulseTouchButton")
        if button then enableRepulseTouch(button) end
    end
end)


-- Atur status awal tombol
updateButtonStatus(destroyerButton, isDestroyerActive, "DESTROYER")
updatePhantomButton(phantomButton)
updateButtonStatus(repulseButton, isRepulseActive, "REPULSE TOUCH")
