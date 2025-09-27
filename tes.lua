--[[
    Skrip ANTI-ADMIN / ANTI-GRIEF dengan Tombol ON/OFF
    
    Fitur Utama:
    - Kontrol Toggle: Tombol visual ON/OFF.
    - Perlindungan: ANTI-KILL, ANTI-FREEZE, ANTI-TELEPORT/FLING.
    - Logika Respawn: Mempertahankan status ON/OFF setelah mati.
    
    Credit: [AI Assistant]
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- ** ⬇️ STATUS FITUR CORE ⬇️ **
local ConnectionTable = {} -- Untuk menyimpan koneksi event
local GodModeActive = false -- Status ON/OFF global


-- 🔽 GUI Sederhana (Tombol ON/OFF) 🔽

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AntiAdminToggleGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local godModeToggle = Instance.new("TextButton")
godModeToggle.Size = UDim2.new(0, 200, 0, 40) 
godModeToggle.Position = UDim2.new(0.5, -100, 1, -60) -- Posisi di bawah tengah
godModeToggle.BackgroundColor3 = Color3.fromRGB(150, 0, 0) -- Merah (OFF)
godModeToggle.TextColor3 = Color3.new(1, 1, 1)
godModeToggle.Text = "ANTI-ADMIN: NONAKTIF"
godModeToggle.Font = Enum.Font.GothamBold
godModeToggle.TextSize = 18
godModeToggle.BorderSizePixel = 0
godModeToggle.Parent = screenGui


-- ⬇️ FUNGSI PERLINDUNGAN ⬇️

local function ApplyAdminProtection()
    -- Putuskan semua koneksi lama sebelum membuat yang baru
    for _, conn in pairs(ConnectionTable) do
        conn:Disconnect()
    end
    ConnectionTable = {}
    
    local char = player.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    local rootPart = char and char:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not rootPart then
        warn("Karakter belum valid. Tidak dapat menerapkan perlindungan.")
        return
    end

    -- 1. ANTI-KILL (Kekebalan dari Kerusakan)
    humanoid.MaxHealth = math.huge
    humanoid.Health = humanoid.MaxHealth
    
    -- Memastikan kesehatan tidak berkurang
    ConnectionTable["HealthChanged"] = humanoid.HealthChanged:Connect(function(newHealth)
        if newHealth < humanoid.MaxHealth then
            humanoid.Health = humanoid.MaxHealth
        end
    end)
    
    -- 2. ANTI-FREEZE / ANTI-DEATH (Mencegah perintah Humanoid:ChangeState)
    ConnectionTable["StateChanged"] = humanoid.Seated:Connect(function(isSitting)
        if humanoid:GetState() == Enum.HumanoidStateType.Dead or humanoid:GetState() == Enum.HumanoidStateType.FallingDown then
            humanoid:ChangeState(Enum.HumanoidStateType.Running) -- Paksa kembali berlari
        end
    end)
    
    -- 3. ANTI-TELEPORT / ANTI-FREEZE PERMANEN
    ConnectionTable["Heartbeat"] = RunService.Heartbeat:Connect(function()
        -- a) ANTI-FREEZE / ANTI-SPEED CHANGE
        if humanoid.WalkSpeed < 10 or humanoid.WalkSpeed > 30 then
            humanoid.WalkSpeed = 16 -- Kembalikan ke normal
        end
        
        -- b) ANTI-FLING (Mencegah dorongan fisik)
        if rootPart.CanCollide == true then
             rootPart.CanCollide = false
        end
        
        -- c) ANTI-DESTROY (Mencegah penghapusan bagian tubuh penting)
        if not rootPart.Parent then
            player:LoadCharacter() 
        end
    end)
    
    -- Perbarui status visual
    GodModeActive = true
    godModeToggle.BackgroundColor3 = Color3.fromRGB(0, 150, 0) -- Hijau
    godModeToggle.Text = "ANTI-ADMIN: AKTIF"
    print("Perlindungan Anti-Admin AKTIF.")
end


local function RemoveAdminProtection()
    -- Putuskan semua koneksi
    for _, conn in pairs(ConnectionTable) do
        conn:Disconnect()
    end
    ConnectionTable = {}

    local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    
    if humanoid then
        humanoid.MaxHealth = 100
        humanoid.Health = math.min(humanoid.Health, 100)
        humanoid.WalkSpeed = 16
    end
    
    if rootPart then
        rootPart.CanCollide = true
    end
    
    -- Perbarui status visual
    GodModeActive = false
    godModeToggle.BackgroundColor3 = Color3.fromRGB(150, 0, 0) -- Merah
    godModeToggle.Text = "ANTI-ADMIN: NONAKTIF"
    print("Perlindungan Anti-Admin DINONAKTIFKAN.")
end


-- 🔽 LOGIKA TOMBOL & RESPAWN 🔽

-- Logika Tombol Toggle
godModeToggle.MouseButton1Click:Connect(function()
    if GodModeActive then
        RemoveAdminProtection()
    else
        ApplyAdminProtection()
    end
end)


-- Logika Respawn (Mempertahankan status ON/OFF)
local function handleCharacterAdded(char)
    if GodModeActive then
        -- Jika perlindungan AKTIF sebelum mati, aktifkan lagi
        char:WaitForChild("HumanoidRootPart", 5) 
        -- Panggil ApplyAdminProtection untuk membangun kembali semua koneksi
        ApplyAdminProtection() 
    end
end

-- Hubungkan fungsi ke event CharacterAdded
player.CharacterAdded:Connect(handleCharacterAdded)

-- Jika karakter sudah ada saat skrip pertama kali dijalankan
if player.Character then
    -- Hanya aktifkan jika tombol sudah ON (tapi default-nya OFF)
    -- Kita hanya perlu memastikan handleCharacterAdded dipasang dan tombol siap.
    -- Tidak perlu memanggil ApplyAdminProtection di sini karena default-nya OFF.
end
