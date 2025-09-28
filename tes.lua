local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage") -- Ditambahkan

-- ASUMSI: RemoteEvent ini ada di ReplicatedStorage untuk fitur yang memerlukan sinkronisasi Server.
local PromptDestroyerRemote = ReplicatedStorage:FindFirstChild("PromptDestroyerRemote") 

local player = Players.LocalPlayer

-- ** ⬇️ STATUS FITUR CORE ⬇️ **
local isDestroyerActive = false 
local destroyerTouchConnection = nil
local currentSpeed = 16 -- Kecepatan default
local isPartChangerActive = false -- Status baru untuk Part Changer
local partChangerTouchConnection = nil -- Koneksi baru

-- [ANIMASI "BY : Xraxor" dan GUI UTAMA TIDAK DIUBAH]
-- ... (Biarkan kode animasi dan GUI Anda di sini) ...
-- ... (Hingga sebelum FUNGSI UTILITY GLOBAL) ...


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


-- 🔽 FUNGSI PART PROMPT DESTROYER (DIPERBAHARUI LOGIKA SENTUH) 🔽

local function onPartDestroyerTouch(otherPart)
    if not isDestroyerActive or not otherPart or not otherPart.Parent then return end

    local char = player.Character
    local targetModel = otherPart.Parent
    
    -- Cek jika bagian yang disentuh adalah bagian dari karakter pemain (Anda atau pemain lain)
    local isTouchingMyCharacter = char and (targetModel == char or targetModel.Parent == char)
    local isTouchingOtherPlayer = Players:GetPlayerFromCharacter(targetModel) or 
                                  (targetModel.Parent and Players:GetPlayerFromCharacter(targetModel.Parent))

    -- Jika menyentuh karakter, ABAIKAN (Logika sentuh yang benar)
    if isTouchingMyCharacter or isTouchingOtherPlayer then
        return 
    end

    local targetPart = otherPart
    
    -- Cek Part Promt
    local hasPrompt = targetPart:FindFirstChildOfClass("ProximityPrompt")
    if not hasPrompt then
        if targetPart.Parent and targetPart.Parent:FindFirstChildOfClass("ProximityPrompt") then
             hasPrompt = targetPart.Parent:FindFirstChildOfClass("ProximityPrompt")
        end
    end

    if hasPrompt and targetPart:IsA("BasePart") then
        if PromptDestroyerRemote then
            -- Permintaan dikirim ke Server (untuk sinkronisasi global)
            PromptDestroyerRemote:FireServer(targetPart)
        end
        
        -- Hapus lokal (terlihat instan di layar Anda)
        targetPart:Destroy()
        print("Prompt Destroyer Aktif: Menghilangkan part bernama " .. targetPart.Name)
    end
end

local function activateDestroyer(button)
    if isDestroyerActive then return end
    isDestroyerActive = true
    
    local character = player.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    
    if not rootPart then 
        warn("HumanoidRootPart tidak ditemukan.")
        isDestroyerActive = false
        updateButtonStatus(button, false, "PROMPT DESTROYER")
        return 
    end

    updateButtonStatus(button, true, "PROMPT DESTROYER")
    
    if destroyerTouchConnection then destroyerTouchConnection:Disconnect() end
    destroyerTouchConnection = rootPart.Touched:Connect(onPartDestroyerTouch)
    
    print("Prompt Destroyer AKTIF.")
end

local function deactivateDestroyer(button)
    if not isDestroyerActive then return end
    isDestroyerActive = false
    
    if destroyerTouchConnection then
        destroyerTouchConnection:Disconnect()
        destroyerTouchConnection = nil
    end
    
    updateButtonStatus(button, false, "PROMPT DESTROYER")
    print("Prompt Destroyer NONAKTIF.")
end


-- 🔽 FUNGSI SPEED HACK BARU 🔽

local function toggleSpeedHack(button)
    local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    if currentSpeed == 16 then -- Jika default (mati), aktifkan ke 50
        currentSpeed = 50 
        humanoid.WalkSpeed = currentSpeed
        button.Text = "SPEED HACK: ON (x" .. math.floor(currentSpeed/16) .. ")"
        button.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
    else -- Jika aktif, kembalikan ke default (16)
        currentSpeed = 16 
        humanoid.WalkSpeed = currentSpeed
        button.Text = "SPEED HACK: OFF"
        button.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    end
end

-- 🔽 FUNGSI PART CHANGER BARU 🔽

local function onPartChangerTouch(otherPart)
    if not isPartChangerActive or not otherPart or not otherPart.Parent then return end

    local char = player.Character
    local targetModel = otherPart.Parent
    
    -- Abaikan jika menyentuh karakter pemain (Anda atau pemain lain)
    local isTouchingPlayer = Players:GetPlayerFromCharacter(targetModel) or 
                             (targetModel.Parent and Players:GetPlayerFromCharacter(targetModel.Parent))
    if isTouchingPlayer or (char and targetModel == char) then return end

    local targetPart = otherPart
    
    if targetPart:IsA("BasePart") and targetPart.Anchored == false then
        -- ** Aksi Sisi Klien Saja (Local-only) **
        targetPart.Color = Color3.fromHSV(math.random(), 1, 1) -- Ubah ke warna acak
        targetPart.Material = Enum.Material.Neon -- Ubah material
        targetPart.Transparency = 0.5 -- Buat transparan
        
        print("Part Changer Aktif: Mengubah part bernama " .. targetPart.Name)
    end
end

local function togglePartChanger(button)
    isPartChangerActive = not isPartChangerActive
    local character = player.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")

    if not rootPart then 
        warn("HumanoidRootPart tidak ditemukan.")
        isPartChangerActive = false
    end

    updateButtonStatus(button, isPartChangerActive, "PART CHANGER")
    
    if isPartChangerActive then
        if partChangerTouchConnection then partChangerTouchConnection:Disconnect() end
        partChangerTouchConnection = rootPart.Touched:Connect(onPartChangerTouch)
        print("Part Changer AKTIF.")
    else
        if partChangerTouchConnection then
            partChangerTouchConnection:Disconnect()
            partChangerTouchConnection = nil
        end
        print("Part Changer NONAKTIF.")
    end
end


-- 🔽 FUNGSI PEMBUAT TOMBOL FITUR (TIDAK DIUBAH) 🔽

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

-- 🔽 PENAMBAHAN TOMBOL KE FEATURE LIST BARU 🔽

-- 1. Tombol PROMPT DESTROYER (DIREVISI)
local destroyerButton = makeFeatureButton("PROMPT DESTROYER: OFF", Color3.fromRGB(150, 0, 0), function(button)
    if isDestroyerActive then
        deactivateDestroyer(button)
    else
        activateDestroyer(button)
    end
end)

-- 2. Tombol SPEED HACK (BARU)
local speedButton = makeFeatureButton("SPEED HACK: OFF", Color3.fromRGB(150, 0, 0), toggleSpeedHack)

-- 3. Tombol PART CHANGER (BARU)
local changerButton = makeFeatureButton("PART CHANGER: OFF", Color3.fromRGB(150, 0, 0), togglePartChanger)


-- 🔽 LOGIKA CHARACTER ADDED (DIPERBAHARUI UNTUK MEMPERTAHANKAN STATUS) 🔽
player.CharacterAdded:Connect(function(char)
    -- Lakukan deactivate untuk membersihkan koneksi lama (jika ada)
    deactivateDestroyer(destroyerButton)
    if partChangerTouchConnection then deactivateDestroyer(changerButton) end
    
    -- Pertahankan status Destroyer
    if isDestroyerActive then
        char:WaitForChild("HumanoidRootPart", 5)
        local button = featureScrollFrame:FindFirstChild("PromptDestroyerButton")
        if button then activateDestroyer(button) end
    end
    
    -- Pertahankan status Speed
    local humanoid = char:WaitForChild("Humanoid", 5)
    if humanoid then
        humanoid.WalkSpeed = currentSpeed
        if currentSpeed ~= 16 then
             local button = featureScrollFrame:FindFirstChild("SpeedHackButton")
             if button then 
                 button.Text = "SPEED HACK: ON (x" .. math.floor(currentSpeed/16) .. ")"
                 button.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
             end
        end
    end
    
    -- Pertahankan status Part Changer
    if isPartChangerActive then
        char:WaitForChild("HumanoidRootPart", 5)
        local button = featureScrollFrame:FindFirstChild("PartChangerButton")
        if button then togglePartChanger(button) end -- Panggil toggle untuk mengaktifkan koneksi sentuh
    end
end)


-- Atur status awal tombol
updateButtonStatus(destroyerButton, isDestroyerActive, "PROMPT DESTROYER")
-- Speed hack akan diatur oleh fungsinya sendiri (currentSpeed=16 secara default)
updateButtonStatus(changerButton, isPartChangerActive, "PART CHANGER")
