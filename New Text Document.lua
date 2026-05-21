 -- LOW HUB - SEED FUNCTION TEST
    -- LocalScript / client script
    -- Separate GUI
    -- Uses function wrapper to call Seed Shop remote

    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local UserInputService = game:GetService("UserInputService")

    local Player = Players.LocalPlayer
    local PlayerGui = Player:WaitForChild("PlayerGui")

    local GUI_NAME = "LowHubSeedFunctionTest"
    local DESTINATION = "Seed Shop"

    local function log(msg)
        print("[LowHubSeedFunction] " .. tostring(msg))
    end

    local function warnlog(msg)
        warn("[LowHubSeedFunction] " .. tostring(msg))
    end

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

    local function corner(obj, r)
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, r or 8)
        c.Parent = obj
    end

    local function stroke(obj, color, thickness, transparency)
        local s = Instance.new("UIStroke")
        s.Color = color or Color3.fromRGB(57, 255, 20)
        s.Thickness = thickness or 1
        s.Transparency = transparency or 0
        s.Parent = obj
    end

    local function padding(obj, l, r)
        local p = Instance.new("UIPadding")
        p.PaddingLeft = UDim.new(0, l or 8)
        p.PaddingRight = UDim.new(0, r or 8)
        p.Parent = obj
    end

    local function shortPos(v)
        return string.format("%.1f, %.1f, %.1f", v.X, v.Y, v.Z)
    end

    local function getCharacter()
        local character = Player.Character or Player.CharacterAdded:Wait()
        local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 5)
        local root = character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart", 5)
        return character, humanoid, root
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

    -- Function wrapper
    local TeleportAPI = {}

    function TeleportAPI.Fire(destination)
        local remote, err = getTeleportRemote()

        if not remote then
            return false, err
        end

        if typeof(destination) ~= "string" then
            return false, "Destination must be string"
        end

        local ok, fireErr = pcall(function()
            local args = {
                destination
            }

            remote:FireServer(unpack(args))
        end)

        if not ok then
            return false, tostring(fireErr)
        end

        return true, "Request sent: " .. destination
    end

    function TeleportAPI.SeedShop()
        return TeleportAPI.Fire(DESTINATION)
    end

    function TeleportAPI.SeedShopWithPositionCheck()
        local character, humanoid, root = getCharacter()

        if not root then
            return false, "HumanoidRootPart not found"
        end

        local before = root.Position

        local ok, msg = TeleportAPI.SeedShop()

        if not ok then
            return false, msg
        end

        task.wait(1)

        local , , afterRoot = getCharacter()

        if not afterRoot then
            return false, "Request sent, but root missing after"
        end

        local after = afterRoot.Position
        local distance = (after - before).Magnitude

        log("Before: " .. shortPos(before))
        log("After: " .. shortPos(after))
        log("Distance: " .. tostring(math.floor(distance)))

        if distance >= 10 then
            return true, "Moved " .. tostring(math.floor(distance)) .. " studs"
        end

        return false, "Request sent, no movement. Pos: " .. shortPos(after)
    end

    local Gui = Instance.new("ScreenGui")
    Gui.Name = GUI_NAME
    Gui.ResetOnSpawn = false
    Gui.IgnoreGuiInset = false
    Gui.DisplayOrder = 999999
    Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

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
    Main.Size = UDim2.new(0, 360, 0, 265)
    Main.Position = UDim2.new(0, 30, 0.5, -132)
    Main.BackgroundColor3 = Color3.fromRGB(14, 20, 14)
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.ZIndex = 1000
    Main.Parent = Gui
    corner(Main, 10)
    stroke(Main, Color3.fromRGB(57, 255, 20), 2, 0.05)

    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 42)
    Header.BackgroundColor3 = Color3.fromRGB(20, 34, 20)
    Header.BorderSizePixel = 0
    Header.Active = true
    Header.ZIndex = 1001
    Header.Parent = Main
    corner(Header, 10)

    local Cover = Instance.new("Frame")
    Cover.Name = "Cover"
    Cover.Size = UDim2.new(1, 0, 0, 10)
    Cover.Position = UDim2.new(0, 0, 1, -10)
    Cover.BackgroundColor3 = Color3.fromRGB(20, 34, 20)
    Cover.BorderSizePixel = 0
    Cover.ZIndex = 1001
    Cover.Parent = Header

    local Badge = Instance.new("TextLabel")
    Badge.Name = "Badge"
    Badge.Size = UDim2.new(0, 34, 0, 28)
    Badge.Position = UDim2.new(0, 8, 0, 7)
    Badge.BackgroundColor3 = Color3.fromRGB(57, 255, 20)
    Badge.BorderSizePixel = 0
    Badge.Text = "LH"
    Badge.TextColor3 = Color3.fromRGB(0, 0, 0)
    Badge.TextSize = 13
    Badge.Font = Enum.Font.GothamBold
    Badge.ZIndex = 1002
    Badge.Parent = Header
    corner(Badge, 7)

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, -125, 1, 0)
    Title.Position = UDim2.new(0, 50, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "LOW HUB - FUNCTION TEST"
    Title.TextColor3 = Color3.fromRGB(57, 255, 20)
    Title.TextSize = 13
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.ZIndex = 1002
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
    MinBtn.ZIndex = 1003
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
    CloseBtn.ZIndex = 1003
    CloseBtn.Parent = Header
    corner(CloseBtn, 6)

    local Status = Instance.new("TextLabel")
    Status.Name = "Status"
    Status.Size = UDim2.new(1, -24, 0, 58)
    Status.Position = UDim2.new(0, 12, 0, 58)
    Status.BackgroundColor3 = Color3.fromRGB(24, 32, 24)
    Status.BorderSizePixel = 0
    Status.Text = "Status: Ready"
    Status.TextColor3 = Color3.fromRGB(190, 210, 190)
    Status.TextSize = 11
    Status.Font = Enum.Font.Gotham
    Status.TextXAlignment = Enum.TextXAlignment.Left
    Status.TextWrapped = true
    Status.ZIndex = 1001
    Status.Parent = Main
    corner(Status, 6)
    padding(Status, 8, 8)

    local Info = Instance.new("TextLabel")
    Info.Name = "Info"
    Info.Size = UDim2.new(1, -24, 0, 48)
    Info.Position = UDim2.new(0, 12, 0, 126)
    Info.BackgroundColor3 = Color3.fromRGB(20, 26, 20)
    Info.BorderSizePixel = 0
    Info.Text = "This tests a function wrapper:\nTeleportAPI.SeedShop() -> FireServer(\"Seed Shop\")"
    Info.TextColor3 = Color3.fromRGB(150, 170, 150)
    Info.TextSize = 10
    Info.Font = Enum.Font.Gotham
    Info.TextXAlignment = Enum.TextXAlignment.Left
    Info.TextWrapped = true
    Info.ZIndex = 1001
    Info.Parent = Main
    corner(Info, 6)
    padding(Info, 8, 8)

    local FunctionBtn = Instance.new("TextButton")
    FunctionBtn.Name = "FunctionSeedButton"
    FunctionBtn.Size = UDim2.new(1, -24, 0, 36)
    FunctionBtn.Position = UDim2.new(0, 12, 0, 186)
    FunctionBtn.BackgroundColor3 = Color3.fromRGB(35, 55, 35)
    FunctionBtn.BorderSizePixel = 0
    FunctionBtn.Text = "Call Function: SeedShop()"
    FunctionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    FunctionBtn.TextSize = 13
    FunctionBtn.Font = Enum.Font.GothamBold
    FunctionBtn.ZIndex = 1001
    FunctionBtn.Parent = Main
    corner(FunctionBtn, 6)
    stroke(FunctionBtn, Color3.fromRGB(57, 255, 20), 1, 0.45)

    local PosBtn = Instance.new("TextButton")
    PosBtn.Name = "PrintPositionButton"
    PosBtn.Size = UDim2.new(1, -24, 0, 28)
    PosBtn.Position = UDim2.new(0, 12, 0, 230)
    PosBtn.BackgroundColor3 = Color3.fromRGB(35, 45, 55)
    PosBtn.BorderSizePixel = 0
    PosBtn.Text = "Print Position"
    PosBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    PosBtn.TextSize = 12
    PosBtn.Font = Enum.Font.GothamBold
    PosBtn.ZIndex = 1001
    PosBtn.Parent = Main
    corner(PosBtn, 6)

    local Icon = Instance.new("TextButton")
    Icon.Name = "OpenIcon"
    Icon.Size = UDim2.new(0, 52, 0, 52)
    Icon.Position = UDim2.new(0, 20, 0.5, -26)
    Icon.BackgroundColor3 = Color3.fromRGB(57, 255, 20)
    Icon.BorderSizePixel = 0
    Icon.Text = "LH"
    Icon.TextColor3 = Color3.fromRGB(0, 0, 0)
    Icon.TextSize = 16
    Icon.Font = Enum.Font.GothamBold
    Icon.Visible = false
    Icon.Active = true
    Icon.ZIndex = 2000
    Icon.Parent = Gui
    corner(Icon, 10)

    local function setStatus(text, color)
        Status.Text = "Status: " .. tostring(text)
        Status.TextColor3 = color or Color3.fromRGB(190, 210, 190)
    end

    FunctionBtn.MouseButton1Click:Connect(function()
        setStatus("Calling TeleportAPI.SeedShopWithPositionCheck()...", Color3.fromRGB(255, 220, 80))

        task.spawn(function()
            local ok, msg = TeleportAPI.SeedShopWithPositionCheck()

            if ok then
                setStatus(msg, Color3.fromRGB(57, 255, 20))
            else
                setStatus(msg, Color3.fromRGB(255, 150, 80))
            end

            log("Function result: " .. tostring(ok) .. " / " .. tostring(msg))
        end)
    end)

    PosBtn.MouseButton1Click:Connect(function()
        local , , root = getCharacter()

        if root then
            setStatus("Pos: " .. shortPos(root.Position), Color3.fromRGB(180, 220, 255))
            log("Position: " .. shortPos(root.Position))
        else
            setStatus("No HumanoidRootPart", Color3.fromRGB(255, 80, 80))
        end
    end)

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

    local remote, err = getTeleportRemote()

    if remote then
        setStatus("Ready. Remote found.", Color3.fromRGB(57, 255, 20))
        log("Remote found: " .. remote:GetFullName())
    else
        setStatus(err, Color3.fromRGB(255, 80, 80))
        warnlog(err)
    end

    log("Function test GUI loaded")
