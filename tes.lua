local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- ** ⬇️ VARIABEL & FUNGSI FITUR BARU ⬇️ **
local isDestroyerActive = false
local touchConnection = nil

local function activatePartDestroyer()
    if isDestroyerActive then return end
    isDestroyerActive = true
    
    local character = player.Character
    local humanoid = character and character:FindFirstChild("Humanoid")
    
    if not humanoid then 
        warn("Humanoid tidak ditemukan, tidak bisa mengaktifkan destroyer.")
        isDestroyerActive = false
        return 
    end

    print("Local Part Destroyer AKTIF.")
    
    -- Hubungkan fungsi saat HumanoidRootPart menyentuh sesuatu
    local rootPart = character:WaitForChild("HumanoidRootPart")
    
    touchConnection = rootPart.Touched:Connect(function(otherPart)
        -- HANYA HAPUS DI SISI KLIEN (LOCAL)
        if isDestroyerActive and otherPart and otherPart.Parent and otherPart.Name ~= "HumanoidRootPart" then
            if otherPart:IsA("BasePart") or otherPart:IsA("MeshPart") or otherPart:IsA("UnionOperation") then
                -- Pastikan tidak menghapus bagian karakter pemain lain
                if not otherPart.Parent:FindFirstChildOfClass("Humanoid") then
                    otherPart:Destroy()
                end
            end
        end
    end)
end

local function deactivatePartDestroyer()
    if not isDestroyerActive then return end
    isDestroyerActive = false
    
    if touchConnection then
        touchConnection:Disconnect()
        touchConnection = nil
    end
    print("Local Part Destroyer NONAKTIF.")
end


-- 🔽 GUI UTAMA (Tombol Destroyer) 🔽
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DestroyerGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 100) 
frame.Position = UDim2.new(0.5, -110, 0.5, -50)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 15)
corner.Parent = frame

-- Judul GUI
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "LOCAL PART DESTROYER"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = frame

-- Tombol On/Off
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0, 180, 0, 40)
toggleButton.Position = UDim2.new(0.5, -90, 0, 45)
toggleButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0) -- Merah (OFF)
toggleButton.Text = "DESTROYER: OFF"
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 14
toggleButton.Parent = frame

local featCorner = Instance.new("UICorner")
featCorner.CornerRadius = UDim.new(0, 10)
featCorner.Parent = toggleButton


-- 🔽 LOGIKA TOMBOL 🔽

toggleButton.MouseButton1Click:Connect(function()
    if isDestroyerActive then
        deactivatePartDestroyer()
        toggleButton.Text = "DESTROYER: OFF"
        toggleButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0) -- Merah
    else
        activatePartDestroyer()
        toggleButton.Text = "DESTROYER: ON"
        toggleButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0) -- Hijau
    end
end)

-- Pastikan koneksi diaktifkan kembali jika karakter di-reset
player.CharacterAdded:Connect(function(character)
    if isDestroyerActive then
        -- Tunggu HumanoidRootPart muncul
        character:WaitForChild("HumanoidRootPart")
        -- Hentikan dan mulai kembali koneksi sentuhan
        deactivatePartDestroyer() 
        activatePartDestroyer()
    end
end)
