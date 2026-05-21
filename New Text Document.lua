 -- AUTO CLICK ORIGINAL SEED SHOP BUTTON
    -- Tries to find and activate original GUI button

    local Players = game:GetService("Players")
    local VirtualInputManager = game:GetService("VirtualInputManager")

    local Player = Players.LocalPlayer
    local PlayerGui = Player:WaitForChild("PlayerGui")

    local function isSeedObject(obj)
        local text = ""

        pcall(function()
            if obj:IsA("TextButton") or obj:IsA("TextLabel") or obj:IsA("TextBox") then
                text = obj.Text or ""
            end
        end)

        local n = string.lower(obj.Name or "")
        local t = string.lower(text or "")

        return n:find("seed") or t:find("seed") or n:find("seed shop") or t:find("seed shop")
    end

    local function findSeedButton()
        for _, obj in ipairs(PlayerGui:GetDescendants()) do
            if obj:IsA("TextButton") and isSeedObject(obj) then
                return obj
            end
        end

        -- Sometimes label contains Seed Shop and parent/sibling is the button
        for _, obj in ipairs(PlayerGui:GetDescendants()) do
            if (obj:IsA("TextLabel") or obj:IsA("TextBox")) and isSeedObject(obj) then
                local p = obj.Parent

                while p and p ~= PlayerGui do
                    if p:IsA("TextButton") or p:IsA("ImageButton") then
                        return p
                    end
                    p = p.Parent
                end
            end
        end

        -- ImageButton case by name
        for _, obj in ipairs(PlayerGui:GetDescendants()) do
            if obj:IsA("ImageButton") and isSeedObject(obj) then
                return obj
            end
        end

        return nil
    end

    local btn = findSeedButton()

    if not btn then
        warn("[LowHub] Seed Shop button not found")
        return
    end

    print("[LowHub] Found button:", btn:GetFullName(), btn.ClassName)

    pcall(function()
        btn.Visible = true
    end)

    local absPos = btn.AbsolutePosition
    local absSize = btn.AbsoluteSize

    local x = absPos.X + absSize.X / 2
    local y = absPos.Y + absSize.Y / 2

    print("[LowHub] Clicking at:", x, y)

    VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
    task.wait(0.05)
    VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)


    Kalau executor/lingkungan kamu tidak support VirtualInputManager, coba cara koneksi signal:

    lua
    -- TRY FIRE GUI BUTTON SIGNALS
    -- May work in some executors

    local Players = game:GetService("Players")
    local Player = Players.LocalPlayer
    local PlayerGui = Player:WaitForChild("PlayerGui")

    local function matches(obj)
        local text = ""

        pcall(function()
            if obj:IsA("TextButton") or obj:IsA("TextLabel") or obj:IsA("TextBox") then
                text = obj.Text or ""
            end
        end)

        local n = string.lower(obj.Name or "")
        local t = string.lower(text or "")

        return n:find("seed") or t:find("seed")
    end

    local target = nil

    for _, obj in ipairs(PlayerGui:GetDescendants()) do
        if obj:IsA("TextButton") and matches(obj) then
            target = obj
            break
        end
    end

    if not target then
        warn("[LowHub] Target TextButton not found")
        return
    end

    print("[LowHub] Target:", target:GetFullName())

    if firesignal then
        firesignal(target.MouseButton1Click)
        print("[LowHub] firesignal MouseButton1Click")
    elseif getconnections then
        local cons = getconnections(target.MouseButton1Click)
        print("[LowHub] Connections:", #cons)

        for _, con in ipairs(cons) do
            pcall(function()
                con:Fire()
            end)
        end
    else
        warn("[LowHub] firesignal/getconnections not available")
    end
