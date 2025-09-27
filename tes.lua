local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService") -- Dipertahankan untuk Animasi Intro

local player = Players.LocalPlayer

-- ** ⬇️ STATUS FITUR CORE (Disederhanakan) ⬇️ **
local selectedTarget = nil -- Variabel untuk Pemain Target yang Dipilih

-- 🔽 ANIMASI "BY : Xraxor" (Kode lama, dipertahankan) 🔽
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

-- 🔽 GUI Utama 🔽
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CoreFeaturesGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Frame utama (ukuran disesuaikan untuk fitur tunggal)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 280) -- Ukuran diperkecil
frame.Position = UDim2.new(0.4, -110, 0.5, -140)
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
title.Text = "TELEPORT TARGET MENU" -- Judul Diubah
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = frame

-- ScrollingFrame untuk Daftar Pilihan Fitur (Hanya berisi 2 tombol: Teleport dan Reset)
local featureScrollFrame = Instance.new("ScrollingFrame")
featureScrollFrame.Name = "FeatureList"
featureScrollFrame.Size = UDim2.new(1, -20, 0, 90) -- Ruang disesuaikan
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

-- 🔽 Bagian Pemilihan Target Pemain 🔽
local targetTitle = Instance.new("TextLabel")
targetTitle.Size = UDim2.new(1, 0, 0, 25)
targetTitle.Position = UDim2.new(0, 0, 0, 130) -- Posisi disesuaikan
targetTitle.BackgroundTransparency = 1
targetTitle.Text = "TARGET: NONE" 
targetTitle.TextColor3 = Color3.fromRGB(255, 255, 0)
targetTitle.Font = Enum.Font.GothamBold
targetTitle.TextSize = 14
targetTitle.Parent = frame

local playerScrollFrame = Instance.new("ScrollingFrame")
playerScrollFrame.Name = "PlayerList"
playerScrollFrame.Size = UDim2.new(1, -20, 0, 120)
playerScrollFrame.Position = UDim2.new(0.5, -100, 0, 160) -- Posisi disesuaikan
playerScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
playerScrollFrame.ScrollBarThickness = 6
playerScrollFrame.BackgroundTransparency = 1
playerScrollFrame.Parent = frame

local playerListLayout = Instance.new("UIListLayout")
playerListLayout.Padding = UDim.new(0, 2)
playerListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
playerListLayout.SortOrder = Enum.SortOrder.LayoutOrder
playerListLayout.Parent = playerScrollFrame

playerListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    playerScrollFrame.CanvasSize = UDim2.new(0, 0, 0, playerListLayout.AbsoluteContentSize.Y + 5)
end)


-- 🔽 FUNGSI UTILITY GLOBAL 🔽

local function updateTargetTitle()
    if selectedTarget and selectedTarget.Name then
        targetTitle.Text = "TARGET: " .. selectedTarget.Name:upper()
        targetTitle.TextColor3 = Color3.fromRGB(0, 255, 0)
    else
        targetTitle.Text = "TARGET: NONE"
        targetTitle.TextColor3 = Color3.fromRGB(255, 255, 0)
    end
end

-- 🔽 FUNGSI INTI: TELEPORT TARGET 🔽

local function teleportTargetToMe()
    if not selectedTarget then
        warn("Pilih target terlebih dahulu!")
        return
    end
    
    local targetCharacter = selectedTarget.Character
    local targetRoot = targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart")
    
    local localCharacter = player.Character
    local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
    
    if not targetRoot or not localRoot then
        warn("Target atau pemain lokal tidak memiliki HumanoidRootPart atau Karakter.")
        return
    end
    
    -- Tentukan posisi di depan pemain lokal
    local distance = 5 -- Jarak di depan pemain lokal
    local newPositionCFrame = localRoot.CFrame * CFrame.new(0, 0, -distance) 
    
    -- Teleport Target ke posisi baru tersebut
    pcall(function()
        -- Gunakan CFrame untuk memindahkan root part target, mempertahankan rotasi target
        targetRoot.CFrame = newPositionCFrame * CFrame.Angles(targetRoot.CFrame:ToOrientation())
        print("Teleported target: " .. selectedTarget.Name .. " to near player.")
    end)
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

-- 🔽 FUNGSI PEMBUAT TOMBOL PEMAIN 🔽

local function createPlayerButton(targetPlayer)
    local pButton = Instance.new("TextButton")
    pButton.Name = targetPlayer.Name .. "TargetButton"
    pButton.Size = UDim2.new(0, 180, 0, 30)
    pButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    pButton.Text = targetPlayer.Name
    pButton.TextColor3 = Color3.new(1, 1, 1)
    pButton.Font = Enum.Font.SourceSans
    pButton.TextSize = 14
    pButton.Parent = playerScrollFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = pButton

    pButton.MouseButton1Click:Connect(function()
        -- Atur Target yang Dipilih
        selectedTarget = targetPlayer
        
        -- Reset warna semua tombol
        for _, button in ipairs(playerScrollFrame:GetChildren()) do
            if button:IsA("TextButton") then
                button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            end
        end
        
        -- Set warna tombol yang dipilih
        pButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
        
        updateTargetTitle()
        print("Target set to: " .. targetPlayer.Name)
    end)
    return pButton
end

local function refreshPlayerList()
    -- Hapus tombol lama
    for _, button in ipairs(playerScrollFrame:GetChildren()) do
        if button:IsA("TextButton") then
            button:Destroy()
        end
    end
    
    -- Buat tombol baru
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then -- Jangan masukkan diri sendiri
            createPlayerButton(p)
        end
    end
end

-- Refresh daftar saat ada pemain masuk/keluar
Players.PlayerAdded:Connect(refreshPlayerList)
Players.PlayerRemoving:Connect(function(p)
    if selectedTarget == p then
        selectedTarget = nil
        updateTargetTitle()
    end
    refreshPlayerList()
end)

-- 🔽 PENAMBAHAN TOMBOL KE FEATURE LIST 🔽

-- 1. Tombol TELEPORT TO ME
local teleportButton = makeFeatureButton("TELEPORT TARGET TO ME", Color3.fromRGB(0, 150, 255), function()
    teleportTargetToMe()
end)

-- 2. Tombol Reset Target
local resetButton = makeFeatureButton("RESET TARGET", Color3.fromRGB(200, 200, 0), function()
    selectedTarget = nil
    updateTargetTitle()
    refreshPlayerList()
    print("Target Direset.")
end)


-- Atur status awal dan daftar pemain
updateTargetTitle()
refreshPlayerList()
