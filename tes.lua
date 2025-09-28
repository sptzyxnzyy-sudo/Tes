--You can take the script with your own ideas, friend.
-- credit: Xraxor1

-- Core Services
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local PromptService = game:GetService("PromptService") -- Untuk konfirmasi hapus
local Clipboard = game:GetService("ClipboardService") -- Untuk copy lokasi

local player = Players.LocalPlayer

-- ** ⬇️ CORE STATUS & DATA ⬇️ **

-- Saved Location Feature Data (FITUR SAVE LOKASI)
local localSavedLocations = {} -- { {Name = "Lokasi 1", CFrame = CFrame.new(x, y, z)}, ... }
local isAutoTeleportingSaved = false -- Status untuk Auto-Teleporting melalui SAVED locations
local autoTeleportTask = nil
local featureScrollFrame -- Reference ke Saved Location List UI

-- Teleport ID Input References (FITUR 3)
local teleportIdInput = nil 
local serverIdInput = nil 

-- Auto Farm Status (FITUR 1)
local position1 = Vector3.new(625.27, 1799.83, 3432.84)
local position2 = Vector3.new(780.47, 2183.38, 3945.07)
local teleportingSummit = false 
local buttonSummit -- Reference ke tombol SUMMIT

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

-- 🔽 FUNGSI SAVE LOKASI & LIST 🔽

local function updateLocationList()
    if not featureScrollFrame then return end
    
    -- Hapus semua elemen lama di ScrollingFrame
    for _, child in ipairs(featureScrollFrame:GetChildren()) do
        if child:IsA("Frame") and child.Name == "LocationEntry" then
            child:Destroy()
        end
    end

    local listLayout = featureScrollFrame:FindFirstChild("FeatureListLayout")
    if not listLayout then return end

    -- Tambahkan lokasi baru
    for index, data in ipairs(localSavedLocations) do
        local entryFrame = Instance.new("Frame")
        entryFrame.Name = "LocationEntry"
        entryFrame.Size = UDim2.new(1, 0, 0, 30)
        entryFrame.BackgroundTransparency = 1
        entryFrame.Parent = featureScrollFrame

        local entryLayout = Instance.new("UIListLayout")
        entryLayout.FillDirection = Enum.FillDirection.Horizontal
        entryLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        entryLayout.Padding = UDim.new(0, 5)
        entryLayout.Parent = entryFrame
        
        -- Text Label (Nama Lokasi)
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(0.45, 0, 1, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = data.Name
        nameLabel.TextColor3 = Color3.new(1, 1, 1)
        nameLabel.Font = Enum.Font.Gotham
        nameLabel.TextSize = 12
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = entryFrame

        -- Tombol Teleport (Individual)
        local tpButton = Instance.new("TextButton")
        tpButton.Size = UDim2.new(0.25, 0, 1, 0)
        tpButton.BackgroundColor3 = Color3.fromRGB(0, 100, 200) -- Biru
        tpButton.Text = "TP"
        tpButton.TextColor3 = Color3.new(1, 1, 1)
        tpButton.Font = Enum.Font.GothamBold
        tpButton.TextSize = 12
        tpButton.Parent = entryFrame
        
        local tpCorner = Instance.new("UICorner")
        tpCorner.CornerRadius = UDim.new(0, 5)
        tpCorner.Parent = tpButton
        
        tpButton.MouseButton1Click:Connect(function()
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                character.HumanoidRootPart.CFrame = data.CFrame
                print("Teleport ke: " .. data.Name)
            end
        end)

        -- Tombol Delete
        local deleteButton = Instance.new("TextButton")
        deleteButton.Size = UDim2.new(0.25, 0, 1, 0)
        deleteButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0) -- Merah
        deleteButton.Text = "DEL"
        deleteButton.TextColor3 = Color3.new(1, 1, 1)
        deleteButton.Font = Enum.Font.GothamBold
        deleteButton.TextSize = 12
        deleteButton.Parent = entryFrame
        
        local delCorner = Instance.new("UICorner")
        delCorner.CornerRadius = UDim.new(0, 5)
        delCorner.Parent = deleteButton

        deleteButton.MouseButton1Click:Connect(function()
            local confirmed = PromptService:PromptDialog and PromptService:PromptDialog("KONFIRMASI HAPUS", "Hapus lokasi '" .. data.Name .. "'?", "DELETE", "CANCEL") or Enum.PromptButton.Button1
            
            if confirmed == Enum.PromptButton.Button1 then
                localSavedLocations[index] = nil 
                table.remove(localSavedLocations, index)
                updateLocationList()
                print("Lokasi dihapus: " .. data.Name)
            end
        end)
    end
    
    -- Update CanvasSize
    if listLayout and listLayout.AbsoluteContentSize.Y > 0 then
        featureScrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
    else
        featureScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    end
end

local function saveCurrentLocation()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    
    if root then
        local locationName = "Lokasi " .. (#localSavedLocations + 1)
        local cframe = root.CFrame
        
        table.insert(localSavedLocations, {Name = locationName, CFrame = cframe})
        print("Lokasi baru tersimpan: " .. locationName)
        updateLocationList()
    else
        warn("Karakter/RootPart tidak ditemukan.")
    end
end

local function toggleAutoTeleportSaved(button)
    if #localSavedLocations == 0 then
        warn("Tidak ada lokasi tersimpan untuk Auto-Teleport.")
        return
    end

    isAutoTeleportingSaved = not isAutoTeleportingSaved
    updateButtonStatus(button, isAutoTeleportingSaved, "AUTO TP SAVED")

    if isAutoTeleportingSaved then
        autoTeleportTask = task.spawn(function()
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if not root then
                warn("Tidak bisa Auto-Teleport: RootPart tidak ditemukan.")
                isAutoTeleportingSaved = false
                updateButtonStatus(button, false, "AUTO TP SAVED")
                return
            end
            
            for _, data in ipairs(localSavedLocations) do
                if not isAutoTeleportingSaved then break end 
                
                print("Auto-Teleport ke: " .. data.Name)
                root.CFrame = data.CFrame
                task.wait(1.5) 
            end
            
            isAutoTeleportingSaved = false
            updateButtonStatus(button, false, "AUTO TP SAVED")
            print("Auto-Teleport Selesai.")
        end)
    else
        if autoTeleportTask then
            task.cancel(autoTeleportTask)
        end
        print("Auto-Teleport Dibatalkan.")
    end
end

local function copyAllLocations()
    if #localSavedLocations == 0 then
        print("Tidak ada lokasi yang tersimpan untuk dicopy.")
        return
    end

    local locationString = "Saved Locations (CFrame):\n"
    for index, data in ipairs(localSavedLocations) do
        local pos = data.CFrame.p
        locationString = locationString .. string.format("[%d] %s: CFrame.new(%.3f, %.3f, %.3f)\n", index, data.Name, pos.X, pos.Y, pos.Z)
    end
    
    pcall(function()
        Clipboard:Set(locationString)
        print("Semua lokasi berhasil dicopy ke clipboard.")
    end)
end

-- 🔽 FUNGSI TELEPORT ID/SERVER (FITUR 3) 🔽

local function teleportToID()
    local placeIdText = teleportIdInput and teleportIdInput.Text
    local serverIdText = serverIdInput and serverIdInput.Text

    local placeId = tonumber(placeIdText)
    
    if not placeId or placeId <= 0 then
        warn("ID Tempat (Place ID) tidak valid.")
        return
    end

    if serverIdText and serverIdText ~= "" then
        print("Mencoba Teleport ke Server: " .. serverIdText .. " di Place ID: " .. placeId)
        local success, result = pcall(function()
            TeleportService:TeleportToPlaceInstance(placeId, serverIdText, player)
        end)

        if not success then
             print("Gagal Teleport ke Server ID. Mencoba Teleport standar...")
             TeleportService:Teleport(placeId, player)
        end
    else
        print("Mencoba Teleport standar ke Place ID: " .. placeId)
        TeleportService:Teleport(placeId, player)
    end
end

-- 🔽 AUTO FARM SYSTEM (Tombol SUMMIT - FITUR 1) - DIHUBUNGKAN KE TELEPORT ID 🔽

local function teleportTo(pos)
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(pos)
    end
end

local function autoFarmLoop()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then
        warn("Auto Farm dihentikan: Karakter tidak ditemukan.")
        teleportingSummit = false
        if buttonSummit and buttonSummit.Parent then
            buttonSummit.Text = "SUMMIT"
            buttonSummit.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        end
        return
    end

    teleportTo(position1)
    task.wait(2)
    teleportTo(position2)
    task.wait(1)
    
    -- **KONEKSI KE FITUR 3:** Gunakan Place ID dan Server ID dari Input
    local placeIdText = teleportIdInput and teleportIdInput.Text
    local serverIdText = serverIdInput and serverIdInput.Text
    local placeId = tonumber(placeIdText)
    
    if placeId and placeId > 0 then
        print("Auto Farm: Rejoining menggunakan Place ID: " .. placeId)
        
        if serverIdText and serverIdText ~= "" then
            pcall(function()
                TeleportService:TeleportToPlaceInstance(placeId, serverIdText, player)
            end)
        else
            TeleportService:Teleport(placeId, player)
        end
    else
        -- Fallback ke game.PlaceId jika input ID tidak valid
        print("Auto Farm: Rejoining menggunakan game.PlaceId (Input ID tidak valid)")
        TeleportService:Teleport(game.PlaceId, player) 
    end
end

local function toggleAutoFarm(state)
    teleportingSummit = state
    
    local statusValue = ReplicatedStorage:FindFirstChild("AutoFarmStatus")
    if statusValue then
        statusValue.Value = state
    end
    
    if teleportingSummit then
        buttonSummit.Text = "RUNNING..."
        buttonSummit.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        task.spawn(autoFarmLoop)
    else
        buttonSummit.Text = "SUMMIT"
        buttonSummit.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    end
end

-- 🔽 ANIMASI "BY : Xraxor" (FITUR 4) 🔽
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

-- 🔽 GUI UTAMA 🔽
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CoreFeaturesGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 500) 
frame.Position = UDim2.new(0.4, -110, 0.5, -250)
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
title.Text = "Mount Atin V2"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = frame

-- Tombol SUMMIT (Feature 1)
buttonSummit = Instance.new("TextButton")
buttonSummit.Name = "SummitButton"
buttonSummit.Size = UDim2.new(0, 160, 0, 40)
buttonSummit.Position = UDim2.new(0.5, -80, 0, 40) 
buttonSummit.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
buttonSummit.Text = "SUMMIT"
buttonSummit.TextColor3 = Color3.new(1, 1, 1)
buttonSummit.Font = Enum.Font.GothamBold
buttonSummit.TextSize = 15
buttonSummit.Parent = frame

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 10)
buttonCorner.Parent = buttonSummit

buttonSummit.MouseButton1Click:Connect(function()
    toggleAutoFarm(not teleportingSummit)
end)

-- 🔽 KELOMPOK TELEPORT ID/SERVER (Feature 3) 🔽

local teleportTitle = Instance.new("TextLabel")
teleportTitle.Size = UDim2.new(1, -20, 0, 20)
teleportTitle.Position = UDim2.new(0.5, -100, 0, 95)
teleportTitle.BackgroundTransparency = 1
teleportTitle.Text = "Teleport ID/Server"
teleportTitle.TextColor3 = Color3.new(1, 1, 1)
teleportTitle.Font = Enum.Font.GothamBold
teleportTitle.TextSize = 14
teleportTitle.Parent = frame

-- Input Place ID
local placeIdLabel = Instance.new("TextLabel")
placeIdLabel.Size = UDim2.new(0.4, 0, 0, 20)
placeIdLabel.Position = UDim2.new(0, 10, 0, 120)
placeIdLabel.BackgroundTransparency = 1
placeIdLabel.Text = "Place ID:"
placeIdLabel.TextColor3 = Color3.new(1, 1, 1)
placeIdLabel.Font = Enum.Font.Gotham
placeIdLabel.TextSize = 12
placeIdLabel.TextXAlignment = Enum.TextXAlignment.Left
placeIdLabel.Parent = frame

teleportIdInput = Instance.new("TextBox")
teleportIdInput.Size = UDim2.new(0.5, 0, 0, 20)
teleportIdInput.Position = UDim2.new(0.45, 0, 0, 120)
teleportIdInput.PlaceholderText = "Masukkan Place ID"
teleportIdInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
teleportIdInput.TextColor3 = Color3.new(1, 1, 1)
teleportIdInput.Font = Enum.Font.SourceSans
teleportIdInput.TextSize = 12
teleportIdInput.Parent = frame

-- Input Server ID
local serverIdLabel = Instance.new("TextLabel")
serverIdLabel.Size = UDim2.new(0.4, 0, 0, 20)
serverIdLabel.Position = UDim2.new(0, 10, 0, 145)
serverIdLabel.BackgroundTransparency = 1
serverIdLabel.Text = "Server ID:"
serverIdLabel.TextColor3 = Color3.new(1, 1, 1)
serverIdLabel.Font = Enum.Font.Gotham
serverIdLabel.TextSize = 12
serverIdLabel.TextXAlignment = Enum.TextXAlignment.Left
serverIdLabel.Parent = frame

serverIdInput = Instance.new("TextBox")
serverIdInput.Size = UDim2.new(0.5, 0, 0, 20)
serverIdInput.Position = UDim2.new(0.45, 0, 0, 145)
serverIdInput.PlaceholderText = "Opsional Server ID"
serverIdInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
serverIdInput.TextColor3 = Color3.new(1, 1, 1)
serverIdInput.Font = Enum.Font.SourceSans
serverIdInput.TextSize = 12
serverIdInput.Parent = frame

-- Tombol Teleport (Execute)
local tpExecuteButton = Instance.new("TextButton")
tpExecuteButton.Size = UDim2.new(0, 160, 0, 30)
tpExecuteButton.Position = UDim2.new(0.5, -80, 0, 175)
tpExecuteButton.BackgroundColor3 = Color3.fromRGB(0, 100, 200) 
tpExecuteButton.Text = "TELEPORT"
tpExecuteButton.TextColor3 = Color3.new(1, 1, 1)
tpExecuteButton.Font = Enum.Font.GothamBold
tpExecuteButton.TextSize = 15
tpExecuteButton.Parent = frame

local tpExecuteCorner = Instance.new("UICorner")
tpExecuteCorner.CornerRadius = UDim.new(0, 8)
tpExecuteCorner.Parent = tpExecuteButton

tpExecuteButton.MouseButton1Click:Connect(teleportToID)


-- 🔽 KELOMPOK SAVE LOKASI & UTILITY (Fitur Save) 🔽

local saveTitle = Instance.new("TextLabel")
saveTitle.Size = UDim2.new(1, -20, 0, 20)
saveTitle.Position = UDim2.new(0.5, -100, 0, 215)
saveTitle.BackgroundTransparency = 1
saveTitle.Text = "Saved Location Manager"
saveTitle.TextColor3 = Color3.new(1, 1, 1)
saveTitle.Font = Enum.Font.GothamBold
saveTitle.TextSize = 14
saveTitle.Parent = frame

-- ScrollingFrame untuk Utility Button (Save, Auto TP, Copy)
local utilityScrollFrame = Instance.new("ScrollingFrame")
utilityScrollFrame.Name = "UtilityList"
utilityScrollFrame.Size = UDim2.new(1, -20, 0, 70) 
utilityScrollFrame.Position = UDim2.new(0.5, -100, 0, 240)
utilityScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
utilityScrollFrame.ScrollBarThickness = 6
utilityScrollFrame.BackgroundTransparency = 1
utilityScrollFrame.Parent = frame

local utilityListLayout = Instance.new("UIListLayout")
utilityListLayout.Padding = UDim.new(0, 5)
utilityListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
utilityListLayout.SortOrder = Enum.SortOrder.LayoutOrder
utilityListLayout.Parent = utilityScrollFrame

utilityListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    utilityScrollFrame.CanvasSize = UDim2.new(0, 0, 0, utilityListLayout.AbsoluteContentSize.Y + 10)
end)

-- Fungsi pembuat tombol untuk utilitas
local function makeUtilityButton(name, layoutOrder, color, callback)
    local featButton = Instance.new("TextButton")
    featButton.Name = name:gsub(" ", "") .. "Button"
    featButton.Size = UDim2.new(0, 180, 0, 20)
    featButton.BackgroundColor3 = color
    featButton.Text = name
    featButton.TextColor3 = Color3.new(1, 1, 1)
    featButton.Font = Enum.Font.GothamBold
    featButton.TextSize = 12
    featButton.LayoutOrder = layoutOrder
    featButton.Parent = utilityScrollFrame

    local featCorner = Instance.new("UICorner")
    featCorner.CornerRadius = UDim.new(0, 6)
    featCorner.Parent = featButton

    featButton.MouseButton1Click:Connect(function()
        callback(featButton)
    end)
    return featButton
end

-- Tombol Utilitas 
local saveButton = makeUtilityButton("SAVE LOKASI", 1, Color3.fromRGB(0, 150, 0), saveCurrentLocation)
local autoTpSavedButton = makeUtilityButton("AUTO TP SAVED: OFF", 2, Color3.fromRGB(150, 0, 0), toggleAutoTeleportSaved)
local copyButton = makeUtilityButton("COPY ALL LOCATIONS", 3, Color3.fromRGB(200, 100, 0), copyAllLocations)


-- ScrollingFrame untuk Daftar Lokasi yang Disimpan
featureScrollFrame = Instance.new("ScrollingFrame")
featureScrollFrame.Name = "LocationList"
featureScrollFrame.Size = UDim2.new(1, -20, 1, -330) 
featureScrollFrame.Position = UDim2.new(0.5, -100, 0, 320)
featureScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
featureScrollFrame.ScrollBarThickness = 6
featureScrollFrame.BackgroundTransparency = 0.9
featureScrollFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
featureScrollFrame.Parent = frame

local locationListLayout = Instance.new("UIListLayout")
locationListLayout.Name = "FeatureListLayout"
locationListLayout.Padding = UDim.new(0, 5)
locationListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
locationListLayout.SortOrder = Enum.SortOrder.LayoutOrder
locationListLayout.Parent = featureScrollFrame

locationListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    if locationListLayout.AbsoluteContentSize.Y > 0 then
        featureScrollFrame.CanvasSize = UDim2.new(0, 0, 0, locationListLayout.AbsoluteContentSize.Y)
    else
        featureScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    end
end)

-- 🔽 LOGIKA STATUS AWAL 🔽

local statusValue = ReplicatedStorage:FindFirstChild("AutoFarmStatus")
if not statusValue then
    statusValue = Instance.new("BoolValue")
    statusValue.Name = "AutoFarmStatus"
    statusValue.Value = false
    statusValue.Parent = ReplicatedStorage
end

player.CharacterAdded:Connect(function(char)
    -- Matikan status auto teleport saved saat respawn
    if isAutoTeleportingSaved then
        isAutoTeleportingSaved = false
        if autoTpSavedButton and autoTpSavedButton.Parent then
            updateButtonStatus(autoTpSavedButton, false, "AUTO TP SAVED")
        end
        if autoTeleportTask then
            task.cancel(autoTeleportTask)
        end
    end
end)

updateButtonStatus(autoTpSavedButton, isAutoTeleportingSaved, "AUTO TP SAVED")
updateLocationList()
