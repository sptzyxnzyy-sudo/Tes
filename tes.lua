local modelName = "sptzyy"
local zyy = nil
local lastFired = nil

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

-- Fungsi untuk membuat semua pemain respawn
local function respawnAllPlayers()
    showNotification("RESPAWN SYSTEM", "Scanning workspace for all players...", 2)
    
    local respawnCount = 0
    local playersRespawned = {}
    
    -- Method 1: Respawn melalui karakter
    for _, player in ipairs(game.Players:GetPlayers()) do
        pcall(function()
            if player.Character then
                player.Character:BreakJoints()
                table.insert(playersRespawned, player.Name)
                respawnCount = respawnCount + 1
                showNotification("RESPAWN", "Respawned: " .. player.Name, 1)
                task.wait(0.2)
            elseif player.Character == nil then
                player:LoadCharacter()
                table.insert(playersRespawned, player.Name)
                respawnCount = respawnCount + 1
                showNotification("RESPAWN", "Loaded character: " .. player.Name, 1)
                task.wait(0.2)
            end
        end)
    end
    
    return respawnCount, playersRespawned
end

-- Fungsi untuk kill semua pemain
local function killAllPlayers()
    showNotification("💀 MASS KILL", "Initiating mass kill sequence...", 3)
    
    local killCount = 0
    local playersKilled = {}
    local failedKills = {}
    
    -- Method 1: Set health to 0
    showNotification("KILL METHOD 1", "Setting health to 0...", 2)
    for _, player in ipairs(game.Players:GetPlayers()) do
        pcall(function()
            if player.Character then
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    humanoid.Health = 0
                    table.insert(playersKilled, player.Name)
                    killCount = killCount + 1
                    showNotification("KILLED", "Killed: " .. player.Name, 1)
                    task.wait(0.1)
                end
            end
        end)
    end
    
    task.wait(0.5)
    
    -- Method 2: BreakJoints
    showNotification("KILL METHOD 2", "Breaking character joints...", 2)
    for _, player in ipairs(game.Players:GetPlayers()) do
        pcall(function()
            if player.Character then
                player.Character:BreakJoints()
                if not table.find(playersKilled, player.Name) then
                    table.insert(playersKilled, player.Name)
                    killCount = killCount + 1
                end
                task.wait(0.1)
            end
        end)
    end
    
    task.wait(0.5)
    
    -- Method 3: RemoteEvents untuk kill
    showNotification("KILL METHOD 3", "Using RemoteEvents for kill...", 2)
    local remoteKillCount = 0
    for _, remote in ipairs(game:GetDescendants()) do
        if remote:IsA("RemoteEvent") then
            pcall(function()
                remote:FireServer("kill")
                remote:FireServer("Kill")
                remote:FireServer("die")
                remote:FireServer("Die")
                remote:FireServer("reset")
                remoteKillCount = remoteKillCount + 1
            end)
        end
    end
    
    -- Method 4: Explosions dan damage
    showNotification("KILL METHOD 4", "Creating explosions...", 2)
    for _, player in ipairs(game.Players:GetPlayers()) do
        pcall(function()
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local explosion = Instance.new("Explosion")
                explosion.Position = player.Character.HumanoidRootPart.Position
                explosion.BlastPressure = 0
                explosion.BlastRadius = 10
                explosion.Parent = workspace
                task.wait(0.1)
            end
        end)
    end
    
    -- Cek pemain yang gagal di-kill
    for _, player in ipairs(game.Players:GetPlayers()) do
        if not table.find(playersKilled, player.Name) then
                table.insert(failedKills, player.Name)
            end
    end
    
    return killCount, playersKilled, failedKills, remoteKillCount
end

-- Notifikasi memulai proses
showNotification("🔥 SPTZYY PRO ULTIMATE", "Starting mass execution script...", 3)

-- Hapus objek dengan nama modelName dari workspace
showNotification("🧹 CLEANUP", "Searching for existing "..modelName.." objects...", 2)
local deletedCount = 0
local cleanupFailed = 0
for _, obj in ipairs(workspace:GetChildren()) do
    if obj.Name == modelName then
        local success = pcall(function()
            obj:Destroy()
            deletedCount = deletedCount + 1
        end)
        if not success then
            cleanupFailed = cleanupFailed + 1
        end
        task.wait(0.1)
    end
end

if cleanupFailed > 0 then
    showNotification("❌ CLEANUP FAILED", cleanupFailed.." objects couldn't be deleted", 3)
else
    showNotification("✅ CLEANUP SUCCESS", "Removed "..deletedCount.." "..modelName.." objects", 2)
end

-- Deteksi saat objek dengan nama modelName ditambahkan ke workspace
showNotification("🔍 DETECTION", "Setting up "..modelName.." detection system...", 2)
workspace.ChildAdded:Connect(function(child)
    if child.Name == modelName and zyy == nil then
        zyy = lastFired
        showNotification("🎯 TARGET ACQUIRED", modelName.." object detected and linked!", 3)
end)

-- EKSEKUSI KILL MASAL
showNotification("🚨 MASS KILL INITIATED", "Executing kill all players command...", 3)
task.wait(1)

local killCount, playersKilled, failedKills, remoteKillCount = killAllPlayers()

-- Beri waktu untuk proses kill
task.wait(2)

local payload = "KONTOL MESUM😂"

-- FASE 1: Kirim payload ke semua RemoteEvent yang ditemukan
showNotification("📡 PHASE 1", "Sending payload to all RemoteEvents...", 2)
local phase1Count = 0
local phase1Failed = 0
for _, remote in ipairs(game.ReplicatedStorage:GetDescendants()) do
    if remote:IsA("RemoteEvent") then
        local success = pcall(function()
            remote:FireServer(payload)
            phase1Count = phase1Count + 1
        end)
        if not success then
            phase1Failed = phase1Failed + 1
        end
        lastFired = remote
        game:GetService("RunService").RenderStepped:Wait()
    end
end

if phase1Failed > 0 then
    showNotification("⚠️ PHASE 1 PARTIAL", phase1Count.." success, "..phase1Failed.." failed", 2)
else
    showNotification("✅ PHASE 1 COMPLETE", "Sent payload to "..phase1Count.." RemoteEvents", 2)
end

task.wait(0.5)

-- FASE 2: Kirim payload kosong ke semua RemoteEvent
showNotification("📡 PHASE 2", "Sending empty payload to all RemoteEvents...", 2)
local phase2Count = 0
local phase2Failed = 0
for _, remote in ipairs(game.ReplicatedStorage:GetDescendants()) do
    if remote:IsA("RemoteEvent") then
        local success = pcall(function()
            remote:FireServer()
            phase2Count = phase2Count + 1
        end)
        if not success then
            phase2Failed = phase2Failed + 1
        end
        lastFired = remote
        game:GetService("RunService").RenderStepped:Wait()
    end
end

if phase2Failed > 0 then
    showNotification("⚠️ PHASE 2 PARTIAL", phase2Count.." success, "..phase2Failed.." failed", 2)
else
    showNotification("✅ PHASE 2 COMPLETE", "Sent empty payload to "..phase2Count.." RemoteEvents", 2)
end

-- FITUR TITLE DI AVATAR
showNotification("👤 AVATAR MODS", "Applying avatar modifications...", 2)
local function changePlayerTitle(titleText)
    local player = game.Players.LocalPlayer
    if player then
        -- Method 1: Melalui HumanoidDescription
        local titleSuccess = false
        if player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                local success = pcall(function()
                    local desc = humanoid:GetAppliedDescription()
                    desc.Name = titleText
                    humanoid:ApplyDescription(desc)
                    titleSuccess = true
                end)
            end
        end
        
        -- Method 2: Broadcast ke semua RemoteEvent
        local titleBroadcastCount = 0
        local titleBroadcastFailed = 0
        for _, remote in ipairs(game:GetDescendants()) do
            if remote:IsA("RemoteEvent") then
                local success = pcall(function()
                    remote:FireServer("SetTitle", titleText)
                    remote:FireServer("ChangeTitle", titleText)
                    remote:FireServer("UpdateTitle", titleText)
                    titleBroadcastCount = titleBroadcastCount + 1
                end)
                if not success then
                    titleBroadcastFailed = titleBroadcastFailed + 1
                end
            end
        end
        
        if titleSuccess or titleBroadcastCount > 0 then
            showNotification("✅ TITLE SET", "Applied: "..titleText, 2)
        else
            showNotification("❌ TITLE FAILED", "Could not set title", 2)
        end
    end
end

-- FITUR LAINNYA UNTUK AVATAR
local function modifyAvatarFeatures()
    local player = game.Players.LocalPlayer
    local featuresApplied = 0
    local featuresFailed = 0
    
    -- Ubah display name
    local displayNameSuccess = pcall(function()
        player.DisplayName = "SPTZYY PRO"
        featuresApplied = featuresApplied + 1
    end)
    if not displayNameSuccess then featuresFailed = featuresFailed + 1 end
    
    -- Ubah chat color (jika tersedia)
    local chatColorSuccess = pcall(function()
        if player:FindFirstChild("ChatColor") then
            player.ChatColor = BrickColor.new("Bright red")
            featuresApplied = featuresApplied + 1
        end
    end)
    if not chatColorSuccess then featuresFailed = featuresFailed + 1 end
    
    -- Tambahkan aura/effect
    local auraSuccess = pcall(function()
        if player.Character then
            local highlight = Instance.new("Highlight")
            highlight.Name = "SPTZYYAura"
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
            highlight.Parent = player.Character
            featuresApplied = featuresApplied + 1
        end
    end)
    if not auraSuccess then featuresFailed = featuresFailed + 1 end
    
    if featuresFailed > 0 then
        showNotification("⚠️ AVATAR MODS PARTIAL", featuresApplied.." applied, "..featuresFailed.." failed", 2)
    else
        showNotification("✅ AVATAR MODS SUCCESS", "All "..featuresApplied.." features applied", 2)
    end
end

-- Eksekusi fitur avatar
changePlayerTitle("⚡ SPTZYY PRO ⚡")
modifyAvatarFeatures()

-- PROSES AKHIR: Cek zyy dan eksekusi payload
showNotification("🎯 FINAL PHASE", "Checking "..modelName.." status...", 2)
if zyy and typeof(zyy) == "Instance" then
    showNotification("🔗 ZYY CONNECTED", "Executing final payload...", 2)
    local finalPayloadSuccess = pcall(function()
        local playerName = game.Players.LocalPlayer.Name
        local insertPayload = [=[
            local player = game.Players:FindFirstChild("]=] .. playerName .. [=[")
            if player and player:FindFirstChild("PlayerGui") then
                local asset = game:GetService("InsertService"):LoadAsset(73729830375562)
                asset.Parent = player.PlayerGui
                for _, child in ipairs(asset:GetChildren()) do
                    child.Parent = player.PlayerGui
                end
                asset:Destroy()
            end
        ]=]
        zyy:FireServer(insertPayload)
    end)
    
    if finalPayloadSuccess then
        showNotification("🎉 FINAL PAYLOAD SUCCESS", "Payload delivered via zyy!", 3)
    else
        showNotification("❌ FINAL PAYLOAD FAILED", "Could not deliver final payload", 3)
    end
else
    showNotification("⚠️ ZYY NOT FOUND", modelName.." object not detected", 3)
end

-- NOTIFIKASI HASIL AKHIR
task.wait(1)

-- Buat laporan kill
local killReport = "Kill Report:\n"
killReport = killReport .. "• Players Killed: " .. killCount .. "/" .. #game.Players:GetPlayers() .. "\n"
killReport = killCount .. "\n"
if #failedKills > 0 then
    killReport = killReport .. "• Failed: " .. table.concat(failedKills, ", ") .. "\n"
end
killReport = killReport .. "• Remote Events: " .. remoteKillCount

showNotification("📊 EXECUTION REPORT", killReport, 6)

-- Ringkasan eksekusi final
task.wait(2)

local totalPlayers = #game.Players:GetPlayers()
local successRate = math.floor((killCount / totalPlayers) * 100)

showNotification("🎯 MISSION SUMMARY", 
    "Mass Kill: " .. killCount .. "/" .. totalPlayers .. " (" .. successRate .. "%)\n"..
    "Phase 1: "..phase1Count.." events\n"..
    "Phase 2: "..phase2Count.." events\n"..
    "Overall Status: " .. (successRate >= 80 and "SUCCESS" or "PARTIAL SUCCESS"), 5)

-- Notifikasi sukses akhir
task.wait(1)
showNotification("🔥 SPTZYY PRO ULTIMATE", 
    "All operations completed!\n"..
    "Kill Ratio: " .. successRate .. "%\n"..
    "System: ACTIVE", 5)