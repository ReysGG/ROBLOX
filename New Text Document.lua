-- LOW HUB TELEPORT DEBUG
    -- One file LocalScript
    -- ASCII only version

    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local TweenService = game:GetService("TweenService")

    local Player = Players.LocalPlayer
    local PlayerGui = Player:WaitForChild("PlayerGui")

    local GUI_NAME = "LowHubTeleportDebug"

    local function log(msg)
        print("[LowHub] " .. tostring(msg))
    end

    local function warnlog(msg)
        warn("[LowHub] " .. tostring(msg))
    end

    local function getCharacter()
        local char = Player.Character or Player.CharacterAdded:Wait()
        local hum = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 5)
        local root = char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart", 5)
        return char, hum, root
    end

    local function getTeleportRemote()
        local gameEvents = ReplicatedStorage:FindFirstChild("GameEvents")
        if not gameEvents then
            gameEvents = ReplicatedStorage:WaitForChild("GameEvents", 5)
        end

        if not gameEvents then
            return nil, "GameEvents not found"
        end

        local remote = gameEvents:FindFirstChild("PlayerTeleportTriggered")
        if not remote then
            remote = gameEvents:WaitForChild("PlayerTeleportTriggered", 5)
        end

        if not remote then
            return nil, "PlayerTeleportTriggered not found"
        end

        if not remote:IsA("RemoteEvent") then
            return nil, "PlayerTeleportTriggered is not RemoteEvent"
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
    Main.Size = UDim2.new(0, 320, 0, 260)
    Main.Position = UDim2.new(0.5, -160, 0.5, -130)
    Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Draggable = true
    Main.Parent = Gui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 8)
    MainCorner.Parent = Main

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(0, 255, 0)
    MainStroke.Thickness = 2
    MainStroke.Parent = Main

    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 42)
    Header.Position = UDim2.new(0, 0, 0, 0)
    Header.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Header.BorderSizePixel = 0
    Header.Parent = Main

    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 8)
    HeaderCorner.Parent = Header

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, -85, 1, 0)
    Title.Position = UDim2.new(0, 12, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "LOW HUB - TELEPORT"
    Title.TextColor3 = Color3.fromRGB(0, 255, 0)
    Title.TextSize = 15
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

    local Icon = Instance.new("TextButton")
    Icon.Name = "OpenIcon"
    Icon.Size = UDim2.new(0, 54, 0, 54)
    Icon.Position = UDim2.new(0, 20, 0.5, -27)
    Icon.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    Icon.BorderSizePixel = 0
    Icon.Text = "LH"
    Icon.TextColor3 = Color3.fromRGB(0, 0, 0)
    Icon.TextSize = 16
    Icon.Font = Enum.Font.GothamBold
    Icon.Visible = false
    Icon.Active = true
    Icon.Draggable = true
    Icon.Parent = Gui

    local IconCorner = Instance.new("UICorner")
    IconCorner.CornerRadius = UDim.new(0, 10)
    IconCorner.Parent = Icon

    local Status = Instance.new("TextLabel")
    Status.Name = "Status"
    Status.Size = UDim2.new(1, -24, 0, 46)
    Status.Position = UDim2.new(0, 12, 0, 54)
    Status.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
    Status.BorderSizePixel = 0
    Status.Text = "Status: Ready"
    Status.TextColor3 = Color3.fromRGB(200, 200, 200)
    Status.TextSize = 12
    Status.Font = Enum.Font.Gotham
    Status.TextXAlignment = Enum.TextXAlignment.Left
    Status.TextYAlignment = Enum.TextYAlignment.Center
    Status.Parent = Main

    local StatusCorner = Instance.new("UICorner")
    StatusCorner.CornerRadius = UDim.new(0, 6)
    StatusCorner.Parent = Status

    local StatusPad = Instance.new("UIPadding")
    StatusPad.PaddingLeft = UDim.new(0, 10)
    StatusPad.PaddingRight = UDim.new(0, 10)
    StatusPad.Parent = Status

    local Info = Instance.new("TextLabel")
    Info.Name = "Info"
    Info.Size = UDim2.new(1, -24, 0, 42)
    Info.Position = UDim2.new(0, 12, 0, 108)
    Info.BackgroundTransparency = 1
    Info.Text = "Remote: ReplicatedStorage.GameEvents.PlayerTeleportTriggered\nArgs: Farm"
    Info.TextColor3 = Color3.fromRGB(160, 160, 160)
    Info.TextSize = 10
    Info.Font = Enum.Font.Gotham
    Info.TextXAlignment = Enum.TextXAlignment.Left
    Info.TextYAlignment = Enum.TextYAlignment.Top
    Info.Parent = Main

    local function makeButton(name, text, y, color)
        local Btn = Instance.new("TextButton")
        Btn.Name = name
        Btn.Size = UDim2.new(1, -24, 0, 38)
        Btn.Position = UDim2.new(0, 12, 0, y)
        Btn.BackgroundColor3 = color or Color3.fromRGB(32, 32, 32)
        Btn.BorderSizePixel = 0
        Btn.Text = text
        Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Btn.TextSize = 12
        Btn.Font = Enum.Font.GothamBold
        Btn.Parent = Main

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 6)
        Corner.Parent = Btn

        return Btn
    end

    local GardenBtn = makeButton("GardenBtn", "Teleport to Garden", 156, Color3.fromRGB(32, 32, 32))
    local TestBtn = makeButton("TestBtn", "Test Remote + Position Check", 200, Color3.fromRGB(35, 45, 35))

    local function setStatus(text, color)
        Status.Text = "Status: " .. tostring(text)
        Status.TextColor3 = color or Color3.fromRGB(200, 200, 200)
    end

    local function fireTeleport(locationName)
        local remote, err = getTeleportRemote()
        if not remote then
            setStatus(err, Color3.fromRGB(255, 80, 80))
            warnlog(err)
            return false
        end

        local ok, fireErr = pcall(function()
            local args = {
                locationName
            }
            remote:FireServer(unpack(args))
        end)

        if not ok then
            setStatus("FireServer error", Color3.fromRGB(255, 80, 80))
            warnlog(fireErr)
            return false
        end

        log("FireServer sent with arg: " .. tostring(locationName))
        return true
    end

    local function teleportAndCheck(locationName)
        local char, hum, root = getCharacter()

        if not root then
            setStatus("HumanoidRootPart not found", Color3.fromRGB(255, 80, 80))
            return false
        end

        local before = root.Position

        setStatus("Sending request: " .. tostring(locationName), Color3.fromRGB(255, 255, 100))

        local sent = fireTeleport(locationName)
        if not sent then
            return false
        end

        task.wait(1.25)

        char, hum, root = getCharacter()

        if not root then
            setStatus("No root after request", Color3.fromRGB(255, 80, 80))
            return false
        end

        local after = root.Position
        local distance = (after - before).Magnitude

        log("Position before: " .. tostring(before))
        log("Position after: " .. tostring(after))
        log("Distance changed: " .. tostring(math.floor(distance)))

        if distance >= 20 then
            setStatus("Teleport success. Moved " .. tostring(math.floor(distance)) .. " studs", Color3.fromRGB(0, 255, 0))
            return true
        else
            setStatus("Request sent, but position did not change", Color3.fromRGB(255, 120, 80))
            return false
        end
    end

    GardenBtn.MouseButton1Click:Connect(function()
        teleportAndCheck("Farm")

        task.delay(3, function()
            if Status and Status.Parent then
                setStatus("Ready", Color3.fromRGB(200, 200, 200))
            end
        end)
    end)

    TestBtn.MouseButton1Click:Connect(function()
        setStatus("Testing remote...", Color3.fromRGB(255, 255, 100))

        local remote, err = getTeleportRemote()
        if not remote then
            setStatus(err, Color3.fromRGB(255, 80, 80))
            return
        end

        log("Remote found: " .. remote:GetFullName())

        local locations = {
            "Farm",
            "Garden",
            "Home",
            "MyFarm"
        }

        local success = false

        for _, location in ipairs(locations) do
            setStatus("Trying: " .. location, Color3.fromRGB(255, 255, 100))
            local result = teleportAndCheck(location)

            if result then
                success = true
                setStatus("Worked with arg: " .. location, Color3.fromRGB(0, 255, 0))
                break
            end

            task.wait(0.5)
        end

        if not success then
            setStatus("No tested arg teleported", Color3.fromRGB(255, 80, 80))
            warnlog("Remote sent, but server did not teleport. Arg may be wrong or server rejected request.")
        end

        task.delay(4, function()
            if Status and Status.Parent then
                setStatus("Ready", Color3.fromRGB(200, 200, 200))
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

    local remote, err = getTeleportRemote()
    if remote then
        setStatus("Ready. Remote found.", Color3.fromRGB(0, 255, 0))
        log("Loaded. Remote found: " .. remote:GetFullName())
    else
        setStatus(err, Color3.fromRGB(255, 80, 80))
        warnlog(err)
    end

    log("GUI loaded")
