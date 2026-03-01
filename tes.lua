local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

-- Cek jika pencarian otomatis sedang berjalan dari server sebelumnya
if _G.SearchingFor == nil then
    _G.SearchingFor = ""
end

-- GUI SETUP (Premium Edition)
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local StatusLabel = Instance.new("TextLabel")
local TargetInput = Instance.new("TextBox")
local StartBtn = Instance.new("TextButton")

ScreenGui.Parent = game:GetService("CoreGui")
MainFrame.Size = UDim2.new(0, 240, 0, 190)
MainFrame.Position = UDim2.new(0.5, -120, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- Rainbow Border
local Border = Instance.new("Frame")
Border.Size = UDim2.new(1, 4, 1, 4)
Border.Position = UDim2.new(0, -2, 0, -2)
Border.ZIndex = 0
Border.BackgroundColor3 = Color3.fromHSV(0, 1, 1)
Border.Parent = MainFrame
Instance.new("UICorner", Border).CornerRadius = UDim.new(0, 10)

task.spawn(function()
    while true do
        for i = 0, 1, 0.01 do
            Border.BackgroundColor3 = Color3.fromHSV(i, 1, 1)
            task.wait(0.03)
        end
    end
end)

Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "👤 USERNAME HUNTER"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.Parent = MainFrame

TargetInput.Size = UDim2.new(0.85, 0, 0, 35)
TargetInput.Position = UDim2.new(0.075, 0, 0.3, 0)
TargetInput.PlaceholderText = "Ketik Username..."
TargetInput.Text = _G.SearchingFor
TargetInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TargetInput.TextColor3 = Color3.fromRGB(255, 255, 255)
TargetInput.Parent = MainFrame
Instance.new("UICorner", TargetInput)

StatusLabel.Size = UDim2.new(1, 0, 0, 30)
StatusLabel.Position = UDim2.new(0, 0, 0.55, 0)
StatusLabel.Text = "Status: Idle"
StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Parent = MainFrame

StartBtn.Size = UDim2.new(0.85, 0, 0, 40)
StartBtn.Position = UDim2.new(0.075, 0, 0.75, 0)
StartBtn.Text = "CARI & AUTO HOP"
StartBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
StartBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StartBtn.Font = Enum.Font.SourceSansBold
StartBtn.Parent = MainFrame
Instance.new("UICorner", StartBtn)

-- Fungsi Teleport ke Server Acak
local function ServerHop()
    StatusLabel.Text = "Mencari server baru..."
    local success, result = pcall(function()
        return game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
    end)
    
    if success then
        local data = HttpService:JSONDecode(result).data
        local possibleServers = {}
        for _, server in ipairs(data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                table.insert(possibleServers, server.id)
            end
        end
        
        if #possibleServers > 0 then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, possibleServers[math.random(1, #possibleServers)])
        else
            StatusLabel.Text = "Tidak ada server kosong."
        end
    else
        StatusLabel.Text = "Gagal memuat API server."
    end
end

-- Logika Utama
local function ExecuteHunter()
    local name = TargetInput.Text
    if name == "" then return end
    
    _G.SearchingFor = name
    StatusLabel.Text = "Mengecek server saat ini..."
    task.wait(1)
    
    local targetFound = false
    for _, player in pairs(Players:GetPlayers()) do
        if player.Name:lower() == name:lower() then
            targetFound = true
            break
        end
    end
    
    if targetFound then
        StatusLabel.Text = "✅ " .. name .. " DITEMUKAN!"
        StartBtn.Text = "DITEMUKAN"
        StartBtn.BackgroundColor3 = Color3.fromRGB(34, 139, 34)
        _G.SearchingFor = "" -- Reset setelah ketemu
    else
        StatusLabel.Text = "❌ Tidak ada. Hop server..."
        task.wait(2)
        ServerHop()
    end
end

StartBtn.MouseButton1Click:Connect(ExecuteHunter)

-- Jika skrip dijalankan ulang (karena teleport), otomatis lanjut cari
if _G.SearchingFor ~= "" then
    task.spawn(ExecuteHunter)
end
