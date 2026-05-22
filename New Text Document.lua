  -- LOW HUB - HONEY SEED NPC TELEPORT
  -- Combined Client + Server Source
  -- Server block jalan hanya di Script server
  -- Client block jalan hanya di LocalScript client

  local RunService = game:GetService("RunService")

  local Players = game:GetService("Players")
  local ReplicatedStorage = game:GetService("ReplicatedStorage")

  local GUI_NAME = "LowHubHoneySeedNPC"
  local NPC_FOLDER_NAME = "NPCS"
  local NPC_NAME = "HoneySeedShop"
  local SHOP_NAME = "Honey Seed Shop"

  local GAME_EVENTS_NAME = "GameEvents"
  local REMOTE_NAME = "PlayerTeleportTriggered"

  local function log(msg)
      print("[LowHubHoneySeed] " .. tostring(msg))
  end

  local function warnlog(msg)
      warn("[LowHubHoneySeed] " .. tostring(msg))
  end

  local function getOrCreateRemote()
      local gameEvents = ReplicatedStorage:FindFirstChild(GAME_EVENTS_NAME)

      if not gameEvents and RunService:IsServer() then
          gameEvents = Instance.new("Folder")
          gameEvents.Name = GAME_EVENTS_NAME
          gameEvents.Parent = ReplicatedStorage
      end

      if not gameEvents then
          gameEvents = ReplicatedStorage:WaitForChild(GAME_EVENTS_NAME, 5)
      end

      if not gameEvents then
          return nil, "GameEvents not found"
      end

      local remote = gameEvents:FindFirstChild(REMOTE_NAME)

      if not remote and RunService:IsServer() then
          remote = Instance.new("RemoteEvent")
          remote.Name = REMOTE_NAME
          remote.Parent = gameEvents
      end

      if not remote then
          remote = gameEvents:WaitForChild(REMOTE_NAME, 5)
      end

      if not remote then
          return nil, "PlayerTeleportTriggered not found"
      end

      return remote
  end

  local function getHoneySeedNPC()
      local npcs = workspace:FindFirstChild(NPC_FOLDER_NAME)
      if not npcs then
          npcs = workspace:WaitForChild(NPC_FOLDER_NAME, 5)
      end

      if not npcs then
          return nil, "workspace.NPCS not found"
      end

      local npc = npcs:FindFirstChild(NPC_NAME)
      if not npc then
          npc = npcs:WaitForChild(NPC_NAME, 5)
      end

      if not npc then
          return nil, "workspace.NPCS.HoneySeedShop not found"
      end

      return npc
  end

  local function getInstanceCFrame(inst)
      if inst:IsA("Model") then
          return inst:GetPivot()
      end

      if inst:IsA("BasePart") then
          return inst.CFrame
      end

      if inst:IsA("Attachment") then
          return inst.WorldCFrame
      end

      local model = inst:FindFirstAncestorOfClass("Model")
      if model then
          return model:GetPivot()
      end

      local part = inst:FindFirstChildWhichIsA("BasePart", true)
      if part then
          return part.CFrame
      end

      return nil
  end

  local function shortPos(v)
      return string.format("%.1f, %.1f, %.1f", v.X, v.Y, v.Z)
  end

  -- SERVER
  if RunService:IsServer() then
      local remote, remoteErr = getOrCreateRemote()

      if not remote then
          warnlog(remoteErr)
          return
      end

      local allowedDestinations = {
          ["Seed Shop"] = true,
          ["Honey Seed Shop"] = true,
          ["HoneySeedShop"] = true,
      }

      local cooldown = {}

      local function getTeleportCFrame(targetCFrame)
          local distanceBack = 6
          local backPosition = (targetCFrame * CFrame.new(0, 0, distanceBack)).Position

          return CFrame.new(
              backPosition + Vector3.new(0, 3, 0),
              Vector3.new(targetCFrame.Position.X, backPosition.Y + 3, targetCFrame.Position.Z)
          )
      end

      remote.OnServerEvent:Connect(function(player, destination)
          log("Server received from " .. player.Name .. ": " .. tostring(destination))

          if typeof(destination) ~= "string" then
              remote:FireClient(player, false, "Invalid destination")
              return
          end

          if not allowedDestinations[destination] then
              remote:FireClient(player, false, "Destination rejected: " .. destination)
              return
          end

          local now = os.clock()
          if cooldown[player] and now - cooldown[player] < 1.5 then
              remote:FireClient(player, false, "Cooldown")
              return
          end
          cooldown[player] = now

          local character = player.Character
          if not character then
              remote:FireClient(player, false, "Character not found")
              return
          end

          local root = character:FindFirstChild("HumanoidRootPart")
          if not root then
              remote:FireClient(player, false, "HumanoidRootPart not found")
              return
          end

          local npc, npcErr = getHoneySeedNPC()
          if not npc then
              remote:FireClient(player, false, npcErr)
              return
          end

          local npcCFrame = getInstanceCFrame(npc)
          if not npcCFrame then
              remote:FireClient(player, false, "Could not get NPC CFrame")
              return
          end

          root.AssemblyLinearVelocity = Vector3.zero
          root.AssemblyAngularVelocity = Vector3.zero
          character:PivotTo(getTeleportCFrame(npcCFrame))

          task.wait(0.1)

          remote:FireClient(player, true, "Server teleported. Pos: " .. shortPos(root.Position))
      end)

      log("Server handler loaded")
      return
  end

  -- CLIENT
  if not RunService:IsClient() then
      return
  end

  local UserInputService = game:GetService("UserInputService")

  local Player = Players.LocalPlayer
  local PlayerGui = Player:WaitForChild("PlayerGui")

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

  local function padding(obj, left, right)
      local p = Instance.new("UIPadding")
      p.PaddingLeft = UDim.new(0, left or 8)
      p.PaddingRight = UDim.new(0, right or 8)
      p.Parent = obj
  end

  local function getCharacter()
      local character = Player.Character or Player.CharacterAdded:Wait()
      local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 5)
      local root = character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart", 5)
      return character, humanoid, root
  end

  local function getGroundedCFrameNear(targetCFrame, distanceBack)
      distanceBack = distanceBack or 6

      local backPosition = (targetCFrame * CFrame.new(0, 0, distanceBack)).Position
      local rayOrigin = Vector3.new(backPosition.X, backPosition.Y + 100, backPosition.Z)
      local rayDirection = Vector3.new(0, -300, 0)

      local raycastParams = RaycastParams.new()
      raycastParams.FilterType = Enum.RaycastFilterType.Exclude
      raycastParams.IgnoreWater = true

      local excludeList = {}
      local character = Player.Character
      if character then
          table.insert(excludeList, character)
      end

      local npc = getHoneySeedNPC()
      if npc then
          table.insert(excludeList, npc)
      end

      raycastParams.FilterDescendantsInstances = excludeList

      local result = workspace:Raycast(rayOrigin, rayDirection, raycastParams)

      local groundPosition
      if result then
          groundPosition = result.Position + Vector3.new(0, 0.5, 0)
      else
          groundPosition = Vector3.new(backPosition.X, 0.5, backPosition.Z)
      end

      return CFrame.new(
          groundPosition,
          Vector3.new(targetCFrame.Position.X, groundPosition.Y, targetCFrame.Position.Z)
      )
  end

  local function teleportToHoneySeedNPC()
      local npc, err = getHoneySeedNPC()
      if not npc then
          return false, err
      end

      local targetCFrame = getInstanceCFrame(npc)
      if not targetCFrame then
          return false, "Could not get NPC CFrame"
      end

      local character, _, root = getCharacter()
      if not character or not root then
          return false, "Character/root not found"
      end

      local before = root.Position

      root.AssemblyLinearVelocity = Vector3.zero
      root.AssemblyAngularVelocity = Vector3.zero

      local finalCFrame = getGroundedCFrameNear(targetCFrame, 6)
      character:PivotTo(finalCFrame)

      task.wait(0.25)

      local after = root.Position
      local dist = (after - before).Magnitude

      log("Client PivotTo teleport")
      log("Before: " .. shortPos(before))
      log("After: " .. shortPos(after))
      log("Distance: " .. tostring(math.floor(dist)))

      return true, "Client PivotTo. Pos: " .. shortPos(after)
  end

  local function firePlayerTeleportTriggered()
      local remote, err = getOrCreateRemote()
      if not remote then
          return false, err
      end

      remote:FireServer("Seed Shop")
      log("FireServer sent: Seed Shop")

      return true, "Teleport request sent to server"
  end

  local function openHoneySeedShopUI()
      local ok, controller = pcall(function()
          return require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("EventShopUIController"))
      end)

      if not ok then
          return false, "Require EventShopUIController failed: " .. tostring(controller)
      end

      local openOk, openErr = pcall(function()
          controller:Open(SHOP_NAME)
      end)

      if not openOk then
          return false, "Open shop failed: " .. tostring(openErr)
      end

      return true, "Opened " .. SHOP_NAME
  end

  local Gui = Instance.new("ScreenGui")
  Gui.Name = GUI_NAME
  Gui.ResetOnSpawn = false
  Gui.IgnoreGuiInset = false
  Gui.DisplayOrder = 999999
  Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
  Gui.Parent = PlayerGui

  local Main = Instance.new("Frame")
  Main.Name = "Main"
  Main.Size = UDim2.new(0, 360, 0, 375)
  Main.Position = UDim2.new(0, 30, 0.5, -187)
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
  Header.BackgroundColor3 = Color3.fromRGB(20, 34, 20)
  Header.BorderSizePixel = 0
  Header.Active = true
  Header.ZIndex = 1001
  Header.Parent = Main
  corner(Header, 10)

  local Cover = Instance.new("Frame")
  Cover.Name = "Cover"
  Cover.Size = UDim2.new(1, 0, 0, 10)
  Cover.Position = UDim2.new(0, 0, 1, -10)
  Cover.BackgroundColor3 = Color3.fromRGB(20, 34, 20)
  Cover.BorderSizePixel = 0
  Cover.ZIndex = 1001
  Cover.Parent = Header

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
  Title.Size = UDim2.new(1, -125, 1, 0)
  Title.Position = UDim2.new(0, 50, 0, 0)
  Title.BackgroundTransparency = 1
  Title.Text = "LOW HUB - HONEY SEED"
  Title.TextColor3 = Color3.fromRGB(57, 255, 20)
  Title.TextSize = 13
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
  Status.Size = UDim2.new(1, -24, 0, 62)
  Status.Position = UDim2.new(0, 12, 0, 58)
  Status.BackgroundColor3 = Color3.fromRGB(24, 32, 24)
  Status.BorderSizePixel = 0
  Status.Text = "Status: Ready"
  Status.TextColor3 = Color3.fromRGB(190, 210, 190)
  Status.TextSize = 11
  Status.Font = Enum.Font.Gotham
  Status.TextXAlignment = Enum.TextXAlignment.Left
  Status.TextWrapped = true
  Status.ZIndex = 1001
  Status.Parent = Main
  corner(Status, 6)
  padding(Status, 8, 8)

  local Info = Instance.new("TextLabel")
  Info.Name = "Info"
  Info.Size = UDim2.new(1, -24, 0, 58)
  Info.Position = UDim2.new(0, 12, 0, 130)
  Info.BackgroundColor3 = Color3.fromRGB(20, 26, 20)
  Info.BorderSizePixel = 0
  Info.Text = "Target:\nworkspace.NPCS.HoneySeedShop\nRemote: GameEvents.PlayerTeleportTriggered"
  Info.TextColor3 = Color3.fromRGB(150, 170, 150)
  Info.TextSize = 10
  Info.Font = Enum.Font.Gotham
  Info.TextXAlignment = Enum.TextXAlignment.Left
  Info.TextWrapped = true
  Info.ZIndex = 1001
  Info.Parent = Main
  corner(Info, 6)
  padding(Info, 8, 8)

  local function makeButton(name, text, y, color)
      local b = Instance.new("TextButton")
      b.Name = name
      b.Size = UDim2.new(1, -24, 0, 34)
      b.Position = UDim2.new(0, 12, 0, y)
      b.BackgroundColor3 = color or Color3.fromRGB(35, 55, 35)
      b.BorderSizePixel = 0
      b.Text = text
      b.TextColor3 = Color3.fromRGB(255, 255, 255)
      b.TextSize = 12
      b.Font = Enum.Font.GothamBold
      b.ZIndex = 1001
      b.Parent = Main
      corner(b, 6)
      stroke(b, Color3.fromRGB(57, 255, 20), 1, 0.45)
      return b
  end

  local TeleportBtn = makeButton("TeleportHoneySeedNPC", "Client PivotTo HoneySeedShop", 200, Color3.fromRGB(35, 55,
  35))
  local FireRemoteBtn = makeButton("FireRemote", "Fire Server Teleport Remote", 244, Color3.fromRGB(35, 35, 65))
  local OpenShopBtn = makeButton("OpenHoneySeedShop", "Open Honey Seed Shop UI", 288, Color3.fromRGB(55, 45, 35))
  local PosBtn = makeButton("PrintPosition", "Print Position", 332, Color3.fromRGB(35, 45, 55))

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

  local function setStatus(text, color)
      Status.Text = "Status: " .. tostring(text)
      Status.TextColor3 = color or Color3.fromRGB(190, 210, 190)
  end

  local remote = getOrCreateRemote()
  if remote then
      remote.OnClientEvent:Connect(function(success, message)
          if success then
              setStatus(message, Color3.fromRGB(57, 255, 20))
          else
              setStatus(message, Color3.fromRGB(255, 80, 80))
              warnlog(message)
          end
      end)
  end

  TeleportBtn.MouseButton1Click:Connect(function()
      setStatus("Client teleporting...", Color3.fromRGB(255, 220, 80))

      local ok, msg = teleportToHoneySeedNPC()
      if ok then
          setStatus(msg, Color3.fromRGB(57, 255, 20))
      else
          setStatus(msg, Color3.fromRGB(255, 80, 80))
          warnlog(msg)
      end
  end)

  FireRemoteBtn.MouseButton1Click:Connect(function()
      setStatus("Sending request to server...", Color3.fromRGB(255, 220, 80))

      local ok, msg = firePlayerTeleportTriggered()
      if ok then
          setStatus(msg, Color3.fromRGB(57, 255, 20))
      else
          setStatus(msg, Color3.fromRGB(255, 80, 80))
          warnlog(msg)
      end
  end)

  OpenShopBtn.MouseButton1Click:Connect(function()
      setStatus("Opening Honey Seed Shop UI...", Color3.fromRGB(255, 220, 80))

      local ok, msg = openHoneySeedShopUI()
      if ok then
          setStatus(msg, Color3.fromRGB(57, 255, 20))
      else
          setStatus(msg, Color3.fromRGB(255, 80, 80))
          warnlog(msg)
      end
  end)

  PosBtn.MouseButton1Click:Connect(function()
      local _, _, root = getCharacter()

      if root then
          setStatus("Pos: " .. shortPos(root.Position), Color3.fromRGB(180, 220, 255))
          log("Position: " .. shortPos(root.Position))
      else
          setStatus("No HumanoidRootPart", Color3.fromRGB(255, 80, 80))
      end
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
      if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType ==
  Enum.UserInputType.Touch) then
          local delta = input.Position - dragStart

          Main.Position = UDim2.new(
              startPos.X.Scale,
              startPos.X.Offset + delta.X,
              startPos.Y.Scale,
              startPos.Y.Offset + delta.Y
          )
      end
  end)

  local npc, err = getHoneySeedNPC()
  if npc then
      setStatus("Ready. Found: " .. npc:GetFullName(), Color3.fromRGB(57, 255, 20))
      log("Found NPC: " .. npc:GetFullName())
  else
      setStatus(err, Color3.fromRGB(255, 80, 80))
      warnlog(err)
  end

  log("Client GUI loaded")
