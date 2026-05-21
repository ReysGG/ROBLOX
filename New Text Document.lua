local Players = game:GetService("Players")
  local ReplicatedStorage = game:GetService("ReplicatedStorage")

  local player = Players.LocalPlayer
  local playerGui = player:WaitForChild("PlayerGui")

  local gameEvents = ReplicatedStorage:WaitForChild("GameEvents")
  local teleportRemote = gameEvents:WaitForChild("PlayerTeleportTriggered")

  local oldGui = playerGui:FindFirstChild("TeleportGui")
  if oldGui then
      oldGui:Destroy()
  end

  local screenGui = Instance.new("ScreenGui")
  screenGui.Name = "TeleportGui"
  screenGui.ResetOnSpawn = false
  screenGui.IgnoreGuiInset = true
  screenGui.Parent = playerGui

  local frame = Instance.new("Frame")
  frame.Name = "Main"
  frame.Size = UDim2.new(0, 260, 0, 145)
  frame.Position = UDim2.new(0, 30, 0, 130)
  frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
  frame.BorderSizePixel = 0
  frame.Active = true
  frame.Draggable = true
  frame.Parent = screenGui

  local frameCorner = Instance.new("UICorner")
  frameCorner.CornerRadius = UDim.new(0, 10)
  frameCorner.Parent = frame

  local title = Instance.new("TextLabel")
  title.Name = "Title"
  title.Size = UDim2.new(1, -45, 0, 35)
  title.Position = UDim2.new(0, 12, 0, 0)
  title.BackgroundTransparency = 1
  title.Text = "Teleport GUI"
  title.TextColor3 = Color3.fromRGB(255, 255, 255)
  title.TextSize = 17
  title.Font = Enum.Font.GothamBold
  title.TextXAlignment = Enum.TextXAlignment.Left
  title.Parent = frame

  local closeButton = Instance.new("TextButton")
  closeButton.Name = "Close"
  closeButton.Size = UDim2.new(0, 30, 0, 30)
  closeButton.Position = UDim2.new(1, -36, 0, 4)
  closeButton.BackgroundColor3 = Color3.fromRGB(190, 60, 60)
  closeButton.Text = "X"
  closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
  closeButton.TextSize = 14
  closeButton.Font = Enum.Font.GothamBold
  closeButton.Parent = frame

  local closeCorner = Instance.new("UICorner")
  closeCorner.CornerRadius = UDim.new(0, 8)
  closeCorner.Parent = closeButton

  local seedButton = Instance.new("TextButton")
  seedButton.Name = "SeedShopButton"
  seedButton.Size = UDim2.new(1, -24, 0, 42)
  seedButton.Position = UDim2.new(0, 12, 0, 48)
  seedButton.BackgroundColor3 = Color3.fromRGB(70, 130, 255)
  seedButton.Text = "Teleport: Seed Shop"
  seedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
  seedButton.TextSize = 15
  seedButton.Font = Enum.Font.GothamSemibold
  seedButton.Parent = frame

  local seedCorner = Instance.new("UICorner")
  seedCorner.CornerRadius = UDim.new(0, 8)
  seedCorner.Parent = seedButton

  local status = Instance.new("TextLabel")
  status.Name = "Status"
  status.Size = UDim2.new(1, -24, 0, 30)
  status.Position = UDim2.new(0, 12, 0, 100)
  status.BackgroundTransparency = 1
  status.Text = "Ready"
  status.TextColor3 = Color3.fromRGB(200, 200, 200)
  status.TextSize = 13
  status.Font = Enum.Font.Gotham
  status.TextXAlignment = Enum.TextXAlignment.Left
  status.Parent = frame

  local function teleportSeedShop()
      local args = {
          "Seed Shop"
      }

      status.Text = "Mengirim teleport..."

      local success, err = pcall(function()
          teleportRemote:FireServer(unpack(args))
      end)

      if success then
          status.Text = "Request terkirim: Seed Shop"
      else
          status.Text = "Gagal: " .. tostring(err)
      end
  end

  seedButton.MouseButton1Click:Connect(teleportSeedShop)

  closeButton.MouseButton1Click:Connect(function()
      screenGui:Destroy()
  end)
