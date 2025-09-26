-- credit: Xraxor1 (Original GUI/Intro structure)
-- Modification for List-based GUI, Impersonate Player & Phantom Touch: [AI Assistant]

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService") 

local player = Players.LocalPlayer

-- Status untuk fitur Phantom Touch
local isPhantomTouchActive = false
local touchConnection = nil
local partsTouched = {} -- Tabel untuk melacak part yang telah disentuh

-- 🔽 STATUS FITUR BARU 🔽
local isKeepAvatarActive = false -- Status untuk fitur Jaga-Avatar
local isFollowingPlayer = false -- Status untuk fitur Gendong/Ikuti
local currentTargetPlayer = nil -- Pemain yang sedang diikuti
local followConnection = nil -- Koneksi untuk loop following (RunService)
local phantomTouchButtonReference = nil -- Referensi untuk tombol Phantom Touch di sidebar

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

-- 🔽 GUI Utama (List Menu) 🔽
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ImpersonateGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
-- Ukuran Frame disesuaikan karena Phantom Touch dipindah
frame.Size = UDim2.new(0, 220, 0, 180) 
frame.Position = UDim2.new(0.4, -110, 0.5, -90)
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

-- Sesuaikan CanvasSize saat item ditambahkan
featureListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    featureScrollFrame.CanvasSize = UDim2.new(0, 0, 0, featureListLayout.AbsoluteContentSize.Y + 10)
end)


-- 🔽 FUNGSI JAGA AVATAR 🔽

local function updateKeepAvatarButton(button)
    if isKeepAvatarActive then
        button.Text = "JAGA AVATAR: ON (Anti-Reset)"
        button.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
    else
        button.Text = "JAGA AVATAR: OFF"
        button.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    end
end

local function toggleKeepAvatar(button)
    isKeepAvatarActive = not isKeepAvatarActive
    -- Mencegah klien menjalankan ulang CharacterAdded event secara default
    player.CharacterAdded:SetScriptable(isKeepAvatarActive) 
    updateKeepAvatarButton(button)
    print("Jaga Avatar: " .. (isKeepAvatarActive and "Aktif" or "Tidak Aktif"))
end

-- 🔽 FUNGSI PHANTOM TOUCH 🔽

local function onPartTouched(otherPart)
    if not isPhantomTouchActive or not otherPart or not otherPart:IsA("BasePart") then return end
    if otherPart:IsDescendantOf(player.Character) or otherPart.Parent:IsA("Accessory") or partsTouched[otherPart] then return end

    otherPart.Transparency = 1
    otherPart.CanCollide = false
    
    partsTouched[otherPart] = true
    print("Phantom Touched: " .. otherPart.Name .. " menghilang.")
end

local function updatePhantomButton(button)
    if not button then return end
    if isPhantomTouchActive then
        button.Text = "PHANTOM TOUCH: ON (Hapus Part)"
        button.BackgroundColor3 = Color3.fromRGB(0, 180, 0) -- Hijau untuk ON
    else
        button.Text = "PHANTOM TOUCH: OFF"
        button.BackgroundColor3 = Color3.fromRGB(150, 0, 0) -- Merah untuk OFF
    end
end

local function enablePhantomTouch(button)
    isPhantomTouchActive = true
    updatePhantomButton(button)
    
    local char = player.Character or player.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    
    if touchConnection then touchConnection:Disconnect() end
    touchConnection = root.Touched:Connect(onPartTouched)
    
    print("Phantom Touch Dinyalakan.")
}

local function disablePhantomTouch(button)
    isPhantomTouchActive = false
    updatePhantomButton(button)
    
    if touchConnection then
        touchConnection:Disconnect()
        touchConnection = nil
    end
    
    partsTouched = {}
    print("Phantom Touch Dimatikan.")
end

-- Listener CharacterAdded untuk mengaktifkan kembali Touch
player.CharacterAdded:Connect(function(char)
    if isPhantomTouchActive and phantomTouchButtonReference then
        enablePhantomTouch(phantomTouchButtonReference)
    end
end)


-- 🔽 FUNGSI TELEPORT & FOLLOW (GENDONG) 🔽

local function stopFollowing(targetPlayer, button)
    isFollowingPlayer = false
    currentTargetPlayer = nil
    
    if followConnection then
        followConnection:Disconnect()
        followConnection = nil
    end
    
    if button then
        button.Text = "IKUTI PEMAIN: OFF"
        button.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    end
    
    print("Berhenti mengikuti: " .. (targetPlayer and targetPlayer.Name or "Pemain tidak diketahui"))
end

local function startFollowing(targetPlayer, button)
    local char = player.Character
    local targetChar = targetPlayer.Character
    
    if not char or not targetChar then 
        warn("Karakter tidak ditemukan, tidak bisa mulai mengikuti.") 
        stopFollowing(targetPlayer, button)
        return 
    end
    
    local playerRoot = char:FindFirstChild("HumanoidRootPart")
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")

    if not playerRoot or not targetRoot then
        warn("HumanoidRootPart tidak ditemukan.")
        stopFollowing(targetPlayer, button)
        return
    end

    -- 1. TELEPORT ke target
    -- CFrame.new(0, 3, 0) menempatkan pemain di atas kepala target (efek gendong)
    playerRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 3, 0) 
    
    -- 2. SETUP FOLLOWING 
    isFollowingPlayer = true
    currentTargetPlayer = targetPlayer

    if followConnection then followConnection:Disconnect() end
    -- Menggunakan Heartbeat untuk pergerakan halus
    followConnection = RunService.Heartbeat:Connect(function()
        if not isFollowingPlayer or not currentTargetPlayer or not currentTargetPlayer.Character then
            stopFollowing(currentTargetPlayer, button)
            return
        end
        
        local currentTargetRoot = currentTargetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if currentTargetRoot and playerRoot then
            -- Memperbarui CFrame pemain setiap frame
            playerRoot.CFrame = currentTargetRoot.CFrame * CFrame.new(0, 3, 0)
        else
            stopFollowing(currentTargetPlayer, button)
        end
    end)
    
    if button then
        button.Text = "IKUTI PEMAIN: ON (" .. targetPlayer.Name .. ")"
        button.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
    end

    print("Mulai mengikuti dan digendong oleh: " .. targetPlayer.Name)
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

-- Tombol RESET
makeFeatureButton("RESET AVATAR & STATS", Color3.fromRGB(150, 0, 0), function(button)
    local success, err = pcall(function()
        player:LoadCharacter()
    end)

    if success then
        player.Character:WaitForChild("Humanoid").WalkSpeed = 16
        player.Character:WaitForChild("Humanoid").JumpPower = 50
    end
    print("Karakter berhasil di-reset.")
end)

-- Tombol JAGA AVATAR
local keepAvatarButton = makeFeatureButton("JAGA AVATAR: OFF", Color3.fromRGB(150, 0, 0), function(button)
    toggleKeepAvatar(button)
end)
updateKeepAvatarButton(keepAvatarButton)

-- Tombol IKUTI PEMAIN (Hanya untuk Matikan Status Follow)
local followButton = makeFeatureButton("IKUTI PEMAIN: OFF", Color3.fromRGB(150, 0, 0), function(button)
    if isFollowingPlayer then
        stopFollowing(currentTargetPlayer, button)
    else
        warn("Pilih pemain dari daftar samping untuk mulai mengikuti.")
    end
end)


-- 🔽 GUI Samping Player List 🔽
local flagButton = Instance.new("ImageButton")
flagButton.Size = UDim2.new(0, 20, 0, 20)
flagButton.Position = UDim2.new(1, -30, 0, 5)
flagButton.BackgroundTransparency = 1
flagButton.Image = "rbxassetid://6031097229" 
flagButton.Parent = frame

local sideFrame = Instance.new("Frame")
sideFrame.Size = UDim2.new(0, 170, 0, 300) -- Ditinggikan untuk tombol tambahan
sideFrame.Position = UDim2.new(1, 10, 0, 0)
sideFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
sideFrame.Visible = false
sideFrame.Parent = frame

local sideCorner = Instance.new("UICorner")
sideCorner.CornerRadius = UDim.new(0, 12)
sideCorner.Parent = sideFrame

-- Judul Daftar Pemain
local sideTitle = Instance.new("TextLabel")
sideTitle.Size = UDim2.new(1, 0, 0, 25)
sideTitle.BackgroundTransparency = 1
sideTitle.Text = "PLAYER LIST & EXTRAS"
sideTitle.TextColor3 = Color3.new(1, 1, 1)
sideTitle.Font = Enum.Font.GothamBold
sideTitle.TextSize = 14
sideTitle.Parent = sideFrame

-- 🔽 TOMBOL PHANTOM TOUCH (DIPINDAH KE SINI) 🔽
phantomTouchButtonReference = Instance.new("TextButton")
phantomTouchButtonReference.Name = "PhantomTouchButton"
phantomTouchButtonReference.Size = UDim2.new(0, 150, 0, 30)
phantomTouchButtonReference.Position = UDim2.new(0.5, -75, 0, 30)
phantomTouchButtonReference.Font = Enum.Font.SourceSansBold
phantomTouchButtonReference.TextSize = 12
phantomTouchButtonReference.TextColor3 = Color3.new(1, 1, 1)
phantomTouchButtonReference.Parent = sideFrame

local phantomCorner = Instance.new("UICorner")
phantomCorner.CornerRadius = UDim.new(0, 8)
phantomCorner.Parent = phantomTouchButtonReference

updatePhantomButton(phantomTouchButtonReference) -- Atur status awal

phantomTouchButtonReference.MouseButton1Click:Connect(function()
    if isPhantomTouchActive then
        disablePhantomTouch(phantomTouchButtonReference)
    else
        enablePhantomTouch(phantomTouchButtonReference)
    end
end)

-- ScrollingFrame untuk Daftar Pilihan Pemain
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "PlayerScroll"
scrollFrame.Size = UDim2.new(1, 0, 1, -65) -- Disesuaikan agar tidak menimpa tombol PT
scrollFrame.Position = UDim2.new(0, 0, 0, 60)
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

-- 🔽 Logika Impersonate Player & GENDONG/IKUTI 🔽

local function makePlayerButton(targetPlayer)
    local tpButton = Instance.new("TextButton")
    tpButton.Size = UDim2.new(0, 140, 0, 30)
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
        
        -- Cek apakah pemain yang sama dipilih dan sedang diikuti, hentikan follow
        if targetPlayer == currentTargetPlayer and isFollowingPlayer then
            stopFollowing(targetPlayer, followButton)
            return
        elseif targetPlayer ~= player then
            -- Jika pemain lain dipilih: Teleport dan Mulai Follow
            startFollowing(targetPlayer, followButton)
            
            -- Panggil juga logika Impersonate (jika ingin mengganti avatar target saat digendong)
            local char = player.Character
            local targetChar = targetPlayer.Character

            if not char or not targetChar then warn("Karakter tidak ditemukan!") return end
            
            -- CLONING KOSTUM/AKSESORIS
            for _, obj in ipairs(char:GetChildren()) do
                if obj:IsA("Accessory") or obj:IsA("Shirt") or obj:IsA("Pants") then obj:Destroy() end
            end
            for _, obj in ipairs(targetChar:GetChildren()) do
                if obj:IsA("Accessory") or obj:IsA("Shirt") or obj:IsA("Pants") then
                    local clone = obj:Clone()
                    clone.Parent = char
                end
            end
            
            print("Meniru properti dari: " .. targetPlayer.Name)
        end
        
    end)
end

local function populatePlayerList()
    -- Hapus tombol lama
    for _, child in ipairs(scrollFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    local playerList = Players:GetPlayers()
    table.sort(playerList, function(a, b) return a.Name < b.Name end)

    -- Buat tombol baru untuk setiap pemain
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
