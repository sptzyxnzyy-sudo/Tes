local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- ** ⬇️ VARIABEL & FUNGSI FITUR UTAMA ⬇️ **
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

    print("Aggressive Local Destroyer AKTIF. Efek hanya terlihat oleh klien ini.")
    
    local rootPart = character:WaitForChild("HumanoidRootPart")
    
    touchConnection = rootPart.Touched:Connect(function(otherPart)
        -- HANYA EFEK LOKAL (KLIEN)
        if isDestroyerActive and otherPart and otherPart.Parent and otherPart.Name ~= "HumanoidRootPart" then
            if otherPart:IsA("BasePart") or otherPart:IsA("MeshPart") or otherPart:IsA("UnionOperation") then
                
                local parentModel = otherPart.Parent
                local hitHumanoid = parentModel:FindFirstChildOfClass("Humanoid")
                
                -- Cek apakah bagian yang disentuh adalah bagian dari karakter pemain lain
                if hitHumanoid and parentModel ~= player.Character then
                    -- ** EFEK PEMBUNUHAN LOKAL (Non-Visual Illusion) **
                    -- Pemain lain akan terlihat 'mati' (ragdoll) hanya di klien ini.
                    hitHumanoid.Health = 0 
                end
                
                -- Penghancuran Bagian LOKAL
                otherPart:Destroy()
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
    print("Aggressive Local Destroyer NONAKTIF.")
end

---
## 💻 GUI: Stealth Mode

-- 🔽 GUI UTAMA 🔽
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DestroyerGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 150, 0, 50) 
frame.Position = UDim2.new(1, -160, 0, 10) -- Pojok atas kanan
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BackgroundTransparency = 0.8 -- Semi-transparan
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

-- Tombol On/Off
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(1, 0, 1, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0) -- Merah (OFF)
toggleButton.BackgroundTransparency = 1 -- **Transparan penuh**
toggleButton.Text = "DESTROYER"
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 14
toggleButton.Parent = frame


-- 🔽 LOGIKA TOMBOL 🔽

toggleButton.MouseButton1Click:Connect(function()
    if isDestroyerActive then
        deactivatePartDestroyer()
        toggleButton.Text = "DESTROYER"
        toggleButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        toggleButton.BackgroundTransparency = 1
    else
        activatePartDestroyer()
        toggleButton.Text = "ACTIVE"
        toggleButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        toggleButton.BackgroundTransparency = 0.7 -- Sedikit terlihat saat aktif
    end
end)

-- Penanganan Karakter Reset (CharacterAdded)
player.CharacterAdded:Connect(function(character)
    if isDestroyerActive then
        character:WaitForChild("HumanoidRootPart")
        -- Hentikan dan mulai kembali koneksi sentuhan pada karakter baru
        deactivatePartDestroyer() 
        activatePartDestroyer()
    end
end)
