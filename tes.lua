-- credit: Xraxor1 (Original GUI/Intro structure)
-- Modification for Teleport Target TO YOU (Restored to last functional version): [AI Assistant]

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- 🔽 GUI UTAMA (Frame untuk menampung Tombol Toggle List) 🔽

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TeleportGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
-- Frame kecil di sisi layar untuk menampung tombol toggle
frame.Size = UDim2.new(0, 50, 0, 50) 
frame.Position = UDim2.new(0.9, -50, 0.5, -25)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 15)
corner.Parent = frame


-- 🔽 GUI Samping Player List 🔽
local flagButton = Instance.new("ImageButton")
flagButton.Size = UDim2.new(1, 0, 1, 0)
flagButton.BackgroundTransparency = 1
flagButton.Image = "rbxassetid://6031097229" -- Ikon untuk toggle
flagButton.Parent = frame

local sideFrame = Instance.new("Frame")
sideFrame.Size = UDim2.new(0, 170, 0, 250)
sideFrame.Position = UDim2.new(1, 10, 0, 0) -- Posisi di samping frame utama
sideFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
sideFrame.Visible = false
sideFrame.Parent = frame

local sideCorner = Instance.new("UICorner")
sideCorner.CornerRadius = UDim.new(0, 12)
sideCorner.Parent = sideFrame

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, 0, 1, -5)
scrollFrame.Position = UDim2.new(0, 0, 0, 5)
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.ScrollBarThickness = 6
scrollFrame.BackgroundTransparency = 1
scrollFrame.Parent = sideFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 5)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = scrollFrame

listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
end)

-- 🔽 Logika Tombol Teleport (Teleport Target Ke Pemain) 🔽

local function makePlayerButton(targetPlayer)
    local tpButton = Instance.new("TextButton")
    tpButton.Size = UDim2.new(0, 140, 0, 35)
    -- Warna tombol akan sedikit berbeda jika itu adalah tombol Anda sendiri
    tpButton.BackgroundColor3 = targetPlayer == player and Color3.fromRGB(50, 100, 50) or Color3.fromRGB(40, 40, 40)
    tpButton.Text = targetPlayer.Name .. (targetPlayer == player and " (You)" or "")
    tpButton.TextColor3 = Color3.new(1, 1, 1)
    tpButton.Font = Enum.Font.SourceSansBold
    tpButton.TextSize = 14
    tpButton.Parent = scrollFrame

    local tpCorner = Instance.new("UICorner")
    tpCorner.CornerRadius = UDim.new(0, 8)
    tpCorner.Parent = tpButton

    tpButton.MouseButton1Click:Connect(function()
        
        -- Jangan teleport diri sendiri
        if targetPlayer == player then 
            print("Tidak dapat meneleport diri sendiri!")
            return 
        end

        local char = player.Character
        local targetChar = targetPlayer.Character

        if not char or not targetChar then warn("Karakter target tidak ditemukan atau belum dimuat!") return end

        local playerRoot = char:FindFirstChild("HumanoidRootPart")
        local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
        if not playerRoot or not targetRoot then warn("HumanoidRootPart tidak ditemukan!") return end
        
        -- Dapatkan lokasi CFrame Anda saat ini
        local playerCFrame = playerRoot.CFrame 

        -- *******************************************
        -- LOGIKA TELEPORT: TargetRoot pindah ke PlayerCFrame
        -- *******************************************
        targetRoot.CFrame = playerCFrame
        print(targetPlayer.Name .. " telah diteleport ke lokasi Anda.")

    end)
end

local function populatePlayerList()
    -- Hapus tombol lama
    for _, child in ipairs(scrollFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    -- Isi daftar pemain
    local playerList = Players:GetPlayers()
    table.sort(playerList, function(a, b) return a.Name < b.Name end)

    for _, target in ipairs(playerList) do
        makePlayerButton(target)
    end
end

-- Logika Tombol Samping (Toggle Player List)
flagButton.MouseButton1Click:Connect(function()
    sideFrame.Visible = not sideFrame.Visible
    if sideFrame.Visible then
        populatePlayerList()
    end
end)

-- Pastikan daftar di-refresh saat pemain baru bergabung/keluar
Players.PlayerAdded:Connect(function() 
    if sideFrame.Visible then populatePlayerList() end 
end)
Players.PlayerRemoving:Connect(function() 
    if sideFrame.Visible then populatePlayerList() end 
end)
