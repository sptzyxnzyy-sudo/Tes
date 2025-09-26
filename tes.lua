-- credit: Xraxor1 (Original GUI/Intro structure)
-- Modification for Dual-Tab GUI, Impersonate Player & Core Features: [AI Assistant]

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
local isSuperJumpActive = false
local isNoclipActive = false
-- Nilai awal akan diambil dari karakter saat pertama kali dimuat
local originalJumpPower = 50 
local originalCanCollide = true

-- 🔽 INISIALISASI AWAL KARAKTER DAN NILAI DEFAULT 🔽
local function initializeCharacterProperties(char)
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local rootPart = char:FindFirstChild("HumanoidRootPart")

    if humanoid and originalJumpPower == 50 then
         originalJumpPower = humanoid.JumpPower -- Ambil nilai jump default game
    end
    if rootPart and originalCanCollide == true then
         originalCanCollide = rootPart.CanCollide -- Ambil nilai CanCollide default
    end
    
    -- Terapkan kembali status fitur saat karakter baru muncul
    if isDestroyerActive then
        activatePartDestroyer(featureScrollFrame:FindFirstChild("DestroyerButton"))
    end
    
    if isPhantomTouchActive then
        enablePhantomTouch(featureScrollFrame:FindFirstChild("PhantomTouchButton"))
    end
    
    if isSuperJumpActive and humanoid then
        humanoid.JumpPower = 150
    elseif humanoid then
        humanoid.JumpPower = originalJumpPower
    end

    if isNoclipActive and rootPart then
        rootPart.CanCollide = false
    elseif rootPart then
        rootPart.CanCollide = originalCanCollide
    end

    -- Pastikan status tombol GUI ter-update
    local destroyerButton = featureScrollFrame:FindFirstChild("DestroyerButton")
    if destroyerButton then updateButtonStatus(destroyerButton, isDestroyerActive) end
    local noclipButton = featureScrollFrame:FindFirstChild("NoclipButton")
    if noclipButton then updateButtonStatus(noclipButton, isNoclipActive) end
    local jumpButton = featureScrollFrame:FindFirstChild("SuperJumpButton")
    if jumpButton then updateButtonStatus(jumpButton, isSuperJumpActive) end
    local phantomButton = featureScrollFrame:FindFirstChild("PhantomTouchButton")
    if phantomButton then updateButtonStatus(phantomButton, isPhantomTouchActive) end
end

-- Listener Karakter: PENTING untuk me-restart koneksi fitur
player.CharacterAdded:Connect(initializeCharacterProperties)
-- Panggil juga saat pertama kali, jika karakter sudah ada sebelum script berjalan
if player.Character then
    initializeCharacterProperties(player.Character)
end


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

-- 🔽 GUI Utama (Dual-Tab Structure) 🔽
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ImpersonateGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 260) 
frame.Position = UDim2.new(0.4, -110, 0.5, -130)
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
title.Text = "IMPERSONATE MENU"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = frame

-- Header Tab
local tabHeader = Instance.new("Frame")
tabHeader.Size = UDim2.new(1, 0, 0, 30)
tabHeader.Position = UDim2.new(0, 0, 0, 30)
tabHeader.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
tabHeader.BorderSizePixel = 0
tabHeader.Parent = frame

-- Container untuk konten tab
local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, -20, 1, -70) 
tabContainer.Position = UDim2.new(0.5, -100, 0, 65)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = frame

-- Membuat Tab Content (Main Features)
local featureScrollFrame = Instance.new("ScrollingFrame")
featureScrollFrame.Name = "MainFeatures"
featureScrollFrame.Size = UDim2.new(1, 0, 1, 0)
featureScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
featureScrollFrame.ScrollBarThickness = 6
featureScrollFrame.BackgroundTransparency = 1
featureScrollFrame.Parent = tabContainer

local featureListLayout = Instance.new("UIListLayout")
featureListLayout.Padding = UDim.new(0, 5)
featureListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
featureListLayout.SortOrder = Enum.SortOrder.LayoutOrder
featureListLayout.Parent = featureScrollFrame

featureListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    featureScrollFrame.CanvasSize = UDim2.new(0, 0, 0, featureListLayout.AbsoluteContentSize.Y + 10)
end)

-- Membuat Tab Content (Player List)
local playerScrollFrame = Instance.new("ScrollingFrame")
playerScrollFrame.Name = "PlayerList"
playerScrollFrame.Size = UDim2.new(1, 0, 1, 0)
playerScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
playerScrollFrame.ScrollBarThickness = 6
playerScrollFrame.BackgroundTransparency = 1
playerScrollFrame.Visible = false 
playerScrollFrame.Parent = tabContainer

local playerListLayout = Instance.new("UIListLayout")
playerListLayout.Padding = UDim.new(0, 5)
playerListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
playerListLayout.SortOrder = Enum.SortOrder.LayoutOrder
playerListLayout.Parent = playerScrollFrame

playerListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    playerScrollFrame.CanvasSize = UDim2.new(0, 0, 0, playerListLayout.AbsoluteContentSize.Y + 10)
end)


-- FUNGSI TAB SWITCHING
local tabs = {
    ["Main"] = featureScrollFrame,
    ["Players"] = playerScrollFrame
}
local tabButtons = {}

local function populatePlayerList()
    -- Hapus tombol lama
    for _, child in ipairs(playerScrollFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    local playerList = Players:GetPlayers()
    table.sort(playerList, function(a, b) return a.Name < b.Name end)

    -- Tambahkan tombol baru
    for _, target in ipairs(playerList) do
        if target.Character then -- Pastikan pemain memiliki karakter
            makePlayerButton(target)
        end
    end
end

local function switchTab(tabName)
    for name, content in pairs(tabs) do
        content.Visible = (name == tabName)
        tabButtons[name].BackgroundColor3 = (name == tabName) and Color3.fromRGB(40, 40, 40) or Color3.fromRGB(30, 30, 30)
    end
    if tabName == "Players" then
        populatePlayerList()
    end
end

local function createTabButton(name, positionX)
    local button = Instance.new("TextButton")
    button.Name = name .. "TabButton"
    button.Size = UDim2.new(0.5, 0, 1, 0)
    button.Position = UDim2.new(positionX, 0, 0, 0)
    button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    button.Text = name
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 12
    button.Parent = tabHeader

    button.MouseButton1Click:Connect(function()
        switchTab(name)
    end)
    return button
end

tabButtons["Main"] = createTabButton("Main", 0)
tabButtons["Players"] = createTabButton("Players", 0.5)

-- Set default tab
switchTab("Main")


-- 🔽 FUNGSI FITUR UTAMA 🔽

local function updateButtonStatus(button, isActive)
    -- Cek jika tombol sudah di-destroy karena reload karakter
    if not button or not button.Parent then return end 

    local featureName = button.Name:gsub("Button", ""):gsub("_", " "):upper()
    if isActive then
        button.Text = featureName .. ": ON"
        button.BackgroundColor3 = Color3.fromRGB(0, 180, 0) -- Hijau
    else
        button.Text = featureName .. ": OFF"
        button.BackgroundColor3 = Color3.fromRGB(150, 0, 0) -- Merah
    end
end

-- ** 1. AGGRESSIVE LOCAL DESTROYER **
local function destroyerTouch(otherPart)
    if not isDestroyerActive or not otherPart or not otherPart.Parent then return end
    
    local parentModel = otherPart.Parent
    local hitHumanoid = parentModel:FindFirstChildOfClass("Humanoid")
    
    -- Hindari menghancurkan/membunuh diri sendiri atau part karakter sendiri
    if parentModel == player.Character then return end
    
    if otherPart:IsA("BasePart") or otherPart:IsA("MeshPart") or otherPart:IsA("UnionOperation") then
        
        if hitHumanoid and parentModel:FindFirstChild("HumanoidRootPart") then
            hitHumanoid.Health = 0 -- Pembunuhan LOKAL
        end
        
        -- Tambahkan pcall untuk menghindari crash jika part sudah di-destroy oleh script lain
        pcall(function() otherPart:Destroy() end)
    end
end

local function activatePartDestroyer(button)
    if isDestroyerActive then return end
    
    local character = player.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    
    if not rootPart then 
        warn("HumanoidRootPart tidak ditemukan, tunggu karakter dimuat.")
        -- Jangan set isDestroyerActive = true di sini karena akan diaktifkan ulang di CharacterAdded
        updateButtonStatus(button, false)
        return 
    end

    isDestroyerActive = true
    updateButtonStatus(button, true)
    
    -- Pastikan koneksi lama terputus sebelum membuat koneksi baru
    if destroyerTouchConnection then destroyerTouchConnection:Disconnect() end
    destroyerTouchConnection = rootPart.Touched:Connect(destroyerTouch)
    
    print("Aggressive Local Destroyer AKTIF.")
end

local function deactivatePartDestroyer(button)
    if not isDestroyerActive then return end
    isDestroyerActive = false
    updateButtonStatus(button, false)
    
    if destroyerTouchConnection then
        destroyerTouchConnection:Disconnect()
        destroyerTouchConnection = nil
    end
    print("Aggressive Local Destroyer NONAKTIF.")
end


-- 2. Super Jump
local function toggleSuperJump(button)
    local char = player.Character or player.CharacterAdded:Wait()
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    isSuperJumpActive = not isSuperJumpActive

    if isSuperJumpActive then
        humanoid.JumpPower = 150 
    else
        -- Pastikan menggunakan nilai original yang benar
        humanoid.JumpPower = originalJumpPower 
    end
    updateButtonStatus(button, isSuperJumpActive)
end

-- 3. Noclip
local function toggleNoclip(button)
    local char = player.Character or player.CharacterAdded:Wait()
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    isNoclipActive = not isNoclipActive

    if isNoclipActive then
        rootPart.CanCollide = false
    else
        -- Pastikan menggunakan nilai original yang benar
        rootPart.CanCollide = originalCanCollide
    end
    updateButtonStatus(button, isNoclipActive)
end

-- 4. Phantom Touch
local function onPartTouched(otherPart)
    if not isPhantomTouchActive or not otherPart or not otherPart:IsA("BasePart") then return end
    if otherPart:IsDescendantOf(player.Character) or otherPart.Parent:IsA("Accessory") or partsTouched[otherPart] then return end

    otherPart.Transparency = 1
    otherPart.CanCollide = false
    
    partsTouched[otherPart] = true
    print("Phantom Touched: " .. otherPart.Name .. " menghilang.")
end

local function enablePhantomTouch(button)
    isPhantomTouchActive = true
    updateButtonStatus(button, true)
    
    local char = player.Character or player.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    
    if touchConnection then touchConnection:Disconnect() end
    touchConnection = root.Touched:Connect(onPartTouched)
    print("Phantom Touch Dinyalakan.")
end -- DIBENARKAN: Hapus kurung kurawal '}' yang tidak perlu

local function disablePhantomTouch(button)
    isPhantomTouchActive = false
    updateButtonStatus(button, false)
    
    if touchConnection then
        touchConnection:Disconnect()
        touchConnection = nil
    end
    
    -- Kembalikan transparansi dan CanCollide part yang telah disentuh (secara lokal)
    for part, _ in pairs(partsTouched) do
        if part and part.Parent then 
             part.Transparency = 0 
             part.CanCollide = true
        end
    end
    partsTouched = {}
    print("Phantom Touch Dimatikan.")
end

-- 🔽 FUNGSI PEMBUAT TOMBOL FITUR 🔽

local function makeFeatureButton(container, name, color, callback)
    local featButton = Instance.new("TextButton")
    featButton.Name = name:gsub(" ", ""):gsub(":", "") .. "Button" 
    featButton.Size = UDim2.new(0, 180, 0, 40)
    featButton.BackgroundColor3 = color
    featButton.Text = name
    featButton.TextColor3 = Color3.new(1, 1, 1)
    featButton.Font = Enum.Font.GothamBold
    featButton.TextSize = 12
    featButton.Parent = container

    local featCorner = Instance.new("UICorner")
    featCorner.CornerRadius = UDim.new(0, 10)
    featCorner.Parent = featButton

    featButton.MouseButton1Click:Connect(function()
        callback(featButton)
    end)
    return featButton
end

-- 🔽 PENAMBAHAN TOMBOL KE MAIN FEATURES (Tab 1) 🔽

-- 1. Tombol DESTROYER 
local destroyerButton = makeFeatureButton(featureScrollFrame, "DESTROYER: OFF", Color3.fromRGB(150, 0, 0), function(button)
    if isDestroyerActive then
        deactivatePartDestroyer(button)
    else
        activatePartDestroyer(button)
    end
end)


-- 2. Tombol Noclip
local noclipButton = makeFeatureButton(featureScrollFrame, "NOCLIP: OFF", Color3.fromRGB(150, 0, 0), toggleNoclip)

-- 3. Tombol Super Jump
local jumpButton = makeFeatureButton(featureScrollFrame, "SUPER JUMP: OFF", Color3.fromRGB(150, 0, 0), toggleSuperJump)

-- 4. Tombol PHANTOM TOUCH
local phantomButton = makeFeatureButton(featureScrollFrame, "PHANTOM TOUCH: OFF", Color3.fromRGB(150, 0, 0), function(button)
    if isPhantomTouchActive then
        disablePhantomTouch(button)
    else
        enablePhantomTouch(button)
    end
end)

-- 5. Tombol RESET
makeFeatureButton(featureScrollFrame, "RESET AVATAR", Color3.fromRGB(150, 0, 0), function()
    player:LoadCharacter()
end)


-- 🔽 Logika Impersonate Player (Tab 2) 🔽

local function makePlayerButton(targetPlayer)
    local tpButton = Instance.new("TextButton")
    tpButton.Size = UDim2.new(0, 180, 0, 35)
    tpButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    tpButton.Text = targetPlayer.Name .. (targetPlayer == player and " (You)" or "")
    tpButton.TextColor3 = Color3.new(1, 1, 1)
    tpButton.Font = Enum.Font.SourceSansBold
    tpButton.TextSize = 14
    tpButton.Parent = playerScrollFrame

    local tpCorner = Instance.new("UICorner")
    tpCorner.CornerRadius = UDim.new(0, 8)
    tpCorner.Parent = tpButton

    tpButton.MouseButton1Click:Connect(function()
        local char = player.Character
        local targetChar = targetPlayer.Character

        if not char or not targetChar then warn("Karakter tidak ditemukan!") return end
        local playerHumanoid = char:FindFirstChildOfClass("Humanoid")
        local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")
        if not playerHumanoid or not targetHumanoid then warn("Humanoid tidak ditemukan!") return end

        -- CLONING KOSTUM/AKSESORIS
        -- Gunakan :ClearAllChildren() pada aksesoris lama jika ada, atau pastikan destroy bekerja
        for _, obj in ipairs(char:GetChildren()) do
            if obj:IsA("Accessory") or obj:IsA("Shirt") or obj:IsA("Pants") then 
                pcall(function() obj:Destroy() end)
            end
        end
        
        -- Kloning aksesoris baru
        for _, obj in ipairs(targetChar:GetChildren()) do
            if obj:IsA("Accessory") or obj:IsA("Shirt") or obj:IsA("Pants") then
                local clone = obj:Clone()
                clone.Parent = char
            end
        end

        -- STATS DAN LOKASI
        local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
        local playerRoot = char:FindFirstChild("HumanoidRootPart")
        
        -- Sesuaikan stat sesuai target, tetapi hormati status fitur ON/OFF
        playerHumanoid.WalkSpeed = targetHumanoid.WalkSpeed 
        if not isSuperJumpActive then
             playerHumanoid.JumpPower = targetHumanoid.JumpPower
        end
        
        if targetRoot and playerRoot then
            -- Gunakan SetPrimaryPartCFrame atau CFrame langsung
            playerRoot.CFrame = targetRoot.CFrame 
        end
        print("Meniru properti dari: " .. targetPlayer.Name)
    end)
end
