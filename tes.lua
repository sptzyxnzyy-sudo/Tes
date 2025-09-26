-- credit: Xraxor1 (Original GUI/Intro structure)
-- Modification for Impersonate Player: [AI Assistant]

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

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

-- 🔽 Status AutoFarm (Dipertahankan untuk struktur GUI awal, walau tidak dipakai) 🔽
local statusValue = ReplicatedStorage:FindFirstChild("AutoFarmStatus")
if not statusValue then
    statusValue = Instance.new("BoolValue")
    statusValue.Name = "AutoFarmStatus"
    statusValue.Value = false
    statusValue.Parent = ReplicatedStorage
end

-- 🔽 GUI Utama 🔽
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ImpersonateGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 160)
frame.Position = UDim2.new(0.4, -110, 0.5, -80)
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
title.Text = "IMPERSONATE"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = frame

-- Tombol RESET (Menggantikan SUMMIT)
local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 160, 0, 40)
button.Position = UDim2.new(0.5, -80, 0.5, -20)
button.BackgroundColor3 = Color3.fromRGB(150, 0, 0) -- Merah untuk Reset
button.Text = "RESET AVATAR & STATS"
button.TextColor3 = Color3.new(1, 1, 1)
button.Font = Enum.Font.GothamBold
button.TextSize = 12
button.Parent = frame

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 10)
buttonCorner.Parent = button

-- 🔽 GUI Samping Player List 🔽
local flagButton = Instance.new("ImageButton")
flagButton.Size = UDim2.new(0, 20, 0, 20)
flagButton.Position = UDim2.new(1, -30, 0, 5)
flagButton.BackgroundTransparency = 1
flagButton.Image = "rbxassetid://6031097229" -- Ikon Bendera (Bisa diganti ikon User)
flagButton.Parent = frame

local sideFrame = Instance.new("Frame")
sideFrame.Size = UDim2.new(0, 170, 0, 250)
sideFrame.Position = UDim2.new(1, 10, 0, 0)
sideFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
sideFrame.Visible = false
sideFrame.Parent = frame

local sideCorner = Instance.new("UICorner")
sideCorner.CornerRadius = UDim.new(0, 12)
sideCorner.Parent = sideFrame

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, 0, 1, -5)
scrollFrame.Position = UDim2.new(0, 0, 0, 5)
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.ScrollBarThickness = 6
scrollFrame.BackgroundTransparency = 1
scrollFrame.Parent = sideFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 5)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = scrollFrame

listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
end)

-- 🔽 Fungsi Inti "Meniru Pemain" 🔽

local function makePlayerButton(targetPlayer)
    local tpButton = Instance.new("TextButton")
    tpButton.Size = UDim2.new(0, 140, 0, 35)
    tpButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    tpButton.Text = targetPlayer.Name .. (targetPlayer == player and " (You)" or "")
    tpButton.TextColor3 = Color3.new(1, 1, 1)
    tpButton.Font = Enum.Font.SourceSansBold
    tpButton.TextSize = 14
    tpButton.Parent = scrollFrame

    local tpCorner = Instance.new("UICorner")
    tpCorner.CornerRadius = UDim.new(0, 8)
    tpCorner.Parent = tpButton

    tpButton.MouseButton1Click:Connect(function()
        local char = player.Character
        local targetChar = targetPlayer.Character

        if not char or not targetChar then
            warn("Karakter tidak ditemukan!")
            return
        end

        local playerHumanoid = char:FindFirstChildOfClass("Humanoid")
        local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")

        if not playerHumanoid or not targetHumanoid then
            warn("Humanoid tidak ditemukan!")
            return
        end

        -- 1. CLONING KOSTUM/AKSESORIS
        -- Menghapus aksesoris yang ada di pemain saat ini
        for _, obj in ipairs(char:GetChildren()) do
            if obj:IsA("Accessory") or obj:IsA("Shirt") or obj:IsA("Pants") then
                obj:Destroy()
            end
        end

        -- Kloning Aksesoris/Pakaian dari pemain target (hanya di klien)
        for _, obj in ipairs(targetChar:GetChildren()) do
            if obj:IsA("Accessory") or obj:IsA("Shirt") or obj:IsA("Pants") then
                local clone = obj:Clone()
                clone.Parent = char
            end
            -- CATATAN: Kloning Tool/Senjata dan Pakaian sempurna memerlukan Server/Remote Event
        end

        -- 2. STATS DAN LOKASI
        local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
        local playerRoot = char:FindFirstChild("HumanoidRootPart")
        
        -- Meniru Kecepatan Berjalan/Melompat
        playerHumanoid.WalkSpeed = targetHumanoid.WalkSpeed
        playerHumanoid.JumpPower = targetHumanoid.JumpPower
        
        -- Teleportasi ke Lokasi Target
        if targetRoot and playerRoot then
            playerRoot.CFrame = targetRoot.CFrame
        end
        
        -- Coba memuat deskripsi avatar (efeknya seringkali tidak bekerja tanpa exploit)
        -- player:LoadCharacterWithHumanoidDescription(targetHumanoid:GetAppliedDescription())

        print("Meniru properti dari: " .. targetPlayer.Name)
    end)
end

-- Fungsi untuk mengisi daftar pemain
local function populatePlayerList()
    -- Hapus tombol lama
    for _, child in ipairs(scrollFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    -- Tambahkan tombol baru
    local playerList = Players:GetPlayers()
    table.sort(playerList, function(a, b)
        return a.Name < b.Name
    end)

    for _, target in ipairs(playerList) do
        makePlayerButton(target)
    end
end

-- Logika Tombol Samping (Toggle Player List)
flagButton.MouseButton1Click:Connect(function()
    sideFrame.Visible = not sideFrame.Visible
    if sideFrame.Visible then
        populatePlayerList()
    end
end)

-- 🔽 FITUR RESET (Tombol Utama) 🔽
button.MouseButton1Click:Connect(function()
    -- Memuat ulang karakter (cara tercepat untuk reset penampilan dan tool)
    local success, err = pcall(function()
        player:LoadCharacter()
    end)

    if success then
        -- Atur ulang kecepatan ke default Roblox
        player.Character:WaitForChild("Humanoid").WalkSpeed = 16
        player.Character:WaitForChild("Humanoid").JumpPower = 50
    end
    
    print("Karakter berhasil di-reset.")
end)
