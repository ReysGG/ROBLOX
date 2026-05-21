 -- LOW HUB - SEED GUI INVESTIGATOR
    -- LocalScript / client script
    -- Separate overlay GUI
    -- Does not destroy original game GUI
    -- ASCII only

    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local UserInputService = game:GetService("UserInputService")
    local VirtualInputManager = game:GetService("VirtualInputManager")

    local Player = Players.LocalPlayer
    local PlayerGui = Player:WaitForChild("PlayerGui")

    local GUI_NAME = "LowHubSeedInvestigator"
    local DESTINATION = "Seed Shop"

    local ScannedButtons = {}

    local function log(msg)
        print("[LowHubSeed] " .. tostring(msg))
    end

    local function warnlog(msg)
        warn("[LowHubSeed] " .. tostring(msg))
    end

    local function destroyOld()
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

    local function shortPos(v)
        return string.format("%.1f, %.1f, %.1f", v.X, v.Y, v.Z)
    end

    local function getRoot()
        local character = Player.Character or Player.CharacterAdded:Wait()
        local root = character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart", 5)
        return root
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

    local function getText(obj)
        local text = ""

        pcall(function()
            if obj:IsA("TextButton") or obj:IsA("TextLabel") or obj:IsA("TextBox") then
                text = obj.Text or ""
            end
        end)

        return text
    end

    local function getParentChain(obj)
        local parts = {}
        local current = obj

        while current and current ~= game do
            table.insert(parts, 1, current.Name)
            current = current.Parent
        end

        return table.concat(parts, ".")
    end

    local function hasAncestorName(obj, keyword)
        local current = obj

        keyword = string.lower(keyword)

        while current and current ~= game do
            if string.lower(current.Name or ""):find(keyword) then
                return true
            end
            current = current.Parent
        end

        return false
    end

    local function isVisibleChain(obj)
        local current = obj

        while current and current ~= game do
            if current:IsA("GuiObject") then
                if current.Visible == false then
                    return false
                end
            end
            current = current.Parent
        end

        return true
    end

    local function safeAbsPos(obj)
        local ok, result = pcall(function()
            return obj.AbsolutePosition
        end)

        if ok then
            return result
        end

        return Vector2.new(0, 0)
    end

    local function safeAbsSize(obj)
        local ok, result = pcall(function()
            return obj.AbsoluteSize
        end)

        if ok then
            return result
        end

        return Vector2.new(0, 0)
    end

    local function isLikelyClickable(obj)
        if obj:IsA("TextButton") or obj:IsA("ImageButton") then
            return true
        end

        return false
    end

    local function scanButtons(filterMode)
        ScannedButtons = {}

        print("========== LOW HUB SEED GUI SCAN ==========")
        print("FilterMode:", tostring(filterMode))
        print("Time:", os.date("%X"))
        print("-------------------------------------------")

        local roots = {
            PlayerGui
        }

        pcall(function()
            table.insert(roots, game:GetService("CoreGui"))
        end)

        local printed = 0

        for _, root in ipairs(roots) do
            print("ROOT:", root:GetFullName())

            for _, obj in ipairs(root:GetDescendants()) do
                local include = false

                if isLikelyClickable(obj) then
                    include = true
                end

                if filterMode == "main_frame" then
                    include = include and hasAncestorName(obj, "main_frame")
                elseif filterMode == "seed_shop_related" then
                    local text = string.lower(getText(obj) or "")
                    local name = string.lower(obj.Name or "")
                    include = include and (
                        text:find("seed") or
                        text:find("shop") or
                        name:find("seed") or
                        name:find("shop") or
                        hasAncestorName(obj, "seed") or
                        hasAncestorName(obj, "shop")
                    )
                end

                if include then
                    local absPos = safeAbsPos(obj)
                    local absSize = safeAbsSize(obj)
                    local text = getText(obj)
                    local visible = isVisibleChain(obj)
                    local sizeOk = absSize.X > 0 and absSize.Y > 0

                    table.insert(ScannedButtons, obj)
                    printed = printed + 1

                    print("[" .. tostring(#ScannedButtons) .. "]")
                    print("Class:", obj.ClassName)
                    print("Name:", obj.Name)
                    print("Text:", text)
                    print("Path:", obj:GetFullName())
                    print("Chain:", getParentChain(obj))
                    print("VisibleChain:", tostring(visible))
                    print("SizeOK:", tostring(sizeOk))
                    print("AbsolutePosition:", tostring(absPos))
                    print("AbsoluteSize:", tostring(absSize))

                    pcall(function()
                        print("Active:", tostring(obj.Active))
                    end)

                    pcall(function()
                        print("Selectable:", tostring(obj.Selectable))
                    end)

                    pcall(function()
                        print("AutoButtonColor:", tostring(obj.AutoButtonColor))
                    end)

                    print("-------------------------------------------")
                end
            end
        end

        print("TOTAL SCANNED BUTTONS:", tostring(#ScannedButtons))
        print("===========================================")

        return #ScannedButtons
    end

    local function scanGuiObjectsByMainFrame()
        print("========== LOW HUB MAIN_FRAME OBJECT SCAN ==========")

        local count = 0

        for _, obj in ipairs(PlayerGui:GetDescendants()) do
            if hasAncestorName(obj, "main_frame") then
                if obj:IsA("GuiObject") then
                    count = count + 1
                    local text = getText(obj)
                    local absPos = safeAbsPos(obj)
                    local absSize = safeAbsSize(obj)

                    print("[" .. tostring(count) .. "]")
                    print("Class:", obj.ClassName)
                    print("Name:", obj.Name)
                    print("Text:", text)
                    print("Path:", obj:GetFullName())
                    print("VisibleChain:", tostring(isVisibleChain(obj)))
                    print("AbsolutePosition:", tostring(absPos))
                    print("AbsoluteSize:", tostring(absSize))
                    print("-------------------------------------------")
                end
            end
        end

        print("TOTAL MAIN_FRAME GUIOBJECTS:", tostring(count))
        print("====================================================")

        return count
    end

    destroyOld()

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
    Main.Size = UDim2.new(0, 390, 0, 390)
    Main.Position = UDim2.new(0.5, -195, 0.5, -195)
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
    Title.Text = "LOW HUB - SEED INVESTIGATOR"
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
    Status.Size = UDim2.new(1, -24, 0, 66)
    Status.Position = UDim2.new(0, 12, 0, 55)
    Status.BackgroundColor3 = Color3.fromRGB(30, 35, 30)
    Status.BorderSizePixel = 0
    Status.Text = "Status: Ready. Use Scan buttons, then send output."
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
    Info.Size = UDim2.new(1, -24, 0, 48)
    Info.Position = UDim2.new(0, 12, 0, 130)
    Info.BackgroundColor3 = Color3.fromRGB(24, 28, 24)
    Info.BorderSizePixel = 0
    Info.Text = "Scan output appears in console.\nThen use index to click a scanned button."
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
        b.TextSize = 11
        b.Font = Enum.Font.GothamBold
        b.ZIndex = 1001
        b.Parent = Main
        corner(b, 6)
        stroke(b, Color3.fromRGB(57, 255, 20), 1, 0.5)
        return b
    end

    local ScanAllBtn = makeButton("ScanAllBtn", "Scan All Buttons", 12, 190, 178, 32, Color3.fromRGB(35, 45, 55))
    local ScanMainBtn = makeButton("ScanMainBtn", "Scan main_frame", 200, 190, 178, 32, Color3.fromRGB(35, 45, 55))
    local ScanObjBtn = makeButton("ScanObjBtn", "Scan main_frame Objects", 12, 230, 366, 32, Color3.fromRGB(45, 45, 55))
    local FireSeedBtn = makeButton("FireSeedBtn", "Fire Seed Remote", 12, 270, 178, 32, Color3.fromRGB(35, 55, 35))
    local PosBtn = makeButton("PosBtn", "Print Position", 200, 270, 178, 32, Color3.fromRGB(45, 35, 55))

    local IndexBox = Instance.new("TextBox")
    IndexBox.Name = "IndexBox"
    IndexBox.Size = UDim2.new(0, 110, 0, 32)
    IndexBox.Position = UDim2.new(0, 12, 0, 312)
    IndexBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    IndexBox.BorderSizePixel = 0
    IndexBox.Text = "1"
    IndexBox.PlaceholderText = "Index"
    IndexBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    IndexBox.PlaceholderColor3 = Color3.fromRGB(140, 140, 140)
    IndexBox.TextSize = 12
    IndexBox.Font = Enum.Font.Gotham
    IndexBox.ZIndex = 1001
    IndexBox.Parent = Main
    corner(IndexBox, 6)
    stroke(IndexBox, Color3.fromRGB(57, 255, 20), 1, 0.7)

    local ClickIndexBtn = makeButton("ClickIndexBtn", "Click Index", 132, 312, 116, 32, Color3.fromRGB(55, 45, 35))
    local PrintIndexBtn = makeButton("PrintIndexBtn", "Print Index", 260, 312, 118, 32, Color3.fromRGB(45, 45, 35))
    local HideBtn = makeButton("HideBtn", "Hide Our GUI", 12, 352, 366, 28, Color3.fromRGB(45, 45, 45))

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
            return
        end

        local before = nil
        local root = getRoot()
        if root then
            before = root.Position
        end

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
            return
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
            else
                setStatus("Request sent, no movement. Pos: " .. shortPos(after), Color3.fromRGB(255, 150, 80))
            end
        else
            setStatus("Request sent", Color3.fromRGB(57, 255, 20))
        end
    end

    local function printPosition()
        local root = getRoot()

        if root then
            setStatus("Pos: " .. shortPos(root.Position), Color3.fromRGB(180, 220, 255))
            log("Position: " .. shortPos(root.Position))
        else
            setStatus("No HumanoidRootPart", Color3.fromRGB(255, 80, 80))
        end
    end

    local function getIndex()
        local n = tonumber(IndexBox.Text)
        if not n then
            return nil
        end

        return math.floor(n)
    end

    local function printButtonAtIndex()
        local idx = getIndex()

        if not idx then
            setStatus("Invalid index", Color3.fromRGB(255, 80, 80))
            return
        end

        local obj = ScannedButtons[idx]

        if not obj then
            setStatus("No button at index " .. tostring(idx), Color3.fromRGB(255, 80, 80))
            return
        end

        print("========== LOW HUB BUTTON INDEX ==========")
        print("Index:", idx)
        print("Class:", obj.ClassName)
        print("Name:", obj.Name)
        print("Text:", getText(obj))
        print("Path:", obj:GetFullName())
        print("Chain:", getParentChain(obj))
        print("VisibleChain:", tostring(isVisibleChain(obj)))
        print("AbsolutePosition:", tostring(safeAbsPos(obj)))
        print("AbsoluteSize:", tostring(safeAbsSize(obj)))
        print("==========================================")

        setStatus("Printed index " .. tostring(idx) .. ": " .. obj.Name, Color3.fromRGB(180, 220, 255))
    end

    local function clickButtonAtIndex()
        local idx = getIndex()

        if not idx then
            setStatus("Invalid index", Color3.fromRGB(255, 80, 80))
            return
        end

        local obj = ScannedButtons[idx]

        if not obj then
            setStatus("No button at index " .. tostring(idx), Color3.fromRGB(255, 80, 80))
            return
        end

        setStatus("Clicking index " .. tostring(idx) .. ": " .. obj.Name, Color3.fromRGB(255, 220, 80))
        log("Click index " .. tostring(idx) .. ": " .. obj:GetFullName())

        local usedSignal = false

        if firesignal then
            pcall(function()
                firesignal(obj.MouseButton1Click)
                usedSignal = true
            end)
        end

        if not usedSignal and getconnections then
            pcall(function()
                local cons = getconnections(obj.MouseButton1Click)
                log("Connections: " .. tostring(#cons))

                for _, con in ipairs(cons) do
                    pcall(function()
                        con:Fire()
                    end)
                end

                usedSignal = true
            end)
        end

        if usedSignal then
            setStatus("Fired signal for index " .. tostring(idx), Color3.fromRGB(57, 255, 20))
            return
        end

        local pos = safeAbsPos(obj)
        local size = safeAbsSize(obj)

        if size.X <= 0 or size.Y <= 0 then
            setStatus("Button has zero size", Color3.fromRGB(255, 80, 80))
            return
        end

        local x = pos.X + size.X / 2
        local y = pos.Y + size.Y / 2

        pcall(function()
            VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
            task.wait(0.05)
            VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
        end)

        setStatus("Virtual clicked index " .. tostring(idx), Color3.fromRGB(57, 255, 20))
    end

    ScanAllBtn.MouseButton1Click:Connect(function()
        local count = scanButtons("all")
        setStatus("Scan All done. Buttons: " .. tostring(count) .. ". Send console output.", Color3.fromRGB(57, 255, 20))
    end)

    ScanMainBtn.MouseButton1Click:Connect(function()
        local count = scanButtons("main_frame")
        setStatus("Scan main_frame done. Buttons: " .. tostring(count) .. ". Send console output.", Color3.fromRGB(57, 255, 20))
    end)

    ScanObjBtn.MouseButton1Click:Connect(function()
        local count = scanGuiObjectsByMainFrame()
        setStatus("main_frame object scan done. Objects: " .. tostring(count), Color3.fromRGB(57, 255, 20))
    end)

    FireSeedBtn.MouseButton1Click:Connect(function()
        fireSeedRemote()
    end)

    PosBtn.MouseButton1Click:Connect(function()
        printPosition()
    end)

    ClickIndexBtn.MouseButton1Click:Connect(function()
        clickButtonAtIndex()
    end)

    PrintIndexBtn.MouseButton1Click:Connect(function()
        printButtonAtIndex()
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
        setStatus("Ready. Remote found. Start with Scan main_frame.", Color3.fromRGB(57, 255, 20))
        log("Remote found: " .. remote:GetFullName())
    else
        setStatus(err, Color3.fromRGB(255, 80, 80))
        warnlog(err)
    end

    log("LowHub Seed Investigator loaded")
