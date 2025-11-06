--[ Executor Lua Code - Global Audio Player (Optimized Modern GUI) ]--

-- === Konfigurasi & Service ===
local GUI_NAME = "AudioExecutorGUI"
local ICON_ID = "rbxassetid://7335147596" -- Icon Asset ID untuk Notifikasi
local FLOATING_ICON_EMOJI = "🛡️"
local ICON_SIZE = UDim2.new(0, 50, 0, 50) 
local IS_ENABLED = false
local IS_GUI_VISIBLE = false 
local DRAG_THRESHOLD = 5 -- Batas pixel untuk membedakan click dari drag

-- Warna Modern/Minimalis
local COLOR_BG = Color3.fromRGB(35, 35, 35)      
local COLOR_ACCENT = Color3.fromRGB(0, 150, 255)  
local COLOR_ON = Color3.fromRGB(0, 200, 83)      
local COLOR_OFF = Color3.fromRGB(50, 50, 50)     

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- === 1. Fungsi Notifikasi ===
local function notify(title, text, duration)
    StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = duration or 3,
        Icon = ICON_ID,
    })
end

-- === 2. Logika Inti: Toggle Global Audio ===
local function toggleGlobalAudio(shouldPlay)
    local partCount = 0
    local workspace = game:GetService("Workspace")

    for _, part in workspace:GetDescendants() do
        if part:IsA("BasePart") then
            local sound = part:FindFirstChildOfClass("Sound")
            if sound and sound:IsA("Sound") then
                partCount = partCount + 1
                
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

    local status = shouldPlay and "DIJALANKAN" or "DIHENTIKAN"
    local notifText = string.format("Fitur audio global telah %s.\nMemproses %d part audio.", status, partCount)
    notify("🔊 Audio Executor", notifText, 5)
end

-- === 3. Fungsi Drag GUI (Optimized) ===
-- Mengembalikan fungsi checkDrag yang menentukan apakah input adalah drag atau click
local function makeDraggable(frame)
    local dragging = false
    local dragStartPos = nil
    local startFramePos = nil
    local isDragging = false -- Status ini yang akan diperiksa oleh MouseButton1Click

    -- Tentukan area yang bisa di-drag
    local dragArea = frame:FindFirstChild("DragHandle") or frame
    dragArea.Active = true

    dragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            isDragging = false -- Reset status drag
            dragStartPos = input.Position
            startFramePos = frame.Position
        end
    end)

    dragArea.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
            local delta = input.Position - dragStartPos
            
            -- Jika pergerakan melebihi batas, maka ini adalah drag
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

-- === 4. Pembuatan GUI Utama (Frame, Judul, Tombol Switch) ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = GUI_NAME
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 110) 
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -55)
MainFrame.BackgroundColor3 = COLOR_BG
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false 
MainFrame.Parent = ScreenGui

-- Rounded Corners pada MainFrame
local CornerMain = Instance.new("UICorner")
CornerMain.CornerRadius = UDim.new(0, 8) 
CornerMain.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "DragHandle" -- Area drag
TitleLabel.Size = UDim2.new(1, 0, 0, 30)
TitleLabel.BackgroundColor3 = COLOR_ACCENT
TitleLabel.Text = "🎵 GLOBAL AUDIO PLAYER"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.SourceSansSemibold
TitleLabel.TextSize = 18
TitleLabel.Active = true 
TitleLabel.Parent = MainFrame

local SwitchButton = Instance.new("TextButton") 
SwitchButton.Size = UDim2.new(0.9, 0, 0, 40)
SwitchButton.Position = UDim2.new(0.05, 0, 0, 60)
SwitchButton.BackgroundColor3 = COLOR_OFF
SwitchButton.Text = "AUDIO GLOBAL: OFF"
SwitchButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SwitchButton.Font = Enum.Font.SourceSansBold
SwitchButton.TextSize = 18
SwitchButton.Parent = MainFrame

local CornerButton = Instance.new("UICorner")
CornerButton.CornerRadius = UDim.new(0, 6)
CornerButton.Parent = SwitchButton

-- Terapkan drag pada MainFrame (menggunakan TitleLabel sebagai handle)
local isMainFrameDragging = makeDraggable(MainFrame)

-- Koneksi Tombol Switch
SwitchButton.MouseButton1Click:Connect(function()
    IS_ENABLED = not IS_ENABLED
    SwitchButton.Text = "Audio Global: " .. (IS_ENABLED and "ON" or "OFF")
    toggleGlobalAudio(IS_ENABLED)
    SwitchButton.BackgroundColor3 = IS_ENABLED and COLOR_ON or COLOR_OFF
end)

-- === 5. Icon Floating (TextButton 🛡️) dan Koneksi Toggle ===
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

-- Fungsi Tombol Icon (Cancel GUI / Toggle)
FloatingIcon.MouseButton1Click:Connect(function()
    -- Cek status drag yang dikembalikan oleh makeDraggable
    if not isIconDragging() then
        IS_GUI_VISIBLE = not IS_GUI_VISIBLE
        MainFrame.Visible = IS_GUI_VISIBLE 
        notify("⚙️ GUI Status", "Panel Audio: " .. (IS_GUI_VISIBLE and "Terlihat" or "Tersembunyi"), 2)
    end
end)

-- === Finalisasi ===
ScreenGui.Parent = PlayerGui
notify("✅ Executor Loaded", "Floating Icon " .. FLOATING_ICON_EMOJI .. " (modern) telah aktif. Klik untuk membuka panel.", 4)
