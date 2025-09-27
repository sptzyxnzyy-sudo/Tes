local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer

-- ** ⬇️ STATUS FITUR CORE ⬇️ **
local isRepulseActive = false 
local repulseTouchConnection = nil 
local lastRepulse = 0
local KNOCKBACK_POWER = 10000 
local DEBOUNCE_TIME = 0 

local isOwnerTitleActive = false 

local selectedTarget = nil 
local isCagingActive = false 
local currentCageParts = {} 
local cageUpdateConnection = nil 

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
frame.Size = UDim2.new(0, 220, 0, 410) 
frame.Position = UDim2.new(0.4, -110, 0.5, -205) 
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
featureScrollFrame.Size = UDim2.new(1, -20, 0, 190) 
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
targetTitle.Position = UDim2.new(0, 0, 0, 230) 
targetTitle.BackgroundTransparency = 1
targetTitle.Text = "TARGET: NONE" 
targetTitle.TextColor3 = Color3.fromRGB(255, 255, 0)
targetTitle.Font = Enum.Font.GothamBold
targetTitle.TextSize = 14
targetTitle.Parent = frame

local playerScrollFrame = Instance.new("ScrollingFrame")
playerScrollFrame.Name = "PlayerList"
playerScrollFrame.Size = UDim2.new(1, -20, 0, 150)
playerScrollFrame.Position = UDim2.new(0.5, -100, 0, 260) 
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

-- 🔽 FUNGSI REPULSE TOUCH (KNOCKBACK) 🔽

local function repulseTouch(otherPart)
    if not isRepulseActive or (tick() - lastRepulse < DEBOUNCE_TIME) then return end
    
    local otherCharacter = otherPart.Parent:FindFirstAncestorOfClass("Model")
    if not otherCharacter then return end
    
    local otherPlayer = Players:GetPlayerFromCharacter(otherCharacter)
    
    if otherPlayer == player then return end
    
    local isTarget = (selectedTarget and otherPlayer == selectedTarget)
    
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
end

local function enableRepulseTouch(button)
    if isRepulseActive then return end
    isRepulseActive = true
    
    local character = player.Character or player.CharacterAdded:Wait()
    local rootPart = character:WaitForChild("HumanoidRootPart")
    
    updateButtonStatus(button, true, "REPULSE TOUCH")
    
    if repulseTouchConnection then repulseTouchConnection:Disconnect() end
    repulseTouchConnection = rootPart.Touched:Connect(repulseTouch)
end

local function disableRepulseTouch(button)
    if not isRepulseActive then return end
    isRepulseActive = false
    updateButtonStatus(button, false, "REPULSE TOUCH")
    
    if repulseTouchConnection then
        repulseTouchConnection:Disconnect()
        repulseTouchConnection = nil
    end
end

-- 🔽 FUNGSI OWNER TITLE 🔽

local function createOwnerTitle()
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
        if player.Character then
            createOwnerTitle()
        end
    else
        destroyOwnerTitle()
    end
end


-- 🔽 FUNGSI CAGE PLAYER 🔽

local function makeCagePart(cframe, size, transparency, color, name)
    local part = Instance.new("Part")
    part.CFrame = cframe
    part.Size = size
    part.Transparency = transparency
    part.Color = color or Color3.fromRGB(0, 150, 255)
    part.Material = Enum.Material.ForceField
    part.Anchored = true
    part.CanCollide = true
    part.Name = name or "CageWall"
    part.Parent = workspace.TemporaryCages or Instance.new("Folder", workspace)
    part.Parent.Name = "TemporaryCages"
    return part
end

local function destroyCage()
    if cageUpdateConnection then
        cageUpdateConnection:Disconnect()
        cageUpdateConnection = nil
    end
    
    for _, part in ipairs(currentCageParts) do
        if part:IsA("Part") then
            Debris:AddItem(part, 0.1) 
        end
    end
    currentCageParts = {}
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
    
    destroyCage() -- Hancurkan sangkar lama

    local cageSize = 8 
    local wallThickness = 0.5
    local wallHeight = 10 
    
    local partsData = {
        {name = "Front", size = Vector3.new(cageSize, wallHeight, wallThickness), offset = Vector3.new(0, 0, -cageSize/2 + wallThickness/2)},
        {name = "Back", size = Vector3.new(cageSize, wallHeight, wallThickness), offset = Vector3.new(0, 0, cageSize/2 - wallThickness/2)},
        {name = "Right", size = Vector3.new(wallThickness, wallHeight, cageSize), offset = Vector3.new(cageSize/2 - wallThickness/2, 0, 0)},
        {name = "Left", size = Vector3.new(wallThickness, wallHeight, cageSize), offset = Vector3.new(-cageSize/2 + wallThickness/2, 0, 0)},
        {name = "Roof", size = Vector3.new(cageSize, wallThickness, cageSize), offset = Vector3.new(0, wallHeight/2 - wallThickness/2, 0)},
        {name = "Floor", size = Vector3.new(cageSize, wallThickness, cageSize), offset = Vector3.new(0, -wallHeight/2 + wallThickness/2, 0)},
    }
    
    for _, data in ipairs(partsData) do
        local part = makeCagePart(CFrame.new(), data.size, 0.5, nil, data.name)
        part:SetAttribute("Offset", data.offset) 
        table.insert(currentCageParts, part)
    end
    
    cageUpdateConnection = RunService.Heartbeat:Connect(function()
        if not selectedTarget or not selectedTarget.Character or not selectedTarget.Character:FindFirstChild("HumanoidRootPart") then
            isCagingActive = false
            local cageBtn = featureScrollFrame:FindFirstChild("CagePlayerButton")
            if cageBtn then updateButtonStatus(cageBtn, false, "CAGE PLAYER") end
            destroyCage()
            return
        end
        
        local rootPart = selectedTarget.Character.HumanoidRootPart
        local centerCFrame = rootPart.CFrame * CFrame.new(0, wallHeight/2, 0)

        for _, part in ipairs(currentCageParts) do
            local offset = part:GetAttribute("Offset")
            if offset then
                part.CFrame = centerCFrame * CFrame.new(offset)
            end
        end
    end)
    
    return true
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
        else
            isCagingActive = false
            updateButtonStatus(button, false, "CAGE PLAYER")
        end
    else
        destroyCage()
        updateButtonStatus(button, false, "CAGE PLAYER")
    end
end

-- 🔽 FUNGSI PULL AND CAGE BARU 🔽

local function pullAndCageTarget(button)
    if not selectedTarget then
        warn("Pilih target terlebih dahulu!")
        return
    end
    
    local targetCharacter = selectedTarget.Character
    local targetRoot = targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart")
    
    local localCharacter = player.Character
    local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
    
    if not targetRoot or not localRoot then
        warn("Target atau pemain lokal tidak memiliki HumanoidRootPart.")
        return
    end
    
    -- 1. Tentukan posisi di depan pemain lokal
    local distance = 5 -- Jarak di depan pemain lokal
    -- CFrame.Angles digunakan untuk mempertahankan rotasi target saat teleport
    local newPositionCFrame = localRoot.CFrame * CFrame.new(0, 0, -distance) 
    
    -- 2. Tarik Target ke posisi tersebut
    pcall(function()
        targetRoot.CFrame = newPositionCFrame * CFrame.Angles(targetRoot.CFrame:ToOrientation())
    end)
    
    -- 3. Langsung aktifkan fitur CAGE PLAYER
    if isCagingActive then
        isCagingActive = false -- Matikan dulu agar toggle menyalakannya kembali
        destroyCage()
    end
    
    local cageButton = featureScrollFrame:FindFirstChild("CagePlayerButton")
    if cageButton then
        -- Toggle akan menjalankan createCageForTarget dan memperbarui status
        toggleCagePlayer(cageButton) 
    else
        isCagingActive = true
        createCageForTarget()
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
        selectedTarget = targetPlayer
        
        for _, button in ipairs(playerScrollFrame:GetChildren()) do
            if button:IsA("TextButton") then
                button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            end
        end
        
        pButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
        
        updateTargetTitle()
        
        if isCagingActive then
            local cageBtn = featureScrollFrame:FindFirstChild("CagePlayerButton")
            if cageBtn then toggleCagePlayer(cageBtn) end
        end
    end)
    return pButton
end

local function refreshPlayerList()
    for _, button in ipairs(playerScrollFrame:GetChildren()) do
        if button:IsA("TextButton") then
            button:Destroy()
        end
    end
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then
            createPlayerButton(p)
        end
    end
end

Players.PlayerAdded:Connect(refreshPlayerList)
Players.PlayerRemoving:Connect(function(p)
    if selectedTarget == p then
        selectedTarget = nil
        updateTargetTitle()
        
        if isCagingActive then
            isCagingActive = false
            destroyCage()
            local cageBtn = featureScrollFrame:FindFirstChild("CagePlayerButton")
            if cageBtn then updateButtonStatus(cageBtn, false, "CAGE PLAYER") end
        end
    end
    refreshPlayerList()
end)

-- 🔽 PENAMBAHAN TOMBOL KE FEATURE LIST 🔽

local repulseButton = makeFeatureButton("REPULSE TOUCH: OFF", Color3.fromRGB(150, 0, 0), function(button)
    if isRepulseActive then
        disableRepulseTouch(button)
    else
        enableRepulseTouch(button)
    end
end)

local ownerTitleButton = makeFeatureButton("OWNER TITLE: OFF", Color3.fromRGB(150, 0, 0), toggleOwnerTitle)

local cagePlayerButton = makeFeatureButton("CAGE PLAYER: OFF", Color3.fromRGB(150, 0, 0), toggleCagePlayer)

-- TOMBOL PULL & CAGE BARU
local pullCageButton = makeFeatureButton("PULL & CAGE", Color3.fromRGB(0, 120, 200), pullAndCageTarget)

local resetButton = makeFeatureButton("RESET TARGET", Color3.fromRGB(200, 200, 0), function(button)
    selectedTarget = nil
    updateTargetTitle()
    refreshPlayerList()
    
    if isCagingActive then
        isCagingActive = false
        destroyCage()
        local cageBtn = featureScrollFrame:FindFirstChild("CagePlayerButton")
        if cageBtn then updateButtonStatus(cageBtn, false, "CAGE PLAYER") end
    end
end)


-- 🔽 LOGIKA CHARACTER ADDED (MENJAGA STATUS SETELAH MATI) 🔽
player.CharacterAdded:Connect(function(char)
    local repulseBtn = featureScrollFrame:FindFirstChild("RepulseTouchButton")
    local titleBtn = featureScrollFrame:FindFirstChild("OwnerTitleButton")
    
    if isRepulseActive and repulseBtn then
        enableRepulseTouch(repulseBtn) 
    end
    
    if isOwnerTitleActive and titleBtn then
        createOwnerTitle()
        updateButtonStatus(titleBtn, true, "OWNER TITLE")
    end
end)

-- LOGIKA KHUSUS: Mengaktifkan kembali sangkar jika target respawn
local function handleTargetCharacterAdded(char)
    if isCagingActive then
        local cageBtn = featureScrollFrame:FindFirstChild("CagePlayerButton")
        if cageBtn then
            -- Tunggu sebentar untuk memastikan root part dimuat
            task.wait(0.5) 
            createCageForTarget() 
            updateButtonStatus(cageBtn, true, "CAGE PLAYER")
        end
    end
end

-- Menghubungkan fungsi penanganan respawn ke target saat ini atau yang baru
Players.PlayerAdded:Connect(function(p)
    if p == selectedTarget then
        p.CharacterAdded:Connect(handleTargetCharacterAdded)
    end
end)

-- Pastikan target yang sudah ada juga dihubungkan
if selectedTarget then
    selectedTarget.CharacterAdded:Connect(handleTargetCharacterAdded)
end

-- Inisialisasi awal
updateButtonStatus(repulseButton, isRepulseActive, "REPULSE TOUCH")
updateButtonStatus(ownerTitleButton, isOwnerTitleActive, "OWNER TITLE")
updateButtonStatus(cagePlayerButton, isCagingActive, "CAGE PLAYER")
updateTargetTitle()
refreshPlayerList()
