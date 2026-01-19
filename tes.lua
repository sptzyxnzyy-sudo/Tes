local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

---------------------------------------
-- 1. ANTI-KICK (SILENT PROTECTION)
---------------------------------------
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if tostring(method) == "Kick" or tostring(method) == "kick" then
        if self == LocalPlayer then
            return nil 
        end
    end
    return oldNamecall(self, unpack({...}))
end)
setreadonly(mt, true)

-- Pembersihan UI
if LocalPlayer.PlayerGui:FindFirstChild("SptzyV7Progress") then
    LocalPlayer.PlayerGui.SptzyV7Progress:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SptzyV7Progress"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer.PlayerGui

local isProcessing = false
local crashData = string.rep("SPTZY_BYPASS_", 900)
local TP_VOID = CFrame.new(0, -99999, 0)

---------------------------------------
-- 2. UI MINIMALIS + PROGRESS BAR
---------------------------------------
local function createProfileUI()
    local profileFrame = Instance.new("Frame")
    profileFrame.Size = UDim2.new(0, 260, 0, 130)
    profileFrame.Position = UDim2.new(1, -20, 0, 40)
    profileFrame.AnchorPoint = Vector2.new(1, 0)
    profileFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
    profileFrame.BorderSizePixel = 0
    profileFrame.Parent = screenGui

    local stroke = Instance.new("UIStroke", profileFrame)
    stroke.Thickness = 2
    Instance.new("UICorner", profileFrame).CornerRadius = UDim.new(0, 12)

    -- RAINBOW TITLE: SPTZY
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = "SPTZY V7"
    titleLabel.Position = UDim2.new(0, 15, 0, 10)
    titleLabel.Size = UDim2.new(0, 230, 0, 35)
    titleLabel.Font = Enum.Font.GothamBlack
    titleLabel.TextSize = 28
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = profileFrame

    task.spawn(function()
        local hue = 0
        while true do
            hue = hue + 0.01
            local color = Color3.fromHSV(hue % 1, 0.8, 1)
            titleLabel.TextColor3 = color
            stroke.Color = color
            task.wait()
        end
    end)

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Text = "Status: System Idle"
    statusLabel.Position = UDim2.new(0, 15, 0, 50)
    statusLabel.Size = UDim2.new(0, 230, 0, 20)
    statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    statusLabel.Font = Enum.Font.GothamMedium
    statusLabel.TextSize = 10
    statusLabel.BackgroundTransparency = 1
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = profileFrame

    -- PROGRESS BAR BACKGROUND
    local barBg = Instance.new("Frame")
    barBg.Name = "BarBackground"
    barBg.Size = UDim2.new(0, 230, 0, 8)
    barBg.Position = UDim2.new(0, 15, 0, 85)
    barBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    barBg.BorderSizePixel = 0
    barBg.Parent = profileFrame
    Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)

    -- PROGRESS BAR FILL
    local barFill = Instance.new("Frame")
    barFill.Name = "BarFill"
    barFill.Size = UDim2.new(0, 0, 1, 0)
    barFill.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
    barFill.BorderSizePixel = 0
    barFill.Parent = barBg
    Instance.new("UICorner", barFill).CornerRadius = UDim.new(1, 0)

    -- Glow effect on bar fill
    local barGlow = Instance.new("UIStroke", barFill)
    barGlow.Color = Color3.fromRGB(0, 255, 150)
    barGlow.Thickness = 1
    barGlow.Transparency = 0.5
end

---------------------------------------
-- 3. LOGIKA LOOP + PROGRESS BAR ANIMATION
---------------------------------------
local function startExecution()
    task.spawn(function()
        local status = screenGui:FindFirstChild("StatusLabel", true)
        local fill = screenGui:FindFirstChild("BarFill", true)
        
        while isProcessing do
            local allPlayers = Players:GetPlayers()
            for i, player in ipairs(allPlayers) do
                if not isProcessing then break end
                
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
                    -- Animasi Progress Bar
                    if fill then
                        local percent = i / #allPlayers
                        TweenService:Create(fill, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Size = UDim2.new(percent, 0, 1, 0)}):Play()
                    end
                    
                    if status then status.Text = "Targeting: " .. player.DisplayName end
                    Camera.CameraSubject = player.Character.Humanoid

                    -- Remote Execution
                    for _, remote in pairs(game:GetDescendants()) do
                        if not isProcessing then break end
                        if remote:IsA("RemoteEvent") then
                            pcall(function()
                                remote:FireServer("Teleport", player, TP_VOID)
                                remote:FireServer("Kick", player, crashData)
                            end)
                        end
                    end
                    task.wait(1.5)
                end
            end
            
            -- Reset bar setelah satu putaran server
            if fill then fill.Size = UDim2.new(0, 0, 1, 0) end
            task.wait(0.1)
        end
        
        if status then status.Text = "Status: System Idle" end
        if fill then fill.Size = UDim2.new(0, 0, 1, 0) end
    end)
end

---------------------------------------
-- 4. TOGGLE BUTTON
---------------------------------------
local function createToggle()
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 260, 0, 45)
    btn.Position = UDim2.new(1, -20, 0, 180)
    btn.AnchorPoint = Vector2.new(1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    btn.Font = Enum.Font.GothamBold
    btn.Text = "ACTIVATE SPTZY ENGINE"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 12
    btn.Parent = screenGui
    Instance.new("UICorner", btn)

    btn.MouseButton1Click:Connect(function()
        isProcessing = not isProcessing
        if isProcessing then
            btn.Text = "STOP ENGINE"
            btn.BackgroundColor3 = Color3.fromRGB(180, 0, 50)
            startExecution()
        else
            btn.Text = "ACTIVATE SPTZY ENGINE"
            btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            Camera.CameraSubject = LocalPlayer.Character.Humanoid
        end
    end)
end

createProfileUI()
createToggle()
