local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create Main ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ModernSystemGui"
screenGui.ResetOnSpawn = false -- Tetap ada saat respawn
screenGui.Parent = playerGui

---------------------------------------
-- 1. ANIMASI LOADING (Tengah Layar)
---------------------------------------
local function createLoadingScreen()
    local loadingFrame = Instance.new("Frame")
    loadingFrame.Size = UDim2.new(1, 0, 1, 0)
    loadingFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    loadingFrame.ZIndex = 10
    loadingFrame.Parent = screenGui

    local spinner = Instance.new("ImageLabel")
    spinner.Size = UDim2.new(0, 80, 0, 80)
    spinner.Position = UDim2.new(0.5, 0, 0.5, 0)
    spinner.AnchorPoint = Vector2.new(0.5, 0.5)
    spinner.BackgroundTransparency = 1
    spinner.Image = "rbxassetid://6033328132" -- Icon Loading Bulat
    spinner.ImageColor3 = Color3.fromRGB(0, 170, 255)
    spinner.Parent = loadingFrame

    -- Animasi Putar
    local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1)
    local tween = TweenService:Create(spinner, tweenInfo, {Rotation = 360})
    tween:Play()

    -- Hilangkan loading setelah 3 detik
    task.delay(3, function()
        TweenService:Create(loadingFrame, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
        TweenService:Create(spinner, TweenInfo.new(0.5), {ImageTransparency = 1}):Play()
        task.wait(0.5)
        loadingFrame:Destroy()
    end)
end

---------------------------------------
-- 2. UI PROFILE (Modern Design)
---------------------------------------
local function createProfileUI()
    local profileFrame = Instance.new("Frame")
    profileFrame.Size = UDim2.new(0, 250, 0, 80)
    profileFrame.Position = UDim2.new(1, -20, 0, 20)
    profileFrame.AnchorPoint = Vector2.new(1, 0)
    profileFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    profileFrame.BorderSizePixel = 0
    profileFrame.Parent = screenGui

    -- Rounded Corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = profileFrame

    -- Shadow/Stroke
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 2
    stroke.Color = Color3.fromRGB(50, 50, 50)
    stroke.Parent = profileFrame

    -- Profile Picture
    local img = Instance.new("ImageLabel")
    img.Size = UDim2.new(0, 60, 0, 60)
    img.Position = UDim2.new(0, 10, 0.5, 0)
    img.AnchorPoint = Vector2.new(0, 0.5)
    img.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    img.Image = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
    img.Parent = profileFrame
    
    local imgCorner = Instance.new("UICorner")
    imgCorner.CornerRadius = UDim.new(1, 0)
    imgCorner.Parent = img

    -- Name & ID Labels
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Text = player.DisplayName .. " (@" .. player.Name .. ")"
    nameLabel.Position = UDim2.new(0, 80, 0.25, 0)
    nameLabel.Size = UDim2.new(0, 160, 0, 20)
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.BackgroundTransparency = 1
    nameLabel.Parent = profileFrame

    local idLabel = Instance.new("TextLabel")
    idLabel.Text = "ID: " .. player.UserId
    idLabel.Position = UDim2.new(0, 80, 0.55, 0)
    idLabel.Size = UDim2.new(0, 160, 0, 20)
    idLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    idLabel.TextXAlignment = Enum.TextXAlignment.Left
    idLabel.Font = Enum.Font.Gotham
    idLabel.TextSize = 12
    idLabel.BackgroundTransparency = 1
    idLabel.Parent = profileFrame
end

---------------------------------------
-- 3. TOGGLE SWITCH (Server Disconnect)
---------------------------------------
local function createDisconnectToggle()
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(0, 200, 0, 40)
    toggleFrame.Position = UDim2.new(1, -20, 0, 110)
    toggleFrame.AnchorPoint = Vector2.new(1, 0)
    toggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    toggleFrame.Parent = screenGui

    Instance.new("UICorner", toggleFrame).CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel")
    label.Text = "Kill Connection"
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0.05, 0, 0, 0)
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleFrame

    -- Toggle Visual
    local switchBG = Instance.new("TextButton")
    switchBG.Size = UDim2.new(0, 50, 0, 24)
    switchBG.Position = UDim2.new(0.95, 0, 0.5, 0)
    switchBG.AnchorPoint = Vector2.new(1, 0.5)
    switchBG.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    switchBG.Text = ""
    switchBG.Parent = toggleFrame
    Instance.new("UICorner", switchBG).CornerRadius = UDim.new(1, 0)

    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 18, 0, 18)
    circle.Position = UDim2.new(0.1, 0, 0.5, 0)
    circle.AnchorPoint = Vector2.new(0, 0.5)
    circle.BackgroundColor3 = Color3.new(1, 1, 1)
    circle.Parent = switchBG
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

    local isOn = false
    switchBG.MouseButton1Click:Connect(function()
        isOn = not isOn
        if isOn then
            -- Animasi On
            TweenService:Create(circle, TweenInfo.new(0.2), {Position = UDim2.new(0.9, 0, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5)}):Play()
            TweenService:Create(switchBG, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 50, 50)}):Play()
            
            -- FITUR DISCONNECT
            task.wait(0.5)
            player:Kick("Server Terputus (Toggle Activated)")
        else
            -- Animasi Off
            TweenService:Create(circle, TweenInfo.new(0.2), {Position = UDim2.new(0.1, 0, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5)}):Play()
            TweenService:Create(switchBG, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play()
        end
    end)
end

-- Jalankan Fungsi
createLoadingScreen()
createProfileUI()
createDisconnectToggle()
