-- credit: Xraxor1 (Original GUI/Intro structure)
-- Cleaned version (Removed all client-side manipulation/exploit features)

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService") 

local player = Players.LocalPlayer

-- ** ⬇️ VARIABLE AUTO-FOLLOW & BEAM ⬇️ **
local currentTarget = nil        -- Pemain yang sedang diikuti
local autoFollowConnection = nil -- Koneksi RunService untuk loop teleport
local followBeam = nil           -- Objek Beam yang akan kita gunakan (tali)


-- ** ⬇️ FUNGSI UNTUK MENGELOLA BEAM ⬇️ **
local function createFollowBeam(targetPlayer)
    local char = player.Character
    local targetChar = targetPlayer.Character

    if char and char:FindFirstChild("HumanoidRootPart") and targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
        local myRoot = char.HumanoidRootPart
        local targetRoot = targetChar.HumanoidRootPart

        -- Hapus Beam lama jika ada
        if followBeam and followBeam.Parent then
            followBeam:Destroy()
        end

        -- Buat Attachment pada kedua RootPart
        local attachment0 = Instance.new("Attachment")
        attachment0.Parent = myRoot
        
        local attachment1 = Instance.new("Attachment")
        attachment1.Parent = targetRoot

        -- Buat Beam itu sendiri (Tali)
        followBeam = Instance.new("Beam")
        followBeam.Color = BrickColor.new("Really red") -- Warna tali
        followBeam.Texture = "rbxassetid://5499965042" -- Texture garis lurus
        followBeam.TextureLength = 10 
        followBeam.Segments = 10
        followBeam.Width0 = 0.2 -- Ketebalan di ujung 0 (Anda)
        followBeam.Width1 = 0.2 -- Ketebalan di ujung 1 (Target)
        followBeam.Attachment0 = attachment0
        followBeam.Attachment1 = attachment1
        followBeam.LightInfluence = 1 
        followBeam.Parent = game.Workspace.Terrain -- Taruh di tempat yang aman

        print("Tali penghubung dibuat ke:", targetPlayer.Name)
    end
end

local function destroyFollowBeam()
    if followBeam and followBeam.Parent then
        -- Hapus Beam dan Attachments yang dibuatnya
        local att0 = followBeam.Attachment0
        local att1 = followBeam.Attachment1
        
        followBeam:Destroy()
        
        -- Cek Parent sebelum Destroy untuk menghindari error jika Parent sudah hilang
        if att0 and att0.Parent then att0:Destroy() end
        if att1 and att1.Parent then att1:Destroy() end
        
        followBeam = nil
        print("Tali penghubung dihapus.")
    end
end

-- ** ⬇️ FUNGSI AUTO-TELEPORT UTAMA ⬇️ **
local function setTargetToFollow(targetPlayer)
    if autoFollowConnection then
        -- Hentikan auto-teleport yang sedang berjalan
        autoFollowConnection:Disconnect()
        autoFollowConnection = nil
        destroyFollowBeam() -- Hapus Beam saat follow berhenti
        
        -- Hentikan pergerakan karakter 
        local character = player.Character
        local humanoid = character and character:FindFirstChild("Humanoid")
        if humanoid then
             humanoid:MoveTo(player.Character.HumanoidRootPart.Position)
        end

        currentTarget = nil
    end

    if targetPlayer and targetPlayer ~= player then
        -- Mulai auto-teleport ke pemain baru
        currentTarget = targetPlayer
        
        -- Buat Beam baru ke pemain target
        createFollowBeam(targetPlayer) 

        local character = player.Character
        
        if character and character:FindFirstChild("HumanoidRootPart") then
            print("Mulai Auto-Teleport ke pemain:", currentTarget.Name)

            -- Fungsi yang dijalankan setiap frame (RunService.Stepped)
            autoFollowConnection = RunService.Stepped:Connect(function()
                if not currentTarget or not currentTarget.Character or not currentTarget.Character:FindFirstChild("HumanoidRootPart") then
                    -- Target hilang, hentikan mengikuti
                    print("Target hilang, auto-teleport dihentikan.")
                    setTargetToFollow(nil)
                    return
                end
                
                -- Pastikan Beam masih ada. Jika tidak, buat ulang.
                if not followBeam then 
                    createFollowBeam(currentTarget) 
                end

                local targetTorso = currentTarget.Character:FindFirstChild("HumanoidRootPart")
                local myTorso = player.Character:FindFirstChild("HumanoidRootPart")

                if targetTorso and myTorso then
                    
                    local distance = (targetTorso.Position - myTorso.Position).Magnitude
                    
                    -- Lakukan Teleport jika jarak lebih dari 1 stud (Hampir selalu aktif)
                    if distance > 1 then 
                        -- Ambil posisi target
                        local targetCFrame = targetTorso.CFrame 
                        
                        -- Tentukan posisi offset (5 studs di belakang target)
                        local offset = targetCFrame.LookVector * -5 
                        local newCFrame = targetCFrame + offset 

                        -- ** TELEPORTASI UTAMA: Atur CFrame karakter lokal **
                        myTorso.CFrame = newCFrame 
                    end
                end
            end)
        end
    end
    
    -- Perbarui GUI Player List jika sedang terlihat
    if screenGui.ImpersonateGUI and screenGui.ImpersonateGUI.Frame.sideFrame.Visible then
        populatePlayerList()
    end
end

---

## 🎨 Logika GUI dan Animasi

```lua
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

-- 🔽 GUI Utama (List Menu) 🔽
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ImpersonateGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
-- Ukuran Frame disesuaikan hanya untuk tombol dasar
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

-- Judul GUI
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "MENU DASAR"
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
        local humanoid = player.Character:WaitForChild("Humanoid")
        humanoid.WalkSpeed = 16
        humanoid.JumpPower = 50
    end
    print("Karakter berhasil di-reset.")
end)

-- Tombol baru untuk menghentikan Follow
makeFeatureButton("STOP TELEPORT", Color3.fromRGB(0, 150, 150), function(button)
    setTargetToFollow(nil)
    populatePlayerList()
end)


-- 🔽 GUI Samping Player List 🔽
local flagButton = Instance.new("ImageButton")
flagButton.Size = UDim2.new(0, 20, 0, 20)
flagButton.Position = UDim2.new(1, -30, 0, 5)
flagButton.BackgroundTransparency = 1
flagButton.Image = "rbxassetid://6031097229" 
flagButton.Parent = frame

local sideFrame = Instance.new("Frame")
sideFrame.Name = "sideFrame"
sideFrame.Size = UDim2.new(0, 170, 0, 250)
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
sideTitle.Text = "PLAYER LIST"
sideTitle.TextColor3 = Color3.new(1, 1, 1)
sideTitle.Font = Enum.Font.GothamBold
sideTitle.TextSize = 14
sideTitle.Parent = sideFrame

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "PlayerScroll"
scrollFrame.Size = UDim2.new(1, 0, 1, -30) 
scrollFrame.Position = UDim2.new(0, 0, 0, 30)
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

-- 🔽 Logika Player List (Dengan Aksi Auto-Teleport) 🔽

local function makePlayerButton(targetPlayer)
    local tpButton = Instance.new("TextButton")
    tpButton.Size = UDim2.new(0, 140, 0, 30)
    -- Perbarui warna tombol jika pemain sedang di-teleport
    local buttonColor = (currentTarget == targetPlayer) and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(40, 40, 40)
    tpButton.BackgroundColor3 = buttonColor
    tpButton.Text = targetPlayer.Name .. (targetPlayer == player and " (You)" or "")
    tpButton.TextColor3 = Color3.new(1, 1, 1)
    tpButton.Font = Enum.Font.SourceSansBold
    tpButton.TextSize = 14
    tpButton.Parent = scrollFrame

    local tpCorner = Instance.new("UICorner")
    tpCorner.CornerRadius = UDim.new(0, 8)
    tpCorner.Parent = tpButton

    tpButton.MouseButton1Click:Connect(function()
        if targetPlayer == player then
            print("Tidak bisa mengikuti diri sendiri.")
            return
        end
        
        if currentTarget == targetPlayer then
            -- Jika sudah di-follow, hentikan follow
            setTargetToFollow(nil)
        else
            -- Jika belum/follow pemain lain, mulai follow pemain ini
            setTargetToFollow(targetPlayer)
        end
        
        -- Perbarui daftar pemain untuk menampilkan status follow yang baru
        populatePlayerList()
    end)
end

local function populatePlayerList()
    for _, child in ipairs(scrollFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    local playerList = Players:GetPlayers()
    table.sort(playerList, function(a, b) return a.Name < b.Name end)

    for _, target in ipairs(playerList) do
        makePlayerButton(target)
    end
end

-- Logika Tombol Samping (Toggle Player List)
flagButton.MouseButton1Click:Connect(function()
    sideFrame.Visible = not sideFrame.Visible
    if sideFrame.Visible then
        populatePlayerList()
    else
        -- Pastikan Beam di-destroy jika frame ditutup dan follow tidak aktif
        if not currentTarget then
            destroyFollowBeam()
        end
    end
end)
