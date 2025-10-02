-- LocalScript di StarterPlayerScripts
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

-- Buat GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ESPMenu"
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 100)
frame.Position = UDim2.new(0, 20, 0, 200)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Text = "Fitur Menu"
title.Parent = frame

local espButton = Instance.new("TextButton")
espButton.Size = UDim2.new(1, 0, 0, 40)
espButton.Position = UDim2.new(0, 0, 0, 40)
espButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
espButton.TextColor3 = Color3.fromRGB(255, 255, 255)
espButton.Text = "ESP: OFF"
espButton.Parent = frame

-- ESP System
local ESP_ENABLED = false

local function addESP(player)
    if player.Character and not player.Character:FindFirstChild("PlayerESP") then
        local highlight = Instance.new("Highlight")
        highlight.Name = "PlayerESP"
        highlight.FillColor = Color3.fromRGB(0, 255, 0)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.Parent = player.Character
    end
end

local function removeESP(player)
    if player.Character and player.Character:FindFirstChild("PlayerESP") then
        player.Character.PlayerESP:Destroy()
    end
end

local function toggleESP(state)
    ESP_ENABLED = state
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if ESP_ENABLED then
                addESP(player)
            else
                removeESP(player)
            end
        end
    end
end

-- Button handler
espButton.MouseButton1Click:Connect(function()
    ESP_ENABLED = not ESP_ENABLED
    toggleESP(ESP_ENABLED)
    espButton.Text = ESP_ENABLED and "ESP: ON" or "ESP: OFF"
end)

-- Handle player join/respawn
Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        player.CharacterAdded:Connect(function()
            if ESP_ENABLED then
                task.wait(1)
                addESP(player)
            end
        end)
    end
end)

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        player.CharacterAdded:Connect(function()
            if ESP_ENABLED then
                task.wait(1)
                addESP(player)
            end
        end)
    end
end