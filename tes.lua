-- NHX: Client+Server FE Script with Backdoor (Undetected)
-- Features: Client-side fly, noclip, etc.; Server-side backdoor (ReplicatedStorage.Execute); Scanner

local a = game:GetService("Players")
local b = game:GetService("TweenService")
local c = game:GetService("RunService")
local d = game:GetService("ReplicatedStorage")
local e = game:GetService("UserInputService")
local f = a.LocalPlayer

-- Obfuscated Debugging
local function g(h) print("[NHX] " .. h) end
g("Init client+server backdoor script...")

-- Backdoor Setup (Replace 'Execute' with actual RemoteEvent name)
local backdoor = d:FindFirstChild("Execute") -- Must match your game's backdoor RemoteEvent
g("Checking backdoor: " .. (backdoor and backdoor.Name or "Not found"))

-- GUI Setup
local i = Instance.new("ScreenGui")
i.Name = "NHXGui"
i.ResetOnSpawn = false
i.IgnoreGuiInset = true
i.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
i.Enabled = true
i.Parent = f:WaitForChild("PlayerGui", 5)
if not i.Parent then
    warn("[NHX] PlayerGui not found!")
    return
end
g("ScreenGui created")

-- Main Frame
local j = Instance.new("Frame")
j.Name = "MF"
j.Size = UDim2.new(0, 500, 0, 400)
j.Position = UDim2.new(0.5, -250, 0.5, -200)
j.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
j.BackgroundTransparency = 0.1
j.BorderSizePixel = 0
j.ZIndex = 15
j.Parent = i
g("MainFrame created")

local k = Instance.new("UICorner")
k.CornerRadius = UDim.new(0, 12)
k.Parent = j

local l = Instance.new("UIStroke")
l.Color = Color3.fromRGB(0, 255, 255)
l.Thickness = 2
l.Transparency = 0.3
l.Parent = j

-- Title Bar
local m = Instance.new("Frame")
m.Name = "TB"
m.Size = UDim2.new(1, 0, 0, 40)
m.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
m.BackgroundTransparency = 0.2
m.BorderSizePixel = 0
m.ZIndex = 16
m.Parent = j

local n = Instance.new("UICorner")
n.CornerRadius = UDim.new(0, 12)
n.Parent = m

local o = Instance.new("TextLabel")
o.Size = UDim2.new(1, -80, 1, 0)
o.Position = UDim2.new(0, 10, 0, 0)
o.BackgroundTransparency = 1
o.Text = "NyxoyHubX"
o.TextColor3 = Color3.fromRGB(0, 255, 255)
o.TextSize = 20
o.Font = Enum.Font.GothamBold
o.TextXAlignment = Enum.TextXAlignment.Left
o.ZIndex = 17
o.Parent = m

-- Minimize Button
local p = Instance.new("TextButton")
p.Name = "MB"
p.Size = UDim2.new(0, 40, 0, 40)
p.Position = UDim2.new(1, -50, 0, 0)
p.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
p.BackgroundTransparency = 0.2
p.Text = "-"
p.TextColor3 = Color3.fromRGB(255, 255, 255)
p.TextSize = 20
p.Font = Enum.Font.GothamBold
p.ZIndex = 17
p.Parent = m

local q = Instance.new("UICorner")
q.CornerRadius = UDim.new(0, 12)
q.Parent = p

-- Content Frame
local r = Instance.new("Frame")
r.Name = "CF"
r.Size = UDim2.new(1, -10, 1, -90)
r.Position = UDim2.new(0, 5, 0, 45)
r.BackgroundTransparency = 1
r.ZIndex = 15
r.Parent = j
g("ContentFrame created")

-- Log Area
local s = Instance.new("ScrollingFrame")
s.Name = "LF"
s.Size = UDim2.new(1, 0, 0.55, 0)
s.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
s.BackgroundTransparency = 0.3
s.BorderSizePixel = 0
s.ScrollBarThickness = 6
s.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 255)
s.ZIndex = 16
s.Parent = r

local t = Instance.new("UICorner")
t.CornerRadius = UDim.new(0, 8)
t.Parent = s

local u = Instance.new("UIListLayout")
u.SortOrder = Enum.SortOrder.LayoutOrder
u.Padding = UDim.new(0, 4)
u.Parent = s

-- Command Bar
local v = Instance.new("TextBox")
v.Name = "CB"
v.Size = UDim2.new(1, -10, 0, 40)
v.Position = UDim2.new(0, 5, 0.55, 10)
v.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
v.BackgroundTransparency = 0.2
v.Text = ""
v.PlaceholderText = "Enter command..."
v.TextColor3 = Color3.fromRGB(255, 255, 255)
v.TextSize = 16
v.Font = Enum.Font.Gotham
v.ZIndex = 16
v.Parent = r
g("CommandBar created")

local w = Instance.new("UICorner")
w.CornerRadius = UDim.new(0, 8)
w.Parent = v

local x = Instance.new("UIStroke")
x.Color = Color3.fromRGB(0, 255, 255)
x.Thickness = 1
x.Transparency = 0.5
x.Parent = v

-- Buttons Frame
local y = Instance.new("Frame")
y.Name = "BF"
y.Size = UDim2.new(1, -10, 0, 100)
y.Position = UDim2.new(0, 5, 0.55, 60)
y.BackgroundTransparency = 1
y.ZIndex = 16
y.Parent = r

local z = Instance.new("UIGridLayout")
z.CellSize = UDim2.new(0, 140, 0, 35)
z.CellPadding = UDim2.new(0, 10, 0, 10)
z.HorizontalAlignment = Enum.HorizontalAlignment.Center
z.Parent = y

-- Buttons
local aa = Instance.new("TextButton")
aa.Name = "SB"
aa.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
aa.Text = "Scan Backdoors"
aa.TextColor3 = Color3.fromRGB(255, 255, 255)
aa.TextSize = 14
aa.Font = Enum.Font.GothamBold
aa.ZIndex = 17
aa.Parent = y

local ab = Instance.new("UICorner")
ab.CornerRadius = UDim.new(0, 8)
ab.Parent = aa

local ac = Instance.new("TextButton")
ac.Name = "HDB"
ac.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
ac.Text = "Remove HD Admin"
ac.TextColor3 = Color3.fromRGB(255, 255, 255)
ac.TextSize = 14
ac.Font = Enum.Font.GothamBold
ac.ZIndex = 17
ac.Parent = y

local ad = Instance.new("UICorner")
ad.CornerRadius = UDim.new(0, 8)
ad.Parent = ac

local ae = Instance.new("TextButton")
ae.Name = "RB"
ae.BackgroundColor3 = Color3.fromRGB(0, 0, 200)
ae.Text = "Disable Remotes"
ae.TextColor3 = Color3.fromRGB(255, 255, 255)
ae.TextSize = 14
ae.Font = Enum.Font.GothamBold
ae.ZIndex = 17
ae.Parent = y

local af = Instance.new("UICorner")
af.CornerRadius = UDim.new(0, 8)
af.Parent = ae

local ag = Instance.new("TextButton")
ag.Name = "FB"
ag.BackgroundColor3 = Color3.fromRGB(0, 200, 200)
ag.Text = "Toggle Fly"
ag.TextColor3 = Color3.fromRGB(255, 255, 255)
ag.TextSize = 14
ag.Font = Enum.Font.GothamBold
ag.ZIndex = 17
ag.Parent = y

local ah = Instance.new("UICorner")
ah.CornerRadius = UDim.new(0, 8)
ah.Parent = ag

-- State Management
local ai = {
    aj = false, -- isMinimized
    ak = nil, -- remoteMonitorConnection
    al = {}, -- flyConnections
    am = false, -- isNoclip
    an = nil, -- noclipConnection
    ao = false, -- isJumpBoosted
    ap = 50, -- originalJumpPower
    aq = 16, -- originalWalkSpeed
    ar = false, -- isInvisible
    as = false -- isGodmode
}

-- Utility Functions
local function at(au, av, aw)
    v.PlaceholderText = au
    v.TextColor3 = aw or Color3.fromRGB(255, 255, 255)
    task.spawn(function()
        task.wait(math.random(15, 25) / 10) -- Random delay for anti-detection
        if v.PlaceholderText == au then
            v.PlaceholderText = "Enter command..."
            v.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
    end)
    g("FB: " .. au)
end

local function ax(ay, az)
    local ba = Instance.new("TextLabel")
    ba.Size = UDim2.new(1, -10, 0, 20)
    ba.BackgroundTransparency = 1
    ba.Text = "[" .. os.date("%H:%M:%S") .. "] " .. ay
    ba.TextColor3 = az or Color3.fromRGB(255, 255, 255)
    ba.TextSize = 12
    ba.Font = Enum.Font.Gotham
    ba.TextXAlignment = Enum.TextXAlignment.Left
    ba.TextWrapped = true
    ba.LayoutOrder = #s:GetChildren()
    ba.ZIndex = 17
    ba.Parent = s
    s.CanvasSize = UDim2.new(0, 0, 0, u.AbsoluteContentSize.Y)
    g("Log: " .. ay)
end

local function bb(bc)
    local bd = bc.Character
    local be = bd and bd:FindFirstChildOfClass("Humanoid")
    local bf = bd and bd:FindFirstChild("HumanoidRootPart")
    return bd, be, bf
end

-- Client-Side Fly
local function bg(bh)
    local bd, be, bf = bb(bh)
    if not bd or not be or not bf then
        at("Error: No char for " .. bh.Name, 2, Color3.fromRGB(255, 0, 0))
        ax("Failed fly for " .. bh.Name .. ": No char", Color3.fromRGB(255, 0, 0))
        return
    end

    if ai.al[bh] then
        bi(bh)
    end

    ai.al[bh] = { bj = nil, bk = nil, bl = nil }
    be.PlatformStand = true

    local bm = Instance.new("BodyVelocity")
    bm.Name = "FV"
    bm.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bm.Parent = bf
    ai.al[bh].bk = bm

    local bn = Instance.new("BodyGyro")
    bn.Name = "FG"
    bn.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bn.P = 10000
    bn.D = 1000
    bn.Parent = bf
    ai.al[bh].bl = bn

    local bo = 50 -- Realistic speed for anti-detection
    ai.al[bh].bj = c.Heartbeat:Connect(function()
        if not bf.Parent or not be.Parent then
            bi(bh)
            return
        end

        local bp = workspace.CurrentCamera
        local bq = bp.CFrame.LookVector
        local br = bp.CFrame.RightVector
        local bs = Vector3.new(0, 0, 0)
        local bt = bo

        if e:IsKeyDown(Enum.KeyCode.LeftShift) then
            bt = math.min(bo * 1.5, 75)
        elseif e:IsKeyDown(Enum.KeyCode.LeftControl) then
            bt = math.max(bo * 0.5, 25)
        end

        if e:IsKeyDown(Enum.KeyCode.W) then
            bs = bs + bq
        end
        if e:IsKeyDown(Enum.KeyCode.S) then
            bs = bs - bq
        end
        if e:IsKeyDown(Enum.KeyCode.A) then
            bs = bs - br
        end
        if e:IsKeyDown(Enum.KeyCode.D) then
            bs = bs + br
        end
        if e:IsKeyDown(Enum.KeyCode.Space) then
            bs = bs + Vector3.new(0, 1, 0)
        end
        if e:IsKeyDown(Enum.KeyCode.LeftControl) then
            bs = bs - Vector3.new(0, 1, 0)
        end

        if bs.Magnitude > 0 then
            bs = bs.Unit * bt
        end
        bm.Velocity = bs
        bn.CFrame = CFrame.new(Vector3.new(0, 0, 0), Vector3.new(bq.X, 0, bq.Z))
    end)

    be.Died:Connect(function()
        bi(bh)
    end)

    at("Fly on for " .. bh.Name .. " (client)", 2, Color3.fromRGB(0, 255, 0))
    ax("Fly on for " .. bh.Name .. " (client)", Color3.fromRGB(0, 255, 0))
end

local function bi(bh)
    local bd, be, bf = bb(bh)
    if ai.al[bh] then
        if ai.al[bh].bj then
            ai.al[bh].bj:Disconnect()
        end
        if bf then
            if bf:FindFirstChild("FV") then
                bf.FV:Destroy()
            end
            if bf:FindFirstChild("FG") then
                bf.FG:Destroy()
            end
        end
        if be then
            be.PlatformStand = false
        end
        ai.al[bh] = nil
        at("Fly off for " .. bh.Name .. " (client)", 2, Color3.fromRGB(0, 255, 0))
        ax("Fly off for " .. bh.Name .. " (client)", Color3.fromRGB(0, 255, 0))
    end
end

local function bu()
    for _, bh in pairs(a:GetPlayers()) do
        bg(bh)
    end
    at("Fly on for all (client)", 2, Color3.fromRGB(0, 255, 0))
    ax("Fly on for all (client)", Color3.fromRGB(0, 255, 0))
end

local function bv()
    for _, bh in pairs(a:GetPlayers()) do
        bi(bh)
    end
    at("Fly off for all (client)", 2, Color3.fromRGB(0, 255, 0))
    ax("Fly off for all (client)", Color3.fromRGB(0, 255, 0))
end

-- Server-Side Fly (Backdoor)
local function bw(bh)
    if not backdoor then
        at("Error: No backdoor!", 2, Color3.fromRGB(255, 0, 0))
        ax("No backdoor for serverfly", Color3.fromRGB(255, 0, 0))
        bg(bh) -- Fallback to client-side
        return
    end
    pcall(function()
        backdoor:FireServer("fly", bh.Name, {speed = 50})
        at("Server fly sent for " .. bh.Name, 2, Color3.fromRGB(0, 255, 0))
        ax("Server fly sent for " .. bh.Name, Color3.fromRGB(0, 255, 0))
    end)
end

local function bx(bh)
    if not backdoor then
        at("Error: No backdoor!", 2, Color3.fromRGB(255, 0, 0))
        ax("No backdoor for serverunfly", Color3.fromRGB(255, 0, 0))
        bi(bh) -- Fallback to client-side
        return
    end
    pcall(function()
        backdoor:FireServer("unfly", bh.Name)
        at("Server unfly sent for " .. bh.Name, 2, Color3.fromRGB(0, 255, 0))
        ax("Server unfly sent for " .. bh.Name, Color3.fromRGB(0, 255, 0))
    end)
end

-- Noclip
local function by()
    local bd = bb(f)
    if not bd then
        at("Error: No char!", 2, Color3.fromRGB(255, 0, 0))
        ax("Failed noclip: No char", Color3.fromRGB(255, 0, 0))
        return
    end

    if ai.am then
        bz()
    end

    ai.am = true
    ai.an = c.Stepped:Connect(function()
        if not bd.Parent or not ai.am then
            bz()
            return
        end
        for _, part in pairs(bd:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)

    at("Noclip on (client)", 2, Color3.fromRGB(0, 255, 0))
    ax("Noclip on (client)", Color3.fromRGB(0, 255, 0))
end

local function bz()
    local bd = bb(f)
    if ai.am then
        ai.am = false
        if ai.an then
            ai.an:Disconnect()
            ai.an = nil
        end
        if bd then
            for _, part in pairs(bd:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
        at("Noclip off (client)", 2, Color3.fromRGB(0, 255, 0))
        ax("Noclip off (client)", Color3.fromRGB(0, 255, 0))
    end
end

-- Jump Boost
local function ca(cb)
    local bd, be = bb(f)
    if not be then
        at("Error: No char!", 2, Color3.fromRGB(255, 0, 0))
        ax("Failed jumpboost: No char", Color3.fromRGB(255, 0, 0))
        return
    end

    if ai.ao then
        cc()
    end

    ai.ao = true
    ai.ap = be.JumpPower
    be.JumpPower = math.min(ai.ap * cb, 100) -- Realistic limit
    be.Died:Connect(function()
        cc()
    end)
    at("Jump boost on: " .. cb .. "x (client)", 2, Color3.fromRGB(0, 255, 0))
    ax("Jump boost on: " .. cb .. "x (client)", Color3.fromRGB(0, 255, 0))
end

local function cc()
    local bd, be = bb(f)
    if ai.ao then
        ai.ao = false
        if be then
            be.JumpPower = ai.ap
        end
        at("Jump boost off (client)", 2, Color3.fromRGB(0, 255, 0))
        ax("Jump boost off (client)", Color3.fromRGB(0, 255, 0))
    end
end

-- Speed Boost
local function cd(ce)
    local bd, be = bb(f)
    if not be then
        at("Error: No char!", 2, Color3.fromRGB(255, 0, 0))
        ax("Failed speedboost: No char", Color3.fromRGB(255, 0, 0))
        return
    end

    ai.aq = be.WalkSpeed
    be.WalkSpeed = math.min(ai.aq * ce, 50) -- Realistic limit
    at("Speed boost on: " .. ce .. "x (client)", 2, Color3.fromRGB(0, 255, 0))
    ax("Speed boost on: " .. ce .. "x (client)", Color3.fromRGB(0, 255, 0))
end

local function cf()
    local bd, be = bb(f)
    if be then
        be.WalkSpeed = ai.aq
        at("Speed boost off (client)", 2, Color3.fromRGB(0, 255, 0))
        ax("Speed boost off (client)", Color3.fromRGB(0, 255, 0))
    end
end

-- Teleport
local function cg(ch, ci, cj)
    local bd, _, bf = bb(f)
    if not bf then
        at("Error: No char!", 2, Color3.fromRGB(255, 0, 0))
        ax("Failed teleport: No char", Color3.fromRGB(255, 0, 0))
        return
    end

    bf.CFrame = CFrame.new(Vector3.new(ch, ci, cj))
    at("Teleported to: " .. ch .. ", " .. ci .. ", " .. cj .. " (client)", 2, Color3.fromRGB(0, 255, 0))
    ax("Teleported to: " .. ch .. ", " .. ci .. ", " .. cj .. " (client)", Color3.fromRGB(0, 255, 0))
end

local function ck(bh, ch, ci, cj)
    if not backdoor then
        at("Error: No backdoor!", 2, Color3.fromRGB(255, 0, 0))
        ax("No backdoor for serverteleport", Color3.fromRGB(255, 0, 0))
        if bh == f then
            cg(ch, ci, cj) -- Fallback to client-side
        end
        return
    end
    pcall(function()
        backdoor:FireServer("teleport", bh.Name, {x = ch, y = ci, z = cj})
        at("Server teleport sent for " .. bh.Name, 2, Color3.fromRGB(0, 255, 0))
        ax("Server teleport sent for " .. bh.Name, Color3.fromRGB(0, 255, 0))
    end)
end

-- Invisible
local function cl()
    local bd = bb(f)
    if not bd then
        at("Error: No char!", 2, Color3.fromRGB(255, 0, 0))
        ax("Failed invisible: No char", Color3.fromRGB(255, 0, 0))
        return
    end

    if ai.ar then
        cm()
    end

    ai.ar = true
    for _, part in pairs(bd:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("MeshPart") then
            part.Transparency = 1
        elseif part:IsA("Decal") then
            part.Transparency = 1
        end
    end
    at("Invisible on (client)", 2, Color3.fromRGB(0, 255, 0))
    ax("Invisible on (client)", Color3.fromRGB(0, 255, 0))
end

local function cm()
    local bd = bb(f)
    if ai.ar then
        ai.ar = false
        if bd then
            for _, part in pairs(bd:GetDescendants()) do
                if part:IsA("BasePart") or part:IsA("MeshPart") then
                    part.Transparency = 0
                elseif part:IsA("Decal") then
                    part.Transparency = 0
                end
            end
        end
        at("Invisible off (client)", 2, Color3.fromRGB(0, 255, 0))
        ax("Invisible off (client)", Color3.fromRGB(0, 255, 0))
    end
end

-- Godmode
local function cn()
    local bd, be = bb(f)
    if not be then
        at("Error: No char!", 2, Color3.fromRGB(255, 0, 0))
        ax("Failed godmode: No char", Color3.fromRGB(255, 0, 0))
        return
    end

    if ai.as then
        co()
    end

    ai.as = true
    be.MaxHealth = 10000 -- Realistic for anti-detection
    be.Health = 10000
    be.Died:Connect(function()
        task.wait(0.1)
        if ai.as then
            cn()
        end
    end)
    at("Godmode on (client)", 2, Color3.fromRGB(0, 255, 0))
    ax("Godmode on (client)", Color3.fromRGB(0, 255, 0))
end

local function co()
    local bd, be = bb(f)
    if ai.as then
        ai.as = false
        if be then
            be.MaxHealth = 100
            be.Health = 100
        end
        at("Godmode off (client)", 2, Color3.fromRGB(0, 255, 0))
        ax("Godmode off (client)", Color3.fromRGB(0, 255, 0))
    end
end

local function cp(bh)
    if not backdoor then
        at("Error: No backdoor!", 2, Color3.fromRGB(255, 0, 0))
        ax("No backdoor for servergodmode", Color3.fromRGB(255, 0, 0))
        if bh == f then
            cn() -- Fallback to client-side
        end
        return
    end
    pcall(function()
        backdoor:FireServer("godmode", bh.Name)
        at("Server godmode sent for " .. bh.Name, 2, Color3.fromRGB(0, 255, 0))
        ax("Server godmode sent for " .. bh.Name, Color3.fromRGB(0, 255, 0))
    end)
end

-- Server-Side Kill (Backdoor)
local function cq(bh)
    if not backdoor then
        at("Error: No backdoor!", 2, Color3.fromRGB(255, 0, 0))
        ax("No backdoor for serverkill", Color3.fromRGB(255, 0, 0))
        local bd, be = bb(bh)
        if be then
            be.Health = 0
            at("Killed " .. bh.Name .. " (client)", 2, Color3.fromRGB(0, 255, 0))
            ax("Killed " .. bh.Name .. " (client)", Color3.fromRGB(0, 255, 0))
        end
        return
    end
    pcall(function()
        backdoor:FireServer("kill", bh.Name)
        at("Server kill sent for " .. bh.Name, 2, Color3.fromRGB(0, 255, 0))
        ax("Server kill sent for " .. bh.Name, Color3.fromRGB(0, 255, 0))
    end)
end

-- Scanner
local cr = {
    "require%(%d+%)", "loadstring%(", "game:HttpGet", "syn%.request", "http%.request",
    "getfenv", "setfenv", "HDAdmin", "Backdoor", "Exploit"
}

local function cs()
    ax("Starting scan...", Color3.fromRGB(0, 255, 0))
    at("Scanning...", 2, Color3.fromRGB(0, 255, 0))
    local ct = 0

    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
            local success, source = pcall(function() return obj.Source end)
            if success and source then
                for _, pattern in pairs(cr) do
                    if source:lower():find(pattern:lower()) then
                        ax("Found: " .. obj:GetFullName(), Color3.fromRGB(255, 0, 0))
                        pcall(function() obj:Destroy() end)
                        ct = ct + 1
                        break
                    end
                end
            end
        end
    end

    at("Scan done. Removed: " .. ct .. " (client)", 3, Color3.fromRGB(0, 255, 0))
    ax("Scan done. Removed: " .. ct .. " (client)", Color3.fromRGB(0, 255, 0))
end

local function cu()
    ax("Removing HD Admin...", Color3.fromRGB(255, 100, 100))
    at("Removing HD Admin...", 2, Color3.fromRGB(255, 100, 100))
    local ct = 0

    for _, obj in pairs(game:GetDescendants()) do
        if obj.Name:lower():find("hdadmin") or obj.Name:lower():find("main") then
            if obj:IsA("LocalScript") or obj:IsA("ModuleScript") or obj:IsA("Folder") then
                ax("Removed: " .. obj:GetFullName(), Color3.fromRGB(255, 0, 0))
                pcall(function() obj:Destroy() end)
                ct = ct + 1
            end
        end
    end

    if d:FindFirstChild("HDAdmin") then
        pcall(function()
            d.HDAdmin:Destroy()
            ax("Removed HDAdmin folder (client)", Color3.fromRGB(255, 0, 0))
            ct = ct + 1
        end)
    end

    at("HD Admin done. Removed: " .. ct .. " (client)", 3, Color3.fromRGB(0, 255, 0))
    ax("HD Admin done. Removed: " .. ct .. " (client)", Color3.fromRGB(0, 255, 0))
end

local function cv()
    ax("Disabling remotes...", Color3.fromRGB(0, 100, 255))
    at("Disabling remotes...", 2, Color3.fromRGB(0, 100, 255))
    local ct = 0

    for _, obj in pairs(d:GetChildren()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            if obj.Name:lower():find("backdoor") or obj.Name:lower():find("exploit") or obj.Name:lower():find("hdadmin") then
                ax("Removed: " .. obj:GetFullName(), Color3.fromRGB(255, 0, 0))
                pcall(function() obj:Destroy() end)
                ct = ct + 1
            else
                pcall(function()
                    obj.Parent = nil
                    task.wait(math.random(5, 10) / 100)
                    obj:Destroy()
                    ax("Disabled: " .. obj:GetFullName(), Color3.fromRGB(255, 165, 0))
                    ct = ct + 1
                end)
            end
        end
    end

    if ai.ak then
        ai.ak:Disconnect()
    end
    ai.ak = d.ChildAdded:Connect(function(child)
        if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
            ax("New remote: " .. child:GetFullName() .. ". Removing (client)...", Color3.fromRGB(255, 165, 0))
            pcall(function() child:Destroy() end)
            ct = ct + 1
        end
    end)

    at("Remotes done. Handled: " .. ct .. " (client)", 3, Color3.fromRGB(0, 255, 0))
    ax("Remotes done. Handled: " .. ct .. " (client)", Color3.fromRGB(0, 255, 0))
end

-- Commands
local cw = {
    fly = {
        func = function(cx)
            if cx[1] == "all" then
                bu()
            elseif cx[1] then
                local cy = nil
                for _, p in pairs(a:GetPlayers()) do
                    if p.Name:lower():find(cx[1]:lower()) then
                        cy = p
                        break
                    end
                end
                if cy then
                    bg(cy)
                else
                    at("Error: Player " .. cx[1] .. " not found!", 2, Color3.fromRGB(255, 0, 0))
                    ax("Player " .. cx[1] .. " not found for fly", Color3.fromRGB(255, 0, 0))
                end
            else
                bg(f)
            end
        end,
        desc = "Fly for self, 'all', or player (e.g., fly all, fly playername, client)"
    },
    unfly = {
        func = function(cx)
            if cx[1] == "all" then
                bv()
            elseif cx[1] then
                local cy = nil
                for _, p in pairs(a:GetPlayers()) do
                    if p.Name:lower():find(cx[1]:lower()) then
                        cy = p
                        break
                    end
                end
                if cy then
                    bi(cy)
                else
                    at("Error: Player " .. cx[1] .. " not found!", 2, Color3.fromRGB(255, 0, 0))
                    ax("Player " .. cx[1] .. " not found for unfly", Color3.fromRGB(255, 0, 0))
                end
            else
                bi(f)
            end
        end,
        desc = "Unfly for self, 'all', or player (e.g., unfly all, unfly playername, client)"
    },
    serverfly = {
        func = function(cx)
            if cx[1] == "all" then
                for _, p in pairs(a:GetPlayers()) do
                    bw(p)
                end
            elseif cx[1] then
                local cy = nil
                for _, p in pairs(a:GetPlayers()) do
                    if p.Name:lower():find(cx[1]:lower()) then
                        cy = p
                        break
                    end
                end
                if cy then
                    bw(cy)
                else
                    at("Error: Player " .. cx[1] .. " not found!", 2, Color3.fromRGB(255, 0, 0))
                    ax("Player " .. cx[1] .. " not found for serverfly", Color3.fromRGB(255, 0, 0))
                end
            else
                bw(f)
            end
        end,
        desc = "Server-side fly via backdoor (e.g., serverfly all, serverfly playername)"
    },
    serverunfly = {
        func = function(cx)
            if cx[1] == "all" then
                for _, p in pairs(a:GetPlayers()) do
                    bx(p)
                end
            elseif cx[1] then
                local cy = nil
                for _, p in pairs(a:GetPlayers()) do
                    if p.Name:lower():find(cx[1]:lower()) then
                        cy = p
                        break
                    end
                end
                if cy then
                    bx(cy)
                else
                    at("Error: Player " .. cx[1] .. " not found!", 2, Color3.fromRGB(255, 0, 0))
                    ax("Player " .. cx[1] .. " not found for serverunfly", Color3.fromRGB(255, 0, 0))
                end
            else
                bx(f)
            end
        end,
        desc = "Server-side unfly via backdoor (e.g., serverunfly all, serverunfly playername)"
    },
    noclip = {
        func = by,
        desc = "Noclip (move through walls, client)"
    },
    unnoclip = {
        func = bz,
        desc = "Disable noclip (client)"
    },
    jumpboost = {
        func = function(cx)
            local cb = tonumber(cx[1]) or 2
            ca(cb)
        end,
        desc = "Jump boost (e.g., jumpboost 2 for 2x, client)"
    },
    unjumpboost = {
        func = cc,
        desc = "Disable jump boost (client)"
    },
    speedboost = {
        func = function(cx)
            local ce = tonumber(cx[1]) or 2
            cd(ce)
        end,
        desc = "Speed boost (e.g., speedboost 2 for 2x, client)"
    },
    unspeedboost = {
        func = cf,
        desc = "Disable speed boost (client)"
    },
    teleport = {
        func = function(cx)
            local ch = tonumber(cx[1]) or 0
            local ci = tonumber(cx[2]) or 0
            local cj = tonumber(cx[3]) or 0
            cg(ch, ci, cj)
        end,
        desc = "Teleport to coords (e.g., teleport 100 50 100, client)"
    },
    serverteleport = {
        func = function(cx)
            local cy = cx[1] and a:FindFirstChild(cx[1]) or f
            local ch = tonumber(cx[2]) or 0
            local ci = tonumber(cx[3]) or 0
            local cj = tonumber(cx[4]) or 0
            if not cy then
                at("Error: Player " .. cx[1] .. " not found!", 2, Color3.fromRGB(255, 0, 0))
                ax("Player " .. cx[1] .. " not found for serverteleport", Color3.fromRGB(255, 0, 0))
                return
            end
            ck(cy, ch, ci, cj)
        end,
        desc = "Server-side teleport (e.g., serverteleport playername 100 50 100)"
    },
    invisible = {
        func = cl,
        desc = "Invisible (client)"
    },
    uninvisible = {
        func = cm,
        desc = "Disable invisible (client)"
    },
    godmode = {
        func = cn,
        desc = "Godmode (client)"
    },
    ungodmode = {
        func = co,
        desc = "Disable godmode (client)"
    },
    servergodmode = {
        func = function(cx)
            local cy = cx[1] and a:FindFirstChild(cx[1]) or f
            if not cy then
                at("Error: Player " .. cx[1] .. " not found!", 2, Color3.fromRGB(255, 0, 0))
                ax("Player " .. cx[1] .. " not found for servergodmode", Color3.fromRGB(255, 0, 0))
                return
            end
            cp(cy)
        end,
        desc = "Server-side godmode (e.g., servergodmode playername)"
    },
    serverkill = {
        func = function(cx)
            local cy = cx[1] and a:FindFirstChild(cx[1]) or f
            if not cy then
                at("Error: Player " .. cx[1] .. " not found!", 2, Color3.fromRGB(255, 0, 0))
                ax("Player " .. cx[1] .. " not found for serverkill", Color3.fromRGB(255, 0, 0))
                return
            end
            cq(cy)
        end,
        desc = "Server-side kill (e.g., serverkill playername)"
    },
    scan = {
        func = cs,
        desc = "Scan for backdoors (client)"
    },
    hdremove = {
        func = cu,
        desc = "Remove HD Admin (client)"
    },
    disableremotes = {
        func = cv,
        desc = "Disable remotes (client)"
    },
    clearlogs = {
        func = function()
            for _, child in pairs(s:GetChildren()) do
                if child:IsA("TextLabel") then child:Destroy() end
            end
            s.CanvasSize = UDim2.new(0, 0, 0, 0)
            at("Logs cleared!", 2, Color3.fromRGB(0, 255, 0))
            ax("Logs cleared.", Color3.fromRGB(0, 255, 0))
        end,
        desc = "Clear logs"
    },
    autoscan = {
        func = function(cx)
            local cz = tonumber(cx[1]) or 30
            task.spawn(function()
                while task.wait(cz) do
                    cs()
                end
            end)
            at("Auto-scan started (" .. cz .. "s, client)", 3, Color3.fromRGB(0, 255, 0))
            ax("Auto-scan started (" .. cz .. "s, client)", Color3.fromRGB(0, 255, 0))
        end,
        desc = "Periodic scan (e.g., autoscan 30, client)"
    },
    respawn = {
        func = function()
            local bd, be = bb(f)
            if be then
                be.Health = 0
                at("Respawn triggered (client)", 2, Color3.fromRGB(0, 255, 0))
                ax("Respawn triggered (client)", Color3.fromRGB(0, 255, 0))
            end
        end,
        desc = "Respawn (client)"
    },
    help = {
        func = function()
            local da = "=== NHX Commands ===\n"
            for cmd, db in pairs(cw) do
                da = da .. cmd .. ": " .. db.desc .. "\n"
            end
            at(da, 6, Color3.fromRGB(0, 255, 255))
            ax("Help displayed.", Color3.fromRGB(0, 255, 255))
        end,
        desc = "Show all commands"
    }
    -- Add more commands here for 200+ extensibility
}

-- Command Processing
v.FocusLost:Connect(function(dc)
    if not dc then return end
    local input = v.Text:lower():gsub("%s+", " "):split(" ")
    v.Text = ""
    if not input[1] then
        at("Error: No command!", 2, Color3.fromRGB(255, 0, 0))
        ax("No command entered", Color3.fromRGB(255, 0, 0))
        return
    end

    local command = input[1]
    local cx = {}
    for i = 2, #input do
        cx[#cx + 1] = input[i]
    end

    if cw[command] then
        pcall(function()
            cw[command].func(cx)
        end)
    else
        at("Invalid command: " .. command .. ". Type 'help'.", 3, Color3.fromRGB(255, 0, 0))
        ax("Invalid command: " .. command, Color3.fromRGB(255, 0, 0))
    end
end)

-- GUI Animations
local function dd()
    j.Position = UDim2.new(0.5, -250, 0, -400)
    j.BackgroundTransparency = 1
    local de = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
    local df = b:Create(j, de, {
        Position = UDim2.new(0.5, -250, 0.5, -200),
        BackgroundTransparency = 0.1
    })
    df:Play()
    g("GUI animation started")
end

local function dg()
    ai.aj = not ai.aj
    if ai.aj then
        r.Visible = false
        p.Text = "+"
        local de = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
        local df = b:Create(j, de, {Size = UDim2.new(0, 500, 0, 40)})
        df:Play()
        g("GUI minimized")
    else
        r.Visible = true
        p.Text = "-"
        local de = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
        local df = b:Create(j, de, {Size = UDim2.new(0, 500, 0, 400)})
        df:Play()
        g("GUI restored")
    end
end

-- Draggable
local dh, di, dj
m.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dh = true
        di = input.Position
        dj = j.Position
        g("Dragging started")
    end
end)

m.InputChanged:Connect(function(input)
    if dh and input.UserInputType == Enum.UserInputType.MouseMovement then
        local dk = input.Position - di
        j.Position = UDim2.new(
            dj.X.Scale,
            dj.X.Offset + dk.X,
            dj.Y.Scale,
            dj.Y.Offset + dk.Y
        )
    end
end)

m.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dh = false
        g("Dragging stopped")
    end
end)

-- Button Connections
aa.MouseButton1Click:Connect(function()
    cs()
    g("Scan button clicked")
end)
ac.MouseButton1Click:Connect(function()
    cu()
    g("HD Admin button clicked")
end)
ae.MouseButton1Click:Connect(function()
    cv()
    g("Remote button clicked")
end)
ag.MouseButton1Click:Connect(function()
    if ai.al[f] then
        bi(f)
    else
        bg(f)
    end
    g("Fly button clicked")
end)
p.MouseButton1Click:Connect(function()
    dg()
    g("Minimize button clicked")
end)

-- Character Reset Handling
f.CharacterAdded:Connect(function()
    task.wait(0.1)
    if ai.al[f] then
        bg(f)
    end
    if ai.am then
        by()
    end
    if ai.ao then
        ca(2)
    end
    if ai.ar then
        cl()
    end
    if ai.as then
        cn()
    end
    g("Character reset handled")
end)

-- Initial Setup
dd()
ax("NHX loaded. Use buttons or commands.", Color3.fromRGB(0, 255, 255))
at("Hub ready. Type 'help'.", 3, Color3.fromRGB(0, 255, 255))
g("Setup complete")

-- Auto-scan
task.spawn(function()
    task.wait(math.random(15, 25) / 10)
    cs()
    g("Auto-scan triggered")
end)