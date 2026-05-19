-- [[ SERVER-REPLICATED SHARP SQUARE 300x300 PHYSICS PRO V12 ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
end)

-- [[ SETUP GUI UTAMA ]] --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ServerPhysicsGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = (gethui and gethui()) or game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

-- Frame Utama (Persegi Empat Sempurna 300x300)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 300)
MainFrame.Position = UDim2.new(0.5, -150, 0.3, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true 
MainFrame.Parent = ScreenGui

-- Border Cyan Tajam
local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(0, 180, 255)
UIStroke.Thickness = 1.5
UIStroke.Parent = MainFrame

-- Header Menu
local HeaderLabel = Instance.new("TextLabel")
HeaderLabel.Size = UDim2.new(1, 0, 0, 30)
HeaderLabel.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
HeaderLabel.BorderSizePixel = 0
HeaderLabel.Text = "  SERVER REPLICATED PHYSICS V12"
HeaderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
HeaderLabel.Font = Enum.Font.SourceSansBold
HeaderLabel.TextSize = 11
HeaderLabel.TextXAlignment = Enum.TextXAlignment.Left
HeaderLabel.Parent = MainFrame

local HeaderStroke = Instance.new("UIStroke")
HeaderStroke.Color = Color3.fromRGB(28, 28, 33)
HeaderStroke.Thickness = 1
HeaderStroke.Parent = HeaderLabel

-- Kontainer Utama Vertikal
local ScrollContainer = Instance.new("ScrollingFrame")
ScrollContainer.Size = UDim2.new(1, -12, 1, -40)
ScrollContainer.Position = UDim2.new(0, 6, 0, 34)
ScrollContainer.BackgroundTransparency = 1
ScrollContainer.BorderSizePixel = 0
ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, 360)
ScrollContainer.ScrollBarThickness = 3
ScrollContainer.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.FillDirection = Enum.FillDirection.Vertical
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = ScrollContainer

-- [[ VARIABLE & LOGIKA REPLIKASI FISIKA ]] --
local States = {
    MassSpin = false,
    BlackHole = false,
    FlingSlingshot = false,
    BreakTethers = false,
    GlitchMagnet = false,
    QuantumTether = false
}

local Configs = {
    MassSpin_Speed = 150,
    BlackHole_Force = 65,
    Fling_Power = 500,
    Scan_Radius = 150,
    Glitch_Multi = 2000,
    Quantum_Power = 45 -- Kecepatan respons magnet pembawa bawaan kepala
}

-- Fungsi klaim Network Ownership otomatis via fisika aktif
local function claimNetworkOwnership(part)
    if settings().Physics.AllowSleep then
        settings().Physics.AllowSleep = false
    end
    part.RotVelocity = part.RotVelocity + Vector3.new(0, 0.01, 0)
end

-- Blacklist Filter agar sama sekali tidak mengganggu part tubuh manapun
local function isAPlayerPart(part)
    for _, player in pairs(Players:GetPlayers()) do
        local pChar = player.Character
        if pChar and part:IsDescendantOf(pChar) then
            return true
        end
    end
    if part.Parent and (part.Parent:FindFirstChildOfClass("Humanoid") or (part.Parent.Parent and part.Parent.Parent:FindFirstChildOfClass("Humanoid"))) then
        return true
    end
    if part.Parent and (part.Parent:IsA("Accessory") or part.Parent:IsA("Tool") or part.Parent:IsA("Hat")) then
        return true
    end
    local name = part.Name:lower()
    if name:find("head") or name:find("torso") or name:find("root") or name:find("arm") or name:find("leg") or name:find("hand") or name:find("foot") or name:find("limb") then
        return true
    end
    return false
end

-- Fungsi Pemindaian Sesuai Radius Konfigurasi
local function getValidParts()
    local parts = {}
    local root = Character:FindFirstChild("HumanoidRootPart")
    if not root then return parts end

    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj.Anchored then
            if not isAPlayerPart(obj) then
                if (obj.Position - root.Position).Magnitude <= Configs.Scan_Radius then
                    table.insert(parts, obj)
                end
            end
        end
    end
    return parts
end

-- Runtime Loop Menggunakan Heartbeat (Sync Fisika Server)
RunService.Heartbeat:Connect(function()
    local root = Character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local targets = getValidParts()

    for _, part in pairs(targets) do
        claimNetworkOwnership(part)

        -- =======================================================
        -- LOGIKA BARU QUANTUM TETHER (SCAN -> BREAK -> MAGNET -> SPIN DI ATAS KEPALA)
        -- =======================================================
        if States.QuantumTether then
            -- 1. Break Tethers (Putus otomatis instan saat tergenggam fitur ini)
            for _, subObj in pairs(part:GetChildren()) do
                if subObj:IsA("Constraint") or subObj:IsA("RopeConstraint") or subObj:IsA("Weld") or subObj:IsA("WeldConstraint") then
                    subObj:Destroy()
                end
            end

            -- Posisi Target: Selalu di atas kepala player (Y + 12 agar tidak menabrak karakter)
            local targetPos = root.Position + Vector3.new(0, 12, 0)
            local direction = (targetPos - part.Position)
            local distance = direction.Magnitude
            
            -- 2. Magnet (Menarik objek menuju titik target di atas kepala)
            if distance > 1.5 then
                part.Velocity = direction * Configs.Quantum_Power
            else
                -- Jika sudah sampai di atas kepala, kunci kecepatan menyatu dengan pergerakan player
                part.Velocity = root.Velocity
            end

            -- 3. Spin Di Atas Kepala (Konstan berputar ekstrem agar replikasi server terjaga)
            part.RotVelocity = Vector3.new(0, 120, 0)
        end

        -- 1. Mass Spin (Normal Standalone)
        if States.MassSpin and not States.QuantumTether then
            part.RotVelocity = Vector3.new(0, Configs.MassSpin_Speed, 0)
            part.Velocity = part.Velocity + Vector3.new(math.random(-15, 15), math.random(-10, 10), math.random(-15, 15))
        end

        -- 2. Black Hole (Normal Standalone)
        if States.BlackHole and not States.QuantumTether then
            local targetPos = root.Position + Vector3.new(0, 18, 0)
            local direction = (targetPos - part.Position)
            local distance = direction.Magnitude
            if distance > 2 then
                part.Velocity = direction.Unit * Configs.BlackHole_Force
            else
                part.Velocity = Vector3.new(0, 0, 0)
            end
        end

        -- 3. Fling Slingshot
        if States.FlingSlingshot then
            local power = Configs.Fling_Power
            part.Velocity = Vector3.new(
                math.random(-power, power),
                math.random(power * 0.8, power * 1.4),
                math.random(-power, power)
            )
        end

        -- 4. Break Tethers (Normal Standalone)
        if States.BreakTethers and not States.QuantumTether then
            for _, subObj in pairs(part:GetChildren()) do
                if subObj:IsA("Constraint") or subObj:IsA("RopeConstraint") or subObj:IsA("Weld") or subObj:IsA("WeldConstraint") then
                    subObj:Destroy()
                end
            end
        end

        -- 5. Glitch Magnet
        if States.GlitchMagnet then
            local targetPos = root.Position
            local direction = (targetPos - part.Position)
            local multi = Configs.Glitch_Multi
            part.Velocity = direction.Unit * math.random(multi * 0.4, multi) * (math.random(1, 2) == 1 and 1 or -1)
            part.RotVelocity = Vector3.new(math.random(-500, 500), math.random(-500, 500), math.random(-500, 500))
        end
    end
end)

-- [[ METODE GENERATOR KOMPONEN GUI + INPUT FIELD ]] --
local function createSquareComponent(title, desc, defaultVal, configKey, callback)
    local ButtonFrame = Instance.new("Frame")
    ButtonFrame.Size = UDim2.new(1, -6, 0, 50)
    ButtonFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
    ButtonFrame.BorderSizePixel = 0
    ButtonFrame.Parent = ScrollContainer

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(35, 35, 40)
    Stroke.Thickness = 1
    Stroke.Parent = ButtonFrame

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -110, 0.4, 0)
    TitleLabel.Position = UDim2.new(0, 8, 0.1, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title
    TitleLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
    TitleLabel.Font = Enum.Font.SourceSansBold
    TitleLabel.TextSize = 12
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = ButtonFrame

    local DescLabel = Instance.new("TextLabel")
    DescLabel.Size = UDim2.new(1, -110, 0.5, 0)
    DescLabel.Position = UDim2.new(0, 8, 0.45, 0)
    DescLabel.BackgroundTransparency = 1
    DescLabel.Text = desc
    DescLabel.TextColor3 = Color3.fromRGB(130, 130, 135)
    DescLabel.Font = Enum.Font.SourceSansItalic
    DescLabel.TextSize = 8.5
    DescLabel.TextWrapped = true
    DescLabel.TextXAlignment = Enum.TextXAlignment.Left
    DescLabel.TextYAlignment = Enum.TextYAlignment.Top
    DescLabel.Parent = ButtonFrame

    -- INPUT FIELD TEXTBOX
    local InputBox = Instance.new("TextBox")
    InputBox.Size = UDim2.new(0, 42, 0, 20)
    InputBox.Position = UDim2.new(1, -92, 0.5, -10)
    InputBox.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    InputBox.BorderSizePixel = 0
    InputBox.Text = tostring(defaultVal)
    InputBox.TextColor3 = Color3.fromRGB(0, 180, 255)
    InputBox.Font = Enum.Font.Code
    InputBox.TextSize = 10
    InputBox.ClearTextOnFocus = false
    InputBox.Parent = ButtonFrame

    local InputStroke = Instance.new("UIStroke")
    InputStroke.Color = Color3.fromRGB(45, 45, 50)
    InputStroke.Thickness = 1
    InputStroke.Parent = InputBox

    InputBox.FocusLost:Connect(function(enterPressed)
        local num = tonumber(InputBox.Text)
        if num then
            Configs[configKey] = num
        else
            InputBox.Text = tostring(Configs[configKey])
        end
    end)

    -- TOMBOL SWITCH ON/OFF
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0, 36, 0, 20)
    ToggleButton.Position = UDim2.new(1, -44, 0.5, -10)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Text = "OFF"
    ToggleButton.TextColor3 = Color3.fromRGB(150, 150, 150)
    ToggleButton.Font = Enum.Font.SourceSansBold
    ToggleButton.TextSize = 9
    ToggleButton.Parent = ButtonFrame

    local IndicatorStroke = Instance.new("UIStroke")
    IndicatorStroke.Color = Color3.fromRGB(50, 50, 55)
    IndicatorStroke.Thickness = 1
    IndicatorStroke.Parent = ToggleButton

    local toggled = false

    ToggleButton.MouseButton1Click:Connect(function()
        toggled = not toggled
        if toggled then
            Stroke.Color = Color3.fromRGB(0, 180, 255)
            ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 85, 160)
            ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            ToggleButton.Text = "ON"
            IndicatorStroke.Color = Color3.fromRGB(0, 180, 255)
        else
            Stroke.Color = Color3.fromRGB(35, 35, 40)
            ToggleButton.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            ToggleButton.TextColor3 = Color3.fromRGB(150, 150, 150)
            ToggleButton.Text = "OFF"
            IndicatorStroke.Color = Color3.fromRGB(50, 50, 55)
        end
        callback(toggled)
    end)
end

-- [[ INTEGRASI SEURUH KOMPONEN KE UI ]] --
createSquareComponent("Quantum Tether", "Scan -> Break -> Magnet -> Spin di atas kepala.", Configs.Quantum_Power, "Quantum_Power", function(state) States.QuantumTether = state end)
createSquareComponent("Mass Spin", "Membuat objek berputar ekstrem & bergoyang.", Configs.MassSpin_Speed, "MassSpin_Speed", function(state) States.MassSpin = state end)
createSquareComponent("Black Hole", "Menarik objek berkumpul statis di atas kepala.", Configs.BlackHole_Force, "BlackHole_Force", function(state) States.BlackHole = state end)
createSquareComponent("Fling Slingshot", "Melontarkan objek dengan gaya entakan masif.", Configs.Fling_Power, "Fling_Power", function(state) States.FlingSlingshot = state end)
createSquareComponent("Break Tethers", "Membatasi jarak radius scan & memutus tali.", Configs.Scan_Radius, "Scan_Radius", function(state) States.BreakTethers = state end)
createSquareComponent("Glitch Magnet", "Menarik objek dengan keanehan velocity acak.", Configs.Glitch_Multi, "Glitch_Multi", function(state) States.GlitchMagnet = state end)

print("Server-Replicated Physics Toolkit v12 (Chain Genggam Kepala) Loaded!")
