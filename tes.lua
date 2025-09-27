--[[
    Skrip Trolling Penuh (Final Version - 5 Tombol + List Pemain)
    
    Perubahan Utama:
    1. POSSESSION BOND diubah menjadi sistem seleksi target.
    2. Frame GUI diperbesar dan ditambahkan PlayerList Frame.
    
    credit: Xraxor1 (Original GUI/Intro structure)
    Modification for Advanced TROLLING: [AI Assistant]
--]]

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui") 
local UserInputService = game:GetService("UserInputService") 

local player = Players.LocalPlayer

-- ** ⬇️ STATUS FITUR CORE ⬇️ **
local isSpeedBoostActive = false 
local isPossessionActive = false 
local isGravityForceActive = false
local isTargetFreezeActive = false 
local isAutoChatActive = false
local isPlayerListVisible = false -- Status list pemain

-- Nilai Konstan
local DEFAULT_WALKSPEED = 16
local BOOST_WALKSPEED = 40
local GRAVITY_FORCE_MAGNITUDE = 50000 
local currentBond = nil 
local originalTargetWalkSpeed = {} -- Menggunakan tabel untuk menyimpan status multiple target
local currentBondTarget = nil -- Pemain yang sedang terikat

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

-- Frame utama (ukuran disesuaikan untuk 5 tombol DAN Player List)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 400, 0, 280) -- Ukuran diperbesar (Lebar 400)
frame.Position = UDim2.new(0.5, -200, 0.5, -140)
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
title.Text = "ADVANCED TROLLING & LOCAL"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = frame

-- ScrollingFrame untuk Daftar Pilihan Fitur (Kiri)
local featureScrollFrame = Instance.new("ScrollingFrame")
featureScrollFrame.Name = "FeatureList"
featureScrollFrame.Size = UDim2.new(0.45, 0, 1, -40) -- Ambil 45% lebar
featureScrollFrame.Position = UDim2.new(0, 10, 0, 35)
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

-- ScrollingFrame untuk Daftar Pemain (Kanan)
local playerListFrame = Instance.new("ScrollingFrame")
playerListFrame.Name = "PlayerList"
playerListFrame.Size = UDim2.new(0.5, 0, 1, -40) -- Ambil 50% lebar
playerListFrame.Position = UDim2.new(0.5, 10, 0, 35)
playerListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
playerListFrame.ScrollBarThickness = 6
playerListFrame.BackgroundTransparency = 1
playerListFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
playerListFrame.Visible = false -- Sembunyikan secara default
playerListFrame.Parent = frame

local playerListLayout = Instance.new("UIListLayout")
playerListLayout.Padding = UDim.new(0, 2)
playerListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
playerListLayout.SortOrder = Enum.SortOrder.LayoutOrder
playerListLayout.Parent = playerListFrame

playerListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    playerListFrame.CanvasSize = UDim2.new(0, 0, 0, playerListLayout.AbsoluteContentSize.Y + 10)
end)


-- 🔽 FUNGSI UTILITY GLOBAL 🔽

local function updateButtonStatus(button, isActive, featureName, isTrolling)
    if not button or not button.Parent then return end
    local name = featureName or button.Name:gsub("Button", ""):gsub("_", " "):upper()
    
    local onColor = isTrolling and Color3.fromRGB(200, 50, 0) or Color3.fromRGB(0, 180, 0) 
    local offColor = Color3.fromRGB(150, 0, 0)
    
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

-- ⬇️ FUNGSI PLAYER LIST ⬇️

local function createPlayerButton(targetPlayer)
    local playerName = targetPlayer.Name
    local playerButton = Instance.new("TextButton")
    playerButton.Name = playerName .. "Entry"
    playerButton.Size = UDim2.new(1, 0, 0, 25)
    playerButton.BackgroundTransparency = 1
    playerButton.Text = playerName
    playerButton.TextColor3 = Color3.new(1, 1, 1)
    playerButton.TextSize = 14
    playerButton.Font = Enum.Font.SourceSans
    playerButton.TextXAlignment = Enum.TextXAlignment.Left
    playerButton.Parent = playerListFrame
    
    playerButton.MouseEnter:Connect(function() playerButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50) end)
    playerButton.MouseLeave:Connect(function() playerButton.BackgroundTransparency = 1 end)
    
    playerButton.MouseButton1Click:Connect(function()
        -- Panggil fungsi Possess pada pemain yang dipilih
        if isPossessionActive and currentBondTarget == nil then
            applyPossessionBond(targetPlayer)
        elseif currentBondTarget == targetPlayer then
            releasePossessionBond()
        end
    end)
    return playerButton
end

local function refreshPlayerList()
    -- Hapus entri lama
    for _, child in ipairs(playerListFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    -- Tambahkan entri baru
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then
            createPlayerButton(p)
        end
    end
end

local function togglePlayerList(isVisible)
    isPlayerListVisible = isVisible
    playerListFrame.Visible = isVisible
    
    if isVisible then
        refreshPlayerList()
    end
end


-- --- FUNGSI LOKAL (Klien) ---

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

-- 🔽 2. POSSESSION BOND (IKATAN KEPEMILIKAN) - Logika Baru 🔽

local function releasePossessionBond()
    if currentBond and currentBond.Parent then
        currentBond:Destroy()
        currentBond = nil
    end
    
    -- Kembalikan kontrol pergerakan target
    local targetHumanoid = getHumanoid(currentBondTarget)
    if targetHumanoid and originalTargetWalkSpeed[currentBondTarget.Name] then
        targetHumanoid.WalkSpeed = originalTargetWalkSpeed[currentBondTarget.Name]
        originalTargetWalkSpeed[currentBondTarget.Name] = nil
    end
    print("POSSESSION BOND NONAKTIF. Ikatan dilepas dari " .. currentBondTarget.Name)
    currentBondTarget = nil
end

local function applyPossessionBond(targetPlayer)
    if currentBondTarget ~= nil then 
        releasePossessionBond() 
        return 
    end -- Lepas ikatan jika sudah ada
    
    if not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        warn("Target tidak valid atau belum spawn.")
        return
    end

    local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")

    if not myRoot or not targetRoot then return end

    currentBondTarget = targetPlayer
    
    -- 1. Buat Ikatan Fisik 
    currentBond = Instance.new("WeldConstraint")
    currentBond.Name = "PossessionWeld"
    currentBond.Part0 = myRoot
    currentBond.Part1 = targetRoot
    currentBond.Parent = myRoot 

    -- 2. Matikan kontrol pergerakan target
    local targetHumanoid = getHumanoid(targetPlayer)
    if targetHumanoid then
        originalTargetWalkSpeed[targetPlayer.Name] = targetHumanoid.WalkSpeed
        targetHumanoid.WalkSpeed = 0 
    end

    print("POSSESSION BOND AKTIF: Terikat pada " .. targetPlayer.Name)
end

local function togglePossessionButton(button)
    isPossessionActive = not isPossessionActive
    updateButtonStatus(button, isPossessionActive, "POSSESSION BOND", true) 

    if isPossessionActive then
        togglePlayerList(true)
        if currentBondTarget ~= nil then
             releasePossessionBond() -- Pastikan tidak ada ikatan lama
        end
    else
        togglePlayerList(false)
        if currentBondTarget ~= nil then
            releasePossessionBond()
        end
    end
end

-- 🔽 3. GRAVITASI PAKSA (FORCED GRAVITY) 🔽
local function toggleForcedGravity(button)
    isGravityForceActive = not isGravityForceActive
    updateButtonStatus(button, isGravityForceActive, "GRAVITASI PAKSA", true)
    
    if isGravityForceActive then
        togglePlayerList(false)
        task.spawn(function()
            while isGravityForceActive do
                for _, targetP in ipairs(Players:GetPlayers()) do
                    if targetP ~= player and targetP.Character then
                        applyForcedGravity(targetP)
                    end
                end
                task.wait(math.random(5, 15)) 
            end
        end)
    else
        togglePlayerList(false)
    end
end


-- 🔽 4. PEMBEKUAN TARGET (TARGET FREEZE) 🔽
local function freezeTarget(targetPlayer)
    if not targetPlayer or targetPlayer == player then return end

    local targetHumanoid = getHumanoid(targetPlayer)
    if targetHumanoid then
        local originalWalkSpeed = targetHumanoid.WalkSpeed 
        targetHumanoid.WalkSpeed = 0 
        
        task.wait(3) 

        targetHumanoid.WalkSpeed = originalWalkSpeed
    end
end

local function toggleTargetFreeze(button)
    isTargetFreezeActive = not isTargetFreezeActive
    updateButtonStatus(button, isTargetFreezeActive, "TARGET FREEZE", true)

    if isTargetFreezeActive then
        togglePlayerList(false)
        task.spawn(function()
            while isTargetFreezeActive do
                local playerList = Players:GetPlayers()
                local targetIndex = math.random(1, #playerList)
                local targetP = playerList[targetIndex]
                
                if targetP ~= player and targetP.Character then
                    freezeTarget(targetP)
                end

                task.wait(math.random(10, 25)) 
            end
        end)
    else
        togglePlayerList(false)
    end
end


-- 🔽 5. Pesan Otomatis yang Menggiring (Subtle Auto Chat) 🔽
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
        togglePlayerList(false)
        task.spawn(autoChatLoop)
    else
        togglePlayerList(false)
    end
end


-- 🔽 FUNGSI PEMBUAT TOMBOL FITUR 🔽

local function makeFeatureButton(name, color, callback, isTrolling, currentStatus)
    local featButton = Instance.new("TextButton")
    featButton.Name = name:gsub(" ", "") .. "Button"
    featButton.Size = UDim2.new(0, 160, 0, 40) -- Ukuran lebih kecil agar pas
    featButton.BackgroundColor3 = color
    featButton.Text = name
    featButton.TextColor3 = Color3.new(1, 1, 1)
    featButton.Font = Enum.Font.GothamBold
    featButton.TextSize = 12
    featButton.Parent = featureScrollFrame

    Instance.new("UICorner", featButton).CornerRadius = UDim.new(0, 10)
    updateButtonStatus(featButton, currentStatus, name, isTrolling)

    featButton.MouseButton1Click:Connect(function()
        callback(featButton)
    end)
    return featButton
end

-- 🔽 PENAMBAHAN TOMBOL KE FEATURE LIST 🔽

-- LOCAL FEATURE (Slot 1)
local speedButton = makeFeatureButton("SPEED BOOST", Color3.fromRGB(150, 0, 0), toggleSpeedBoost, false, isSpeedBoostActive)

-- TROLLING FEATURE: POSSESSION BOND (Slot 2)
local bondButton = makeFeatureButton("POSSESSION BOND", Color3.fromRGB(150, 0, 0), togglePossessionButton, true, isPossessionActive)

-- TROLLING FEATURE: GRAVITASI PAKSA (Slot 3)
local gravityButton = makeFeatureButton("GRAVITASI PAKSA", Color3.fromRGB(150, 0, 0), toggleForcedGravity, true, isGravityForceActive)

-- TROLLING FEATURE: TARGET FREEZE (Slot 4)
local freezeButton = makeFeatureButton("TARGET FREEZE", Color3.fromRGB(150, 0, 0), toggleTargetFreeze, true, isTargetFreezeActive)

-- TROLLING FEATURE: AUTO CHAT (Slot 5)
local autoChatButton = makeFeatureButton("AUTO CHAT", Color3.fromRGB(150, 0, 0), toggleAutoChat, true, isAutoChatActive)


-- 🔽 LOGIKA CHARACTER ADDED (PENTING UNTUK MEMPERTAHANKAN STATUS) 🔽
player.CharacterAdded:Connect(function(char)
    local humanoid = char:WaitForChild("Humanoid")
    
    -- Pertahankan Speed Boost
    humanoid.WalkSpeed = isSpeedBoostActive and BOOST_WALKSPEED or DEFAULT_WALKSPEED
    
    -- Update GUI status setelah respawn
    updateButtonStatus(speedButton, isSpeedBoostActive, "SPEED BOOST", false)
    updateButtonStatus(bondButton, isPossessionActive, "POSSESSION BOND", true)
    updateButtonStatus(gravityButton, isGravityForceActive, "GRAVITASI PAKSA", true)
    updateButtonStatus(freezeButton, isTargetFreezeActive, "TARGET FREEZE", true)
    updateButtonStatus(autoChatButton, isAutoChatActive, "AUTO CHAT", true)
    
    -- Jika Possession aktif, coba ikat ulang ke pemain terdekat setelah respawn
    if isPossessionActive then
        -- Tidak otomatis bind; hanya tampilkan list lagi
        togglePlayerList(true) 
    end
end)

Players.PlayerAdded:Connect(refreshPlayerList)
Players.PlayerRemoving:Connect(refreshPlayerList)
