local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris") -- Tambahkan Service Debris untuk pembersihan

local player = Players.LocalPlayer

-- ** ⬇️ STATUS FITUR CORE ⬇️ **
local isRepulseActive = false 
local repulseTouchConnection = nil 
local lastRepulse = 0
local KNOCKBACK_POWER = 10000 -- Kekuatan dorongan maksimal
local DEBOUNCE_TIME = 0 -- Tanpa jeda waktu

local isOwnerTitleActive = false -- Status fitur Owner Title baru

local selectedTarget = nil -- 🔽 Variabel baru untuk Pemain Target yang Dipilih 🔽
local isCagingActive = false -- 🔽 VARIABEL BARU UNTUK CAGE PLAYER 🔽
local currentCageParts = {} -- 🔽 Tabel untuk menyimpan bagian-bagian sangkar 🔽

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

-- Frame utama (ukuran disesuaikan agar cukup untuk fitur tambahan)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 365) -- UKURAN DIPERBESAR
frame.Position = UDim2.new(0.4, -110, 0.5, -182) -- POSISI DISESUAIKAN
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
title.Text = "CORE FEATURE & TARGET"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = frame

-- ScrollingFrame untuk Daftar Pilihan Fitur
local featureScrollFrame = Instance.new("ScrollingFrame")
featureScrollFrame.Name = "FeatureList"
featureScrollFrame.Size = UDim2.new(1, -20, 0, 145) -- RUANG UNTUK FITUR TAMBAHAN
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
targetTitle.Position = UDim2.new(0, 0, 0, 185) -- POSISI DISESUAIKAN
targetTitle.BackgroundTransparency = 1
targetTitle.Text = "TARGET: NONE" -- Akan diupdate
targetTitle.TextColor3 = Color3.fromRGB(255, 255, 0)
targetTitle.Font = Enum.Font.GothamBold
targetTitle.TextSize = 14
targetTitle.Parent = frame

local playerScrollFrame = Instance.new("ScrollingFrame")
playerScrollFrame.Name = "PlayerList"
playerScrollFrame.Size = UDim2.new(1, -20, 0, 150)
playerScrollFrame.Position = UDim2.new(0.5, -100, 0, 215) -- POSISI DISESUAIKAN
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

local function updateTargetTitle()
    if selectedTarget and selectedTarget.Name then
        targetTitle.Text = "TARGET: " .. selectedTarget.Name:upper()
        targetTitle.TextColor3 = Color3.fromRGB(0, 255, 0)
    else
        targetTitle.Text = "TARGET: NONE"
        targetTitle.TextColor3 = Color3.fromRGB(255, 255, 0)
    end
end

-- 🔽 FUNGSI REPULSE TOUCH (KNOCKBACK) - Diubah untuk Target 🔽
-- ... (Fungsi repulseTouch, enableRepulseTouch, disableRepulseTouch tidak diubah dari kode Anda)
local function repulseTouch(otherPart)
    if not isRepulseActive or (tick() - lastRepulse < DEBOUNCE_TIME) then return end
    
    local otherCharacter = otherPart.Parent:FindFirstAncestorOfClass("Model")
    if not otherCharacter then return end
    
    local otherPlayer = Players:GetPlayerFromCharacter(otherCharacter)
    
    -- ** 💡 LOGIKA BARU: Hanya Dorong Pemain Target atau Semua Pemain jika Belum Ada Target 💡 **
    if otherPlayer == player then return end
    
    local isTarget = (selectedTarget and otherPlayer == selectedTarget)
    
    -- Jika Target telah dipilih, hanya dorong Target. Jika tidak ada target, dorong siapa pun.
    if selectedTarget and not isTarget then return end
    
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

-- 🔽 FUNGSI OWNER TITLE (Dipertahankan) 🔽
-- ... (Fungsi createOwnerTitle, destroyOwnerTitle, toggleOwnerTitle tidak diubah dari kode Anda)
local function createOwnerTitle()
    local nameDisplay = player.Character:FindFirstChild("Head"):FindFirstChild("NameDisplay")
    if not nameDisplay then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "OwnerTitleGUI"
    billboard.Size = UDim2.new(0, 150, 0, 50)
    billboard.Adornee = player.Character.Head
    billboard.AlwaysOnTop = true
    billboard.ExtentsOffset = Vector3.new(0, 1.5, 0)

    local label = Instance.new("TextLabel")
    label.Name = "OwnerLabel"
    label.Size = UDim2.new(1, 0, 0.5, 0)
    label.Position = UDim2.new(0, 0, 0.5, 0)
    label.BackgroundTransparency = 1
    label.Text = "[ OWNER ]"
    label.TextColor3 = Color3.fromRGB(255, 255, 0)
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    label.TextStrokeTransparency = 0
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 18
    label.Parent = billboard
    
    billboard.LocalTransparencyModifier = 1 

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


-- 🔽 FUNGSI CAGE PLAYER BARU 🔽

local function makeCagePart(cframe, size, transparency, color)
    local part = Instance.new("Part")
    part.CFrame = cframe
    part.Size = size
    part.Transparency = transparency
    part.Color = color or Color3.fromRGB(0, 150, 255)
    part.Material = Enum.Material.ForceField -- Biar kelihatan keren dan tembus pandang
    part.Anchored = true
    part.CanCollide = true
    part.Name = "CageWall"
    part.Parent = workspace.TemporaryCages or Instance.new("Folder", workspace) -- Simpan di folder sementara
    part.Parent.Name = "TemporaryCages"
    return part
end

local function createCageForTarget()
    if not selectedTarget or not selectedTarget.Character then
        warn("Tidak ada target atau target tidak memiliki karakter.")
        return false
    end
    
    local targetCharacter = selectedTarget.Character
    local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
    
    if not targetRoot then
        warn("Target tidak memiliki HumanoidRootPart.")
        return false
    end

    local cageSize = 8 -- Ukuran sisi sangkar (misalnya, 8x8x8)
    local wallThickness = 0.5
    local wallHeight = 10 -- Tinggi dinding

    local centerPosition = targetRoot.CFrame.p + Vector3.new(0, wallHeight/2 - targetRoot.Size.Y/2, 0) -- Posisikan di sekitar karakter

    currentCageParts = {}

    -- 1. Dinding Depan
    local frontWall = makeCagePart(
        CFrame.new(centerPosition) * CFrame.new(0, 0, -cageSize/2 + wallThickness/2), 
        Vector3.new(cageSize, wallHeight, wallThickness), 
        0.5
    )
    table.insert(currentCageParts, frontWall)

    -- 2. Dinding Belakang
    local backWall = makeCagePart(
        CFrame.new(centerPosition) * CFrame.new(0, 0, cageSize/2 - wallThickness/2), 
        Vector3.new(cageSize, wallHeight, wallThickness), 
        0.5
    )
    table.insert(currentCageParts, backWall)

    -- 3. Dinding Kanan
    local rightWall = makeCagePart(
        CFrame.new(centerPosition) * CFrame.new(cageSize/2 - wallThickness/2, 0, 0), 
        Vector3.new(wallThickness, wallHeight, cageSize), 
        0.5
    )
    table.insert(currentCageParts, rightWall)

    -- 4. Dinding Kiri
    local leftWall = makeCagePart(
        CFrame.new(centerPosition) * CFrame.new(-cageSize/2 + wallThickness/2, 0, 0), 
        Vector3.new(wallThickness, wallHeight, cageSize), 
        0.5
    )
    table.insert(currentCageParts, leftWall)

    -- 5. Atap (opsional, tapi bagus untuk mencegah keluar lewat atas)
    local roof = makeCagePart(
        CFrame.new(centerPosition) * CFrame.new(0, wallHeight/2 - wallThickness/2, 0), 
        Vector3.new(cageSize, wallThickness, cageSize), 
        0.7
    )
    table.insert(currentCageParts, roof)
    
    -- 6. Lantai (opsional, agar tidak ada yang bisa "clip" ke bawah tanah)
    local floor = makeCagePart(
        CFrame.new(centerPosition) * CFrame.new(0, -wallHeight/2 + wallThickness/2, 0), 
        Vector3.new(cageSize, wallThickness, cageSize), 
        0.7
    )
    table.insert(currentCageParts, floor)

    -- Tambahkan Loop untuk menjaga agar sangkar tetap di posisi target
    local loopConnection = RunService.Heartbeat:Connect(function()
        if selectedTarget and selectedTarget.Character and selectedTarget.Character:FindFirstChild("HumanoidRootPart") then
            local newCenter = selectedTarget.Character.HumanoidRootPart.CFrame.p + Vector3.new(0, wallHeight/2 - selectedTarget.Character.HumanoidRootPart.Size.Y/2, 0)
            -- Kita tidak perlu mengatur setiap bagian, cukup pindahkan target ke tengah, tapi ini berbahaya.
            -- Lebih aman untuk mengunci sangkar pada posisi target setiap frame.
            
            -- Pindahkan sangkar agar target selalu di tengah (posisi target tidak berubah)
            local targetPos = selectedTarget.Character.HumanoidRootPart.Position
            
            frontWall.CFrame = CFrame.new(targetPos + Vector3.new(0, wallHeight/2, -cageSize/2 + wallThickness/2))
            backWall.CFrame = CFrame.new(targetPos + Vector3.new(0, wallHeight/2, cageSize/2 - wallThickness/2))
            rightWall.CFrame = CFrame.new(targetPos + Vector3.new(cageSize/2 - wallThickness/2, wallHeight/2, 0)) * CFrame.Angles(0, math.rad(90), 0) -- Rotasi untuk dinding samping
            leftWall.CFrame = CFrame.new(targetPos + Vector3.new(-cageSize/2 + wallThickness/2, wallHeight/2, 0)) * CFrame.Angles(0, math.rad(90), 0) -- Rotasi untuk dinding samping
            roof.CFrame = CFrame.new(targetPos + Vector3.new(0, wallHeight, 0)) -- Atap
            floor.CFrame = CFrame.new(targetPos) -- Lantai di level kaki

        else
            -- Jika target hilang/mati, hentikan loop dan hancurkan sangkar
            loopConnection:Disconnect()
            if isCagingActive then
                 -- Ini akan mencegah error jika toggleCagePlayer dipanggil saat loop masih berjalan
                 isCagingActive = false 
                 destroyCage() 
            end
        end
    end)
    
    table.insert(currentCageParts, loopConnection) -- Simpan koneksi loop untuk dihancurkan nanti
    
    return true
end

local function destroyCage()
    -- Hancurkan semua bagian sangkar dan putuskan koneksi loop
    for _, item in ipairs(currentCageParts) do
        if item:IsA("Connection") then
            item:Disconnect()
        elseif item:IsA("Part") then
            -- Gunakan Debris untuk memastikan penghapusan yang bersih
            Debris:AddItem(item, 0.1) 
        end
    end
    currentCageParts = {}
    print("Sangkar Dihancurkan.")
end

local function toggleCagePlayer(button)
    if not selectedTarget then
        warn("Pilih target terlebih dahulu!")
        return
    end

    isCagingActive = not isCagingActive
    
    if isCagingActive then
        local success = createCageForTarget()
        if success then
            updateButtonStatus(button, true, "CAGE PLAYER")
            print("Cage Player AKTIF pada: " .. selectedTarget.Name)
        else
            isCagingActive = false -- Reset status jika gagal
            updateButtonStatus(button, false, "CAGE PLAYER")
        end
    else
        destroyCage()
        updateButtonStatus(button, false, "CAGE PLAYER")
        print("Cage Player NONAKTIF.")
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

-- 🔽 FUNGSI PEMBUAT TOMBOL PEMAIN 🔽
-- ... (Fungsi createPlayerButton dan refreshPlayerList tidak diubah dari kode Anda)
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
        
        -- Matikan sangkar jika target berubah (PENTING!)
        if isCagingActive then
            local cageBtn = featureScrollFrame:FindFirstChild("CagePlayerButton")
            if cageBtn then toggleCagePlayer(cageBtn) end
        end
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
        
        -- Matikan sangkar jika target keluar
        if isCagingActive then
            local cageBtn = featureScrollFrame:FindFirstChild("CagePlayerButton")
            if cageBtn then toggleCagePlayer(cageBtn) end
        end
    end
    refreshPlayerList()
end)

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

-- 3. Tombol CAGE PLAYER BARU
local cagePlayerButton = makeFeatureButton("CAGE PLAYER: OFF", Color3.fromRGB(150, 0, 0), toggleCagePlayer)

-- 4. Tombol Reset Target
local resetButton = makeFeatureButton("RESET TARGET", Color3.fromRGB(200, 200, 0), function(button)
    selectedTarget = nil
    updateTargetTitle()
    refreshPlayerList()
    
    -- Pastikan sangkar hilang saat reset target
    if isCagingActive then
        local cageBtn = featureScrollFrame:FindFirstChild("CagePlayerButton")
        if cageBtn then toggleCagePlayer(cageBtn) end
    end
    
    print("Target Direset.")
end)


-- 🔽 LOGIKA CHARACTER ADDED (PENTING UNTUK MEMPERTAHANKAN STATUS) 🔽
player.CharacterAdded:Connect(function(char)
    local repulseBtn = featureScrollFrame:FindFirstChild("RepulseTouchButton")
    local titleBtn = featureScrollFrame:FindFirstChild("OwnerTitleButton")
    local cageBtn = featureScrollFrame:FindFirstChild("CagePlayerButton")
    
    if isRepulseActive and repulseBtn then
        enableRepulseTouch(repulseBtn) 
    end
    
    if isOwnerTitleActive and titleBtn then
        createOwnerTitle()
        updateButtonStatus(titleBtn, true, "OWNER TITLE")
    end
    
    -- Sangkar tidak perlu diaktifkan kembali saat karakter pemain lokal respawn, 
    -- karena sangkar diposisikan relatif terhadap target. Target akan tetap terkurung.
    
    -- Namun, jika target respawn, sangkar harus dibuat ulang.
    if selectedTarget and isCagingActive and cageBtn then
        selectedTarget.CharacterAdded:Wait() -- Tunggu sampai karakter target muncul
        -- Hancurkan sangkar lama dan buat yang baru di posisi baru
        destroyCage()
        createCageForTarget()
        updateButtonStatus(cageBtn, true, "CAGE PLAYER")
    end
end)


-- Atur status awal dan daftar pemain
updateButtonStatus(repulseButton, isRepulseActive, "REPULSE TOUCH")
updateButtonStatus(ownerTitleButton, isOwnerTitleActive, "OWNER TITLE")
updateButtonStatus(cagePlayerButton, isCagingActive, "CAGE PLAYER")
updateTargetTitle()
refreshPlayerList()

