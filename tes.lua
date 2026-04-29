local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

if CoreGui:FindFirstChild("SptzyyToolboxFinal") then 
    CoreGui.SptzyyToolboxFinal:Destroy() 
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SptzyyToolboxFinal"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- Variabel Logika Pagination
local cursors = { [1] = "" } -- Menyimpan cursor tiap halaman
local currentPage = 1
local currentKeyword = ""
local isFetching = false

-- ==========================================
-- MAIN FRAME & OPEN/CLOSE
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

-- ==========================================
-- HEADER & SEARCH INPUT
-- ==========================================
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

local Input = Instance.new("TextBox")
Input.Size = UDim2.new(1, -20, 0, 25)
Input.Position = UDim2.new(0, 10, 0, 45)
Input.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Input.PlaceholderText = "Cari asset..."
Input.TextColor3 = Color3.fromRGB(255, 255, 255)
Input.Font = Enum.Font.SourceSans
Input.TextSize = 13
Input.ClearTextOnFocus = false
Input.Parent = Main
addCorner(Input, 4)

-- ==========================================
-- PAGINATION NAV (Panah Kiri & Kanan)
-- ==========================================
local NavFrame = Instance.new("Frame")
NavFrame.Size = UDim2.new(1, -10, 0, 25)
NavFrame.Position = UDim2.new(0, 5, 0, 75)
NavFrame.BackgroundTransparency = 1
NavFrame.Visible = false
NavFrame.Parent = Main

local PrevBtn = Instance.new("TextButton")
PrevBtn.Size = UDim2.new(0, 25, 1, 0)
PrevBtn.Position = UDim2.new(0, 5, 0, 0)
PrevBtn.Text = " < "
PrevBtn.Font = Enum.Font.SourceSansBold
PrevBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PrevBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
PrevBtn.Parent = NavFrame
addCorner(PrevBtn)

local NextBtn = Instance.new("TextButton")
NextBtn.Size = UDim2.new(0, 25, 1, 0)
NextBtn.Position = UDim2.new(1, -30, 0, 0)
NextBtn.Text = " > "
NextBtn.Font = Enum.Font.SourceSansBold
NextBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
NextBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
NextBtn.Parent = NavFrame
addCorner(NextBtn)

local PageIndicator = Instance.new("TextLabel")
PageIndicator.Size = UDim2.new(1, -70, 1, 0)
PageIndicator.Position = UDim2.new(0, 35, 0, 0)
PageIndicator.Text = "Page 1"
PageIndicator.TextColor3 = Color3.fromRGB(200, 200, 200)
PageIndicator.Font = Enum.Font.SourceSans
PageIndicator.TextSize = 12
PageIndicator.BackgroundTransparency = 1
PageIndicator.Parent = NavFrame

-- ==========================================
-- LIST CONTAINER
-- ==========================================
local ListPage = Instance.new("ScrollingFrame")
ListPage.Size = UDim2.new(1, -10, 1, -110)
ListPage.Position = UDim2.new(0, 5, 0, 105)
ListPage.BackgroundTransparency = 1
ListPage.ScrollBarThickness = 2
ListPage.Parent = Main

local Grid = Instance.new("UIGridLayout")
Grid.CellSize = UDim2.new(0, 92, 0, 110)
Grid.CellPadding = UDim2.new(0, 3, 0, 5)
Grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
Grid.Parent = ListPage

-- ==========================================
-- LOGIC & API
-- ==========================================
local function httpRequest(opt)
    local f = (syn and syn.request) or (http and http.request) or http_request or request
    return f(opt)
end

local function renderItems(dataList)
    for _, v in pairs(ListPage:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
    for _, data in pairs(dataList) do
        local Card = Instance.new("Frame")
        Card.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        Card.Parent = ListPage
        addCorner(Card, 6)
        
        local Img = Instance.new("ImageLabel")
        Img.Size = UDim2.new(1, -10, 0, 70)
        Img.Position = UDim2.new(0, 5, 0, 5)
        Img.Image = "rbxthumb://type=Asset&id="..data.asset.id.."&w=150&h=150"
        Img.BackgroundTransparency = 1
        Img.Parent = Card
        
        local Info = Instance.new("TextLabel")
        Info.Size = UDim2.new(1, -6, 0, 30)
        Info.Position = UDim2.new(0, 3, 0, 78)
        Info.Text = data.asset.name.."\nID: "..data.asset.id
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
        btn.MouseButton1Click:Connect(function() setclipboard(tostring(data.asset.id)) end)
    end
    ListPage.CanvasPosition = Vector2.new(0,0)
    ListPage.CanvasSize = UDim2.new(0,0,0,Grid.AbsoluteContentSize.Y + 10)
end

local function Search(kw, cursor, pageNum)
    if isFetching then return end
    isFetching = true
    
    local url = "https://apis.roblox.com/toolbox-service/v1/marketplace/10?limit=30&keyword="..HttpService:UrlEncode(kw)
    if cursor and cursor ~= "" then url = url.."&cursor="..cursor end
    
    local res = httpRequest({Url = url, Method = "GET"})
    if res and res.StatusCode == 200 then
        local body = HttpService:JSONDecode(res.Body)
        
        -- Logika Page
        currentPage = pageNum
        cursors[currentPage + 1] = body.nextPageCursor or ""
        
        -- Update Navigasi
        NavFrame.Visible = true
        PageIndicator.Text = "Page "..currentPage.." / Total Results: "..(body.totalResults or "...")
        PrevBtn.Visible = (currentPage > 1)
        NextBtn.Visible = (body.nextPageCursor ~= nil and body.nextPageCursor ~= "")

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

-- Event Tombol Navigasi
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

Input.FocusLost:Connect(function(enter)
    if enter and Input.Text ~= "" then
        currentKeyword = Input.Text
        cursors = { [1] = "" } -- Reset cursors
        Search(currentKeyword, "", 1)
    end
end)

-- Toggle UI
CloseBtn.MouseButton1Click:Connect(function() Main.Visible = false OpenBtn.Visible = true end)
OpenBtn.MouseButton1Click:Connect(function() Main.Visible = true OpenBtn.Visible = false end)
