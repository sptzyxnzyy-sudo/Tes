local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- Global variable untuk auto-run setelah teleport
if _G.SearchingFor == nil then _G.SearchingFor = "" end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "IkyyPremium_V3_Hunter"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -150)
MainFrame.Size = UDim2.new(0, 220, 0, 380) -- Ukuran ditambah untuk fitur Hunter
MainFrame.Active = true
MainFrame.Draggable = true

-- Rainbow Border
local Border = Instance.new("Frame")
Border.Name = "RainbowBorder"
Border.Parent = MainFrame
Border.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Border.BorderSizePixel = 0
Border.Position = UDim2.new(0, -2, 0, -2)
Border.Size = UDim2.new(1, 4, 1, 4)
Border.ZIndex = 0
Instance.new("UICorner", Border).CornerRadius = UDim.new(0, 8)
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

-- Profile Section
local ProfileFrame = Instance.new("Frame")
ProfileFrame.Size = UDim2.new(1, 0, 0, 60)
ProfileFrame.BackgroundTransparency = 1
ProfileFrame.Parent = MainFrame

local AvatarImg = Instance.new("ImageLabel")
AvatarImg.Size = UDim2.new(0, 45, 0, 45)
AvatarImg.Position = UDim2.new(0, 10, 0, 10)
AvatarImg.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. LocalPlayer.UserId .. "&width=420&height=420&format=png"
AvatarImg.Parent = ProfileFrame
Instance.new("UICorner", AvatarImg).CornerRadius = UDim.new(1, 0)

local UserName = Instance.new("TextLabel")
UserName.Text = LocalPlayer.DisplayName
UserName.Position = UDim2.new(0, 65, 0, 12)
UserName.Size = UDim2.new(0, 140, 0, 20)
UserName.TextColor3 = Color3.fromRGB(255, 255, 255)
UserName.TextXAlignment = Enum.TextXAlignment.Left
UserName.Font = Enum.Font.SourceSansBold
UserName.BackgroundTransparency = 1
UserName.TextSize = 16
UserName.Parent = ProfileFrame

-- Buttons Container
local Container = Instance.new("Frame")
Container.Position = UDim2.new(0, 0, 0, 70)
Container.Size = UDim2.new(1, 0, 0, 120)
Container.BackgroundTransparency = 1
Container.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.Parent = Container
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIList.Padding = UDim.new(0, 10)

-- Rainbow Logic
task.spawn(function()
    while true do
        for i = 0, 1, 0.01 do
            Border.BackgroundColor3 = Color3.fromHSV(i, 1, 1)
            task.wait(0.02)
        end
    end
end)

local function CreateStyledButton(name, icon, color, func)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0.9, 0, 0, 45)
    Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Btn.Text = "          " .. name
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.SourceSansSemibold
    Btn.TextSize = 14
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    Btn.Parent = Container
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    
    local IconImg = Instance.new("ImageLabel")
    IconImg.Size = UDim2.new(0, 25, 0, 25)
    IconImg.Position = UDim2.new(0, 10, 0.5, -12)
    IconImg.Image = icon
    IconImg.BackgroundTransparency = 1
    IconImg.Parent = Btn
    
    local Active = false
    Btn.MouseButton1Click:Connect(function()
        Active = not Active
        Btn.BackgroundColor3 = Active and color or Color3.fromRGB(35, 35, 35)
        task.spawn(function()
            while Active do
                pcall(func)
                task.wait(0.1)
            end
        end)
    end)
end

-- 1 & 2. Auto Farm Buttons
CreateStyledButton("AUTO BELI PADI", "rbxassetid://6031764630", Color3.fromRGB(0, 102, 204), function()
    game:GetService("ReplicatedStorage").Remotes.TutorialRemotes.RequestShop:InvokeServer("BUY", "Bibit Padi", 1)
end)

CreateStyledButton("AUTO SELL PADI", "rbxassetid://6031154871", Color3.fromRGB(153, 0, 0), function()
    game:GetService("ReplicatedStorage").Remotes.TutorialRemotes.RequestSell:InvokeServer("SELL", "Padi", 45)
end)

-- 3. USERNAME HUNTER SECTION
local HunterFrame = Instance.new("Frame")
HunterFrame.Size = UDim2.new(0.9, 0, 0, 140)
HunterFrame.Position = UDim2.new(0.05, 0, 0, 200)
HunterFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
HunterFrame.Parent = MainFrame
Instance.new("UICorner", HunterFrame)

local HTitle = Instance.new("TextLabel")
HTitle.Text = "TARGET HUNTER"
HTitle.Size = UDim2.new(1, 0, 0, 25)
HTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
HTitle.Font = Enum.Font.SourceSansBold
HTitle.BackgroundTransparency = 1
HTitle.Parent = HunterFrame

local TargetInput = Instance.new("TextBox")
TargetInput.Size = UDim2.new(0.9, 0, 0, 30)
TargetInput.Position = UDim2.new(0.05, 0, 0.25, 0)
TargetInput.PlaceholderText = "Ketik Username..."
TargetInput.Text = _G.SearchingFor
TargetInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
TargetInput.TextColor3 = Color3.fromRGB(255, 255, 255)
TargetInput.Parent = HunterFrame
Instance.new("UICorner", TargetInput)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.Position = UDim2.new(0, 0, 0.5, 0)
StatusLabel.Text = "Status: Idle"
StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextSize = 12
StatusLabel.Parent = HunterFrame

local function ServerHop()
    StatusLabel.Text = "Status: Hopping..."
    local success, result = pcall(function()
        return game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
    end)
    if success then
        local data = HttpService:JSONDecode(result).data
        for _, server in ipairs(data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id)
                break
            end
        end
    end
end

local function StartHunting()
    local name = TargetInput.Text
    if name == "" then return end
    _G.SearchingFor = name
    StatusLabel.Text = "Status: Checking..."
    task.wait(1)
    
    local found = false
    for _, p in pairs(Players:GetPlayers()) do
        if p.Name:lower() == name:lower() then found = true break end
    end
    
    if found then
        StatusLabel.Text = "Status: TARGET FOUND!"
        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        _G.SearchingFor = ""
    else
        StatusLabel.Text = "Status: Not here. Hopping..."
        task.wait(1)
        ServerHop()
    end
end

local HuntBtn = Instance.new("TextButton")
HuntBtn.Size = UDim2.new(0.9, 0, 0, 35)
HuntBtn.Position = UDim2.new(0.05, 0, 0.7, 0)
HuntBtn.Text = "START HUNT"
HuntBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
HuntBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
HuntBtn.Parent = HunterFrame
Instance.new("UICorner", HuntBtn)

HuntBtn.MouseButton1Click:Connect(StartHunting)

-- Watermark
local WM = Instance.new("TextLabel")
WM.Text = "IKYY EXECUTOR v3.1"
WM.Position = UDim2.new(0, 0, 1, -20)
WM.Size = UDim2.new(1, 0, 0, 15)
WM.BackgroundTransparency = 1
WM.TextColor3 = Color3.fromRGB(80, 80, 80)
WM.TextSize = 10
WM.Parent = MainFrame

-- Auto Run Hunter after teleport
if _G.SearchingFor ~= "" then task.spawn(StartHunting) end
