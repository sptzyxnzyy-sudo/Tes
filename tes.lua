-- LocalScript di StarterPlayerScripts
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

-- Buat GUI utama
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ESPMenu"
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui

-- Frame menu utama
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 120)
frame.Position = UDim2.new(0, 20, 0, 200)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.BorderSizePixel = 0
frame.Visible = true
frame.Active = true -- penting untuk drag
frame.Draggable = false -- kita bikin custom drag
frame.Parent = screenGui

-- Judul
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -35, 0, 30)
title.Position = UDim2.new(0, 5, 0, 0)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Text = "Fitur Menu"
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.Parent = frame

-- Tombol close (X)
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 25, 0, 25)
closeButton.Position = UDim2.new(1, -28, 0, 3)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- merah terang
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.SourceSansBold
closeButton.TextSize = 18
closeButton.Parent = frame

-- Tombol floating (⚙️)
local floatingButton = Instance.new("TextButton")
floatingButton.Size = UDim2.new(0, 50, 0, 50)
floatingButton.Position = UDim2.new(0, 20, 0, 200)
floatingButton.BackgroundColor3 = Color3.fromRGB(50, 150, 250)
floatingButton.Text = "⚙️"
floatingButton.TextColor3 = Color3.fromRGB(255, 255, 255)
floatingButton.Font = Enum.Font.SourceSansBold
floatingButton.TextSize = 24
floatingButton.Visible = false
floatingButton.Active = true
floatingButton.Draggable = false
floatingButton.Parent = screenGui

-- Tombol ESP toggle
local espButton = Instance.new("TextButton")
espButton.Size = UDim2.new(1, -10, 0, 40)
espButton.Position = UDim2.new(0, 5, 0, 40)
espButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
espButton.TextColor3 = Color3.fromRGB(255, 255, 255)
espButton.Text = "ESP: OFF"
espButton.Font = Enum.Font.SourceSansBold
espButton.TextSize = 18
espButton.Parent = frame

-- =========================
-- DRAG FUNCTION
-- =========================
local function makeDraggable(gui)
    local dragging = false
    local dragInput, dragStart, startPos

    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    gui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- bikin draggable
makeDraggable(frame)
makeDraggable(floatingButton)

-- =========================
-- ESP SYSTEM
-- =========================
local ESP_ENABLED = false

local function addESP(player)
    if player.Character and not player.Character:FindFirstChild("PlayerESP") then
        local highlight = Instance.new("Highlight")
        highlight.Name = "PlayerESP"
        highlight.FillColor = Color3.fromRGB(0, 255, 0) -- hijau
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

local function refreshESP()
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

-- =========================
-- BUTTON HANDLERS
-- =========================
espButton.MouseButton1Click:Connect(function()
    ESP_ENABLED = not ESP_ENABLED
    refreshESP()
    espButton.Text = ESP_ENABLED and "ESP: ON" or "ESP: OFF"
end)

closeButton.MouseButton1Click:Connect(function()
    frame.Visible = false
    floatingButton.Visible = true
end)

floatingButton.MouseButton1Click:Connect(function()
    frame.Visible = true
    floatingButton.Visible = false
end)

-- =========================
-- PLAYER EVENTS
-- =========================
Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        player.CharacterAdded:Connect(function()
            task.wait(1) -- tunggu load
            if ESP_ENABLED then
                addESP(player)
            end
        end)
    end
end)

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        player.CharacterAdded:Connect(function()
            task.wait(1)
            if ESP_ENABLED then
                addESP(player)
            end
        end)
    end
end