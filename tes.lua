-- LocalScript di StarterPlayerScripts
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

-- Buat GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ESPMenu"
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui

-- Frame menu utama
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 100)
frame.Position = UDim2.new(0, 20, 0, 200)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.Visible = true
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -30, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Text = "Fitur Menu"
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

-- Tombol close (X)
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -30, 0, 0)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Parent = frame

-- Tombol floating (lingkaran)
local floatingButton = Instance.new("TextButton")
floatingButton.Size = UDim2.new(0, 50, 0, 50)
floatingButton.Position = UDim2.new(0, 20, 0, 200)
floatingButton.BackgroundColor3 = Color3.fromRGB(50, 150, 250)
floatingButton.Text = "+"
floatingButton.TextColor3 = Color3.fromRGB(255, 255, 255)
floatingButton.Visible = false
floatingButton.Parent = screenGui
floatingButton.AutoButtonColor = true
floatingButton.TextScaled = true
floatingButton.Font = Enum.Font.SourceSansBold
floatingButton.ClipsDescendants = true
floatingButton.AnchorPoint = Vector2.new(0,0)
floatingButton.ZIndex = 2
floatingButton.TextWrapped = true
floatingButton.TextStrokeTransparency = 0.5
floatingButton.BorderSizePixel = 0
floatingButton.BackgroundTransparency = 0
floatingButton.TextYAlignment = Enum.TextYAlignment.Center
floatingButton.TextXAlignment = Enum.TextXAlignment.Center
floatingButton.TextSize = 30
floatingButton.Text = "⚙️" -- icon gear / lingkaran mod

floatingButton.TextStrokeColor3 = Color3.fromRGB(0,0,0)

-- Tombol ESP toggle
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

-- Button ESP handler
espButton.MouseButton1Click:Connect(function()
    ESP_ENABLED = not ESP_ENABLED
    toggleESP(ESP_ENABLED)
    espButton.Text = ESP_ENABLED and "ESP: ON" or "ESP: OFF"
end)

-- Close menu (tampilkan floating button)
closeButton.MouseButton1Click:Connect(function()
    frame.Visible = false
    floatingButton.Visible = true
end)

-- Floating button (tampilkan kembali menu)
floatingButton.MouseButton1Click:Connect(function()
    frame.Visible = true
    floatingButton.Visible = false
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