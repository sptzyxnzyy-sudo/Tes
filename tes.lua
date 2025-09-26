-- credit: Xraxor1 (Original GUI/Intro structure)
-- Modification for Impersonate Player & Phantom Touch: [AI Assistant]

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

-- Status untuk fitur baru
local isPhantomTouchActive = false
local touchConnection = nil
local partsTouched = {} -- Tabel untuk melacak part yang telah disentuh

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

-- 🔽 GUI Utama 🔽
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ImpersonateGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
-- Ukuran Frame diperbesar untuk menampung tombol baru (160 -> 220)
frame.Size = UDim2.new(0, 220, 0, 220) 
frame.Position = UDim2.new(0.4, -110, 0.5, -110)
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

-- Tombol RESET
local buttonReset = Instance.new("TextButton")
buttonReset.Name = "ResetButton"
buttonReset.Size = UDim2.new(0, 160, 0, 40)
buttonReset.Position = UDim2.new(0.5, -80, 0.35, -20) -- Posisi disesuaikan
buttonReset.BackgroundColor3 = Color3.fromRGB(150, 0, 0) 
buttonReset.Text = "RESET AVATAR & STATS"
buttonReset.TextColor3 = Color3.new(1, 1, 1)
buttonReset.Font = Enum.Font.GothamBold
buttonReset.TextSize = 12
buttonReset.Parent = frame

local buttonResetCorner = Instance.new("UICorner")
buttonResetCorner.CornerRadius = UDim.new(0, 10)
buttonResetCorner.Parent = buttonReset

-- Tombol PHANTOM TOUCH (Fitur Baru)
local buttonPhantom = Instance.new("TextButton")
buttonPhantom.Name = "PhantomButton"
buttonPhantom.Size = UDim2.new(0, 160, 0, 40)
buttonPhantom.Position = UDim2.new(0.5, -80, 0.65, -20) -- Posisi disesuaikan
buttonPhantom.BackgroundColor3 = Color3.fromRGB(40, 40, 40) -- Default OFF
buttonPhantom.Text = "PHANTOM TOUCH: OFF"
buttonPhantom.TextColor3 = Color3.new(1, 1, 1)
buttonPhantom.Font = Enum.Font.GothamBold
buttonPhantom.TextSize = 12
buttonPhantom.Parent = frame

local buttonPhantomCorner = Instance.new("UICorner")
buttonPhantomCorner.CornerRadius = UDim.new(0, 10)
buttonPhantomCorner.Parent = buttonPhantom

-- 🔽 GUI Samping Player List (Tidak berubah) 🔽
local flagButton = Instance.new("ImageButton")
flagButton.Size = UDim2.new(0, 20, 0, 20)
flagButton.Position = UDim2.new(1, -30, 0, 5)
flagButton.BackgroundTransparency = 1
flagButton.Image = "rbxassetid://6031097229" 
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


-- 🔽 LOGIKA PHANTOM TOUCH (Fitur Baru) 🔽

local function onPartTouched(otherPart)
    -- Pastikan fitur aktif dan part yang disentuh valid
    if not isPhantomTouchActive or not otherPart or not otherPart:IsA("BasePart") then return end

    -- Abaikan jika bagian tersebut milik karakter, GUI, atau sudah dihilangkan
    if otherPart:IsDescendantOf(player.Character) or otherPart.Parent:IsA("Accessory") or partsTouched[otherPart] then return end

    -- Logika Klien Side Exploit: Hilangkan part
    otherPart.Transparency = 1
    otherPart.CanCollide = false
    
    -- Tandai part agar tidak diproses berulang
    partsTouched[otherPart] = true
    
    print("Phantom Touched: " .. otherPart.Name .. " menghilang.")
end

local function enablePhantomTouch()
    isPhantomTouchActive = true
    buttonPhantom.Text = "PHANTOM TOUCH: ON"
    buttonPhantom.BackgroundColor3 = Color3.fromRGB(0, 180, 0) -- Hijau untuk ON
    
    local char = player.Character
    if not char then 
        warn("Karakter belum dimuat!") 
        return 
    end

    -- Hubungkan fungsi onPartTouched ke semua bagian tubuh karakter
    for _, part in ipairs(char:GetChildren()) do
        if part:IsA("BasePart") then
            -- Putuskan koneksi yang mungkin sudah ada sebelumnya untuk menghindari duplikasi
            if touchConnection then touchConnection:Disconnect() end 
            
            -- Koneksi Touch hanya perlu dibuat sekali pada salah satu bagian tubuh (misal: HumanoidRootPart)
            if part.Name == "HumanoidRootPart" then
                 touchConnection = part.Touched:Connect(onPartTouched)
            end
        end
    end
    print("Phantom Touch Dinyalakan.")
end

local function disablePhantomTouch()
    isPhantomTouchActive = false
    buttonPhantom.Text = "PHANTOM TOUCH: OFF"
    buttonPhantom.BackgroundColor3 = Color3.fromRGB(40, 40, 40) -- Abu-abu untuk OFF
    
    -- Putuskan koneksi sentuhan
    if touchConnection then
        touchConnection:Disconnect()
        touchConnection = nil
    end
    
    -- Membersihkan daftar part yang telah disentuh (optional, tapi baik)
    partsTouched = {}
    print("Phantom Touch Dimatikan.")
end

buttonPhantom.MouseButton1Click:Connect(function()
    if isPhantomTouchActive then
        disablePhantomTouch()
    else
        enablePhantomTouch()
    end
end)

-- Pastikan koneksi diaktifkan kembali jika karakter mati/respawn (Wajib untuk LocalScript)
player.CharacterAdded:Connect(function(char)
    if isPhantomTouchActive then
        -- Tunggu HumanoidRootPart muncul lalu hubungkan kembali
        local root = char:WaitForChild("HumanoidRootPart")
        if root and touchConnection then
            -- Putuskan koneksi lama (jika ada) dan buat koneksi baru
            touchConnection:Disconnect()
            touchConnection = root.Touched:Connect(onPartTouched)
        elseif root and not touchConnection then
            -- Jika sedang ON tapi koneksi hilang (misal saat skrip pertama kali jalan), buat koneksi
             touchConnection = root.Touched:Connect(onPartTouched)
        end
    end
end)

-- 🔽 Fungsi "Meniru Pemain" dan Logika Player List (Tidak Berubah) 🔽
-- ... (Fungsi makePlayerButton, populatePlayerList, dan Logika flagButton.MouseButton1Click tetap sama) ...
-- ... (Diletakkan di sini dalam kode lengkap) ...

-- 🔽 Logika Tombol Samping (Toggle Player List)
flagButton.MouseButton1Click:Connect(function()
    sideFrame.Visible = not sideFrame.Visible
    if sideFrame.Visible then
        populatePlayerList()
    end
end)

-- 🔽 Logika Tombol RESET 🔽
buttonReset.MouseButton1Click:Connect(function()
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

-- [Sisipan Fungsi makePlayerButton dan populatePlayerList di sini]

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
        for _, obj in ipairs(char:GetChildren()) do
            if obj:IsA("Accessory") or obj:IsA("Shirt") or obj:IsA("Pants") then
                obj:Destroy()
            end
        end

        for _, obj in ipairs(targetChar:GetChildren()) do
            if obj:IsA("Accessory") or obj:IsA("Shirt") or obj:IsA("Pants") then
                local clone = obj:Clone()
                clone.Parent = char
            end
        end

        -- 2. STATS DAN LOKASI
        local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
        local playerRoot = char:FindFirstChild("HumanoidRootPart")
        
        playerHumanoid.WalkSpeed = targetHumanoid.WalkSpeed
        playerHumanoid.JumpPower = targetHumanoid.JumpPower
        
        if targetRoot and playerRoot then
            playerRoot.CFrame = targetRoot.CFrame
        end

        print("Meniru properti dari: " .. targetPlayer.Name)
    end)
end

local function populatePlayerList()
    for _, child in ipairs(scrollFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    local playerList = Players:GetPlayers()
    table.sort(playerList, function(a, b)
        return a.Name < b.Name
    end)

    for _, target in ipairs(playerList) do
        makePlayerButton(target)
    end
end
