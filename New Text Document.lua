-- LOW HUB - TELEPORT GUI
    -- Put this LocalScript in StarterGui or StarterPlayerScripts

    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    local Player = Players.LocalPlayer
    local PlayerGui = Player:WaitForChild("PlayerGui")

    local GUI_NAME = "LowHub"

    -- Remove old GUI if exists
    local oldGui = PlayerGui:FindFirstChild(GUI_NAME)
    if oldGui then
        oldGui:Destroy()
    end

    -- Remote
    local GameEvents = ReplicatedStorage:WaitForChild("GameEvents")
    local TeleportRemote = GameEvents:WaitForChild("PlayerTeleportTriggered")

    local function TeleportToGarden()
        local args = {
            "Farm"
        }

        local success, err = pcall(function()
            TeleportRemote:FireServer(unpack(args))
        end)

        if success then
            print("[Low Hub] Teleport to Garden sent")
        else
            warn("[Low Hub] Teleport failed:", err)
        end
    end

    -- GUI
    local Gui = Instance.new("ScreenGui")
    Gui.Name = GUI_NAME
    Gui.ResetOnSpawn = false
    Gui.Parent = PlayerGui

    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 280, 0, 160)
    Main.Position = UDim2.new(0.5, -140, 0.5, -80)
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

    -- Header
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
    Title.Size = UDim2.new(1, -50, 1, 0)
    Title.Position = UDim2.new(0, 12, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "LOW HUB"
    Title.TextColor3 = Color3.fromRGB(0, 255, 0)
    Title.TextSize = 16
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

    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 6)
    CloseCorner.Parent = CloseBtn

    CloseBtn.MouseButton1Click:Connect(function()
        Gui:Destroy()
    end)

    -- Status text
    local Status = Instance.new("TextLabel")
    Status.Name = "Status"
    Status.Size = UDim2.new(1, -24, 0, 28)
    Status.Position = UDim2.new(0, 12, 0, 52)
    Status.BackgroundTransparency = 1
    Status.Text = "Ready"
    Status.TextColor3 = Color3.fromRGB(200, 200, 200)
    Status.TextSize = 12
    Status.Font = Enum.Font.Gotham
    Status.TextXAlignment = Enum.TextXAlignment.Left
    Status.Parent = Main

    -- Teleport button
    local GardenBtn = Instance.new("TextButton")
    GardenBtn.Name = "GardenButton"
    GardenBtn.Size = UDim2.new(1, -24, 0, 42)
    GardenBtn.Position = UDim2.new(0, 12, 0, 92)
    GardenBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
    GardenBtn.BorderSizePixel = 0
    GardenBtn.Text = "Teleport to Garden"
    GardenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    GardenBtn.TextSize = 13
    GardenBtn.Font = Enum.Font.GothamBold
    GardenBtn.Parent = Main

    local GardenCorner = Instance.new("UICorner")
    GardenCorner.CornerRadius = UDim.new(0, 6)
    GardenCorner.Parent = GardenBtn

    local GardenStroke = Instance.new("UIStroke")
    GardenStroke.Color = Color3.fromRGB(0, 140, 0)
    GardenStroke.Thickness = 1
    GardenStroke.Parent = GardenBtn

    GardenBtn.MouseButton1Click:Connect(function()
        Status.Text = "Teleporting..."
        Status.TextColor3 = Color3.fromRGB(255, 255, 100)

        TeleportToGarden()

        Status.Text = "Teleport request sent"
        Status.TextColor3 = Color3.fromRGB(0, 255, 0)

        task.delay(2, function()
            if Status and Status.Parent then
                Status.Text = "Ready"
                Status.TextColor3 = Color3.fromRGB(200, 200, 200)
            end
        end)
    end)

    print("[Low Hub] GUI loaded")
