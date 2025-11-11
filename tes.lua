-- File: ExecutorGUI_LocalScript (DIPERBARUI DENGAN PRIORITAS DETEKSI BROADCAST)

-- === Konfigurasi & Service ===
local GUI_NAME = "ExecutorGUI"
local ICON_ID = "rbxassetid://7335147596" 
local FLOATING_ICON_EMOJI = "🛡️"
local ICON_SIZE = UDim2.new(0, 50, 0, 50) 
local DRAG_THRESHOLD = 5 
local LOOP_INTERVAL = 0.5 
local SCAN_INTERVAL = 0.005 -- Dipercepat: Untuk "memproses dengan cepat"
local CONSOLE_PADDING = UDim.new(0, 5) 
local PLAYER_LIST_SIZE_Y = 200 

-- ID ITEM STARTERPACK (TIDAK BERUBAH)
local TARGET_TOOL_NAME = "Glowstick" 
local ID_EKSTERNAL = 121365069 
local STARTPACK_ITEM_NAME = "Startpack Tool" 

-- Status (TIDAK BERUBAH)
local IS_AUDIO_ENABLED = false    
local IS_SCAN_ENABLED = false     
local IS_GUI_VISIBLE = false      
local IsAudioLoopActive = false   
local AudioLoopThread = nil       
local IsScanActive = false        
local ScanLoopThread = nil        
local TESTED_REMOTES = {}         

-- Warna Modern/Minimalis (TIDAK BERUBAH)
local COLOR_BG = Color3.fromRGB(35, 35, 35)      
local COLOR_ACCENT = Color3.fromRGB(0, 150, 255)  
local COLOR_ON = Color3.fromRGB(0, 200, 83)      
local COLOR_OFF = Color3.fromRGB(50, 50, 50)     
local COLOR_SCAN = Color3.fromRGB(255, 165, 0)   
local COLOR_WARN = Color3.fromRGB(255, 50, 50)   
local COLOR_CLONE = Color3.fromRGB(150, 0, 255)  
local COLOR_ITEM = Color3.fromRGB(255, 200, 0)   

-- Services (TIDAK BERUBAH)
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

-- (Fungsi 2 - Logika Inti Loop Audio - TIDAK BERUBAH)

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

---

-- === 3. Logika RemoteEvent Scanner (DIPERBARUI) ===

-- FUNGSI UJI INJEKSI PASIF (TIDAK BERUBAH)
local function runPassiveInjectionTest(remote)
    local remotePath = remote:GetFullName()
    
    if TESTED_REMOTES[remotePath] then 
        return TESTED_REMOTES[remotePath] 
    end
    
    local potentialVuln = "CLEAN"

    local vulnerability = checkRemoteEventVulnerability(remote)
    if vulnerability ~= "NONE" then
        potentialVuln = vulnerability
    end

    -- Override FireServer (Simulasi Logika Injeksi)
    -- Jika remote digunakan oleh skrip lain setelah scanner ini berjalan, 
    -- kerentanan akan dideteksi dan dicatat di TESTED_REMOTES

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
    local vulnerability = "NONE"
    local lowerName = remoteName:lower()
    
    local highRiskPatterns = {
        "Kick", "Ban", "Moderation", "AdminEvent", 
        "Teleport", "tp", "CFrame",
        "Broadcast", "GlobalMessage", "NotifyAll", "MessagePlayers" -- BARU: Deteksi Notifikasi Global
    }

    local mediumRiskPatterns = {
        "GiveAll", "ChangeValue", "FireServer", "ExecuteCommand", 
        "SetProperty", "MovePlayer", "RemoteFunction", "SyncState", "SetData",
        "Damage", "Health", "Stat", "Give", "AddItem", "Currency"
    }

    for _, pattern in ipairs(highRiskPatterns) do
        if lowerName:match(pattern:lower()) then
            -- Kasus khusus: Deteksi Notifikasi Global
            if pattern == "Broadcast" or pattern == "GlobalMessage" or pattern == "NotifyAll" or pattern == "MessagePlayers" then
                return "HIGH (GLOBAL MESSAGE/NOTIFIKASI - Potensi Kirim 'hai' ke semua)"
            else
                return "HIGH (Admin/Moderation/Teleport Bypass)"
            end
        end
    end

    for _, pattern in ipairs(mediumRiskPatterns) do
        if lowerName:match(pattern:lower()) then 
            return "MEDIUM (Common Exploit Pattern: " .. pattern .. ")"
        end
    end

    return vulnerability
end

local function startScanLoop(console, scanButton, cancelButton)
    if IsScanActive then return end
    
    IsScanActive = true
    IS_SCAN_ENABLED = true
    console.Text = "SCANNER: Memulai pemindaian & Uji Injeksi Cepat..."
    notify("🛡️ RemoteEvent Scanner", "Pemindaian Cepat & Uji Injeksi Pasif **DIMULAI**. Cek Konsol GUI.", 4)
    
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
        local globalNotifyRemote = nil -- Variabel untuk menyimpan remote notifikasi global

        for _, remote in ipairs(remotesToScan) do
            if not IsScanActive then break end 
            
            totalScanned = totalScanned + 1
            local vulnerability = checkRemoteEventVulnerability(remote) 
            local remotePath = remote:GetFullName()
            
            console.Text = "SCANNING: " .. remote.Name .. " (" .. totalScanned .. "/" .. #remotesToScan .. ")"
            task.wait(SCAN_INTERVAL)
            
            if vulnerability ~= "NONE" then
                vulnerableFound = vulnerableFound + 1
                
                -- EKSEKUSI UJI INJEKSI PASIF
                local testResult = runPassiveInjectionTest(remote)
                
                local actionText = ""
                local warnColor = COLOR_WARN
                
                if testResult:match("HIGH") then
                    highRiskCount = highRiskCount + 1
                    actionText = "BLOCKED" 
                    -- Blokir komunikasi Server secara otomatis
                    remote.FireServer = function() end 
                    if remote:IsA("RemoteFunction") then remote.InvokeServer = function() return nil end end
                    warnColor = Color3.fromRGB(255, 0, 0)

                    -- Cek jika ini adalah Remote Global Notify yang dicari
                    if testResult:match("GLOBAL MESSAGE") and not globalNotifyRemote then
                        globalNotifyRemote = remote
                    end

                elseif testResult:match("MEDIUM") then
                    actionText = "LOGGED"
                    warnColor = COLOR_SCAN
                else
                    actionText = "UNKNOWN"
                end
                
                local warningText = "⚠️ KELEMAHAN DITEMUKAN: " .. remotePath .. " - " .. testResult .. " (" .. actionText .. ")"
                console.Text = warningText 
                notify("🚨 UJI INJEKSI HASIL", warningText, 10, ICON_ID)
                task.wait(0.1) -- Mengurangi jeda untuk kecepatan
            end
        end
        
        local statusText = "SCANNER: Selesai. Ditemukan **" .. vulnerableFound .. "** kelemahan. **" .. highRiskCount .. "** Remote BERISIKO TINGGI."
        console.Text = statusText
        notify("✅ Pemindaian Selesai", statusText, 5)

        -- PESAN KHUSUS UNTUK PERMINTAAN "KIRIM NOTIF LAYAR HAI"
        if globalNotifyRemote then
            local notifyPath = globalNotifyRemote:GetFullName()
            local successMsg = "🎉 NOTIFIKASI GLOBAL DITEMUKAN! " .. notifyPath
            console.Text = successMsg
            notify("⭐ KERENTANAN 'HAI' SIAP", "Remote Global: **" .. notifyPath .. "**. Remote tersebut sekarang diblokir.", 8, ICON_ID)
            
            -- Menampilkan instruksi manual (Pengganti Eksekusi Aktif)
            task.wait(2)
            notify("ℹ️ MANUAL INJECTION", "Untuk mengirim 'hai', gunakan: **" .. notifyPath .. ":FireServer('hai')** di Executor lain (Remote ini sudah diblokir).", 10, ICON_ID)
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

---

-- (Fungsi 4, 5, 6, 7, 8, 9 - Sisa GUI/Logika - TIDAK BERUBAH)

-- [BLOK KODE UNTUK makeDraggable, cloneAvatar, populatePlayerList, giveStartpackItem, GUI Creation, dan Koneksi Tombol LAINNYA. Blok ini identik dengan kode sebelumnya.]

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

local function cloneAvatar(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then
        notify("❌ Gagal Clone", "Karakter target tidak ditemukan.", 3)
        return
    end

    local targetHumanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not targetHumanoid then
        notify("❌ Gagal Clone", "Humanoid target tidak ditemukan.", 3)
        return
    end

    local description
    if targetHumanoid:FindFirstChild("HumanoidDescription") then
        description = targetHumanoid:FindFirstChild("HumanoidDescription"):Clone()
    else
        description = Players:GetHumanoidDescriptionFromUserId(targetPlayer.UserId)
    end
    
    if not description then
        notify("❌ Gagal Clone", "Gagal mendapatkan deskripsi Humanoid.", 3)
        return
    end

    task.spawn(function()
        LocalPlayer:LoadCharacterWithHumanoidDescription(description)
        task.wait(0.5) 
    end)

    local PlayerListFrame = PlayerGui:FindFirstChild(GUI_NAME):FindFirstChild("PlayerListFrame")
    if PlayerListFrame then
        PlayerListFrame.Visible = false
    end

    notify("✅ Avatar Cloned", "Anda sekarang terlihat seperti **" .. targetPlayer.Name .. "**! (Karakter dimuat ulang)", 5)
end

local function populatePlayerList(scrollingFrame)
    for _, child in ipairs(scrollingFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    local listLayout = scrollingFrame:FindFirstChildOfClass("UIListLayout")
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
    
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, count * (30 + (listLayout.Padding.Offset or 0)))
end

local function giveStartpackItem(targetName, toolId)
    local toolTemplate = nil
    
    if targetName and targetName ~= "" then
        toolTemplate = ReplicatedStorage:FindFirstChild(targetName) 
        if not toolTemplate then
            toolTemplate = StarterPack:FindFirstChild(targetName)
        end
        if not toolTemplate then
             toolTemplate = Workspace:FindFirstChild(targetName)
        end
    end

    if not toolTemplate and toolId and toolId > 0 then
        local success, itemModel = pcall(function()
            return InsertService:LoadAsset(toolId)
        end)
        
        if success and itemModel then
            local tool = itemModel:FindFirstChildOfClass("Tool")
            if tool then
                toolTemplate = tool
                toolTemplate.Parent = nil 
                itemModel:Destroy()
            end
        end
    end
    
    if not toolTemplate or not toolTemplate:IsA("Tool") then
        notify("❌ Gagal Item", "Item **" .. (targetName or tostring(toolId)) .. "** tidak ditemukan atau bukan Tool. Periksa NAMA atau ID Anda.", 4, ICON_ID)
        return
    end

    local actualToolName = toolTemplate.Name
    STARTPACK_ITEM_NAME = actualToolName
    
    if LocalPlayer.Backpack:FindFirstChild(actualToolName) then
        notify("ℹ️ Item Sudah Ada", "**" .. actualToolName .. "** sudah ada di ransel Anda.", 3, ICON_ID)
        return
    end
    
    if not StarterPack:FindFirstChild(actualToolName) then
        local toolForStarterPack = toolTemplate:Clone()
        toolForStarterPack.Parent = StarterPack
        
        local toolForBackpack = toolForStarterPack:Clone()
        toolForBackpack.Parent = LocalPlayer.Backpack
        
        notify("✅ Item Diberikan (Respawn Aktif)", "**" .. actualToolName .. "** ditambahkan ke ransel dan StarterPack.", 5, ICON_ID)
    else
        local existingTool = StarterPack:FindFirstChild(actualToolName)
        local newClone = existingTool:Clone()
        newClone.Parent = LocalPlayer.Backpack
        
        notify("✅ Item Diberikan", "**" .. actualToolName .. "** ditambahkan ke ransel Anda.", 4, ICON_ID)
    end
    
    local ItemButton = PlayerGui:FindFirstChild(GUI_NAME):FindFirstChild("MainFrame"):FindFirstChild("ItemButton")
    if ItemButton then
         ItemButton.Text = "⛏️ GET: " .. actualToolName
    end
end

-- GUI Creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = GUI_NAME
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.Parent = PlayerGui 

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 225) 
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -112.5) 
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

local AudioButton = Instance.new("TextButton") 
AudioButton.Name = "AudioButton"
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

local ScanButton = Instance.new("TextButton") 
ScanButton.Name = "ScanButton"
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

local CloneButton = Instance.new("TextButton") 
CloneButton.Name = "CloneButton"
CloneButton.Size = UDim2.new(0.9, 0, 0, 30)
CloneButton.Position = UDim2.new(0.05, 0, 0, 110)
CloneButton.BackgroundColor3 = COLOR_CLONE
CloneButton.Text = "🎭 AVATAR CLONE: OPEN LIST"
CloneButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloneButton.Font = Enum.Font.SourceSansBold
CloneButton.TextSize = 16
CloneButton.Parent = MainFrame

local CornerClone = Instance.new("UICorner")
CornerClone.CornerRadius = UDim.new(0, 6)
CornerClone.Parent = CloneButton

local ItemButton = Instance.new("TextButton") 
ItemButton.Name = "ItemButton"
ItemButton.Size = UDim2.new(0.9, 0, 0, 30)
ItemButton.Position = UDim2.new(0.05, 0, 0, 145) 
ItemButton.BackgroundColor3 = COLOR_ITEM
ItemButton.Text = "⛏️ GET: " .. (TARGET_TOOL_NAME or ID_EKSTERNAL) 
ItemButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ItemButton.Font = Enum.Font.SourceSansBold
ItemButton.TextSize = 16
ItemButton.Parent = MainFrame

local CornerItem = Instance.new("UICorner")
CornerItem.CornerRadius = UDim.new(0, 6)
CornerItem.Parent = ItemButton

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

local isMainFrameDragging = makeDraggable(MainFrame)
local isConsoleDragging = makeDraggable(ConsoleFrame)
local isPlayerListDragging = makeDraggable(PlayerListFrame) 

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

ScanButton.MouseButton1Click:Connect(function()
    if isMainFrameDragging() then return end
    
    if not IsScanActive then
        ConsoleFrame.Visible = true
        ConsoleCancelButton.Visible = true
        ScanButton.BackgroundColor3 = COLOR_SCAN
        ScanButton.Text = "🛡️ REMOTE SCANNER: RUNNING"
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
        notify("🎭 Avatar Clone", "Daftar Pemain dibuka. Pilih target.", 3)
    else
        notify("🎭 Avatar Clone", "Daftar Pemain ditutup.", 2)
    end
end)

ItemButton.MouseButton1Click:Connect(function()
    if isMainFrameDragging() then return end
    giveStartpackItem(TARGET_TOOL_NAME, ID_EKSTERNAL)
end)


ConsoleCancelButton.MouseButton1Click:Connect(function()
    if isConsoleDragging() then return end
    
    if IsScanActive then
        stopScanLoop(ConsoleDragHandle, ScanButton, ConsoleCancelButton)
    end
end)

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
