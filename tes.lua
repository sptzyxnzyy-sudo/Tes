local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

-- Konfigurasi Payload
local BROADCAST_MESSAGE = "SERVER UNDER MAINTENANCE - SYSTEM OVERLOAD"
local GAMEPASS_ID = 99999999 -- ID fiktif untuk memicu error alur pembelian

-- Fungsi Notifikasi Resmi Roblox
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

-- Pembersihan UI lama
if LocalPlayer.PlayerGui:FindFirstChild("GlobalRemoteSys") then
    LocalPlayer.PlayerGui.GlobalRemoteSys:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GlobalRemoteSys"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer.PlayerGui

local isProcessing = false

---------------------------------------
-- 1. UI PROFILE
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
    stroke.Color = Color3.fromRGB(255, 0, 100) -- Warna Cyberpunk Red

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

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Text = "Status: READY"
    statusLabel.Position = UDim2.new(0, 80, 0.55, 0)
    statusLabel.Size = UDim2.new(0, 160, 0, 20)
    statusLabel.TextColor3 = Color3.fromRGB(255, 0, 100)
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Font = Enum.Font.Code
    statusLabel.TextSize = 10
    statusLabel.BackgroundTransparency = 1
    statusLabel.Parent = profileFrame
end

---------------------------------------
-- 2. LOGIKA ADVANCED GLOBAL PROCESSOR
---------------------------------------
local function startGlobalProcessing()
    task.spawn(function()
        local statusLabel = screenGui:FindFirstChild("StatusLabel", true)
        while isProcessing do
            local foundRemotes = 0
            for _, obj in pairs(game:GetDescendants()) do
                if not isProcessing then break end
                
                if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                    foundRemotes = foundRemotes + 1
                    
                    pcall(function()
                        -- 1. Payload Disconnect/Kick
                        for _, p in pairs(Players:GetPlayers()) do
                            if p ~= LocalPlayer then
                                if obj:IsA("RemoteEvent") then
                                    obj:FireServer("Kick", p, "Critical Error")
                                    obj:FireServer(p, "Disconnect")
                                else -- RemoteFunction
                                    obj:InvokeServer("Kick", p)
                                end
                            end
                        end
                        
                        -- 2. Payload Broadcast (Pesan Global)
                        obj:FireServer("Message", BROADCAST_MESSAGE)
                        obj:FireServer("Broadcast", BROADCAST_MESSAGE)
                        obj:FireServer("Chat", BROADCAST_MESSAGE, "All")
                        
                        -- 3. Payload Gamepass Flow (Bypass/Purchase Attempt)
                        obj:FireServer("BuyGamepass", GAMEPASS_ID)
                        obj:FireServer("Purchase", "Gamepass", GAMEPASS_ID)
                        obj:FireServer("OwnsGamepass", GAMEPASS_ID, true)
                        obj:FireServer("AwardItem", GAMEPASS_ID)
                    end)
                end
            end
            
            if statusLabel then statusLabel.Text = "Injected: " .. foundRemotes .. " Remotes" end
            task.wait(0.3)
        end
        if statusLabel then statusLabel.Text = "Status: IDLE" end
    end)
end

---------------------------------------
-- 3. TOGGLE SWITCH
---------------------------------------
local function createToggle()
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(0, 260, 0, 45)
    toggleFrame.Position = UDim2.new(1, -20, 0, 130)
    toggleFrame.AnchorPoint = Vector2.new(1, 0)
    toggleFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    toggleFrame.Parent = screenGui
    Instance.new("UICorner", toggleFrame).CornerRadius = UDim.new(0, 10)

    local label = Instance.new("TextLabel")
    label.Text = "ULTIMATE GLOBAL ATTACK"
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
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 0, 100)}):Play()
            
            sendRobloxNotif("ATTACK ACTIVE", "Broadcasting & Gamepass Infiltration Started", "rbxassetid://6023454774")
            startGlobalProcessing()
        else
            TweenService:Create(circle, TweenInfo.new(0.2), {Position = UDim2.new(0.1, 0, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5)}):Play()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}):Play()
            
            sendRobloxNotif("SYSTEM HALTED", "Returning to stealth mode.", "rbxassetid://6023454055")
        end
    end)
end

-- Eksekusi Utama
createProfileUI()
createToggle()
sendRobloxNotif("System Loaded", "Executor Ready: Server-Side Mode", "rbxassetid://6023454774")
