local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Fungsi Notifikasi Resmi
local function sendRobloxNotif(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title;
            Text = text;
            Icon = "rbxassetid://6023454774";
            Duration = 3;
        })
    end)
end

-- Pembersihan UI lama
if LocalPlayer.PlayerGui:FindFirstChild("SptzySelfSys") then
    LocalPlayer.PlayerGui.SptzySelfSys:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SptzySelfSys"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer.PlayerGui

local isProcessing = false

---------------------------------------
-- 1. UI PROFILE + RAINBOW TITLE (SPTZY)
---------------------------------------
local function createProfileUI()
    local profileFrame = Instance.new("Frame")
    profileFrame.Size = UDim2.new(0, 260, 0, 120)
    profileFrame.Position = UDim2.new(1, -20, 0, 40)
    profileFrame.AnchorPoint = Vector2.new(1, 0)
    profileFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    profileFrame.BorderSizePixel = 0
    profileFrame.Parent = screenGui

    Instance.new("UICorner", profileFrame).CornerRadius = UDim.new(0, 12)
    local stroke = Instance.new("UIStroke", profileFrame)
    stroke.Thickness = 2

    -- LOGO/AVATAR
    local img = Instance.new("ImageLabel")
    img.Size = UDim2.new(0, 50, 0, 50)
    img.Position = UDim2.new(0, 15, 0, 15)
    img.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
    img.Parent = profileFrame
    Instance.new("UICorner", img).CornerRadius = UDim.new(1, 0)

    -- RAINBOW TITLE: SPTZY
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = "SPTZY"
    titleLabel.Position = UDim2.new(0, 80, 0, 10)
    titleLabel.Size = UDim2.new(0, 160, 0, 25)
    titleLabel.Font = Enum.Font.GothamBlack
    titleLabel.TextSize = 22
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = profileFrame

    -- Logika Rainbow Effect
    task.spawn(function()
        local hue = 0
        while true do
            hue = hue + 0.01
            if hue > 1 then hue = 0 end
            local color = Color3.fromHSV(hue, 0.8, 1)
            titleLabel.TextColor3 = color
            stroke.Color = color
            task.wait()
        end
    end)

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Text = "Self-Injection Mode"
    nameLabel.Position = UDim2.new(0, 80, 0, 35)
    nameLabel.Size = UDim2.new(0, 160, 0, 20)
    nameLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Font = Enum.Font.Gotham
    nameLabel.TextSize = 12
    nameLabel.BackgroundTransparency = 1
    nameLabel.Parent = profileFrame

    local logLabel = Instance.new("TextLabel")
    logLabel.Name = "LogLabel"
    logLabel.Text = "Status: Waiting..."
    logLabel.Position = UDim2.new(0, 15, 0, 80)
    logLabel.Size = UDim2.new(0, 230, 0, 25)
    logLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    logLabel.Font = Enum.Font.Code
    logLabel.TextSize = 9
    logLabel.BackgroundTransparency = 1
    logLabel.Parent = profileFrame
end

---------------------------------------
-- 2. SELF REMOTE INJECTION (ONLY YOU)
---------------------------------------
local function startSelfAttack()
    task.spawn(function()
        local logLabel = screenGui:FindFirstChild("LogLabel", true)
        while isProcessing do
            for _, obj in pairs(game:GetDescendants()) do
                if not isProcessing then break end
                
                if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                    if logLabel then logLabel.Text = "Testing: " .. obj.Name end
                    
                    pcall(function()
                        -- Payload Khusus Akun Sendiri
                        local payloads = {
                            {"GiveAdmin", LocalPlayer},
                            {"SetAdmin", LocalPlayer.Name, true},
                            {"AddCoins", 999999},
                            {"AddCash", 999999},
                            {"UnlockAll", true},
                            {"GiveItem", "All"},
                            {"SetRank", "Owner"}
                        }

                        for _, pLoad in pairs(payloads) do
                            if obj:IsA("RemoteEvent") then
                                obj:FireServer(unpack(pLoad))
                            else
                                obj:InvokeServer(unpack(pLoad))
                            end
                        end
                    end)
                end
            end
            task.wait(0.5) -- Jeda agar tidak lag
        end
        if logLabel then logLabel.Text = "System: Halted." end
    end)
end

---------------------------------------
-- 3. TOGGLE SWITCH
---------------------------------------
local function createToggle()
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(0, 260, 0, 45)
    toggleFrame.Position = UDim2.new(1, -20, 0, 170)
    toggleFrame.AnchorPoint = Vector2.new(1, 0)
    toggleFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    toggleFrame.Parent = screenGui
    Instance.new("UICorner", toggleFrame).CornerRadius = UDim.new(0, 10)

    local label = Instance.new("TextLabel")
    label.Text = "START SELF-INJECTION"
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0.05, 0, 0, 0)
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 10
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleFrame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 50, 0, 26)
    btn.Position = UDim2.new(0.93, 0, 0.5, 0)
    btn.AnchorPoint = Vector2.new(1, 0.5)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
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
        isProcessing = not isProcessing
        if isProcessing then
            TweenService:Create(circle, TweenInfo.new(0.2), {Position = UDim2.new(0.9, 0, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5)}):Play()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 255, 150)}):Play()
            sendRobloxNotif("SPTZY SYSTEM", "Starting self-remote testing...")
            startSelfAttack()
        else
            TweenService:Create(circle, TweenInfo.new(0.2), {Position = UDim2.new(0.1, 0, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5)}):Play()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}):Play()
            sendRobloxNotif("SPTZY SYSTEM", "Stopped.")
        end
    end)
end

createProfileUI()
createToggle()
