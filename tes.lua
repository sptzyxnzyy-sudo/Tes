local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

-- Fungsi Notifikasi Resmi
local function sendRobloxNotif(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title;
            Text = text;
            Icon = "rbxassetid://6023454774";
            Duration = 3;
        })
    end)
end

-- Pembersihan UI lama
if LocalPlayer.PlayerGui:FindFirstChild("SptzyConsoleSys") then
    LocalPlayer.PlayerGui.SptzyConsoleSys:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SptzyConsoleSys"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer.PlayerGui

local isProcessing = false

---------------------------------------
-- 1. UI PROFILE & LOG CONSOLE
---------------------------------------
local function createMainUI()
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 280, 0, 250) -- Ukuran lebih besar untuk console
    mainFrame.Position = UDim2.new(1, -20, 0, 40)
    mainFrame.AnchorPoint = Vector2.new(1, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui

    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)
    local stroke = Instance.new("UIStroke", mainFrame)
    stroke.Thickness = 2

    -- RAINBOW TITLE: SPTZY
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = "SPTZY"
    titleLabel.Position = UDim2.new(0, 15, 0, 10)
    titleLabel.Size = UDim2.new(0, 100, 0, 30)
    titleLabel.Font = Enum.Font.GothamBlack
    titleLabel.TextSize = 24
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = mainFrame

    -- Logika Rainbow Effect
    task.spawn(function()
        local hue = 0
        while true do
            hue = hue + 0.01
            if hue > 1 then hue = 0 end
            local color = Color3.fromHSV(hue, 0.8, 1)
            titleLabel.TextColor3 = color
            stroke.Color = color
            task.wait()
        end
    end)

    -- EXECUTION CONSOLE (Scrolling Frame)
    local consoleFrame = Instance.new("ScrollingFrame")
    consoleFrame.Name = "Console"
    consoleFrame.Position = UDim2.new(0, 10, 0, 50)
    consoleFrame.Size = UDim2.new(1, -20, 0, 140)
    consoleFrame.BackgroundTransparency = 0.9
    consoleFrame.BackgroundColor3 = Color3.new(0,0,0)
    consoleFrame.ScrollBarThickness = 2
    consoleFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    consoleFrame.Parent = mainFrame

    local layout = Instance.new("UIListLayout", consoleFrame)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 2)

    -- TOGGLE BUTTON
    local btn = Instance.new("TextButton")
    btn.Name = "ToggleButton"
    btn.Position = UDim2.new(0, 10, 0, 200)
    btn.Size = UDim2.new(1, -20, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.Font = Enum.Font.GothamBold
    btn.Text = "START SELF-EXECUTION"
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextSize = 14
    btn.Parent = mainFrame
    Instance.new("UICorner", btn)

    return btn, consoleFrame
end

local toggleBtn, console = createMainUI()

---------------------------------------
-- 2. LOGGING FUNCTION
---------------------------------------
local function addLog(text)
    local log = Instance.new("TextLabel")
    log.Text = "> " .. text
    log.Size = UDim2.new(1, 0, 0, 18)
    log.BackgroundTransparency = 1
    log.TextColor3 = Color3.fromRGB(0, 255, 150)
    log.Font = Enum.Font.Code
    log.TextSize = 10
    log.TextXAlignment = Enum.TextXAlignment.Left
    log.Parent = console
    
    -- Auto scroll ke bawah
    console.CanvasSize = UDim2.new(0, 0, 0, layout and layout.AbsoluteContentSize.Y or 500)
    console.CanvasPosition = Vector2.new(0, 9999)
    
    -- Hapus log lama agar tidak berat
    if #console:GetChildren() > 30 then
        console:GetChildren()[2]:Destroy()
    end
end

---------------------------------------
-- 3. SELF-EXECUTION LOOP
---------------------------------------
local function startExecution()
    task.spawn(function()
        while isProcessing do
            for _, obj in pairs(game:GetDescendants()) do
                if not isProcessing then break end
                
                if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                    addLog("Injecting: " .. obj.Name)
                    
                    pcall(function()
                        local payloads = {
                            {"GiveAdmin", LocalPlayer},
                            {"AddCoins", 99999},
                            {"SetRank", LocalPlayer.Name, "Owner"},
                            {"UnlockGamepass", true}
                        }

                        for _, p in pairs(payloads) do
                            if obj:IsA("RemoteEvent") then
                                obj:FireServer(unpack(p))
                            else
                                obj:InvokeServer(unpack(p))
                            end
                        end
                    end)
                    task.wait(0.05) -- Kecepatan log
                end
            end
            task.wait(1)
        end
    end)
end

---------------------------------------
-- 4. TOGGLE LOGIC
---------------------------------------
toggleBtn.MouseButton1Click:Connect(function()
    isProcessing = not isProcessing
    if isProcessing then
        toggleBtn.Text = "STOPPING..."
        toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 50)
        sendRobloxNotif("SPTZY", "Self-Execution Loop Started")
        startExecution()
    else
        toggleBtn.Text = "START SELF-EXECUTION"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        addLog("SYSTEM HALTED.")
    end
end)
