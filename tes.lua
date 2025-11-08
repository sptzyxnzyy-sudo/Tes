--[ Executor Lua Code - Global Audio Player (Optimized Modern GUI with Persistent Loop) & RemoteEvent Scanner ]--

-- === Konfigurasi & Service ===
local GUI_NAME = "ExecutorGUI"
local ICON_ID = "rbxassetid://7335147596" -- Icon Asset ID untuk Notifikasi
local FLOATING_ICON_EMOJI = "🛡️"
local ICON_SIZE = UDim2.new(0, 50, 0, 50) 
local DRAG_THRESHOLD = 5 -- Batas pixel untuk membedakan click dari drag
local LOOP_INTERVAL = 0.5 -- Interval pengecekan audio (detik)
local SCAN_INTERVAL = 0.05 -- Interval tampilan animasi scan (detik)

-- Status
local IS_AUDIO_ENABLED = false    -- Status Tombol Audio UI
local IS_SCAN_ENABLED = false     -- Status Tombol Scan UI
local IS_GUI_VISIBLE = false      -- Status Visibility Panel
local IsAudioLoopActive = false   -- Status Loop Logika Audio
local AudioLoopThread = nil       -- Thread yang menjalankan loop audio
local IsScanActive = false        -- Status Loop Logika Scan
local ScanLoopThread = nil        -- Thread yang menjalankan loop scan

-- Warna Modern/Minimalis
local COLOR_BG = Color3.fromRGB(35, 35, 35)      
local COLOR_ACCENT = Color3.fromRGB(0, 150, 255)  
local COLOR_ON = Color3.fromRGB(0, 200, 83)      
local COLOR_OFF = Color3.fromRGB(50, 50, 50)     
local COLOR_SCAN = Color3.fromRGB(255, 165, 0)   -- Warna untuk Scan
local COLOR_WARN = Color3.fromRGB(255, 50, 50)   -- Warna untuk Warning

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local task = task or coroutine

-- === 1. Fungsi Notifikasi ===
local function notify(title, text, duration, iconOverride)
    StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = duration or 3,
        Icon = iconOverride or ICON_ID,
    })
end

-- ---

-- === 2. Logika Inti Loop Audio ===
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
    AudioLoopThread = nil

    for _, part in Workspace:GetDescendants() do
        if part:IsA("BasePart") then
            local sound = part:FindFirstChildOfClass("Sound")
            if sound and sound:IsA("Sound") and sound.Playing then
                sound:Stop() 
            end
        end
    end
end

-- ---

-- === 3. Logika Inti RemoteEvent Scanner ===
local function checkRemoteEventVulnerability(remote)
    local remoteName = remote.Name
    local vulnerability = "NONE"
    
    -- Heuristik Deteksi Kelemahan Sederhana:
    local commonExploits = {
        "GiveAll", "TeleportPlayer", "ChangeValue", "FireServer", 
        "ExecuteCommand", "KickPlayer", "BanPlayer", "AdminEvent",
        "SetProperty", "MovePlayer", "RemoteFunction" 
    }

    if remoteName:match("Teleport") or remoteName:match("tp") then
        vulnerability = "HIGH (Teleporting/Bypassing)"
    elseif remoteName:match("Kick") or remoteName:match("Ban") or remoteName:match("Moderation") then
        vulnerability = "HIGH (Admin/Moderation Bypass)"
    elseif remoteName:match("Damage") or remoteName:match("Health") or remoteName:match("Stat") then
        vulnerability = "MEDIUM (Stat Manipulation)"
    elseif remoteName:match("Give") or remoteName:match("AddItem") or remoteName:match("Currency") then
        vulnerability = "MEDIUM (Item/Currency Giver)"
    else
        for _, pattern in ipairs(commonExploits) do
            if remoteName:match(pattern) then
                vulnerability = "MEDIUM (Common Exploit Pattern: " .. pattern .. ")"
                break
            end
        end
    end

    return vulnerability
end

local function startScanLoop(console)
    if IsScanActive then return end
    
    IsScanActive = true
    IS_SCAN_ENABLED = true
    console.Text = "SCANNER: Memulai pemindaian..."
    notify("🛡️ RemoteEvent Scanner", "Pemindaian kelemahan RemoteEvent **DIMULAI**. Cek Konsol GUI.", 4)
    
    ScanLoopThread = task.spawn(function()
        local remotesToScan = {}
        
        -- Kumpulkan semua RemoteEvent dan RemoteFunction
        for _, obj in ReplicatedStorage:GetDescendants() do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                table.insert(remotesToScan, obj)
            end
        end
        for _, obj in Workspace:GetDescendants() do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                table.insert(remotesToScan, obj)
            end
        end
        
        local vulnerableFound = 0
        local totalScanned = 0
        
        for _, remote in ipairs(remotesToScan) do
            if not IsScanActive then break end -- Cek jika dibatalkan
            
            totalScanned = totalScanned + 1
            local vulnerability = checkRemoteEventVulnerability(remote)
            local remotePath = remote:GetFullName()
            
            -- Tampilkan loop animasi di console
            console.Text = "SCANNING: " .. remote.Name .. " (" .. totalScanned .. "/" .. #remotesToScan .. ")"
            task.wait(SCAN_INTERVAL)
            
            if vulnerability ~= "NONE" then
                vulnerableFound = vulnerableFound + 1
                local warningText = "⚠️ KELEMAHAN DITEMUKAN: " .. remotePath .. " - " .. vulnerability
                console.Text = warningText 
                notify("🚨 KELEMAHAN DITEMUKAN!", warningText, 10, ICON_ID)
                task.wait(0.5) -- Jeda agar user sempat melihat
            end
        end
        
        -- Selesai
        local statusText = "SCANNER: Selesai. Ditemukan **" .. vulnerableFound .. "** kelemahan dari **" .. totalScanned .. "** Remote."
        console.Text = statusText
        notify("✅ Pemindaian Selesai", statusText, 5)

        IsScanActive = false
        IS_SCAN_ENABLED = false
        ScanButton.Text = "🛡️ REMOTE SCANNER: OFF"
        ScanButton.BackgroundColor3 = COLOR_OFF
        ConsoleCancelButton.Visible = false
    end)
end

local function stopScanLoop(console)
    if not IsScanActive then return end
    
    IsScanActive = false
    IS_SCAN_ENABLED = false
    ScanLoopThread = nil
    console.Text = "SCANNER: DIBATALKAN/DIHENTIKAN."
    notify("🚫 Pemindaian Dibatalkan", "Pemindaian RemoteEvent dihentikan oleh pengguna.", 3)
}

-- ---

-- === 4. Fungsi Drag GUI (Optimized) ===
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

-- ---

-- === 5. Pembuatan GUI Utama (Panel Kontrol) ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = GUI_NAME
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 155) 
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -77)
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
TitleLabel.Text = "🛠️ EXECUTION PANEL"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.SourceSansSemibold
TitleLabel.TextSize = 18
TitleLabel.Active = true 
TitleLabel.Parent = MainFrame

-- Audio Switch Button
local AudioButton = Instance.new("TextButton") 
AudioButton.Size = UDim2.new(0.9, 0, 0, 30)
AudioButton.Position = UDim2.new(0.05, 0, 0, 40)
AudioButton.BackgroundColor3 = COLOR_OFF
AudioButton.Text = "🎵 AUDIO GLOBAL: OFF"
AudioButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AudioButton.Font = Enum.Font.SourceSansBold
AudioButton.TextSize = 16
AudioButton.Parent = MainFrame

local CornerAudio = Instance.new("UICorner")
CornerAudio.CornerRadius = UDim.new(0, 6)
CornerAudio.Parent = AudioButton

-- Scan Switch Button
local ScanButton = Instance.new("TextButton") 
ScanButton.Size = UDim2.new(0.9, 0, 0, 30)
ScanButton.Position = UDim2.new(0.05, 0, 0, 75)
ScanButton.BackgroundColor3 = COLOR_OFF
ScanButton.Text = "🛡️ REMOTE SCANNER: OFF"
ScanButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ScanButton.Font = Enum.Font.SourceSansBold
ScanButton.TextSize = 16
ScanButton.Parent = MainFrame

local CornerScan = Instance.new("UICorner")
CornerScan.CornerRadius = UDim.new(0, 6)
CornerScan.Parent = ScanButton

-- Console GUI Frame (untuk Tampilan Scan)
local ConsoleFrame = Instance.new("Frame")
ConsoleFrame.Name = "ScannerConsole"
ConsoleFrame.Size = UDim2.new(0, 250, 0, 40)
ConsoleFrame.Position = UDim2.new(0.5, -125, 0.5, -200) -- Di atas MainFrame
ConsoleFrame.BackgroundColor3 = COLOR_BG
ConsoleFrame.BorderSizePixel = 0
ConsoleFrame.Visible = false
ConsoleFrame.Parent = ScreenGui

local CornerConsole = Instance.new("UICorner")
CornerConsole.CornerRadius = UDim.new(0, 8)
CornerConsole.Parent = ConsoleFrame

local ConsoleDragHandle = Instance.new("TextLabel")
ConsoleDragHandle.Name = "DragHandle"
ConsoleDragHandle.Size = UDim2.new(1, -50, 1, 0) -- Beri ruang untuk Cancel Button
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
ConsoleCancelButton.Size = UDim2.new(0, 50, 1, 0)
ConsoleCancelButton.Position = UDim2.new(1, -50, 0, 0)
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

-- Terapkan drag
local isMainFrameDragging = makeDraggable(MainFrame)
local isConsoleDragging = makeDraggable(ConsoleFrame)

-- === 6. Koneksi Tombol Utama ===

-- Koneksi Tombol Audio Switch
AudioButton.MouseButton1Click:Connect(function()
    if isMainFrameDragging() then return end
    IS_AUDIO_ENABLED = not IS_AUDIO_ENABLED
    AudioButton.Text = "🎵 AUDIO GLOBAL: " .. (IS_AUDIO_ENABLED and "ON" or "OFF")
    
    if IS_AUDIO_ENABLED then
        startAudioLoop()
        notify("🔊 Audio Executor", "Fitur audio global DIJALANKAN (Loop Aktif).", 5)
    else
        stopAudioAndLoop()
        notify("🔊 Audio Executor", "Fitur audio global DIHENTIKAN (Loop Mati).", 5)
    end
    
    AudioButton.BackgroundColor3 = IS_AUDIO_ENABLED and COLOR_ON or COLOR_OFF
end)

-- Koneksi Tombol Scan Switch
ScanButton.MouseButton1Click:Connect(function()
    if isMainFrameDragging() then return end
    
    if not IsScanActive then
        ConsoleFrame.Visible = true
        ConsoleCancelButton.Visible = true
        ScanButton.BackgroundColor3 = COLOR_SCAN
        ScanButton.Text = "🛡️ REMOTE SCANNER: RUNNING"
        startScanLoop(ConsoleDragHandle)
    else
        -- Tombol ini juga berfungsi sebagai stop/cancel
        stopScanLoop(ConsoleDragHandle)
        ConsoleFrame.Visible = false
        ConsoleCancelButton.Visible = false
        ScanButton.BackgroundColor3 = COLOR_OFF
        ScanButton.Text = "🛡️ REMOTE SCANNER: OFF"
    end
end)

-- Koneksi Tombol Console Cancel (Tombol ❌)
ConsoleCancelButton.MouseButton1Click:Connect(function()
    if isConsoleDragging() then return end
    
    if IsScanActive then
        stopScanLoop(ConsoleDragHandle)
        ConsoleFrame.Visible = false
        ConsoleCancelButton.Visible = false
        ScanButton.BackgroundColor3 = COLOR_OFF
        ScanButton.Text = "🛡️ REMOTE SCANNER: OFF"
    end
end)


-- ---

-- === 7. Icon Floating dan Koneksi Toggle ===
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

-- Terapkan drag pada Icon Floating
local isIconDragging = makeDraggable(FloatingIcon)

-- Fungsi Tombol Icon (Toggle Panel)
FloatingIcon.MouseButton1Click:Connect(function()
    if not isIconDragging() then
        IS_GUI_VISIBLE = not IS_GUI_VISIBLE
        MainFrame.Visible = IS_GUI_VISIBLE 
        
        -- Console hanya terlihat jika panel utama terlihat ATAU sedang dalam proses scan
        if IS_GUI_VISIBLE or IsScanActive then
            ConsoleFrame.Visible = true
        else
            ConsoleFrame.Visible = false
        end

        -- Jika Console tidak sedang scan dan MainFrame ditutup, sembunyikan ConsoleCancelButton
        if not IsScanActive then
            ConsoleCancelButton.Visible = false
        end

        notify("⚙️ GUI Status", "Panel Eksekutor: " .. (IS_GUI_VISIBLE and "Terlihat" or "Tersembunyi"), 2)
    end
end)

-- === Finalisasi ===
ScreenGui.Parent = PlayerGui
notify("✅ Executor Loaded", "Floating Icon " .. FLOATING_ICON_EMOJI .. " telah aktif. Klik untuk membuka panel.", 4)
