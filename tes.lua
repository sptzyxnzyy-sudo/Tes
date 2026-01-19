local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- 1. PROTEKSI ANTI-KICK (Silently Active)
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    if getnamecallmethod() == "Kick" and self == LocalPlayer then return nil end
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)

-- Pembersihan UI lama
if LocalPlayer.PlayerGui:FindFirstChild("SptzyV10Final") then
    LocalPlayer.PlayerGui.SptzyV10Final:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SptzyV10Final"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer.PlayerGui

---------------------------------------
-- 2. MODERN BRAINBROW FRAME
---------------------------------------
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 360, 0, 480)
mainFrame.Position = UDim2.new(0.5, -180, 0.5, -240)
mainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local stroke = Instance.new("UIStroke", mainFrame)
stroke.Thickness = 2
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 15)

-- Header Rainbow
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 60)
header.BackgroundTransparency = 1
header.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Text = "SPTZY ULTIMATE V10"
titleLabel.Size = UDim2.new(1, -100, 1, 0)
titleLabel.Position = UDim2.new(0, 20, 0, 0)
titleLabel.Font = Enum.Font.GothamBlack
titleLabel.TextSize = 20
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.BackgroundTransparency = 1
titleLabel.Parent = header

-- Rainbow Loop
task.spawn(function()
    local h = 0
    while true do
        h = h + 0.005
        local c = Color3.fromHSV(h % 1, 0.8, 1)
        titleLabel.TextColor3 = c
        stroke.Color = c
        task.wait()
    end
end)

---------------------------------------
-- 3. INTERACTIVE PLAYER LIST (AUTO-SCROLL)
---------------------------------------
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Position = UDim2.new(0, 10, 0, 70)
scrollFrame.Size = UDim2.new(1, -20, 1, -130)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 2
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y -- Memastikan tidak terpotong
scrollFrame.Parent = mainFrame

local layout = Instance.new("UIListLayout", scrollFrame)
layout.Padding = UDim.new(0, 8)
layout.SortOrder = Enum.SortOrder.Name

---------------------------------------
-- 4. UTILITY FUNCTIONS (GOTO & VIEW)
---------------------------------------
local function createCard(player)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -10, 0, 65)
    card.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    card.Parent = scrollFrame
    Instance.new("UICorner", card)

    local pfp = Instance.new("ImageLabel")
    pfp.Size = UDim2.new(0, 45, 0, 45)
    pfp.Position = UDim2.new(0, 10, 0.5, -22)
    pfp.Image = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
    pfp.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    pfp.Parent = card
    Instance.new("UICorner", pfp).CornerRadius = UDim.new(1, 0)

    local name = Instance.new("TextLabel")
    name.Text = player.DisplayName
    name.Position = UDim2.new(0, 65, 0.2, 0)
    name.Size = UDim2.new(0, 150, 0, 20)
    name.Font = Enum.Font.GothamBold
    name.TextColor3 = Color3.new(1,1,1)
    name.TextSize = 14
    name.TextXAlignment = Enum.TextXAlignment.Left
    name.BackgroundTransparency = 1
    name.Parent = card

    local user = Instance.new("TextLabel")
    user.Text = "@" .. player.Name
    user.Position = UDim2.new(0, 65, 0.5, 0)
    user.Size = UDim2.new(0, 150, 0, 15)
    user.Font = Enum.Font.Gotham
    user.TextColor3 = Color3.fromRGB(150, 150, 150)
    user.TextSize = 11
    user.TextXAlignment = Enum.TextXAlignment.Left
    user.BackgroundTransparency = 1
    user.Parent = card

    -- Buttons Container
    local btns = Instance.new("Frame")
    btns.Size = UDim2.new(0, 80, 1, 0)
    btns.Position = UDim2.new(1, -90, 0, 0)
    btns.BackgroundTransparency = 1
    btns.Parent = card

    local function makeBtn(txt, color, y, cb)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, 0, 0, 22)
        b.Position = UDim2.new(0, 0, 0, y)
        b.BackgroundColor3 = color
        b.Text = txt
        b.Font = Enum.Font.GothamBold
        b.TextSize = 10
        b.TextColor3 = Color3.new(1,1,1)
        b.Parent = btns
        Instance.new("UICorner", b)
        b.MouseButton1Click:Connect(cb)
    end

    makeBtn("VIEW", Color3.fromRGB(60, 120, 255), 8, function()
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            Camera.CameraSubject = player.Character.Humanoid
        end
    end)

    makeBtn("GOTO", Color3.fromRGB(40, 180, 100), 34, function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
        end
    end)
end

local function refresh()
    for _, v in pairs(scrollFrame:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
    for _, p in pairs(Players:GetPlayers()) do createCard(p) end
end

Players.PlayerAdded:Connect(refresh)
Players.PlayerRemoving:Connect(refresh)
refresh()

---------------------------------------
-- 5. FOOTER: SPECTATE OFF & REFRESH
---------------------------------------
local footer = Instance.new("Frame")
footer.Size = UDim2.new(1, 0, 0, 50)
footer.Position = UDim2.new(0, 0, 1, -50)
footer.BackgroundTransparency = 1
footer.Parent = mainFrame

local resetCam = Instance.new("TextButton")
resetCam.Text = "RESET CAMERA (VIEW SELF)"
resetCam.Size = UDim2.new(1, -20, 0, 35)
resetCam.Position = UDim2.new(0, 10, 0, 0)
resetCam.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
resetCam.Font = Enum.Font.GothamBold
resetCam.TextColor3 = Color3.new(1,1,1)
resetCam.Parent = footer
Instance.new("UICorner", resetCam)

resetCam.MouseButton1Click:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        Camera.CameraSubject = LocalPlayer.Character.Humanoid
    end
end)

-- Close Button
local close = Instance.new("TextButton")
close.Text = "×"
close.Size = UDim2.new(0, 35, 0, 35)
close.Position = UDim2.new(1, -45, 0, 12)
close.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
close.TextColor3 = Color3.new(1,1,1)
close.TextSize = 25
close.Font = Enum.Font.GothamBold
close.Parent = mainFrame
Instance.new("UICorner", close)
close.MouseButton1Click:Connect(function() screenGui:Destroy() end)
