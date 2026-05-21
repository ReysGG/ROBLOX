 -- LOW HUB - HONEY SEED SHOP UI TEST
    -- Opens EventShopUIController:Open("Honey Seed Shop")

    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local UserInputService = game:GetService("UserInputService")

    local Player = Players.LocalPlayer
    local PlayerGui = Player:WaitForChild("PlayerGui")

    local GUI_NAME = "LowHubHoneySeedShopTest"

    local old = PlayerGui:FindFirstChild(GUI_NAME)
    if old then
        old:Destroy()
    end

    local function corner(obj, r)
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, r or 8)
        c.Parent = obj
    end

    local Gui = Instance.new("ScreenGui")
    Gui.Name = GUI_NAME
    Gui.ResetOnSpawn = false
    Gui.DisplayOrder = 999999
    Gui.Parent = PlayerGui

    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 330, 0, 170)
    Main.Position = UDim2.new(0, 30, 0.5, -85)
    Main.BackgroundColor3 = Color3.fromRGB(14, 20, 14)
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Parent = Gui
    corner(Main, 10)

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(57, 255, 20)
    Stroke.Thickness = 2
    Stroke.Parent = Main

    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 40)
    Header.BackgroundColor3 = Color3.fromRGB(20, 34, 20)
    Header.BorderSizePixel = 0
    Header.Active = true
    Header.Parent = Main
    corner(Header, 10)

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -55, 1, 0)
    Title.Position = UDim2.new(0, 12, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "LOW HUB - HONEY SEED"
    Title.TextColor3 = Color3.fromRGB(57, 255, 20)
    Title.TextSize = 14
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Header

    local Close = Instance.new("TextButton")
    Close.Size = UDim2.new(0, 30, 0, 30)
    Close.Position = UDim2.new(1, -36, 0, 5)
    Close.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    Close.BorderSizePixel = 0
    Close.Text = "X"
    Close.TextColor3 = Color3.fromRGB(255, 255, 255)
    Close.TextSize = 14
    Close.Font = Enum.Font.GothamBold
    Close.Parent = Header
    corner(Close, 6)

    local Status = Instance.new("TextLabel")
    Status.Size = UDim2.new(1, -24, 0, 42)
    Status.Position = UDim2.new(0, 12, 0, 55)
    Status.BackgroundColor3 = Color3.fromRGB(24, 32, 24)
    Status.BorderSizePixel = 0
    Status.Text = "Status: Ready"
    Status.TextColor3 = Color3.fromRGB(190, 210, 190)
    Status.TextSize = 11
    Status.Font = Enum.Font.Gotham
    Status.TextXAlignment = Enum.TextXAlignment.Left
    Status.Parent = Main
    corner(Status, 6)

    local Pad = Instance.new("UIPadding")
    Pad.PaddingLeft = UDim.new(0, 8)
    Pad.PaddingRight = UDim.new(0, 8)
    Pad.Parent = Status

    local OpenBtn = Instance.new("TextButton")
    OpenBtn.Size = UDim2.new(1, -24, 0, 42)
    OpenBtn.Position = UDim2.new(0, 12, 0, 112)
    OpenBtn.BackgroundColor3 = Color3.fromRGB(35, 55, 35)
    OpenBtn.BorderSizePixel = 0
    OpenBtn.Text = "Open Honey Seed Shop"
    OpenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    OpenBtn.TextSize = 13
    OpenBtn.Font = Enum.Font.GothamBold
    OpenBtn.Parent = Main
    corner(OpenBtn, 6)

    local function setStatus(text, color)
        Status.Text = "Status: " .. tostring(text)
        Status.TextColor3 = color or Color3.fromRGB(190, 210, 190)
    end

    local function openHoneySeedShop()
        setStatus("Requiring EventShopUIController...", Color3.fromRGB(255, 220, 80))

        local ok, controller = pcall(function()
            return require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("EventShopUIController"))
        end)

        if not ok then
            setStatus("Require failed", Color3.fromRGB(255, 80, 80))
            warn("[LowHub] Require failed:", controller)
            return
        end

        setStatus("Opening Honey Seed Shop...", Color3.fromRGB(255, 220, 80))

        local openOk, openErr = pcall(function()
            controller:Open("Honey Seed Shop")
        end)

        if openOk then
            setStatus("Opened Honey Seed Shop", Color3.fromRGB(57, 255, 20))
            print("[LowHub] EventShopUIController:Open(\"Honey Seed Shop\")")
        else
            setStatus("Open failed", Color3.fromRGB(255, 80, 80))
            warn("[LowHub] Open failed:", openErr)
        end
    end

    OpenBtn.MouseButton1Click:Connect(function()
        openHoneySeedShop()
    end)

    Close.MouseButton1Click:Connect(function()
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

    print("[LowHub] Honey Seed Shop test GUI loaded")
