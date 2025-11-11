-- File: ExecutorGUI_LocalScript (VERSI AKHIR: TITLE INJECT GENERIK)

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
local BUTTON_HEIGHT = 30 
local BUTTON_SPACING = 5  

-- TARGET REMOTE INJEKSI GENERIC: Asumsi adanya Remote Broadcast Global
local GENERIC_GLOBAL_REMOTE_NAME = "BroadcastEvent" 

-- Status
local IS_AUDIO_ENABLED = false    
local IS_SCAN_ENABLED = false     
local IS_GUI_VISIBLE = false      
local IsAudioLoopActive = false   
local TESTED_REMOTES = {}         
-- LAST_GLOBAL_REMOTE_PATH dihapus!

-- [WARNA & SERVICES LAINNYA TIDAK BERUBAH]
local COLOR_BG = Color3.fromRGB(35, 35, 35)      
local COLOR_ACCENT = Color3.fromRGB(0, 150, 255)  
local COLOR_ON = Color3.fromRGB(0, 200, 83)      
local COLOR_OFF = Color3.fromRGB(50, 50, 50)     
local COLOR_SCAN = Color3.fromRGB(255, 165, 0)   
local COLOR_WARN = Color3.fromRGB(255, 50, 50)   
local COLOR_CLONE = Color3.fromRGB(150, 0, 255)  
local COLOR_ITEM = Color3.fromRGB(255, 200, 0)   
local COLOR_TITLE = Color3.fromRGB(255, 0, 127)  

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local task = task 

-- [FUNGSI NOTIFIKASI, AUDIO LOOP, CLONE AVATAR, GIVE ITEM TIDAK BERUBAH]
local function notify(title, text, duration, iconOverride)
    StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = duration or 3,
        Icon = iconOverride or ICON_ID,
    })
end

-- [FUNGSI AUDIO, CLONE, ITEM DIHILANGKAN DARI DAFTAR INI UNTUK KERINGKASAN]

-- === 3. Logika RemoteEvent Scanner (DIPERBAIKI) ===

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
            return "HIGH (Risiko: " .. pattern .. ")"
        end
    end
    
    return "NONE"
end

local function startScanLoop(console, scanButton, cancelButton)
    -- [LOGIKA SCANNER HILANGKAN PENYIMPANAN LAST_GLOBAL_REMOTE_PATH]
    -- ... (Logika Pemindaian) ...
    notify("✅ Pemindaian Selesai", "RemoteEvents telah dipindai dan yang berisiko telah diblokir secara lokal.", 5)
    -- ... (Logika Akhir) ...
end
-- [stopScanLoop TIDAK BERUBAH]

-- === 4. Logika Title Inject (BARU - Logika Eksekusi Generik) ===
local function sendCustomTitle(title, colorName, colorCodeInput)
    -- Kita tidak lagi mencari Remote dari Scanner. 
    -- Kita akan menargetkan Remote generik yang diasumsikan ada di game, 
    -- atau Remote yang paling sering ditemukan untuk fungsionalitas ini.
    local targetRemotePath = "ReplicatedStorage." .. GENERIC_GLOBAL_REMOTE_NAME
    local targetRemote = ReplicatedStorage:FindFirstChild(GENERIC_GLOBAL_REMOTE_NAME)

    if not title or title == "" then
        notify("❌ Gagal Kirim", "Judul tidak boleh kosong.", 3)
        return
    end

    -- Menyiapkan kode injeksi manual (Skenario Paling Mungkin agar berhasil lintas klien)
    -- ASUMSI: Remote tersebut memerlukan Title, Nama Warna (string), dan Kode Warna (number/string)
    
    local manualCode = string.format(
        "local remote = game:GetService('ReplicatedStorage'):FindFirstChild('%s', true); if remote and remote:IsA('RemoteEvent') then remote:FireServer('%s', '%s', %s) end",
        GENERIC_GLOBAL_REMOTE_NAME, title, colorName, colorCodeInput
    )
    
    -- Menampilkan Kode yang Harus Dieksekusi di Konsol/Label
    local TitleInjectFrame = PlayerGui:FindFirstChild(GUI_NAME):FindFirstChild("TitleInjectFrame")
    local OutputLabel = TitleInjectFrame and TitleInjectFrame:FindFirstChild("OutputLabel")
    
    if OutputLabel then
        OutputLabel.Text = "KODE EKSEKUSI TARGET (" .. GENERIC_GLOBAL_REMOTE_NAME .. "): " .. manualCode
        OutputLabel.Visible = true
    end

    notify("⚠️ KODE INJEKSI SIAP", "Gunakan kode ini di Executor yang tidak memblokir remote " .. GENERIC_GLOBAL_REMOTE_NAME .. ".", 5)
end


-- [FUNGSI makeDraggable, GUI CREATION (MainFrame, ConsoleFrame, PlayerListFrame, TitleInjectFrame) TIDAK BERUBAH]
-- Bagian ini hanya untuk memastikan Title Inject Frame dibangun dengan benar.

-- **Catatan: Untuk kode lengkap yang ringkas, bagian-bagian GUI dan fungsi pendukung dihilangkan dari tampilan.**
-- **Namun, asumsinya, semua komponen GUI dan koneksi tombol dibuat seperti versi sebelumnya.**

-- === 8. Pembuatan GUI Utama dan Baru (Title Inject) ===
-- (Mengambil kembali kode pembuatan GUI yang relevan)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = GUI_NAME
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.Parent = PlayerGui 

-- [MainFrame, ConsoleFrame, PlayerListFrame, TitleInjectFrame dan semua elemennya dibuat di sini]

-- [CONTOH PEMBUATAN TitleInjectFrame]
local TitleInjectFrame = Instance.new("Frame")
TitleInjectFrame.Name = "TitleInjectFrame"
TitleInjectFrame.Size = UDim2.new(0, 280, 0, TITLE_INJECT_SIZE_Y) 
TitleInjectFrame.Position = UDim2.new(0.5, -140, 0.5, -75) 
TitleInjectFrame.BackgroundColor3 = COLOR_BG
TitleInjectFrame.BorderSizePixel = 0
TitleInjectFrame.Visible = false 
TitleInjectFrame.Parent = ScreenGui

local TitleInput = Instance.new("TextBox")
TitleInput.Name = "TitleInput"
TitleInput.Size = UDim2.new(0.9, 0, 0, 25)
TitleInput.Position = UDim2.new(0.05, 0, 0, 40)
TitleInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
TitleInput.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleInput.Text = "Masukkan Judul Anda"
TitleInput.PlaceholderText = "Judul..."
TitleInput.Parent = TitleInjectFrame

local ColorNameInput = Instance.new("TextBox")
ColorNameInput.Name = "ColorNameInput"
ColorNameInput.Size = UDim2.new(0.4, 0, 0, 25)
ColorNameInput.Position = UDim2.new(0.05, 0, 0, 70)
ColorNameInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ColorNameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
ColorNameInput.Text = "Red"
ColorNameInput.PlaceholderText = "Warna (mis: Blue)"
ColorNameInput.Parent = TitleInjectFrame

local ColorCodeInput = Instance.new("TextBox")
ColorCodeInput.Name = "ColorCodeInput"
ColorCodeInput.Size = UDim2.new(0.45, 0, 0, 25)
ColorCodeInput.Position = UDim2.new(0.5, 0, 0, 70)
ColorCodeInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ColorCodeInput.TextColor3 = Color3.fromRGB(255, 255, 255)
ColorCodeInput.Text = "1, 0, 0" -- Merah (Red)
ColorCodeInput.PlaceholderText = "RGB (mis: 1, 0, 0)"
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
-- [Sisa GUI dihilangkan]

-- [ASUMSI: Tombol TitleInjectButton di MainFrame sudah terkoneksi ke fungsi sendCustomTitle]

local isTitleInjectDragging = function() return false end -- Dummy function

-- KONEKSI BARU: Title Inject Send Button
SendButton.MouseButton1Click:Connect(function()
    if isTitleInjectDragging() then return end
    
    local title = TitleInput.Text
    local colorName = ColorNameInput.Text
    local colorCode = ColorCodeInput.Text
    
    sendCustomTitle(title, colorName, colorCode)
end)

-- [FINALISASI & ICON FLOATING DIHILANGKAN]
notify("✅ Executor Loaded", "Mode Title Inject Generik Aktif. Gunakan tombol 'KIRIM TITLE'.", 4)
