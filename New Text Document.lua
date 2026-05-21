 -- LOW HUB - SEED SHOP TELEPORT DEBUG
    -- LocalScript
    -- Focus only on PlayerTeleportTriggered("Seed Shop")
    -- ASCII only

    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local UserInputService = game:GetService("UserInputService")

    local Player = Players.LocalPlayer
    local PlayerGui = Player:WaitForChild("PlayerGui")

    local GUI_NAME = "LowHubSeedTeleportDebug"
    local DESTINATION = "Seed Shop"

    local function log(msg)
        print("[LowHubSeed] " .. tostring(msg))
    end

    local function warnlog(msg)
        warn("[LowHubSeed] " .. tostring(msg))
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

    local function corner(obj, radius)
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, radius or 8)
        c.Parent = obj
    end

    local function stroke(obj, color, thickness, transparency)
        local s = Instance.new("UIStroke")
        s.Color = color or Color3.fromRGB(57, 255, 20)
        s.Thickness = thickness or 1
        s.Transparency = transparency or 0
        s.Parent = obj
    end

    local function pad(obj, l, r, t, b)
        local p = Instance.new("UIPadding")
        p.PaddingLeft = UDim.new(0, l or 0)
        p.PaddingRight = UDim.new(0, r or 0)
        p.PaddingTop = UDim.new(0, t or 0)
        p.PaddingBottom = UDim.new(0, b or 0)
        p.Parent = obj
    end

    local function getRoot()
        local character = Player.Character or Player.CharacterAdded:Wait()
        local root = character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart", 5)
        return root
    end

    local function getRemote()
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
    Main.Size = UDim2.new(0, 360, 0, 260)
    Main.Position = UDim2.new(0.5, -180, 0.5, -130)
    Main.BackgroundColor3 = Color3.fromRGB(18, 22, 18)
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Parent = Gui
    corner(Main, 10)
    stroke(Main, Color3.fromRGB(57, 255, 20), 2, 0.1)

    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 42)
    Header.BackgroundColor3 = Color3.fromRGB(25, 32, 25)
    Header.BorderSizePixel = 0
    Header.Active = true
    Header.Parent = Main
    corner(Header, 10)

    local HeaderCover = Instance.new("Frame")
    HeaderCover.Name = "HeaderCover"
    HeaderCover.Size = UDim2.new(1, 0, 0, 10)
    HeaderCover.Position = UDim2.new(0, 0, 1, -10)
    HeaderCover.BackgroundColor3 = Color3.fromRGB(25, 32, 25)
    HeaderCover.BorderSizePixel = 0
    HeaderCover.Parent = Header

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, -55, 1, 0)
    Title.Position = UDim2.new(0, 12, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "LOW HUB - SEED TELEPORT"
    Title.TextColor3 = Color3.fromRGB(57, 255, 20)
    Title.TextSize = 14
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Header

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
    Status.Size = UDim2.new(1, -24, 0, 55)
    Status.Position = UDim2.new(0, 12, 0, 55)
    Status.BackgroundColor3 = Color3.fromRGB(30, 35, 30)
    Status.BorderSizePixel = 0
    Status.Text = "Status: Ready"
    Status.TextColor3 = Color3.fromRGB(180, 180, 180)
    Status.TextSize = 11
    Status.Font = Enum.Font.Gotham
    Status.TextXAlignment = Enum.TextXAlignment.Left
    Status.TextYAlignment = Enum.TextYAlignment.Center
    Status.TextWrapped = true
    Status.Parent = Main
    corner(Status, 6)
    pad(Status, 8, 8, 0, 0)

    local Info = Instance.new("TextLabel")
    Info.Name = "Info"
    Info.Size = UDim2.new(1, -24, 0, 42)
    Info.Position = UDim2.new(0, 12, 0, 118)
    Info.BackgroundColor3 = Color3.fromRGB(24, 28, 24)
    Info.BorderSizePixel = 0
    Info.Text = "Remote: ReplicatedStorage.GameEvents.PlayerTeleportTriggered\nArg: Seed Shop"
    Info.TextColor3 = Color3.fromRGB(150, 160, 150)
    Info.TextSize = 10
    Info.Font = Enum.Font.Gotham
    Info.TextXAlignment = Enum.TextXAlignment.Left
    Info.TextYAlignment = Enum.TextYAlignment.Center
    Info.Parent = Main
    corner(Info, 6)
    pad(Info, 8, 8, 0, 0)

    local function makeButton(name, text, x, y, w, h, color)
        local b = Instance.new("TextButton")
        b.Name = name
        b.Size = UDim2.new(0, w, 0, h)
        b.Position = UDim2.new(0, x, 0, y)
        b.BackgroundColor3 = color or Color3.fromRGB(35, 55, 35)
        b.BorderSizePixel = 0
        b.Text = text
        b.TextColor3 = Color3.fromRGB(255, 255, 255)
        b.TextSize = 12
        b.Font = Enum.Font.GothamBold
        b.Parent = Main
        corner(b, 6)
        stroke(b, Color3.fromRGB(57, 255, 20), 1, 0.5)
        return b
    end

    local FireBtn = makeButton("FireBtn", "Fire Seed Shop", 12, 172, 336, 38, Color3.fromRGB(35, 55, 35))
    local RetryBtn = makeButton("RetryBtn", "Retry x3", 12, 218, 106, 30, Color3.fromRGB(45, 45, 35))
    local PosBtn = makeButton("PosBtn", "Print Pos", 127, 218, 106, 30, Color3.fromRGB(35, 45, 55))
    local TestBtn = makeButton("TestBtn", "Test Remote", 242, 218, 106, 30, Color3.fromRGB(45, 35, 45))

    local function setStatus(text, color)
        Status.Text = "Status: " .. tostring(text)
        Status.TextColor3 = color or Color3.fromRGB(180, 180, 180)
    end

    local function shortVec(v)
        return string.format("%.1f, %.1f, %.1f", v.X, v.Y, v.Z)
    end

    local function printPosition()
        local root = getRoot()
        if not root then
            setStatus("No HumanoidRootPart", Color3.fromRGB(255, 80, 80))
            return
        end

        local pos = root.Position
        log("Player position: " .. shortVec(pos))
        setStatus("Position: " .. shortVec(pos), Color3.fromRGB(180, 220, 255))
    end

    local function fireOnce()
        local remote, err = getRemote()

        if not remote then
            setStatus(err, Color3.fromRGB(255, 80, 80))
            warnlog(err)
            return false
        end

        local root = getRoot()
        local before = root and root.Position or nil

        setStatus("Firing Seed Shop...", Color3.fromRGB(255, 220, 80))

        local ok, fireErr = pcall(function()
            local args = {
                DESTINATION
            }

            remote:FireServer(unpack(args))
        end)

        if not ok then
            setStatus("FireServer error", Color3.fromRGB(255, 80, 80))
            warnlog(fireErr)
            return false
        end

        log("Fired PlayerTeleportTriggered with arg: " .. DESTINATION)

        task.wait(1)

        local afterRoot = getRoot()

        if before and afterRoot then
            local after = afterRoot.Position
            local dist = (after - before).Magnitude

            log("Before: " .. shortVec(before))
            log("After: " .. shortVec(after))
            log("Distance: " .. tostring(math.floor(dist)))

            if dist >= 10 then
                setStatus("Moved " .. tostring(math.floor(dist)) .. " studs", Color3.fromRGB(57, 255, 20))
                return true
            else
                setStatus("Request sent, no movement. Pos: " .. shortVec(after), Color3.fromRGB(255, 150, 80))
                return false
            end
        end

        setStatus("Request sent", Color3.fromRGB(57, 255, 20))
        return true
    end

    FireBtn.MouseButton1Click:Connect(function()
        fireOnce()
    end)

    RetryBtn.MouseButton1Click:Connect(function()
        task.spawn(function()
            for i = 1, 3 do
                setStatus("Retry " .. tostring(i) .. "/3", Color3.fromRGB(255, 220, 80))
                local moved = fireOnce()
                if moved then
                    break
                end
                task.wait(0.8)
            end
        end)
    end)

    PosBtn.MouseButton1Click:Connect(function()
        printPosition()
    end)

    TestBtn.MouseButton1Click:Connect(function()
        local remote, err = getRemote()
        if remote then
            setStatus("Remote OK: " .. remote.Name, Color3.fromRGB(57, 255, 20))
            log("Remote OK: " .. remote:GetFullName())
        else
            setStatus(err, Color3.fromRGB(255, 80, 80))
            warnlog(err)
        end
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

    local remote, err = getRemote()
    if remote then
        setStatus("Ready. Remote found.", Color3.fromRGB(57, 255, 20))
        log("Remote found: " .. remote:GetFullName())
    else
        setStatus(err, Color3.fromRGB(255, 80, 80))
        warnlog(err)
    end

    log("Seed teleport debug GUI loaded")
