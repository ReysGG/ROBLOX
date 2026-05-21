 -- LOW HUB - OUR SEPARATE GUI
    -- LocalScript / client script
    -- This only creates our overlay GUI.
    -- It does not remove or modify original game GUI.

    local Players = game:GetService("Players")
    local UserInputService = game:GetService("UserInputService")

    local Player = Players.LocalPlayer
    local PlayerGui = Player:WaitForChild("PlayerGui")

    local GUI_NAME = "LowHubSeedOverlay"

    local function log(msg)
        print("[LowHubSeedOverlay] " .. tostring(msg))
    end

    -- Remove only our old GUI, not original GUI
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

    local function padding(obj, left, right, top, bottom)
        local p = Instance.new("UIPadding")
        p.PaddingLeft = UDim.new(0, left or 8)
        p.PaddingRight = UDim.new(0, right or 8)
        p.PaddingTop = UDim.new(0, top or 0)
        p.PaddingBottom = UDim.new(0, bottom or 0)
        p.Parent = obj
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
    Main.Size = UDim2.new(0, 340, 0, 230)
    Main.Position = UDim2.new(0, 30, 0.5, -115)
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
    Header.Position = UDim2.new(0, 0, 0, 0)
    Header.BackgroundColor3 = Color3.fromRGB(20, 34, 20)
    Header.BorderSizePixel = 0
    Header.Active = true
    Header.ZIndex = 1001
    Header.Parent = Main
    corner(Header, 10)

    local HeaderCover = Instance.new("Frame")
    HeaderCover.Name = "HeaderCover"
    HeaderCover.Size = UDim2.new(1, 0, 0, 10)
    HeaderCover.Position = UDim2.new(0, 0, 1, -10)
    HeaderCover.BackgroundColor3 = Color3.fromRGB(20, 34, 20)
    HeaderCover.BorderSizePixel = 0
    HeaderCover.ZIndex = 1001
    HeaderCover.Parent = Header

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
    Title.Size = UDim2.new(1, -120, 1, 0)
    Title.Position = UDim2.new(0, 50, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "LOW HUB - OUR GUI"
    Title.TextColor3 = Color3.fromRGB(57, 255, 20)
    Title.TextSize = 14
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
    Status.Size = UDim2.new(1, -24, 0, 50)
    Status.Position = UDim2.new(0, 12, 0, 58)
    Status.BackgroundColor3 = Color3.fromRGB(24, 32, 24)
    Status.BorderSizePixel = 0
    Status.Text = "Status: Our GUI loaded. Original GUI untouched."
    Status.TextColor3 = Color3.fromRGB(190, 210, 190)
    Status.TextSize = 11
    Status.Font = Enum.Font.Gotham
    Status.TextXAlignment = Enum.TextXAlignment.Left
    Status.TextWrapped = true
    Status.ZIndex = 1001
    Status.Parent = Main
    corner(Status, 6)
    padding(Status, 8, 8, 0, 0)

    local Info = Instance.new("TextLabel")
    Info.Name = "Info"
    Info.Size = UDim2.new(1, -24, 0, 70)
    Info.Position = UDim2.new(0, 12, 0, 118)
    Info.BackgroundColor3 = Color3.fromRGB(20, 26, 20)
    Info.BorderSizePixel = 0
    Info.Text = "This is LOW HUB overlay.\nIt is separate from the original game GUI.\nUse this area later for Seed tools/debug."
    Info.TextColor3 = Color3.fromRGB(150, 170, 150)
    Info.TextSize = 11
    Info.Font = Enum.Font.Gotham
    Info.TextXAlignment = Enum.TextXAlignment.Left
    Info.TextYAlignment = Enum.TextYAlignment.Center
    Info.TextWrapped = true
    Info.ZIndex = 1001
    Info.Parent = Main
    corner(Info, 6)
    padding(Info, 8, 8, 0, 0)

    local TestBtn = Instance.new("TextButton")
    TestBtn.Name = "TestButton"
    TestBtn.Size = UDim2.new(1, -24, 0, 30)
    TestBtn.Position = UDim2.new(0, 12, 0, 198)
    TestBtn.BackgroundColor3 = Color3.fromRGB(35, 55, 35)
    TestBtn.BorderSizePixel = 0
    TestBtn.Text = "Test Button - Our GUI"
    TestBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    TestBtn.TextSize = 12
    TestBtn.Font = Enum.Font.GothamBold
    TestBtn.ZIndex = 1001
    TestBtn.Parent = Main
    corner(TestBtn, 6)
    stroke(TestBtn, Color3.fromRGB(57, 255, 20), 1, 0.45)

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
    stroke(Icon, Color3.fromRGB(0, 0, 0), 1, 0.65)

    local function setStatus(text, color)
        Status.Text = "Status: " .. tostring(text)
        Status.TextColor3 = color or Color3.fromRGB(190, 210, 190)
    end

    TestBtn.MouseButton1Click:Connect(function()
        setStatus("Our GUI button clicked.", Color3.fromRGB(57, 255, 20))
        log("Our GUI test button clicked")
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

    log("Our separate GUI loaded")
