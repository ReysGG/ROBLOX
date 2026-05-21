-- LOW HUB - SEED SHOP GUI
    -- LocalScript
    -- For your own Roblox game

    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local UserInputService = game:GetService("UserInputService")

    local Player = Players.LocalPlayer
    local PlayerGui = Player:WaitForChild("PlayerGui")

    local GUI_NAME = "LowHubSeedShop"
    local REMOTE_FOLDER = "GameEvents"
    local REMOTE_NAME = "LowHubSeedShopRequest"

    local old = PlayerGui:FindFirstChild(GUI_NAME)
    if old then
        old:Destroy()
    end

    local function corner(obj, r)
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, r or 8)
        c.Parent = obj
    end

    local function stroke(obj, color, thickness)
        local s = Instance.new("UIStroke")
        s.Color = color or Color3.fromRGB(57, 255, 20)
        s.Thickness = thickness or 1
        s.Transparency = 0.2
        s.Parent = obj
    end

    local function getRemote()
        local folder = ReplicatedStorage:WaitForChild(REMOTE_FOLDER, 5)
        if not folder then
            return nil, REMOTE_FOLDER .. " not found"
        end

        local remote = folder:WaitForChild(REMOTE_NAME, 5)
        if not remote then
            return nil, REMOTE_NAME .. " not found"
        end

        if not remote:IsA("RemoteEvent") then
            return nil, REMOTE_NAME .. " is not RemoteEvent"
        end

        return remote, nil
    end

    local Gui = Instance.new("ScreenGui")
    Gui.Name = GUI_NAME
    Gui.ResetOnSpawn = false
    Gui.IgnoreGuiInset = false
    Gui.DisplayOrder = 999
    Gui.Parent = PlayerGui

    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 330, 0, 210)
    Main.Position = UDim2.new(0.5, -165, 0.5, -105)
    Main.BackgroundColor3 = Color3.fromRGB(18, 22, 18)
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Parent = Gui
    corner(Main, 10)
    stroke(Main, Color3.fromRGB(57, 255, 20), 2)

    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 42)
    Header.BackgroundColor3 = Color3.fromRGB(25, 32, 25)
    Header.BorderSizePixel = 0
    Header.Parent = Main
    corner(Header, 10)

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
    corner(MinBtn, 6)

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
    corner(CloseBtn, 6)

    local Status = Instance.new("TextLabel")
    Status.Name = "Status"
    Status.Size = UDim2.new(1, -24, 0, 44)
    Status.Position = UDim2.new(0, 12, 0, 56)
    Status.BackgroundColor3 = Color3.fromRGB(30, 38, 30)
    Status.BorderSizePixel = 0
    Status.Text = "Status: Ready"
    Status.TextColor3 = Color3.fromRGB(180, 180, 180)
    Status.TextSize = 12
    Status.Font = Enum.Font.Gotham
    Status.TextXAlignment = Enum.TextXAlignment.Left
    Status.Parent = Main
    corner(Status, 6)

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
    SeedBtn.Text = "Open Seed Shop"
    SeedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    SeedBtn.TextSize = 13
    SeedBtn.Font = Enum.Font.GothamBold
    SeedBtn.Parent = Main
    corner(SeedBtn, 6)
    stroke(SeedBtn, Color3.fromRGB(57, 255, 20), 1)

    local TeleportBtn = Instance.new("TextButton")
    TeleportBtn.Name = "TeleportSeedShopBtn"
    TeleportBtn.Size = UDim2.new(1, -24, 0, 42)
    TeleportBtn.Position = UDim2.new(0, 12, 0, 160)
    TeleportBtn.BackgroundColor3 = Color3.fromRGB(35, 45, 55)
    TeleportBtn.BorderSizePixel = 0
    TeleportBtn.Text = "Teleport to Seed Shop"
    TeleportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    TeleportBtn.TextSize = 13
    TeleportBtn.Font = Enum.Font.GothamBold
    TeleportBtn.Parent = Main
    corner(TeleportBtn, 6)
    stroke(TeleportBtn, Color3.fromRGB(57, 180, 255), 1)

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
    corner(Icon, 10)

    local function setStatus(text, color)
        Status.Text = "Status: " .. tostring(text)
        Status.TextColor3 = color or Color3.fromRGB(180, 180, 180)
    end

    local function sendRequest(action)
        local remote, err = getRemote()

        if not remote then
            setStatus(err, Color3.fromRGB(255, 80, 80))
            warn("[LowHub] " .. tostring(err))
            return
        end

        setStatus("Sending: " .. tostring(action), Color3.fromRGB(255, 220, 80))

        local ok, fireErr = pcall(function()
            remote:FireServer(action)
        end)

        if not ok then
            setStatus("Request error", Color3.fromRGB(255, 80, 80))
            warn("[LowHub] " .. tostring(fireErr))
            return
        end

        setStatus("Request sent: " .. tostring(action), Color3.fromRGB(57, 255, 20))
        print("[LowHub] Request sent:", action)

        task.delay(3, function()
            if Status and Status.Parent then
                setStatus("Ready", Color3.fromRGB(180, 180, 180))
            end
        end)
    end

    SeedBtn.MouseButton1Click:Connect(function()
        sendRequest("OpenSeedShop")
    end)

    TeleportBtn.MouseButton1Click:Connect(function()
        sendRequest("TeleportSeedShop")
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
        print("[LowHub] Remote found:", remote:GetFullName())
    else
        setStatus(err, Color3.fromRGB(255, 80, 80))
        warn("[LowHub] " .. tostring(err))
    end

    print("[LowHub] Seed Shop GUI loaded")


    SERVER SCRIPT
    Taruh di ServerScriptService:

    lua
    -- LOW HUB - SEED SHOP SERVER
    -- ServerScript
    -- For your own Roblox game

    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Players = game:GetService("Players")

    local REMOTE_FOLDER = "GameEvents"
    local REMOTE_NAME = "LowHubSeedShopRequest"

    local SEED_SHOP_CFRAME = CFrame.new(
        28.999998092651367,
        3,
        10.556415557861328
    )

    local folder = ReplicatedStorage:FindFirstChild(REMOTE_FOLDER)

    if not folder then
        folder = Instance.new("Folder")
        folder.Name = REMOTE_FOLDER
        folder.Parent = ReplicatedStorage
    end

    local remote = folder:FindFirstChild(REMOTE_NAME)

    if not remote then
        remote = Instance.new("RemoteEvent")
        remote.Name = REMOTE_NAME
        remote.Parent = folder
    end

    local cooldown = {}
    local COOLDOWN_TIME = 1

    local function canUse(player)
        local now = os.clock()
        local last = cooldown[player]

        if last and now - last < COOLDOWN_TIME then
            return false
        end

        cooldown[player] = now
        return true
    end

    local function teleportToSeedShop(player)
        local character = player.Character

        if not character then
            return false, "Character not found"
        end

        local root = character:FindFirstChild("HumanoidRootPart")

        if not root then
            return false, "HumanoidRootPart not found"
        end

        root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)

        character:PivotTo(SEED_SHOP_CFRAME)

        return true, "Teleported"
    end

    local function openSeedShop(player)
        -- Isi ini dengan sistem shop kamu sendiri.
        -- Contoh: set attribute agar client/shop UI kamu membaca statusnya.
        player:SetAttribute("SeedShopOpen", true)

        print("[SeedShopServer] Open shop for", player.Name)

        return true, "Opened"
    end

    remote.OnServerEvent:Connect(function(player, action)
        print("[SeedShopServer] Request:", player.Name, tostring(action))

        if typeof(action) ~= "string" then
            warn("[SeedShopServer] Invalid action type")
            return
        end

        if not canUse(player) then
            warn("[SeedShopServer] Cooldown:", player.Name)
            return
        end

        if action == "TeleportSeedShop" then
            local ok, msg = teleportToSeedShop(player)

            if ok then
                print("[SeedShopServer] Teleported:", player.Name)
            else
                warn("[SeedShopServer] Teleport failed:", msg)
            end

            return
        end

        if action == "OpenSeedShop" then
            local ok, msg = openSeedShop(player)

            if ok then
                print("[SeedShopServer] Opened shop:", player.Name)
            else
                warn("[SeedShopServer] Open shop failed:", msg)
            end

            return
        end

        warn("[SeedShopServer] Unknown action:", tostring(action))
    end)

    Players.PlayerRemoving:Connect(function(player)
        cooldown[player] = nil
    end)

    print("[SeedShopServer] Ready:", remote:GetFullName())
