local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- LOGIKA VERIFIKASI (BARU)
-- ==========================================
local isVerified = false
local adminWhatsApp = "6281234567890" -- GANTI DENGAN NOMOR ANDA

local function checkUserVerification()
    local success, result = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/sptzydev1/lisen/refs/heads/main/verif.json")
    end)
    
    if success then
        local myId = tostring(LocalPlayer.UserId)
        local lines = result:split("\n")
        
        for _, line in pairs(lines) do
            local cleanLine = line:gsub("%s+", "") -- Hapus spasi/new line
            if cleanLine == "" then continue end
            
            local data = cleanLine:split(",")
            local targetId = data[1]
            
            if targetId == myId then
                isVerified = true
                break
            end
        end
    end
    return isVerified
end

-- Jalankan pengecekan
checkUserVerification()

-- Membersihkan UI lama jika ada
if CoreGui:FindFirstChild("SptzyyToolboxFinal") then 
    CoreGui.SptzyyToolboxFinal:Destroy() 
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SptzyyToolboxFinal"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- State Management (Logika Halaman & Data)
local cursors = { [1] = "" } 
local currentPage = 1
local currentKeyword = ""
local isFetching = false
local currentId = ""
local searchMode = "10" 

local function addCorner(obj, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 4)
    c.Parent = obj
end

-- ==========================================
-- OPEN BUTTON
-- ==========================================
local OpenBtn = Instance.new("ImageButton")
OpenBtn.Name = "OpenButton"
OpenBtn.Size = UDim2.new(0, 45, 0, 45)
OpenBtn.Position = UDim2.new(0, 10, 0.5, -22)
OpenBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
OpenBtn.Image = "rbxassetid://10734950309"
OpenBtn.Visible = false
OpenBtn.Active = true
OpenBtn.Draggable = true
OpenBtn.Parent = ScreenGui
addCorner(OpenBtn, 10)

-- ==========================================
-- MAIN FRAME
-- ==========================================
local Main = Instance.new("Frame")
Main.Name = "MainFrame"
Main.Size = UDim2.new(0, 300, 0, 300)
Main.Position = UDim2.new(0.5, -150, 0.5, -150)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui
addCorner(Main, 8)

-- ==========================================
-- LOGIKA LOCK GUI (BARU)
-- ==========================================
if not isVerified then
    local LockOverlay = Instance.new("Frame")
    LockOverlay.Name = "LockOverlay"
    LockOverlay.Size = UDim2.new(1, 0, 1, 0)
    LockOverlay.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    LockOverlay.BackgroundTransparency = 0.3
    LockOverlay.ZIndex = 100
    LockOverlay.Parent = Main
    addCorner(LockOverlay, 8)

    local LockIcon = Instance.new("ImageButton")
    LockIcon.Size = UDim2.new(0, 80, 0, 80)
    LockIcon.Position = UDim2.new(0.5, -40, 0.5, -50)
    LockIcon.BackgroundTransparency = 1
    LockIcon.Image = "rbxassetid://6031081537" -- Icon Gembok
    LockIcon.ZIndex = 101
    LockIcon.Parent = LockOverlay

    local LockMsg = Instance.new("TextLabel")
    LockMsg.Size = UDim2.new(1, -20, 0, 40)
    LockMsg.Position = UDim2.new(0, 10, 0.5, 30)
    LockMsg.Text = "KLIK GEMBOK UNTUK VERIFIKASI\nID: "..LocalPlayer.UserId
    LockMsg.TextColor3 = Color3.fromRGB(255, 255, 255)
    LockMsg.Font = Enum.Font.SourceSansBold
    LockMsg.TextSize = 14
    LockMsg.BackgroundTransparency = 1
    LockMsg.ZIndex = 101
    LockMsg.Parent = LockOverlay

    LockIcon.MouseButton1Click:Connect(function()
        setclipboard(tostring(LocalPlayer.UserId))
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "ID Disalin!",
            Text = "Kirim ID ke WhatsApp Admin.",
            Duration = 5
        })
        -- Catatan: Membuka browser langsung sering diblokir roblox, jadi user diarahkan manual lewat notif/pesan
        print("Kirim ID ke Admin WA: " .. adminWhatsApp)
    end)
end

-- Tombol Close (X)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -30, 0, 5)
CloseBtn.Text = "×"
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 20
CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseBtn.BackgroundTransparency = 1
CloseBtn.ZIndex = 105 -- Diatas Lock
CloseBtn.Parent = Main

-- ==========================================
-- CENTERED HEADER
-- ==========================================
local HeaderContainer = Instance.new("Frame")
HeaderContainer.Size = UDim2.new(1, 0, 0, 60)
HeaderContainer.BackgroundTransparency = 1
HeaderContainer.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 25)
Title.Position = UDim2.new(0, 0, 0, 10)
Title.Text = "SEARCH TOOLBOX"
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Center
Title.BackgroundTransparency = 1
Title.Parent = HeaderContainer

local Credit = Instance.new("TextLabel")
Credit.Size = UDim2.new(1, 0, 0, 15)
Credit.Position = UDim2.new(0, 0, 0, 30)
Credit.Text = "by @sptzyy"
Credit.Font = Enum.Font.SourceSans
Credit.TextSize = 13
Credit.TextColor3 = Color3.fromRGB(180, 180, 180)
Credit.TextXAlignment = Enum.TextXAlignment.Center
Credit.BackgroundTransparency = 1
Credit.Parent = HeaderContainer

local Version = Instance.new("TextLabel")
Version.Size = UDim2.new(1, 0, 0, 10)
Version.Position = UDim2.new(0, 0, 0, 45)
Version.Text = "version 1.2 (Multi-Mode)"
Version.Font = Enum.Font.SourceSans
Version.TextSize = 10
Version.TextColor3 = Color3.fromRGB(100, 100, 100)
Version.TextXAlignment = Enum.TextXAlignment.Center
Version.BackgroundTransparency = 1
Version.Parent = HeaderContainer

-- ==========================================
-- SYMMETRICAL INPUT
-- ==========================================
local PrevBtn = Instance.new("TextButton")
PrevBtn.Size = UDim2.new(0, 25, 0, 25)
PrevBtn.Position = UDim2.new(0, 10, 0, 65)
PrevBtn.Text = "<"
PrevBtn.Font = Enum.Font.SourceSansBold
PrevBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PrevBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
PrevBtn.Visible = false
PrevBtn.Parent = Main
addCorner(PrevBtn)

local Input = Instance.new("TextBox")
Input.Size = UDim2.new(0, 180, 0, 25)
Input.Position = UDim2.new(0, 45, 0, 65)
Input.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Input.PlaceholderText = "Cari asset..."
Input.Text = ""
Input.TextColor3 = Color3.fromRGB(255, 255, 255)
Input.Font = Enum.Font.SourceSans
Input.TextSize = 13
Input.ClearTextOnFocus = false
Input.Parent = Main
addCorner(Input, 4)

local ModeBtn = Instance.new("ImageButton")
ModeBtn.Size = UDim2.new(0, 25, 0, 25)
ModeBtn.Position = UDim2.new(0, 230, 0, 65)
ModeBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
ModeBtn.Image = "rbxassetid://10734950309"
ModeBtn.Parent = Main
addCorner(ModeBtn)

local NextBtn = Instance.new("TextButton")
NextBtn.Size = UDim2.new(0, 25, 0, 25)
NextBtn.Position = UDim2.new(0, 265, 0, 65)
NextBtn.Text = ">"
NextBtn.Font = Enum.Font.SourceSansBold
NextBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
NextBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
NextBtn.Visible = false
NextBtn.Parent = Main
addCorner(NextBtn)

local PageIndicator = Instance.new("TextLabel")
PageIndicator.Size = UDim2.new(1, -20, 0, 15)
PageIndicator.Position = UDim2.new(0, 10, 0, 92)
PageIndicator.Text = "MODE: MODEL"
PageIndicator.TextColor3 = Color3.fromRGB(0, 170, 255)
PageIndicator.Font = Enum.Font.SourceSansBold
PageIndicator.TextSize = 10
PageIndicator.TextXAlignment = Enum.TextXAlignment.Center
PageIndicator.BackgroundTransparency = 1
PageIndicator.Parent = Main

-- ==========================================
-- LOGIC: SWITCH MODE
-- ==========================================
ModeBtn.MouseButton1Click:Connect(function()
    if searchMode == "10" then
        searchMode = "3"
        PageIndicator.Text = "MODE: AUDIO"
        PageIndicator.TextColor3 = Color3.fromRGB(255, 170, 0)
        ModeBtn.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
        ModeBtn.Image = "rbxassetid://10734951121"
    else
        searchMode = "10"
        PageIndicator.Text = "MODE: MODEL"
        PageIndicator.TextColor3 = Color3.fromRGB(0, 170, 255)
        ModeBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        ModeBtn.Image = "rbxassetid://10734950309"
    end
end)

-- ==========================================
-- LIST PAGE & GRID
-- ==========================================
local ListPage = Instance.new("ScrollingFrame")
ListPage.Size = UDim2.new(1, -10, 1, -120)
ListPage.Position = UDim2.new(0, 5, 0, 110)
ListPage.BackgroundTransparency = 1
ListPage.ScrollBarThickness = 2
ListPage.Parent = Main

local Grid = Instance.new("UIGridLayout")
Grid.CellSize = UDim2.new(0, 92, 0, 110)
Grid.CellPadding = UDim2.new(0, 3, 0, 5)
Grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
Grid.Parent = ListPage

local WelcomeMsg = Instance.new("TextLabel")
WelcomeMsg.Size = UDim2.new(1, -20, 0, 80)
WelcomeMsg.Position = UDim2.new(0, 10, 0.2, 0)
WelcomeMsg.Text = "Pilih mode (Model/Audio), ketik kata kunci, lalu tekan Enter."
WelcomeMsg.Font = Enum.Font.SourceSansItalic
WelcomeMsg.TextSize = 14
WelcomeMsg.TextColor3 = Color3.fromRGB(100, 100, 100)
WelcomeMsg.TextWrapped = true
WelcomeMsg.BackgroundTransparency = 1
WelcomeMsg.Parent = ListPage

-- ==========================================
-- DETAIL PAGE
-- ==========================================
local DetailPage = Instance.new("Frame")
DetailPage.Size = UDim2.new(1, 0, 1, -35)
DetailPage.Position = UDim2.new(0, 0, 0, 35)
DetailPage.BackgroundColor3 = Main.BackgroundColor3
DetailPage.Visible = false
DetailPage.Parent = Main
addCorner(DetailPage, 8)

local BackBtn = Instance.new("TextButton")
BackBtn.Size = UDim2.new(0, 30, 0, 30)
BackBtn.Position = UDim2.new(0, 5, 0, 5)
BackBtn.Text = "←"
BackBtn.Font = Enum.Font.SourceSansBold
BackBtn.TextSize = 25
BackBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
BackBtn.BackgroundTransparency = 1
BackBtn.Parent = DetailPage

local DetImg = Instance.new("ImageLabel")
DetImg.Size = UDim2.new(0, 120, 0, 120)
DetImg.Position = UDim2.new(0.5, -60, 0, 20)
DetImg.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
DetImg.Parent = DetailPage
addCorner(DetImg)

local DetName = Instance.new("TextLabel")
DetName.Size = UDim2.new(1, -40, 0, 35)
DetName.Position = UDim2.new(0, 20, 0, 145)
DetName.Font = Enum.Font.SourceSansBold
DetName.TextSize = 15
DetName.TextColor3 = Color3.fromRGB(255, 255, 255)
DetName.TextWrapped = true
DetName.BackgroundTransparency = 1
DetName.Parent = DetailPage

local DetCreator = Instance.new("TextLabel")
DetCreator.Size = UDim2.new(0, 160, 0, 20)
DetCreator.Position = UDim2.new(0, 20, 0, 180)
DetCreator.TextSize = 12
DetCreator.TextColor3 = Color3.fromRGB(180, 180, 180)
DetCreator.TextXAlignment = Enum.TextXAlignment.Left
DetCreator.BackgroundTransparency = 1
DetCreator.Parent = DetailPage

local MenuBtn = Instance.new("TextButton")
MenuBtn.Size = UDim2.new(0, 25, 0, 25)
MenuBtn.Position = UDim2.new(1, -40, 0, 178)
MenuBtn.Text = "≡"
MenuBtn.Font = Enum.Font.SourceSansBold
MenuBtn.TextSize = 22
MenuBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
MenuBtn.BackgroundTransparency = 1
MenuBtn.Parent = DetailPage

local Dropdown = Instance.new("TextButton")
Dropdown.Size = UDim2.new(0, 80, 0, 25)
Dropdown.Position = UDim2.new(1, -90, 0, 205)
Dropdown.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Dropdown.Text = "Copy ID"
Dropdown.Font = Enum.Font.SourceSans
Dropdown.TextSize = 13
Dropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
Dropdown.Visible = false
Dropdown.ZIndex = 10
Dropdown.Parent = DetailPage
addCorner(Dropdown, 4)

-- ==========================================
-- API & SEARCH LOGIC
-- ==========================================
local function httpRequest(opt)
    local f = (syn and syn.request) or (http and http.request) or http_request or request
    return f(opt)
end

local function clearList()
    for _, v in pairs(ListPage:GetChildren()) do
        if v:IsA("Frame") then v:Destroy() end
    end
end

local function showDetail(data)
    currentId = tostring(data.asset.id)
    if searchMode == "3" then
        DetImg.Image = "rbxassetid://10734951121"
    else
        DetImg.Image = "rbxthumb://type=Asset&id="..currentId.."&w=420&h=420"
    end
    
    DetName.Text = data.asset.name
    DetCreator.Text = "by " .. (data.creator and data.creator.name or "Unknown")
    
    Dropdown.Visible = false
    ListPage.Visible = false
    HeaderContainer.Visible = false
    Input.Visible = false
    PrevBtn.Visible = false
    ModeBtn.Visible = false
    NextBtn.Visible = false
    PageIndicator.Visible = false
    DetailPage.Visible = true
end

local function Search(kw, cursor, pageNum)
    if isFetching or not isVerified then return end
    isFetching = true
    clearList()
    WelcomeMsg.Visible = false
    
    local url = "https://apis.roblox.com/toolbox-service/v1/marketplace/"..searchMode.."?limit=30&keyword="..HttpService:UrlEncode(kw)
    if cursor and cursor ~= "" then url = url.."&cursor="..cursor end
    
    local success, res = pcall(function() return httpRequest({Url = url, Method = "GET"}) end)
    
    if success and res and res.StatusCode == 200 then
        local body = HttpService:JSONDecode(res.Body)
        currentPage = pageNum
        cursors[currentPage + 1] = body.nextPageCursor or ""
        
        PrevBtn.Visible = (currentPage > 1)
        NextBtn.Visible = (body.nextPageCursor ~= nil and body.nextPageCursor ~= "")
        
        local labelMode = (searchMode == "10") and "MODELS" or "AUDIO"
        PageIndicator.Text = "MODE: "..labelMode.." | PAGE: "..currentPage
        PageIndicator.Visible = true

        local ids = {}
        for _, v in pairs(body.data) do table.insert(ids, tostring(v.id)) end
        
        if #ids == 0 then
            WelcomeMsg.Text = "Asset tidak ditemukan."
            WelcomeMsg.Visible = true
        else
            local detRes = httpRequest({Url = "https://apis.roblox.com/toolbox-service/v1/items/details?assetIds="..table.concat(ids, ","), Method = "GET"})
            if detRes and detRes.StatusCode == 200 then
                for _, data in pairs(HttpService:JSONDecode(detRes.Body).data) do
                    local Card = Instance.new("Frame")
                    Card.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                    Card.Parent = ListPage
                    addCorner(Card, 6)
                    
                    local Img = Instance.new("ImageLabel")
                    Img.Size = UDim2.new(1, -10, 0, 70)
                    Img.Position = UDim2.new(0, 5, 0, 5)
                    
                    if searchMode == "3" then
                        Img.Image = "rbxassetid://10734951121"
                    else
                        Img.Image = "rbxthumb://type=Asset&id="..data.asset.id.."&w=150&h=150"
                    end
                    
                    Img.BackgroundTransparency = 1
                    Img.Parent = Card
                    
                    local Info = Instance.new("TextLabel")
                    Info.Size = UDim2.new(1, -6, 0, 30)
                    Info.Position = UDim2.new(0, 3, 0, 78)
                    Info.Text = data.asset.name.."\nID: "..data.asset.id
                    Info.TextColor3 = Color3.fromRGB(255, 255, 255)
                    Info.TextSize = 8
                    Info.Font = Enum.Font.SourceSansBold
                    Info.TextWrapped = true
                    Info.BackgroundTransparency = 1
                    Info.Parent = Card
                    
                    local btn = Instance.new("TextButton")
                    btn.Size = UDim2.new(1, 0, 1, 0)
                    btn.BackgroundTransparency = 1
                    btn.Text = ""
                    btn.Parent = Card
                    btn.MouseButton1Click:Connect(function() showDetail(data) end)
                end
            end
        end
    end
    ListPage.CanvasPosition = Vector2.new(0,0)
    ListPage.CanvasSize = UDim2.new(0,0,0,Grid.AbsoluteContentSize.Y + 10)
    isFetching = false
end

-- ==========================================
-- BUTTON & INPUT CONNECTIONS
-- ==========================================
Input.FocusLost:Connect(function(enter)
    if enter and Input.Text ~= "" then
        currentKeyword = Input.Text
        cursors = { [1] = "" }
        Search(currentKeyword, "", 1)
    end
end)

NextBtn.MouseButton1Click:Connect(function()
    if not isFetching and cursors[currentPage + 1] ~= "" then
        Search(currentKeyword, cursors[currentPage + 1], currentPage + 1)
    end
end)

PrevBtn.MouseButton1Click:Connect(function()
    if not isFetching and currentPage > 1 then
        Search(currentKeyword, cursors[currentPage - 1], currentPage - 1)
    end
end)

CloseBtn.MouseButton1Click:Connect(function() Main.Visible = false OpenBtn.Visible = true end)
OpenBtn.MouseButton1Click:Connect(function() Main.Visible = true OpenBtn.Visible = false end)

BackBtn.MouseButton1Click:Connect(function()
    DetailPage.Visible = false
    HeaderContainer.Visible = true
    Input.Visible = true
    ModeBtn.Visible = true
    PrevBtn.Visible = (currentPage > 1)
    NextBtn.Visible = (cursors[currentPage+1] ~= "")
    PageIndicator.Visible = true
    ListPage.Visible = true
end)

MenuBtn.MouseButton1Click:Connect(function() Dropdown.Visible = not Dropdown.Visible end)
Dropdown.MouseButton1Click:Connect(function()
    setclipboard(currentId)
    Dropdown.Text = "Copied!"
    task.wait(1)
    Dropdown.Text = "Copy ID"
    Dropdown.Visible = false
end)
