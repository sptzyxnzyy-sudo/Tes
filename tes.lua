local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- ** ⬇️ STATUS FITUR CORE ⬇️ **
local isShakerActive = false -- Ganti isTetherActive menjadi isShakerActive
local shakerTouchConnection = nil
local activeShakes = {} -- Menyimpan tween untuk part yang sedang digoyangkan

-- Konstanta Goyang
local SHAKE_DURATION = 0.1 -- Durasi setiap siklus goyang
local SHAKE_MAGNITUDE = 0.5 -- Besarnya pergeseran goyang (dalam stud)
local SHAKE_CYCLES = 10 -- Jumlah siklus goyang per sentuhan

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

-- Frame utama (Disesuaikan untuk 1 tombol)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 100) 
frame.Position = UDim2.new(0.4, -110, 0.5, -50)
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


-- 🔽 FUNGSI PART SHAKER BARU (GOYANG PART SAAT SENTUH) 🔽

local function startShake(part)
    if not part or activeShakes[part] then return end

    local originalCFrame = part.CFrame
    local currentCycles = 0
    local isShaking = true
    
    activeShakes[part] = isShaking -- Tandai part sedang digoyangkan

    local function performShake()
        if not part.Parent or currentCycles >= SHAKE_CYCLES or not isShaking then
            activeShakes[part] = nil -- Hapus dari daftar aktif
            if part.Parent then
                -- Pastikan part kembali ke posisi semula
                part.CFrame = originalCFrame 
            end
            return
        end

        currentCycles = currentCycles + 1
        
        -- Goyang ke arah acak (sedikit ke samping)
        local randomVector = Vector3.new(math.random() * 2 - 1, math.random() * 2 - 1, math.random() * 2 - 1) * SHAKE_MAGNITUDE
        local targetCFrame = originalCFrame * CFrame.new(randomVector)
        
        local tweenInfo = TweenInfo.new(SHAKE_DURATION, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
        local tween = TweenService:Create(part, tweenInfo, {CFrame = targetCFrame})

        tween.Completed:Connect(function()
            -- Kembali ke posisi semula (atau lakukan siklus berikutnya)
            if part.Parent and currentCycles < SHAKE_CYCLES and isShaking then
                local resetTween = TweenService:Create(part, tweenInfo, {CFrame = originalCFrame})
                resetTween.Completed:Wait() -- Tunggu sebentar untuk efek goyang
                performShake()
            else
                activeShakes[part] = nil
                if part.Parent then
                    part.CFrame = originalCFrame 
                end
            end
        end)
        tween:Play()
    end

    performShake()
end

local function onShakerTouch(otherPart)
    if not isShakerActive or not otherPart or not otherPart.Parent then return end

    -- Mendapatkan Humanoid Root Part dari karakter kita sendiri untuk koneksi Touched
    local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    
    -- Pastikan bagian yang disentuh BUKAN bagian dari karakter kita sendiri
    if otherPart.Parent:FindFirstChildOfClass("Humanoid") and otherPart.Parent == player.Character then 
        return 
    end

    -- Target adalah part yang disentuh (atau model/karakter lain)
    local targetPart = otherPart
    
    -- Cek apakah target memiliki Prompt (misalnya ProximityPrompt) di dalamnya atau di induknya
    local hasPrompt = targetPart:FindFirstChildOfClass("ProximityPrompt")
    if not hasPrompt then
        -- Cek di model induknya
        if targetPart.Parent and targetPart.Parent:FindFirstChildOfClass("ProximityPrompt") then
             hasPrompt = targetPart.Parent:FindFirstChildOfClass("ProximityPrompt")
        end
    end

    -- Hanya goyangkan jika part tersebut atau induknya memiliki ProximityPrompt DAN itu adalah BasePart yang dapat digoyangkan
    if hasPrompt and targetPart:IsA("BasePart") and targetPart.Anchored == false then
        if not activeShakes[targetPart] then
            startShake(targetPart)
            print("Part Shaker Aktif: Menggoyangkan " .. targetPart.Name)
        end
    end
end

local function activateShaker(button)
    if isShakerActive then return end
    isShakerActive = true
    
    local character = player.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    
    if not rootPart then 
        warn("HumanoidRootPart tidak ditemukan.")
        isShakerActive = false
        updateButtonStatus(button, false, "PART SHAKER")
        return 
    end

    updateButtonStatus(button, true, "PART SHAKER")
    
    -- Hubungkan event Touched ke HumanoidRootPart pemain
    if shakerTouchConnection then shakerTouchConnection:Disconnect() end
    shakerTouchConnection = rootPart.Touched:Connect(onShakerTouch)
    
    print("Part Shaker AKTIF.")
end

local function deactivateShaker(button)
    if not isShakerActive then return end
    isShakerActive = false
    
    if shakerTouchConnection then
        shakerTouchConnection:Disconnect()
        shakerTouchConnection = nil
    end
    
    -- Tidak perlu fungsi releaseAllTethers lagi
    updateButtonStatus(button, false, "PART SHAKER")
    print("Part Shaker NONAKTIF.")
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

-- Tombol PART SHAKER BARU
local shakerButton = makeFeatureButton("PART SHAKER: OFF", Color3.fromRGB(150, 0, 0), function(button)
    if isShakerActive then
        deactivateShaker(button)
    else
        activateShaker(button)
    end
end)


-- 🔽 LOGIKA CHARACTER ADDED (PENTING UNTUK MEMPERTAHANKAN STATUS) 🔽
player.CharacterAdded:Connect(function(char)
    -- Lakukan deactivate untuk membersihkan koneksi lama (jika ada)
    deactivateShaker(shakerButton)
    
    -- Pertahankan status Part Shaker
    if isShakerActive then
        char:WaitForChild("HumanoidRootPart", 5)
        local button = featureScrollFrame:FindFirstChild("PartShakerButton")
        if button then activateShaker(button) end
    end
end)


-- Atur status awal tombol
updateButtonStatus(shakerButton, isShakerActive, "PART SHAKER")
