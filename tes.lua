local modelName = "sptzyy"
local zyy = nil
local lastFired = nil
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
    highlight.Name = "ESP_Highlight_" .. player.Name
    highlight.Adornee = nil
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
    highlight.FillTransparency = 0.8
    highlight.OutlineTransparency = 0
    highlight.Parent = game.CoreGui
    
    -- Line ke local player
    local line = Instance.new("Frame")
    line.Name = "ESP_Line_" .. player.Name
    line.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
    line.BorderSizePixel = 0
    line.Size = UDim2.new(0, 2, 0, 100)
    line.Visible = false
    line.ZIndex = 10
    line.Parent = game.CoreGui
    
    -- Info label
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Name = "ESP_Info_" .. player.Name
    infoLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    infoLabel.BackgroundTransparency = 0.3
    infoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    infoLabel.TextSize = 12
    infoLabel.Font = Enum.Font.GothamBold
    infoLabel.Text = ""
    infoLabel.Size = UDim2.new(0, 120, 0, 35)
    infoLabel.Visible = false
    infoLabel.ZIndex = 10
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
        local length = math.min(distance * 0.5, 150)
        
        esp.line.Visible = true
        esp.line.Size = UDim2.new(0, 2, 0, length)
        esp.line.Position = UDim2.new(0, localPos.X, 0, localPos.Y)
        esp.line.Rotation = math.deg(angle)
        
        -- Update info label
        local health = "DEAD"
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.Health > 0 then
            health = math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)
        end
        
        esp.infoLabel.Text = string.format(
            "%s\n%d studs\n%s",
            player.Name,
            math.floor(distance),
            health
        )
        
        -- Position info label di atas kepala player
        esp.infoLabel.Position = UDim2.new(0, rootPos.X - 60, 0, rootPos.Y - 40)
        esp.infoLabel.Visible = true
        
        -- Update warna berdasarkan health
        if humanoid then
            if humanoid.Health <= 0 then
                esp.highlight.FillColor = Color3.fromRGB(100, 100, 100)
                esp.line.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            elseif humanoid.Health / humanoid.MaxHealth < 0.3 then
                esp.highlight.FillColor = Color3.fromRGB(255, 0, 0)
                esp.line.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            elseif humanoid.Health / humanoid.MaxHealth < 0.6 then
                esp.highlight.FillColor = Color3.fromRGB(255, 165, 0)
                esp.line.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
            else
                esp.highlight.FillColor = Color3.fromRGB(0, 255, 0)
                esp.line.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            end
        end
    else
        esp.line.Visible = false
        esp.infoLabel.Visible = false
    end
end

-- Fungsi untuk setup ESP semua pemain
local function setupESP()
    -- Setup ESP untuk pemain yang sudah ada
    for _, player in ipairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer and not espObjects[player] then
            espObjects[player] = createESP(player)
        end
    end
    
    -- Listen untuk pemain baru
    game.Players.PlayerAdded:Connect(function(player)
        task.wait(1)
        espObjects[player] = createESP(player)
    end)
    
    -- Listen untuk pemain yang leave
    game.Players.PlayerRemoving:Connect(function(player)
        if espObjects[player] then
            espObjects[player].highlight:Destroy()
            espObjects[player].line:Destroy()
            espObjects[player].infoLabel:Destroy()
            espObjects[player] = nil
        end
    end)
    
    -- Update loop untuk ESP
    game:GetService("RunService").RenderStepped:Connect(function()
        for player, esp in pairs(espObjects) do
            updateESP(player, esp)
        end
    end)
end

-- Fungsi untuk kill semua pemain
local function killAllPlayers()
    local killCount = 0
    local playersKilled = {}
    local failedKills = {}
    
    -- Method 1: Set health to 0
    for _, player in ipairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer then
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
    end
    
    task.wait(0.5)
    
    -- Method 2: BreakJoints untuk yang belum mati
    for _, player in ipairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer and not table.find(playersKilled, player.Name) then
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
showNotification("🔥 SPTZYY PRO ULTIMATE", "Starting execution with ESP...", 2)

-- Setup ESP system langsung jalan
setupESP()
showNotification("👁️ ESP SYSTEM", "ESP activated for all players", 2)

-- Hapus objek dengan nama modelName dari workspace
local deletedCount = 0
for _, obj in ipairs(workspace:GetChildren()) do
    if obj.Name == modelName then
        pcall(function()
            obj:Destroy()
            deletedCount = deletedCount + 1
        end)
    end
end

showNotification("🧹 CLEANUP", "Removed "..deletedCount.." objects", 2)

-- Deteksi saat objek dengan nama modelName ditambahkan ke workspace
workspace.ChildAdded:Connect(function(child)
    if child.Name == modelName and zyy == nil then
        zyy = lastFired
        showNotification("🎯 TARGET FOUND", modelName.." object linked!", 2)
end)

-- Eksekusi Mass Kill langsung
task.wait(1)
showNotification("🚨 MASS KILL", "Executing kill sequence...", 2)

local killCount, playersKilled, failedKills = killAllPlayers()

task.wait(1)

local payload = "KONTOL MESUM😂"

-- FASE 1: Kirim payload ke RemoteEvents
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

showNotification("📡 PHASE 1", phase1Count.." events triggered", 2)

task.wait(0.3)

-- FASE 2: Kirim payload kosong
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

showNotification("📡 PHASE 2", phase2Count.." events triggered", 2)

-- FITUR AVATAR
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

showNotification("👤 AVATAR", "Title: ⚡ SPTZYY PRO ⚡", 2)

-- PROSES AKHIR
task.wait(0.5)

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
    showNotification("⚠️ WARNING", modelName.." not found", 2)
end

-- NOTIFIKASI HASIL AKHIR
task.wait(1)

local totalPlayers = #game.Players:GetPlayers() - 1 -- exclude local player
if totalPlayers < 0 then totalPlayers = 0 end

local successRate = totalPlayers > 0 and math.floor((killCount / totalPlayers) * 100) or 100

-- Tampilkan hasil kill
if killCount == totalPlayers then
    showNotification("💀 MASS KILL COMPLETE", 
        killCount.."/"..totalPlayers.." killed ("..successRate.."%)", 4)
elseif killCount > 0 then
    showNotification("⚠️ MASS KILL PARTIAL", 
        killCount.."/"..totalPlayers.." killed ("..successRate.."%)", 4)
else
    showNotification("❌ MASS KILL FAILED", 
        "0/"..totalPlayers.." killed", 4)
end

-- INFO ESP AKTIF
task.wait(1)
showNotification("👁️ ESP ACTIVE", 
    "Tracking "..totalPlayers.." players\n"..
    "Lines: VISIBLE\n"..
    "Info: ON", 4)

-- SUMMARY FINAL
task.wait(1)

showNotification("📊 EXECUTION COMPLETE", 
    "Kill: "..killCount.."/"..totalPlayers.."\n"..
    "ESP: ALWAYS ON\n"..
    "Status: OPERATIONAL", 5)

-- Auto refresh ESP saat character respawn
game.Players.LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(2)
    showNotification("🔄 ESP REFRESH", "ESP system updated", 2)
end