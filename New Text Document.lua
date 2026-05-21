 -- LOW HUB TELEPORT SERVER DEBUG
    -- Put this in ServerScriptService

    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Players = game:GetService("Players")

    local REMOTE_FOLDER = "GameEvents"
    local REMOTE_NAME = "PlayerTeleportTriggered"

    print("[TeleportServer] Starting...")

    local folder = ReplicatedStorage:FindFirstChild(REMOTE_FOLDER)

    if not folder then
        folder = Instance.new("Folder")
        folder.Name = REMOTE_FOLDER
        folder.Parent = ReplicatedStorage
        print("[TeleportServer] Created folder:", folder:GetFullName())
    else
        print("[TeleportServer] Found folder:", folder:GetFullName())
    end

    local remote = folder:FindFirstChild(REMOTE_NAME)

    if not remote then
        remote = Instance.new("RemoteEvent")
        remote.Name = REMOTE_NAME
        remote.Parent = folder
        print("[TeleportServer] Created remote:", remote:GetFullName())
    else
        print("[TeleportServer] Found remote:", remote:GetFullName(), remote.ClassName)
    end

    if not remote:IsA("RemoteEvent") then
        warn("[TeleportServer] ERROR: PlayerTeleportTriggered exists but is not RemoteEvent")
        return
    end

    local TeleportPoints = {
        Farm = CFrame.new(0, 20, 0),
        Garden = CFrame.new(100, 20, 0),
        Home = CFrame.new(0, 20, 100),
        Shop = CFrame.new(-100, 20, 0)
    }

    local Cooldown = {}
    local COOLDOWN_TIME = 0.5

    local function getRoot(player)
        local character = player.Character

        if not character then
            return nil, "Character nil"
        end

        local root = character:FindFirstChild("HumanoidRootPart")

        if not root then
            return nil, "HumanoidRootPart nil"
        end

        return root, nil
    end

    remote.OnServerEvent:Connect(function(player, locationName)
        print("[TeleportServer] Request received")
        print("[TeleportServer] Player:", player.Name)
        print("[TeleportServer] Location:", tostring(locationName))
        print("[TeleportServer] Location type:", typeof(locationName))

        if typeof(locationName) ~= "string" then
            warn("[TeleportServer] Rejected: location is not string")
            return
        end

        local now = os.clock()
        local last = Cooldown[player]

        if last and now - last < COOLDOWN_TIME then
            warn("[TeleportServer] Rejected: cooldown")
            return
        end

        Cooldown[player] = now

        local targetCFrame = TeleportPoints[locationName]

        if not targetCFrame then
            warn("[TeleportServer] Rejected: invalid location:", tostring(locationName))

            print("[TeleportServer] Valid locations:")
            for name, _ in pairs(TeleportPoints) do
                print(" -", name)
            end

            return
        end

        local root, rootErr = getRoot(player)

        if not root then
            warn("[TeleportServer] Rejected:", rootErr)
            return
        end

        print("[TeleportServer] Before:", root.Position)

        root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        root.CFrame = targetCFrame

        task.wait(0.1)

        print("[TeleportServer] After:", root.Position)
        print("[TeleportServer] Teleported", player.Name, "to", locationName)
    end)

    Players.PlayerRemoving:Connect(function(player)
        Cooldown[player] = nil
    end)

    print("[TeleportServer] Ready:", remote:GetFullName())
