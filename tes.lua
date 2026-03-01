local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Create Canvas
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "IkyyPremium_V3"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -100)
MainFrame.Size = UDim2.new(0, 220, 0, 280)
MainFrame.Active = true
MainFrame.Draggable = true

-- Rainbow Border Effect
local Border = Instance.new("Frame")
Border.Name = "RainbowBorder"
Border.Parent = MainFrame
Border.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Border.BorderSizePixel = 0
Border.Position = UDim2.new(0, -2, 0, -2)
Border.Size = UDim2.new(1, 4, 1, 4)
Border.ZIndex = 0

local UICorner_B = Instance.new("UICorner")
UICorner_B.CornerRadius = UDim.new(0, 8)
UICorner_B.Parent = Border

local UICorner_M = Instance.new("UICorner")
UICorner_M.CornerRadius = UDim.new(0, 8)
UICorner_M.Parent = MainFrame

-- Profile Section
local ProfileFrame = Instance.new("Frame")
ProfileFrame.Size = UDim2.new(1, 0, 0, 60)
ProfileFrame.BackgroundTransparency = 1
ProfileFrame.Parent = MainFrame

local AvatarImg = Instance.new("ImageLabel")
AvatarImg.Size = UDim2.new(0, 45, 0, 45)
AvatarImg.Position = UDim2.new(0, 10, 0, 10)
AvatarImg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
AvatarImg.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. LocalPlayer.UserId .. "&width=420&height=420&format=png"
AvatarImg.Parent = ProfileFrame

local UICorner_A = Instance.new("UICorner")
UICorner_A.CornerRadius = UDim.new(1, 0)
UICorner_A.Parent = AvatarImg

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

local UserTag = Instance.new("TextLabel")
UserTag.Text = "@" .. LocalPlayer.Name
UserTag.Position = UDim2.new(0, 65, 0, 28)
UserTag.Size = UDim2.new(0, 140, 0, 20)
UserTag.TextColor3 = Color3.fromRGB(180, 180, 180)
UserTag.TextXAlignment = Enum.TextXAlignment.Left
UserTag.Font = Enum.Font.SourceSans
UserTag.BackgroundTransparency = 1
UserTag.TextSize = 12
UserTag.Parent = ProfileFrame

-- Buttons Container
local Container = Instance.new("Frame")
Container.Position = UDim2.new(0, 0, 0, 70)
Container.Size = UDim2.new(1, 0, 1, -70)
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
            local color = Color3.fromHSV(i, 1, 1)
            Border.BackgroundColor3 = color
            task.wait(0.02)
        end
    end
end)

-- Button Function
local function CreateStyledButton(name, icon, color, func)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0.9, 0, 0, 45)
    Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Btn.Text = "          " .. name -- Spacing for icon
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.SourceSansSemibold
    Btn.TextSize = 15
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    Btn.Parent = Container
    
    local UICorner_Btn = Instance.new("UICorner")
    UICorner_Btn.CornerRadius = UDim.new(0, 6)
    UICorner_Btn.Parent = Btn
    
    local IconImg = Instance.new("ImageLabel")
    IconImg.Size = UDim2.new(0, 25, 0, 25)
    IconImg.Position = UDim2.new(0, 10, 0.5, -12)
    IconImg.Image = icon
    IconImg.BackgroundTransparency = 1
    IconImg.Parent = Btn
    
    local Active = false
    Btn.MouseButton1Click:Connect(function()
        Active = not Active
        if Active then
            Btn.BackgroundColor3 = color
            task.spawn(function()
                while Active do
                    pcall(func)
                    task.wait()
                end
            end)
        else
            Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        end
    end)
end

-- ICONS: Beli (Cart icon), Jual (Dollar icon)
local CART_ICON = "rbxassetid://6031764630"
local SELL_ICON = "rbxassetid://6031154871"

-- Add Buttons
CreateStyledButton("AUTO BELI PADI", CART_ICON, Color3.fromRGB(0, 102, 204), function()
    game:GetService("ReplicatedStorage").Remotes.TutorialRemotes.RequestShop:InvokeServer("BUY", "Bibit Padi", 1)
end)

CreateStyledButton("AUTO SELL PADI", SELL_ICON, Color3.fromRGB(153, 0, 0), function()
    game:GetService("ReplicatedStorage").Remotes.TutorialRemotes.RequestSell:InvokeServer("SELL", "Padi", 45)
end)

-- Watermark
local WM = Instance.new("TextLabel")
WM.Text = "IKYY EXECUTOR v3"
WM.Position = UDim2.new(0, 0, 1, -25)
WM.Size = UDim2.new(1, 0, 0, 20)
WM.BackgroundTransparency = 1
WM.TextColor3 = Color3.fromRGB(80, 80, 80)
WM.TextSize = 10
WM.Parent = MainFrame
