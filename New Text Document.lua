local Players = game:GetService("Players")
  local ReplicatedStorage = game:GetService("ReplicatedStorage")

  local player = Players.LocalPlayer
  local playerGui = player:WaitForChild("PlayerGui")

  local remote = ReplicatedStorage
      :WaitForChild("GameEvents")
      :WaitForChild("PlayerTeleportTriggered")

  local teleportList = {
      "Seed Shop",
  }

  local oldGui = playerGui:FindFirstChild("TeleportGui")
  if oldGui then
      oldGui:Destroy()
  end

  local screenGui = Instance.new("ScreenGui")
  screenGui.Name = "TeleportGui"
  screenGui.ResetOnSpawn = false
  screenGui.IgnoreGuiInset = true
  screenGui.Parent = playerGui

  local mainFrame = Instance.new("Frame")
  mainFrame.Name = "MainFrame"
  mainFrame.Size = UDim2.new(0, 240, 0, 160)
  mainFrame.Position = UDim2.new(0, 25, 0, 120)
  mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
  mainFrame.BorderSizePixel = 0
  mainFrame.Active = true
  mainFrame.Draggable = true
  mainFrame.Parent = screenGui

  local corner = Instance.new("UICorner")
  corner.CornerRadius = UDim.new(0, 10)
  corner.Parent = mainFrame

  local title = Instance.new("TextLabel")
  title.Name = "Title"
  title.Size = UDim2.new(1, -40, 0, 35)
  title.Position = UDim2.new(0, 10, 0, 0)
  title.BackgroundTransparency = 1
  title.Text = "Teleport GUI"
  title.TextColor3 = Color3.fromRGB(255, 255, 255)
  title.TextSize = 17
  title.Font = Enum.Font.GothamBold
  title.TextXAlignment = Enum.TextXAlignment.Left
  title.Parent = mainFrame

  local closeButton = Instance.new("TextButton")
  closeButton.Name = "CloseButton"
  closeButton.Size = UDim2.new(0, 30, 0, 30)
  closeButton.Position = UDim2.new(1, -35, 0, 3)
  closeButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
  closeButton.Text = "X"
  closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
  closeButton.TextSize = 14
  closeButton.Font = Enum.Font.GothamBold
  closeButton.Parent = mainFrame

  local closeCorner = Instance.new("UICorner")
  closeCorner.CornerRadius = UDim.new(0, 8)
  closeCorner.Parent = closeButton

  local container = Instance.new("Frame")
  container.Name = "Container"
  container.Size = UDim2.new(1, -20, 1, -50)
  container.Position = UDim2.new(0, 10, 0, 42)
  container.BackgroundTransparency = 1
  container.Parent = mainFrame

  local layout = Instance.new("UIListLayout")
  layout.Padding = UDim.new(0, 8)
  layout.SortOrder = Enum.SortOrder.LayoutOrder
  layout.Parent = container

  local function teleport(locationName)
      remote:FireServer(locationName)
  end

  local function createTeleportButton(locationName)
      local button = Instance.new("TextButton")
      button.Name = locationName:gsub("%s+", "") .. "Button"
      button.Size = UDim2.new(1, 0, 0, 38)
      button.BackgroundColor3 = Color3.fromRGB(70, 130, 255)
      button.Text = locationName
      button.TextColor3 = Color3.fromRGB(255, 255, 255)
      button.TextSize = 15
      button.Font = Enum.Font.GothamSemibold
      button.Parent = container

      local buttonCorner = Instance.new("UICorner")
      buttonCorner.CornerRadius = UDim.new(0, 8)
      buttonCorner.Parent = button

      button.MouseButton1Click:Connect(function()
          teleport(locationName)
      end)
  end

  for _, locationName in ipairs(teleportList) do
      createTeleportButton(locationName)
  end

  closeButton.MouseButton1Click:Connect(function()
      screenGui:Destroy()
  end)
