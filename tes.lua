--[[
    Skrip SPECTATE/VIEW PLAYER Standalone (Final)
    
    Fitur Utama:
    - SPECTATE/VIEW PLAYER: Pilih pemain dari daftar untuk membuat kamera Anda melihat dan mengikuti karakter mereka.
    - Player List Interaktif: Daftar pemain selalu terlihat. KLIK NAMA PEMAIN untuk mengaktifkan Spectate/View atau menghentikannya.
    
    credit: Xraxor1 (Original GUI/Intro structure)
    Modification for Spectate Feature: [AI Assistant]
    
    LOGIKA BARU: Mengubah posisi kamera lokal (spectate) alih-alih memindahkan karakter atau mengikatnya.
--]]

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

-- ** ⬇️ STATUS FITUR CORE ⬇️ **
local currentTarget = nil 
local originalCameraSubject = nil -- Menyimpan subjek kamera asli (biasanya Humanoid)

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
screenGui.Name = "SpectateGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Frame utama (ukuran ringkas, hanya untuk daftar pemain)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 280) 
frame.Position = UDim2.new(0.5, -100, 0.5, -140)
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
title.Text = "PLAYER VIEW (SPECTATE)"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = frame


-- ScrollingFrame untuk Daftar Pemain
local playerListFrame = Instance.new("ScrollingFrame")
playerListFrame.Name = "PlayerList"
playerListFrame.Size = UDim2.new(1, -20, 1, -40) 
playerListFrame.Position = UDim2.new(0.5, -90, 0, 35)
playerListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
playerListFrame.ScrollBarThickness = 6
playerListFrame.BackgroundTransparency = 1
playerListFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
playerListFrame.Parent = frame

local playerListTitle = Instance.new("TextLabel")
playerListTitle.Size = UDim2.new(1, 0, 0, 20)
playerListTitle.BackgroundTransparency = 1
playerListTitle.TextColor3 = Color3.new(1, 1, 1)
playerListTitle.TextSize = 14
playerListTitle.Font = Enum.Font.GothamBold
playerListTitle.Text = "KLIK NAMA UNTUK VIEW / BERHENTI"
playerListTitle.Parent = playerListFrame

local playerListLayout = Instance.new("UIListLayout")
playerListLayout.Padding = UDim.new(0, 2)
playerListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
playerListLayout.SortOrder = Enum.SortOrder.LayoutOrder
playerListLayout.Parent = playerListFrame

playerListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    playerListFrame.CanvasSize = UDim2.new(0, 0, 0, playerListLayout.AbsoluteContentSize.Y + 10)
end)


-- 🔽 FUNGSI UTILITY GLOBAL 🔽

local function getHumanoid(target)
    local char = target.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end


-- ⬇️ FUNGSI SPECTATE ⬇️

local function stopSpectate()
    if currentTarget and originalCameraSubject and Workspace.CurrentCamera then
        -- Kembalikan Subjek Kamera ke Humanoid pemain lokal
        Workspace.CurrentCamera.CameraSubject = originalCameraSubject
    end
    print("SPECTATE NONAKTIF. Kamera kembali ke diri sendiri.")
    currentTarget = nil
    originalCameraSubject = nil
end

local function startSpectate(targetPlayer)
    if currentTarget ~= nil then 
        stopSpectate() 
    end
    
    local targetHumanoid = getHumanoid(targetPlayer)
    if not targetHumanoid then
        warn("Target tidak valid atau belum spawn.")
        return
    end

    currentTarget = targetPlayer
    
    if Workspace.CurrentCamera then
        -- Simpan subjek kamera asli sebelum diubah
        originalCameraSubject = Workspace.CurrentCamera.CameraSubject
        
        -- Ubah tipe kamera
        Workspace.CurrentCamera.CameraType = Enum.CameraType.Follow
        
        -- Set subjek kamera ke Humanoid target
        Workspace.CurrentCamera.CameraSubject = targetHumanoid
    end

    print("SPECTATE AKTIF: Melihat posisi " .. targetPlayer.Name)
end

local function createPlayerButton(targetPlayer)
    local playerName = targetPlayer.Name
    local playerButton = Instance.new("TextButton")
    playerButton.Name = playerName .. "Entry"
    playerButton.Size = UDim2.new(1, 0, 0, 25)
    playerButton.BackgroundTransparency = 1
    
    -- Warna teks disesuaikan
    if currentTarget == targetPlayer then
        playerButton.TextColor3 = Color3.fromRGB(0, 255, 0) -- Hijau jika sedang dilihat
        playerButton.Text = "[VIEWING] " .. playerName
    else
        playerButton.TextColor3 = Color3.new(1, 1, 1) -- Putih default
        playerButton.Text = playerName 
    end
    
    playerButton.TextSize = 14
    playerButton.Font = Enum.Font.SourceSans
    playerButton.TextXAlignment = Enum.TextXAlignment.Left
    playerButton.Parent = playerListFrame
    
    -- Hapus Efek hover agar terlihat seperti teks biasa
    
    playerButton.MouseButton1Click:Connect(function()
        -- Logika klik: jika sudah spectate target ini, hentikan. Jika belum, mulai spectate.
        if currentTarget == targetPlayer then
            stopSpectate()
        else
            startSpectate(targetPlayer)
        end
        refreshPlayerList() -- Perbarui GUI setelah aksi
    end)
    return playerButton
end

local function refreshPlayerList()
    -- Hapus entri lama (kecuali judul)
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


-- 🔽 LOGIKA KARAKTER & EVENT 🔽

player.CharacterAdded:Connect(function(char)
    -- Jika Spectate sedang aktif pada target, hentikan sementara saat respawn
    if currentTarget ~= nil then
        stopSpectate()
    end
    refreshPlayerList()
end)

-- Hubungkan event Player Added/Removing agar list pemain otomatis diperbarui
Players.PlayerAdded:Connect(refreshPlayerList)
Players.PlayerRemoving:Connect(function(removedPlayer)
    if currentTarget == removedPlayer then
        stopSpectate()
    end
    refreshPlayerList()
end)

-- Panggil refresh list saat skrip pertama kali dimuat
refreshPlayerList()
