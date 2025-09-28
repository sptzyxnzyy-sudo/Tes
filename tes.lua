-- credit: Xraxor1 (Original GUI/Intro structure)
-- Modification: Added Prompt Destroyer feature for global manipulation.

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage") 

-- 🚨 GANTI INI 🚨: Anda harus menemukan RemoteEvent yang rentan di game target 
-- yang menerima Part sebagai argumen dan menghancurkannya.
local PromptDestroyerRemote = ReplicatedStorage:FindFirstChild("RemoteEventRentanyangAdayangBisaDigunakan") 

local player = Players.LocalPlayer

-- ** ⬇️ STATUS FITUR CORE ⬇️ **
local isTetherActive = false 
local tetherTouchConnection = nil
local activeTethers = {} 

-- ** STATUS PROMPT DESTROYER **
local isDestroyerActive = false
local destroyerTouchConnection = nil


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

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 150) 
frame.Position = UDim2.new(0.4, -110, 0.5, -75) 
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 15)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "CORE FEATURES"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = frame

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


-- 🔽 FUNGSI PLAYER TETHER 🔽

local function onTetherTouch(otherPart)
    if not isTetherActive or not otherPart or not otherPart.Parent then return end

    local targetPlayer = Players:GetPlayerFromCharacter(otherPart.Parent)
    local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    local targetRoot = targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")

    if not myRoot or not targetRoot or targetPlayer == player then return end

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
    
    releaseAllTethers()
    updateButtonStatus(button, false, "PLAYER TETHER")
    print("Player Tether NONAKTIF.")
end


-- 🔽 FUNGSI PROMPT DESTROYER 🔽

local function onPartDestroyerTouch(otherPart)
    if not isDestroyerActive or not otherPart or not otherPart.Parent then return end

    local char = player.Character
    local targetModel = otherPart.Parent
    
    -- Logika Sentuh: Abaikan karakter pemain (Anda atau pemain lain)
    local isTouchingMyCharacter = char and (targetModel == char or targetModel.Parent == char)
    local isTouchingOtherPlayer = Players:GetPlayerFromCharacter(targetModel) or 
                                  (targetModel.Parent and Players:GetPlayerFromCharacter(targetModel.Parent))

    if isTouchingMyCharacter or isTouchingOtherPlayer then
        return 
    end

    local targetPart = otherPart
    
    -- Logika Deteksi: Cek Part Promt
    local hasPrompt = targetPart:FindFirstChildOfClass("ProximityPrompt")
    if not hasPrompt then
        if targetPart.Parent and targetPart.Parent:FindFirstChildOfClass("ProximityPrompt") then
             hasPrompt = targetPart.Parent:FindFirstChildOfClass("ProximityPrompt")
        end
    end

    if hasPrompt and targetPart:IsA("BasePart") then
        if PromptDestroyerRemote then
            -- Kunci: Mengirim sinyal ke Server untuk penghapusan global
            -- Tidak ada penghapusan lokal agar fitur tidak terlihat "hanya di layar saya".
            PromptDestroyerRemote:FireServer(targetPart)
            print("Prompt Destroyer: Permintaan penghapusan part " .. targetPart.Name .. " dikirim ke Server.")
        else
            warn("Prompt Destroyer: RemoteEvent tidak ditemukan. Aksi global GAGAL.")
        end
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

-- 1. Tombol PLAYER TETHER
local tetherButton = makeFeatureButton("PLAYER TETHER: OFF", Color3.fromRGB(150, 0, 0), function(button)
    if isTetherActive then
        deactivateTether(button)
    else
        activateTether(button)
    end
end)

-- 2. Tombol PROMPT DESTROYER
local destroyerButton = makeFeatureButton("PROMPT DESTROYER: OFF", Color3.fromRGB(150, 0, 0), function(button)
    if isDestroyerActive then
        deactivateDestroyer(button)
    else
        activateDestroyer(button)
    end
end)


-- 🔽 LOGIKA CHARACTER ADDED 🔽
player.CharacterAdded:Connect(function(char)
    releaseAllTethers() 
    
    if isTetherActive then
        char:WaitForChild("HumanoidRootPart", 5)
        local button = featureScrollFrame:FindFirstChild("PlayerTetherButton")
        if button then activateTether(button) end
    end
    
    if isDestroyerActive then
        char:WaitForChild("HumanoidRootPart", 5)
        local button = featureScrollFrame:FindFirstChild("PromptDestroyerButton")
        if button then activateDestroyer(button) end
    end
end)


-- Atur status awal tombol
updateButtonStatus(tetherButton, isTetherActive, "PLAYER TETHER")
updateButtonStatus(destroyerButton, isDestroyerActive, "PROMPT DESTROYER")
