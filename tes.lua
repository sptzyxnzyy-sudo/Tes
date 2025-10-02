-- credit: Xraxor1 (Original GUI/Intro structure)
-- Modification by Sptzyy
-- Features: Auto Unlock All VIP Maps + Auto Chat (All/Team/Whisper)

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- ================= INTRO ANIMATION =================
do
    local introGui = Instance.new("ScreenGui")
    introGui.Name = "IntroAnimation"
    introGui.ResetOnSpawn = false
    introGui.Parent = player:WaitForChild("PlayerGui")

    local introLabel = Instance.new("TextLabel")
    introLabel.Size = UDim2.new(0, 300, 0, 50)
    introLabel.Position = UDim2.new(0.5, -150, 0.4, 0)
    introLabel.BackgroundTransparency = 1
    introLabel.Text = "By : Sptzyy"
    introLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    introLabel.TextScaled = true
    introLabel.Font = Enum.Font.GothamBold
    introLabel.Parent = introGui

    local tweenInfoMove = TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
    local tweenMove = TweenService:Create(introLabel, tweenInfoMove, {Position = UDim2.new(0.5, -150, 0.42, 0)})
    tweenMove:Play()

    task.wait(2)
    local fadeOut = TweenService:Create(introLabel, TweenInfo.new(0.6), {TextTransparency = 1})
    fadeOut:Play()
    fadeOut.Completed:Connect(function()
        introGui:Destroy()
    end)
end

-- ================= CORE GUI =================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CoreFeaturesGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 280, 0, 240)
frame.Position = UDim2.new(0.4, -140, 0.5, -120)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 15)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "AUTO FEATURES"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = frame

-- ❌ tombol close
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(1, -30, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.Parent = frame

local cornerClose = Instance.new("UICorner")
cornerClose.CornerRadius = UDim.new(1, 0)
cornerClose.Parent = closeBtn

local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 40, 0, 40)
openBtn.Position = UDim2.new(0, 10, 1, -50)
openBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
openBtn.Text = "≡"
openBtn.TextColor3 = Color3.new(1, 1, 1)
openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = 20
openBtn.Visible = false
openBtn.Parent = screenGui

local cornerOpen = Instance.new("UICorner")
cornerOpen.CornerRadius = UDim.new(1, 0)
cornerOpen.Parent = openBtn

closeBtn.MouseButton1Click:Connect(function()
    frame.Visible = false
    openBtn.Visible = true
end)
openBtn.MouseButton1Click:Connect(function()
    frame.Visible = true
    openBtn.Visible = false
end)

-- ================= TOGGLE BUTTON CREATOR =================
local function createToggle(name, parent, posY, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 35)
    btn.Position = UDim2.new(0, 10, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.Text = name .. ": OFF"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Parent = parent

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        if state then
            btn.Text = name .. ": ON"
            btn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        else
            btn.Text = name .. ": OFF"
            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        end
        callback(state)
    end)
    return btn
end

-- ================= FEATURE: AUTO UNLOCK VIP ALL =================
local VIP_UNLOCK = false
local function unlockVIPAll()
    while VIP_UNLOCK do
        task.wait(2)
        for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") and string.find(string.lower(obj.Name), "vip") then
                obj:FireServer(true)
            end
        end
    end
end

createToggle("Auto Unlock All VIP", frame, 40, function(state)
    VIP_UNLOCK = state
    if state then
        task.spawn(unlockVIPAll)
    end
end)

-- ================= FEATURE: AUTO CHAT (All / Team / Whisper) =================
local AUTO_CHAT = false
local CHAT_MESSAGE = "Halo semua!"
local CHAT_MODE = "All"
local WHISPER_TARGET = "PlayerName"

-- input pesan
local chatBox = Instance.new("TextBox")
chatBox.Size = UDim2.new(1, -20, 0, 30)
chatBox.Position = UDim2.new(0, 10, 0, 80)
chatBox.PlaceholderText = "Masukkan pesan..."
chatBox.Text = CHAT_MESSAGE
chatBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
chatBox.TextColor3 = Color3.new(1, 1, 1)
chatBox.Font = Enum.Font.Gotham
chatBox.TextSize = 14
chatBox.ClearTextOnFocus = false
chatBox.Parent = frame

chatBox.FocusLost:Connect(function()
    CHAT_MESSAGE = chatBox.Text
end)

-- input mode (All / Team / Whisper)
local modeBox = Instance.new("TextBox")
modeBox.Size = UDim2.new(1, -20, 0, 30)
modeBox.Position = UDim2.new(0, 10, 0, 120)
modeBox.PlaceholderText = "Mode: All/Team/Whisper"
modeBox.Text = CHAT_MODE
modeBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
modeBox.TextColor3 = Color3.new(1, 1, 1)
modeBox.Font = Enum.Font.Gotham
modeBox.TextSize = 14
modeBox.ClearTextOnFocus = false
modeBox.Parent = frame

modeBox.FocusLost:Connect(function()
    CHAT_MODE = modeBox.Text
end)

-- input target whisper
local whisperBox = Instance.new("TextBox")
whisperBox.Size = UDim2.new(1, -20, 0, 30)
whisperBox.Position = UDim2.new(0, 10, 0, 160)
whisperBox.PlaceholderText = "Nama Player (Whisper)"
whisperBox.Text = WHISPER_TARGET
whisperBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
whisperBox.TextColor3 = Color3.new(1, 1, 1)
whisperBox.Font = Enum.Font.Gotham
whisperBox.TextSize = 14
whisperBox.ClearTextOnFocus = false
whisperBox.Parent = frame

whisperBox.FocusLost:Connect(function()
    WHISPER_TARGET = whisperBox.Text
end)

local function autoChatLoop()
    while AUTO_CHAT do
        task.wait() -- no delay, secepat mungkin
        if CHAT_MODE == "All" then
            ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(CHAT_MESSAGE, "All")
        elseif CHAT_MODE == "Team" then
            ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(CHAT_MESSAGE, "Team")
        elseif CHAT_MODE == "Whisper" then
            ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/w " .. WHISPER_TARGET .. " " .. CHAT_MESSAGE, "All")
        end
    end
end

createToggle("Auto Chat", frame, 200, function(state)
    AUTO_CHAT = state
    if state then
        CHAT_MESSAGE = chatBox.Text
        CHAT_MODE = modeBox.Text
        WHISPER_TARGET = whisperBox.Text
        task.spawn(autoChatLoop)
    end
end)