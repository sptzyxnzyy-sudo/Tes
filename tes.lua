--[ Executor Lua Code - Audio Global Player ]--

-- === Konfigurasi ===
local TOGGLE_KEY = Enum.KeyCode.RightControl -- Tombol untuk menampilkan/menyembunyikan GUI
local GUI_NAME = "AudioExecutorGUI"
local ICON_ID = "rbxassetid://7335147596" -- Ganti dengan ID Icon yang Anda inginkan
local IS_ENABLED = false

-- === Helper Functions (Simulasi Executor) ===

-- Fungsi Notifikasi (Sering diimplementasikan sebagai fungsi global di Executor)
local function notify(title, text, duration)
    if not game:IsLoaded() then return end
    -- Menggunakan fungsi notifikasi bawaan Roblox untuk kompatibilitas yang lebih luas
    game.StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = duration or 3,
        Icon = ICON_ID,
        -- Tidak semua executor mendukung semua parameter SetCore
    })
end

-- Fungsi Toggle Audio: Inti Logika
local function toggleGlobalAudio(shouldPlay)
    local partCount = 0
    local workspace = game:GetService("Workspace")

    for _, part in workspace:GetDescendants() do
        -- Pastikan itu BasePart dan memiliki Sound
        if part:IsA("BasePart") then
            local sound = part:FindFirstChildOfClass("Sound")
            if sound and sound:IsA("Sound") then
                partCount = partCount + 1
                -- Sound:Play() yang dijalankan pada LocalScript/Executor
                -- di Part di Workspace akan didengar secara global 
                -- asalkan properti Sound dikonfigurasi dengan benar (atau FilteringEnabled diabaikan oleh Executor).
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

-- === Logika GUI dan Tombol Switch ===

local PlayerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = GUI_NAME
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 100)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -50)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true -- Penting untuk drag
MainFrame.Draggable = true -- Penting untuk drag
MainFrame.Parent = ScreenGui

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0, 30)
TitleLabel.Position = UDim2.new(0, 0, 0, 0)
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
    
    -- Alur Kerja: Scan -> Proses -> Tampilkan Notifikasi
    toggleGlobalAudio(IS_ENABLED)
    
    SwitchButton.BackgroundColor3 = IS_ENABLED and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(50, 50, 50)
end)

-- Pasang GUI
ScreenGui.Parent = PlayerGui
notify("✅ Executor Loaded", "GUI Audio Global siap. Tekan Right Control untuk toggle GUI.", 4)

-- === Fungsi Tombol Toggle Icon (Sembunyikan/Tampilkan GUI) ===
local UIS = game:GetService("UserInputService")
local isHidden = false

-- Logika Cancel GUI / Toggle
UIS.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == TOGGLE_KEY and not gameProcessed then
        isHidden = not isHidden
        MainFrame.Visible = not isHidden
        
        -- Tampilkan notifikasi saat toggle GUI
        notify("⚙️ GUI Status", "GUI audio: " .. (not isHidden and "Terlihat" or "Tersembunyi"), 2)
    end
end)
