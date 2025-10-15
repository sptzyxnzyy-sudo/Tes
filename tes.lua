local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

-- GUI Utama
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KohlAdminGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 420, 0, 260)
frame.Position = UDim2.new(0, 10, 0, 80)
frame.BackgroundTransparency = 0.12
frame.BorderSizePixel = 0
frame.Name = "MainFrame"
frame.Parent = screenGui

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 28)
title.BackgroundTransparency = 1
title.Text = "Kohl's Admin — Test Toolkit (Private)"
title.TextScaled = true
title.Font = Enum.Font.SourceSansBold
title.TextColor3 = Color3.new(1,1,1)

-- UTIL
local ROOT_NAME = "Kohl's Admin Source"
local REMOTE_NAME = "VIPUGCMethod"
local COOLDOWN = 1
local attachedLogger = false
local lastCall = 0
local loggerConnection

local function safeFindRoot()
    local ok, root = pcall(function()
        return ReplicatedStorage:FindFirstChild(ROOT_NAME)
    end)
    return ok and root or nil
end

local function findRemote()
    local root = safeFindRoot()
    if not root then return nil end
    local remoteContainer = root:FindFirstChild("Remote") or root:FindFirstChildWhichIsA("Folder")
    if not remoteContainer then return nil end
    return remoteContainer:FindFirstChild(REMOTE_NAME) or remoteContainer:FindFirstChildWhichIsA("RemoteEvent")
end

-- Label & Input
local function makeLabel(text, y)
    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(0, 180, 0, 20)
    lbl.Position = UDim2.new(0, 8, 0, y)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.Font = Enum.Font.SourceSans
    lbl.TextSize = 14
    lbl.TextColor3 = Color3.new(1,1,1)
    return lbl
end

local function makeInput(y, placeholder)
    local box = Instance.new("TextBox", frame)
    box.Size = UDim2.new(0, 220, 0, 24)
    box.Position = UDim2.new(0, 190, 0, y)
    box.Text = placeholder or ""
    box.ClearTextOnFocus = false
    box.Font = Enum.Font.SourceSans
    box.TextSize = 14
    box.TextColor3 = Color3.new(0,0,0)
    return box
end

makeLabel("ID (number):", 36)
local idBox = makeInput(36, "92807314389236")
makeLabel("Asset URI:", 66)
local assetBox = makeInput(66, "rbxassetid://89119211625300")
makeLabel("Flag (true/false):", 96)
local flagBox = makeInput(96, "true")
makeLabel("Display name:", 126)
local nameBox = makeInput(126, "Gold Wings")

-- Buttons
local function makeButton(text, x, y, w)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0, w or 120, 0, 28)
    btn.Position = UDim2.new(0, x, 0, y)
    btn.Text = text
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    btn.AutoButtonColor = true
    return btn
end

local scanBtn = makeButton("Scan Remotes", 8, 160, 130)
local loggerBtn = makeButton("Attach Logger", 150, 160, 130)
local callBtn = makeButton("Call VIPUGCMethod", 292, 160, 120)
local statusLabel = makeLabel("Status: Idle", 200)

-- Functions
local function setStatus(txt)
    statusLabel.Text = "Status: " .. tostring(txt)
end

scanBtn.MouseButton1Click:Connect(function()
    setStatus("Scanning...")
    local root = safeFindRoot()
    if not root then
        setStatus(("Root '%s' not found"):format(ROOT_NAME))
        return
    end
    local found = {}
    for _, v in ipairs(root:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            table.insert(found, {name = v.Name, class = v.ClassName, path = v:GetFullName()})
        end
    end
    if #found == 0 then
        setStatus("No Remotes found under root.")
        return
    end
    setStatus(("Found %d remote(s). See console."):format(#found))
    print("==== Kohl's Admin Remote Scan Results ====")
    for i, r in ipairs(found) do
        print(("[%d] %s (%s) -> %s"):format(i, r.name, r.class, r.path))
    end
    print("=========================================")
end)

loggerBtn.MouseButton1Click:Connect(function()
    if attachedLogger then
        if loggerConnection then
            loggerConnection:Disconnect()
            loggerConnection = nil
        end
        attachedLogger = false
        setStatus("Logger detached")
        loggerBtn.Text = "Attach Logger"
        return
    end

    local remote = findRemote()
    if not remote or not remote:IsA("RemoteEvent") then
        setStatus("RemoteEvent not found!")
        return
    end

    loggerConnection = remote.OnClientEvent:Connect(function(...)
        local args = {...}
        print("---- VIPUGCMethod OnClientEvent fired ----")
        for i, a in ipairs(args) do
            print(("arg[%d] -> %s (type: %s)"):format(i, tostring(a), typeof(a)))
        end
        print("------------------------------------------")
        setStatus("Logger: last event printed to console")
    end)

    attachedLogger = true
    loggerBtn.Text = "Detach Logger"
    setStatus("Logger attached")
end)

callBtn.MouseButton1Click:Connect(function()
    local now = tick()
    if now - lastCall < COOLDOWN then
        setStatus(("Cooldown: wait %.2fs"):format(COOLDOWN - (now - lastCall)))
        return
    end

    local remote = findRemote()
    if not remote or not remote:IsA("RemoteEvent") then
        setStatus("RemoteEvent not found!")
        return
    end

    local idNum = tonumber(idBox.Text) or idBox.Text
    local assetUri = tostring(assetBox.Text or "")
    local flagVal = (tostring(flagBox.Text or "true"):lower() == "true")
    local displayName = tostring(nameBox.Text or "")
    local args = { idNum, assetUri, flagVal, displayName }

    local ok, err = pcall(function()
        remote:FireServer(unpack(args))
    end)
    if ok then
        setStatus("Call sent (check server / console).")
    else
        setStatus("Error calling remote: " .. tostring(err))
    end

    lastCall = now
end)

-- Shortcut toggle GUI
local uis = game:GetService("UserInputService")
local visible = true
uis.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        visible = not visible
        screenGui.Enabled = visible
        setStatus(visible and "Visible" or "Hidden")
    end
end)

setStatus("Ready")
print("[KohlAdminTool] Ready.")