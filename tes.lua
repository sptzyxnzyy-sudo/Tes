local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

if CoreGui:FindFirstChild("SptzyyToolboxFinal") then 
    CoreGui.SptzyyToolboxFinal:Destroy() 
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SptzyyToolboxFinal"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- Variabel Logika Scrolling
local currentCursor = ""
local isFetching = false
local currentKeyword = ""

-- ==========================================
-- OPEN BUTTON (Icon Store)
-- ==========================================
local OpenBtn = Instance.new("ImageButton")
OpenBtn.Size = UDim2.new(0, 45, 0, 45)
OpenBtn.Position = UDim2.new(0, 10, 0.5, -22)
OpenBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
OpenBtn.Image = "rbxassetid://10734950309"
OpenBtn.Visible = false
OpenBtn.Active = true
OpenBtn.Draggable = true
OpenBtn.Parent = ScreenGui
local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(0, 10)
OpenCorner.Parent = OpenBtn

-- ==========================================
-- MAIN FRAME
-- ==========================================
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 300, 0, 300)
Main.Position = UDim2.new(0.5, -150, 0.5, -150)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local function addCorner(obj, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 4)
    c.Parent = obj
end
addCorner(Main, 8)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.Text = "×"
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 25
CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -60, 0, 25)
Title.Position = UDim2.new(0, 10, 0, 5)
Title.Text = "SEARCH TOOLBOX"
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.Parent = Main

local Credit = Instance.new("TextLabel")
Credit.Size = UDim2.new(1, -60, 0, 15)
Credit.Position = UDim2.new(0, 10, 0, 22)
Credit.Text = "by @sptzyy"
Credit.Font = Enum.Font.SourceSans
Credit.TextSize = 11
Credit.TextColor3 = Color3.fromRGB(150, 150, 150)
Credit.TextXAlignment = Enum.TextXAlignment.Left
Credit.BackgroundTransparency = 1
Credit.Parent = Main

local Input = Instance.new("TextBox")
Input.Size = UDim2.new(1, -20, 0, 25)
Input.Position = UDim2.new(0, 10, 0, 45)
Input.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Input.PlaceholderText = "Cari asset..."
Input.Text = ""
Input.TextColor3 = Color3.fromRGB(255, 255, 255)
Input.Font = Enum.Font.SourceSans
Input.TextSize = 13
Input.ClearTextOnFocus = false
Input.Parent = Main
addCorner(Input, 4)

local ListPage = Instance.new("ScrollingFrame")
ListPage.Size = UDim2.new(1, -10, 1, -85)
ListPage.Position = UDim2.new(0, 5, 0, 80)
ListPage.BackgroundTransparency = 1
ListPage.ScrollBarThickness = 2
ListPage.Parent = Main

local Grid = Instance.new("UIGridLayout")
Grid.CellSize = UDim2.new(0, 92, 0, 110)
Grid.CellPadding = UDim2.new(0, 3, 0, 5)
Grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
Grid.Parent = ListPage

local WelcomeMsg = Instance.new("TextLabel")
WelcomeMsg.Size = UDim2.new(1, -20, 1, 0)
WelcomeMsg.Position = UDim2.new(0, 10, 0, 0)
WelcomeMsg.Text = "Gunakan scroll untuk melihat semua hasil."
WelcomeMsg.Font = Enum.Font.SourceSansItalic
WelcomeMsg.TextSize = 14
WelcomeMsg.TextColor3 = Color3.fromRGB(100, 100, 100)
WelcomeMsg.TextWrapped = true
WelcomeMsg.BackgroundTransparency = 1
WelcomeMsg.Parent = ListPage

-- ==========================================
-- DETAIL PAGE & LOGIC
-- ==========================================
local DetailPage = Instance.new("Frame")
DetailPage.Size = UDim2.new(1, 0, 1, -40)
DetailPage.Position = UDim2.new(0, 0, 0, 40)
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
DetName.TextSize = 16
DetName.TextColor3 = Color3.fromRGB(255, 255, 255)
DetName.TextWrapped = true
DetName.BackgroundTransparency = 1
DetName.Parent = DetailPage

local DetCreator = Instance.new("TextLabel")
DetCreator.Size = UDim2.new(0, 160, 0, 20)
DetCreator.Position = UDim2.new(0, 20, 0, 180)
DetCreator.TextSize = 13
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
Dropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
Dropdown.Visible = false
Dropdown.Parent = DetailPage
addCorner(Dropdown, 4)

-- Logic Functions
local currentAssetId = ""

local function httpRequest(opt)
    local f = (syn and syn.request) or (http and http.request) or http_request or request
    return f(opt)
end

local function renderItems(dataList)
    for _, data in pairs(dataList) do
        local Card = Instance.new("Frame")
        Card.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        Card.Parent = ListPage
        addCorner(Card, 6)
        
        local Img = Instance.new("ImageLabel")
        Img.Size = UDim2.new(1, -10, 0, 70)
        Img.Position = UDim2.new(0, 5, 0, 5)
        Img.Image = "rbxthumb://type=Asset&id="..data.asset.id.."&w=150&h=150"
        Img.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        Img.Parent = Card
        addCorner(Img, 4)
        
        local Info = Instance.new("TextLabel")
        Info.Size = UDim2.new(1, -6, 0, 30)
        Info.Position = UDim2.new(0, 3, 0, 78)
        Info.Text = data.asset.name .. "\nID: " .. data.asset.id
        Info.TextColor3 = Color3.fromRGB(255, 255, 255)
        Info.TextSize = 9
        Info.Font = Enum.Font.SourceSansBold
        Info.TextWrapped = true
        Info.BackgroundTransparency = 1
        Info.Parent = Card
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.Parent = Card
        btn.MouseButton1Click:Connect(function()
            currentAssetId = tostring(data.asset.id)
            DetImg.Image = "rbxthumb://type=Asset&id="..currentAssetId.."&w=420&h=420"
            DetName.Text = data.asset.name
            DetCreator.Text = "by " .. data.creator.name
            Dropdown.Visible = false
            ListPage.Visible = false
            Title.Visible = false
            Credit.Visible = false
            Input.Visible = false
            DetailPage.Visible = true
        end)
    end
    ListPage.CanvasSize = UDim2.new(0,0,0,Grid.AbsoluteContentSize.Y + 10)
end

local function ExecuteSearch(kw, cursor)
    if isFetching then return end
    isFetching = true
    
    local url = "https://apis.roblox.com/toolbox-service/v1/marketplace/10?limit=30&keyword="..HttpService:UrlEncode(kw)
    if cursor and cursor ~= "" then
        url = url .. "&cursor=" .. cursor
    end
    
    local res = httpRequest({Url = url, Method = "GET"})
    if res and res.StatusCode == 200 then
        local body = HttpService:JSONDecode(res.Body)
        currentCursor = body.nextPageCursor or "" -- Simpan cursor untuk halaman selanjutnya
        
        local ids = {}
        for _, v in pairs(body.data) do table.insert(ids, tostring(v.id)) end
        
        if #ids > 0 then
            local detRes = httpRequest({Url = "https://apis.roblox.com/toolbox-service/v1/items/details?assetIds="..table.concat(ids, ","), Method = "GET"})
            if detRes and detRes.StatusCode == 200 then
                renderItems(HttpService:JSONDecode(detRes.Body).data)
            end
        end
    end
    isFetching = false
end

-- Detection Scroll sampai bawah
ListPage:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
    local pos = ListPage.CanvasPosition.Y
    local size = ListPage.AbsoluteWindowSize.Y
    local total = ListPage.CanvasSize.Y.Offset
    
    -- Jika sisa scroll tinggal sedikit (50px), load data baru
    if pos + size >= total - 50 and currentCursor ~= "" and not isFetching then
        ExecuteSearch(currentKeyword, currentCursor)
    end
end)

Input.FocusLost:Connect(function(enter)
    if enter then
        currentKeyword = Input.Text
        currentCursor = "" -- Reset cursor untuk pencarian baru
        for _, v in pairs(ListPage:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
        WelcomeMsg.Visible = false
        ExecuteSearch(currentKeyword, "")
    end
end)

-- UI Toggle
CloseBtn.MouseButton1Click:Connect(function() Main.Visible = false OpenBtn.Visible = true end)
OpenBtn.MouseButton1Click:Connect(function() Main.Visible = true OpenBtn.Visible = false end)
BackBtn.MouseButton1Click:Connect(function() DetailPage.Visible = false Title.Visible = true Credit.Visible = true Input.Visible = true ListPage.Visible = true end)
MenuBtn.MouseButton1Click:Connect(function() Dropdown.Visible = not Dropdown.Visible end)
Dropdown.MouseButton1Click:Connect(function() setclipboard(currentAssetId) Dropdown.Text = "Copied!" task.wait(1) Dropdown.Text = "Copy ID" Dropdown.Visible = false end)
