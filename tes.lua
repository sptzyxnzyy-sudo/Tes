local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Global variable untuk auto-run setelah teleport
if _G.SearchingFor == nil then
    _G.SearchingFor = ""
end

-- GUI CONTAINER
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "IkyyHunter_V3"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

-- MAIN FRAME (PERSEGI RAPI)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -110, 0.4, 0)
MainFrame.Size = UDim2.new(0, 220, 0, 260) -- Persegi panjang proporsional
MainFrame.Active = true
MainFrame.Draggable = true -- Fitur Geser

-- RAINBOW BORDER EFFECT
local Border = Instance.new("Frame")
Border.Name = "Border"
Border.Parent = MainFrame
Border.BackgroundColor3 = Color3.fromHSV(0, 1, 1)
Border.BorderSizePixel = 0
Border.Position = UDim2.new(0, -2, 0, -2)
Border.Size = UDim2.new(1, 4, 1, 4)
Border.ZIndex = 0

local UICorner_B = Instance.new("UICorner")
UICorner_B.CornerRadius = UDim.new(0, 4)
UICorner_B.Parent = Border

local UICorner_M = Instance.new("UICorner")
UICorner_M.CornerRadius = UDim.new(0, 4)
UICorner_M.Parent = MainFrame

-- PROFILE SECTION
local AvatarImg = Instance.new("ImageLabel")
AvatarImg.Size = UDim2.new(0, 40, 0, 40)
AvatarImg.Position = UDim2.new(0.5, -20, 0, 15)
AvatarImg.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. LocalPlayer.UserId .. "&width=420&height=420&format=png"
AvatarImg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
AvatarImg.Parent = MainFrame

local UICorner_A = Instance.new("UICorner")
UICorner_A.CornerRadius = UDim.new(1, 0)
UICorner_A.Parent = AvatarImg

-- TITLE
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Position = UDim2.new(0, 0, 0, 60)
Title.Text = "USERNAME HUNTER"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16
Title.Parent = MainFrame

-- INPUT BOX
local TargetInput = Instance.new("TextBox")
TargetInput.Size = UDim2.new(0.85, 0, 0, 35)
TargetInput.Position = UDim2.new(0.075, 0, 0.4, 0)
TargetInput.PlaceholderText = "Input Username..."
TargetInput.Text = _G.SearchingFor
TargetInput.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TargetInput.TextColor3 = Color3.fromRGB(255, 255, 255)
TargetInput.Font = Enum.Font.SourceSans
TargetInput.TextSize = 14
TargetInput.Parent = MainFrame
Instance.new("UICorner", TargetInput).CornerRadius = UDim.new(0, 4)

-- STATUS LABEL
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 30)
StatusLabel.Position = UDim2.new(0, 0, 0.55, 0)
StatusLabel.Text = "Status: Idle"
StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Font = Enum.Font.SourceSansItalic
StatusLabel.TextSize = 14
StatusLabel.Parent = MainFrame

-- START BUTTON
local StartBtn = Instance.new("TextButton")
StartBtn.Size = UDim2.new(0.85, 0, 0, 40)
StartBtn.Position = UDim2.new(0.075, 0, 0.75, 0)
StartBtn.Text = "START HUNTING"
StartBtn.BackgroundColor3 = Color3.fromRGB(0, 102, 204)
StartBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StartBtn.Font = Enum.Font.SourceSansBold
StartBtn.TextSize = 16
StartBtn.Parent = MainFrame
Instance.new("UICorner", StartBtn).CornerRadius = UDim.new(0, 4)

-- ANIMASI RAINBOW BORDER
task.spawn(function()
    while true do
        for i = 0, 1, 0.01 do
            Border.BackgroundColor3 = Color3.fromHSV(i, 1, 1)
            task.wait(0.03)
        end
    end
end)

-- FUNGSI SERVER HOP
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
            StatusLabel.Text = "Tidak ada server tersedia."
        end
    else
        StatusLabel.Text = "Gagal memuat API server."
    end
end

-- LOGIKA UTAMA
local function ExecuteHunter()
    local name = TargetInput.Text
    if name == "" then 
        StatusLabel.Text = "Status: Masukkan nama!"
        return 
    end
    
    _G.SearchingFor = name
    StatusLabel.Text = "Mengecek player..."
    task.wait(1)
    
    local targetFound = false
    for _, player in pairs(Players:GetPlayers()) do
        if player.Name:lower() == name:lower() then
            targetFound = true
            break
        end
    end
    
    if targetFound then
        StatusLabel.Text = "✅ TARGET DITEMUKAN!"
        StartBtn.Text = "FOUND"
        StartBtn.BackgroundColor3 = Color3.fromRGB(34, 139, 34)
        _G.SearchingFor = "" -- Berhenti jika sudah ketemu
    else
        StatusLabel.Text = "❌ Tidak ada. Pindah server..."
        task.wait(2)
        ServerHop()
    end
end

StartBtn.MouseButton1Click:Connect(ExecuteHunter)

-- AUTO-RESTART SETELAH TELEPORT
if _G.SearchingFor ~= "" then
    task.spawn(ExecuteHunter)
end
