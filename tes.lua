-- File: Global_TitleAndTagInjector_ServerSide.lua 
-- Kode ini dirancang untuk dieksekusi di Server (misalnya, di ServerScriptService atau melalui Server-Side Executor)

-- === 1. Konfigurasi & Services ===
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Daftar nama pengguna yang diizinkan untuk memiliki tag Admin secara otomatis (otomatis)
local ADMIN_USERS = {
    "xnzy101", -- Ganti dengan username Anda
    -- Tambahkan username admin lain di sini
}

-- Nama RemoteEvent yang akan kita buat/gunakan untuk Title Inject Client-to-Server
-- CATATAN: Remote ini HANYA diperlukan jika Anda ingin Client (LocalScript) memicu fungsi Server ini.
local CLIENT_INJECT_REMOTE_NAME = "GlobalTitleTagInjector" 

-- Daftar pemain aktif yang harus memiliki tag, dan detail tag mereka
-- Format: { [UserId] = {Title = "ADMIN", Color = Color3.new(1, 0, 0)} }
local ACTIVE_TAGS = {}

-- === 2. Fungsi Dasar Server-Side ===

-- Membuat BillboardGui Tag di atas kepala pemain (Dilihat Semua Pemain)
local function createAdminTag(player, titleText, tagColor)
    local Character = player.Character
    if not Character or not Character:FindFirstChild("Head") then return end

    local Head = Character.Head
    local ExistingTag = Head:FindFirstChild("AdminTag")
    if ExistingTag then ExistingTag:Destroy() end -- Hapus tag lama jika ada

    -- BillboardGui
    local Tag = Instance.new("BillboardGui")
    Tag.Name = "AdminTag"
    Tag.Size = UDim2.new(3, 0, 1, 0)
    Tag.Adornee = Head
    Tag.AlwaysOnTop = true
    Tag.ExtentsOffsetWorldSpace = Vector3.new(0, 1.5, 0) -- Diangkat sedikit
    Tag.Parent = Head

    -- TextLabel
    local TextLabel = Instance.new("TextLabel")
    TextLabel.Text = "[" .. string.upper(titleText or "ADMIN") .. "]"
    TextLabel.Size = UDim2.new(1, 0, 1, 0)
    TextLabel.Font = Enum.Font.SourceSansBold
    TextLabel.TextColor3 = tagColor or Color3.new(1, 0, 0)
    TextLabel.TextStrokeTransparency = 0
    TextLabel.BackgroundTransparency = 1
    TextLabel.Parent = Tag
end

-- Menghubungkan Tag ke event CharacterAdded (Agar tag muncul setelah respawn)
local function linkTagToCharacter(player, title, color)
    local tagData = {Title = title, Color = color}
    ACTIVE_TAGS[player.UserId] = tagData
    
    local function applyTag()
        if ACTIVE_TAGS[player.UserId] then
             -- Tunggu sebentar untuk memastikan Head sudah dimuat
            task.wait(0.1) 
            createAdminTag(player, tagData.Title, tagData.Color)
        end
    end
    
    -- Koneksi CharacterAdded
    player.CharacterAdded:Connect(applyTag)
    
    -- Terapkan tag jika karakter sudah dimuat
    if player.Character then
        applyTag()
    end
end

-- Menghapus tag dari pemain tertentu
local function removePlayerTag(player)
    if ACTIVE_TAGS[player.UserId] then
        ACTIVE_TAGS[player.UserId] = nil
        if player.Character and player.Character:FindFirstChild("Head") and player.Character.Head:FindFirstChild("AdminTag") then
            player.Character.Head:FindFirstChild("AdminTag"):Destroy()
        end
        return true
    end
    return false
end

-- Mengirim pesan sistem/judul ke SEMUA pemain melalui fungsi Chat internal game
local function broadcastGlobalMessage(title, sourceName, color)
    local message = string.format("[%s] %s: %s", title, sourceName, "Pesan Global")
    
    -- Menggunakan Server API untuk broadcast pesan sistem ke semua pemain (metode terbaik)
    for _, player in ipairs(Players:GetPlayers()) do
        player:SendSystemMessage(message) -- Contoh API yang umum
        
        -- Alternatif menggunakan SetCore (Biasanya klien) - HANYA jika SendSystemMessage gagal:
        -- player.PlayerGui:SetCore("ChatMakeSystemMessage", {
        --     text = message,
        --     color = color
        -- })
    end
    warn("[GLOBAL MESSAGE]: " .. message)
end

-- === 3. Title Injector yang Dapat Dipicu Server/Client ===

-- Fungsi utama untuk memproses permintaan
local function processTitleInjection(player, payload)
    local title = payload.Title or "ANNOUNCEMENT"
    local colorRGB = payload.ColorRGB or Color3.new(1, 1, 1) -- Putih default
    local action = payload.Action or "Broadcast" -- Broadcast / CreateTag / RemoveTag

    if action == "Broadcast" then
        -- Kirim pesan ke semua pemain di kotak chat
        broadcastGlobalMessage(title, player.Name, colorRGB)
        
    elseif action == "CreateTag" then
        -- Terapkan tag ke pemain tertentu atau semua pemain
        local target = payload.Target or player.Name -- Bisa berupa "ALL_PLAYERS" atau nama pemain
        
        if target == "ALL_PLAYERS" then
            for _, p in ipairs(Players:GetPlayers()) do
                linkTagToCharacter(p, title, colorRGB)
            end
            warn(string.format("[GLOBAL TAG]: Tag '%s' diterapkan ke SEMUA pemain oleh %s.", title, player.Name))
        else
            local targetPlayer = Players:FindFirstChild(target)
            if targetPlayer then
                linkTagToCharacter(targetPlayer, title, colorRGB)
                warn(string.format("[GLOBAL TAG]: Tag '%s' diterapkan ke %s oleh %s.", title, target, player.Name))
            else
                warn("[ERROR]: Target pemain untuk tag tidak ditemukan: " .. target)
            end
        end
        
    elseif action == "RemoveTag" then
        -- Hapus tag dari pemain tertentu atau semua pemain
        local target = payload.Target or player.Name
        
        if target == "ALL_PLAYERS" then
            for _, p in ipairs(Players:GetPlayers()) do
                removePlayerTag(p)
            end
            warn(string.format("[GLOBAL TAG]: Tag dihapus dari SEMUA pemain oleh %s.", player.Name))
        else
            local targetPlayer = Players:FindFirstChild(target)
            if targetPlayer then
                removePlayerTag(targetPlayer)
                warn(string.format("[GLOBAL TAG]: Tag dihapus dari %s oleh %s.", target, player.Name))
            else
                warn("[ERROR]: Target pemain untuk penghapusan tag tidak ditemukan: " .. target)
            end
        end
    end
end

-- === 4. Implementasi Pemicu Server (Opsional: Dari Klien) ===

local InjectRemote = ReplicatedStorage:FindFirstChild(CLIENT_INJECT_REMOTE_NAME)
if not InjectRemote then
    -- Buat RemoteEvent agar klien dapat memicu fungsi ini
    InjectRemote = Instance.new("RemoteEvent")
    InjectRemote.Name = CLIENT_INJECT_REMOTE_NAME
    InjectRemote.Parent = ReplicatedStorage
    warn(string.format("RemoteEvent '%s' dibuat di ReplicatedStorage.", CLIENT_INJECT_REMOTE_NAME))
end

-- Dengarkan event yang masuk dari klien
InjectRemote.OnServerEvent:Connect(function(player, payload)
    -- Asumsi: Payload adalah table yang berisi {Title, ColorRGB, Action, Target, dll.}
    if type(payload) == "table" and payload.Title then
        processTitleInjection(player, payload)
    else
        warn(string.format("INJEKSI DITOLAK: Payload tidak valid dari %s.", player.Name))
    end
end)


-- === 5. Auto-Run untuk Admin yang Ditentukan (PlayerAdded) ===
Players.PlayerAdded:Connect(function(player)
    -- 5.1. Auto-Tag Admin
    local isAdmin = false
    for _, adminName in ipairs(ADMIN_USERS) do
        if player.Name:lower() == adminName:lower() then
            isAdmin = true
            break
        end
    end

    if isAdmin then
        -- Secara otomatis beri tag Admin Merah
        linkTagToCharacter(player, "ADMIN", Color3.new(1, 0, 0))
    end
end)

-- Pastikan tag diterapkan saat skrip dimulai (untuk pemain yang sudah ada)
for _, player in ipairs(Players:GetPlayers()) do
    local isAdmin = false
    for _, adminName in ipairs(ADMIN_USERS) do
        if player.Name:lower() == adminName:lower() then
            isAdmin = true
            break
        end
    end

    if isAdmin then
        linkTagToCharacter(player, "ADMIN", Color3.new(1, 0, 0))
    end
end

warn("✅ Global Title and Tag Injector (SERVER-SIDE) Berhasil Dimuat.")
