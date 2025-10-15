local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- ** ⬇️ STATUS FITUR FLYFLING PART ⬇️ **
local isFlyflingActive = false
local flyflingConnection = nil
local isFlyflingRadiusOn = true 
local isFlyflingSpeedOn = true 
local isPartFollowActive = false 
local flyflingSpeedMultiplier = 30 
local flyflingRadius = 30 

-- 🔽 ANIMASI "BY : Xraxor" 🔽
do
    local introGui = Instance.new("ScreenGui")
    introGui.Name = "IntroAnimation"
    introGui.ResetOnSpawn = false
    introGui.Parent = player:WaitForChild("PlayerGui")

    local introLabel = Instance.new("TextLabel")
    introLabel.Size = UDim2.new(0, 300, 0, 50)
    introLabel.Position = UDim2.new(0.5, -150, 0.4, 0)
    introLabel.BackgroundTransparency = 1
    introLabel.Text = "By : Xraxor"
    introLabel.TextColor3 = Color3.fromRGB(40, 40, 40)
    introLabel.TextScaled = true
    introLabel.Font = Enum.Font.GothamBold
    introLabel.Parent = introGui

    local tweenInfoMove = TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
    local tweenMove = TweenService:Create(introLabel, tweenInfoMove, {Position = UDim2.new(0.5, -150, 0.42, 0)})

    local tweenInfoColor = TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
    local tweenColor = TweenService:Create(introLabel, tweenInfoColor, {TextColor3 = Color3.fromRGB(0, 0, 0)})

    tweenMove:Play()
    tweenColor:Play()

    task.wait(2)
    local fadeOut = TweenService:Create(introLabel, TweenInfo.new(0.5), {TextTransparency = 1})
    fadeOut:Play()
    fadeOut.Completed:Connect(function()
        introGui:Destroy()
    end)
end


-- 🔽 GUI Utama 🔽
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CoreFeaturesGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Frame utama 
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 100) 
frame.Position = UDim2.new(0.4, -110, 0.5, -50)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 15)
corner.Parent = frame

-- Judul GUI
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "CORE FEATURES"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = frame

-- ScrollingFrame untuk Daftar Pilihan Fitur
local featureScrollFrame = Instance.new("ScrollingFrame")
featureScrollFrame.Name = "FeatureList"
featureScrollFrame.Size = UDim2.new(1, -20, 1, -40)
featureScrollFrame.Position = UDim2.new(0.5, -100, 0, 35)
featureScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
featureScrollFrame.ScrollBarThickness = 6
featureScrollFrame.BackgroundTransparency = 1
featureScrollFrame.Parent = frame

local featureListLayout = Instance.new("UIListLayout")
featureListLayout.Padding = UDim.new(0, 5)
featureListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
featureListLayout.SortOrder = Enum.SortOrder.LayoutOrder
featureListLayout.Parent = featureScrollFrame

featureListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    featureScrollFrame.CanvasSize = UDim2.new(0, 0, 0, featureListLayout.AbsoluteContentSize.Y + 10)
    local newHeight = math.min(featureListLayout.AbsoluteContentSize.Y + 40 + 30, 600)
    frame.Size = UDim2.new(0, 220, 0, newHeight)
end)


-- 🔽 FUNGSI UTILITY GLOBAL 🔽

local function updateButtonStatus(button, isActive, featureName, isToggle)
    if not button or not button.Parent then return end
    local name = featureName or button.Name:gsub("Button", ""):gsub("_", " "):upper()
    
    if isToggle then 
        if isActive then
            button.Text = name .. ": ON"
            button.BackgroundColor3 = Color3.fromRGB(0, 180, 0) 
        else
            button.Text = name .. ": OFF"
            button.BackgroundColor3 = Color3.fromRGB(150, 0, 0) 
        end
    else 
        if isActive then
            button.Text = name .. ": ON"
            button.BackgroundColor3 = Color3.fromRGB(0, 150, 0) 
        else
            button.Text = name .. ": OFF"
            button.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
        end
    end
end


-- 🔽 FUNGSI FLYFLING PART 🔽

local function doFlyfling()
    if not isFlyflingActive or not player.Character then return end

    local myRoot = player.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    local myVelocity = myRoot.Velocity
    local speed = isFlyflingSpeedOn and flyflingSpeedMultiplier or 0
    local targetParts = {}

    -- Ambil semua part di Workspace
    for _, obj in ipairs(game.Workspace:GetDescendants()) do
        -- Cek kriteria: BasePart, tidak ditambatkan (Unanchored), bukan Baseplate, bukan bagian karakter/Humanoid
        if obj:IsA("BasePart") and obj.Name ~= "Baseplate" and obj.Anchored == false then
            -- Lewati jika part tersebut adalah bagian dari karakter pemain lain atau NPC
            if Players:GetPlayerFromCharacter(obj.Parent) or obj.Parent:FindFirstChildOfClass("Humanoid") then
                continue
            end
            
            local distance = (myRoot.Position - obj.Position).Magnitude
            
            -- Cek Radius
            if isFlyflingRadiusOn and distance > flyflingRadius then continue end
            
            -- Batasi massa part
            if obj:GetMass() < 1000 then 
                 table.insert(targetParts, obj)
            end
        end
    end

    -- Terapkan Gaya
    for _, part in ipairs(targetParts) do
        local direction = (part.Position - myRoot.Position).Unit
        local force = direction * part:GetMass() * speed * 10 
        
        -- Fling: Dorongan menjauhi pemain
        part.Velocity = part.Velocity + (force / part:GetMass())
        
        -- Part Follow: Membuat part mengikuti pemain (Hanya sumbu X dan Z)
        if isPartFollowActive then
            part.AssemblyLinearVelocity = Vector3.new(myVelocity.X, part.AssemblyLinearVelocity.Y, myVelocity.Z) 
        end
    end
end

local function toggleFlyfling(button)
    isFlyflingActive = not isFlyflingActive
    
    if isFlyflingActive then
        updateButtonStatus(button, true, "FLYFLING PART")
        flyflingConnection = RunService.Heartbeat:Connect(doFlyfling)
        FlyflingFrame.Visible = true 
        print("Flyfling Part AKTIF.")
    else
        updateButtonStatus(button, false, "FLYFLING PART")
        if flyflingConnection then
            flyflingConnection:Disconnect()
            flyflingConnection = nil
        end
        FlyflingFrame.Visible = false 
        print("Flyfling Part NONAKTIF.")
    end
end


-- 🔽 FUNGSI PEMBUAT TOMBOL FITUR 🔽

local function makeFeatureButton(name, color, callback, parent)
    local parentContainer = parent or featureScrollFrame

    local featButton = Instance.new("TextButton")
    featButton.Name = name:gsub(" ", "") .. "Button"
    featButton.Size = UDim2.new(0, 180, 0, 40)
    featButton.BackgroundColor3 = color
    featButton.Text = name
    featButton.TextColor3 = Color3.new(1, 1, 1)
    featButton.Font = Enum.Font.GothamBold
    featButton.TextSize = 12
    featButton.Parent = parentContainer

    local featCorner = Instance.new("UICorner")
    featCorner.CornerRadius = UDim.new(0, 10)
    featCorner.Parent = featButton

    featButton.MouseButton1Click:Connect(function()
        callback(featButton)
    end)
    return featButton
end

-- 🔽 PENAMBAHAN TOMBOL KE FEATURE LIST 🔽

-- Tombol FLYFLING PART (Tombol Utama)
local flyflingButton = makeFeatureButton("FLYFLING PART: OFF", Color3.fromRGB(120, 0, 0), toggleFlyfling)

-- 🔽 SUBMENU FLYFLING PART (Frame) 🔽

local FlyflingFrame = Instance.new("Frame")
FlyflingFrame.Name = "FlyflingSettings"
FlyflingFrame.Size = UDim2.new(1, -20, 0, 270) 
FlyflingFrame.Position = UDim2.new(0, 10, 0, 0)
FlyflingFrame.BackgroundTransparency = 1
FlyflingFrame.Visible = false 
FlyflingFrame.Parent = featureScrollFrame

local FlyflingLayout = Instance.new("UIListLayout")
FlyflingLayout.Padding = UDim.new(0, 5)
FlyflingLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
FlyflingLayout.SortOrder = Enum.SortOrder.LayoutOrder
FlyflingLayout.Parent = FlyflingFrame

-- Tombol PART FOLLOW
local partFollowButton = makeFeatureButton("PART FOLLOW: OFF", Color3.fromRGB(150, 0, 0), function(button)
    isPartFollowActive = not isPartFollowActive
    updateButtonStatus(button, isPartFollowActive, "PART FOLLOW", true)
end, FlyflingFrame)


-- Tombol Radius ON/OFF
local radiusButton = makeFeatureButton("RADIUS ON/OFF", Color3.fromRGB(0, 180, 0), function(button)
    isFlyflingRadiusOn = not isFlyflingRadiusOn
    updateButtonStatus(button, isFlyflingRadiusOn, "RADIUS", true)
end, FlyflingFrame)

-- Tombol Speed ON/OFF
local speedToggleButton = makeFeatureButton("SPEED ON/OFF", Color3.fromRGB(0, 180, 0), function(button)
    isFlyflingSpeedOn = not isFlyflingSpeedOn
    updateButtonStatus(button, isFlyflingSpeedOn, "SPEED", true)
    
    local speedInput = FlyflingFrame:FindFirstChild("SpeedInput")
    if speedInput then
        speedInput.PlaceholderText = "Atur Speed: " .. tostring(flyflingSpeedMultiplier)
    end
end, FlyflingFrame)

-- Input Jumlah Speed
local speedInput = Instance.new("TextBox")
speedInput.Name = "SpeedInput"
speedInput.Size = UDim2.new(0, 180, 0, 40)
speedInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
speedInput.PlaceholderText = "Atur Speed: " .. tostring(flyflingSpeedMultiplier) 
speedInput.Text = ""
speedInput.TextColor3 = Color3.new(1, 1, 1)
speedInput.Font = Enum.Font.Gotham
speedInput.TextSize = 12
speedInput.Parent = FlyflingFrame

speedInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local newSpeed = tonumber(speedInput.Text)
        if newSpeed and newSpeed >= 0 then
            flyflingSpeedMultiplier = newSpeed
            speedInput.PlaceholderText = "Atur Speed: " .. tostring(flyflingSpeedMultiplier)
            speedInput.Text = "" 
        else
            speedInput.Text = "Invalid Number!"
            task.wait(1)
            speedInput.Text = ""
        end
    end
end)


-- Button Speed List (Jumlah x)
local speedListFrame = Instance.new("Frame")
speedListFrame.Name = "SpeedListFrame"
speedListFrame.Size = UDim2.new(0, 180, 0, 40) 
speedListFrame.BackgroundTransparency = 1
speedListFrame.Parent = FlyflingFrame

local speedListLayout = Instance.new("UIListLayout")
speedListLayout.Padding = UDim.new(0, 5)
speedListLayout.FillDirection = Enum.FillDirection.Horizontal
speedListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
speedListLayout.SortOrder = Enum.SortOrder.LayoutOrder
speedListLayout.Parent = speedListFrame

local speedOptions = {10, 30, 50, 80, 150} 

for i, speedValue in ipairs(speedOptions) do
    local speedListItem = Instance.new("TextButton")
    speedListItem.Name = "SpeedList" .. speedValue .. "Button"
    speedListItem.Size = UDim2.new(1 / #speedOptions, -5, 1, 0) 
    speedListItem.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    speedListItem.Text = tostring(speedValue) .. "x"
    speedListItem.TextColor3 = Color3.new(1, 1, 1)
    speedListItem.Font = Enum.Font.GothamBold
    speedListItem.TextSize = 10
    speedListItem.Parent = speedListFrame

    local listItemCorner = Instance.new("UICorner")
    listItemCorner.CornerRadius = UDim.new(0, 5)
    listItemCorner.Parent = speedListItem

    speedListItem.MouseButton1Click:Connect(function()
        flyflingSpeedMultiplier = speedValue
        speedInput.PlaceholderText = "Atur Speed: " .. tostring(flyflingSpeedMultiplier)
        speedInput.Text = "" 
        print("Flyfling Speed diatur ke: " .. tostring(speedValue))
    end)
end

-- Pastikan FlyflingLayout dan featureListLayout diperbarui
FlyflingLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    FlyflingFrame.Size = UDim2.new(1, -20, 0, FlyflingLayout.AbsoluteContentSize.Y + 10)
    featureListLayout.AbsoluteContentSize = featureListLayout.AbsoluteContentSize 
end)


-- 🔽 LOGIKA CHARACTER ADDED (PENTING UNTUK MEMPERTAHANKAN STATUS) 🔽
player.CharacterAdded:Connect(function(char)
    -- Pertahankan status Flyfling Part
    if isFlyflingActive then
        local button = featureScrollFrame:FindFirstChild("FlyflingPartButton")
        if button then 
            if not flyflingConnection then
                flyflingConnection = RunService.Heartbeat:Connect(doFlyfling)
            end
        end
    end
end)


-- Atur status awal tombol
updateButtonStatus(flyflingButton, isFlyflingActive, "FLYFLING PART")
updateButtonStatus(partFollowButton, isPartFollowActive, "PART FOLLOW", true)
updateButtonStatus(radiusButton, isFlyflingRadiusOn, "RADIUS", true)
updateButtonStatus(speedToggleButton, isFlyflingSpeedOn, "SPEED", true)
