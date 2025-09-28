local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- ** ⬇️ STATUS FITUR CORE ⬇️ **
local isTetherActive = false 
local tetherTouchConnection = nil
local activeTethers = {} -- Menyimpan weld untuk pemain yang sedang diikat

-- ** ⬇️ STATUS FITUR RESPOND ⬇️ **
local selectedPlayer = nil -- Menyimpan pemain yang saat ini dipilih
local playerListButtons = {} -- Menyimpan referensi tombol pemain

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


-- 🔽 GUI Utama 🔽
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CoreFeaturesGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Frame utama (Disesuaikan agar lebih besar)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 300) -- Ukuran diperbesar untuk menampung fitur baru
frame.Position = UDim2.new(0.4, -110, 0.5, -150) -- Disesuaikan agar tetap di tengah
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

-- ScrollingFrame untuk Daftar Pilihan Fitur (Player Tether)
local featureScrollFrame = Instance.new("ScrollingFrame")
featureScrollFrame.Name = "FeatureList"
featureScrollFrame.Size = UDim2.new(1, -20, 0, 60) -- Lebih kecil
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

-- *** KONTEN BARU: BAGIAN RESPAWN PEMAIN ***

-- Judul Respawn
local respawnTitle = Instance.new("TextLabel")
respawnTitle.Size = UDim2.new(1, 0, 0, 30)
respawnTitle.Position = UDim2.new(0, 0, 0, 100) -- Posisi di bawah FeatureList
respawnTitle.BackgroundTransparency = 1
respawnTitle.Text = "FORCE RESPAWN"
respawnTitle.TextColor3 = Color3.new(1, 1, 1)
respawnTitle.Font = Enum.Font.GothamBold
respawnTitle.TextSize = 16
respawnTitle.Parent = frame

-- Tombol Respawn
local killButton = Instance.new("TextButton")
killButton.Name = "KillPlayerButton"
killButton.Size = UDim2.new(0, 180, 0, 40)
killButton.Position = UDim2.new(0.5, -90, 0, 135)
killButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
killButton.Text = "RESPAWN: BELUM DIPILIH"
killButton.TextColor3 = Color3.new(1, 1, 1)
killButton.Font = Enum.Font.GothamBold
killButton.TextSize = 12
killButton.Parent = frame

local killCorner = Instance.new("UICorner")
killCorner.CornerRadius = UDim.new(0, 10)
killCorner.Parent = killButton

-- ScrollingFrame untuk Daftar Pemain
local playerScrollFrame = Instance.new("ScrollingFrame")
playerScrollFrame.Name = "PlayerList"
playerScrollFrame.Size = UDim2.new(1, -20, 0, 100)
playerScrollFrame.Position = UDim2.new(0.5, -100, 0, 180) -- Posisi di bawah KillButton
playerScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
playerScrollFrame.ScrollBarThickness = 6
playerScrollFrame.BackgroundTransparency = 1
playerScrollFrame.Parent = frame

local playerListLayout = Instance.new("UIListLayout")
playerListLayout.Padding = UDim.new(0, 5)
playerListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
playerListLayout.SortOrder = Enum.SortOrder.LayoutOrder
playerListLayout.Parent = playerScrollFrame

playerListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    playerScrollFrame.CanvasSize = UDim2.new(0, 0, 0, playerListLayout.AbsoluteContentSize.Y + 10)
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


-- 🔽 FUNGSI PLAYER TETHER (IKAT PEMAIN) 🔽

local function onTetherTouch(otherPart)
    if not isTetherActive or not otherPart or not otherPart.Parent then return end

    local targetPlayer = Players:GetPlayerFromCharacter(otherPart.Parent)
    local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    local targetRoot = targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")

    if not myRoot or not targetRoot or targetPlayer == player then return end

    -- Hanya ikat pemain yang belum diikat
    if not activeTethers[targetPlayer.UserId] then
        local tetherWeld = Instance.new("WeldConstraint")
        tetherWeld.Name = "PlayerTetherWeld"
        tetherWeld.Part0 = myRoot
        tetherWeld.Part1 = targetRoot
        tetherWeld.Parent = targetRoot
        
        activeTethers[targetPlayer.UserId] = tetherWeld
        print("Tether Aktif: Mengikat " .. targetPlayer.Name)
    end
end

local function releaseAllTethers()
    for userId, weld in pairs(activeTethers) do
        if weld and weld.Parent then
            weld:Destroy()
        end
    end
    activeTethers = {}
end

local function activateTether(button)
    if isTetherActive then return end
    isTetherActive = true
    
    local character = player.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    
    if not rootPart then 
        warn("HumanoidRootPart tidak ditemukan.")
        isTetherActive = false
        updateButtonStatus(button, false, "PLAYER TETHER")
        return 
    end

    updateButtonStatus(button, true, "PLAYER TETHER")
    
    if tetherTouchConnection then tetherTouchConnection:Disconnect() end
    tetherTouchConnection = rootPart.Touched:Connect(onTetherTouch)
    
    print("Player Tether AKTIF.")
end

local function deactivateTether(button)
    if not isTetherActive then return end
    isTetherActive = false
    
    if tetherTouchConnection then
        tetherTouchConnection:Disconnect()
        tetherTouchConnection = nil
    end
    
    releaseAllTethers() -- Lepaskan semua ikatan
    updateButtonStatus(button, false, "PLAYER TETHER")
    print("Player Tether NONAKTIF.")
end

-- 🔽 FUNGSI FORCE RESPAWN/KILL PEMAIN LAIN 🔽

local function forcePlayerRespawn(targetPlayer)
    if not targetPlayer then return end
    
    local char = targetPlayer.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")

    -- ** Ini adalah fungsi sisi klien yang mencoba memicu respawn.
    -- ** Di lingkungan Roblox standar, ini HANYA akan bekerja jika server
    -- ** telah mengekspos RemoteEvent untuk fungsi ini.
    -- ** Namun, dalam konteks Executor, ini bisa bekerja:
    if humanoid then
        humanoid.Health = 0 -- Mematikan pemain
        print("Mencoba mematikan: " .. targetPlayer.Name)
        
        -- Opsi lain (hanya akan berfungsi di lingkungan Executor/Server-side):
        -- targetPlayer:LoadCharacter() 
    else
        warn("Gagal mematikan: Humanoid tidak ditemukan untuk " .. targetPlayer.Name)
    end
end

-- 🔽 FUNGSI PEMBUAT TOMBOL PEMAIN 🔽

local function makePlayerButton(targetPlayer)
    local pButton = Instance.new("TextButton")
    pButton.Name = targetPlayer.Name .. "Button"
    pButton.Size = UDim2.new(0, 180, 0, 25)
    pButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    pButton.Text = targetPlayer.Name
    pButton.TextColor3 = Color3.new(1, 1, 1)
    pButton.Font = Enum.Font.GothamBold
    pButton.TextSize = 12
    pButton.Parent = playerScrollFrame

    local pCorner = Instance.new("UICorner")
    pCorner.CornerRadius = UDim.new(0, 5)
    pCorner.Parent = pButton

    pButton.MouseButton1Click:Connect(function()
        -- Atur ulang warna tombol yang sebelumnya dipilih
        if selectedPlayer and playerListButtons[selectedPlayer.UserId] then
            playerListButtons[selectedPlayer.UserId].BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        end

        -- Pilih pemain baru
        selectedPlayer = targetPlayer
        pButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0) -- Warna untuk pemain terpilih

        -- Perbarui teks tombol kill
        killButton.Text = "RESPAWN: " .. targetPlayer.Name:upper()
        print("Pemain dipilih: " .. targetPlayer.Name)
    end)

    playerListButtons[targetPlayer.UserId] = pButton
    return pButton
end

-- 🔽 FUNGSI UNTUK MEMPERBARUI DAFTAR PEMAIN 🔽

local function updatePlayerList()
    -- Hapus tombol lama
    for _, button in pairs(playerListButtons) do
        button:Destroy()
    end
    playerListButtons = {}
    selectedPlayer = nil
    killButton.Text = "RESPAWN: BELUM DIPILIH"

    -- Tambahkan pemain baru
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then -- Jangan tambahkan diri sendiri
            makePlayerButton(p)
        end
    end
end

-- Hubungkan event Players.PlayerAdded dan Players.PlayerRemoving
Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)


-- 🔽 FUNGSI PEMBUAT TOMBOL FITUR (Tether) 🔽

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

-- Tombol PLAYER TETHER
local tetherButton = makeFeatureButton("PLAYER TETHER: OFF", Color3.fromRGB(150, 0, 0), function(button)
    if isTetherActive then
        deactivateTether(button)
    else
        activateTether(button)
    end
end)

-- Hubungkan tombol Kill
killButton.MouseButton1Click:Connect(function()
    if selectedPlayer then
        forcePlayerRespawn(selectedPlayer)
    else
        print("Pilih pemain terlebih dahulu.")
    end
end)


-- 🔽 LOGIKA CHARACTER ADDED (PENTING UNTUK MEMPERTAHANKAN STATUS) 🔽
player.CharacterAdded:Connect(function(char)
    -- Pastikan semua ikatan dilepas saat respawn (untuk menghindari error)
    releaseAllTethers() 
    
    -- Pertahankan status Player Tether
    if isTetherActive then
        char:WaitForChild("HumanoidRootPart", 5)
        local button = featureScrollFrame:FindFirstChild("PlayerTetherButton")
        if button then activateTether(button) end
    end
end)

-- Inisialisasi: Atur status awal tombol dan daftar pemain
updateButtonStatus(tetherButton, isTetherActive, "PLAYER TETHER")
task.wait(0.1) -- Beri waktu GUI untuk diinisialisasi
updatePlayerList() 
