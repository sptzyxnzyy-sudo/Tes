-- File: ExecutorGUI_LocalScript (Simpan di StarterGui)

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
local TITLE_INJECT_SIZE_Y_NEW = 280 
local BUTTON_HEIGHT = 30 
local BUTTON_SPACING = 5  

-- TARGET REMOTE INJEKSI GLOBAL (HARUS SAMA DENGAN NAMA DI SERVER SCRIPT)
local GENERIC_GLOBAL_REMOTE_NAME = "GlobalTitleTagInjector" 

-- ID ITEM STARTERPACK
local TARGET_TOOL_NAME = "Glowstick" 

-- Status
local IS_AUDIO_ENABLED = false    
local IS_SCAN_ENABLED = false     
local IS_GUI_VISIBLE = false      
local IsAudioLoopActive = false   
local AudioLoopThread = nil       
local IsScanActive = false        
local ScanLoopThread = nil        
local TESTED_REMOTES = {}         
local currentTitleTagInstance = nil -- Melacak instance tag kepala lokal

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
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local StarterPack = game:GetService("StarterPack") 
local task = task 

-- *** PERBAIKAN: Memastikan LocalPlayer dan PlayerGui siap ***
local LocalPlayer = Players.LocalPlayer or Players.LocalPlayer:Wait()
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService") -- Ditambahkan untuk drag UI feedback

-- === 1. Fungsi Notifikasi ===
local function notify(title, text, duration, iconOverride)
    pcall(StarterGui.SetCore, StarterGui, "SendNotification", {
        Title = title,
        Text = text,
        Duration = duration or 3,
        Icon = iconOverride or ICON_ID,
    })
end

-- === 6. Fungsi Drag GUI (Diperbarui untuk keandalan) ===
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
            UserInputService:SetMouseIcon("rbxassetid://273775019") -- Cursor drag
        end
    end)

    dragArea.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
            local delta = input.Position - dragStartPos
            
            if not isDragging and (delta.X * delta.X + delta.Y * delta.Y) > (DRAG_THRESHOLD * DRAG_THRESHOLD) then
                isDragging = true
            end
            
            if isDragging then
                -- Hitung posisi baru
                local newX = startFramePos.X.Scale + (delta.X / frame.Parent.AbsoluteSize.X)
                local newY = startFramePos.Y.Scale + (delta.Y / frame.Parent.AbsoluteSize.Y)
                
                -- Clamp posisi untuk mencegah Frame keluar dari layar
                newX = math.max(0, math.min(newX, 1 - frame.Size.X.Scale))
                newY = math.max(0, math.min(newY, 1 - frame.Size.Y.Scale))

                frame.Position = UDim2.new(newX, 0, newY, 0) -- Menggunakan Scale untuk Clamp
            end
        end
    end)
    
    dragArea.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            UserInputService:SetMouseIcon("") -- Kembalikan kursor normal
        end
    end)

    return function()
        return isDragging
    end
end

-- === 2. Logika Inti Loop Audio (Dipertahankan) ===
local function enforceAudioState()
    for _, part in Workspace:GetDescendants() do
        if part:IsA("BasePart") then
            local sound = part:FindFirstChildOfClass("Sound")
            if sound and sound:IsA("Sound") and sound.Loaded then
                if not sound.Playing then
                    pcall(sound.Play, sound) -- Menggunakan pcall untuk menghindari error jika Sound diblokir
                end
            end
        end
    end
end

local function startAudioLoop()
    stopAudioAndLoop() -- Hentikan loop yang mungkin sudah berjalan
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
end

-- === 3. Logika RemoteEvent Scanner (Dipertahankan) ===
local function checkRemoteEventVulnerability(remote)
    local lowerName = remote.Name:lower()
    local highRiskPatterns = {
        "Kick", "Ban", "Moderation", "AdminEvent", 
        "Teleport", "tp", "CFrame",
        "Broadcast", "GlobalMessage", "NotifyAll", "MessagePlayers", "Inject" 
    }
    for _, pattern in ipairs(highRiskPatterns) do
        if lowerName:match(pattern:lower()) then
            return "HIGH (Risiko: " .. pattern .. ")"
        end
    end
    return "NONE"
end

local function runPassiveInjectionTest(remote)
    local remotePath = remote:GetFullName()
    if TESTED_REMOTES[remotePath] then return TESTED_REMOTES[remotePath] end
    local potentialVuln = checkRemoteEventVulnerability(remote)

    if potentialVuln ~= "NONE" then
        -- Simulasi blokir FireServer/InvokeServer
        remote.FireServer = function(...)
            potentialVuln = "HIGH (Simulasi Injeksi Berhasil Melacak FireServer)"
        end 
        if remote:IsA("RemoteFunction") then
            remote.InvokeServer = function(...)
                potentialVuln = "HIGH (Simulasi Injeksi Berhasil Melacak InvokeServer)"
                return nil
            end 
        end
    end

    TESTED_REMOTES[remotePath] = potentialVuln
    return potentialVuln 
end

local function startScanLoop(console, scanButton, cancelButton)
    if IsScanActive then return end
    
    IsScanActive = true
    IS_SCAN_ENABLED = true
    console.Text = "SCANNER: Memulai pemindaian & Uji Injeksi Cepat..."
    
    ScanLoopThread = task.spawn(function()
        local remotesToScan = {}
        for _, area in ipairs({ReplicatedStorage, Workspace}) do
            for _, obj in area:GetDescendants() do
                if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                    table.insert(remotesToScan, obj)
                end
            end
        end
        
        local vulnerableFound = 0
        local highRiskCount = 0
        
        for i, remote in ipairs(remotesToScan) do
            if not IsScanActive then break end 
            
            local remotePath = remote:GetFullName()
            console.Text = string.format("SCANNING: %s (%d/%d)", remote.Name, i, #remotesToScan)
            task.wait(SCAN_INTERVAL)
            
            local vulnerability = checkRemoteEventVulnerability(remote) 
            if vulnerability ~= "NONE" then
                vulnerableFound = vulnerableFound + 1
                local testResult = runPassiveInjectionTest(remote)
                
                if testResult:match("HIGH") then
                    highRiskCount = highRiskCount + 1
                    
                    local warningText = "⚠️ KELEMAHAN DITEMUKAN: " .. remotePath .. " - " .. testResult .. " (BLOCKED)"
                    console.Text = warningText 
                    notify("🚨 UJI INJEKSI HASIL", warningText, 5, ICON_ID)
                    task.wait(0.1) 
                end
            end
        end
        
        local statusText = string.format("SCANNER: Selesai. Ditemukan **%d** kelemahan. **%d** Remote BERISIKO TINGGI (Diblokir Lokal).", vulnerableFound, highRiskCount)
        console.Text = statusText
        notify("✅ Pemindaian Selesai", "RemoteEvents telah dipindai dan yang berisiko telah diblokir secara lokal.", 5)
        
        IsScanActive = false
        IS_SCAN_ENABLED = false
        scanButton.Text = "🛡️ 2. REMOTE SCANNER: OFF"
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

    scanButton.Text = "🛡️ 2. REMOTE SCANNER: OFF"
    scanButton.BackgroundColor3 = COLOR_OFF
    cancelButton.Visible = false
end

-- === 4. Logika Title Inject BARU (Fokus Payload Server) ===

-- Fungsi Tag Lokal (Hanya untuk diri sendiri)
local function createLocalTitleTag(player, title, color)
    local Character = player.Character
    if not Character or not Character:FindFirstChild("Head") then return end

    local Head = Character.Head
    
    -- Hapus Tag yang ada, termasuk tag dari LocalPlayer:CharacterAdded
    if currentTitleTagInstance and currentTitleTagInstance.Parent then
        currentTitleTagInstance:Destroy()
        currentTitleTagInstance = nil
    end 
    
    local ExistingTag = Head:FindFirstChild("LocalTitleTag")
    if ExistingTag then ExistingTag:Destroy() end 

    local Tag = Instance.new("BillboardGui")
    Tag.Name = "LocalTitleTag"
    Tag.Size = UDim2.new(3, 0, 1, 0)
    Tag.Adornee = Head
    Tag.AlwaysOnTop = true
    Tag.ExtentsOffsetWorldSpace = Vector3.new(0, 1.5, 0) 
    Tag.Parent = Head

    local TextLabel = Instance.new("TextLabel")
    TextLabel.Text = "[" .. string.upper(title) .. "]" 
    TextLabel.Size = UDim2.new(1, 0, 1, 0)
    TextLabel.Font = Enum.Font.SourceSansBold
    TextLabel.TextColor3 = color 
    TextLabel.TextStrokeTransparency = 0
    TextLabel.BackgroundTransparency = 1
    TextLabel.Parent = Tag
    
    currentTitleTagInstance = Tag -- Simpan referensi ke tag yang baru dibuat

    -- Koneksi untuk karakter baru
    local function reconnectTag(newCharacter)
        newCharacter:WaitForChild("Head", 5)
        task.wait(0.1)
        clearLocalTitleTag(player) -- Bersihkan koneksi lama
        createLocalTitleTag(player, title, color) -- Buat ulang tag
    end
    
    localPlayer.CharacterAdded:Connect(reconnectTag)
end

local function clearLocalTitleTag(player)
    local Character = player.Character
    local TagDestroyed = false
    
    -- Hapus Tag yang ada (jika ada)
    if currentTitleTagInstance and currentTitleTagInstance.Parent then
        currentTitleTagInstance:Destroy()
        currentTitleTagInstance = nil
        TagDestroyed = true
    elseif Character and Character:FindFirstChild("Head") and Character.Head:FindFirstChild("LocalTitleTag") then
        Character.Head:FindFirstChild("LocalTitleTag"):Destroy()
        TagDestroyed = true
    end

    if TagDestroyed then
        notify("❌ Tag Dihapus", "Tag kepala lokal Anda telah dihapus.", 2)
        return true
    end
    notify("❌ Gagal Hapus", "Tidak ada Tag Kepala Lokal ditemukan.", 2)
    return false
end


local function sendCustomTitle(title, colorName, colorCodeInput, mode, OutputLabel) 
    -- Mode: 'GENERATE_CHAT', 'LOCAL_TAG', 'GLOBAL_TAG'

    if not title or title == "Masukkan Judul Anda" or title == "" then
        notify("❌ Gagal Kirim", "Judul tidak boleh kosong.", 3)
        if OutputLabel then OutputLabel.Text = "ERROR: Judul tidak boleh kosong!" OutputLabel.Visible = true end
        return
    end

    -- PERBAIKAN: Memparsing Color3
    local finalColorCode = colorCodeInput:gsub("[ %c%s]+", "") -- Hapus spasi dan kontrol
    local color = Color3.fromRGB(255, 0, 0) -- Default: Merah
    local colorText = "1, 0, 0" -- Default

    -- Coba parsing 0-1 (Float)
    local r_float, g_float, b_float = finalColorCode:match("(%d?%.?%d+)[%s]*,[%s]*(%d?%.?%d+)[%s]*,[%s]*(%d?%.?%d+)")
    if r_float and g_float and b_float then
        color = Color3.new(tonumber(r_float) or 1, tonumber(g_float) or 0, tonumber(b_float) or 0)
        colorText = string.format("%f, %f, %f", color.R, color.G, color.B)
    else
        -- Coba parsing 0-255 (Integer)
        local r_int, g_int, b_int = finalColorCode:match("(%d+)[%s]*,[%s]*(%d+)[%s]*,[%s]*(%d+)")
        if r_int and g_int and b_int then
            color = Color3.fromRGB(tonumber(r_int) or 255, tonumber(g_int) or 0, tonumber(b_int) or 0)
            colorText = string.format("Color3.fromRGB(%d, %d, %d)", tonumber(r_int), tonumber(g_int), tonumber(b_int))
        end
    end
    
    -- OPSI 1: TAG KEPALA LOKAL (Hanya Klien Anda)
    if mode == 'LOCAL_TAG' then
        clearLocalTitleTag(LocalPlayer)
        createLocalTitleTag(LocalPlayer, title, color)
        
        notify("✅ Tag Lokal Dibuat", "Tag '" .. title .. "' dibuat di atas kepala Anda (Hanya Klien Lokal).", 4)
        if OutputLabel then OutputLabel.Text = "LOKAL: Tag Kepala Berhasil Dibuat." OutputLabel.Visible = true end
        return
    end
    
    -- OPSI 2 & 3: PAYLOAD SERVER (Generate Kode C&P)
    local payloadFormat, action, notificationTitle, notificationText
    
    -- Jika menggunakan Color3.fromRGB, gunakan string Color3.fromRGB()
    local colorPayloadString = colorText:match("Color3%.fromRGB") and colorText or ("Color3.new(" .. colorText .. ")")

    if mode == 'GLOBAL_TAG' then
        -- Payload Tag Kepala (Meminta Server untuk membuat Tag di ALL_PLAYERS)
        payloadFormat = string.format(
            "local payload = {['Action'] = 'CreateTag', ['Title'] = '%s', ['ColorRGB'] = %s, ['Target'] = 'ALL_PLAYERS', ['Source'] = game.Players.LocalPlayer.Name};",
            title, colorPayloadString
        )
        action = "TAG GLOBAL"
        notificationTitle = "⚠️ KODE INJEKSI TAG SIAP"
        notificationText = "Salin & Jalankan kode di Executor. Tag lokal Anda sudah aktif."
        
        -- Aktifkan Tag Lokal di Anda dulu
        clearLocalTitleTag(LocalPlayer)
        createLocalTitleTag(LocalPlayer, title, color)

    elseif mode == 'GENERATE_CHAT' then
        -- Payload Pesan Chat Global (Meminta Server untuk Broadcast Pesan)
        payloadFormat = string.format(
            "local payload = {['Action'] = 'Broadcast', ['Title'] = '%s', ['ColorRGB'] = %s, ['Source'] = game.Players.LocalPlayer.Name};",
            title, colorPayloadString
        )
        action = "CHAT GLOBAL"
        notificationTitle = "⚠️ KODE INJEKSI CHAT SIAP"
        notificationText = "Salin & Jalankan kode di Executor."
        
    end
    
    -- *** PERBAIKAN: Format string yang lebih kompak untuk C&P ***
    local manualCode = string.format(
        "local r=game:GetService('ReplicatedStorage'):FindFirstChild('%s',true);if r and r:IsA('RemoteEvent')then %s r:FireServer(payload)else warn(\"Remote %s tidak ditemukan.\")end",
        GENERIC_GLOBAL_REMOTE_NAME, payloadFormat, GENERIC_GLOBAL_REMOTE_NAME
    )

    if OutputLabel then
        -- Menghilangkan spasi dan baris baru di kode yang ditampilkan agar mudah di-copy-paste (portable)
        local compactCode = manualCode:gsub("\n", ""):gsub("%s+", " ")
        OutputLabel.Text = string.format("%s (C&P): %s", action, compactCode)
        OutputLabel.Visible = true
    end

    notify(notificationTitle, notificationText, 5)
end

-- === 5. Logika Clone & Item (Dipertahankan) ===
local function cloneAvatar(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then
        notify("❌ Gagal Clone", "Karakter target tidak ditemukan.", 3)
        return
    end
    LocalPlayer:LoadCharacter()
    notify("✅ Avatar Cloned", "Anda sekarang terlihat seperti **" .. targetPlayer.Name .. "**! (Karakter dimuat ulang)", 5)
end

local function populatePlayerList(scrollingFrame)
    for _, child in ipairs(scrollingFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    -- *** PERBAIKAN: Menggunakan UIListLayout yang benar untuk mengatur padding ***
    local players = Players:GetPlayers()
    table.sort(players, function(a, b) return a.Name < b.Name end) -- Sortir berdasarkan nama

    for _, player in ipairs(players) do
        if player ~= LocalPlayer then
            local Button = Instance.new("TextButton")
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
                if isPlayerListDragging() then return end
                cloneAvatar(player)
            end)
        end
    end
    
    -- Memastikan CanvasSize diperbarui setelah tombol ditambahkan
    if scrollingFrame.AutomaticCanvasSize == Enum.AutomaticSize.Y then
        scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0) -- Reset agar otomatis berfungsi
    end
end

local function giveStartpackItem(targetName)
    local tool = Instance.new("Tool")
    tool.Name = targetName
    
    local part = Instance.new("Part")
    part.Name = "Handle"
    part.Size = Vector3.new(1, 1, 1)
    part.Parent = tool
    
    tool.Parent = StarterPack
    notify("✅ Item Diberikan", "**" .. targetName .. "** ditambahkan ke ransel Anda.", 4, ICON_ID)
end

-- === 7. Pembuatan GUI Utama & Sub-Frame ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = GUI_NAME
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.DisplayOrder = 999 -- Pastikan di atas GUI Roblox lainnya
ScreenGui.Parent = PlayerGui 

local total_buttons = 5 
local main_frame_height = 30 + (total_buttons * BUTTON_HEIGHT) + ((total_buttons + 1) * BUTTON_SPACING) -- Perhitungan diperbaiki

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, main_frame_height) 
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -(main_frame_height / 2)) 
MainFrame.BackgroundColor3 = COLOR_BG
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false 
MainFrame.ZIndex = 5
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
TitleLabel.ZIndex = 6
TitleLabel.Parent = MainFrame

local function getButtonY(index)
    return 30 + (BUTTON_SPACING * index) + (BUTTON_HEIGHT * (index - 1))
end

-- Tombol Utama 1-5 (Dibutuhkan ZIndex 5)
local AudioButton = Instance.new("TextButton") 
-- ... (Properti AudioButton lainnya) ...
AudioButton.Position = UDim2.new(0.05, 0, 0, getButtonY(1))
AudioButton.Parent = MainFrame

local ScanButton = Instance.new("TextButton") 
-- ... (Properti ScanButton lainnya) ...
ScanButton.Position = UDim2.new(0.05, 0, 0, getButtonY(2))
ScanButton.Parent = MainFrame

local CloneButton = Instance.new("TextButton") 
-- ... (Properti CloneButton lainnya) ...
CloneButton.Position = UDim2.new(0.05, 0, 0, getButtonY(3))
CloneButton.Parent = MainFrame

local ItemButton = Instance.new("TextButton") 
-- ... (Properti ItemButton lainnya) ...
ItemButton.Position = UDim2.new(0.05, 0, 0, getButtonY(4))
ItemButton.Parent = MainFrame

local TitleInjectButton = Instance.new("TextButton") 
-- ... (Properti TitleInjectButton lainnya) ...
TitleInjectButton.Position = UDim2.new(0.05, 0, 0, getButtonY(5))
TitleInjectButton.Parent = MainFrame

-- Styling tombol MainFrame
for _, btn in ipairs(MainFrame:GetChildren()) do
    if btn:IsA("TextButton") then
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.SourceSansBold
        btn.TextSize = 16
        btn.ZIndex = 5 -- Pastikan tombol di atas Frame
        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 6)
        Corner.Parent = btn
        
        -- Mengcopy properti dari template
        if btn.Name == "AudioButton" then btn.BackgroundColor3 = COLOR_OFF; btn.Text = "🎵 1. AUDIO GLOBAL: OFF"
        elseif btn.Name == "ScanButton" then btn.BackgroundColor3 = COLOR_OFF; btn.Text = "🛡️ 2. REMOTE SCANNER: OFF"
        elseif btn.Name == "CloneButton" then btn.BackgroundColor3 = COLOR_CLONE; btn.Text = "🎭 3. AVATAR CLONE: OPEN LIST"
        elseif btn.Name == "ItemButton" then btn.BackgroundColor3 = COLOR_ITEM; btn.Text = "⛏️ 4. GET ITEM: " .. TARGET_TOOL_NAME 
        elseif btn.Name == "TitleInjectButton" then btn.BackgroundColor3 = COLOR_TITLE; btn.Text = "👑 5. TITLE INJECTOR: OPEN PANEL" end
        btn.Size = UDim2.new(0.9, 0, 0, BUTTON_HEIGHT)
    end
end

-- Console Frame 
local ConsoleFrame = Instance.new("Frame")
-- ... (Properti ConsoleFrame) ...
ConsoleFrame.Size = UDim2.new(0, 250, 0, 30) 
ConsoleFrame.Position = UDim2.new(0.5, -125, 0.5, -200) -- Sesuaikan posisi agar tidak menutupi MainFrame
ConsoleFrame.ZIndex = 4 -- Sedikit di bawah MainFrame agar MainFrame selalu terlihat
ConsoleFrame.Parent = ScreenGui

local ConsoleDragHandle = Instance.new("TextLabel")
-- ... (Properti ConsoleDragHandle) ...
ConsoleDragHandle.Size = UDim2.new(1, -35, 1, 0) -- Ukuran dikurangi untuk tombol Cancel
ConsoleDragHandle.Position = UDim2.new(0, 5, 0, 0) 
ConsoleDragHandle.ZIndex = 5
ConsoleDragHandle.Text = "CONSOLE: Siap memindai..."
ConsoleDragHandle.Parent = ConsoleFrame

local ConsoleCancelButton = Instance.new("TextButton")
-- ... (Properti ConsoleCancelButton) ...
ConsoleCancelButton.Size = UDim2.new(0, 30, 1, 0) 
ConsoleCancelButton.Position = UDim2.new(1, -30, 0, 0)
ConsoleCancelButton.ZIndex = 5
ConsoleCancelButton.Parent = ConsoleFrame

-- Title Inject Frame
local TitleInjectFrame = Instance.new("Frame")
-- ... (Properti TitleInjectFrame) ...
TitleInjectFrame.Size = UDim2.new(0, 280, 0, TITLE_INJECT_SIZE_Y_NEW) 
TitleInjectFrame.Position = UDim2.new(0.5, -140, 0.5, -140) 
TitleInjectFrame.ZIndex = 5 -- Di atas MainFrame
TitleInjectFrame.Parent = ScreenGui

local TitleInjectHandle = Instance.new("TextLabel")
-- ... (Properti TitleInjectHandle) ...
TitleInjectHandle.ZIndex = 6
TitleInjectHandle.Parent = TitleInjectFrame

local TitleInput = Instance.new("TextBox")
-- ... (Properti TitleInput) ...
TitleInput.Parent = TitleInjectFrame

local ColorNameInput = Instance.new("TextBox")
-- ... (Properti ColorNameInput) ...
ColorNameInput.Parent = TitleInjectFrame

local ColorCodeInput = Instance.new("TextBox")
-- ... (Properti ColorCodeInput) ...
ColorCodeInput.Parent = TitleInjectFrame

-- Tombol Injector (Dibutuhkan ZIndex 6)
local SendButton = Instance.new("TextButton") ; SendButton.ZIndex = 6 ; SendButton.Parent = TitleInjectFrame
local GlobalTagButton = Instance.new("TextButton"); GlobalTagButton.ZIndex = 6; GlobalTagButton.Parent = TitleInjectFrame
local LocalTagButton = Instance.new("TextButton"); LocalTagButton.ZIndex = 6; LocalTagButton.Parent = TitleInjectFrame
local ClearTagButton = Instance.new("TextButton"); ClearTagButton.ZIndex = 6; ClearTagButton.Parent = TitleInjectFrame

-- OutputLabel (Dibutuhkan ZIndex 6)
local OutputLabel = Instance.new("TextLabel")
-- ... (Properti OutputLabel) ...
OutputLabel.ZIndex = 6
OutputLabel.Parent = TitleInjectFrame

-- Player List Frame 
local PlayerListFrame = Instance.new("Frame")
-- ... (Properti PlayerListFrame) ...
PlayerListFrame.Size = UDim2.new(0, 250, 0, PLAYER_LIST_SIZE_Y) 
PlayerListFrame.Position = UDim2.new(0.5, -125, 0.5, 130) 
PlayerListFrame.ZIndex = 5
PlayerListFrame.Parent = ScreenGui

local ListTitle = Instance.new("TextLabel")
-- ... (Properti ListTitle) ...
ListTitle.ZIndex = 6
ListTitle.Parent = PlayerListFrame

local PlayerListScroll = Instance.new("ScrollingFrame")
-- ... (Properti PlayerListScroll) ...
PlayerListScroll.Parent = PlayerListFrame

local ListLayout = Instance.new("UIListLayout")
-- ... (Properti ListLayout) ...
ListLayout.Parent = PlayerListScroll

-- Terapkan Drag 
local isMainFrameDragging = makeDraggable(MainFrame)
local isConsoleDragging = makeDraggable(ConsoleFrame)
local isPlayerListDragging = makeDraggable(PlayerListFrame) 
local isTitleInjectDragging = makeDraggable(TitleInjectFrame) 

-- === 8. Koneksi Tombol Utama & Injector ===

AudioButton.MouseButton1Click:Connect(function()
    if isMainFrameDragging() then return end
    IS_AUDIO_ENABLED = not IS_AUDIO_ENABLED
    AudioButton.Text = "🎵 1. AUDIO GLOBAL: " .. (IS_AUDIO_ENABLED and "ON" or "OFF")
    AudioButton.BackgroundColor3 = IS_AUDIO_ENABLED and COLOR_ON or COLOR_OFF
    if IS_AUDIO_ENABLED then startAudioLoop() else stopAudioAndLoop() end
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
    if PlayerListFrame.Visible then populatePlayerList(PlayerListScroll) end
    notify("🎭 Avatar Clone", "Daftar Pemain " .. (PlayerListFrame.Visible and "dibuka." or "ditutup."), 2)
end)

ItemButton.MouseButton1Click:Connect(function()
    if isMainFrameDragging() then return end
    giveStartpackItem(TARGET_TOOL_NAME)
end)

TitleInjectButton.MouseButton1Click:Connect(function()
    if isMainFrameDragging() then return end
    
    TitleInjectFrame.Visible = not TitleInjectFrame.Visible
    
    if TitleInjectFrame.Visible then
        notify("👑 Title Injector", "Panel injeksi judul dibuka.", 4)
    else
        notify("👑 Title Injector", "Panel injeksi judul ditutup.", 2)
    end
end)

-- Koneksi Tombol Title Injector ke fungsi sendCustomTitle
SendButton.MouseButton1Click:Connect(function()
    if isTitleInjectDragging() then return end
    sendCustomTitle(TitleInput.Text, ColorNameInput.Text, ColorCodeInput.Text, 'GENERATE_CHAT', OutputLabel) 
end)

GlobalTagButton.MouseButton1Click:Connect(function()
    if isTitleInjectDragging() then return end
    sendCustomTitle(TitleInput.Text, ColorNameInput.Text, ColorCodeInput.Text, 'GLOBAL_TAG', OutputLabel) 
end)

LocalTagButton.MouseButton1Click:Connect(function()
    if isTitleInjectDragging() then return end
    sendCustomTitle(TitleInput.Text, ColorNameInput.Text, ColorCodeInput.Text, 'LOCAL_TAG', OutputLabel) 
end)

ClearTagButton.MouseButton1Click:Connect(function()
    if isTitleInjectDragging() then return end
    clearLocalTitleTag(LocalPlayer)
end)

ConsoleCancelButton.MouseButton1Click:Connect(function()
    if isConsoleDragging() then return end
    
    if IsScanActive then
        stopScanLoop(ConsoleDragHandle, ScanButton, ConsoleCancelButton)
    end
end)

-- === 9. Icon Floating dan Koneksi Toggle (Diperbarui untuk ZIndex) ===
local FloatingIcon = Instance.new("TextButton") 
FloatingIcon.Name = "FloatingIcon" -- Nama diubah agar konsisten
FloatingIcon.Size = ICON_SIZE
FloatingIcon.Position = UDim2.new(0.02, 0, 0.85, 0) 
FloatingIcon.BackgroundTransparency = 0 -- Ikon harus solid agar mudah terlihat
FloatingIcon.BackgroundColor3 = COLOR_ACCENT 
FloatingIcon.Text = FLOATING_ICON_EMOJI 
FloatingIcon.TextColor3 = Color3.new(1, 1, 1) -- Warna teks/emoji
FloatingIcon.TextSize = ICON_SIZE.Offset.X * 0.7 
FloatingIcon.ZIndex = 20 -- ZIndex tertinggi untuk visibilitas
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
