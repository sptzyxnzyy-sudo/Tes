local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Pembersihan UI lama
if LocalPlayer.PlayerGui:FindFirstChild("SptzyModernExplorer") then
    LocalPlayer.PlayerGui.SptzyModernExplorer:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SptzyModernExplorer"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer.PlayerGui

---------------------------------------
-- 1. MAIN CONTAINER (MODERN DARK THEME)
---------------------------------------
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 350, 0, 450)
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -225)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local stroke = Instance.new("UIStroke", mainFrame)
stroke.Thickness = 2
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 16)

-- Header Glow Line
local headerLine = Instance.new("Frame")
headerLine.Size = UDim2.new(1, 0, 0, 2)
headerLine.Position = UDim2.new(0, 0, 0, 55)
headerLine.BorderSizePixel = 0
headerLine.Parent = mainFrame

---------------------------------------
-- 2. BRAINBROW TITLE LOGIC
---------------------------------------
local titleLabel = Instance.new("TextLabel")
titleLabel.Text = "SPTZY EXPLORER V9"
titleLabel.Size = UDim2.new(1, 0, 0, 55)
titleLabel.Font = Enum.Font.GothamBlack
titleLabel.TextSize = 20
titleLabel.BackgroundTransparency = 1
titleLabel.Parent = mainFrame

task.spawn(function()
    local h = 0
    while true do
        h = h + 0.01
        local color = Color3.fromHSV(h % 1, 0.7, 1)
        titleLabel.TextColor3 = color
        stroke.Color = color
        headerLine.BackgroundColor3 = color
        task.wait()
    end
end)

---------------------------------------
-- 3. ENHANCED SCROLLING SYSTEM
---------------------------------------
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "PlayerList"
scrollFrame.Position = UDim2.new(0, 10, 0, 65)
scrollFrame.Size = UDim2.new(1, -20, 1, -80)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 0 -- Sembunyikan bar agar rapi tapi tetap bisa scroll
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y -- Support scroll luas tanpa terpotong
scrollFrame.Parent = mainFrame

local layout = Instance.new("UIListLayout", scrollFrame)
layout.Padding = UDim.new(0, 10)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

---------------------------------------
-- 4. PLAYER CARD TEMPLATE
---------------------------------------
local function createPlayerCard(player)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -5, 0, 70)
    card.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    card.BorderSizePixel = 0
    card.Parent = scrollFrame
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)

    -- Avatar Profile
    local img = Instance.new("ImageLabel")
    img.Size = UDim2.new(0, 50, 0, 50)
    img.Position = UDim2.new(0, 10, 0.5, -25)
    img.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    img.Image = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
    img.Parent = card
    Instance.new("UICorner", img).CornerRadius = UDim.new(1, 0)

    -- Name Info
    local name = Instance.new("TextLabel")
    name.Text = player.DisplayName
    name.Size = UDim2.new(0, 140, 0, 20)
    name.Position = UDim2.new(0, 70, 0, 15)
    name.Font = Enum.Font.GothamBold
    name.TextColor3 = Color3.new(1,1,1)
    name.TextSize = 13
    name.TextXAlignment = Enum.TextXAlignment.Left
    name.BackgroundTransparency = 1
    name.Parent = card

    local user = Instance.new("TextLabel")
    user.Text = "@" .. player.Name
    user.Size = UDim2.new(0, 140, 0, 15)
    user.Position = UDim2.new(0, 70, 0, 35)
    user.Font = Enum.Font.Gotham
    user.TextColor3 = Color3.fromRGB(150, 150, 150)
    user.TextSize = 10
    user.TextXAlignment = Enum.TextXAlignment.Left
    user.BackgroundTransparency = 1
    user.Parent = card

    -- ACTION BUTTONS
    local btnContainer = Instance.new("Frame")
    btnContainer.Size = UDim2.new(0, 80, 1, 0)
    btnContainer.Position = UDim2.new(1, -90, 0, 0)
    btnContainer.BackgroundTransparency = 1
    btnContainer.Parent = card

    local function createActionButton(text, color, pos, callback)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, 0, 0, 25)
        b.Position = pos
        b.BackgroundColor3 = color
        b.Text = text
        b.Font = Enum.Font.GothamBold
        b.TextColor3 = Color3.new(1,1,1)
        b.TextSize = 10
        b.Parent = btnContainer
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
        b.MouseButton1Click:Connect(callback)
    end

    -- View Camera
    createActionButton("VIEW", Color3.fromRGB(50, 50, 200), UDim2.new(0, 0, 0, 8), function()
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            Camera.CameraSubject = player.Character.Humanoid
        end
    end)

    -- Teleport To
    createActionButton("GOTO", Color3.fromRGB(50, 150, 50), UDim2.new(0, 0, 0, 37), function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
        end
    end)
end

---------------------------------------
-- 5. REFRESH LOGIC
---------------------------------------
local function refresh()
    for _, c in pairs(scrollFrame:GetChildren()) do
        if c:IsA("Frame") then c:Destroy() end
    end
    for _, p in pairs(Players:GetPlayers()) do
        createPlayerCard(p)
    end
end

Players.PlayerAdded:Connect(refresh)
Players.PlayerRemoving:Connect(refresh)
refresh()

-- Close Button
local close = Instance.new("TextButton")
close.Text = "×"
close.Size = UDim2.new(0, 30, 0, 30)
close.Position = UDim2.new(1, -35, 0, 12)
close.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
close.TextColor3 = Color3.new(1,1,1)
close.Font = Enum.Font.GothamBold
close.TextSize = 20
close.Parent = mainFrame
Instance.new("UICorner", close)
close.MouseButton1Click:Connect(function() screenGui:Destroy() end)
