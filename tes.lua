-- LocalScript (taruh di StarterPlayerScripts)
-- ESP + NameTag + Tracer (Drawing if available, fallback GUI) + draggable menu + intro animation
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
-- try restore ESP state stored in attribute
local savedESP = screenGui:GetAttribute("ESPEnabled")
if type(savedESP) == "boolean" then
    ESP_ENABLED = savedESP
end

local function saveESPState()
    screenGui:SetAttribute("ESPEnabled", ESP_ENABLED)
end

-- ---------- detect Drawing availability ----------
local drawingAvailable = false
do
    local ok, _ = pcall(function()
        -- try to create a test drawing object
        if Drawing and type(Drawing.new) == "function" then
            local t = Drawing.new("Line")
            t.Visible = false
            t:Remove()
            drawingAvailable = true
        else
            drawingAvailable = false
        end
    end)
    if not ok then drawingAvailable = false end
end

-- ---------- helper: create NameTag & Highlight & tracer storage ----------
local tracers = {} -- key = player.Name -> {drawing=line} or {frame=frameGui}

local function createNameTag(player)
    -- create if not exists
    if not player.Character or not player.Character:FindFirstChild("Head") then return end
    if player.Character:FindFirstChild("NameTag") then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "NameTag"
    billboard.Adornee = player.Character:FindFirstChild("Head")
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
    if not player.Character then return end
    if player.Character:FindFirstChild("PlayerESP") then return end
    local h = Instance.new("Highlight")
    h.Name = "PlayerESP"
    h.FillColor = Color3.fromRGB(0,255,0)
    h.OutlineColor = Color3.fromRGB(255,255,255)
    h.FillTransparency = 0.55
    h.OutlineTransparency = 0
    h.Parent = player.Character
end

local function createTracerFor(player)
    -- ensure removal of old tracer if any
    if tracers[player.Name] then
        -- remove existing
        if tracers[player.Name].drawing then
            pcall(function() tracers[player.Name].drawing:Remove() end)
        end
        if tracers[player.Name].frame then
            pcall(function() tracers[player.Name].frame:Destroy() end)
        end
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
        -- GUI fallback: create a Frame to act as line
        local lineFrame = Instance.new("Frame")
        lineFrame.Name = "TracerFrame_"..player.Name
        lineFrame.AnchorPoint = Vector2.new(0.5, 0.5)
        lineFrame.Size = UDim2.new(0, 10, 0, 3) -- width will be updated
        lineFrame.Position = UDim2.new(0.5,0,0.5,0)
        lineFrame.BackgroundColor3 = Color3.fromRGB(0,255,0)
        lineFrame.BorderSizePixel = 0
        lineFrame.Rotation = 0
        lineFrame.Visible = false
        lineFrame.Parent = tracerGuiContainer
        tracers[player.Name] = { frame = lineFrame }
    end
end

local function removeESPFor(player)
    -- remove highlight/name
    if player.Character then
        if player.Character:FindFirstChild("PlayerESP") then
            pcall(function() player.Character.PlayerESP:Destroy() end)
        end
        if player.Character:FindFirstChild("NameTag") then
            pcall(function() player.Character.NameTag:Destroy() end)
        end
    end
    -- remove tracer
    if tracers[player.Name] then
        if tracers[player.Name].drawing then
            pcall(function() tracers[player.Name].drawing:Remove() end)
        end
        if tracers[player.Name].frame then
            pcall(function() tracers[player.Name].frame:Destroy() end)
        end
        tracers[player.Name] = nil
    end
end

-- ---------- add/remove ESP (called when enabling/disabling or player spawn) ----------
local function addESPFor(player)
    if player == LocalPlayer then return end
    if not player.Character then return end
    createHighlight(player)
    createNameTag(player)
    createTracerFor(player)
end

local function removeESPAll()
    for _, p in ipairs(Players:GetPlayers()) do
        removeESPFor(p)
    end
end

-- ---------- update tracer positions each frame ----------
RunService.RenderStepped:Connect(function()
    if not ESP_ENABLED then
        -- ensure tracers hidden
        for _, data in pairs(tracers) do
            if data.drawing then pcall(function() data.drawing.Visible = false end) end
            if data.frame then pcall(function() data.frame.Visible = false end) end
        end
        return
    end

    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local myHRP = LocalPlayer.Character.HumanoidRootPart
    local myPos = myHRP.Position
    local myScreenPos, myOnScreen = Camera:WorldToViewportPoint(myPos)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and tracers[player.Name] then
            local targetHRP = player.Character.HumanoidRootPart
            local targetPos = targetHRP.Position
            local screenPos, onScreen = Camera:WorldToViewportPoint(targetPos)

            if onScreen and myOnScreen then
                local from = Vector2.new(myScreenPos.X, myScreenPos.Y)
                local to = Vector2.new(screenPos.X, screenPos.Y)
                if tracers[player.Name].drawing then
                    local ok, err = pcall(function()
                        local line = tracers[player.Name].drawing
                        line.From = from
                        line.To = to
                        line.Visible = true
                    end)
                    if not ok then
                        -- if drawing failed, fallback: create GUI tracer and destroy drawing
                        pcall(function() tracers[player.Name].drawing:Remove() end)
                        tracers[player.Name].drawing = nil
                        createTracerFor(player)
                    end
                elseif tracers[player.Name].frame then
                    local frameLine = tracers[player.Name].frame
                    local dx = to.X - from.X
                    local dy = to.Y - from.Y
                    local length = math.sqrt((dx*dx) + (dy*dy))
                    -- midpoint
                    local midX = (from.X + to.X) * 0.5
                    local midY = (from.Y + to.Y) * 0.5
                    -- set size and position (pixel-based)
                    frameLine.Size = UDim2.new(0, math.max(2, length), 0, 3)
                    frameLine.Position = UDim2.new(0, midX, 0, midY)
                    frameLine.Rotation = math.deg(math.atan2(dy, dx))
                    frameLine.Visible = true
                end
            else
                if tracers[player.Name].drawing then
                    pcall(function() tracers[player.Name].drawing.Visible = false end)
                end
                if tracers[player.Name].frame then
                    pcall(function() tracers[player.Name].frame.Visible = false end)
                end
            end
        end
    end
end)

-- ---------- refresh / toggle logic ----------
local function refreshAllESP()
    -- create or remove ESP for each player according to ESP_ENABLED
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            if ESP_ENABLED then
                addESPFor(p)
            else
                removeESPFor(p)
            end
        end
    end
end

local function updateESPButtonVisual()
    if ESP_ENABLED then
        espButton.Text = "ESP: ON"
        espButton.BackgroundColor3 = Color3.fromRGB(0,170,0)
    else
        espButton.Text = "ESP: OFF"
        espButton.BackgroundColor3 = Color3.fromRGB(80,80,80)
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
end)

floatingButton.MouseButton1Click:Connect(function()
    frame.Visible = true
    floatingButton.Visible = false
end)

-- ---------- player events ----------
Players.PlayerAdded:Connect(function(player)
    if player == LocalPlayer then return end
    player.CharacterAdded:Connect(function()
        task.wait(0.9)
        if ESP_ENABLED then
            addESPFor(player)
        end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    removeESPFor(player)
end)

-- initial apply for existing players
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        if ESP_ENABLED and p.Character then
            addESPFor(p)
        else
            -- still prepare tracer object (so later enabling is instant)
            createTracerFor(p)
        end
        p.CharacterAdded:Connect(function()
            task.wait(0.9)
            if ESP_ENABLED then addESPFor(p) end
        end)
    end
end

-- ---------- draggable with save (menu & floating) ----------
local function makeDraggable(guiObject, dragHandle, saveKey)
    local dragging = false
    local dragStart = Vector2.new(0,0)
    local startPos = UDim2.new()

    -- restore pos if available
    local saved = screenGui:GetAttribute(saveKey)
    if saved and type(saved) == "userdata" then
        -- If stored UDim2, restore
        pcall(function() guiObject.Position = saved end)
    end

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = guiObject.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            local newPos = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
            guiObject.Position = newPos
            -- save position (UDim2 object)
            pcall(function() screenGui:SetAttribute(saveKey, newPos) end)
        end
    end)
end

makeDraggable(frame, frame, "MenuPos")
makeDraggable(floatingButton, floatingButton, "FloatPos")

-- restore visibility (if previously closed)
local wasClosed = screenGui:GetAttribute("MenuClosed")
if wasClosed == true then
    frame.Visible = false
    floatingButton.Visible = true
end

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

-- ---------- initialization ----------
-- play intro, then show menu (unless previously closed)
task.defer(function()
    playIntro()
    local closed = screenGui:GetAttribute("MenuClosed")
    if closed == true then
        frame.Visible = false
        floatingButton.Visible = true
    else
        frame.Visible = true
        floatingButton.Visible = false
    end
end)

-- apply saved ESP variable to UI
updateESPButtonVisual()
refreshAllESP()

-- done
print("[ESPMenu] Initialized. Drawing available:", drawingAvailable)