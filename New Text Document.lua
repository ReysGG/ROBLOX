-- LOW HUB v4.1.30 - Grow a Garden
-- LocalScript | 1 file
-- Sections: TELEPORT | CONSOLE | EGG ESP | BUILDER | COMING SOON

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local RunService        = game:GetService("RunService")

local Player    = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local CoreGui = game:GetService("CoreGui")

local GUI_NAME = "LowHubV4"
local BOOT_GUI_NAME = GUI_NAME .. "Boot"

local oldBoot = PlayerGui:FindFirstChild(BOOT_GUI_NAME)
if oldBoot then oldBoot:Destroy() end

local BootGui = Instance.new("ScreenGui")
BootGui.Name = BOOT_GUI_NAME
BootGui.ResetOnSpawn = false
BootGui.DisplayOrder = 2147483647
BootGui.IgnoreGuiInset = true
BootGui.Parent = PlayerGui

local BootBtn = Instance.new("TextButton")
BootBtn.Size = UDim2.new(0, 150, 0, 34)
BootBtn.Position = UDim2.new(0, 8, 0, 8)
BootBtn.BackgroundColor3 = Color3.fromRGB(20, 55, 10)
BootBtn.BorderSizePixel = 0
BootBtn.Text = "LowHub v4.1.30 boot"
BootBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
BootBtn.TextSize = 11
BootBtn.Font = Enum.Font.GothamBold
BootBtn.Parent = BootGui

local BootCorner = Instance.new("UICorner")
BootCorner.CornerRadius = UDim.new(0, 8)
BootCorner.Parent = BootBtn

local function bootStatus(txt)
    if BootBtn then BootBtn.Text = tostring(txt) end
end

bootStatus("LowHub v4.1.30 start")

local function getGuiParent()
    local ok = pcall(function()
        local probe = Instance.new("Folder")
        probe.Name = "LowHubParentProbe"
        probe.Parent = CoreGui
        probe:Destroy()
    end)
    return ok and CoreGui or PlayerGui
end

local GuiParent = getGuiParent()

-- cleanup
local old = PlayerGui:FindFirstChild(GUI_NAME)
if old then old:Destroy() end
pcall(function()
    local c = CoreGui:FindFirstChild(GUI_NAME)
    if c then c:Destroy() end
end)

-- ============================================================
-- DESTINATIONS CONFIG
-- ============================================================
local DESTINATIONS = {
    {
        id        = "honey_seed",
        label     = "Honey Seed Shop",
        sub       = "Event Shop",
        icon      = "H",
        npcName   = "HoneySeedShop",
        pos       = nil,
        useRemote = true,
        remoteArg = "Seed Shop",
        shopName  = "Honey Seed Shop",
        color     = Color3.fromRGB(255, 180, 30),
    },
    {
        id      = "seed_stands",
        label   = "Seed Stands",
        sub     = "Buy Seeds",
        icon    = "S",
        npcName = "Seed Stands",
        pos     = Vector3.new(35.4, 3.0, -25.4),
        color   = Color3.fromRGB(80, 200, 80),
    },
    {
        id      = "sell_stands",
        label   = "Sell Stands",
        sub     = "Sell Harvest",
        icon    = "$",
        npcName = "Sell Stands",
        pos     = Vector3.new(40.4, 2.8, 0.4),
        color   = Color3.fromRGB(255, 210, 60),
    },
    {
        id      = "honey_hannah",
        label   = "Honey Hannah",
        sub     = "Special Shop",
        icon    = "P",
        npcName = "Honey Hannah",
        pos     = Vector3.new(41.9, 3.0, -27.1),
        color   = Color3.fromRGB(255, 140, 80),
    },
    {
        id      = "pet_stand",
        label   = "Pet Stand",
        sub     = "Pets & Eggs",
        icon    = "A",
        npcName = "Pet Stand",
        pos     = Vector3.new(-241.3, 5.0, 11.2),
        color   = Color3.fromRGB(160, 100, 255),
    },
    {
        id      = "gear_stands",
        label   = "Gear Stands",
        sub     = "Tools & Gear",
        icon    = "G",
        npcName = "Gear Stands",
        pos     = Vector3.new(-218.1, 4.4, -4.6),
        color   = Color3.fromRGB(120, 180, 255),
    },
}

-- ============================================================
-- COLORS & THEME
-- ============================================================
local C = {
    bg        = Color3.fromRGB(10, 13, 10),
    surface   = Color3.fromRGB(16, 21, 16),
    card      = Color3.fromRGB(20, 27, 20),
    cardHover = Color3.fromRGB(26, 36, 26),
    sidebar   = Color3.fromRGB(13, 18, 13),
    header    = Color3.fromRGB(14, 19, 14),
    border    = Color3.fromRGB(35, 55, 35),
    green     = Color3.fromRGB(57, 255, 20),
    greenMid  = Color3.fromRGB(40, 160, 15),
    greenDark = Color3.fromRGB(20, 55, 10),
    greenDeep = Color3.fromRGB(12, 30, 8),
    text      = Color3.fromRGB(210, 230, 210),
    textMid   = Color3.fromRGB(140, 170, 140),
    textDim   = Color3.fromRGB(80, 110, 80),
    textFaint = Color3.fromRGB(50, 75, 50),
    red       = Color3.fromRGB(220, 60, 60),
    redDark   = Color3.fromRGB(80, 20, 20),
    yellow    = Color3.fromRGB(255, 210, 60),
    blue      = Color3.fromRGB(80, 160, 255),
    white     = Color3.fromRGB(255, 255, 255),
    purple    = Color3.fromRGB(160, 100, 255),
    orange    = Color3.fromRGB(255, 140, 40),
}

-- ============================================================
-- UI HELPERS
-- ============================================================
local function corner(obj, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = obj
    return c
end

local function stroke(obj, col, thick, trans)
    local existing = obj:FindFirstChildOfClass("UIStroke")
    if existing then existing:Destroy() end
    local s = Instance.new("UIStroke")
    s.Color = col or C.green
    s.Thickness = thick or 1
    s.Transparency = trans or 0
    s.Parent = obj
    return s
end

local function pad(obj, l, r, t, b)
    local existing = obj:FindFirstChildOfClass("UIPadding")
    if existing then existing:Destroy() end
    local p = Instance.new("UIPadding")
    p.PaddingLeft   = UDim.new(0, l or 0)
    p.PaddingRight  = UDim.new(0, r or 0)
    p.PaddingTop    = UDim.new(0, t or 0)
    p.PaddingBottom = UDim.new(0, b or 0)
    p.Parent = obj
    return p
end

local function shortPos(v)
    return string.format("%.1f, %.1f, %.1f", v.X, v.Y, v.Z)
end

local function lerp(a, b, t) return a + (b - a) * t end
local function lerpColor(a, b, t)
    return Color3.new(lerp(a.R,b.R,t), lerp(a.G,b.G,t), lerp(a.B,b.B,t))
end

-- ============================================================
-- GAME HELPERS
-- ============================================================
local function getCharacter()
    local ch = Player.Character or Player.CharacterAdded:Wait()
    local hum  = ch:FindFirstChildOfClass("Humanoid") or ch:WaitForChild("Humanoid", 5)
    local root = ch:FindFirstChild("HumanoidRootPart") or ch:WaitForChild("HumanoidRootPart", 5)
    return ch, hum, root
end

local function getNPC(name)
    local folder = workspace:FindFirstChild("NPCS") or workspace:WaitForChild("NPCS", 5)
    if not folder then return nil end
    return folder:FindFirstChild(name)
end

local function getInstanceCFrame(inst)
    if not inst then return nil end
    if inst:IsA("Model")    then return inst:GetPivot() end
    if inst:IsA("BasePart") then return inst.CFrame end
    local m = inst:FindFirstAncestorOfClass("Model")
    if m then return m:GetPivot() end
    local p = inst:FindFirstChildWhichIsA("BasePart", true)
    if p then return p.CFrame end
    return nil
end

local function getGroundedCFrame(targetPos, offsetZ)
    offsetZ = offsetZ or 3
    local back = Vector3.new(targetPos.X + math.cos(0) * offsetZ, targetPos.Y + 100, targetPos.Z + math.sin(0) * offsetZ)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.IgnoreWater = true
    local excl = {}
    if Player.Character then table.insert(excl, Player.Character) end
    params.FilterDescendantsInstances = excl
    local result = workspace:Raycast(back, Vector3.new(0, -300, 0), params)
    local gY = result and (result.Position.Y + 0.5) or (targetPos.Y + 0.5)
    return CFrame.new(Vector3.new(targetPos.X + offsetZ, gY, targetPos.Z), Vector3.new(targetPos.X, gY, targetPos.Z))
end

local function teleportToPos(pos)
    local ch, _, root = getCharacter()
    if not ch or not root then return false, "Character not found" end
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
    pcall(function() ch:PivotTo(getGroundedCFrame(pos, 3)) end)
    task.wait(0.3)
    return true, shortPos(root.Position)
end

local function teleportToNPC(npcName)
    local npc = getNPC(npcName)
    if not npc then return false, npcName .. " not found" end
    local cf = getInstanceCFrame(npc)
    if not cf then return false, "Could not get CFrame" end
    return teleportToPos(cf.Position)
end

local function fireRemote(path, arg)
    local parts = string.split(path, ".")
    local obj = ReplicatedStorage
    for _, part in ipairs(parts) do
        local found = obj:FindFirstChild(part)
        if not found then
            local ok, res = pcall(function() return obj:WaitForChild(part, 3) end)
            if not ok or not res then return false, "Not found: " .. part end
            found = res
        end
        obj = found
    end
    if not obj:IsA("RemoteEvent") then return false, "Not a RemoteEvent" end
    if arg and arg ~= "" then obj:FireServer(arg) else obj:FireServer() end
    return true, "Fired"
end

local function openShopUI(shopName)
    local ok, ctrl = pcall(function()
        return require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("EventShopUIController"))
    end)
    if not ok then return false, tostring(ctrl) end
    local ok2, err2 = pcall(function() ctrl:Open(shopName) end)
    if not ok2 then return false, tostring(err2) end
    return true, "Opened"
end

local function doTeleport(dest)
    if dest.useRemote then
        local npc = getNPC(dest.npcName)
        if npc then
            local cf = getInstanceCFrame(npc)
            if cf then
                local ch, _, root = getCharacter()
                if ch and root then
                    root.AssemblyLinearVelocity = Vector3.zero
                    root.AssemblyAngularVelocity = Vector3.zero
                    pcall(function() ch:PivotTo(getGroundedCFrame(cf.Position, 2)) end)
                    task.wait(0.6)
                end
            end
        end
        local ok, msg = fireRemote("GameEvents.PlayerTeleportTriggered", dest.remoteArg)
        if not ok then return false, "Remote failed: " .. msg end
        task.wait(1.5)
        if dest.shopName then openShopUI(dest.shopName) end
        local _, _, root = getCharacter()
        return true, root and shortPos(root.Position) or "Done"
    else
        local targetPos = dest.pos
        local npc = getNPC(dest.npcName)
        if npc then
            local cf = getInstanceCFrame(npc)
            if cf then targetPos = cf.Position end
        end
        return teleportToPos(targetPos)
    end
end

-- ============================================================
-- EGG ESP SYSTEM
-- ============================================================
local espEnabled    = false
local espCache      = {}   -- [uuid] = { lblEgg, lblPet, lblWt, box }
local activeEggs    = {}   -- [uuid] = object
local eggWeightData = {}   -- [uuid] = actual weight from server
local weightCache   = {}   -- [eggName..petName] = range table
local espRenderConn = nil
local espAddedConn  = nil
local espRemovedConn = nil
local eggModels     = nil
local eggPets       = nil
local espListCallbacks = {} -- callbacks to refresh UI list
local espSettings = {
    rarityFilter = "All",
    searchText = "",
    sortMode = "Distance",
    colorMode = "Rarity",
    staticColor = C.purple,
    boxScale = 1,
    maxDistance = 0,
    showEggName = true,
    showPetName = true,
    showWeight = true,
    showDistance = true,
}

-- Egg registry (safe require)
local eggRegistry = nil
pcall(function()
    eggRegistry = require(ReplicatedStorage.Data.PetRegistry.PetEggs)
end)

-- Hook PetEggService for live weight data
pcall(function()
    ReplicatedStorage.GameEvents.PetEggService.OnClientEvent:Connect(function(eggModel, weight)
        if type(eggModel) ~= "userdata" then return end
        local ok, id = pcall(function() return eggModel:GetAttribute("OBJECT_UUID") end)
        if not ok or not id then return end
        if type(weight) == "number" then
            eggWeightData[id] = weight
            if espCache[id] then
                local lbl = espCache[id][3]
                if lbl then
                    pcall(function() lbl.Text = string.format("%.2f KG", weight) end)
                end
            end
        end
    end)
end)

-- Upvalue extraction (exploit-only)
pcall(function()
    local conn = getconnections(ReplicatedStorage.GameEvents.PetEggService.OnClientEvent)
    if conn and conn[1] then
        local hatchFn = getupvalue(getupvalue(conn[1].Function, 1), 2)
        eggModels = getupvalue(hatchFn, 1)
        eggPets   = getupvalue(hatchFn, 2)
    end
end)

-- Hook EggReadyToHatch
pcall(function()
    local oldHatch; oldHatch = hookfunction(
        getconnections(ReplicatedStorage.GameEvents.EggReadyToHatch_RE.OnClientEvent)[1].Function,
        newcclosure(function(objectId, petName)
            pcall(function() espUpdateEgg(objectId, petName) end)
            return oldHatch(objectId, petName)
        end)
    )
end)

local function getWeightRange(eggName, petName)
    if not eggRegistry or not eggName or not petName then return nil end
    local key = eggName .. petName
    if weightCache[key] then return weightCache[key] end
    local ok, result = pcall(function()
        local ed = eggRegistry[eggName]
        if not ed then return nil end
        local items = ed.RarityData and ed.RarityData.Items
        if not items then return nil end
        local pd = items[petName]
        if type(pd) ~= "table" then return nil end
        local gd = pd.GeneratedPetData
        if type(gd) ~= "table" then return nil end
        local wr = gd.WeightRange
        if type(wr) ~= "table" then return nil end
        return { min = wr[1] or 0, max = wr[2] or 0, huge = gd.HugeChance or 0 }
    end)
    if ok and result then
        weightCache[key] = result
        return result
    end
    return nil
end

local function getRarityColor(eggName, petName)
    if not eggRegistry or not eggName or not petName then return Color3.new(1,1,1) end
    local ok, col = pcall(function()
        local ed = eggRegistry[eggName]
        if not ed then return Color3.new(1,1,1) end
        local items = ed.RarityData and ed.RarityData.Items
        if not items then return Color3.new(1,1,1) end
        local pd = items[petName]
        if type(pd) ~= "table" then return Color3.new(1,1,1) end
        local odd = pd.NormalizedOdd or pd.ItemOdd or 100
        if odd <= 1  then return Color3.fromRGB(255, 50,  50)  end
        if odd <= 5  then return Color3.fromRGB(255, 165, 0)   end
        if odd <= 15 then return Color3.fromRGB(255, 215, 0)   end
        return Color3.new(1, 1, 1)
    end)
    return (ok and col) or Color3.new(1,1,1)
end

local RARITY_LABEL = {} -- for display in list
local RARITY_RANK = { Common = 1, Rare = 2, Epic = 3, Legendary = 4, Unknown = 0 }
local function getRarityLabel(eggName, petName)
    if not eggRegistry or not eggName or not petName then return "Common", Color3.new(1,1,1) end
    local ok, res = pcall(function()
        local ed = eggRegistry[eggName]
        if not ed then return "Common", Color3.new(1,1,1) end
        local items = ed.RarityData and ed.RarityData.Items
        if not items then return "Common", Color3.new(1,1,1) end
        local pd = items[petName]
        if type(pd) ~= "table" then return "Common", Color3.new(1,1,1) end
        local odd = pd.NormalizedOdd or pd.ItemOdd or 100
        if odd <= 1  then return "Legendary", Color3.fromRGB(255, 50, 50)   end
        if odd <= 5  then return "Epic",       Color3.fromRGB(255, 165, 0)  end
        if odd <= 15 then return "Rare",       Color3.fromRGB(255, 215, 0)  end
        return "Common", Color3.new(0.85, 0.85, 0.85)
    end)
    if ok and res then return res end
    return "Unknown", Color3.new(1,1,1)
end

local function getEspColor(eggName, petName)
    if espSettings.colorMode == "Static" then return espSettings.staticColor end
    return getRarityColor(eggName, petName)
end

local function getEggDistance(object)
    local _, _, root = getCharacter()
    if not root or not object then return 0 end
    return math.floor((root.Position - object:GetPivot().Position).Magnitude)
end

local function buildWeightText(objectId, eggName, petName)
    if eggWeightData[objectId] then
        return string.format("%.2f KG", eggWeightData[objectId])
    end
    local wr = getWeightRange(eggName, petName)
    if wr then
        local s = string.format("%.1f-%.1f KG", wr.min, wr.max)
        if wr.huge > 0 then s = s .. string.format(" | H:%.0f%%", wr.huge) end
        return s
    end
    return "? KG"
end

-- Drawing helpers
local function newText(size, color)
    local t = Drawing.new("Text")
    t.Size = size or 14
    t.Color = color or Color3.new(1,1,1)
    t.Outline = true
    t.OutlineColor = Color3.new(0,0,0)
    t.Center = true
    t.Visible = false
    return t
end

local function newBox()
    local b = Drawing.new("Square")
    b.Thickness = 1
    b.Filled = false
    b.Visible = false
    return b
end

local function getObjFromId(id)
    if not eggModels then return nil end
    for _, m in pairs(eggModels) do
        if typeof(m) == "Instance" and m:GetAttribute("OBJECT_UUID") == id then return m end
    end
    return nil
end

local function removeEspById(id)
    if not espCache[id] then return end
    for _, d in ipairs(espCache[id]) do pcall(function() d:Remove() end) end
    espCache[id] = nil
    activeEggs[id] = nil
    for _, cb in ipairs(espListCallbacks) do pcall(cb) end
end

local function addEsp(object)
    if not espEnabled then return end
    if object:GetAttribute("OWNER") ~= Player.Name then return end
    local id = object:GetAttribute("OBJECT_UUID")
    if not id or espCache[id] then return end

    local eggName = object:GetAttribute("EggName")
    local petName = eggPets and eggPets[id]
    local color   = getEspColor(eggName, petName)
    local wtText  = buildWeightText(id, eggName, petName)

    local lblEgg = newText(13, Color3.new(1,1,1))
    local lblPet = newText(15, color)
    local lblWt  = newText(13, Color3.fromRGB(150,220,255))
    local box    = newBox()

    lblEgg.Text = tostring(eggName or "?")
    lblPet.Text = tostring(petName or "?")
    lblWt.Text  = wtText
    box.Color   = color

    espCache[id]   = { lblEgg, lblPet, lblWt, box }
    activeEggs[id] = object
    for _, cb in ipairs(espListCallbacks) do pcall(cb) end
end

function espUpdateEgg(objectId, petName)
    local object = getObjFromId(objectId)
    if not object or not espCache[objectId] then return end
    local eggName = object:GetAttribute("EggName")
    local color   = getEspColor(eggName, petName)
    local e       = espCache[objectId]
    e[2].Text  = tostring(petName)
    e[2].Color = color
    e[3].Text  = buildWeightText(objectId, eggName, petName)
    e[4].Color = color
    for _, cb in ipairs(espListCallbacks) do pcall(cb) end
end

local function removeEsp(object)
    if object:GetAttribute("OWNER") ~= Player.Name then return end
    removeEspById(object:GetAttribute("OBJECT_UUID"))
end

local function updateAllEsp()
    if not espEnabled then return end
    local cam = workspace.CurrentCamera
    local camPos = cam.CFrame.Position
    for id, object in pairs(activeEggs) do
        local e = espCache[id]
        local shouldDraw = true
        local worldPos, pos, dist
        if not object or not object:IsDescendantOf(workspace) then
            removeEspById(id)
            shouldDraw = false
        elseif not e then
            shouldDraw = false
        else
            worldPos = object:GetPivot().Position
            pos, shouldDraw = cam:WorldToViewportPoint(worldPos)
        end
        if e and shouldDraw then
            dist = math.floor((camPos - worldPos).Magnitude)
            if espSettings.maxDistance > 0 and dist > espSettings.maxDistance then
                shouldDraw = false
            end
        end
        if e and not shouldDraw then
            for _, d in ipairs(e) do d.Visible = false end
        elseif e then
            local eggName = object:GetAttribute("EggName")
            local petName = eggPets and eggPets[id]
            local color = getEspColor(eggName, petName)
            local box  = math.clamp(50 - dist * 0.2, 20, 50) * espSettings.boxScale

            e[4].Color    = color
            e[4].Size     = Vector2.new(box, box)
            e[4].Position = Vector2.new(pos.X - box/2, pos.Y - box/2)
            e[4].Visible  = true

            e[1].Text     = tostring(eggName or "?")
            e[1].Position = Vector2.new(pos.X, pos.Y - box/2 - 30)
            e[1].Visible  = espSettings.showEggName

            e[2].Text     = tostring(petName or "?")
            e[2].Color    = color
            e[2].Position = Vector2.new(pos.X, pos.Y - box/2 - 16)
            e[2].Visible  = espSettings.showPetName

            local infoParts = {}
            if espSettings.showWeight then table.insert(infoParts, buildWeightText(id, eggName, petName)) end
            if espSettings.showDistance then table.insert(infoParts, string.format("[%dm]", dist)) end
            e[3].Text     = table.concat(infoParts, "  ")
            e[3].Position = Vector2.new(pos.X, pos.Y + box/2 + 4)
            e[3].Visible  = (#infoParts > 0)
        end
    end
end

local function clearAllEspDrawings()
    for id, e in pairs(espCache) do
        for _, d in ipairs(e) do pcall(function() d:Remove() end) end
    end
    espCache   = {}
    activeEggs = {}
end

local function enableEsp()
    if espEnabled then return end
    espEnabled = true
    for _, obj in ipairs(CollectionService:GetTagged("PetEggServer")) do
        task.spawn(addEsp, obj)
    end
    if not espAddedConn then
        espAddedConn = CollectionService:GetInstanceAddedSignal("PetEggServer"):Connect(addEsp)
    end
    if not espRemovedConn then
        espRemovedConn = CollectionService:GetInstanceRemovedSignal("PetEggServer"):Connect(removeEsp)
    end
    local renderSignal = RunService.PreRender or RunService.RenderStepped
    espRenderConn = renderSignal:Connect(updateAllEsp)
end

local function disableEsp()
    espEnabled = false
    if espRenderConn then espRenderConn:Disconnect(); espRenderConn = nil end
    if espAddedConn then espAddedConn:Disconnect(); espAddedConn = nil end
    if espRemovedConn then espRemovedConn:Disconnect(); espRemovedConn = nil end
    clearAllEspDrawings()
    for _, cb in ipairs(espListCallbacks) do pcall(cb) end
end

-- ============================================================
-- CONSOLE HOOKS
-- ============================================================
local logLines = {}
local MAX_LOGS = 300
local logRenderCallbacks = {}

local _origPrint = print
local _origWarn  = warn

local function pushLog(tag, msg, col)
    local entry = {
        tag = tag,
        msg = tostring(msg),
        col = col or C.text,
        ts  = os.date("%H:%M:%S"),
    }
    table.insert(logLines, entry)
    if #logLines > MAX_LOGS then table.remove(logLines, 1) end
    for _, cb in ipairs(logRenderCallbacks) do pcall(cb, entry) end
    return entry
end

print = function(...)
    local parts = {}
    for _, v in ipairs({...}) do table.insert(parts, tostring(v)) end
    local msg = table.concat(parts, "  ")
    _origPrint(...)
    pcall(function() pushLog("OUT", msg, C.text) end)
end

warn = function(...)
    local parts = {}
    for _, v in ipairs({...}) do table.insert(parts, tostring(v)) end
    local msg = table.concat(parts, "  ")
    _origWarn(...)
    pcall(function() pushLog("WRN", msg, C.yellow) end)
end

-- ============================================================
-- BUILD GUI
-- ============================================================
local Gui = Instance.new("ScreenGui")
Gui.Name = GUI_NAME
Gui.ResetOnSpawn = false
Gui.DisplayOrder = 999999
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = GuiParent
bootStatus("LowHub main UI made")

local FallbackGui
if GuiParent ~= PlayerGui then
    FallbackGui = Instance.new("ScreenGui")
    FallbackGui.Name = GUI_NAME .. "Fallback"
    FallbackGui.ResetOnSpawn = false
    FallbackGui.DisplayOrder = 999998
    FallbackGui.Parent = PlayerGui
end

local Win = Instance.new("Frame")
Win.Name = "Win"
Win.Size = UDim2.new(0, 540, 0, 460)
Win.Position = UDim2.new(0, 30, 0.5, -230)
Win.BackgroundColor3 = C.bg
Win.BorderSizePixel = 0
Win.Active = true
Win.ZIndex = 100
Win.Parent = Gui
corner(Win, 14)
stroke(Win, C.border, 1, 0)

local TopGlow = Instance.new("Frame")
TopGlow.Size = UDim2.new(1, -4, 0, 2)
TopGlow.Position = UDim2.new(0, 2, 0, 1)
TopGlow.BackgroundColor3 = C.greenMid
TopGlow.BackgroundTransparency = 0.4
TopGlow.BorderSizePixel = 0
TopGlow.ZIndex = 101
TopGlow.Parent = Win
corner(TopGlow, 2)

-- HEADER
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 48)
Header.BackgroundColor3 = C.header
Header.BorderSizePixel = 0
Header.ZIndex = 101
Header.Active = true
Header.Parent = Win
corner(Header, 14)

local HFill = Instance.new("Frame")
HFill.Size = UDim2.new(1, 0, 0, 14)
HFill.Position = UDim2.new(0, 0, 1, -14)
HFill.BackgroundColor3 = C.header
HFill.BorderSizePixel = 0
HFill.ZIndex = 101
HFill.Parent = Header

local HDivider = Instance.new("Frame")
HDivider.Size = UDim2.new(1, -20, 0, 1)
HDivider.Position = UDim2.new(0, 10, 1, -1)
HDivider.BackgroundColor3 = C.border
HDivider.BorderSizePixel = 0
HDivider.ZIndex = 102
HDivider.Parent = Header

local Badge = Instance.new("Frame")
Badge.Size = UDim2.new(0, 32, 0, 24)
Badge.Position = UDim2.new(0, 12, 0.5, -12)
Badge.BackgroundColor3 = C.green
Badge.BorderSizePixel = 0
Badge.ZIndex = 103
Badge.Parent = Header
corner(Badge, 6)

local BadgeLbl = Instance.new("TextLabel")
BadgeLbl.Size = UDim2.new(1, 0, 1, 0)
BadgeLbl.BackgroundTransparency = 1
BadgeLbl.Text = "LH"
BadgeLbl.TextColor3 = Color3.fromRGB(0, 0, 0)
BadgeLbl.TextSize = 11
BadgeLbl.Font = Enum.Font.GothamBold
BadgeLbl.ZIndex = 104
BadgeLbl.Parent = Badge

local TitleLbl = Instance.new("TextLabel")
TitleLbl.Size = UDim2.new(0, 160, 1, 0)
TitleLbl.Position = UDim2.new(0, 52, 0, 0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Text = "LOW HUB"
TitleLbl.TextColor3 = C.text
TitleLbl.TextSize = 14
TitleLbl.Font = Enum.Font.GothamBold
TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
TitleLbl.ZIndex = 103
TitleLbl.Parent = Header

local VerLbl = Instance.new("TextLabel")
VerLbl.Size = UDim2.new(0, 60, 1, 0)
VerLbl.Position = UDim2.new(0, 115, 0, 0)
VerLbl.BackgroundTransparency = 1
VerLbl.Text = "v4.1.30"
VerLbl.TextColor3 = C.green
VerLbl.TextSize = 10
VerLbl.Font = Enum.Font.GothamBold
VerLbl.TextXAlignment = Enum.TextXAlignment.Left
VerLbl.ZIndex = 103
VerLbl.Parent = Header

local function hBtn(txt, xOff, bg)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 28, 0, 24)
    b.Position = UDim2.new(1, xOff, 0.5, -12)
    b.BackgroundColor3 = bg
    b.BorderSizePixel = 0
    b.Text = txt
    b.TextColor3 = C.white
    b.TextSize = 12
    b.Font = Enum.Font.GothamBold
    b.ZIndex = 103
    b.Parent = Header
    corner(b, 6)
    return b
end
local MinBtn   = hBtn("-", -72, C.greenMid)
local CloseBtn = hBtn("X", -38, C.red)

-- STATUS BAR
local StatusBar = Instance.new("Frame")
StatusBar.Size = UDim2.new(1, -16, 0, 28)
StatusBar.Position = UDim2.new(0, 8, 0, 52)
StatusBar.BackgroundColor3 = C.surface
StatusBar.BorderSizePixel = 0
StatusBar.ZIndex = 101
StatusBar.Parent = Win
corner(StatusBar, 6)
stroke(StatusBar, C.border, 1, 0)

local SDot = Instance.new("Frame")
SDot.Size = UDim2.new(0, 7, 0, 7)
SDot.Position = UDim2.new(0, 10, 0.5, -3.5)
SDot.BackgroundColor3 = C.green
SDot.BorderSizePixel = 0
SDot.ZIndex = 102
SDot.Parent = StatusBar
corner(SDot, 4)

local SLbl = Instance.new("TextLabel")
SLbl.Size = UDim2.new(1, -28, 1, 0)
SLbl.Position = UDim2.new(0, 24, 0, 0)
SLbl.BackgroundTransparency = 1
SLbl.Text = "Ready"
SLbl.TextColor3 = C.textMid
SLbl.TextSize = 10
SLbl.Font = Enum.Font.Gotham
SLbl.TextXAlignment = Enum.TextXAlignment.Left
SLbl.TextTruncate = Enum.TextTruncate.AtEnd
SLbl.ZIndex = 102
SLbl.Parent = StatusBar

local function setStatus(txt, col)
    SLbl.Text = txt
    SLbl.TextColor3 = col or C.textMid
    SDot.BackgroundColor3 = col or C.green
end

-- BODY
local Body = Instance.new("Frame")
Body.Size = UDim2.new(1, -16, 1, -96)
Body.Position = UDim2.new(0, 8, 0, 88)
Body.BackgroundTransparency = 1
Body.ZIndex = 101
Body.Parent = Win

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 56, 1, 0)
Sidebar.BackgroundColor3 = C.sidebar
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 102
Sidebar.Parent = Body
corner(Sidebar, 10)
stroke(Sidebar, C.border, 1, 0)

local SideListLayout = Instance.new("UIListLayout")
SideListLayout.FillDirection = Enum.FillDirection.Vertical
SideListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SideListLayout.SortOrder = Enum.SortOrder.LayoutOrder
SideListLayout.Padding = UDim.new(0, 6)
SideListLayout.Parent = Sidebar

local SidePad = Instance.new("UIPadding")
SidePad.PaddingTop = UDim.new(0, 10)
SidePad.PaddingLeft = UDim.new(0, 6)
SidePad.PaddingRight = UDim.new(0, 6)
SidePad.Parent = Sidebar

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -64, 1, 0)
Content.Position = UDim2.new(0, 64, 0, 0)
Content.BackgroundTransparency = 1
Content.ZIndex = 102
Content.Parent = Body

-- TABS
local TABS = {
    { id = "farm",     icon = "F",  label = "FARM" },
    { id = "teleport", icon = "T",  label = "TP"  },
    { id = "console",  icon = "L",  label = "LOG" },
    { id = "esp",      icon = "E",  label = "ESP" },
    { id = "builder",  icon = "B",  label = "BLD" },
}

local tabBtns = {}
local panels  = {}
local activeTab = ""

local function makeTabBtn(tab)
    local outer = Instance.new("Frame")
    outer.Size = UDim2.new(1, 0, 0, 44)
    outer.BackgroundTransparency = 1
    outer.ZIndex = 103
    outer.LayoutOrder = #tabBtns + 1
    outer.Parent = Sidebar

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundColor3 = C.greenDeep
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.ZIndex = 103
    btn.Parent = outer
    corner(btn, 8)

    local ico = Instance.new("TextLabel")
    ico.Size = UDim2.new(1, 0, 0, 20)
    ico.Position = UDim2.new(0, 0, 0, 4)
    ico.BackgroundTransparency = 1
    ico.Text = tab.icon
    ico.TextSize = 15
    ico.Font = Enum.Font.GothamBold
    ico.TextColor3 = C.textDim
    ico.ZIndex = 104
    ico.Parent = btn

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 12)
    lbl.Position = UDim2.new(0, 0, 0, 26)
    lbl.BackgroundTransparency = 1
    lbl.Text = tab.label
    lbl.TextSize = 8
    lbl.Font = Enum.Font.GothamBold
    lbl.TextColor3 = C.textFaint
    lbl.ZIndex = 104
    lbl.Parent = btn

    tabBtns[tab.id] = { outer = outer, btn = btn, ico = ico, lbl = lbl }
    return btn
end

for _, t in ipairs(TABS) do makeTabBtn(t) end

local function makePanel(id)
    local p = Instance.new("ScrollingFrame")
    p.Name = "Panel_" .. id
    p.Size = UDim2.new(1, 0, 1, 0)
    p.BackgroundTransparency = 1
    p.ScrollBarThickness = 3
    p.ScrollBarImageColor3 = C.greenMid
    p.CanvasSize = UDim2.new(0, 0, 0, 0)
    p.AutomaticCanvasSize = Enum.AutomaticSize.Y
    p.Visible = false
    p.ZIndex = 103
    p.Parent = Content
    panels[id] = p
    return p
end

local function setActiveTab(id)
    if activeTab == id then return end
    activeTab = id
    for tid, data in pairs(tabBtns) do
        local isActive = (tid == id)
        local accentColor = C.green
        -- ESP tab gets purple accent
        if tid == "esp" then accentColor = C.purple end
        if isActive then
            data.btn.BackgroundColor3 = C.greenDark
            data.ico.TextColor3 = accentColor
            data.lbl.TextColor3 = accentColor
            stroke(data.btn, accentColor, 1, 0.2)
        else
            data.btn.BackgroundColor3 = C.greenDeep
            data.ico.TextColor3 = C.textDim
            data.lbl.TextColor3 = C.textFaint
            local s = data.btn:FindFirstChildOfClass("UIStroke")
            if s then s:Destroy() end
        end
    end
    for pid, panel in pairs(panels) do
        panel.Visible = (pid == id)
    end
end

local function sectionLbl(parent, txt)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 22)
    f.BackgroundTransparency = 1
    f.ZIndex = 104
    f.Parent = parent
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -4, 1, 0)
    l.Position = UDim2.new(0, 4, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = txt
    l.TextColor3 = C.textFaint
    l.TextSize = 9
    l.Font = Enum.Font.GothamBold
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.ZIndex = 105
    l.Parent = f
    return f
end

local function actionBtn(parent, txt, bgCol, h)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, h or 34)
    b.BackgroundColor3 = bgCol or C.card
    b.BorderSizePixel = 0
    b.Text = txt
    b.TextColor3 = C.white
    b.TextSize = 11
    b.Font = Enum.Font.GothamBold
    b.ZIndex = 104
    b.Parent = parent
    corner(b, 8)
    stroke(b, C.border, 1, 0)
    return b
end

-- ============================================================
-- PANEL: TELEPORT
-- ============================================================
local PTP = makePanel("teleport")
local PTPLayout = Instance.new("UIListLayout")
PTPLayout.FillDirection = Enum.FillDirection.Vertical
PTPLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
PTPLayout.SortOrder = Enum.SortOrder.LayoutOrder
PTPLayout.Padding = UDim.new(0, 6)
PTPLayout.Parent = PTP
pad(PTP, 2, 4, 4, 8)

sectionLbl(PTP, "DESTINATIONS")

local Grid = Instance.new("Frame")
Grid.Size = UDim2.new(1, 0, 0, 0)
Grid.AutomaticSize = Enum.AutomaticSize.Y
Grid.BackgroundTransparency = 1
Grid.ZIndex = 104
Grid.Parent = PTP

local GridLayout = Instance.new("UIGridLayout")
GridLayout.CellSize = UDim2.new(0.5, -4, 0, 72)
GridLayout.CellPadding = UDim2.new(0, 6, 0, 6)
GridLayout.SortOrder = Enum.SortOrder.LayoutOrder
GridLayout.Parent = Grid

local destStatus = {}

for i, dest in ipairs(DESTINATIONS) do
    local card = Instance.new("TextButton")
    card.Size = UDim2.new(1, 0, 1, 0)
    card.BackgroundColor3 = C.card
    card.BorderSizePixel = 0
    card.Text = ""
    card.ZIndex = 105
    card.LayoutOrder = i
    card.Parent = Grid
    corner(card, 10)
    stroke(card, C.border, 1, 0)

    local accentBar = Instance.new("Frame")
    accentBar.Size = UDim2.new(1, 0, 0, 3)
    accentBar.BackgroundColor3 = dest.color
    accentBar.BackgroundTransparency = 0.4
    accentBar.BorderSizePixel = 0
    accentBar.ZIndex = 106
    accentBar.Parent = card
    corner(accentBar, 2)

    local icoLbl = Instance.new("TextLabel")
    icoLbl.Size = UDim2.new(0, 28, 0, 28)
    icoLbl.Position = UDim2.new(0, 8, 0, 10)
    icoLbl.BackgroundColor3 = lerpColor(dest.color, C.bg, 0.75)
    icoLbl.BorderSizePixel = 0
    icoLbl.Text = dest.icon
    icoLbl.TextSize = 14
    icoLbl.Font = Enum.Font.GothamBold
    icoLbl.ZIndex = 106
    icoLbl.Parent = card
    corner(icoLbl, 8)

    local titleL = Instance.new("TextLabel")
    titleL.Size = UDim2.new(1, -16, 0, 16)
    titleL.Position = UDim2.new(0, 8, 0, 42)
    titleL.BackgroundTransparency = 1
    titleL.Text = dest.label
    titleL.TextColor3 = C.text
    titleL.TextSize = 10
    titleL.Font = Enum.Font.GothamBold
    titleL.TextXAlignment = Enum.TextXAlignment.Left
    titleL.TextTruncate = Enum.TextTruncate.AtEnd
    titleL.ZIndex = 106
    titleL.Parent = card

    local subL = Instance.new("TextLabel")
    subL.Size = UDim2.new(1, -16, 0, 12)
    subL.Position = UDim2.new(0, 8, 0, 56)
    subL.BackgroundTransparency = 1
    subL.Text = dest.sub
    subL.TextColor3 = C.textDim
    subL.TextSize = 8
    subL.Font = Enum.Font.Gotham
    subL.TextXAlignment = Enum.TextXAlignment.Left
    subL.ZIndex = 106
    subL.Parent = card

    local statDot = Instance.new("Frame")
    statDot.Size = UDim2.new(0, 6, 0, 6)
    statDot.Position = UDim2.new(1, -12, 0, 8)
    statDot.BackgroundColor3 = C.textFaint
    statDot.BorderSizePixel = 0
    statDot.ZIndex = 107
    statDot.Parent = card
    corner(statDot, 3)

    destStatus[dest.id] = statDot

    card.MouseEnter:Connect(function()
        TweenService:Create(card, TweenInfo.new(0.15), { BackgroundColor3 = C.cardHover }):Play()
        stroke(card, dest.color, 1, 0.5)
    end)
    card.MouseLeave:Connect(function()
        TweenService:Create(card, TweenInfo.new(0.15), { BackgroundColor3 = C.card }):Play()
        stroke(card, C.border, 1, 0)
    end)

    card.MouseButton1Click:Connect(function()
        setStatus("Teleporting to " .. dest.label .. "...", C.yellow)
        statDot.BackgroundColor3 = C.yellow
        task.spawn(function()
            local ok, msg = doTeleport(dest)
            if ok then
                setStatus("OK " .. dest.label .. " - " .. msg, C.green)
                statDot.BackgroundColor3 = C.green
                pushLog("TP", dest.label .. " -> " .. msg, C.green)
            else
                setStatus("X " .. msg, C.red)
                statDot.BackgroundColor3 = C.red
                pushLog("ERR", dest.label .. " -> " .. msg, C.red)
            end
        end)
    end)
end

GridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Grid.Size = UDim2.new(1, 0, 0, GridLayout.AbsoluteContentSize.Y)
end)
task.defer(function()
    Grid.Size = UDim2.new(1, 0, 0, GridLayout.AbsoluteContentSize.Y)
end)

sectionLbl(PTP, "QUICK ACTIONS")

local QRow = Instance.new("Frame")
QRow.Size = UDim2.new(1, 0, 0, 30)
QRow.BackgroundTransparency = 1
QRow.ZIndex = 104
QRow.Parent = PTP

local QLayout = Instance.new("UIListLayout")
QLayout.FillDirection = Enum.FillDirection.Horizontal
QLayout.SortOrder = Enum.SortOrder.LayoutOrder
QLayout.Padding = UDim.new(0, 6)
QLayout.Parent = QRow

local PosQBtn = actionBtn(QRow, "T Position", C.surface, 30)
PosQBtn.Size = UDim2.new(0, 100, 1, 0)
PosQBtn.LayoutOrder = 1

local OpenSeedShopBtn = actionBtn(QRow, "H Open UI", C.surface, 30)
OpenSeedShopBtn.Size = UDim2.new(0, 90, 1, 0)
OpenSeedShopBtn.LayoutOrder = 2

PosQBtn.MouseButton1Click:Connect(function()
    local _, _, root = getCharacter()
    if root then
        local p = shortPos(root.Position)
        setStatus("Pos: " .. p, C.blue)
        pushLog("POS", p, C.blue)
    end
end)

OpenSeedShopBtn.MouseButton1Click:Connect(function()
    setStatus("Opening Honey Seed Shop UI...", C.yellow)
    task.spawn(function()
        local ok, msg = openShopUI("Honey Seed Shop")
        setStatus(ok and "OK Shop opened" or "X " .. msg, ok and C.green or C.red)
    end)
end)

-- ============================================================
-- PANEL: CONSOLE
-- ============================================================
local PCS = makePanel("console")
local PCSLayout = Instance.new("UIListLayout")
PCSLayout.FillDirection = Enum.FillDirection.Vertical
PCSLayout.SortOrder = Enum.SortOrder.LayoutOrder
PCSLayout.Padding = UDim.new(0, 6)
PCSLayout.Parent = PCS
pad(PCS, 2, 4, 4, 8)

local LogFrame = Instance.new("Frame")
LogFrame.Size = UDim2.new(1, 0, 0, 180)
LogFrame.BackgroundColor3 = C.surface
LogFrame.BorderSizePixel = 0
LogFrame.ZIndex = 104
LogFrame.Parent = PCS
corner(LogFrame, 8)
stroke(LogFrame, C.border, 1, 0)

local LogScroll = Instance.new("ScrollingFrame")
LogScroll.Size = UDim2.new(1, -2, 1, -2)
LogScroll.Position = UDim2.new(0, 1, 0, 1)
LogScroll.BackgroundTransparency = 1
LogScroll.ScrollBarThickness = 3
LogScroll.ScrollBarImageColor3 = C.greenMid
LogScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
LogScroll.ZIndex = 105
LogScroll.Parent = LogFrame

local LogLayout = Instance.new("UIListLayout")
LogLayout.FillDirection = Enum.FillDirection.Vertical
LogLayout.SortOrder = Enum.SortOrder.LayoutOrder
LogLayout.Padding = UDim.new(0, 1)
LogLayout.Parent = LogScroll
pad(LogScroll, 6, 6, 4, 4)

local function renderLogLine(entry)
    local row = Instance.new("TextLabel")
    row.Size = UDim2.new(1, 0, 0, 15)
    row.BackgroundTransparency = 1
    row.RichText = true
    row.Text = string.format(
        '<font color="#%s" size="8">[%s]</font> <font color="#%s" size="8">%s</font>  <font color="#ffffff" size="9">%s</font>',
        "506850", entry.ts,
        string.format("%02x%02x%02x",
            math.floor(entry.col.R*255),
            math.floor(entry.col.G*255),
            math.floor(entry.col.B*255)),
        entry.tag,
        entry.msg:gsub("<","&lt;"):gsub(">","&gt;")
    )
    row.TextXAlignment = Enum.TextXAlignment.Left
    row.TextTruncate = Enum.TextTruncate.AtEnd
    row.LayoutOrder = #logLines
    row.ZIndex = 106
    row.Parent = LogScroll
    task.defer(function()
        LogScroll.CanvasSize = UDim2.new(0, 0, 0, LogLayout.AbsoluteContentSize.Y + 8)
        LogScroll.CanvasPosition = Vector2.new(0,
            math.max(0, LogScroll.CanvasSize.Y.Offset - LogScroll.AbsoluteSize.Y))
    end)
end

table.insert(logRenderCallbacks, renderLogLine)
for _, entry in ipairs(logLines) do renderLogLine(entry) end

local ConToolbar = Instance.new("Frame")
ConToolbar.Size = UDim2.new(1, 0, 0, 28)
ConToolbar.BackgroundTransparency = 1
ConToolbar.ZIndex = 104
ConToolbar.Parent = PCS

local CTLayout = Instance.new("UIListLayout")
CTLayout.FillDirection = Enum.FillDirection.Horizontal
CTLayout.SortOrder = Enum.SortOrder.LayoutOrder
CTLayout.Padding = UDim.new(0, 6)
CTLayout.Parent = ConToolbar

local CopyBtn = actionBtn(ConToolbar, "COPY Copy All", C.surface, 28)
CopyBtn.Size = UDim2.new(0, 100, 1, 0)
CopyBtn.LayoutOrder = 1

local ClearLogBtn = actionBtn(ConToolbar, "X Clear", C.redDark, 28)
ClearLogBtn.Size = UDim2.new(0, 80, 1, 0)
ClearLogBtn.LayoutOrder = 2

sectionLbl(PCS, "SCRIPT EXECUTOR")

local ExecBox = Instance.new("TextBox")
ExecBox.Size = UDim2.new(1, 0, 0, 80)
ExecBox.BackgroundColor3 = C.surface
ExecBox.BorderSizePixel = 0
ExecBox.Text = "-- paste script here"
ExecBox.TextColor3 = Color3.fromRGB(140, 220, 130)
ExecBox.PlaceholderColor3 = C.textFaint
ExecBox.TextSize = 10
ExecBox.Font = Enum.Font.Code
ExecBox.TextXAlignment = Enum.TextXAlignment.Left
ExecBox.TextYAlignment = Enum.TextYAlignment.Top
ExecBox.MultiLine = true
ExecBox.ClearTextOnFocus = false
ExecBox.ZIndex = 104
ExecBox.Parent = PCS
corner(ExecBox, 8)
stroke(ExecBox, C.border, 1, 0)
pad(ExecBox, 8, 8, 6, 6)

local ExecToolbar = Instance.new("Frame")
ExecToolbar.Size = UDim2.new(1, 0, 0, 28)
ExecToolbar.BackgroundTransparency = 1
ExecToolbar.ZIndex = 104
ExecToolbar.Parent = PCS

local ETLayout = Instance.new("UIListLayout")
ETLayout.FillDirection = Enum.FillDirection.Horizontal
ETLayout.SortOrder = Enum.SortOrder.LayoutOrder
ETLayout.Padding = UDim.new(0, 6)
ETLayout.Parent = ExecToolbar

local RunBtn = actionBtn(ExecToolbar, "> Run", C.greenDark, 28)
RunBtn.Size = UDim2.new(0, 80, 1, 0)
RunBtn.LayoutOrder = 1
stroke(RunBtn, C.greenMid, 1, 0.2)

local ClearExecBtn = actionBtn(ExecToolbar, "X Clear", C.redDark, 28)
ClearExecBtn.Size = UDim2.new(0, 80, 1, 0)
ClearExecBtn.LayoutOrder = 2

CopyBtn.MouseButton1Click:Connect(function()
    local lines = {}
    for _, l in ipairs(logLines) do
        table.insert(lines, string.format("[%s] %s  %s", l.ts, l.tag, l.msg))
    end
    if type(setclipboard) ~= "function" then
        pushLog("ERR", "setclipboard unavailable", C.red)
        setStatus("Clipboard unavailable", C.red)
        return
    end
    local ok = pcall(function()
        setclipboard(table.concat(lines, "\n"))
    end)
    if ok then
        pushLog("SYS", "Copied " .. #logLines .. " lines", C.blue)
        setStatus("Copied " .. #logLines .. " log lines", C.blue)
    else
        pushLog("ERR", "Clipboard copy failed", C.red)
        setStatus("Clipboard failed", C.red)
    end
end)

ClearLogBtn.MouseButton1Click:Connect(function()
    logLines = {}
    for _, c in ipairs(LogScroll:GetChildren()) do
        if c:IsA("TextLabel") then c:Destroy() end
    end
    LogScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    pushLog("SYS", "Console cleared", C.textDim)
end)

ClearExecBtn.MouseButton1Click:Connect(function()
    ExecBox.Text = ""
end)

RunBtn.MouseButton1Click:Connect(function()
    local code = ExecBox.Text
    if code == "" or code == "-- paste script here" then
        pushLog("ERR", "No script to run", C.red)
        return
    end
    pushLog("SYS", "Running...", C.textDim)
    setStatus("Running script...", C.yellow)
    task.spawn(function()
        if type(loadstring) ~= "function" then
            pushLog("ERR", "loadstring unavailable in this executor", C.red)
            setStatus("Executor unsupported", C.red)
            return
        end
        local fn, err = loadstring(code)
        if not fn then
            pushLog("ERR", "Compile: " .. tostring(err), C.red)
            setStatus("Compile error", C.red)
            return
        end
        local ok, runErr = pcall(fn)
        if not ok then
            pushLog("ERR", "Runtime: " .. tostring(runErr), C.red)
            setStatus("Runtime error", C.red)
        else
            pushLog("SYS", "Done OK", C.green)
            setStatus("Script done", C.green)
        end
    end)
end)

-- ============================================================
-- PANEL: BUILDER
-- ============================================================
local PBL = makePanel("builder")
local PBLLayout = Instance.new("UIListLayout")
PBLLayout.FillDirection = Enum.FillDirection.Vertical
PBLLayout.SortOrder = Enum.SortOrder.LayoutOrder
PBLLayout.Padding = UDim.new(0, 8)
PBLLayout.Parent = PBL
pad(PBL, 2, 4, 4, 8)

local PFARM = makePanel("farm")
local PFARMLayout = Instance.new("UIListLayout")
PFARMLayout.FillDirection = Enum.FillDirection.Vertical
PFARMLayout.SortOrder = Enum.SortOrder.LayoutOrder
PFARMLayout.Padding = UDim.new(0, 8)
PFARMLayout.Parent = PFARM
pad(PFARM, 2, 4, 4, 8)

sectionLbl(PFARM, "FARM CONTROL")

local function farmCard(parent, h)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, h)
    card.BackgroundColor3 = C.surface
    card.BorderSizePixel = 0
    card.ZIndex = 104
    card.Parent = parent
    corner(card, 10)
    stroke(card, C.border, 1, 0)
    return card
end

local FarmStatusCard = farmCard(PFARM, 64)

local FarmTitleLbl = Instance.new("TextLabel")
FarmTitleLbl.Size = UDim2.new(1, -20, 0, 20)
FarmTitleLbl.Position = UDim2.new(0, 10, 0, 7)
FarmTitleLbl.BackgroundTransparency = 1
FarmTitleLbl.Text = "Auto Farm"
FarmTitleLbl.TextColor3 = C.green
FarmTitleLbl.TextSize = 12
FarmTitleLbl.Font = Enum.Font.GothamBold
FarmTitleLbl.TextXAlignment = Enum.TextXAlignment.Left
FarmTitleLbl.ZIndex = 105
FarmTitleLbl.Parent = FarmStatusCard

local FarmStatusLbl = Instance.new("TextLabel")
FarmStatusLbl.Size = UDim2.new(1, -20, 0, 28)
FarmStatusLbl.Position = UDim2.new(0, 10, 0, 30)
FarmStatusLbl.BackgroundTransparency = 1
FarmStatusLbl.Text = "Seed: Carrot | Ready"
FarmStatusLbl.TextColor3 = C.text
FarmStatusLbl.TextSize = 10
FarmStatusLbl.Font = Enum.Font.Code
FarmStatusLbl.TextXAlignment = Enum.TextXAlignment.Left
FarmStatusLbl.TextWrapped = true
FarmStatusLbl.ZIndex = 105
FarmStatusLbl.Parent = FarmStatusCard

local seedOptions = {
    "Carrot",
    "Strawberry",
    "Blueberry",
    "Tomato",
    "Corn",
    "Daffodil",
    "Watermelon",
    "Pumpkin",
    "Apple",
    "Bamboo",
    "Coconut",
    "Cactus",
    "Dragon Fruit",
    "Mango",
    "Grape",
    "Mushroom",
    "Pepper",
    "Cacao",
    "Beanstalk",
}
local selectedSeedIndex = 1
local autoBuyEnabled = false
local autoBuyThread = nil
local autoSellEnabled = false
local autoSellThread = nil
autoFarmEnabled = false
autoFarmThread = nil
autoFarmPhase = "idle"
autoFarmLastStatus = ""

local SeedPickBtn = actionBtn(PFARM, "Seed: Carrot", C.surface, 32)
local BuySeedBtn = actionBtn(PFARM, "Buy Once", C.greenDark, 32)
stroke(BuySeedBtn, C.greenMid, 1, 0.2)
local AutoBuyBtn = actionBtn(PFARM, "Auto Buy: OFF", C.surface, 32)
local SellInvBtn = actionBtn(PFARM, "Sell Now", C.greenDark, 32)
stroke(SellInvBtn, C.greenMid, 1, 0.2)
local AutoSellBtn = actionBtn(PFARM, "Auto Sell: OFF", C.surface, 32)
AutoFarmBtn = actionBtn(PFARM, "Auto Farm: OFF", C.surface, 32)

sectionLbl(PFARM, "RARE QUICK PICK")
local QuickRow = Instance.new("Frame")
QuickRow.Size = UDim2.new(1, 0, 0, 112)
QuickRow.BackgroundTransparency = 1
QuickRow.ZIndex = 104
QuickRow.Parent = PFARM

local QuickGrid = Instance.new("UIGridLayout")
QuickGrid.CellSize = UDim2.new(0, 86, 0, 30)
QuickGrid.CellPadding = UDim2.new(0, 6, 0, 7)
QuickGrid.SortOrder = Enum.SortOrder.LayoutOrder
QuickGrid.Parent = QuickRow

local function setSelectedSeed(seedName)
    for i, name in ipairs(seedOptions) do
        if name == seedName then
            selectedSeedIndex = i
            SeedPickBtn.Text = "Seed: " .. name
            FarmStatusLbl.Text = "Seed: " .. name .. " | Ready"
            return
        end
    end
end

for _, quickSeed in ipairs({ "Beanstalk", "Dragon Fruit", "Mango", "Grape", "Pepper", "Cacao" }) do
    local btn = actionBtn(QuickRow, quickSeed, C.surface, 30)
    btn.MouseButton1Click:Connect(function()
        setSelectedSeed(quickSeed)
    end)
end

sectionLbl(PBL, "REMOTE FIRE BUILDER")

local function fieldGroup(parent, labelTxt, placeholder, defaultVal)
    local grp = Instance.new("Frame")
    grp.Size = UDim2.new(1, 0, 0, 48)
    grp.BackgroundTransparency = 1
    grp.ZIndex = 104
    grp.Parent = parent

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 14)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelTxt
    lbl.TextColor3 = C.textDim
    lbl.TextSize = 9
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 105
    lbl.Parent = grp

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, 0, 0, 30)
    box.Position = UDim2.new(0, 0, 0, 16)
    box.BackgroundColor3 = C.surface
    box.BorderSizePixel = 0
    box.PlaceholderText = placeholder
    box.PlaceholderColor3 = C.textFaint
    box.Text = defaultVal or ""
    box.TextColor3 = C.text
    box.TextSize = 10
    box.Font = Enum.Font.Code
    box.TextXAlignment = Enum.TextXAlignment.Left
    box.ClearTextOnFocus = false
    box.ZIndex = 105
    box.Parent = grp
    corner(box, 7)
    stroke(box, C.border, 1, 0)
    pad(box, 8, 8, 0, 0)
    return grp, box
end

local _, PathBox = fieldGroup(PBL, "REMOTE PATH (from ReplicatedStorage)", "GameEvents.SomethingHere", "GameEvents.PlayerTeleportTriggered")
local _, ArgBox  = fieldGroup(PBL, "ARGUMENT (string - leave blank for none)", "Seed Shop", "Seed Shop")

local FireBuildBtn = actionBtn(PBL, ">  Fire Remote", C.greenDark, 36)
stroke(FireBuildBtn, C.greenMid, 1, 0.2)

local ResultCard = Instance.new("Frame")
ResultCard.Size = UDim2.new(1, 0, 0, 36)
ResultCard.BackgroundColor3 = C.surface
ResultCard.BorderSizePixel = 0
ResultCard.ZIndex = 104
ResultCard.Parent = PBL
corner(ResultCard, 8)
stroke(ResultCard, C.border, 1, 0)

local ResultLbl = Instance.new("TextLabel")
ResultLbl.Size = UDim2.new(1, 0, 1, 0)
ResultLbl.BackgroundTransparency = 1
ResultLbl.Text = "Result will appear here"
ResultLbl.TextColor3 = C.textFaint
ResultLbl.TextSize = 10
ResultLbl.Font = Enum.Font.Code
ResultLbl.TextXAlignment = Enum.TextXAlignment.Left
ResultLbl.TextWrapped = true
ResultLbl.ZIndex = 105
ResultLbl.Parent = ResultCard
pad(ResultLbl, 10, 10, 0, 0)

local TipCard = Instance.new("Frame")
TipCard.Size = UDim2.new(1, 0, 0, 86)
TipCard.BackgroundColor3 = C.surface
TipCard.BorderSizePixel = 0
TipCard.ZIndex = 104
TipCard.Parent = PBL
corner(TipCard, 8)

local TipLbl = Instance.new("TextLabel")
TipLbl.Size = UDim2.new(1, 0, 1, 0)
TipLbl.BackgroundTransparency = 1
TipLbl.Text = "BUILDER\nPath mulai dari ReplicatedStorage, contoh: GameEvents.PlayerTeleportTriggered\nFARM TOOLS\nSell Inventory = teleport ke Sell Stands lalu fire Sell_Inventory"
TipLbl.TextColor3 = C.textFaint
TipLbl.TextSize = 9
TipLbl.Font = Enum.Font.Gotham
TipLbl.TextXAlignment = Enum.TextXAlignment.Left
TipLbl.TextYAlignment = Enum.TextYAlignment.Center
TipLbl.TextWrapped = true
TipLbl.ZIndex = 105
TipLbl.Parent = TipCard
pad(TipLbl, 10, 10, 6, 6)

FireBuildBtn.MouseButton1Click:Connect(function()
    local path = PathBox.Text
    local arg  = ArgBox.Text
    if path == "" then
        ResultLbl.Text = "WARN Path cannot be empty"
        ResultLbl.TextColor3 = C.red
        return
    end
    ResultLbl.Text = "Firing..."
    ResultLbl.TextColor3 = C.yellow
    task.spawn(function()
        local ok, msg = fireRemote(path, arg)
        local display = (ok and "OK " or "X ") .. msg
        ResultLbl.Text = display
        ResultLbl.TextColor3 = ok and C.green or C.red
        setStatus(display, ok and C.green or C.red)
        pushLog(ok and "BLD" or "ERR", path .. (arg ~= "" and (' "' .. arg .. '"') or ""), ok and C.green or C.red)
    end)
end)

sectionLbl(PBL, "FARM TOOLS")
local FarmDumpBtn = actionBtn(PBL, "Dump Farm Remotes", C.surface, 32)
FarmDumpBtn.MouseButton1Click:Connect(function()
    local cmd = '-- Dump auto farm data after Farm teleport\nlocal Players=game:GetService("Players")\nlocal RS=game:GetService("ReplicatedStorage")\nlocal LP=Players.LocalPlayer\nlocal ge=RS:FindFirstChild("GameEvents")\nlocal tp=ge and ge:FindFirstChild("PlayerTeleportTriggered")\nif tp then pcall(function() tp:FireServer("Farm") end) task.wait(1.5) end\nlocal root=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")\nprint("== LOWHUB GARDEN DUMP ==")\nprint("Player", LP.Name)\nif root then print("RootPos", root.Position.X, root.Position.Y, root.Position.Z) end\nprint("== TOOLS ==")\nfor _,c in ipairs({LP.Backpack, LP.Character}) do\n    if c then for _,v in ipairs(c:GetChildren()) do if v:IsA("Tool") then print(v:GetFullName(), "Seed", tostring(v:GetAttribute("Seed")), "Qty", tostring(v:GetAttribute("Quantity"))) end end end\nend\nprint("== REMOTES ==")\nfor _,v in ipairs(RS:GetDescendants()) do\n    if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then\n        local n=v.Name:lower()\n        if n:find("sell") or n:find("garden") or n:find("seed") or n:find("plant") or n:find("harvest") or n:find("crop") or n:find("buy") or n:find("shop") or n:find("inventory") or n:find("teleport") then print(v.ClassName, v:GetFullName()) end\n    end\nend\nprint("== CAN_PLANT PARTS ==")\nif root then\n    for _,v in ipairs(workspace:GetDescendants()) do\n        local n=v.Name:lower()\n        if v:IsA("BasePart") and (n:find("can_plant") or n:find("plant_location")) then\n            local p=v.Position\n            if (root.Position-p).Magnitude<180 then print(v:GetFullName(), "dist", math.floor((root.Position-p).Magnitude), "pos", math.floor(p.X), math.floor(p.Y), math.floor(p.Z), "Side", tostring(v:GetAttribute("Side"))) end\n        end\n    end\nend\nprint("== NEAR CROP OBJECTS ==")\nif root then\n    for _,v in ipairs(workspace:GetDescendants()) do\n        local n=v.Name:lower()\n        if not v:IsA("Tool") and (n:find("carrot") or n:find("fruit") or n:find("crop") or n:find("plant")) then\n            local ok,p=pcall(function() return v:IsA("BasePart") and v.Position or (v:IsA("Model") and v:GetPivot().Position) end)\n            if ok and p and (root.Position-p).Magnitude<120 then print(v.ClassName, v:GetFullName(), "dist", math.floor((root.Position-p).Magnitude)) end\n        end\n    end\nend'
    if type(setclipboard) == "function" then pcall(function() setclipboard(cmd) end) end
    print(cmd)
    ResultLbl.Text = "Auto farm dump copied/printed"
    ResultLbl.TextColor3 = C.green
    setStatus("Auto farm dump ready", C.green)
    pushLog("BLD", "Auto farm dump command copied/printed", C.green)
end)

local function buySelectedSeedOnce()
    local seedName = seedOptions[selectedSeedIndex]
    setStatus("Buying " .. seedName .. " seed...", C.yellow)
    pcall(function()
        local ch, _, root = getCharacter()
        if ch and root then
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
            ch:PivotTo(CFrame.new(36.4, 3.0, -24.6))
        end
    end)
    task.wait(0.4)
    local ok, msg = pcall(function()
        local gui = PlayerGui:FindFirstChild("Seed_Shop")
        local shop = gui and gui:FindFirstChild("Frame")
        local scroll = shop and shop:FindFirstChild("ScrollingFrame")
        local item = scroll and scroll:FindFirstChild(seedName)
        local frame = item and item:FindFirstChild("Frame")
        local buy = frame and frame:FindFirstChild("Sheckles_Buy")
        if not buy then error(seedName .. " buy button not found") end
        if type(firesignal) ~= "function" then error("firesignal unavailable") end
        firesignal(buy.Activated)
    end)
    local resultText = ok and ("Buy " .. seedName .. " clicked") or ("Buy " .. seedName .. " failed: " .. tostring(msg))
    FarmStatusLbl.Text = "Seed: " .. seedName .. " | " .. resultText
    setStatus(resultText, ok and C.green or C.red)
    pushLog(ok and "FARM" or "ERR", resultText, ok and C.green or C.red)
    return ok
end

local function sellInventoryOnce()
    setStatus("Moving to Sell Stands...", C.yellow)
    pcall(function()
        local ch, _, root = getCharacter()
        if ch and root then
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
            ch:PivotTo(CFrame.new(37.1, 3.0, 1.5))
        end
    end)
    task.wait(0.6)
    local ok, msg = fireRemote("GameEvents.Sell_Inventory", "")
    local resultText = ok and "Sell inventory fired" or ("Sell failed: " .. msg)
    FarmStatusLbl.Text = "Sell | " .. resultText
    setStatus(resultText, ok and C.green or C.red)
    pushLog(ok and "FARM" or "ERR", "Sell_Inventory -> " .. msg, ok and C.green or C.red)
    return ok
end

function farmSetPhase(phase, detail, color)
    local txt = "Auto Farm | " .. phase .. (detail and detail ~= "" and (" | " .. detail) or "")
    autoFarmPhase = phase
    if txt ~= autoFarmLastStatus then
        autoFarmLastStatus = txt
        FarmStatusLbl.Text = txt
        setStatus(txt, color or C.yellow)
        pushLog("FARM", txt, color or C.yellow)
    end
end

function findSeedTool(seedName)
    local ch = Player.Character
    local containers = { Player:FindFirstChild("Backpack"), ch }
    local needle = seedName:lower()
    for _, container in ipairs(containers) do
        if container then
            for _, item in ipairs(container:GetChildren()) do
                if item:IsA("Tool") then
                    local n = item.Name:lower()
                    if n:find(needle, 1, true) and n:find("seed", 1, true) then
                        return item
                    end
                end
            end
        end
    end
    return nil
end

function equipSeedTool(seedName)
    local tool = findSeedTool(seedName)
    if not tool then return nil, "seed tool not found" end
    local ch, hum = getCharacter()
    if hum and tool.Parent ~= ch then
        pcall(function() hum:EquipTool(tool) end)
        task.wait(0.2)
    end
    return tool, "equipped"
end

function getSeedQuantity(tool)
    if not tool then return 0 end
    local qty = tonumber(tool:GetAttribute("Quantity")) or 0
    if qty <= 0 then
        local found = tostring(tool.Name):match("%[X(%d+)%]")
        qty = tonumber(found) or 1
    end
    if qty > 12 then qty = 12 end
    if qty < 0 then qty = 0 end
    return qty
end

function getPlantPosition(index)
    local _, _, root = getCharacter()
    if not root then return Vector3.new(0, 0, 0), "no root" end
    local best, bestDist = nil, 160
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local n = obj.Name:lower()
            if n:find("can_plant", 1, true) then
                local dist = (root.Position - obj.Position).Magnitude
                if dist < bestDist then
                    best = obj
                    bestDist = dist
                end
            end
        end
    end
    if best then
        local p = best.Position
        local i = index or 1
        local ox = ((i - 1) % 4) * 2.2 - 3.3
        local oz = (math.floor((i - 1) / 4) % 3) * 2.2 - 2.2
        return Vector3.new(p.X + ox, 0.1355266571044922, p.Z + oz), "nearest Can_Plant"
    end
    local p = root.Position + (root.CFrame.LookVector * (5 + ((index or 1) % 4)))
    return Vector3.new(p.X, 0.1355266571044922, p.Z), "front of player"
end

function teleportToPlantPosition()
    local _, _, root = getCharacter()
    if not root then return false, "character missing" end
    local ge = ReplicatedStorage:FindFirstChild("GameEvents")
    local tp = ge and ge:FindFirstChild("PlayerTeleportTriggered")
    if not tp then return false, "Farm teleport remote missing" end
    local start = root.Position
    pcall(function() tp:FireServer("Farm") end)
    task.wait(1.2)
    local moved = (root.Position - start).Magnitude
    return true, "Farm remote moved " .. tostring(math.floor(moved))
end

function plantSelectedSeedBatch()
    if not autoFarmEnabled then return false, "stopped", 0 end
    local seedName = seedOptions[selectedSeedIndex]
    farmSetPhase("check seed", seedName, C.yellow)
    local tool = findSeedTool(seedName)
    if not tool then return false, "selected seed missing", 0 end
    local count = getSeedQuantity(tool)
    if count <= 0 then return false, "seed quantity 0", 0 end
    local equipped, equipMsg = equipSeedTool(seedName)
    if not autoFarmEnabled then return false, "stopped", 0 end
    if not equipped then return false, equipMsg, 0 end
    farmSetPhase("teleport garden", seedName, C.yellow)
    local tpOk, tpMsg = teleportToPlantPosition()
    if not autoFarmEnabled then return false, "stopped", 0 end
    if not tpOk then return false, tpMsg, 0 end
    local remote = ReplicatedStorage:FindFirstChild("GameEvents") and ReplicatedStorage.GameEvents:FindFirstChild("Plant_RE")
    if not remote then return false, "Plant_RE not found", 0 end
    local planted = 0
    local posSource = "unknown"
    farmSetPhase("plant batch", seedName .. " x" .. tostring(count), C.yellow)
    for i = 1, count do
        if not autoFarmEnabled then return false, "stopped", planted end
        local pos
        pos, posSource = getPlantPosition(i)
        local ok = pcall(function() remote:FireServer(pos, seedName) end)
        if ok then planted = planted + 1 end
        if i == count or i == 1 or i == 6 or i == 12 then
            farmSetPhase("plant batch", tostring(planted) .. "/" .. tostring(count) .. " at " .. posSource, C.yellow)
        end
        task.wait(0.25)
    end
    local msg = "planted " .. tostring(planted) .. "/" .. tostring(count)
    farmSetPhase(planted > 0 and "planted" or "plant failed", msg, planted > 0 and C.green or C.red)
    return planted > 0, msg, planted
end

function plantSelectedSeedOnce()
    local ok, msg = plantSelectedSeedBatch()
    return ok, msg
end

function isOwnCharacterOrTool(obj)
    local ch = Player.Character
    local backpack = Player:FindFirstChild("Backpack")
    if ch and (obj == ch or obj:IsDescendantOf(ch)) then return true end
    if backpack and (obj == backpack or obj:IsDescendantOf(backpack)) then return true end
    if obj:IsA("Tool") or obj:FindFirstAncestorOfClass("Tool") then return true end
    return false
end

function findHarvestTarget(seedName)
    local _, _, root = getCharacter()
    if not root then return nil end
    local needle = seedName:lower()
    local best, bestDist = nil, 120
    for _, obj in ipairs(workspace:GetDescendants()) do
        if (obj:IsA("Model") or obj:IsA("BasePart")) and not isOwnCharacterOrTool(obj) then
            local n = obj.Name:lower()
            local farmParent = obj:FindFirstAncestor("Farm") or obj:FindFirstAncestor("Plants") or obj:FindFirstAncestor("Fruits")
            local harvestName = n:find(needle, 1, true) or n:find("fruit", 1, true) or n:find("crop", 1, true) or n:find("plant", 1, true)
            if farmParent and harvestName and not n:find("seed", 1, true) and not n:find("can_plant", 1, true) then
                local cf = getInstanceCFrame(obj)
                if cf then
                    local dist = (root.Position - cf.Position).Magnitude
                    if dist < bestDist then
                        best = obj
                        bestDist = dist
                    end
                end
            end
        end
    end
    return best
end

function harvestSelectedSeedOnce()
    if not autoFarmEnabled then return false, "stopped" end
    local seedName = seedOptions[selectedSeedIndex]
    local target = findHarvestTarget(seedName)
    if not target then return false, "harvest target not found" end
    local cf = getInstanceCFrame(target)
    pcall(function()
        local ch, _, root = getCharacter()
        if ch and root and cf then ch:PivotTo(cf + Vector3.new(0, 2, 0)) end
    end)
    task.wait(0.3)
    if not autoFarmEnabled then return false, "stopped" end
    local okAny = false
    for _, d in ipairs(target:GetDescendants()) do
        if d:IsA("ProximityPrompt") and type(fireproximityprompt) == "function" then
            okAny = pcall(function() fireproximityprompt(d) end) or okAny
        elseif d:IsA("ClickDetector") and type(fireclickdetector) == "function" then
            okAny = pcall(function() fireclickdetector(d) end) or okAny
        end
    end
    local remote = ReplicatedStorage:FindFirstChild("GameEvents") and ReplicatedStorage.GameEvents:FindFirstChild("HarvestRemote")
    if remote then
        if remote:IsA("RemoteFunction") then
            okAny = pcall(function() remote:InvokeServer(target) end) or okAny
        else
            okAny = pcall(function() remote:FireServer(target) end) or okAny
        end
    end
    return okAny, okAny and ("harvest attempted: " .. target.Name) or "harvest failed"
end

function harvestReadyBatch()
    local tries = 0
    local done = 0
    while autoFarmEnabled and tries < 20 do
        local target = findHarvestTarget(seedOptions[selectedSeedIndex])
        if not target then break end
        tries = tries + 1
        farmSetPhase("harvest all", target.Name, C.green)
        local ok = harvestSelectedSeedOnce()
        if ok then done = done + 1 end
        task.wait(0.5)
    end
    return done, tries
end

function autoFarmStep()
    local seedName = seedOptions[selectedSeedIndex]
    local plantOk, plantMsg, planted = plantSelectedSeedBatch()
    if not plantOk then
        farmSetPhase("plant blocked", plantMsg, C.red)
        task.wait(8)
        return
    end
    local waited = 0
    local target = findHarvestTarget(seedName)
    farmSetPhase("wait harvest", "planted " .. tostring(planted), C.yellow)
    while autoFarmEnabled and waited < 60 and not target do
        task.wait(5)
        waited = waited + 5
        target = findHarvestTarget(seedName)
        if waited == 15 or waited == 30 or waited == 60 then
            farmSetPhase("wait harvest", tostring(waited) .. "s after " .. tostring(planted) .. " plants", C.yellow)
        end
    end
    if not autoFarmEnabled then return end
    if target then
        farmSetPhase("harvest ready", target.Name, C.green)
    else
        farmSetPhase("harvest timeout", seedName, C.yellow)
    end
    local done, tries = harvestReadyBatch()
    farmSetPhase(done > 0 and "harvest done" or "harvest miss", tostring(done) .. "/" .. tostring(tries), done > 0 and C.green or C.yellow)
    task.wait(0.8)
    if autoFarmEnabled then
        farmSetPhase("sell", "inventory", C.yellow)
        sellInventoryOnce()
    end
    task.wait(1.2)
    task.wait(2)
end

SeedPickBtn.MouseButton1Click:Connect(function()
    selectedSeedIndex = selectedSeedIndex + 1
    if selectedSeedIndex > #seedOptions then selectedSeedIndex = 1 end
    SeedPickBtn.Text = "Seed: " .. seedOptions[selectedSeedIndex]
    FarmStatusLbl.Text = "Seed: " .. seedOptions[selectedSeedIndex] .. " | Ready"
end)

BuySeedBtn.MouseButton1Click:Connect(function()
    task.spawn(buySelectedSeedOnce)
end)

AutoBuyBtn.MouseButton1Click:Connect(function()
    autoBuyEnabled = not autoBuyEnabled
    AutoBuyBtn.Text = autoBuyEnabled and "Auto Buy: ON" or "Auto Buy: OFF"
    AutoBuyBtn.BackgroundColor3 = autoBuyEnabled and C.greenDark or C.surface
    if autoBuyEnabled and not autoBuyThread then
        autoBuyThread = task.spawn(function()
            while autoBuyEnabled do
                pcall(buySelectedSeedOnce)
                task.wait(1.5)
            end
            autoBuyThread = nil
        end)
    end
end)

SellInvBtn.MouseButton1Click:Connect(function()
    task.spawn(sellInventoryOnce)
end)

AutoSellBtn.MouseButton1Click:Connect(function()
    autoSellEnabled = not autoSellEnabled
    AutoSellBtn.Text = autoSellEnabled and "Auto Sell: ON" or "Auto Sell: OFF"
    AutoSellBtn.BackgroundColor3 = autoSellEnabled and C.greenDark or C.surface
    if autoSellEnabled and not autoSellThread then
        autoSellThread = task.spawn(function()
            while autoSellEnabled do
                pcall(sellInventoryOnce)
                task.wait(5)
            end
            autoSellThread = nil
        end)
    end
end)

AutoFarmBtn.MouseButton1Click:Connect(function()
    autoFarmEnabled = not autoFarmEnabled
    AutoFarmBtn.Text = autoFarmEnabled and "Auto Farm: ON" or "Auto Farm: OFF"
    AutoFarmBtn.BackgroundColor3 = autoFarmEnabled and C.greenDark or C.surface
    farmSetPhase(autoFarmEnabled and "running" or "stopped", seedOptions[selectedSeedIndex], autoFarmEnabled and C.green or C.red)
    if autoFarmEnabled and not autoFarmThread then
        autoFarmThread = task.spawn(function()
            while autoFarmEnabled do
                pcall(autoFarmStep)
                task.wait(1)
            end
            autoFarmThread = nil
            farmSetPhase("stopped", "loop ended", C.red)
        end)
    end
end)

-- ============================================================
-- PANEL: EGG ESP
-- ============================================================
local PESP = makePanel("esp")
local PESPLayout = Instance.new("UIListLayout")
PESPLayout.FillDirection = Enum.FillDirection.Vertical
PESPLayout.SortOrder = Enum.SortOrder.LayoutOrder
PESPLayout.Padding = UDim.new(0, 8)
PESPLayout.Parent = PESP
pad(PESP, 2, 4, 4, 8)

-- Toggle card
local ToggleCard = Instance.new("Frame")
ToggleCard.Size = UDim2.new(1, 0, 0, 56)
ToggleCard.BackgroundColor3 = C.card
ToggleCard.BorderSizePixel = 0
ToggleCard.ZIndex = 104
ToggleCard.Parent = PESP
corner(ToggleCard, 10)
stroke(ToggleCard, C.border, 1, 0)

local ToggleAccent = Instance.new("Frame")
ToggleAccent.Size = UDim2.new(0, 3, 1, -12)
ToggleAccent.Position = UDim2.new(0, 0, 0, 6)
ToggleAccent.BackgroundColor3 = C.purple
ToggleAccent.BackgroundTransparency = 0.3
ToggleAccent.BorderSizePixel = 0
ToggleAccent.ZIndex = 105
ToggleAccent.Parent = ToggleCard
corner(ToggleAccent, 2)

local EspIconLbl = Instance.new("TextLabel")
EspIconLbl.Size = UDim2.new(0, 32, 0, 32)
EspIconLbl.Position = UDim2.new(0, 14, 0.5, -16)
EspIconLbl.BackgroundColor3 = lerpColor(C.purple, C.bg, 0.75)
EspIconLbl.BorderSizePixel = 0
EspIconLbl.Text = "E"
EspIconLbl.TextSize = 16
EspIconLbl.Font = Enum.Font.GothamBold
EspIconLbl.TextColor3 = C.purple
EspIconLbl.ZIndex = 105
EspIconLbl.Parent = ToggleCard
corner(EspIconLbl, 8)

local EspTitleLbl = Instance.new("TextLabel")
EspTitleLbl.Size = UDim2.new(1, -120, 0, 18)
EspTitleLbl.Position = UDim2.new(0, 56, 0, 10)
EspTitleLbl.BackgroundTransparency = 1
EspTitleLbl.Text = "Pet Egg ESP"
EspTitleLbl.TextColor3 = C.text
EspTitleLbl.TextSize = 12
EspTitleLbl.Font = Enum.Font.GothamBold
EspTitleLbl.TextXAlignment = Enum.TextXAlignment.Left
EspTitleLbl.ZIndex = 105
EspTitleLbl.Parent = ToggleCard

local EspSubLbl = Instance.new("TextLabel")
EspSubLbl.Size = UDim2.new(1, -120, 0, 14)
EspSubLbl.Position = UDim2.new(0, 56, 0, 30)
EspSubLbl.BackgroundTransparency = 1
EspSubLbl.Text = "Show egg names, rarity, weight"
EspSubLbl.TextColor3 = C.textDim
EspSubLbl.TextSize = 9
EspSubLbl.Font = Enum.Font.Gotham
EspSubLbl.TextXAlignment = Enum.TextXAlignment.Left
EspSubLbl.ZIndex = 105
EspSubLbl.Parent = ToggleCard

-- Toggle pill button
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 52, 0, 26)
ToggleBtn.Position = UDim2.new(1, -62, 0.5, -13)
ToggleBtn.BackgroundColor3 = C.surface
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Text = "OFF"
ToggleBtn.TextColor3 = C.textDim
ToggleBtn.TextSize = 10
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.ZIndex = 106
ToggleBtn.Parent = ToggleCard
corner(ToggleBtn, 13)
stroke(ToggleBtn, C.border, 1, 0)

local function updateToggleUI()
    if espEnabled then
        TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = C.purple
        }):Play()
        ToggleBtn.Text = "ON"
        ToggleBtn.TextColor3 = C.white
        stroke(ToggleBtn, C.purple, 1, 0.2)
        stroke(ToggleCard, C.purple, 1, 0.5)
    else
        TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = C.surface
        }):Play()
        ToggleBtn.Text = "OFF"
        ToggleBtn.TextColor3 = C.textDim
        stroke(ToggleBtn, C.border, 1, 0)
        stroke(ToggleCard, C.border, 1, 0)
    end
end

ToggleBtn.MouseButton1Click:Connect(function()
    if espEnabled then
        disableEsp()
        setStatus("ESP disabled", C.textMid)
        pushLog("ESP", "Disabled", C.textDim)
    else
        enableEsp()
        setStatus("ESP enabled - scanning eggs...", C.purple)
        pushLog("ESP", "Enabled", C.purple)
    end
    updateToggleUI()
end)

-- Stats row
local StatsRow = Instance.new("Frame")
StatsRow.Size = UDim2.new(1, 0, 0, 36)
StatsRow.BackgroundTransparency = 1
StatsRow.ZIndex = 104
StatsRow.Parent = PESP

local StatsLayout = Instance.new("UIListLayout")
StatsLayout.FillDirection = Enum.FillDirection.Horizontal
StatsLayout.SortOrder = Enum.SortOrder.LayoutOrder
StatsLayout.Padding = UDim.new(0, 6)
StatsLayout.Parent = StatsRow

local function statChip(parent, labelTxt, valTxt, col, order)
    local chip = Instance.new("Frame")
    chip.Size = UDim2.new(0.5, -3, 1, 0)
    chip.BackgroundColor3 = C.surface
    chip.BorderSizePixel = 0
    chip.ZIndex = 105
    chip.LayoutOrder = order
    chip.Parent = parent
    corner(chip, 8)
    stroke(chip, C.border, 1, 0)

    local valL = Instance.new("TextLabel")
    valL.Size = UDim2.new(1, 0, 0, 18)
    valL.Position = UDim2.new(0, 0, 0, 4)
    valL.BackgroundTransparency = 1
    valL.Text = valTxt
    valL.TextColor3 = col or C.text
    valL.TextSize = 14
    valL.Font = Enum.Font.GothamBold
    valL.ZIndex = 106
    valL.Parent = chip

    local labL = Instance.new("TextLabel")
    labL.Size = UDim2.new(1, 0, 0, 10)
    labL.Position = UDim2.new(0, 0, 0, 22)
    labL.BackgroundTransparency = 1
    labL.Text = labelTxt
    labL.TextColor3 = C.textFaint
    labL.TextSize = 8
    labL.Font = Enum.Font.Gotham
    labL.ZIndex = 106
    labL.Parent = chip

    return chip, valL
end

local _, ActiveCountLbl = statChip(StatsRow, "ACTIVE EGGS", "0", C.purple, 1)
local _, TotalSeenLbl   = statChip(StatsRow, "TOTAL SEEN", "0", C.blue, 2)
local totalSeen = 0
local rebuildEggList

sectionLbl(PESP, "FILTERS")

local FilterRow = Instance.new("Frame")
FilterRow.Size = UDim2.new(1, 0, 0, 28)
FilterRow.BackgroundTransparency = 1
FilterRow.ZIndex = 104
FilterRow.Parent = PESP
local FilterLayout = Instance.new("UIListLayout")
FilterLayout.FillDirection = Enum.FillDirection.Horizontal
FilterLayout.SortOrder = Enum.SortOrder.LayoutOrder
FilterLayout.Padding = UDim.new(0, 4)
FilterLayout.Parent = FilterRow

local filterButtons = {}
local function smallBtn(parent, text, width, col)
    local b = actionBtn(parent, text, col or C.surface, 28)
    b.Size = UDim2.new(0, width or 64, 1, 0)
    b.TextSize = 9
    return b
end
local function updateFilterButtons()
    for rarity, btn in pairs(filterButtons) do
        if espSettings.rarityFilter == rarity then
            btn.BackgroundColor3 = C.purple
            btn.TextColor3 = C.white
            stroke(btn, C.purple, 1, 0.2)
        else
            btn.BackgroundColor3 = C.surface
            btn.TextColor3 = C.text
            stroke(btn, C.border, 1, 0)
        end
    end
end

for _, rarity in ipairs({"All", "Common", "Rare", "Epic", "Legendary"}) do
    local btn = smallBtn(FilterRow, rarity, rarity == "Legendary" and 78 or 58)
    filterButtons[rarity] = btn
    btn.MouseButton1Click:Connect(function()
        espSettings.rarityFilter = rarity
        updateFilterButtons()
        if rebuildEggList then rebuildEggList() end
        setStatus("ESP filter: " .. rarity, C.purple)
    end)
end
updateFilterButtons()

local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(1, 0, 0, 30)
SearchBox.BackgroundColor3 = C.surface
SearchBox.BorderSizePixel = 0
SearchBox.PlaceholderText = "Search egg or pet name..."
SearchBox.PlaceholderColor3 = C.textFaint
SearchBox.Text = ""
SearchBox.TextColor3 = C.text
SearchBox.TextSize = 10
SearchBox.Font = Enum.Font.Code
SearchBox.TextXAlignment = Enum.TextXAlignment.Left
SearchBox.ClearTextOnFocus = false
SearchBox.ZIndex = 104
SearchBox.Parent = PESP
corner(SearchBox, 8)
stroke(SearchBox, C.border, 1, 0)
pad(SearchBox, 8, 8, 0, 0)
SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    espSettings.searchText = SearchBox.Text:lower()
    if rebuildEggList then rebuildEggList() end
end)

sectionLbl(PESP, "SETTINGS")

local SettingsRow = Instance.new("Frame")
SettingsRow.Size = UDim2.new(1, 0, 0, 62)
SettingsRow.BackgroundTransparency = 1
SettingsRow.ZIndex = 104
SettingsRow.Parent = PESP
local SettingsLayout = Instance.new("UIGridLayout")
SettingsLayout.CellSize = UDim2.new(0.5, -4, 0, 28)
SettingsLayout.CellPadding = UDim2.new(0, 6, 0, 6)
SettingsLayout.SortOrder = Enum.SortOrder.LayoutOrder
SettingsLayout.Parent = SettingsRow

local function toggleSetting(key, label)
    local btn = actionBtn(SettingsRow, label .. ": ON", C.surface, 28)
    btn.TextSize = 9
    local function refresh()
        btn.Text = label .. ": " .. (espSettings[key] and "ON" or "OFF")
        btn.TextColor3 = espSettings[key] and C.purple or C.textDim
    end
    btn.MouseButton1Click:Connect(function()
        espSettings[key] = not espSettings[key]
        refresh()
        if rebuildEggList then rebuildEggList() end
    end)
    refresh()
    return btn
end

toggleSetting("showEggName", "Egg")
toggleSetting("showPetName", "Pet")
toggleSetting("showWeight", "Weight")
toggleSetting("showDistance", "Distance")

local ModeRow = Instance.new("Frame")
ModeRow.Size = UDim2.new(1, 0, 0, 28)
ModeRow.BackgroundTransparency = 1
ModeRow.ZIndex = 104
ModeRow.Parent = PESP
local ModeLayout = Instance.new("UIListLayout")
ModeLayout.FillDirection = Enum.FillDirection.Horizontal
ModeLayout.SortOrder = Enum.SortOrder.LayoutOrder
ModeLayout.Padding = UDim.new(0, 6)
ModeLayout.Parent = ModeRow

local ColorModeBtn = smallBtn(ModeRow, "Color: Rarity", 112)
ColorModeBtn.MouseButton1Click:Connect(function()
    espSettings.colorMode = (espSettings.colorMode == "Rarity") and "Static" or "Rarity"
    ColorModeBtn.Text = "Color: " .. espSettings.colorMode
    setStatus("ESP color mode: " .. espSettings.colorMode, C.purple)
end)
SizeBtn = smallBtn(ModeRow, "Size: 1x", 82)
SizeBtn.MouseButton1Click:Connect(function()
    local vals = {1, 1.25, 1.5, 0.75}
    local idx = 1
    for i, v in ipairs(vals) do if espSettings.boxScale == v then idx = i break end end
    espSettings.boxScale = vals[(idx % #vals) + 1]
    SizeBtn.Text = "Size: " .. tostring(espSettings.boxScale) .. "x"
end)
SortBtn = smallBtn(ModeRow, "Sort: Distance", 116)
SortBtn.MouseButton1Click:Connect(function()
    local vals = {"Distance", "Rarity", "Weight"}
    local idx = 1
    for i, v in ipairs(vals) do if espSettings.sortMode == v then idx = i break end end
    espSettings.sortMode = vals[(idx % #vals) + 1]
    SortBtn.Text = "Sort: " .. espSettings.sortMode
    if rebuildEggList then rebuildEggList() end
end)
MaxDistBtn = smallBtn(ModeRow, "Max: INF", 70)
MaxDistBtn.MouseButton1Click:Connect(function()
    local vals = {0, 50, 100, 250, 500}
    local idx = 1
    for i, v in ipairs(vals) do if espSettings.maxDistance == v then idx = i break end end
    espSettings.maxDistance = vals[(idx % #vals) + 1]
    MaxDistBtn.Text = espSettings.maxDistance == 0 and "Max: INF" or ("Max: " .. espSettings.maxDistance)
    if rebuildEggList then rebuildEggList() end
end)

-- Section: Active List
sectionLbl(PESP, "ACTIVE EGG LIST")

EggListFrame = Instance.new("Frame")
EggListFrame.Size = UDim2.new(1, 0, 0, 200)
EggListFrame.BackgroundColor3 = C.surface
EggListFrame.BorderSizePixel = 0
EggListFrame.ZIndex = 104
EggListFrame.Parent = PESP
corner(EggListFrame, 8)
stroke(EggListFrame, C.border, 1, 0)

EggListScroll = Instance.new("ScrollingFrame")
EggListScroll.Size = UDim2.new(1, -2, 1, -2)
EggListScroll.Position = UDim2.new(0, 1, 0, 1)
EggListScroll.BackgroundTransparency = 1
EggListScroll.ScrollBarThickness = 3
EggListScroll.ScrollBarImageColor3 = C.purple
EggListScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
EggListScroll.ZIndex = 105
EggListScroll.Parent = EggListFrame

EggListLayout = Instance.new("UIListLayout")
EggListLayout.FillDirection = Enum.FillDirection.Vertical
EggListLayout.SortOrder = Enum.SortOrder.LayoutOrder
EggListLayout.Padding = UDim.new(0, 2)
EggListLayout.Parent = EggListScroll
pad(EggListScroll, 6, 6, 4, 4)

-- Empty state label
EmptyLbl = Instance.new("TextLabel")
EmptyLbl.Size = UDim2.new(1, 0, 0, 40)
EmptyLbl.BackgroundTransparency = 1
EmptyLbl.Text = "No active eggs - enable ESP first"
EmptyLbl.TextColor3 = C.textFaint
EmptyLbl.TextSize = 10
EmptyLbl.Font = Enum.Font.Gotham
EmptyLbl.ZIndex = 106
EmptyLbl.Parent = EggListScroll

rebuildEggList = function()
    for _, c in ipairs(EggListScroll:GetChildren()) do
        if c:IsA("TextButton") or c:IsA("Frame") then c:Destroy() end
    end

    local rows = {}
    local search = espSettings.searchText or ""
    for id, object in pairs(activeEggs) do
        if object and object:IsDescendantOf(workspace) then
            local eggName = tostring(object:GetAttribute("EggName") or "?")
            local petName = tostring((eggPets and eggPets[id]) or "?")
            local rarityLabel, rarityColor = getRarityLabel(eggName, petName)
            local dist = getEggDistance(object)
            local wtText = buildWeightText(id, eggName, petName)
            local matchesRarity = (espSettings.rarityFilter == "All" or rarityLabel == espSettings.rarityFilter)
            local matchesSearch = (search == "" or eggName:lower():find(search, 1, true) or petName:lower():find(search, 1, true))
            local matchesDistance = (espSettings.maxDistance == 0 or dist <= espSettings.maxDistance)
            if matchesRarity and matchesSearch and matchesDistance then
                table.insert(rows, {
                    id = id,
                    object = object,
                    eggName = eggName,
                    petName = petName,
                    rarityLabel = rarityLabel,
                    rarityColor = rarityColor,
                    dist = dist,
                    wtText = wtText,
                    rank = RARITY_RANK[rarityLabel] or 0,
                    weight = tonumber((wtText:match("([%d%.]+)"))) or 0,
                })
            end
        end
    end

    table.sort(rows, function(a, b)
        if espSettings.sortMode == "Rarity" then
            if a.rank == b.rank then return a.dist < b.dist end
            return a.rank > b.rank
        elseif espSettings.sortMode == "Weight" then
            if a.weight == b.weight then return a.dist < b.dist end
            return a.weight > b.weight
        end
        return a.dist < b.dist
    end)

    for count, data in ipairs(rows) do
        local row = Instance.new("TextButton")
        row.Size = UDim2.new(1, 0, 0, 42)
        row.BackgroundColor3 = C.card
        row.BorderSizePixel = 0
        row.Text = ""
        row.AutoButtonColor = true
        row.ZIndex = 106
        row.LayoutOrder = count
        row.Parent = EggListScroll
        corner(row, 6)

        local accent = Instance.new("Frame")
        accent.Size = UDim2.new(0, 3, 1, -8)
        accent.Position = UDim2.new(0, 0, 0, 4)
        accent.BackgroundColor3 = data.rarityColor
        accent.BackgroundTransparency = 0.2
        accent.BorderSizePixel = 0
        accent.ZIndex = 107
        accent.Parent = row
        corner(accent, 2)

        local petL = Instance.new("TextLabel")
        petL.Size = UDim2.new(1, -142, 0, 16)
        petL.Position = UDim2.new(0, 12, 0, 4)
        petL.BackgroundTransparency = 1
        petL.Text = data.petName
        petL.TextColor3 = data.rarityColor
        petL.TextSize = 11
        petL.Font = Enum.Font.GothamBold
        petL.TextXAlignment = Enum.TextXAlignment.Left
        petL.TextTruncate = Enum.TextTruncate.AtEnd
        petL.ZIndex = 107
        petL.Parent = row

        local eggL = Instance.new("TextLabel")
        eggL.Size = UDim2.new(1, -142, 0, 12)
        eggL.Position = UDim2.new(0, 12, 0, 22)
        eggL.BackgroundTransparency = 1
        eggL.Text = data.eggName .. "  -  " .. data.rarityLabel
        eggL.TextColor3 = C.textDim
        eggL.TextSize = 9
        eggL.Font = Enum.Font.Gotham
        eggL.TextXAlignment = Enum.TextXAlignment.Left
        eggL.ZIndex = 107
        eggL.Parent = row

        local wtL = Instance.new("TextLabel")
        wtL.Size = UDim2.new(0, 92, 0, 14)
        wtL.Position = UDim2.new(1, -98, 0, 4)
        wtL.BackgroundTransparency = 1
        wtL.Text = data.wtText
        wtL.TextColor3 = Color3.fromRGB(150,220,255)
        wtL.TextSize = 9
        wtL.Font = Enum.Font.GothamBold
        wtL.TextXAlignment = Enum.TextXAlignment.Right
        wtL.ZIndex = 107
        wtL.Parent = row

        local distL = Instance.new("TextLabel")
        distL.Size = UDim2.new(0, 92, 0, 12)
        distL.Position = UDim2.new(1, -98, 0, 22)
        distL.BackgroundTransparency = 1
        distL.Text = data.dist .. "m - tap TP"
        distL.TextColor3 = C.textFaint
        distL.TextSize = 8
        distL.Font = Enum.Font.Gotham
        distL.TextXAlignment = Enum.TextXAlignment.Right
        distL.ZIndex = 107
        distL.Parent = row

        row.MouseButton1Click:Connect(function()
            local ok, msg = teleportToPos(data.object:GetPivot().Position)
            setStatus(ok and ("Teleported to egg: " .. data.petName) or msg, ok and C.purple or C.red)
            pushLog(ok and "ESP" or "ERR", "Egg TP -> " .. data.petName .. " / " .. data.eggName, ok and C.purple or C.red)
        end)
    end

    EmptyLbl.Visible = (#rows == 0)
    EmptyLbl.Text = espEnabled and "No eggs match current filters" or "No active eggs - enable ESP first"
    ActiveCountLbl.Text = tostring(#rows)
    EggListScroll.CanvasSize = UDim2.new(0, 0, 0, EggListLayout.AbsoluteContentSize.Y + 8)
end

-- Register rebuild callback
table.insert(espListCallbacks, rebuildEggList)

-- Also track totalSeen
_origAddEsp = addEsp
addEsp = function(object)
    _origAddEsp(object)
    local id = object:GetAttribute("OBJECT_UUID")
    if id and espCache[id] then
        totalSeen = totalSeen + 1
        TotalSeenLbl.Text = tostring(totalSeen)
    end
end

EspActionRow = Instance.new("Frame")
EspActionRow.Size = UDim2.new(1, 0, 0, 28)
EspActionRow.BackgroundTransparency = 1
EspActionRow.ZIndex = 104
EspActionRow.Parent = PESP
EARLayout = Instance.new("UIListLayout")
EARLayout.FillDirection = Enum.FillDirection.Horizontal
EARLayout.SortOrder = Enum.SortOrder.LayoutOrder
EARLayout.Padding = UDim.new(0, 6)
EARLayout.Parent = EspActionRow

RefreshBtn = smallBtn(EspActionRow, "R Refresh", 84)
RescanBtn = smallBtn(EspActionRow, "Scan Eggs", 86)
CopyEggBtn = smallBtn(EspActionRow, "Copy List", 84)

RefreshBtn.MouseButton1Click:Connect(function()
    if rebuildEggList then rebuildEggList() end
    setStatus("Egg list refreshed", C.purple)
end)
RescanBtn.MouseButton1Click:Connect(function()
    if espEnabled then
        for _, obj in ipairs(CollectionService:GetTagged("PetEggServer")) do task.spawn(addEsp, obj) end
        if rebuildEggList then rebuildEggList() end
        setStatus("ESP rescan complete", C.purple)
    else
        setStatus("Enable ESP before rescanning", C.yellow)
    end
end)
CopyEggBtn.MouseButton1Click:Connect(function()
    local lines = {}
    for id, object in pairs(activeEggs) do
        local eggName = tostring(object:GetAttribute("EggName") or "?")
        local petName = tostring((eggPets and eggPets[id]) or "?")
        local rarity = getRarityLabel(eggName, petName)
        table.insert(lines, string.format("%s | %s | %s | %dm", petName, eggName, rarity, getEggDistance(object)))
    end
    pcall(function() setclipboard(table.concat(lines, "\n")) end)
    pushLog("ESP", "Copied " .. #lines .. " egg rows", C.purple)
    setStatus("Copied egg list", C.purple)
end)


-- ============================================================
-- TAB CONNECTIONS
-- ============================================================
for _, t in ipairs(TABS) do
    tabBtns[t.id].btn.MouseButton1Click:Connect(function()
        setActiveTab(t.id)
    end)
end

setActiveTab("farm")
bootStatus("LowHub ready")

-- ============================================================
-- MINIMIZE / CLOSE / DRAG
-- ============================================================
MinIcon = Instance.new("TextButton")
MinIcon.Size = UDim2.new(0, 48, 0, 48)
MinIcon.Position = UDim2.new(0, 16, 0.5, -24)
MinIcon.BackgroundColor3 = C.green
MinIcon.BorderSizePixel = 0
MinIcon.Text = "LH"
MinIcon.TextColor3 = Color3.fromRGB(0, 0, 0)
MinIcon.TextSize = 13
MinIcon.Font = Enum.Font.GothamBold
MinIcon.Visible = false
MinIcon.Active = true
MinIcon.ZIndex = 2000
MinIcon.Parent = Gui
corner(MinIcon, 10)

FallbackBtn = nil
if FallbackGui then
    FallbackBtn = Instance.new("TextButton")
    FallbackBtn.Size = UDim2.new(0, 118, 0, 34)
    FallbackBtn.Position = UDim2.new(0, 12, 0, 12)
    FallbackBtn.BackgroundColor3 = C.greenDark
    FallbackBtn.BorderSizePixel = 0
    FallbackBtn.Text = "LowHub v4.1.30"
    FallbackBtn.TextColor3 = C.white
    FallbackBtn.TextSize = 11
    FallbackBtn.Font = Enum.Font.GothamBold
    FallbackBtn.ZIndex = 2001
    FallbackBtn.Parent = FallbackGui
    corner(FallbackBtn, 8)
    stroke(FallbackBtn, C.greenMid, 1, 0)
end

MinBtn.MouseButton1Click:Connect(function()
    Win.Visible = false
    MinIcon.Visible = true
end)
MinIcon.MouseButton1Click:Connect(function()
    MinIcon.Visible = false
    Win.Visible = true
end)
BootBtn.MouseButton1Click:Connect(function()
    Win.Visible = true
    MinIcon.Visible = false
end)
if FallbackBtn then
    FallbackBtn.MouseButton1Click:Connect(function()
        Win.Visible = true
        MinIcon.Visible = false
    end)
end
CloseBtn.MouseButton1Click:Connect(function()
    print = _origPrint
    warn  = _origWarn
    if espEnabled then disableEsp() end
    clearAllEspDrawings()
    if FallbackGui then FallbackGui:Destroy() end
    if BootGui then BootGui:Destroy() end
    Gui:Destroy()
end)

-- Drag
local dragging, dragStart, startPos = false, nil, nil
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging  = true
        dragStart = input.Position
        startPos  = Win.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
     or input.UserInputType == Enum.UserInputType.Touch
    ) then
        local d = input.Position - dragStart
        Win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)

-- ============================================================
-- INIT
-- ============================================================
pushLog("SYS", "LowHub v4.1.30 loaded - Grow a Garden", C.green)
pushLog("SYS", "ESP system ready - go to ESP tab to enable", C.purple)
setStatus("Ready", C.green)
print("[LowHub] v4.1.30 initialized")
