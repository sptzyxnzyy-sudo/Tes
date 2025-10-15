-- Executor-friendly toolkit for testing "Kohl's Admin Source" (safe, non-exploit)
-- Paste this into your executor console or run as LocalScript in a private place.
-- Author: Assistant (for your private testing)
-- WARNING: Use only in places you own. Do NOT use to exploit public games.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

-- CONFIG
local ROOT_NAME = "Kohl's Admin Source"
local REMOTE_NAME = "VIPUGCMethod"
local COOLDOWN = 1 -- seconds between manual FireServer calls (safety)

-- UTIL
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

-- SIMPLE UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KohlsAdminTool"
screenGui.ResetOnSpawn = false

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 420, 0, 260)
frame.Position = UDim2.new(0, 10, 0, 80)
frame.BackgroundTransparency = 0.12
frame.BorderSizePixel = 0
frame.Name = "MainFrame"

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 28)
title.BackgroundTransparency = 1
title.Text = "Kohl's Admin — Test Toolkit (Private)"
title.TextScaled = true
title.Font = Enum.Font.SourceSansBold
title.TextColor3 = Color3.new(1,1,1)

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

-- Inputs and labels
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

-- Parent UI
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- FUNCTIONALITY
local attachedLogger = false
local lastCall = 0

local function setStatus(txt)
    statusLabel.Text = "Status: " .. tostring(txt)
end

-- 1) Scan Remotes in ReplicatedStorage -> ROOT_NAME
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

-- 2) Attach/Detach passive logger for VIPUGCMethod's OnClientEvent
local loggerConnection
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
    if not remote then
        setStatus(("Remote '%s' not found"):format(REMOTE_NAME))
        return
    end

    if not remote:IsA("RemoteEvent") then
        setStatus(("'%s' is not a RemoteEvent."):format(remote.Name))
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

-- 3) Manual call wrapper with safety cooldown
callBtn.MouseButton1Click:Connect(function()
    local now = tick()
    if now - lastCall < COOLDOWN then
        setStatus(("Cooldown: wait %.2fs"):format(COOLDOWN - (now - lastCall)))
        return
    end

    local remote = findRemote()
    if not remote then
        setStatus(("Remote '%s' not found"):format(REMOTE_NAME))
        return
    end
    if not remote:IsA("RemoteEvent") then
        setStatus(("'%s' is not a RemoteEvent."):format(remote.Name))
        return
    end

    -- parse inputs safely
    local idText = idBox.Text or ""
    local idNum = tonumber(idText) or idText -- keep as number if possible
    local assetUri = tostring(assetBox.Text or "")
    local flagText = tostring(flagBox.Text or "true"):lower()
    local flagVal = (flagText == "true" or flagText == "1")
    local displayName = tostring(nameBox.Text or "")

    local args = { idNum, assetUri, flagVal, displayName }

    -- log call to console
    print(">>> Calling VIPUGCMethod with args:")
    for i, v in ipairs(args) do
        print(("  [%d] %s (type: %s)"):format(i, tostring(v), typeof(v)))
    end

    -- confirmation UI (simple)
    local confirmed = true -- executed immediately for convenience; change if you want explicit confirmation step

    if confirmed then
        local ok, err = pcall(function()
            remote:FireServer(unpack(args))
        end)
        if ok then
            setStatus("Call sent (check server response / console).")
        else
            setStatus("Error calling remote: " .. tostring(err))
            warn("Error while firing remote:", err)
        end
    else
        setStatus("Call cancelled")
    end

    lastCall = now
end)

-- Nice-to-have shortcut: press RightControl to toggle GUI visibility
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
print("[KohlsAdminTool] Ready. Use the GUI to scan, attach logger, or call VIPUGCMethod.")