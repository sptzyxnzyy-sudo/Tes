local modelName = "sptzyy"
local zyy = nil
local lastFired = nil
local espEnabled = true
local espObjects = {}

-- Fungsi untuk menampilkan notifikasi
local function showNotification(title, text, duration)
    duration = duration or 3
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title,
        Text = text,
        Icon = "",
        Duration = duration,
    })
end

-- Fungsi untuk membuat ESP box dan line
local function createESP(player)
    if player == game.Players.LocalPlayer then return end
    
    local esp = {}
    
    -- Box Highlight
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.Adornee = nil
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
    highlight.FillTransparency = 0.8
    highlight.OutlineTransparency = 0
    highlight.Parent = game.CoreGui
    
    -- Line ke local player
    local line = Instance.new("Frame")
    line.Name = "ESP_Line"
    line.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
    line.BorderSizePixel = 0
    line.Size = UDim2.new(0, 2, 0, 100)
    line.Visible = false
    line.Parent = game.CoreGui
    
    -- Info label
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Name = "ESP_Info"
    infoLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    infoLabel.BackgroundTransparency = 0.5
    infoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    infoLabel.TextSize = 14
    infoLabel.Font = Enum.Font.GothamBold
    infoLabel.Text = ""
    infoLabel.Size = UDim2.new(0, 150, 0, 40)
    infoLabel.Visible = false
    infoLabel.Parent = game.CoreGui
    
    esp.highlight = highlight
    esp.line = line
    esp.infoLabel = infoLabel
    
    return esp
end

-- Fungsi untuk update ESP position
local function updateESP(player, esp)
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        esp.highlight.Adornee = nil
        esp.line.Visible = false
        esp.infoLabel.Visible = false
        return
    end
    
    local rootPart = player.Character.HumanoidRootPart
    local localPlayer = game.Players.LocalPlayer
    local localRoot = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    if not localRoot then return end
    
    -- Update highlight
    esp.highlight.Adornee = player.Character
    
    -- Update line position dan rotation
    local distance = (rootPart.Position - localRoot.Position).Magnitude
    local direction = (rootPart.Position - localRoot.Position).Unit
    
    -- Calculate screen positions
    local rootPos, rootVisible = workspace.CurrentCamera:WorldToViewportPoint(rootPart.Position)
    local localPos, localVisible = workspace.CurrentCamera:WorldToViewportPoint(localRoot.Position)
    
    if rootVisible and localVisible then
        -- Line dari local player ke target
        local angle = math.atan2(rootPos.Y - localPos.Y, rootPos.X - localPos.X)
        local length = math.min(distance * 2, 200) -- Batasi panjang line
        
        esp.line.Visible = true
        esp.line.Size = UDim2.new(0, 2, 0, length)
        esp.line.Position = UDim2.new(0, localPos.X, 0, localPos.Y)
        esp.line.Rotation = math.deg(angle)
        
        -- Update info label
        local health = "N/A"
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            health = math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)
        end
        
        esp.infoLabel.Text = string.format(
            "Player: %s\nDistance: %d\nHealth: %s",
            player.Name,
            math.floor(distance),
            health
        )
        
        -- Position info label di atas kepala player
        esp.infoLabel.Position = UDim2.new(0, rootPos.X - 75, 0, rootPos.Y - 50)
        esp.infoLabel.Visible = true
        
        -- Update warna berdasarkan health
        if humanoid then
            if humanoid.Health <= 0 then
                esp.highlight.FillColor = Color3.fromRGB(100, 100, 100) -- Gray untuk dead
            esp.line.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            elseif humanoid.Health / humanoid.MaxHealth < 0.3 then
                esp.highlight.FillColor = Color3.fromRGB(255, 0, 0) -- Red untuk low health
            esp.line.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            elseif humanoid.Health / humanoid.MaxHealth < 0.6 then
                esp.highlight.FillColor = Color3.fromRGB(255, 165, 0) -- Orange untuk medium health
            esp.line.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
            else
                esp.highlight.FillColor = Color3.fromRGB(0, 255, 0) -- Green untuk high health
            esp.line.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            end
        end
    else
        esp.line.Visible = false
        esp.infoLabel.Visible = false
    end
end

-- Fungsi untuk enable/disable ESP
local function toggleESP(enable)
    espEnabled = enable
    
    for player, esp in pairs(espObjects) do
        if enable then
            esp.highlight.Enabled = true
        else
            esp.highlight.Enabled = false
            esp.line.Visible = false
            esp.infoLabel.Visible = false
        end
    end
    
    if enable then
        showNotification("👁️ ESP", "ESP enabled for all players", 3)
    else
        showNotification("👁️ ESP", "ESP disabled", 3)
    end
end

-- Fungsi untuk setup ESP semua pemain
local function setupESP()
    showNotification("👁️ ESP SYSTEM", "Setting up player ESP...", 2)
    
    -- Setup ESP untuk pemain yang sudah ada
    for _, player in ipairs(game.Players:GetPlayers()) do
        if not espObjects[player] then
            espObjects[player] = createESP(player)
    end
    
    -- Listen untuk pemain baru
    game.Players.PlayerAdded:Connect(function(player)
        espObjects[player] = createESP(player)
        showNotification("👤 NEW PLAYER", "ESP added for: " .. player.Name, 2)
    end)
    
    -- Listen untuk pemain yang leave
    game.Players.PlayerRemoving:Connect(function(player)
        if espObjects[player] then
            espObjects[player].highlight:Destroy()
            espObjects[player].line:Destroy()
            espObjects[player].infoLabel:Destroy()
        espObjects[player] = nil
    end)
    
    -- Update loop untuk ESP
    game:GetService("RunService").RenderStepped:Connect(function()
        if espEnabled then
            for player, esp in pairs(espObjects) do
                updateESP(player, esp)
            end
        else
            for _, esp in pairs(espObjects) do
            esp.line.Visible = false
            esp.infoLabel.Visible = false
        end
    end)
end

-- Fungsi untuk kill semua pemain
local function killAllPlayers()
    showNotification("💀 MASS KILL", "Initiating kill sequence...", 3)
    
    local killCount = 0
    local playersKilled = {}
    local failedKills = {}
    
    -- Method 1: Set health to 0
    for _, player in ipairs(game.Players:GetPlayers()) do
        local success = pcall(function()
            if player.Character then
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                humanoid.Health = 0
                table.insert(playersKilled, player.Name)
                killCount = killCount + 1
            end
        end
    end)
    
    if not success then
        table.insert(failedKills, player.Name)
    end
end

task.wait(1)

-- Method 2: BreakJoints untuk yang belum mati
for _, player in ipairs(game.Players:GetPlayers()) do
    if not table.find(playersKilled, player.Name) then
        local success = pcall(function()
            if player.Character then
                player.Character:BreakJoints()
                table.insert(playersKilled, player.Name)
                killCount = killCount + 1
            end
        end)
        
        if not success then
            table.insert(failedKills, player.Name)
        end
    end
end

return killCount, playersKilled, failedKills
end

-- Notifikasi memulai proses
showNotification("🔥 SPTZYY PRO ULTIMATE", "Starting execution with ESP...", 3)

-- Setup ESP system
setupESP()

-- Hapus objek dengan nama modelName dari workspace
showNotification("🧹 CLEANUP", "Cleaning "..modelName.." objects...", 2)
local deletedCount = 0
for _, obj in ipairs(workspace:GetChildren()) do
    if obj.Name == modelName then
        pcall(function()
            obj:Destroy()
            deletedCount = deletedCount + 1
    end
end

showNotification("✅ CLEANUP", "Removed "..deletedCount.." objects", 2)

-- Deteksi saat objek dengan nama modelName ditambahkan ke workspace
workspace.ChildAdded:Connect(function(child)
    if child.Name == modelName and zyy == nil then
        zyy = lastFired
        showNotification("🎯 TARGET FOUND", modelName.." object linked!", 3)
end)

-- PILIHAN EXECUTION
showNotification("⚙️ SELECT MODE", "Choose action:\n1. Mass Kill\n2. Toggle ESP", 4)

-- Eksekusi Mass Kill
task.wait(2)
showNotification("🚨 EXECUTING", "Mass Kill selected...", 2)

local killCount, playersKilled, failedKills = killAllPlayers()

-- Beri waktu untuk proses
task.wait(2)

local payload = "KONTOL MESUM😂"

-- FASE 1: Kirim payload ke RemoteEvents
showNotification("📡 PHASE 1", "Sending payload...", 2)
local phase1Count = 0
for _, remote in ipairs(game.ReplicatedStorage:GetDescendants()) do
    if remote:IsA("RemoteEvent") then
        pcall(function()
            remote:FireServer(payload)
            phase1Count = phase1Count + 1
        end)
        lastFired = remote
    end
end

showNotification("✅ PHASE 1", phase1Count.." events triggered", 2)

task.wait(0.5)

-- FASE 2: Kirim payload kosong
showNotification("📡 PHASE 2", "Sending empty payload...", 2)
local phase2Count = 0
for _, remote in ipairs(game.ReplicatedStorage:GetDescendants()) do
    if remote:IsA("RemoteEvent") then
        pcall(function()
            remote:FireServer()
            phase2Count = phase2Count + 1
        end)
        lastFired = remote
    end
end

showNotification("✅ PHASE 2", phase2Count.." events triggered", 2)

-- FITUR AVATAR
showNotification("👤 AVATAR", "Applying modifications...", 2)

-- Ubah title
pcall(function()
    local player = game.Players.LocalPlayer
    if player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        local desc = humanoid:GetAppliedDescription()
        desc.Name = "⚡ SPTZYY PRO ⚡"
        humanoid:ApplyDescription(desc)
    end
end
end)

showNotification("✅ TITLE SET", "Title: ⚡ SPTZYY PRO ⚡", 2)

-- PROSES AKHIR
showNotification("🎯 FINAL PHASE", "Checking "..modelName.."...", 2)

if zyy and typeof(zyy) == "Instance" then
    pcall(function()
        local playerName = game.Players.LocalPlayer.Name
        local insertPayload = [[
            local player = game.Players:FindFirstChild("]] .. playerName .. [[")
            if player and player:FindFirstChild("PlayerGui") then
                local asset = game:GetService("InsertService"):LoadAsset(73729830375562)
            asset.Parent = player.PlayerGui
            for _, child in ipairs(asset:GetChildren()) do
                child.Parent = player.PlayerGui
            end
            asset:Destroy()
        end
    ]]
        zyy:FireServer(insertPayload)
        showNotification("🎉 SUCCESS", "Final payload delivered!", 3)
    end)
else
    showNotification("⚠️ WARNING", modelName.." not found", 3)
end

-- NOTIFIKASI HASIL AKHIR
task.wait(1)

local totalPlayers = #game.Players:GetPlayers()
local successRate = math.floor((killCount / totalPlayers) * 100)

-- Tampilkan hasil kill
if killCount == totalPlayers then
    showNotification("💀 MASS KILL COMPLETE", 
        "✅ SUCCESS: "..killCount.."/"..totalPlayers.." killed\n"..
        "("..successRate.."% Success Rate)", 5)
elseif killCount > 0 then
    showNotification("⚠️ MASS KILL PARTIAL", 
        "🟡 PARTIAL: "..killCount.."/"..totalPlayers.." killed\n"..
        "("..successRate.."% Success Rate)", 5)
else
    showNotification("❌ MASS KILL FAILED", 
        "🔴 FAILED: 0/"..totalPlayers.." killed", 5)
end

-- ESP TOGGLE FEATURE
task.wait(2)
showNotification("👁️ ESP CONTROL", "Press F to toggle ESP on/off", 5)

-- Keybind untuk toggle ESP
local UIS = game:GetService("UserInputService")
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F then
        toggleESP(not espEnabled)
    end
end)

-- Tampilkan info ESP
task.wait(1)
showNotification("👁️ ESP STATUS", 
    "ESP: "..(espEnabled and "ENABLED" or "DISABLED").."\n"..
    "Players Tracked: "..#game.Players:GetPlayers().."\n"..
    "Lines: CONNECTED\n"..
    "Info: VISIBLE", 5)

-- SUMMARY FINAL DENGAN ESP INFO
task.wait(2)

showNotification("📊 EXECUTION SUMMARY", 
    "Mass Kill: "..killCount.."/"..totalPlayers.."\n"..
    "ESP: "..(espEnabled and "ACTIVE" or "INACTIVE").."\n"..
    "Phase 1: "..phase1Count.." events\n"..
    "Phase 2: "..phase2Count.." events\n"..
    "Status: "..(successRate >= 80 and "SUCCESS" or successRate >= 50 and "PARTIAL" or "FAILED").."\n"..
    "Press F to toggle ESP", 6)

-- Auto cleanup jika player mati
game.Players.LocalPlayer.CharacterAdded:Connect(function(character)
    character:WaitForChild("Humanoid").Died:Connect(function()
        toggleESP(false)
        showNotification("💀 PLAYER DIED", "ESP disabled automatically", 3)
end)