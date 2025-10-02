-- LocalScript (taruh di StarterPlayerScripts)
-- ESP + NameTag + Tracer + draggable menu + intro animation
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

-- Root ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ESPMenu"
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui

-- ---------- Intro animation ----------
local introLabel = Instance.new("TextLabel")
introLabel.Size = UDim2.new(1,0,1,0)
introLabel.BackgroundTransparency = 1
introLabel.Text = "MOD SPTZYY"
introLabel.TextColor3 = Color3.new(1,1,1)
introLabel.Font = Enum.Font.SourceSansBold
introLabel.TextSize = 56
introLabel.TextTransparency = 1
introLabel.Parent = screenGui

local function playIntro()
    local tweenIn = TweenService:Create(introLabel, TweenInfo.new(0.9, Enum.EasingStyle.Quad), {TextTransparency = 0})
    tweenIn:Play(); tweenIn.Completed:Wait()
    task.wait(1.0)
    local tweenOut = TweenService:Create(introLabel, TweenInfo.new(0.9, Enum.EasingStyle.Quad), {TextTransparency = 1})
    tweenOut:Play(); tweenOut.Completed:Wait()
    introLabel:Destroy()
end

-- ---------- UI: main frame, floating, buttons ----------
local frame = Instance.new("Frame")
frame.Name = "MenuFrame"
frame.Size = UDim2.new(0, 220, 0, 140)
frame.Position = UDim2.new(0, 20, 0, 120)
frame.BackgroundColor3 = Color3.fromRGB(40,40,40)
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -35, 0, 30)
title.Position = UDim2.new(0, 8, 0, 0)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1,1,1)
title.Text = "Fitur Menu"
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseBtn"
closeButton.Size = UDim2.new(0,26,0,26)
closeButton.Position = UDim2.new(1, -30, 0, 4)
closeButton.BackgroundColor3 = Color3.fromRGB(255,0,0)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.new(1,1,1)
closeButton.Font = Enum.Font.SourceSansBold
closeButton.TextSize = 18
closeButton.Parent = frame

local espButton = Instance.new("TextButton")
espButton.Name = "ESP_Toggle"
espButton.Size = UDim2.new(1,-12,0,40)
espButton.Position = UDim2.new(0,6,0,40)
espButton.BackgroundColor3 = Color3.fromRGB(80,80,80)
espButton.Text = "ESP: OFF"
espButton.TextColor3 = Color3.new(1,1,1)
espButton.Font = Enum.Font.SourceSansBold
espButton.TextSize = 16
espButton.Parent = frame

local floatingButton = Instance.new("TextButton")
floatingButton.Name = "FloatingBtn"
floatingButton.Size = UDim2.new(0,48,0,48)
floatingButton.Position = UDim2.new(0, 18, 0, 120)
floatingButton.BackgroundColor3 = Color3.fromRGB(50,150,250)
floatingButton.Text = "⚙️"
floatingButton.TextColor3 = Color3.new(1,1,1)
floatingButton.Font = Enum.Font.SourceSansBold
floatingButton.TextSize = 26
floatingButton.Visible = false
floatingButton.Active = true
floatingButton.Parent = screenGui

-- container for GUI fallback tracers
local tracerGuiContainer = Instance.new("Folder")
tracerGuiContainer.Name = "TracerGUIs"
tracerGuiContainer.Parent = screenGui

-- ---------- state & persistence ----------
local ESP_ENABLED = false
local savedESP = screenGui:GetAttribute("ESPEnabled")
if type(savedESP) == "boolean" then ESP_ENABLED = savedESP end
local function saveESPState() screenGui:SetAttribute("ESPEnabled", ESP_ENABLED) end

-- ---------- detect Drawing availability ----------
local drawingAvailable = false
do
    local ok, _ = pcall(function()
        if Drawing and type(Drawing.new) == "function" then
            local t = Drawing.new("Line")
            t.Visible = false
            t:Remove()
            drawingAvailable = true
        end
    end)
    if not ok then drawingAvailable = false end
end

-- ---------- helper: create NameTag & Highlight & tracer ----------
local tracers = {}

local function createNameTag(player)
    if not player.Character or not player.Character:FindFirstChild("Head") then return end
    if player.Character:FindFirstChild("NameTag") then return end
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "NameTag"
    billboard.Adornee = player.Character.Head
    billboard.Size = UDim2.new(0,160,0,32)
    billboard.StudsOffset = Vector3.new(0, 2.2, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = player.Character
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,0,1,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = player.Name
    lbl.TextColor3 = Color3.new(1,1,1)
    lbl.Font = Enum.Font.SourceSansBold
    lbl.TextSize = 14
    lbl.Parent = billboard
end

local function createHighlight(player)
    if not player.Character or player.Character:FindFirstChild("PlayerESP") then return end
    local h = Instance.new("Highlight")
    h.Name = "PlayerESP"
    h.FillColor = Color3.fromRGB(0,255,0)
    h.OutlineColor = Color3.fromRGB(255,255,255)
    h.FillTransparency = 0.55
    h.OutlineTransparency = 0
    h.Parent = player.Character
end

local function createTracerFor(player)
    if tracers[player.Name] then
        if tracers[player.Name].drawing then pcall(function() tracers[player.Name].drawing:Remove() end) end
        if tracers[player.Name].frame then pcall(function() tracers[player.Name].frame:Destroy() end) end
        tracers[player.Name] = nil
    end
    if drawingAvailable then
        local line = Drawing.new("Line")
        line.Color = Color3.fromRGB(0,255,0)
        line.Thickness = 1.8
        line.Transparency = 1
        line.Visible = false
        tracers[player.Name] = { drawing = line }
    else
        local lineFrame = Instance.new("Frame")
        lineFrame.Name = "TracerFrame_"..player.Name
        lineFrame.AnchorPoint = Vector2.new(0.5, 0.5)
        lineFrame.Size = UDim2.new(0, 10, 0, 3)
        lineFrame.BackgroundColor3 = Color3.fromRGB(0,255,0)
        lineFrame.BorderSizePixel = 0
        lineFrame.Visible = false
        lineFrame.Parent = tracerGuiContainer
        tracers[player.Name] = { frame = lineFrame }
    end
end

local function removeESPFor(player)
    if player.Character then
        if player.Character:FindFirstChild("PlayerESP") then pcall(function() player.Character.PlayerESP:Destroy() end) end
        if player.Character:FindFirstChild("NameTag") then pcall(function() player.Character.NameTag:Destroy() end) end
    end
    if tracers[player.Name] then
        if tracers[player.Name].drawing then pcall(function() tracers[player.Name].drawing:Remove() end) end
        if tracers[player.Name].frame then pcall(function() tracers[player.Name].frame:Destroy() end) end
        tracers[player.Name] = nil
    end
end

local function addESPFor(player)
    if player == LocalPlayer or not player.Character then return end
    createHighlight(player)
    createNameTag(player)
    createTracerFor(player)
end

-- ---------- update tracer positions ----------
RunService.RenderStepped:Connect(function()
    if not ESP_ENABLED then
        for _, data in pairs(tracers) do
            if data.drawing then pcall(function() data.drawing.Visible = false end) end
            if data.frame then pcall(function() data.frame.Visible = false end) end
        end
        return
    end
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local myPos, myOnScreen = Camera:WorldToViewportPoint(LocalPlayer.Character.HumanoidRootPart.Position)
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and tracers[player.Name] then
            local targetPos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if onScreen and myOnScreen then
                local from = Vector2.new(myPos.X, myPos.Y)
                local to = Vector2.new(targetPos.X, targetPos.Y)
                if tracers[player.Name].drawing then
                    local line = tracers[player.Name].drawing
                    line.From, line.To, line.Visible = from, to, true
                elseif tracers[player.Name].frame then
                    local frameLine = tracers[player.Name].frame
                    local dx, dy = to.X-from.X, to.Y-from.Y
                    local length = math.sqrt(dx*dx+dy*dy)
                    local midX, midY = (from.X+to.X)/2, (from.Y+to.Y)/2
                    frameLine.Size = UDim2.new(0, math.max(2,length), 0, 3)
                    frameLine.Position = UDim2.new(0, midX, 0, midY)
                    frameLine.Rotation = math.deg(math.atan2(dy,dx))
                    frameLine.Visible = true
                end
            else
                if tracers[player.Name].drawing then tracers[player.Name].drawing.Visible = false end
                if tracers[player.Name].frame then tracers[player.Name].frame.Visible = false end
            end
        end
    end
end)

-- ---------- refresh / toggle logic ----------
local function refreshAllESP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            if ESP_ENABLED then addESPFor(p) else removeESPFor(p) end
        end
    end
end

local function updateESPButtonVisual()
    if ESP_ENABLED then
        espButton.Text, espButton.BackgroundColor3 = "ESP: ON", Color3.fromRGB(0,170,0)
    else
        espButton.Text, espButton.BackgroundColor3 = "ESP: OFF", Color3.fromRGB(80,80,80)
    end
    saveESPState()
end

-- ---------- UI interactions ----------
espButton.MouseButton1Click:Connect(function()
    ESP_ENABLED = not ESP_ENABLED
    updateESPButtonVisual()
    refreshAllESP()
end)

closeButton.MouseButton1Click:Connect(function()
    frame.Visible = false
    floatingButton.Visible = true
    screenGui:SetAttribute("MenuClosed", true)
end)
floatingButton.MouseButton1Click:Connect(function()
    frame.Visible = true
    floatingButton.Visible = false
    screenGui:SetAttribute("MenuClosed", false)
end)

-- ---------- player events ----------
Players.PlayerAdded:Connect(function(player)
    if player == LocalPlayer then return end
    player.CharacterAdded:Connect(function()
        task.wait(0.9)
        if ESP_ENABLED then addESPFor(player) end
    end)
end)
Players.PlayerRemoving:Connect(function(player) removeESPFor(player) end)
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        if ESP_ENABLED and p.Character then addESPFor(p) else createTracerFor(p) end
        p.CharacterAdded:Connect(function() task.wait(0.9); if ESP_ENABLED then addESPFor(p) end end)
    end
end

-- ---------- draggable (title for frame, self for floating) ----------
local function makeDraggable(guiObject, dragHandle, saveKey)
    local dragging, dragStart, startPos = false, Vector2.new(), UDim2.new()
    local saved = screenGui:GetAttribute(saveKey)
    if saved and typeof(saved) == "UDim2" then guiObject.Position = saved end

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging, dragStart, startPos = true, input.Position, guiObject.Position
            local conn; conn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging=false; conn:Disconnect() end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset+delta.X, startPos.Y.Scale, startPos.Y.Offset+delta.Y)
            guiObject.Position = newPos
            screenGui:SetAttribute(saveKey, newPos)
        end
    end)
end

makeDraggable(frame, title, "MenuPos")
makeDraggable(floatingButton, floatingButton, "FloatPos")

-- ---------- initialization ----------
task.defer(function()
    playIntro()
    if screenGui:GetAttribute("MenuClosed") == true then
        frame.Visible = false
        floatingButton.Visible = true
    else
        frame.Visible = true
        floatingButton.Visible = false
    end
end)

updateESPButtonVisual()
refreshAllESP()
print("[ESPMenu] Initialized. Drawing available:", drawingAvailable)