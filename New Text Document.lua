 -- LOW HUB - SEED SHOP TELEPORT
    -- LocalScript
    -- Only fires ReplicatedStorage.GameEvents.PlayerTeleportTriggered("Seed Shop")

    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    local Player = Players.LocalPlayer
    local PlayerGui = Player:WaitForChild("PlayerGui")

    local GUI_NAME = "LowHubSeedShopTeleport"

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
    Main.Size = UDim2.new(0, 280, 0, 130)
    Main.Position = UDim2.new(0.5, -140, 0.5, -65)
    Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Main.BorderSizePixel = 0
    Main.Parent = Gui

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Main

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(57, 255, 20)
    Stroke.Thickness = 2
    Stroke.Parent = Main

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -20, 0, 35)
    Title.Position = UDim2.new(0, 10, 0, 8)
    Title.BackgroundTransparency = 1
    Title.Text = "Seed Shop Teleport"
    Title.TextColor3 = Color3.fromRGB(57, 255, 20)
    Title.TextSize = 16
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Main

    local Status = Instance.new("TextLabel")
    Status.Size = UDim2.new(1, -20, 0, 24)
    Status.Position = UDim2.new(0, 10, 0, 42)
    Status.BackgroundTransparency = 1
    Status.Text = "Status: Ready"
    Status.TextColor3 = Color3.fromRGB(180, 180, 180)
    Status.TextSize = 12
    Status.Font = Enum.Font.Gotham
    Status.TextXAlignment = Enum.TextXAlignment.Left
    Status.Parent = Main

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -20, 0, 42)
    Button.Position = UDim2.new(0, 10, 0, 76)
    Button.BackgroundColor3 = Color3.fromRGB(35, 55, 35)
    Button.BorderSizePixel = 0
    Button.Text = "Teleport to Seed Shop"
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextSize = 14
    Button.Font = Enum.Font.GothamBold
    Button.Parent = Main

    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 6)
    ButtonCorner.Parent = Button

    local function setStatus(text, color)
        Status.Text = "Status: " .. tostring(text)
        Status.TextColor3 = color or Color3.fromRGB(180, 180, 180)
    end

    local function teleportSeedShop()
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

        if not remote:IsA("RemoteEvent") then
            setStatus("Remote is not RemoteEvent", Color3.fromRGB(255, 80, 80))
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
            print("[LowHub] Fired PlayerTeleportTriggered with arg: Seed Shop")
        else
            setStatus("FireServer error", Color3.fromRGB(255, 80, 80))
            warn("[LowHub] " .. tostring(err))
        end
    end

    Button.MouseButton1Click:Connect(function()
        teleportSeedShop()
    end)

    print("[LowHub] Seed Shop GUI loaded")
