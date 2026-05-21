-- LOW HUB - SEED OVERLAY
    -- LocalScript / client script
    -- Separate GUI from original game GUI
    -- Does not destroy original GUI

    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local UserInputService = game:GetService("UserInputService")
    local VirtualInputManager = game:GetService("VirtualInputManager")

    local Player = Players.LocalPlayer
    local PlayerGui = Player:WaitForChild("PlayerGui")

    local GUI_NAME = "LowHubSeedOverlay"
    local DESTINATION = "Seed Shop"

    local function log(msg)
        print("[LowHubSeed] " .. tostring(msg))
    end

    local function warnlog(msg)
        warn("[LowHubSeed] " .. tostring(msg))
    end

    -- Only remove our own GUI, not original game GUI
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

    local function padding(obj, left, right)
        local p = Instance.new("UIPadding")
        p.PaddingLeft = UDim.new(0, left or 8)
        p.PaddingRight = UDim.new(0, right or 8)
        p.Parent = obj
    end

    local function getRoot()
        local character = Player.Character or Player.CharacterAdded:Wait()
        local root = character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart", 5)
        return root
    end

    local function shortPos(v)
        return string.format("%.1f, %.1f, %.1f", v.X, v.Y, v.Z)
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
    Main.Size = UDim2.new(0, 370, 0, 310)
    Main.Position = UDim2.new(0.5, -185, 0.5, -155)
    Main.BackgroundColor3 = Color3.fromRGB(18, 22, 18)
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.ZIndex = 1000
    Main.Parent = Gui
    corner(Main, 10)
    stroke(Main, Color3.fromRGB(57, 255, 20), 2, 0.1)

    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 42)
    Header.BackgroundColor3 = Color3.fromRGB(25, 32, 25)
    Header.BorderSizePixel = 0
    Header.Active = true
    Header.ZIndex = 1001
    Header.Parent = Main
    corner(Header, 10)

    local HeaderCover = Instance.new("Frame")
    HeaderCover.Name = "HeaderCover"
    HeaderCover.Size = UDim2.new(1, 0, 0, 10)
    HeaderCover.Position = UDim2.new(0, 0, 1, -10)
    HeaderCover.BackgroundColor3 = Color3.fromRGB(25, 32, 25)
    HeaderCover.BorderSizePixel = 0
    HeaderCover.ZIndex = 1001
    HeaderCover.Parent = Header

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, -55, 1, 0)
    Title.Position = UDim2.new(0, 12, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "LOW HUB - SEED OVERLAY"
    Title.TextColor3 = Color3.fromRGB(57, 255, 20)
    Title.TextSize = 14
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.ZIndex = 1002
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
    CloseBtn.ZIndex = 1003
    CloseBtn.Parent = Header
    corner(CloseBtn, 6)

    local Status = Instance.new("TextLabel")
    Status.Name = "Status"
    Status.Size = UDim2.new(1, -24, 0, 60)
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
    Status.ZIndex = 1001
    Status.Parent = Main
    corner(Status, 6)
    padding(Status, 8, 8)

    local Info = Instance.new("TextLabel")
    Info.Name = "Info"
    Info.Size = UDim2.new(1, -24, 0, 45)
    Info.Position = UDim2.new(0, 12, 0, 125)
    Info.BackgroundColor3 = Color3.fromRGB(24, 28, 24)
    Info.BorderSizePixel = 0
    Info.Text = "Our GUI is separate from original GUI.\nRemote: PlayerTeleportTriggered(\"Seed Shop\")"
    Info.TextColor3 = Color3.fromRGB(150, 160, 150)
    Info.TextSize = 10
    Info.Font = Enum.Font.Gotham
    Info.TextXAlignment = Enum.TextXAlignment.Left
    Info.TextYAlignment = Enum.TextYAlignment.Center
    Info.TextWrapped = true
    Info.ZIndex = 1001
    Info.Parent = Main
    corner(Info, 6)
    padding(Info, 8, 8)

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
        b.ZIndex = 1001
        b.Parent = Main
        corner(b, 6)
        stroke(b, Color3.fromRGB(57, 255, 20), 1, 0.5)
        return b
    end

    local FireBtn = makeButton("FireBtn", "Fire Seed Remote", 12, 182, 346, 34, Color3.fromRGB(35, 55, 35))
    local ScanBtn = makeButton("ScanBtn", "Scan Original GUI", 12, 224, 168, 32, Color3.fromRGB(35, 45, 55))
    local ClickBtn = makeButton("ClickBtn", "Try Click Original Seed", 190, 224, 168, 32, Color3.fromRGB(55, 45, 35))
    local PosBtn = makeButton("PosBtn", "Print Position", 12, 264, 168, 30, Color3.fromRGB(45, 35, 55))
    local HideBtn = makeButton("HideBtn", "Hide Our GUI", 190, 264, 168, 30, Color3.fromRGB(45, 45, 45))

    local Icon = Instance.new("TextButton")
    Icon.Name = "OpenIcon"
    Icon.Size = UDim2.new(0, 50, 0, 50)
    Icon.Position = UDim2.new(0, 20, 0.5, -25)
    Icon.BackgroundColor3 = Color3.fromRGB(57, 255, 20)
    Icon.BorderSizePixel = 0
    Icon.Text = "LH"
    Icon.TextColor3 = Color3.fromRGB(0, 0, 0)
    Icon.TextSize = 15
    Icon.Font = Enum.Font.GothamBold
    Icon.Visible = false
    Icon.Active = true
    Icon.ZIndex = 2000
    Icon.Parent = Gui
    corner(Icon, 10)

    local function setStatus(text, color)
        Status.Text = "Status: " .. tostring(text)
        Status.TextColor3 = color or Color3.fromRGB(180, 180, 180)
    end

    local function fireSeedRemote()
        local remote, err = getTeleportRemote()

        if not remote then
            setStatus(err, Color3.fromRGB(255, 80, 80))
            warnlog(err)
            return false
        end

        local root = getRoot()
        local before = root and root.Position or nil

        setStatus("Firing Seed Shop remote...", Color3.fromRGB(255, 220, 80))

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

        log('Fired: PlayerTeleportTriggered("Seed Shop")')

        task.wait(1)

        local afterRoot = getRoot()
        if before and afterRoot then
            local after = afterRoot.Position
            local dist = (after - before).Magnitude

            log("Before: " .. shortPos(before))
            log("After: " .. shortPos(after))
            log("Distance: " .. tostring(math.floor(dist)))

            if dist >= 10 then
                setStatus("Moved " .. tostring(math.floor(dist)) .. " studs", Color3.fromRGB(57, 255, 20))
                return true
            else
                setStatus("Request sent, no movement. Pos: " .. shortPos(after), Color3.fromRGB(255, 150, 80))
                return false
            end
        end

        setStatus("Request sent", Color3.fromRGB(57, 255, 20))
        return true
    end

    local function objectText(obj)
        local text = ""

        pcall(function()
            if obj:IsA("TextButton") or obj:IsA("TextLabel") or obj:IsA("TextBox") then
                text = obj.Text or ""
            end
        end)

        return text
    end

    local function isSeedRelated(obj)
        local n = string.lower(obj.Name or "")
        local t = string.lower(objectText(obj) or "")

        if n:find("seed") then return true end
        if t:find("seed") then return true end
        if n:find("shop") and t:find("shop") then return true end
        if t:find("seed shop") then return true end

        return false
    end

    local function scanOriginalGui()
        local count = 0
        local firstButton = nil

        print("========== LOW HUB ORIGINAL GUI SCAN ==========")

        for _, obj in ipairs(PlayerGui:GetDescendants()) do
            if obj.Name ~= GUI_NAME and not obj:IsDescendantOf(Gui) then
                if isSeedRelated(obj) then
                    count = count + 1

                    local text = objectText(obj)

                    print("[" .. count .. "]")
                    print("Class:", obj.ClassName)
                    print("Name:", obj.Name)
                    print("Text:", text)
                    print("Path:", obj:GetFullName())

                    pcall(function()
                        print("Visible:", tostring(obj.Visible))
                    end)

                    pcall(function()
                        print("Active:", tostring(obj.Active))
                    end)

                    print("--------------------------------------")

                    if not firstButton then
                        if obj:IsA("TextButton") or obj:IsA("ImageButton") then
                            firstButton = obj
                        else
                            local p = obj.Parent
                            while p and p ~= PlayerGui do
                                if p:IsA("TextButton") or p:IsA("ImageButton") then
                                    firstButton = p
                                    break
                                end
                                p = p.Parent
                            end
                        end
                    end
                end
            end
        end

        print("Found seed/shop related objects:", count)
        print("===============================================")

        if firstButton then
            setStatus("Found button: " .. firstButton.Name, Color3.fromRGB(57, 255, 20))
            log("First possible button: " .. firstButton:GetFullName())
        else
            setStatus("Scan done. Found " .. tostring(count) .. " objects, no button", Color3.fromRGB(255, 220, 80))
        end

        return firstButton, count
    end

    local function findOriginalSeedButton()
        local best = nil

        for _, obj in ipairs(PlayerGui:GetDescendants()) do
            if not obj:IsDescendantOf(Gui) then
                if (obj:IsA("TextButton") or obj:IsA("ImageButton")) and isSeedRelated(obj) then
                    best = obj
                    break
                end
            end
        end

        if best then
            return best
        end

        for _, obj in ipairs(PlayerGui:GetDescendants()) do
            if not obj:IsDescendantOf(Gui) then
                if (obj:IsA("TextLabel") or obj:IsA("TextBox")) and isSeedRelated(obj) then
                    local p = obj.Parent

                    while p and p ~= PlayerGui do
                        if p:IsA("TextButton") or p:IsA("ImageButton") then
                            return p
                        end
                        p = p.Parent
                    end
                end
            end
        end

        return nil
    end

    local function tryClickOriginalSeed()
        local btn = findOriginalSeedButton()

        if not btn then
            local found
            found = scanOriginalGui()
            btn = found
        end

        if not btn then
            setStatus("Original Seed button not found", Color3.fromRGB(255, 80, 80))
            warnlog("Original Seed button not found")
            return
        end

        setStatus("Clicking original: " .. btn.Name, Color3.fromRGB(255, 220, 80))
        log("Click original button: " .. btn:GetFullName())

        local okSignal = false

        if firesignal then
            pcall(function()
                firesignal(btn.MouseButton1Click)
                okSignal = true
            end)
        end

        if not okSignal and getconnections then
            pcall(function()
                local cons = getconnections(btn.MouseButton1Click)
                for _, con in ipairs(cons) do
                    pcall(function()
                        con:Fire()
                    end)
                end
                okSignal = true
            end)
        end

        if okSignal then
            setStatus("Fired original button signal", Color3.fromRGB(57, 255, 20))
            return
        end

        local absPos = btn.AbsolutePosition
        local absSize = btn.AbsoluteSize

        local x = absPos.X + absSize.X / 2
        local y = absPos.Y + absSize.Y / 2

        pcall(function()
            VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
            task.wait(0.05)
            VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
        end)

        setStatus("Sent virtual click to original button", Color3.fromRGB(57, 255, 20))
    end

    FireBtn.MouseButton1Click:Connect(function()
        fireSeedRemote()
    end)

    ScanBtn.MouseButton1Click:Connect(function()
        scanOriginalGui()
    end)

    ClickBtn.MouseButton1Click:Connect(function()
        tryClickOriginalSeed()
    end)

    PosBtn.MouseButton1Click:Connect(function()
        local root = getRoot()
        if root then
            setStatus("Pos: " .. shortPos(root.Position), Color3.fromRGB(180, 220, 255))
            log("Position: " .. shortPos(root.Position))
        else
            setStatus("No HumanoidRootPart", Color3.fromRGB(255, 80, 80))
        end
    end)

    HideBtn.MouseButton1Click:Connect(function()
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
        setStatus("Ready. Our GUI loaded. Remote found.", Color3.fromRGB(57, 255, 20))
        log("Remote found: " .. remote:GetFullName())
    else
        setStatus(err, Color3.fromRGB(255, 80, 80))
        warnlog(err)
    end

    log("LowHub Seed Overlay loaded")
