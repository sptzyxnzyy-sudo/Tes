local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

-- Fungsi Notifikasi Resmi Roblox
local function sendRobloxNotif(title, text, icon)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title;
            Text = text;
            Icon = icon or "rbxassetid://6023454774"; -- Icon default info
            Duration = 3;
        })
    end)
end

-- Hapus UI lama jika ada
if LocalPlayer.PlayerGui:FindFirstChild("ServerSideSystem") then
    LocalPlayer.PlayerGui.ServerSideSystem:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ServerSideSystem"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer.PlayerGui

local isAttacking = false

---------------------------------------
-- 1. UI PROFILE (Pojok Kanan Atas)
---------------------------------------
local function createProfileUI()
    local profileFrame = Instance.new("Frame")
    profileFrame.Size = UDim2.new(0, 260, 0, 80)
    profileFrame.Position = UDim2.new(1, -20, 0, 40)
    profileFrame.AnchorPoint = Vector2.new(1, 0)
    profileFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    profileFrame.BorderSizePixel = 0
    profileFrame.Parent = screenGui

    Instance.new("UICorner", profileFrame).CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", profileFrame)
    stroke.Thickness = 2
    stroke.Color = Color3.fromRGB(255, 255, 255)

    local img = Instance.new("ImageLabel")
    img.Size = UDim2.new(0, 50, 0, 50)
    img.Position = UDim2.new(0, 15, 0.5, 0)
    img.AnchorPoint = Vector2.new(0, 0.5)
    img.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
    img.Parent = profileFrame
    Instance.new("UICorner", img).CornerRadius = UDim.new(1, 0)

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Text = LocalPlayer.DisplayName
    nameLabel.Position = UDim2.new(0, 80, 0.3, 0)
    nameLabel.Size = UDim2.new(0, 160, 0, 20)
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.BackgroundTransparency = 1
    nameLabel.Parent = profileFrame

    local idLabel = Instance.new("TextLabel")
    idLabel.Text = "@" .. LocalPlayer.Name
    idLabel.Position = UDim2.new(0, 80, 0.55, 0)
    idLabel.Size = UDim2.new(0, 160, 0, 20)
    idLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    idLabel.TextXAlignment = Enum.TextXAlignment.Left
    idLabel.Font = Enum.Font.Code
    idLabel.TextSize = 10
    idLabel.BackgroundTransparency = 1
    idLabel.Parent = profileFrame
end

---------------------------------------
-- 2. LOGIKA SERVER-SIDE SPAM
---------------------------------------
local function startServerSideSpam()
    task.spawn(function()
        while isAttacking do
            for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                if remote:IsA("RemoteEvent") then
                    for _, p in pairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer then
                            pcall(function()
                                remote:FireServer("Kick", p, "Network Error")
                            end)
                        end
                    end
                end
            end
            task.wait(0.5)
        end
    end)
end

---------------------------------------
-- 3. TOGGLE SWITCH & NOTIFIKASI
---------------------------------------
local function createToggle()
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(0, 260, 0, 45)
    toggleFrame.Position = UDim2.new(1, -20, 0, 130)
    toggleFrame.AnchorPoint = Vector2.new(1, 0)
    toggleFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    toggleFrame.Parent = screenGui
    Instance.new("UICorner", toggleFrame).CornerRadius = UDim.new(0, 10)

    local label = Instance.new("TextLabel")
    label.Text = "SERVER DISCONNECT"
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0.05, 0, 0, 0)
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 10
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleFrame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 50, 0, 26)
    btn.Position = UDim2.new(0.93, 0, 0.5, 0)
    btn.AnchorPoint = Vector2.new(1, 0.5)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.Text = ""
    btn.Parent = toggleFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 20, 0, 20)
    circle.Position = UDim2.new(0.1, 0, 0.5, 0)
    circle.AnchorPoint = Vector2.new(0, 0.5)
    circle.BackgroundColor3 = Color3.new(1, 1, 1)
    circle.Parent = btn
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

    btn.MouseButton1Click:Connect(function()
        isAttacking = not isAttacking
        if isAttacking then
            -- ON
            TweenService:Create(circle, TweenInfo.new(0.2), {Position = UDim2.new(0.9, 0, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5)}):Play()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 170, 255)}):Play()
            
            sendRobloxNotif("System Active", "Server-Side Attack: ON", "rbxassetid://6023454774")
            startServerSideSpam()
        else
            -- OFF
            TweenService:Create(circle, TweenInfo.new(0.2), {Position = UDim2.new(0.1, 0, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5)}):Play()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
            
            sendRobloxNotif("System Disabled", "Server-Side Attack: OFF", "rbxassetid://6023454055")
        end
    end)
end

-- Inisialisasi awal
createProfileUI()
createToggle()
sendRobloxNotif("Script Loaded", "Welcome, " .. LocalPlayer.DisplayName, "rbxassetid://6023454774")
