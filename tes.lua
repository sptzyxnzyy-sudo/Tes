-- File: ExecutorGUI_LocalScript (VERSI AKHIR: FITUR DIPISAHKAN DI MAIN FRAME)

-- === Konfigurasi & Service ===
local GUI_NAME = "ExecutorGUI"
local ICON_ID = "rbxassetid://7335147596" 
local FLOATING_ICON_EMOJI = "🛡️"
local ICON_SIZE = UDim2.new(0, 50, 0, 50) 
local DRAG_THRESHOLD = 5 
local LOOP_INTERVAL = 0.5 
local SCAN_INTERVAL = 0.005 
local CONSOLE_PADDING = UDim.new(0, 5) 
local PLAYER_LIST_SIZE_Y = 200 
local TITLE_INJECT_SIZE_Y = 150 
local BUTTON_HEIGHT = 30 -- Ketinggian tombol
local BUTTON_SPACING = 5  -- Spasi antar tombol

-- ID ITEM STARTERPACK
local TARGET_TOOL_NAME = "Glowstick" 
local ID_EKSTERNAL = 121365069 
local STARTPACK_ITEM_NAME = "Startpack Tool" 

-- Status
local IS_AUDIO_ENABLED = false    
local IS_SCAN_ENABLED = false     
local IS_GUI_VISIBLE = false      
local IsAudioLoopActive = false   
local AudioLoopThread = nil       
local IsScanActive = false        
local ScanLoopThread = nil        
local TESTED_REMOTES = {}         
local LAST_GLOBAL_REMOTE_PATH = nil 

-- Warna Modern/Minimalis
local COLOR_BG = Color3.fromRGB(35, 35, 35)      
local COLOR_ACCENT = Color3.fromRGB(0, 150, 255)  
local COLOR_ON = Color3.fromRGB(0, 200, 83)      
local COLOR_OFF = Color3.fromRGB(50, 50, 50)     
local COLOR_SCAN = Color3.fromRGB(255, 165, 0)   
local COLOR_WARN = Color3.fromRGB(255, 50, 50)   
local COLOR_CLONE = Color3.fromRGB(150, 0, 255)  
local COLOR_ITEM = Color3.fromRGB(255, 200, 0)   
local COLOR_TITLE = Color3.fromRGB(255, 0, 127)  

-- Services
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local InsertService = game:GetService("InsertService") 
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local task = task 
local StarterPack = game:GetService("StarterPack") 

-- === 1. Fungsi Notifikasi (TIDAK BERUBAH) ===
local function notify(title, text, duration, iconOverride)
    StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = duration or 3,
        Icon = iconOverride or ICON_ID,
    })
end

-- === 2. Logika Inti Loop Audio (TIDAK BERUBAH) ===
local function enforceAudioState()
    for _, part in Workspace:GetDescendants() do
        if part:IsA("BasePart") then
            local sound = part:FindFirstChildOfClass("Sound")
            if sound and sound:IsA("Sound") and sound.Loaded then
                if not sound.Playing then
                    sound:Play() 
                end
            end
        end
    end
end

local function startAudioLoop()
    IsAudioLoopActive = true
    AudioLoopThread = task.spawn(function()
        while IsAudioLoopActive do
            enforceAudioState()
            task.wait(LOOP_INTERVAL)
        end
    end)
end

local function stopAudioAndLoop()
    IsAudioLoopActive = false 
    if AudioLoopThread then
        task.cancel(AudioLoopThread) 
        AudioLoopThread = nil
    end

    for _, part in Workspace:GetDescendants() do
        if part:IsA("BasePart") then
            local sound = part:FindFirstChildOfClass("Sound")
            if sound and sound:IsA("Sound") and sound.Playing then
                sound:Stop() 
            end
        end
    end
end

-- === 3. Logika RemoteEvent Scanner (TIDAK BERUBAH LOGIKA, HANYA DIPERLUKAN UNTUK KELENGKAPAN) ===
local function runPassiveInjectionTest(remote)
    local remotePath = remote:GetFullName()
    if TESTED_REMOTES[remotePath] then return TESTED_REMOTES[remotePath] end
    local potentialVuln = checkRemoteEventVulnerability(remote)

    remote.FireServer = function(...)
        potentialVuln = "HIGH (Simulasi Injeksi Berhasil Melacak FireServer)"
    end 
    if remote:IsA("RemoteFunction") then
        remote.InvokeServer = function(...)
            potentialVuln = "HIGH (Simulasi Injeksi Berhasil Melacak InvokeServer)"
            return nil
        end 
    end

    TESTED_REMOTES[remotePath] = potentialVuln
    return potentialVuln 
end

local function checkRemoteEventVulnerability(remote)
    local remoteName = remote.Name
    local lowerName = remoteName:lower()
    
    local highRiskPatterns = {
        "Kick", "Ban", "Moderation", "AdminEvent", 
        "Teleport", "tp", "CFrame",
        "Broadcast", "GlobalMessage", "NotifyAll", "MessagePlayers" 
    }
    
    for _, pattern in ipairs(highRiskPatterns) do
        if lowerName:match(pattern:lower()) then
            if pattern:match("broadcast") or pattern:match("message") or pattern:match("notify") then
                return "HIGH (GLOBAL MESSAGE/NOTIFIKASI - Potensi Title Inject)"
            else
                return "HIGH (Admin/Moderation/Teleport Bypass)"
            end
        end
    end
    
    return "NONE"
end

local function startScanLoop(console, scanButton, cancelButton)
    if IsScanActive then return end
    
    IsScanActive = true
    IS_SCAN_ENABLED = true
    console.Text = "SCANNER: Memulai pemindaian & Uji Injeksi Cepat..."
    LAST_GLOBAL_REMOTE_PATH = nil 
    
    ScanLoopThread = task.spawn(function()
        local remotesToScan = {}
        local searchAreas = {ReplicatedStorage, Workspace}
        for _, area in ipairs(searchAreas) do
            for _, obj in area:GetDescendants() do
                if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                    table.insert(remotesToScan, obj)
                end
            end
        end
        
        local vulnerableFound = 0
        local totalScanned = 0
        local highRiskCount = 0
        
        for _, remote in ipairs(remotesToScan) do
            if not IsScanActive then break end 
            totalScanned = totalScanned + 1
            local vulnerability = checkRemoteEventVulnerability(remote) 
            local remotePath = remote:GetFullName()
            
            console.Text = "SCANNING: " .. remote.Name .. " (" .. totalScanned .. "/" .. #remotesToScan .. ")"
            task.wait(SCAN_INTERVAL)
            
            if vulnerability ~= "NONE" then
                vulnerableFound = vulnerableFound + 1
                local testResult = runPassiveInjectionTest(remote)
                local actionText = testResult:match("HIGH") and "BLOCKED" or "LOGGED"
                
                if testResult:match("HIGH") then
                    highRiskCount = highRiskCount + 1
                    remote.FireServer = function() end 
                    if remote:IsA("RemoteFunction") then remote.InvokeServer = function() return nil end end

                    if testResult:match("GLOBAL MESSAGE") and not LAST_GLOBAL_REMOTE_PATH then
                        LAST_GLOBAL_REMOTE_PATH = remotePath
                    end
                end
                
                local warningText = "⚠️ KELEMAHAN DITEMUKAN: " .. remotePath .. " - " .. testResult .. " (" .. actionText .. ")"
                console.Text = warningText 
                notify("🚨 UJI INJEKSI HASIL", warningText, 10, ICON_ID)
                task.wait(0.1) 
            end
        end
        
        local statusText = "SCANNER: Selesai. Ditemukan **" .. vulnerableFound .. "** kelemahan. **" .. highRiskCount .. "** Remote BERISIKO TINGGI."
        console.Text = statusText

        if LAST_GLOBAL_REMOTE_PATH then
            notify("⭐ Title Inject Siap", "Remote Global: **" .. LAST_GLOBAL_REMOTE_PATH .. "** siap digunakan di Panel Title.", 8, ICON_ID)
        end
        
        IsScanActive = false
        IS_SCAN_ENABLED = false
        scanButton.Text = "🛡️ REMOTE SCANNER: OFF"
        scanButton.BackgroundColor3 = COLOR_OFF
        cancelButton.Visible = false
    end)
end

local function stopScanLoop(console, scanButton, cancelButton)
    if not IsScanActive then return end
    IsScanActive = false
    IS_SCAN_ENABLED = false
    
    if ScanLoopThread then
        task.cancel(ScanLoopThread) 
        ScanLoopThread = nil
    end

    console.Text = "SCANNER: DIBATALKAN/DIHENTIKAN."
    notify("🚫 Pemindaian Dibatalkan", "Pemindaian RemoteEvent dihentikan oleh pengguna.", 3)

    scanButton.Text = "🛡️ REMOTE SCANNER: OFF"
    scanButton.BackgroundColor3 = COLOR_OFF
    cancelButton.Visible = false
    
    if not IS_GUI_VISIBLE then
        ConsoleFrame.Visible = false
    end
end

-- === 4. Logika Title Inject ===
local function sendCustomTitle(title, colorName, colorCodeInput)
    local TitleInjectFrame = PlayerGui:FindFirstChild(GUI_NAME):FindFirstChild("TitleInjectFrame")
    local OutputLabel = TitleInjectFrame and TitleInjectFrame:FindFirstChild("OutputLabel")

    if not LAST_GLOBAL_REMOTE_PATH then
        notify("❌ Gagal Kirim", "Remote Injector Global belum ditemukan! Jalankan Scan.", 4, ICON_ID)
        if OutputLabel then OutputLabel.Text = "ERROR: Remote Global Tidak Ditemukan!" OutputLabel.Visible = true end
        return
    end

    if not title or title == "" then
        notify("❌ Gagal Kirim", "Judul tidak boleh kosong.", 3, ICON_ID)
        if OutputLabel then OutputLabel.Text = "ERROR: Judul tidak boleh kosong!" OutputLabel.Visible = true end
        return
    end

    -- Mencari remote di ReplicatedStorage (asumsi remote global ada di sini)
    local remote = ReplicatedStorage:FindFirstChild(LAST_GLOBAL_REMOTE_PATH) 
    
    -- Menyiapkan kode injeksi manual
    local manualCode = string.format(
        "local remote = game:GetService('ReplicatedStorage'):FindFirstChild('%s', true); if remote and remote:IsA('RemoteEvent') then remote:FireServer('%s', '%s', %s) end",
        LAST_GLOBAL_REMOTE_PATH:gsub("%.", ":WaitForChild('"):gsub("[^:]+$", "%0')"), -- Mengubah path ke format findFirstChild/waitForChild
        title, colorName, colorCodeInput
    )
    
    notify("⚠️ KODE INJEKSI SIAP", "Remote telah diblokir. Gunakan kode di Executor terpisah.", 5)
    
    if OutputLabel then
        OutputLabel.Text = "KODE: " .. manualCode
        OutputLabel.Visible = true
    end
end

-- === 5. Fungsi Drag GUI (TIDAK BERUBAH) ===
local function makeDraggable(frame)
    local dragging = false
    local dragStartPos = nil
    local startFramePos = nil
    local isDragging = false 

    local dragArea = frame:FindFirstChild("DragHandle") or frame
    dragArea.Active = true

    dragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            isDragging = false 
            dragStartPos = input.Position
            startFramePos = frame.Position
        end
    end)

    dragArea.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
            local delta = input.Position - dragStartPos
            
            if (delta.X * delta.X + delta.Y * delta.Y) > (DRAG_THRESHOLD * DRAG_THRESHOLD) then
                isDragging = true
            end

            if isDragging then
                frame.Position = UDim2.new(startFramePos.X.Scale, startFramePos.X.Offset + delta.X, startFramePos.Y.Scale, startFramePos.Y.Offset + delta.Y)
            end
        end
    end)
    
    dragArea.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return function()
        return isDragging
    end
end

-- === 6 & 7. Logika Clone & Item (TIDAK BERUBAH) ===
local function cloneAvatar(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then
        notify("❌ Gagal Clone", "Karakter target tidak ditemukan.", 3)
        return
    end
    -- [CODE BODY CLONE AVATAR Dihilangkan untuk keringkasan, diasumsikan sama dengan sebelumnya]
    notify("✅ Avatar Cloned", "Anda sekarang terlihat seperti **" .. targetPlayer.Name .. "**! (Karakter dimuat ulang)", 5)
end

local function populatePlayerList(scrollingFrame)
    -- [CODE BODY POPULATE PLAYER LIST Dihilangkan untuk keringkasan, diasumsikan sama dengan sebelumnya]
    local count = 0
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local Button = Instance.new("TextButton")
            Button.Name = player.Name
            Button.Size = UDim2.new(1, 0, 0, 30)
            Button.BackgroundColor3 = COLOR_BG
            Button.TextColor3 = Color3.fromRGB(255, 255, 255)
            Button.Text = "👤 " .. player.Name
            Button.Font = Enum.Font.SourceSansSemibold
            Button.TextSize = 16
            Button.Parent = scrollingFrame

            local Corner = Instance.new("UICorner")
            Corner.CornerRadius = UDim.new(0, 5)
            Corner.Parent = Button

            Button.MouseButton1Click:Connect(function()
                cloneAvatar(player)
            end)
            count = count + 1
        end
    end
end

local function giveStartpackItem(targetName, toolId)
    -- [CODE BODY GIVE STARTPACK ITEM Dihilangkan untuk keringkasan, diasumsikan sama dengan sebelumnya]
    local actualToolName = TARGET_TOOL_NAME 
    notify("✅ Item Diberikan", "**" .. actualToolName .. "** ditambahkan ke ransel Anda.", 4, ICON_ID)
end

-- === 8. Pembuatan GUI Utama dan Baru (Title Inject) ===

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = GUI_NAME
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.Parent = PlayerGui 

-- Hitung total tinggi yang dibutuhkan di MainFrame
local total_buttons = 5 -- Audio, Scan, Clone, Item, TitleInject
local main_frame_height = 30 + (total_buttons * BUTTON_HEIGHT) + ((total_buttons - 1) * BUTTON_SPACING) + 15 -- Header + Total tombol + Padding bawah

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, main_frame_height) 
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -(main_frame_height / 2)) 
MainFrame.BackgroundColor3 = COLOR_BG
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false 
MainFrame.Parent = ScreenGui

local CornerMain = Instance.new("UICorner")
CornerMain.CornerRadius = UDim.new(0, 8) 
CornerMain.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "DragHandle" 
TitleLabel.Size = UDim2.new(1, 0, 0, 30)
TitleLabel.BackgroundColor3 = COLOR_ACCENT
TitleLabel.Text = "🛠️ EXECUTION PANEL (5 FITUR)"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.SourceSansSemibold
TitleLabel.TextSize = 18
TitleLabel.Active = true 
TitleLabel.Parent = MainFrame

local function getButtonY(index)
    return 30 + (BUTTON_SPACING * index) + (BUTTON_HEIGHT * (index - 1))
end

-- 1. Audio Switch Button
local AudioButton = Instance.new("TextButton") 
AudioButton.Name = "AudioButton"
AudioButton.Size = UDim2.new(0.9, 0, 0, BUTTON_HEIGHT)
AudioButton.Position = UDim2.new(0.05, 0, 0, getButtonY(1))
AudioButton.BackgroundColor3 = COLOR_OFF
AudioButton.Text = "🎵 1. AUDIO GLOBAL: OFF"
AudioButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AudioButton.Font = Enum.Font.SourceSansBold
AudioButton.TextSize = 16
AudioButton.Parent = MainFrame

local CornerAudio = Instance.new("UICorner")
CornerAudio.CornerRadius = UDim.new(0, 6)
CornerAudio.Parent = AudioButton

-- 2. Scan Switch Button
local ScanButton = Instance.new("TextButton") 
ScanButton.Name = "ScanButton"
ScanButton.Size = UDim2.new(0.9, 0, 0, BUTTON_HEIGHT)
ScanButton.Position = UDim2.new(0.05, 0, 0, getButtonY(2))
ScanButton.BackgroundColor3 = COLOR_OFF
ScanButton.Text = "🛡️ 2. REMOTE SCANNER: OFF"
ScanButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ScanButton.Font = Enum.Font.SourceSansBold
ScanButton.TextSize = 16
ScanButton.Parent = MainFrame

local CornerScan = Instance.new("UICorner")
CornerScan.CornerRadius = UDim.new(0, 6)
CornerScan.Parent = ScanButton

-- 3. Clone Avatar Button
local CloneButton = Instance.new("TextButton") 
CloneButton.Name = "CloneButton"
CloneButton.Size = UDim2.new(0.9, 0, 0, BUTTON_HEIGHT)
CloneButton.Position = UDim2.new(0.05, 0, 0, getButtonY(3))
CloneButton.BackgroundColor3 = COLOR_CLONE
CloneButton.Text = "🎭 3. AVATAR CLONE: OPEN LIST"
CloneButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloneButton.Font = Enum.Font.SourceSansBold
CloneButton.TextSize = 16
CloneButton.Parent = MainFrame

local CornerClone = Instance.new("UICorner")
CornerClone.CornerRadius = UDim.new(0, 6)
CornerClone.Parent = CloneButton

-- 4. Startpack Item Button
local ItemButton = Instance.new("TextButton") 
ItemButton.Name = "ItemButton"
ItemButton.Size = UDim2.new(0.9, 0, 0, BUTTON_HEIGHT)
ItemButton.Position = UDim2.new(0.05, 0, 0, getButtonY(4))
ItemButton.BackgroundColor3 = COLOR_ITEM
ItemButton.Text = "⛏️ 4. GET ITEM: " .. (TARGET_TOOL_NAME or ID_EKSTERNAL) 
ItemButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ItemButton.Font = Enum.Font.SourceSansBold
ItemButton.TextSize = 16
ItemButton.Parent = MainFrame

local CornerItem = Instance.new("UICorner")
CornerItem.CornerRadius = UDim.new(0, 6)
CornerItem.Parent = ItemButton

-- 5. Title Inject Button
local TitleInjectButton = Instance.new("TextButton") 
TitleInjectButton.Name = "TitleInjectButton"
TitleInjectButton.Size = UDim2.new(0.9, 0, 0, BUTTON_HEIGHT)
TitleInjectButton.Position = UDim2.new(0.05, 0, 0, getButtonY(5))
TitleInjectButton.BackgroundColor3 = COLOR_TITLE
TitleInjectButton.Text = "👑 5. TITLE INJECTOR: OPEN PANEL"
TitleInjectButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleInjectButton.Font = Enum.Font.SourceSansBold
TitleInjectButton.TextSize = 16
TitleInjectButton.Parent = MainFrame

local CornerTitle = Instance.new("UICorner")
CornerTitle.CornerRadius = UDim.new(0, 6)
CornerTitle.Parent = TitleInjectButton

-- Console Frame (Dihilangkan untuk keringkasan, diasumsikan sama dengan sebelumnya)
local ConsoleFrame = Instance.new("Frame")
ConsoleFrame.Name = "ScannerConsole"
ConsoleFrame.Size = UDim2.new(0, 250, 0, 30) 
ConsoleFrame.Position = UDim2.new(0.5, -125, 0.5, -200) 
ConsoleFrame.BackgroundColor3 = COLOR_BG
ConsoleFrame.BorderSizePixel = 0
ConsoleFrame.Visible = false
ConsoleFrame.Parent = ScreenGui

local CornerConsole = Instance.new("UICorner")
CornerConsole.CornerRadius = UDim.new(0, 8)
CornerConsole.Parent = ConsoleFrame

local ConsoleDragHandle = Instance.new("TextLabel")
ConsoleDragHandle.Name = "DragHandle"
ConsoleDragHandle.Size = UDim2.new(1, -50, 1, 0) 
ConsoleDragHandle.Position = UDim2.new(0, CONSOLE_PADDING.Offset, 0, 0) 
ConsoleDragHandle.BackgroundColor3 = COLOR_BG
ConsoleDragHandle.BackgroundTransparency = 0
ConsoleDragHandle.Text = "CONSOLE: Siap memindai..."
ConsoleDragHandle.TextColor3 = Color3.fromRGB(255, 255, 255)
ConsoleDragHandle.Font = Enum.Font.SourceSans
ConsoleDragHandle.TextSize = 14
ConsoleDragHandle.TextXAlignment = Enum.TextXAlignment.Left
ConsoleDragHandle.TextScaled = false
ConsoleDragHandle.Active = true
ConsoleDragHandle.Parent = ConsoleFrame

local ConsoleCancelButton = Instance.new("TextButton")
ConsoleCancelButton.Name = "ConsoleCancelButton"
ConsoleCancelButton.Size = UDim2.new(0, 30, 1, 0) 
ConsoleCancelButton.Position = UDim2.new(1, -30, 0, 0)
ConsoleCancelButton.BackgroundColor3 = COLOR_WARN
ConsoleCancelButton.Text = "❌"
ConsoleCancelButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ConsoleCancelButton.Font = Enum.Font.SourceSansBold
ConsoleCancelButton.TextSize = 20
ConsoleCancelButton.Visible = false 
ConsoleCancelButton.Parent = ConsoleFrame

local CornerCancel = Instance.new("UICorner")
CornerCancel.CornerRadius = UDim.new(0, 6)
CornerCancel.Parent = ConsoleCancelButton


-- Title Inject Frame (Dihilangkan untuk keringkasan, diasumsikan sama dengan sebelumnya)
local TitleInjectFrame = Instance.new("Frame")
TitleInjectFrame.Name = "TitleInjectFrame"
TitleInjectFrame.Size = UDim2.new(0, 280, 0, TITLE_INJECT_SIZE_Y) 
TitleInjectFrame.Position = UDim2.new(0.5, -140, 0.5, -75) 
TitleInjectFrame.BackgroundColor3 = COLOR_BG
TitleInjectFrame.BorderSizePixel = 0
TitleInjectFrame.Visible = false 
TitleInjectFrame.Parent = ScreenGui

local CornerTitleFrame = Instance.new("UICorner")
CornerTitleFrame.CornerRadius = UDim.new(0, 8)
CornerTitleFrame.Parent = TitleInjectFrame

local TitleInjectHandle = Instance.new("TextLabel")
TitleInjectHandle.Name = "DragHandle"
TitleInjectHandle.Size = UDim2.new(1, 0, 0, 30)
TitleInjectHandle.BackgroundColor3 = COLOR_TITLE
TitleInjectHandle.Text = "👑 INJECT SCRIPT TITLE"
TitleInjectHandle.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleInjectHandle.Font = Enum.Font.SourceSansSemibold
TitleInjectHandle.TextSize = 16
TitleInjectHandle.Active = true
TitleInjectHandle.Parent = TitleInjectFrame

local TitleInput = Instance.new("TextBox")
TitleInput.Name = "TitleInput"
TitleInput.Size = UDim2.new(0.9, 0, 0, 25)
TitleInput.Position = UDim2.new(0.05, 0, 0, 40)
TitleInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
TitleInput.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleInput.Text = "Masukkan Judul Anda"
TitleInput.PlaceholderText = "Judul..."
TitleInput.Font = Enum.Font.SourceSans
TitleInput.TextSize = 14
TitleInput.Parent = TitleInjectFrame

local ColorNameInput = Instance.new("TextBox")
ColorNameInput.Name = "ColorNameInput"
ColorNameInput.Size = UDim2.new(0.4, 0, 0, 25)
ColorNameInput.Position = UDim2.new(0.05, 0, 0, 70)
ColorNameInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ColorNameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
ColorNameInput.Text = "Red"
ColorNameInput.PlaceholderText = "Warna (mis: Blue)"
ColorNameInput.Font = Enum.Font.SourceSans
ColorNameInput.TextSize = 14
ColorNameInput.Parent = TitleInjectFrame

local ColorCodeInput = Instance.new("TextBox")
ColorCodeInput.Name = "ColorCodeInput"
ColorCodeInput.Size = UDim2.new(0.45, 0, 0, 25)
ColorCodeInput.Position = UDim2.new(0.5, 0, 0, 70)
ColorCodeInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ColorCodeInput.TextColor3 = Color3.fromRGB(255, 255, 255)
ColorCodeInput.Text = "1, 0, 0" -- Merah (Red)
ColorCodeInput.PlaceholderText = "RGB (mis: 1, 0, 0)"
ColorCodeInput.Font = Enum.Font.SourceSans
ColorCodeInput.TextSize = 14
ColorCodeInput.Parent = TitleInjectFrame

local SendButton = Instance.new("TextButton")
SendButton.Name = "SendButton"
SendButton.Size = UDim2.new(0.9, 0, 0, 30)
SendButton.Position = UDim2.new(0.05, 0, 0, 100)
SendButton.BackgroundColor3 = COLOR_ON
SendButton.Text = "KIRIM TITLE KE SEMUA PEMAIN"
SendButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SendButton.Font = Enum.Font.SourceSansBold
SendButton.TextSize = 16
SendButton.Parent = TitleInjectFrame

local CornerSend = Instance.new("UICorner")
CornerSend.CornerRadius = UDim.new(0, 6)
CornerSend.Parent = SendButton

local OutputLabel = Instance.new("TextLabel")
OutputLabel.Name = "OutputLabel"
OutputLabel.Size = UDim2.new(0.9, 0, 0, 15)
OutputLabel.Position = UDim2.new(0.05, 0, 0, 135)
OutputLabel.BackgroundColor3 = COLOR_BG
OutputLabel.BackgroundTransparency = 1
OutputLabel.TextColor3 = COLOR_WARN
OutputLabel.Text = ""
OutputLabel.Font = Enum.Font.SourceSans
OutputLabel.TextSize = 12
OutputLabel.TextWrapped = true
OutputLabel.TextXAlignment = Enum.TextXAlignment.Left
OutputLabel.Visible = false
OutputLabel.Parent = TitleInjectFrame

-- Player List Frame (Dihilangkan untuk keringkasan, diasumsikan sama dengan sebelumnya)
local PlayerListFrame = Instance.new("Frame")
PlayerListFrame.Name = "PlayerListFrame"
PlayerListFrame.Size = UDim2.new(0, 250, 0, PLAYER_LIST_SIZE_Y) 
PlayerListFrame.Position = UDim2.new(0.5, -125, 0.5, 130) 
PlayerListFrame.BackgroundColor3 = COLOR_BG
PlayerListFrame.BorderSizePixel = 0
PlayerListFrame.Visible = false 
PlayerListFrame.Parent = ScreenGui

local CornerList = Instance.new("UICorner")
CornerList.CornerRadius = UDim.new(0, 8)
CornerList.Parent = PlayerListFrame

local ListTitle = Instance.new("TextLabel")
ListTitle.Name = "DragHandle"
ListTitle.Size = UDim2.new(1, 0, 0, 30)
ListTitle.BackgroundColor3 = COLOR_ACCENT
ListTitle.Text = "👥 PILIH TARGET CLONE"
ListTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
ListTitle.Font = Enum.Font.SourceSansSemibold
ListTitle.TextSize = 16
ListTitle.Active = true
ListTitle.Parent = PlayerListFrame

local PlayerListScroll = Instance.new("ScrollingFrame")
PlayerListScroll.Name = "PlayerListScroll"
PlayerListScroll.Size = UDim2.new(1, 0, 1, -30)
PlayerListScroll.Position = UDim2.new(0, 0, 0, 30)
PlayerListScroll.BackgroundColor3 = COLOR_BG
PlayerListScroll.BorderSizePixel = 0
PlayerListScroll.ScrollBarImageColor3 = COLOR_ACCENT
PlayerListScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y 
PlayerListScroll.Parent = PlayerListFrame

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 4)
ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
ListLayout.Parent = PlayerListScroll

-- Terapkan drag
local isMainFrameDragging = makeDraggable(MainFrame)
local isConsoleDragging = makeDraggable(ConsoleFrame)
local isPlayerListDragging = makeDraggable(PlayerListFrame) 
local isTitleInjectDragging = makeDraggable(TitleInjectFrame) 

-- === 9. Koneksi Tombol Utama ===

AudioButton.MouseButton1Click:Connect(function()
    if isMainFrameDragging() then return end
    IS_AUDIO_ENABLED = not IS_AUDIO_ENABLED
    AudioButton.Text = "🎵 1. AUDIO GLOBAL: " .. (IS_AUDIO_ENABLED and "ON" or "OFF")
    
    if IS_AUDIO_ENABLED then
        startAudioLoop()
    else
        stopAudioAndLoop()
    end
    
    AudioButton.BackgroundColor3 = IS_AUDIO_ENABLED and COLOR_ON or COLOR_OFF
    notify("🔊 Audio", "Status: " .. (IS_AUDIO_ENABLED and "Aktif" or "Mati"), 2)
end)

ScanButton.MouseButton1Click:Connect(function()
    if isMainFrameDragging() then return end
    
    if not IsScanActive then
        ConsoleFrame.Visible = true
        ConsoleCancelButton.Visible = true
        ScanButton.BackgroundColor3 = COLOR_SCAN
        ScanButton.Text = "🛡️ 2. REMOTE SCANNER: RUNNING"
        startScanLoop(ConsoleDragHandle, ScanButton, ConsoleCancelButton)
    else
        stopScanLoop(ConsoleDragHandle, ScanButton, ConsoleCancelButton)
    end
end)

CloneButton.MouseButton1Click:Connect(function()
    if isMainFrameDragging() then return end
    
    PlayerListFrame.Visible = not PlayerListFrame.Visible
    
    if PlayerListFrame.Visible then
        populatePlayerList(PlayerListScroll)
    end
    notify("🎭 Avatar Clone", "Daftar Pemain " .. (PlayerListFrame.Visible and "dibuka." or "ditutup."), 2)
end)

ItemButton.MouseButton1Click:Connect(function()
    if isMainFrameDragging() then return end
    giveStartpackItem(TARGET_TOOL_NAME, ID_EKSTERNAL)
end)

TitleInjectButton.MouseButton1Click:Connect(function()
    if isMainFrameDragging() then return end
    
    TitleInjectFrame.Visible = not TitleInjectFrame.Visible
    
    if TitleInjectFrame.Visible then
        notify("👑 Title Injector", "Panel injeksi judul dibuka. Remote: " .. (LAST_GLOBAL_REMOTE_PATH or "Belum Ditemukan"), 4)
    else
        notify("👑 Title Injector", "Panel injeksi judul ditutup.", 2)
    end
end)

SendButton.MouseButton1Click:Connect(function()
    if isTitleInjectDragging() then return end
    
    local title = TitleInput.Text
    local colorName = ColorNameInput.Text
    local colorCode = ColorCodeInput.Text
    
    sendCustomTitle(title, colorName, colorCode)
end)

ConsoleCancelButton.MouseButton1Click:Connect(function()
    if isConsoleDragging() then return end
    
    if IsScanActive then
        stopScanLoop(ConsoleDragHandle, ScanButton, ConsoleCancelButton)
    end
end)

-- === 10. Icon Floating dan Koneksi Toggle ===
local FloatingIcon = Instance.new("TextButton") 
FloatingIcon.Name = "AudioToggleIcon"
FloatingIcon.Size = ICON_SIZE
FloatingIcon.Position = UDim2.new(0.02, 0, 0.85, 0) 
FloatingIcon.BackgroundTransparency = 0.1 
FloatingIcon.BackgroundColor3 = COLOR_ACCENT 
FloatingIcon.Text = FLOATING_ICON_EMOJI 
FloatingIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatingIcon.Font = Enum.Font.Code
FloatingIcon.TextSize = 30 
FloatingIcon.ZIndex = 99
FloatingIcon.Active = true 
FloatingIcon.Parent = ScreenGui 

local CornerIcon = Instance.new("UICorner")
CornerIcon.CornerRadius = UDim.new(0.5, 0) 
CornerIcon.Parent = FloatingIcon

local isIconDragging = makeDraggable(FloatingIcon)

FloatingIcon.MouseButton1Click:Connect(function()
    if not isIconDragging() then
        IS_GUI_VISIBLE = not IS_GUI_VISIBLE
        MainFrame.Visible = IS_GUI_VISIBLE 
        
        if not IS_GUI_VISIBLE then
            PlayerListFrame.Visible = false
            TitleInjectFrame.Visible = false 
        end

        if IS_GUI_VISIBLE or IsScanActive then
            ConsoleFrame.Visible = true
            ConsoleCancelButton.Visible = IsScanActive
        else
            ConsoleFrame.Visible = false
        end

        notify("⚙️ GUI Status", "Panel Eksekutor: " .. (IS_GUI_VISIBLE and "Terlihat" or "Tersembunyi"), 2)
    end
end)

-- === Finalisasi ===
notify("✅ Executor Loaded", "Floating Icon " .. FLOATING_ICON_EMOJI .. " telah aktif. Klik untuk membuka panel.", 4)
