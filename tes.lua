-- credit: Xraxor1 (Original GUI/Intro structure)
-- Modification by Sptzyy
-- Feature: Universal Owner Label (Support All Maps)

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- 🔑 Ganti dengan UserId kamu (Owner)
local OWNER_USERID = 9374524895 

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
screenGui.Name = "OwnerLabelGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 100)
frame.Position = UDim2.new(0.4, -110, 0.5, -50)
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
title.Text = "OWNER LABEL FEATURE"
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

-- ================= TOGGLE CREATOR =================
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

-- ================= FEATURE: OWNER LABEL =================
local LABEL_ENABLED = false
local labelBillboard = nil

local function applyOwnerLabel(char)
    local head = char:FindFirstChild("Head")
    if head then
        if labelBillboard then
            labelBillboard:Destroy()
        end
        labelBillboard = Instance.new("BillboardGui")
        labelBillboard.Size = UDim2.new(0, 120, 0, 30)
        labelBillboard.StudsOffset = Vector3.new(0, 3, 0)
        labelBillboard.AlwaysOnTop = true
        labelBillboard.Parent = head

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = "👑 OWNER 👑"
        label.TextColor3 = Color3.fromRGB(255, 215, 0)
        label.TextScaled = true
        label.Font = Enum.Font.GothamBold
        label.Parent = labelBillboard
    end
end

createToggle("Owner Label", frame, 40, function(state)
    LABEL_ENABLED = state
    local owner = Players:GetPlayerByUserId(OWNER_USERID)

    if state then
        if owner and owner.Character then
            applyOwnerLabel(owner.Character)
        end
        if owner then
            owner.CharacterAdded:Connect(function(char)
                if LABEL_ENABLED then
                    applyOwnerLabel(char)
                end
            end)
        end
    else
        if labelBillboard then
            labelBillboard:Destroy()
            labelBillboard = nil
        end
    end
end)