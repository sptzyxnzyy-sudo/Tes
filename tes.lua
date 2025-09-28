local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local PromptService = game:GetService("PromptService") -- Tambahkan layanan PromptService untuk konfirmasi hapus
local Clipboard = game:GetService("ClipboardService") -- Tambahkan layanan ClipboardService

local player = Players.LocalPlayer

-- ** ⬇️ STATUS FITUR CORE ⬇️ **
local localSavedLocations = {} -- { {Name = "Lokasi 1", CFrame = CFrame.new(x, y, z)}, ... }
local isAutoTeleporting = false
local autoTeleportTask = nil

local featureScrollFrame -- Dideklarasikan lebih awal

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

-- 🔽 FUNGSI GUI LIST LOKASI 🔽

-- Fungsi untuk mengupdate tampilan list lokasi
local function updateLocationList()
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
        entryFrame.Size = UDim2.new(1, 0, 0, 40)
        entryFrame.BackgroundTransparency = 1
        entryFrame.Parent = featureScrollFrame

        local entryLayout = Instance.new("UIListLayout")
        entryLayout.FillDirection = Enum.FillDirection.Horizontal
        entryLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        entryLayout.Padding = UDim.new(0, 5)
        entryLayout.Parent = entryFrame
        
        -- Text Label (Nama Lokasi)
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(0.5, 0, 1, 0)
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
            -- Konfirmasi Hapus
            local confirmed = PromptService:PromptDialog("KONFIRMASI HAPUS", "Hapus lokasi '" .. data.Name .. "'?", "DELETE", "CANCEL")
            
            if confirmed == Enum.PromptButton.Button1 then -- DELETE
                -- Hapus item dari tabel
                localSavedLocations[index] = nil 
                table.remove(localSavedLocations, index)
                updateLocationList()
                print("Lokasi dihapus: " .. data.Name)
            end
        end)
    end
    
    -- Update CanvasSize
    featureScrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
end

-- 🔽 FUNGSI LOKASI & TELEPORT 🔽

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

local function toggleAutoTeleport(button)
    isAutoTeleporting = not isAutoTeleporting
    updateButtonStatus(button, isAutoTeleporting, "AUTO TP ALL")

    if isAutoTeleporting then
        autoTeleportTask = task.spawn(function()
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if not root then
                warn("Tidak bisa Auto-Teleport: RootPart tidak ditemukan.")
                isAutoTeleporting = false
                updateButtonStatus(button, false, "AUTO TP ALL")
                return
            end
            
            for _, data in ipairs(localSavedLocations) do
                if not isAutoTeleporting then break end -- Berhenti jika dinonaktifkan
                
                print("Auto-Teleport ke: " .. data.Name)
                root.CFrame = data.CFrame
                task.wait(1.5) -- Jeda antar teleport
            end
            
            isAutoTeleporting = false
            updateButtonStatus(button, false, "AUTO TP ALL")
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

-- Frame utama (Disesuaikan untuk fitur baru)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 350) -- Ukuran diperluas untuk List Lokasi
frame.Position = UDim2.new(0.5, -110, 0.5, -175) 
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
title.Text = "TELEPORT MANAGER" -- Judul diubah
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = frame

-- ScrollingFrame untuk Daftar Pilihan Fitur (Utilitas: Save, Auto TP, Copy)
local utilityScrollFrame = Instance.new("ScrollingFrame")
utilityScrollFrame.Name = "UtilityList"
utilityScrollFrame.Size = UDim2.new(1, -20, 0, 95) 
utilityScrollFrame.Position = UDim2.new(0.5, -100, 0, 35)
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
    featButton.Size = UDim2.new(0, 180, 0, 25)
    featButton.BackgroundColor3 = color
    featButton.Text = name
    featButton.TextColor3 = Color3.new(1, 1, 1)
    featButton.Font = Enum.Font.GothamBold
    featButton.TextSize = 12
    featButton.LayoutOrder = layoutOrder
    featButton.Parent = utilityScrollFrame

    local featCorner = Instance.new("UICorner")
    featCorner.CornerRadius = UDim.new(0, 8)
    featCorner.Parent = featButton

    featButton.MouseButton1Click:Connect(function()
        callback(featButton)
    end)
    return featButton
end

-- Tombol Utilitas (LayoutOrder memastikan urutan)
local saveButton = makeUtilityButton("SAVE LOKASI", 1, Color3.fromRGB(0, 150, 0), saveCurrentLocation)
local autoTpButton = makeUtilityButton("AUTO TP ALL: OFF", 2, Color3.fromRGB(150, 0, 0), toggleAutoTeleport)
local copyButton = makeUtilityButton("COPY ALL LOCATIONS", 3, Color3.fromRGB(200, 100, 0), copyAllLocations)


-- ScrollingFrame untuk Daftar Lokasi yang Disimpan (Menggantikan featureScrollFrame lama)
featureScrollFrame = Instance.new("ScrollingFrame") -- Menimpa definisi featureScrollFrame lama
featureScrollFrame.Name = "LocationList"
featureScrollFrame.Size = UDim2.new(1, -20, 1, -150) 
featureScrollFrame.Position = UDim2.new(0.5, -100, 0, 135)
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


-- 🔽 LOGIKA CHARACTER ADDED 🔽
player.CharacterAdded:Connect(function(char)
    -- Matikan status auto teleport saat respawn
    if isAutoTeleporting then
        isAutoTeleporting = false
        if autoTpButton and autoTpButton.Parent then
            updateButtonStatus(autoTpButton, false, "AUTO TP ALL")
        end
        if autoTeleportTask then
            task.cancel(autoTeleportTask)
        end
    end
end)


-- Atur status awal tombol dan list
updateButtonStatus(autoTpButton, isAutoTeleporting, "AUTO TP ALL")
updateLocationList()
