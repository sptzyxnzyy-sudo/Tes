local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

-- Pembersihan UI lama
if LocalPlayer.PlayerGui:FindFirstChild("SptzyPlayerList") then
    LocalPlayer.PlayerGui.SptzyPlayerList:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SptzyPlayerList"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer.PlayerGui

---------------------------------------
-- 1. MAIN CONTAINER (DRAGGABLE)
---------------------------------------
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 400)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true -- Support geser manual
mainFrame.Parent = screenGui

local stroke = Instance.new("UIStroke", mainFrame)
stroke.Thickness = 2
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 15)

---------------------------------------
-- 2. RAINBOW TITLE: SPTZY
---------------------------------------
local titleLabel = Instance.new("TextLabel")
titleLabel.Text = "SPTZY EXPLORER"
titleLabel.Size = UDim2.new(1, 0, 0, 50)
titleLabel.Font = Enum.Font.GothamBlack
titleLabel.TextSize = 22
titleLabel.BackgroundTransparency = 1
titleLabel.Parent = mainFrame

task.spawn(function()
    local h = 0
    while true do
        h = h + 0.01
        local color = Color3.fromHSV(h % 1, 0.7, 1)
        titleLabel.TextColor3 = color
        stroke.Color = color
        task.wait()
    end
end)

---------------------------------------
-- 3. SCROLLING PLAYER LIST
---------------------------------------
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "PlayerScroll"
scrollFrame.Position = UDim2.new(0, 10, 0, 60)
scrollFrame.Size = UDim2.new(1, -20, 1, -80)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 3
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.Parent = mainFrame

local layout = Instance.new("UIListLayout", scrollFrame)
layout.Padding = UDim.new(0, 8)
layout.SortOrder = Enum.SortOrder.Name

---------------------------------------
-- 4. FUNCTION: UPDATE LIST
---------------------------------------
local function updateList()
    -- Bersihkan list lama
    for _, child in pairs(scrollFrame:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    for _, player in pairs(Players:GetPlayers()) do
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, -10, 0, 60)
        card.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        card.Parent = scrollFrame
        Instance.new("UICorner", card)

        -- Profile Icon
        local icon = Instance.new("ImageLabel")
        icon.Size = UDim2.new(0, 45, 0, 45)
        icon.Position = UDim2.new(0, 8, 0.5, -22)
        icon.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        icon.Image = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
        icon.Parent = card
        Instance.new("UICorner", icon).CornerRadius = UDim.new(1, 0)

        -- Name Label
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Text = player.DisplayName
        nameLabel.Position = UDim2.new(0, 65, 0.5, -18)
        nameLabel.Size = UDim2.new(1, -75, 0, 20)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextColor3 = Color3.new(1, 1, 1)
        nameLabel.TextSize = 14
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.BackgroundTransparency = 1
        nameLabel.Parent = card

        -- Username Label
        local userLabel = Instance.new("TextLabel")
        userLabel.Text = "@" .. player.Name
        userLabel.Position = UDim2.new(0, 65, 0.5, 2)
        userLabel.Size = UDim2.new(1, -75, 0, 15)
        userLabel.Font = Enum.Font.Gotham
        userLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
        userLabel.TextSize = 11
        userLabel.TextXAlignment = Enum.TextXAlignment.Left
        userLabel.BackgroundTransparency = 1
        userLabel.Parent = card

        -- Efek Hover
        card.MouseEnter:Connect(function()
            TweenService:Create(card, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
        end)
        card.MouseLeave:Connect(function()
            TweenService:Create(card, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(25, 25, 25)}):Play()
        end)
    end
    
    -- Auto adjust canvas
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
end

-- Update saat ada yang masuk/keluar
Players.PlayerAdded:Connect(updateList)
Players.PlayerRemoving:Connect(updateList)

-- Inisialisasi
updateList()

---------------------------------------
-- 5. CLOSE BUTTON
---------------------------------------
local closeBtn = Instance.new("TextButton")
closeBtn.Text = "X"
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -40, 0, 10)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = mainFrame
Instance.new("UICorner", closeBtn)

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)
