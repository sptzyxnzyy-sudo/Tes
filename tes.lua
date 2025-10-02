-- ⚠️ Hanya untuk testing map buatanmu ⚠️
-- Script ini harus dijalankan via executor (contoh: Delta, KRNL, Fluxus)
-- Jangan dipakai di map orang lain ya!

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MapTestGUI"
ScreenGui.Parent = game:GetService("CoreGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 250, 0, 150)
Frame.Position = UDim2.new(0.3, 0, 0.3, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Text = "🛠 Map Tester GUI"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.Parent = Frame

-- Fungsi tombol
local function createButton(name, order, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 30)
    btn.Position = UDim2.new(0, 10, 0, 30 + (order * 35))
    btn.Text = name
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.Parent = Frame

    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Contoh fitur untuk ngetes map kamu
createButton("Tes Gravity", 0, function()
    workspace.Gravity = (workspace.Gravity == 196.2 and 50 or 196.2)
end)

createButton("Tes Destroy Part", 1, function()
    for _, part in ipairs(workspace:GetDescendants()) do
        if part:IsA("Part") or part:IsA("MeshPart") then
            part:Destroy()
            break -- hapus 1 part saja untuk uji ketahanan
        end
    end
end)

createButton("Tes Speed", 2, function()
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = humanoid.WalkSpeed == 16 and 100 or 16
    end
end)

createButton("Tes Jump", 3, function()
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.JumpPower = humanoid.JumpPower == 50 and 200 or 50
    end
end)