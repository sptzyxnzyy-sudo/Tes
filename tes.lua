local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local MarketplaceService = game:GetService("MarketplaceService")
local LocalPlayer = Players.LocalPlayer

-- Fungsi Notifikasi Resmi
local function sendRobloxNotif(title, text, icon)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title;
            Text = text;
            Icon = icon or "rbxassetid://6023454774";
            Duration = 3;
        })
    end)
end

-- Pembersihan UI
if LocalPlayer.PlayerGui:FindFirstChild("AutoScanSys") then
    LocalPlayer.PlayerGui.AutoScanSys:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoScanSys"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer.PlayerGui

local isProcessing = false
local scannedGamepasses = {}

---------------------------------------
-- 1. LOGIKA AUTO-SCAN GAMEPASS ID
---------------------------------------
local function scanGamepasses()
    scannedGamepasses = {} -- Reset
    -- Mencari ID di ReplicatedStorage & Workspace (biasanya ada di folder Gamepasses/Store)
    for _, item in pairs(game:GetDescendants()) do
        if item:IsA("IntValue") or item:IsA("StringValue") or item:IsA("NumberValue") then
            if item.Name:lower():find("gamepass") or item.Name:lower():find("product") then
                local id = tonumber(item.Value)
                if id and id > 1000 then
                    table.insert(scannedGamepasses, id)
                end
            end
        end
    end
    -- Jika tidak ditemukan, tambahkan dummy ID umum sebagai fallback
    if #scannedGamepasses == 0 then table.insert(scannedGamepasses, 123456) end
end

---------------------------------------
-- 2. UI PROFILE & REAL-TIME LOG
---------------------------------------
local function createProfileUI()
    local profileFrame = Instance.new("Frame")
    profileFrame.Size = UDim2.new(0, 260, 0, 110)
    profileFrame.Position = UDim2.new(1, -20, 0, 40)
    profileFrame.AnchorPoint = Vector2.new(1, 0)
    profileFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    profileFrame.BorderSizePixel = 0
    profileFrame.Parent = screenGui

    Instance.new("UICorner", profileFrame).CornerRadius = UDim.new(0, 12)
    local stroke = Instance.new("UIStroke", profileFrame)
    stroke.Thickness = 2
    stroke.Color = Color3.fromRGB(170, 0, 255) -- Ungu Neon

    local img = Instance.new("ImageLabel")
    img.Size = UDim2.new(0, 50, 0, 50)
    img.Position = UDim2.new(0, 15, 0, 15)
    img.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
    img.Parent = profileFrame
    Instance.new("UICorner", img).CornerRadius = UDim.new(1, 0)

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Text = LocalPlayer.DisplayName
    nameLabel.Position = UDim2.new(0, 80, 0, 15)
    nameLabel.Size = UDim2.new(0, 160, 0, 20)
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.BackgroundTransparency = 1
    nameLabel.Parent = profileFrame

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Text = "Scanner: READY"
    statusLabel.Position = UDim2.new(0, 80, 0, 35)
    statusLabel.Size = UDim2.new(0, 160, 0, 20)
    statusLabel.TextColor3 = Color3.fromRGB(170, 0, 255)
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Font = Enum.Font.Code
    statusLabel.Parent = profileFrame

    local logLabel = Instance.new("TextLabel")
    logLabel.Name = "LogLabel"
    logLabel.Text = "Awaiting execution..."
    logLabel.Position = UDim2.new(0, 15, 0, 75)
    logLabel.Size = UDim2.new(0, 230, 0, 20)
    logLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    logLabel.Font = Enum.Font.Code
    logLabel.TextSize = 9
    logLabel.BackgroundTransparency = 1
    logLabel.Parent = profileFrame
end

---------------------------------------
-- 3. AUTO-SCAN & GLOBAL EXECUTION
---------------------------------------
local function startInfection()
    task.spawn(function()
        local logLabel = screenGui:FindFirstChild("LogLabel", true)
        local statusLabel = screenGui:FindFirstChild("StatusLabel", true)

        while isProcessing do
            scanGamepasses() -- Scan otomatis setiap loop
            
            for _, obj in pairs(game:GetDescendants()) do
                if not isProcessing then break end
                
                if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                    for _, target in pairs(Players:GetPlayers()) do
                        for _, passId in pairs(scannedGamepasses) do
                            if logLabel then logLabel.Text = "Target: "..target.Name.." | ID: "..passId end
                            
                            pcall(function()
                                if obj:IsA("RemoteEvent") then
                                    -- Injeksi payload ID gamepass otomatis
                                    obj:FireServer("GivePass", target.UserId, passId)
                                    obj:FireServer("Unlock", passId, target.Name)
                                    obj:FireServer("PurchaseSuccess", passId, target.UserId)
                                else
                                    obj:InvokeServer("VerifyPass", passId)
                                end
                            end)
                        end
                        task.wait(0.05) -- Penyeimbang agar tidak kick karena spam berlebih
                    end
                end
            end
            task.wait(0.5)
        end
    end)
end

---------------------------------------
-- 4. TOGGLE SWITCH
---------------------------------------
local function createToggle()
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(0, 260, 0, 45)
    toggleFrame.Position = UDim2.new(1, -20, 0, 160)
    toggleFrame.AnchorPoint = Vector2.new(1, 0)
    toggleFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    toggleFrame.Parent = screenGui
    Instance.new("UICorner", toggleFrame).CornerRadius = UDim.new(0, 10)

    local label = Instance.new("TextLabel")
    label.Text = "AUTO-SCAN & GRANT ALL"
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
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(170, 0, 255)}):Play()
            
            sendRobloxNotif("SCANNING...", "Searching for Gamepass IDs and Infecting Remotes", "rbxassetid://6023454774")
            startInfection()
        else
            TweenService:Create(circle, TweenInfo.new(0.2), {Position = UDim2.new(0.1, 0, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5)}):Play()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}):Play()
            sendRobloxNotif("HALTED", "Process terminated.", "rbxassetid://6023454055")
        end
    end)
end

createProfileUI()
createToggle()
