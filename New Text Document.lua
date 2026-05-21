 -- LOW HUB - SEED SHOP TELEPORT
    -- LocalScript
    -- GUI + Close Button + Drag
    -- Fires exact event: PlayerTeleportTriggered("Seed Shop")

    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local UserInputService = game:GetService("UserInputService")

    local Player = Players.LocalPlayer
    local PlayerGui = Player:WaitForChild("PlayerGui")

    local GUI_NAME = "LowHubSeedShopTeleport"

    local old = PlayerGui:FindFirstChild(GUI_NAME)
    if old then
        old:Destroy()
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

    local function setPadding(obj, left, right)
        local p = Instance.new("UIPadding")
        p.PaddingLeft = UDim.new(0, left or 8)
        p.PaddingRight = UDim.new(0, right or 8)
        p.Parent = obj
    end

    local Gui = Instance.new("ScreenGui")
    Gui.Name = GUI_NAME
    Gui.ResetOnSpawn = false
    Gui.IgnoreGuiInset = false
    Gui.DisplayOrder = 999
    Gui.Parent = PlayerGui

    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 320, 0, 155)
    Main.Position = UDim2.new(0.5, -160, 0.5, -77)
    Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Parent = Gui
    corner(Main, 8)
    stroke(Main, Color3.fromRGB(57, 255, 20), 2, 0)

    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 42)
    Header.Position = UDim2.new(0, 0, 0, 0)
    Header.BackgroundColor3 = Color3.fromRGB(25, 32, 25)
    Header.BorderSizePixel = 0
    Header.Active = true
    Header.Parent = Main
    corner(Header, 8)

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
    Title.Text = "LOW HUB - SEED SHOP"
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
    Status.Size = UDim2.new(1, -24, 0, 36)
    Status.Position = UDim2.new(0, 12, 0, 55)
    Status.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Status.BorderSizePixel = 0
    Status.Text = "Status: Ready"
    Status.TextColor3 = Color3.fromRGB(180, 180, 180)
    Status.TextSize = 12
    Status.Font = Enum.Font.Gotham
    Status.TextXAlignment = Enum.TextXAlignment.Left
    Status.Parent = Main
    corner(Status, 6)
    setPadding(Status, 8, 8)

    local Button = Instance.new("TextButton")
    Button.Name = "SeedShopButton"
    Button.Size = UDim2.new(1, -24, 0, 42)
    Button.Position = UDim2.new(0, 12, 0, 102)
    Button.BackgroundColor3 = Color3.fromRGB(35, 55, 35)
    Button.BorderSizePixel = 0
    Button.Text = "Teleport to Seed Shop"
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextSize = 13
    Button.Font = Enum.Font.GothamBold
    Button.Parent = Main
    corner(Button, 6)
    stroke(Button, Color3.fromRGB(57, 255, 20), 1, 0.4)

    local function setStatus(text, color)
        Status.Text = "Status: " .. tostring(text)
        Status.TextColor3 = color or Color3.fromRGB(180, 180, 180)
    end

    local function fireSeedShop()
        local gameEvents = ReplicatedStorage:FindFirstChild("GameEvents")
        if not gameEvents then
            gameEvents = ReplicatedStorage:WaitForChild("GameEvents", 5)
        end

        if not gameEvents then
            setStatus("GameEvents not found", Color3.fromRGB(255, 80, 80))
            return
        end

        local remote = gameEvents:FindFirstChild("PlayerTeleportTriggered")
        if not remote then
            remote = gameEvents:WaitForChild("PlayerTeleportTriggered", 5)
        end

        if not remote then
            setStatus("Remote not found", Color3.fromRGB(255, 80, 80))
            return
        end

        if not remote:IsA("RemoteEvent") then
            setStatus("Not a RemoteEvent", Color3.fromRGB(255, 80, 80))
            return
        end

        setStatus("Sending Seed Shop...", Color3.fromRGB(255, 220, 80))

        local ok, err = pcall(function()
            local args = {
                "Seed Shop"
            }

            remote:FireServer(unpack(args))
        end)

        if ok then
            setStatus("Request sent: Seed Shop", Color3.fromRGB(57, 255, 20))

            print("[LowHub] Fired event:")
            print('local args = {')
            print('    "Seed Shop"')
            print('}')
            print('game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("PlayerTeleportTriggered"):FireServer(unpack(args))')
        else
            setStatus("FireServer error", Color3.fromRGB(255, 80, 80))
            warn("[LowHub] " .. tostring(err))
        end
    end

    Button.MouseButton1Click:Connect(function()
        fireSeedShop()
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

    print("[LowHub] Seed Shop GUI loaded")
