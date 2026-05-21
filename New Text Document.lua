 local Locations = {
        "Farm",
        "Garden",
        "Home",
        "Shop"
    }


    menjadi:

    lua
    local Locations = {
        "Farm",
        "Garden",
        "Home",
        "Shop",
        "Seed Shop"
    }


    Tapi karena grid sebelumnya cuma cukup untuk beberapa tombol, ini versi lengkap bagian GUI teleport yang sudah saya rapikan agar ada tombol Seed Shop.

    Ganti bagian Locations sampai pembuatan tombol dengan ini:

    lua
    local Locations = {
        "Farm",
        "Garden",
        "Home",
        "Shop",
        "Seed Shop"
    }

    local ButtonHolder = Instance.new("ScrollingFrame")
    ButtonHolder.Name = "ButtonHolder"
    ButtonHolder.Size = UDim2.new(1, 0, 0, 132)
    ButtonHolder.Position = UDim2.new(0, 0, 0, 120)
    ButtonHolder.BackgroundTransparency = 1
    ButtonHolder.BorderSizePixel = 0
    ButtonHolder.ScrollBarThickness = 3
    ButtonHolder.ScrollBarImageColor3 = C.Neon
    ButtonHolder.CanvasSize = UDim2.new(0, 0, 0, 0)
    ButtonHolder.Parent = Body

    local Grid = Instance.new("UIGridLayout")
    Grid.CellSize = UDim2.new(0.5, -6, 0, 38)
    Grid.CellPadding = UDim2.new(0, 12, 0, 10)
    Grid.SortOrder = Enum.SortOrder.LayoutOrder
    Grid.Parent = ButtonHolder

    Grid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ButtonHolder.CanvasSize = UDim2.new(0, 0, 0, Grid.AbsoluteContentSize.Y + 10)
    end)

    local function createTeleportButton(locationName, order)
        local Btn = Instance.new("TextButton")
        Btn.Name = locationName:gsub("%s+", "") .. "Btn"
        Btn.BackgroundColor3 = C.Panel
        Btn.BorderSizePixel = 0
        Btn.Text = "Teleport: " .. locationName
        Btn.TextColor3 = C.Text
        Btn.TextSize = 12
        Btn.Font = Enum.Font.GothamBold
        Btn.AutoButtonColor = false
        Btn.LayoutOrder = order
        Btn.Parent = ButtonHolder

        round(Btn, 8)
        stroke(Btn, C.Neon, 1, 0.7)

        Btn.MouseEnter:Connect(function()
            tween(Btn, {BackgroundColor3 = Color3.fromRGB(40, 55, 40)}, 0.15)
        end)

        Btn.MouseLeave:Connect(function()
            tween(Btn, {BackgroundColor3 = C.Panel}, 0.15)
        end)

        Btn.MouseButton1Click:Connect(function()
            requestTeleport(locationName)

            task.delay(3, function()
                if Status and Status.Parent then
                    setStatus("Ready", C.Dim)
                end
            end)
        end)
    end

    for i, locationName in ipairs(Locations) do
        createTeleportButton(locationName, i)
    end


    Kalau kamu mau langsung tombol khusus Seed Shop tanpa daftar lokasi, tambahkan ini setelah tombol-tombol lain dibuat:

    lua
    local SeedBtn = Instance.new("TextButton")
    SeedBtn.Name = "SeedShopBtn"
    SeedBtn.Size = UDim2.new(1, 0, 0, 38)
    SeedBtn.Position = UDim2.new(0, 0, 0, 260)
    SeedBtn.BackgroundColor3 = C.Panel
    SeedBtn.BorderSizePixel = 0
    SeedBtn.Text = "Teleport: Seed Shop"
    SeedBtn.TextColor3 = C.Text
    SeedBtn.TextSize = 12
    SeedBtn.Font = Enum.Font.GothamBold
    SeedBtn.Parent = Body

    round(SeedBtn, 8)
    stroke(SeedBtn, C.Neon, 1, 0.7)

    SeedBtn.MouseButton1Click:Connect(function()
        requestTeleport("Seed Shop")
    end)


    Remote event yang dipanggil tetap sama:

    lua
    local args = {
        "Seed Shop"
    }

    game:GetService("ReplicatedStorage")
        :WaitForChild("GameEvents")
        :WaitForChild("PlayerTeleportTriggered")
        :FireServer(unpack(args))


    Kalau mau versi mini yang hanya GUI Seed Shop saja, pakai ini:

    lua
    -- LOW HUB - SEED SHOP TELEPORT
    -- One file LocalScript
    -- ASCII safe

    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local TweenService = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")

    local Player = Players.LocalPlayer
    local PlayerGui = Player:WaitForChild("PlayerGui")

    local GUI_NAME = "LowHubSeedTeleport"

    local function getRemote()
        local folder = ReplicatedStorage:WaitForChild("GameEvents", 5)
        if not folder then
            return nil, "GameEvents not found"
        end

        local remote = folder:WaitForChild("PlayerTeleportTriggered", 5)
        if not remote then
            return nil, "PlayerTeleportTriggered not found"
        end

        if not remote:IsA("RemoteEvent") then
            return nil, "PlayerTeleportTriggered is not RemoteEvent"
        end

        return remote, nil
    end

    local function getRoot()
        local char = Player.Character or Player.CharacterAdded:Wait()
        return char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart", 5)
    end

    local function removeOld()
        local old = PlayerGui:FindFirstChild(GUI_NAME)
        if old then
            old:Destroy()
        end

        pcall(function()
            local core = game:GetService("CoreGui")
            local oldCore = core:FindFirstChild(GUI_NAME)
            if oldCore then
                oldCore:Destroy()
            end
        end)
    end

    removeOld()

    local Gui = Instance.new("ScreenGui")
    Gui.Name = GUI_NAME
    Gui.ResetOnSpawn = false
    Gui.DisplayOrder = 999

    local parented = false
    pcall(function()
        Gui.Parent = game:GetService("CoreGui")
        parented = true
    end)

    if not parented then
        Gui.Parent = PlayerGui
    end

    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 300, 0, 180)
    Main.Position = UDim2.new(0.5, -150, 0.5, -90)
    Main.BackgroundColor3 = Color3.fromRGB(18, 22, 18)
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Parent = Gui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 10)
    MainCorner.Parent = Main

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(57, 255, 20)
    MainStroke.Thickness = 2
    MainStroke.Transparency = 0.15
    MainStroke.Parent = Main

    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 42)
    Header.BackgroundColor3 = Color3.fromRGB(25, 32, 25)
    Header.BorderSizePixel = 0
    Header.Parent = Main

    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 10)
    HeaderCorner.Parent = Header

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, -85, 1, 0)
    Title.Position = UDim2.new(0, 12, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "LOW HUB - SEED SHOP"
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

    local MinCorner = Instance.new("UICorner")
    MinCorner.CornerRadius = UDim.new(0, 6)
    MinCorner.Parent = MinBtn

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

    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 6)
    CloseCorner.Parent = CloseBtn

    local Status = Instance.new("TextLabel")
    Status.Name = "Status"
    Status.Size = UDim2.new(1, -24, 0, 42)
    Status.Position = UDim2.new(0, 12, 0, 55)
    Status.BackgroundColor3 = Color3.fromRGB(30, 38, 30)
    Status.BorderSizePixel = 0
    Status.Text = "Status: Ready"
    Status.TextColor3 = Color3.fromRGB(180, 180, 180)
    Status.TextSize = 12
    Status.Font = Enum.Font.Gotham
    Status.TextXAlignment = Enum.TextXAlignment.Left
    Status.Parent = Main

    local StatusCorner = Instance.new("UICorner")
    StatusCorner.CornerRadius = UDim.new(0, 6)
    StatusCorner.Parent = Status

    local StatusPad = Instance.new("UIPadding")
    StatusPad.PaddingLeft = UDim.new(0, 10)
    StatusPad.PaddingRight = UDim.new(0, 10)
    StatusPad.Parent = Status

    local SeedBtn = Instance.new("TextButton")
    SeedBtn.Name = "SeedShopBtn"
    SeedBtn.Size = UDim2.new(1, -24, 0, 42)
    SeedBtn.Position = UDim2.new(0, 12, 0, 110)
    SeedBtn.BackgroundColor3 = Color3.fromRGB(35, 50, 35)
    SeedBtn.BorderSizePixel = 0
    SeedBtn.Text = "Teleport to Seed Shop"
    SeedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    SeedBtn.TextSize = 13
    SeedBtn.Font = Enum.Font.GothamBold
    SeedBtn.Parent = Main

    local SeedCorner = Instance.new("UICorner")
    SeedCorner.CornerRadius = UDim.new(0, 6)
    SeedCorner.Parent = SeedBtn

    local SeedStroke = Instance.new("UIStroke")
    SeedStroke.Color = Color3.fromRGB(57, 255, 20)
    SeedStroke.Thickness = 1
    SeedStroke.Transparency = 0.5
    SeedStroke.Parent = SeedBtn

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
    Icon.Active = true
    Icon.Parent = Gui

    local IconCorner = Instance.new("UICorner")
    IconCorner.CornerRadius = UDim.new(0, 10)
    IconCorner.Parent = Icon

    local function setStatus(text, color)
        Status.Text = "Status: " .. tostring(text)
        Status.TextColor3 = color or Color3.fromRGB(180, 180, 180)
    end

    local function teleportSeedShop()
        local remote, err = getRemote()

        if not remote then
            setStatus(err, Color3.fromRGB(255, 80, 80))
            warn("[LowHub] " .. tostring(err))
            return
        end

        local beforeRoot = getRoot()
        local beforePos = beforeRoot and beforeRoot.Position

        setStatus("Sending request: Seed Shop", Color3.fromRGB(255, 220, 80))

        local ok, fireErr = pcall(function()
            local args = {
                "Seed Shop"
            }

            remote:FireServer(unpack(args))
        end)

        if not ok then
            setStatus("FireServer error", Color3.fromRGB(255, 80, 80))
            warn("[LowHub] " .. tostring(fireErr))
            return
        end

        task.wait(1)

        local afterRoot = getRoot()

        if beforePos and afterRoot then
            local distance = (afterRoot.Position - beforePos).Magnitude

            if distance >= 10 then
                setStatus("Teleport success", Color3.fromRGB(57, 255, 20))
            else
                setStatus("Request sent, position not changed", Color3.fromRGB(255, 150, 80))
            end
        else
            setStatus("Request sent", Color3.fromRGB(255, 220, 80))
        end
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

    local iconDrag = false
    local iconStart = nil
    local iconStartPos = nil

    Icon.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            iconDrag = true
            iconStart = input.Position
            iconStartPos = Icon.Position
        end
    end)

    Icon.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            iconDrag = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if iconDrag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - iconStart
            Icon.Position = UDim2.new(
                iconStartPos.X.Scale,
                iconStartPos.X.Offset + delta.X,
                iconStartPos.Y.Scale,
                iconStartPos.Y.Offset + delta.Y
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

    print("[LowHub] Seed Shop teleport GUI loaded")
