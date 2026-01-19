local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- Hapus UI lama jika ada
if player.PlayerGui:FindFirstChild("ModernSystemGui") then
    player.PlayerGui.ModernSystemGui:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ModernSystemGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player.PlayerGui

---------------------------------------
-- 1. UI PROFILE (Pojok Kanan Atas)
---------------------------------------
local function createProfileUI()
    local profileFrame = Instance.new("Frame")
    profileFrame.Size = UDim2.new(0, 250, 0, 80)
    profileFrame.Position = UDim2.new(1, -20, 0, 20)
    profileFrame.AnchorPoint = Vector2.new(1, 0)
    profileFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    profileFrame.BorderSizePixel = 0
    profileFrame.Parent = screenGui

    Instance.new("UICorner", profileFrame).CornerRadius = UDim.new(0, 12)
    local stroke = Instance.new("UIStroke", profileFrame)
    stroke.Thickness = 2
    stroke.Color = Color3.fromRGB(0, 170, 255)

    local img = Instance.new("ImageLabel")
    img.Size = UDim2.new(0, 55, 0, 55)
    img.Position = UDim2.new(0, 10, 0.5, 0)
    img.AnchorPoint = Vector2.new(0, 0.5)
    img.Image = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
    img.Parent = profileFrame
    Instance.new("UICorner", img).CornerRadius = UDim.new(1, 0)

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Text = player.DisplayName
    nameLabel.Position = UDim2.new(0, 75, 0.25, 0)
    nameLabel.Size = UDim2.new(0, 160, 0, 20)
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.BackgroundTransparency = 1
    nameLabel.Parent = profileFrame

    local idLabel = Instance.new("TextLabel")
    idLabel.Text = "@" .. player.Name .. "\nID: " .. player.UserId
    idLabel.Position = UDim2.new(0, 75, 0.6, 0)
    idLabel.Size = UDim2.new(0, 160, 0, 30)
    idLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    idLabel.TextXAlignment = Enum.TextXAlignment.Left
    idLabel.Font = Enum.Font.Gotham
    idLabel.TextSize = 10
    idLabel.BackgroundTransparency = 1
    idLabel.Parent = profileFrame
end

---------------------------------------
-- 2. FITUR SERVER DISCONNECT (Executor Version)
---------------------------------------
-- Karena Client tidak bisa Kick, kita gunakan loop untuk membebani 
-- replikasi data ke pemain lain atau mencoba crash/lag.
local isKilling = false

local function startDisconnectLoop()
    task.spawn(function()
        while isKilling do
            -- Logika ini mencoba mengirim paket data berlebih (Spam Replikate)
            -- agar koneksi pemain lain (Client-side) mengalami desync/lag berat.
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player and p.Character then
                    -- Mencoba memanipulasi posisi replikasi (hanya bekerja di beberapa game)
                    p.Character:MoveTo(Vector3.new(math.huge, math.huge, math.huge))
                end
            end
            task.wait(0.1) 
        end
    end)
end

---------------------------------------
-- 3. TOGGLE SWITCH
---------------------------------------
local function createToggle()
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(0, 250, 0, 45)
    toggleFrame.Position = UDim2.new(1, -20, 0, 110)
    toggleFrame.AnchorPoint = Vector2.new(1, 0)
    toggleFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    toggleFrame.Parent = screenGui
    Instance.new("UICorner", toggleFrame).CornerRadius = UDim.new(0, 10)

    local label = Instance.new("TextLabel")
    label.Text = "SERVER ATTACK (LOOP)"
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0.05, 0, 0, 0)
    label.TextColor3 = Color3.fromRGB(255, 60, 60)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 11
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleFrame

    local switchBG = Instance.new("TextButton")
    switchBG.Size = UDim2.new(0, 50, 0, 26)
    switchBG.Position = UDim2.new(0.93, 0, 0.5, 0)
    switchBG.AnchorPoint = Vector2.new(1, 0.5)
    switchBG.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    switchBG.Text = ""
    switchBG.Parent = toggleFrame
    Instance.new("UICorner", switchBG).CornerRadius = UDim.new(1, 0)

    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 20, 0, 20)
    circle.Position = UDim2.new(0.1, 0, 0.5, 0)
    circle.AnchorPoint = Vector2.new(0, 0.5)
    circle.BackgroundColor3 = Color3.new(1, 1, 1)
    circle.Parent = switchBG
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

    switchBG.MouseButton1Click:Connect(function()
        isKilling = not isKilling
        if isKilling then
            TweenService:Create(circle, TweenInfo.new(0.2), {Position = UDim2.new(0.9, 0, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5)}):Play()
            TweenService:Create(switchBG, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 0, 0)}):Play()
            startDisconnectLoop()
        else
            TweenService:Create(circle, TweenInfo.new(0.2), {Position = UDim2.new(0.1, 0, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5)}):Play()
            TweenService:Create(switchBG, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play()
        end
    end)
end

createProfileUI()
createToggle()
