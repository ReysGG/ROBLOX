local ReplicatedStorage = game:GetService("ReplicatedStorage")
  local Players = game:GetService("Players")
  local RunService = game:GetService("RunService")

  local EVENT_FOLDER_NAME = "GameEvents"
  local EVENT_NAME = "PlayerTeleportTriggered"

  local teleportLocations = {
      ["Seed Shop"] = CFrame.new(0, 5, 0),
      ["Sell Shop"] = CFrame.new(50, 5, 0),
      ["Farm"] = CFrame.new(-50, 5, 0),
  }

  local function getRemoteEvent()
      local folder = ReplicatedStorage:FindFirstChild(EVENT_FOLDER_NAME)

      if not folder and RunService:IsServer() then
          folder = Instance.new("Folder")
          folder.Name = EVENT_FOLDER_NAME
          folder.Parent = ReplicatedStorage
      end

      if not folder then
          folder = ReplicatedStorage:WaitForChild(EVENT_FOLDER_NAME)
      end

      local remote = folder:FindFirstChild(EVENT_NAME)

      if not remote and RunService:IsServer() then
          remote = Instance.new("RemoteEvent")
          remote.Name = EVENT_NAME
          remote.Parent = folder
      end

      if not remote then
          remote = folder:WaitForChild(EVENT_NAME)
      end

      return remote
  end

  if RunService:IsServer() then
      local remote = getRemoteEvent()

      remote.OnServerEvent:Connect(function(player, locationName)
          local destination = teleportLocations[locationName]
          if not destination then
              return
          end

          local character = player.Character
          if not character then
              return
          end

          local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
          if not humanoidRootPart then
              return
          end

          humanoidRootPart.CFrame = destination
      end)

      return
  end

  local player = Players.LocalPlayer
  local remote = getRemoteEvent()

  local screenGui = Instance.new("ScreenGui")
  screenGui.Name = "TeleportGui"
  screenGui.ResetOnSpawn = false
  screenGui.Parent = player:WaitForChild("PlayerGui")

  local frame = Instance.new("Frame")
  frame.Size = UDim2.new(0, 230, 0, 190)
  frame.Position = UDim2.new(0, 20, 0.5, -95)
  frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
  frame.BorderSizePixel = 0
  frame.Parent = screenGui

  local title = Instance.new("TextLabel")
  title.Size = UDim2.new(1, 0, 0, 35)
  title.BackgroundTransparency = 1
  title.Text = "Teleport Menu"
  title.TextColor3 = Color3.fromRGB(255, 255, 255)
  title.TextSize = 18
  title.Font = Enum.Font.GothamBold
  title.Parent = frame

  local function createButton(text, order)
      local button = Instance.new("TextButton")
      button.Size = UDim2.new(1, -20, 0, 35)
      button.Position = UDim2.new(0, 10, 0, 40 + ((order - 1) * 40))
      button.BackgroundColor3 = Color3.fromRGB(70, 130, 255)
      button.Text = text
      button.TextColor3 = Color3.fromRGB(255, 255, 255)
      button.TextSize = 15
      button.Font = Enum.Font.Gotham
      button.Parent = frame

      button.MouseButton1Click:Connect(function()
          remote:FireServer(text)
      end)

      return button
  end

  createButton("Seed Shop", 1)
  createButton("Sell Shop", 2)
  createButton("Farm", 3)

  local closeButton = Instance.new("TextButton")
  closeButton.Size = UDim2.new(1, -20, 0, 30)
  closeButton.Position = UDim2.new(0, 10, 0, 160)
  closeButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
  closeButton.Text = "Close"
  closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
  closeButton.TextSize = 14
  closeButton.Font = Enum.Font.Gotham
  closeButton.Parent = frame

  closeButton.MouseButton1Click:Connect(function()
      screenGui.Enabled = false
  end)
