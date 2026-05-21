============================================================
    LOCAL SCRIPT
    Taruh di StarterPlayerScripts / StarterGui
    ============================================================

    lua
    -- LOW HUB TELEPORT
    -- One file LocalScript GUI + client request
    -- ASCII safe version

    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local TweenService = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")

    local Player = Players.LocalPlayer
    local PlayerGui = Player:WaitForChild("PlayerGui")

    local GUI_NAME = "LowHubTeleport"
    local REMOTE_FOLDER = "GameEvents"
    local REMOTE_NAME = "PlayerTeleportTriggered"

    local C = {
        Bg = Color3.fromRGB(18, 22, 18),
        Bg2 = Color3.fromRGB(25, 32, 25),
        Panel = Color3.fromRGB(30, 38, 30),
        Neon = Color3.fromRGB(57, 255, 20),
        Text = Color3.fromRGB(255, 255, 255),
        Dim = Color3.fromRGB(160, 170, 160),
        Red = Color3.fromRGB(220, 60, 60),
        Yellow = Color3.fromRGB(255, 210, 80),
        Green = Color3.fromRGB(60, 220, 100)
    }

    local Locations = {
        "Farm",
        "Garden",
        "Home",
        "Shop"
    }

    local function log(msg)
        print("[LowHubTeleport] " .. tostring(msg))
    end

    local function warnlog(msg)
        warn("[LowHubTeleport] " .. tostring(msg))
    end

    local function round(obj, r)
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, r or 8)
        c.Parent = obj
        return c
    end

    local function stroke(obj, color, thickness, trans)
        local s = Instance.new("UIStroke")
        s.Color = color or C.Neon
        s.Thickness = thickness or 1
        s.Transparency = trans or 0
        s.Parent = obj
        return s
    end

    local function tween(obj, props, time)
        TweenService:Create(
            obj,
            TweenInfo.new(time or 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            props
        ):Play()
    end

    local function getCharacter()
        local char = Player.Character or Player.CharacterAdded:Wait()
        local hum = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 5)
        local root = char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart", 5)
        return char, hum, root
    end

    local function getRemote()
        local folder = ReplicatedStorage:FindFirstChild(REMOTE_FOLDER)

        if not folder then
            folder = ReplicatedStorage:WaitForChild(REMOTE_FOLDER, 5)
        end

        if not folder then
            return nil, REMOTE_FOLDER .. " not found"
        end

        local remote = folder:FindFirstChild(REMOTE_NAME)

        if not remote then
            remote = folder:WaitForChild(REMOTE_NAME, 5)
        end

        if not remote then
            return nil, REMOTE_NAME .. " not found"
        end

        if not remote:IsA("RemoteEvent") then
            return nil, REMOTE_NAME .. " is not RemoteEvent"
        end

        return remote, nil
    end

    local function removeOldGui()
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

    removeOldGui()

    local Gui = Instance.new("ScreenGui")
    Gui.Name = GUI_NAME
    Gui.ResetOnSpawn = false
    Gui.IgnoreGuiInset = false
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
    Main.Size = UDim2.new(0, 420, 0, 330)
    Main.Position = UDim2.new(0.5, -210, 0.5, -165)
    Main.BackgroundColor3 = C.Bg
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Parent = Gui
    round(Main, 12)
    stroke(Main, C.Neon, 2, 0.15)

    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 48)
    Header.BackgroundColor3 = C.Bg2
    Header.BorderSizePixel = 0
    Header.Parent = Main
    round(Header, 12)

    local HeaderCover = Instance.new("Frame")
    HeaderCover.Size = UDim2.new(1, 0, 0, 12)
    HeaderCover.Position = UDim2.new(0, 0, 1, -12)
    HeaderCover.BackgroundColor3 = C.Bg2
    HeaderCover.BorderSizePixel = 0
    HeaderCover.Parent = Header

    local Logo = Instance.new("TextLabel")
    Logo.Name = "Logo"
    Logo.Size = UDim2.new(0, 36, 0, 36)
    Logo.Position = UDim2.new(0, 10, 0.5, -18)
    Logo.BackgroundColor3 = C.Neon
    Logo.BorderSizePixel = 0
    Logo.Text = "LH"
    Logo.TextColor3 = Color3.fromRGB(0, 0, 0)
    Logo.TextSize = 14
    Logo.Font = Enum.Font.GothamBold
    Logo.Parent = Header
    round(Logo, 8)

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, -140, 0, 24)
    Title.Position = UDim2.new(0, 55, 0, 5)
    Title.BackgroundTransparency = 1
    Title.Text = "LOW HUB TELEPORT"
    Title.TextColor3 = C.Neon
    Title.TextSize = 15
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Header

    local SubTitle = Instance.new("TextLabel")
    SubTitle.Name = "SubTitle"
    SubTitle.Size = UDim2.new(1, -140, 0, 16)
    SubTitle.Position = UDim2.new(0, 55, 0, 27)
    SubTitle.BackgroundTransparency = 1
    SubTitle.Text = "Client GUI + server request"
    SubTitle.TextColor3 = C.Dim
    SubTitle.TextSize = 10
    SubTitle.Font = Enum.Font.Gotham
    SubTitle.TextXAlignment = Enum.TextXAlignment.Left
    SubTitle.Parent = Header

    local MinBtn = Instance.new("TextButton")
    MinBtn.Name = "Minimize"
    MinBtn.Size = UDim2.new(0, 32, 0, 32)
    MinBtn.Position = UDim2.new(1, -76, 0.5, -16)
    MinBtn.BackgroundColor3 = C.Green
    MinBtn.BorderSizePixel = 0
    MinBtn.Text = "-"
    MinBtn.TextColor3 = C.Text
    MinBtn.TextSize = 18
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.Parent = Header
    round(MinBtn, 8)

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = "Close"
    CloseBtn.Size = UDim2.new(0, 32, 0, 32)
    CloseBtn.Position = UDim2.new(1, -38, 0.5, -16)
    CloseBtn.BackgroundColor3 = C.Red
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = C.Text
    CloseBtn.TextSize = 13
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Parent = Header
    round(CloseBtn, 8)

    local Body = Instance.new("Frame")
    Body.Name = "Body"
    Body.Size = UDim2.new(1, -24, 1, -66)
    Body.Position = UDim2.new(0, 12, 0, 56)
    Body.BackgroundTransparency = 1
    Body.Parent = Main

    local Status = Instance.new("TextLabel")
    Status.Name = "Status"
    Status.Size = UDim2.new(1, 0, 0, 48)
    Status.BackgroundColor3 = C.Panel
    Status.BorderSizePixel = 0
    Status.Text = "Status: Loading..."
    Status.TextColor3 = C.Dim
    Status.TextSize = 12
    Status.Font = Enum.Font.Gotham
    Status.TextXAlignment = Enum.TextXAlignment.Left
    Status.TextYAlignment = Enum.TextYAlignment.Center
    Status.Parent = Body
    round(Status, 8)
    stroke(Status, C.Neon, 1, 0.75)

    local StatusPad = Instance.new("UIPadding")
    StatusPad.PaddingLeft = UDim.new(0, 12)
    StatusPad.PaddingRight = UDim.new(0, 12)
    StatusPad.Parent = Status

    local Info = Instance.new("TextLabel")
    Info.Name = "Info"
    Info.Size = UDim2.new(1, 0, 0, 52)
    Info.Position = UDim2.new(0, 0, 0, 58)
    Info.BackgroundColor3 = C.Panel
    Info.BorderSizePixel = 0
    Info.Text = "Remote: ReplicatedStorage.GameEvents.PlayerTeleportTriggered\nArgs: locationName\nNote: server script must exist."
    Info.TextColor3 = C.Dim
    Info.TextSize = 10
    Info.Font = Enum.Font.Gotham
    Info.TextXAlignment = Enum.TextXAlignment.Left
    Info.TextYAlignment = Enum.TextYAlignment.Center
    Info.Parent = Body
    round(Info, 8)
    stroke(Info, C.Neon, 1, 0.85)

    local InfoPad = Instance.new("UIPadding")
    InfoPad.PaddingLeft = UDim.new(0, 12)
    InfoPad.PaddingRight = UDim.new(0, 12)
    InfoPad.Parent = Info

    local ButtonHolder = Instance.new("Frame")
    ButtonHolder.Name = "ButtonHolder"
    ButtonHolder.Size = UDim2.new(1, 0, 0, 132)
    ButtonHolder.Position = UDim2.new(0, 0, 0, 120)
    ButtonHolder.BackgroundTransparency = 1
    ButtonHolder.Parent = Body

    local Grid = Instance.new("UIGridLayout")
    Grid.CellSize = UDim2.new(0.5, -6, 0, 38)
    Grid.CellPadding = UDim2.new(0, 12, 0, 10)
    Grid.SortOrder = Enum.SortOrder.LayoutOrder
    Grid.Parent = ButtonHolder

    local function setStatus(text, color)
        Status.Text = "Status: " .. tostring(text)
        Status.TextColor3 = color or C.Dim
    end

    local function requestTeleport(locationName)
        local char, hum, root = getCharacter()

        if not root then
            setStatus("HumanoidRootPart not found", C.Red)
            return false
        end

        local remote, err = getRemote()

        if not remote then
            setStatus(err, C.Red)
            warnlog(err)
            return false
        end

        local before = root.Position

        setStatus("Sending request: " .. tostring(locationName), C.Yellow)

        local ok, fireErr = pcall(function()
            remote:FireServer(locationName)
        end)

        if not ok then
            setStatus("FireServer failed", C.Red)
            warnlog(fireErr)
            return false
        end

        log("FireServer sent: " .. tostring(locationName))

        task.wait(1)

        char, hum, root = getCharacter()

        if not root then
            setStatus("No root after request", C.Red)
            return false
        end

        local after = root.Position
        local distance = (after - before).Magnitude

        if distance >= 10 then
            setStatus("Teleport success: " .. locationName, C.Green)
            log("Moved " .. tostring(math.floor(distance)) .. " studs")
            return true
        else
            setStatus("Request sent, but not moved", C.Yellow)
            warnlog("Server may reject location or server script missing")
            return false
        end
    end

    local function createTeleportButton(locationName, order)
        local Btn = Instance.new("TextButton")
        Btn.Name = locationName .. "Btn"
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

    local TestBtn = Instance.new("TextButton")
    TestBtn.Name = "TestBtn"
    TestBtn.Size = UDim2.new(1, 0, 0, 38)
    TestBtn.Position = UDim2.new(0, 0, 1, -38)
    TestBtn.BackgroundColor3 = Color3.fromRGB(35, 45, 35)
    TestBtn.BorderSizePixel = 0
    TestBtn.Text = "Test Remote"
    TestBtn.TextColor3 = C.Text
    TestBtn.TextSize = 12
    TestBtn.Font = Enum.Font.GothamBold
    TestBtn.Parent = Body
    round(TestBtn, 8)
    stroke(TestBtn, C.Neon, 1, 0.6)

    TestBtn.MouseButton1Click:Connect(function()
        local remote, err = getRemote()

        if not remote then
            setStatus(err, C.Red)
            return
        end

        setStatus("Remote found: " .. remote:GetFullName(), C.Green)
        log("Remote found: " .. remote:GetFullName())
    end)

    local Icon = Instance.new("TextButton")
    Icon.Name = "OpenIcon"
    Icon.Size = UDim2.new(0, 54, 0, 54)
    Icon.Position = UDim2.new(0, 20, 0.5, -27)
    Icon.BackgroundColor3 = C.Neon
    Icon.BorderSizePixel = 0
    Icon.Text = "LH"
    Icon.TextColor3 = Color3.fromRGB(0, 0, 0)
    Icon.TextSize = 16
    Icon.Font = Enum.Font.GothamBold
    Icon.Visible = false
    Icon.Active = true
    Icon.Parent = Gui
    round(Icon, 12)

    MinBtn.MouseButton1Click:Connect(function()
        Main.Visible = false
        Icon.Visible = true
    end)

    Icon.MouseButton1Click:Connect(function()
        Icon.Visible = false
        Main.Visible = true
    end)

    CloseBtn.MouseButton1Click:Connect(function()
        Gui:Destroy()
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

    local iconDragging = false
    local iconStart = nil
    local iconStartPos = nil

    Icon.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            iconDragging = true
            iconStart = input.Position
            iconStartPos = Icon.Position
        end
    end)

    Icon.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            iconDragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if iconDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
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
        setStatus("Ready. Remote found.", C.Green)
        log("Loaded. Remote found: " .. remote:GetFullName())
    else
        setStatus(err, C.Red)
        warnlog(err)
    end

    log("LOW HUB TELEPORT loaded")


    ============================================================
    SERVER SCRIPT
    Taruh di ServerScriptService
    ============================================================

    lua
    -- LOW HUB TELEPORT SERVER
    -- Put this in ServerScriptService
    -- This is required for real server-side teleport

    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Players = game:GetService("Players")

    local REMOTE_FOLDER = "GameEvents"
    local REMOTE_NAME = "PlayerTeleportTriggered"

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

    local TeleportPoints = {
        Farm = CFrame.new(0, 10, 0),
        Garden = CFrame.new(50, 10, 0),
        Home = CFrame.new(0, 10, 50),
        Shop = CFrame.new(-50, 10, 0)
    }

    local Cooldown = {}
    local COOLDOWN_TIME = 2

    local function canTeleport(player)
        local now = os.clock()
        local last = Cooldown[player]

        if last and now - last < COOLDOWN_TIME then
            return false
        end

        Cooldown[player] = now
        return true
    end

    local function getRoot(player)
        local char = player.Character

        if not char then
            return nil
        end

        return char:FindFirstChild("HumanoidRootPart")
    end

    remote.OnServerEvent:Connect(function(player, locationName)
        if type(locationName) ~= "string" then
            warn("[TeleportServer] Invalid location type from " .. player.Name)
            return
        end

        if not canTeleport(player) then
            warn("[TeleportServer] Cooldown: " .. player.Name)
            return
        end

        local targetCFrame = TeleportPoints[locationName]

        if not targetCFrame then
            warn("[TeleportServer] Invalid location: " .. tostring(locationName) .. " from " .. player.Name)
            return
        end

        local root = getRoot(player)

        if not root then
            warn("[TeleportServer] No HumanoidRootPart for " .. player.Name)
            return
        end

        root.CFrame = targetCFrame

        print("[TeleportServer] Teleported " .. player.Name .. " to " .. locationName)
    end)

    Players.PlayerRemoving:Connect(function(player)
        Cooldown[player] = nil
    end)

    print("[TeleportServer] Ready")
