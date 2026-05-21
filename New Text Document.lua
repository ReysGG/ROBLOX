 -- LOW HUB SEED SHOP GUI
    -- LocalScript
    -- ASCII only

    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local UserInputService = game:GetService("UserInputService")

    local Player = Players.LocalPlayer
    local PlayerGui = Player:WaitForChild("PlayerGui")

    local GUI_NAME = "LowHubSeedShop"

    local old = PlayerGui:FindFirstChild(GUI_NAME)
    if old then
        old:Destroy()
    end

    local function setCorner(obj, radius)
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, radius or 8)
        c.Parent = obj
    end

    local function setStroke(obj, color, thickness)
        local s = Instance.new("UIStroke")
        s.Color = color or Color3.fromRGB(57, 255, 20)
        s.Thickness = thickness or 1
        s.Transparency = 0.2
        s.Parent = obj
    end

    local Gui = Instance.new("ScreenGui")
    Gui.Name = GUI_NAME
    Gui.ResetOnSpawn = false
    Gui.IgnoreGuiInset = false
    Gui.DisplayOrder = 999
    Gui.Parent = PlayerGui

    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 310, 0, 180)
    Main.Position = UDim2.new(0.5, -155, 0.5, -90)
    Main.BackgroundColor3 = Color3.fromRGB(18, 22, 18)
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Parent = Gui
    setCorner(Main, 10)
    setStroke(Main, Color3.fromRGB(57, 255, 20), 2)

    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 42)
    Header.BackgroundColor3 = Color3.fromRGB(25, 32, 25)
    Header.BorderSizePixel = 0
    Header.Parent = Main
    setCorner(Header, 10)

    local Cover = Instance.new("Frame")
    Cover.Size = UDim2.new(1, 0, 0, 10)
    Cover.Position = UDim2.new(0, 0, 1, -10)
    Cover.BackgroundColor3 = Color3.fromRGB(25, 32, 25)
    Cover.BorderSizePixel = 0
    Cover.Parent = Header

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, -85, 1, 0)
    Title.Position = UDim2.new(0, 12, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "LOW HUB - TELEPORT"
    Title.TextColor3 = Color3.fromRGB(57, 255, 20)
    Title.TextSize = 14
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Header

    local MinBtn = Instance.new("TextButton")
    MinBtn.Name = "Minimize"
    MinBtn.Size = UDim2.new(0, 30, 0, 30)
    MinBtn.Position = UDim2.new(1, -70, 0, 6)
    MinBtn.BackgroundColor3 = Color3.fromRGB(50, 140, 50)
    MinBtn.BorderSizePixel = 0
    MinBtn.Text = "-"
    MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinBtn.TextSize = 16
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.Parent = Header
    setCorner(MinBtn, 6)

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = "Close"
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -36, 0, 6)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.TextSize = 14
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Parent = Header
    setCorner(CloseBtn, 6)

    local Status = Instance.new("TextLabel")
    Status.Name = "Status"
    Status.Size = UDim2.new(1, -24, 0, 42)
    Status.Position = UDim2.new(0, 12, 0, 56)
    Status.BackgroundColor3 = Color3.fromRGB(30, 38, 30)
    Status.BorderSizePixel = 0
    Status.Text = "Status: Ready"
    Status.TextColor3 = Color3.fromRGB(180, 180, 180)
    Status.TextSize = 12
    Status.Font = Enum.Font.Gotham
    Status.TextXAlignment = Enum.TextXAlignment.Left
    Status.Parent = Main
    setCorner(Status, 6)

    local StatusPad = Instance.new("UIPadding")
    StatusPad.PaddingLeft = UDim.new(0, 10)
    StatusPad.PaddingRight = UDim.new(0, 10)
    StatusPad.Parent = Status

    local SeedBtn = Instance.new("TextButton")
    SeedBtn.Name = "SeedShopBtn"
    SeedBtn.Size = UDim2.new(1, -24, 0, 42)
    SeedBtn.Position = UDim2.new(0, 12, 0, 112)
    SeedBtn.BackgroundColor3 = Color3.fromRGB(35, 50, 35)
    SeedBtn.BorderSizePixel = 0
    SeedBtn.Text = "Teleport to Seed Shop"
    SeedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    SeedBtn.TextSize = 13
    SeedBtn.Font = Enum.Font.GothamBold
    SeedBtn.Parent = Main
    setCorner(SeedBtn, 6)
    setStroke(SeedBtn, Color3.fromRGB(57, 255, 20), 1)

    local Icon = Instance.new("TextButton")
    Icon.Name = "OpenIcon"
    Icon.Size = UDim2.new(0, 54, 0, 54)
    Icon.Position = UDim2.new(0, 20, 0.5, -27)
    Icon.BackgroundColor3 = Color3.fromRGB(57, 255, 20)
    Icon.BorderSizePixel = 0
    Icon.Text = "LH"
    Icon.TextColor3 = Color3.fromRGB(0, 0, 0)
    Icon.TextSize = 16
    Icon.Font = Enum.Font.GothamBold
    Icon.Visible = false
    Icon.Parent = Gui
    setCorner(Icon, 10)

    local function setStatus(text, color)
        Status.Text = "Status: " .. tostring(text)
        Status.TextColor3 = color or Color3.fromRGB(180, 180, 180)
    end

    local function getRemote()
        local folder = ReplicatedStorage:FindFirstChild("GameEvents")
        if not folder then
            folder = ReplicatedStorage:WaitForChild("GameEvents", 5)
        end

        if not folder then
            return nil, "GameEvents not found"
        end

        local remote = folder:FindFirstChild("PlayerTeleportTriggered")
        if not remote then
            remote = folder:WaitForChild("PlayerTeleportTriggered", 5)
        end

        if not remote then
            return nil, "PlayerTeleportTriggered not found"
        end

        if not remote:IsA("RemoteEvent") then
            return nil, "PlayerTeleportTriggered is not RemoteEvent"
        end

        return remote, nil
    end

    local function teleportSeedShop()
        local remote, err = getRemote()

        if not remote then
            setStatus(err, Color3.fromRGB(255, 80, 80))
            warn("[LowHub] " .. tostring(err))
            return
        end

        setStatus("Sending Seed Shop request...", Color3.fromRGB(255, 220, 80))

        local ok, fireErr = pcall(function()
            remote:FireServer("Seed Shop")
        end)

        if not ok then
            setStatus("FireServer error", Color3.fromRGB(255, 80, 80))
            warn("[LowHub] " .. tostring(fireErr))
            return
        end

        setStatus("Request sent: Seed Shop", Color3.fromRGB(57, 255, 20))
        print("[LowHub] Seed Shop request sent")
    end

    SeedBtn.MouseButton1Click:Connect(function()
        teleportSeedShop()

        task.delay(3, function()
            if Status and Status.Parent then
                setStatus("Ready", Color3.fromRGB(180, 180, 180))
            end
        end)
    end)

    CloseBtn.MouseButton1Click:Connect(function()
        Gui:Destroy()
    end)

    MinBtn.MouseButton1Click:Connect(function()
        Main.Visible = false
        Icon.Visible = true
    end)

    Icon.MouseButton1Click:Connect(function()
        Icon.Visible = false
        Main.Visible = true
    end)

    local dragging = false
    local dragStart = nil
    local startPos = nil

    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    local remote, err = getRemote()

    if remote then
        setStatus("Ready. Remote found.", Color3.fromRGB(57, 255, 20))
        print("[LowHub] Remote found: " .. remote:GetFullName())
    else
        setStatus(err, Color3.fromRGB(255, 80, 80))
        warn("[LowHub] " .. tostring(err))
    end

    print("[LowHub] Seed Shop GUI loaded")
