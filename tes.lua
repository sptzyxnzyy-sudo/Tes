--[ Executor Lua Code - Audio Global Player with Floating Icon ]--

-- === Konfigurasi ===
local GUI_NAME = "AudioExecutorGUI"
local ICON_ID = "rbxassetid://7335147596" -- Ganti dengan Icon ID yang Anda inginkan (misal: icon speaker)
local ICON_SIZE = UDim2.new(0, 40, 0, 40)
local IS_ENABLED = false
local IS_GUI_VISIBLE = false -- Status visibility GUI utama

-- === Service dan Player ===
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- === 1. Fungsi Notifikasi (Simulasi Executor) ===
local function notify(title, text, duration)
    -- Menggunakan fungsi notifikasi bawaan Roblox untuk kompatibilitas
    StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = duration or 3,
        Icon = ICON_ID,
    })
end

-- === 2. Logika Pemutaran Audio (Scan & Proses) ===
local function toggleGlobalAudio(shouldPlay)
    local partCount = 0
    local workspace = game:GetService("Workspace")

    for _, part in workspace:GetDescendants() do
        if part:IsA("BasePart") then
            local sound = part:FindFirstChildOfClass("Sound")
            if sound and sound:IsA("Sound") then
                partCount = partCount + 1
                -- Memanggil Play/Stop di klien (executor)
                if shouldPlay then
                    if not sound.Playing then
                        sound:Play()
                    end
                else
                    if sound.Playing then
                        sound:Stop()
                    end
                end
            end
        end
    end

    -- Tampilkan Notifikasi Hasil
    local status = shouldPlay and "DIJALANKAN" or "DIHENTIKAN"
    local notifText = string.format("Fitur audio global telah %s.\nMemproses %d part audio.", status, partCount)
    notify("🔊 Audio Executor", notifText, 5)

    return partCount
end

-- === 3. Pembuatan GUI Utama (Panel) ===

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = GUI_NAME
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 100)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -50)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false -- Mulai dalam keadaan tersembunyi
MainFrame.Parent = ScreenGui

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0, 30)
TitleLabel.BackgroundColor3 = Color3.fromRGB(0, 150, 150)
TitleLabel.Text = "🎵 Global Audio Player"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextSize = 20
TitleLabel.Parent = MainFrame

local SwitchButton = Instance.new("TextButton")
SwitchButton.Size = UDim2.new(0.8, 0, 0, 40)
SwitchButton.Position = UDim2.new(0.1, 0, 0, 45)
SwitchButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SwitchButton.Text = "Audio Global: OFF"
SwitchButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SwitchButton.Font = Enum.Font.SourceSans
SwitchButton.TextSize = 18
SwitchButton.Parent = MainFrame

-- Fungsi Tombol Switch
SwitchButton.MouseButton1Click:Connect(function()
    IS_ENABLED = not IS_ENABLED
    SwitchButton.Text = "Audio Global: " .. (IS_ENABLED and "ON" or "OFF")
    
    -- Proses Audio
    toggleGlobalAudio(IS_ENABLED)
    
    SwitchButton.BackgroundColor3 = IS_ENABLED and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(50, 50, 50)
end)

-- === 4. Icon Floating (Tombol Toggle) ===

local FloatingIcon = Instance.new("ImageButton")
FloatingIcon.Name = "AudioToggleIcon"
FloatingIcon.Size = ICON_SIZE
FloatingIcon.Position = UDim2.new(0.02, 0, 0.85, 0) -- Pojok Kiri Bawah (dapat disesuaikan)
FloatingIcon.BackgroundTransparency = 1
FloatingIcon.Image = ICON_ID
FloatingIcon.ZIndex = 99
FloatingIcon.Parent = ScreenGui -- Diletakkan di ScreenGui yang sama

-- Fungsi Tombol Icon (Alur: Icon -> GUI)
FloatingIcon.MouseButton1Click:Connect(function()
    IS_GUI_VISIBLE = not IS_GUI_VISIBLE
    MainFrame.Visible = IS_GUI_VISIBLE -- Tampilkan/Sembunyikan GUI utama
    
    -- Tampilkan notifikasi saat toggle GUI
    notify("⚙️ GUI Status", "Panel Audio: " .. (IS_GUI_VISIBLE and "Terlihat" or "Tersembunyi"), 2)
end)

-- === 5. Pasang GUI dan Notifikasi Awal ===
ScreenGui.Parent = PlayerGui

notify("✅ Executor Loaded", "Icon floating telah aktif. Klik icon untuk membuka panel.", 4)
