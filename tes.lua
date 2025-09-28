local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local PromptService = game:GetService("PromptService") -- Tambahkan layanan PromptService

local player = Players.LocalPlayer

-- ** ⬇️ STATUS FITUR CORE ⬇️ **
local isTetherActive = false 
local isPromptDestroyerActive = false -- Status baru untuk Prompt Destroyer
local tetherTouchConnection = nil
local promptDestroyerConnection = nil -- Koneksi untuk Prompt Destroyer
local activeTethers = {} -- Menyimpan weld untuk pemain yang sedang diikat


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

-- Frame utama (Disesuaikan untuk 2 tombol)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 150) -- Ditingkatkan ukurannya
frame.Position = UDim2.new(0.4, -110, 0.5, -75) -- Disesuaikan agar tetap di tengah
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

---
---
-- 🔽 FUNGSI PROMPT DESTROYER 🔽
-- Fungsi yang dijalankan setiap frame untuk menampilkan dialog "PromptService"
local function promptDestroyerLoop(deltaTime)
    -- Pastikan fitur aktif
    if not isPromptDestroyerActive then return end
    
    -- Gunakan dialog yang cepat muncul dan mengganggu
    -- Menggunakan `PromptService:PromptDialog(Title, Message, Button1, Button2)`
    -- Catatan: Fungsi ini mungkin memiliki batasan frekuensi/cooldown dari Roblox.
    local success, result = pcall(function()
        PromptService:PromptDialog("WARNING", "LAG", "OK", "CANCEL") 
        -- Prompter yang sangat cepat dapat mengganggu sesi pemain
    end)
    
    if not success then
        warn("PromptService call failed (cooldown?): " .. tostring(result))
    end
end

local function activatePromptDestroyer(button)
    if isPromptDestroyerActive then return end
    isPromptDestroyerActive = true
    
    updateButtonStatus(button, true, "PROMPT DESTROYER")
    
    -- Hubungkan fungsi loop ke RunService.RenderStepped atau Heartbeat
    if promptDestroyerConnection then promptDestroyerConnection:Disconnect() end
    -- Gunakan RenderStepped agar lebih cepat
    promptDestroyerConnection = RunService.RenderStepped:Connect(promptDestroyerLoop)
    
    print("Prompt Destroyer AKTIF.")
end

local function deactivatePromptDestroyer(button)
    if not isPromptDestroyerActive then return end
    isPromptDestroyerActive = false
    
    if promptDestroyerConnection then
        promptDestroyerConnection:Disconnect()
        promptDestroyerConnection = nil
    end
    
    updateButtonStatus(button, false, "PROMPT DESTROYER")
    print("Prompt Destroyer NONAKTIF.")
end

---
---

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

-- Tombol PLAYER TETHER
local tetherButton = makeFeatureButton("PLAYER TETHER: OFF", Color3.fromRGB(150, 0, 0), function(button)
    if isTetherActive then
        deactivateTether(button)
    else
        activateTether(button)
    end
end)

-- Tombol PROMPT DESTROYER (BARU)
local promptDestroyerButton = makeFeatureButton("PROMPT DESTROYER: OFF", Color3.fromRGB(150, 0, 0), function(button)
    if isPromptDestroyerActive then
        deactivatePromptDestroyer(button)
    else
        activatePromptDestroyer(button)
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
    
    -- Tidak perlu mempertahankan status Prompt Destroyer saat respawn,
    -- karena tidak bergantung pada Character.
end)


-- Atur status awal tombol
updateButtonStatus(tetherButton, isTetherActive, "PLAYER TETHER")
updateButtonStatus(promptDestroyerButton, isPromptDestroyerActive, "PROMPT DESTROYER")
