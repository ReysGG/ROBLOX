-- LOW HUB - SEED SHOP TELEPORT CHECK
    -- LocalScript
    -- Fires exact remote and checks player position

    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    local Player = Players.LocalPlayer
    local PlayerGui = Player:WaitForChild("PlayerGui")

    local GUI_NAME = "LowHubSeedShopCheck"

    local old = PlayerGui:FindFirstChild(GUI_NAME)
    if old then
        old:Destroy()
    end

    local Gui = Instance.new("ScreenGui")
    Gui.Name = GUI_NAME
    Gui.ResetOnSpawn = false
    Gui.DisplayOrder = 999
    Gui.Parent = PlayerGui

    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 320, 0, 150)
    Main.Position = UDim2.new(0.5, -160, 0.5, -75)
    Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Main.BorderSizePixel = 0
    Main.Parent = Gui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 8)
    MainCorner.Parent = Main

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(57, 255, 20)
    MainStroke.Thickness = 2
    MainStroke.Parent = Main

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -20, 0, 34)
    Title.Position = UDim2.new(0, 10, 0, 8)
    Title.BackgroundTransparency = 1
    Title.Text = "Seed Shop Teleport Check"
    Title.TextColor3 = Color3.fromRGB(57, 255, 20)
    Title.TextSize = 15
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Main

    local Status = Instance.new("TextLabel")
    Status.Size = UDim2.new(1, -20, 0, 40)
    Status.Position = UDim2.new(0, 10, 0, 42)
    Status.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Status.BorderSizePixel = 0
    Status.Text = "Status: Ready"
    Status.TextColor3 = Color3.fromRGB(180, 180, 180)
    Status.TextSize = 11
    Status.Font = Enum.Font.Gotham
    Status.TextXAlignment = Enum.TextXAlignment.Left
    Status.TextWrapped = true
    Status.Parent = Main

    local StatusCorner = Instance.new("UICorner")
    StatusCorner.CornerRadius = UDim.new(0, 6)
    StatusCorner.Parent = Status

    local StatusPad = Instance.new("UIPadding")
    StatusPad.PaddingLeft = UDim.new(0, 8)
    StatusPad.PaddingRight = UDim.new(0, 8)
    StatusPad.Parent = Status

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -20, 0, 44)
    Button.Position = UDim2.new(0, 10, 0, 94)
    Button.BackgroundColor3 = Color3.fromRGB(35, 55, 35)
    Button.BorderSizePixel = 0
    Button.Text = "Fire Seed Shop Event"
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextSize = 13
    Button.Font = Enum.Font.GothamBold
    Button.Parent = Main

    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 6)
    ButtonCorner.Parent = Button

    local function setStatus(text, color)
        Status.Text = "Status: " .. tostring(text)
        Status.TextColor3 = color or Color3.fromRGB(180, 180, 180)
    end

    local function getRoot()
        local character = Player.Character or Player.CharacterAdded:Wait()
        local root = character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart", 5)
        return root
    end

    local function fireSeedShop()
        local root = getRoot()

        if not root then
            setStatus("No HumanoidRootPart", Color3.fromRGB(255, 80, 80))
            return
        end

        local before = root.Position

        local gameEvents = ReplicatedStorage:WaitForChild("GameEvents", 5)

        if not gameEvents then
            setStatus("GameEvents not found", Color3.fromRGB(255, 80, 80))
            return
        end

        local remote = gameEvents:WaitForChild("PlayerTeleportTriggered", 5)

        if not remote then
            setStatus("PlayerTeleportTriggered not found", Color3.fromRGB(255, 80, 80))
            return
        end

        setStatus("Firing Seed Shop...", Color3.fromRGB(255, 220, 80))

        local ok, err = pcall(function()
            local args = {
                "Seed Shop"
            }

            remote:FireServer(unpack(args))
        end)

        if not ok then
            setStatus("FireServer error", Color3.fromRGB(255, 80, 80))
            warn("[LowHub] " .. tostring(err))
            return
        end

        print("[LowHub] Fired:")
        print('game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("PlayerTeleportTriggered"):FireServer("Seed Shop")')

        task.wait(1)

        local afterRoot = getRoot()

        if not afterRoot then
            setStatus("Request sent, no root after", Color3.fromRGB(255, 120, 80))
            return
        end

        local after = afterRoot.Position
        local distance = (after - before).Magnitude

        print("[LowHub] Before:", before)
        print("[LowHub] After:", after)
        print("[LowHub] Distance:", distance)

        if distance >= 10 then
            setStatus("Moved " .. tostring(math.floor(distance)) .. " studs", Color3.fromRGB(57, 255, 20))
        else
            setStatus("Event fired, but player did not move", Color3.fromRGB(255, 140, 80))
        end
    end

    Button.MouseButton1Click:Connect(function()
        fireSeedShop()
    end)

    print("[LowHub] Seed Shop check GUI loaded")
