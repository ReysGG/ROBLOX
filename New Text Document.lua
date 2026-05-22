-- LOW HUB v3.0 — Grow a Garden
-- LocalScript | 1 file
-- Sections: TELEPORT | CONSOLE | BUILDER | COMING SOON

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")

local Player    = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local GUI_NAME = "LowHubV3"

-- cleanup
local old = PlayerGui:FindFirstChild(GUI_NAME)
if old then old:Destroy() end
pcall(function()
    local c = game:GetService("CoreGui"):FindFirstChild(GUI_NAME)
    if c then c:Destroy() end
end)

-- ============================================================
-- DESTINATIONS CONFIG
-- ============================================================
local DESTINATIONS = {
    {
        id       = "honey_seed",
        label    = "Honey Seed Shop",
        sub      = "Event Shop",
        icon     = "🍯",
        npcName  = "HoneySeedShop",
        pos      = nil, -- from NPC pivot
        useRemote = true,
        remoteArg = "Seed Shop",
        shopName  = "Honey Seed Shop",
        color     = Color3.fromRGB(255, 180, 30),
    },
    {
        id      = "seed_stands",
        label   = "Seed Stands",
        sub     = "Buy Seeds",
        icon    = "🌱",
        npcName = "Seed Stands",
        pos     = Vector3.new(19.1, 4.4, -27.0),
        color   = Color3.fromRGB(80, 200, 80),
    },
    {
        id      = "sell_stands",
        label   = "Sell Stands",
        sub     = "Sell Harvest",
        icon    = "💰",
        npcName = "Sell Stands",
        pos     = Vector3.new(40.4, 2.8, 0.4),
        color   = Color3.fromRGB(255, 210, 60),
    },
    {
        id      = "honey_hannah",
        label   = "Honey Hannah",
        sub     = "Special Shop",
        icon    = "🧑",
        npcName = "Honey Hannah",
        pos     = Vector3.new(41.9, 3.0, -27.1),
        color   = Color3.fromRGB(255, 140, 80),
    },
    {
        id      = "pet_stand",
        label   = "Pet Stand",
        sub     = "Pets & Eggs",
        icon    = "🐾",
        npcName = "Pet Stand",
        pos     = Vector3.new(-241.3, 5.0, 11.2),
        color   = Color3.fromRGB(160, 100, 255),
    },
    {
        id      = "gear_stands",
        label   = "Gear Stands",
        sub     = "Tools & Gear",
        icon    = "⚙️",
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
    -- remove existing
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

local function label(parent, text, size, col, font, zindex)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextSize = size or 11
    l.TextColor3 = col or C.text
    l.Font = font or Enum.Font.Gotham
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.ZIndex = zindex or 104
    l.Parent = parent
    return l
end

local function shortPos(v)
    return string.format("%.1f, %.1f, %.1f", v.X, v.Y, v.Z)
end

local function lerp(a, b, t)
    return a + (b - a) * t
end

local function lerpColor(a, b, t)
    return Color3.new(
        lerp(a.R, b.R, t),
        lerp(a.G, b.G, t),
        lerp(a.B, b.B, t)
    )
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
    if inst:IsA("Model")      then return inst:GetPivot() end
    if inst:IsA("BasePart")   then return inst.CFrame end
    local m = inst:FindFirstAncestorOfClass("Model")
    if m then return m:GetPivot() end
    local p = inst:FindFirstChildWhichIsA("BasePart", true)
    if p then return p.CFrame end
    return nil
end

local function getGroundedCFrame(targetPos, offsetZ)
    offsetZ = offsetZ or 3
    local back = Vector3.new(
        targetPos.X + math.cos(0) * offsetZ,
        targetPos.Y + 100,
        targetPos.Z + math.sin(0) * offsetZ
    )
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.IgnoreWater = true
    local excl = {}
    if Player.Character then table.insert(excl, Player.Character) end
    params.FilterDescendantsInstances = excl
    local result = workspace:Raycast(back, Vector3.new(0, -300, 0), params)
    local gY = result and (result.Position.Y + 0.5) or (targetPos.Y + 0.5)
    local gPos = Vector3.new(targetPos.X + offsetZ, gY, targetPos.Z)
    return CFrame.new(gPos, Vector3.new(targetPos.X, gY, targetPos.Z))
end

-- Teleport to position
local function teleportToPos(pos)
    local ch, _, root = getCharacter()
    if not ch or not root then return false, "Character not found" end
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
    local cf = getGroundedCFrame(pos, 3)
    pcall(function() ch:PivotTo(cf) end)
    task.wait(0.3)
    return true, shortPos(root.Position)
end

-- Teleport to NPC by name
local function teleportToNPC(npcName)
    local npc = getNPC(npcName)
    if not npc then return false, npcName .. " not found" end
    local cf = getInstanceCFrame(npc)
    if not cf then return false, "Could not get CFrame" end
    return teleportToPos(cf.Position)
end

-- Fire remote
local function fireRemote(path, arg)
    local parts = string.split(path, ".")
    local obj = ReplicatedStorage
    for _, part in ipairs(parts) do
        local found = obj:FindFirstChild(part)
        if not found then
            -- try WaitForChild with timeout
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

-- Open shop UI
local function openShopUI(shopName)
    local ok, ctrl = pcall(function()
        return require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("EventShopUIController"))
    end)
    if not ok then return false, tostring(ctrl) end
    local ok2, err2 = pcall(function() ctrl:Open(shopName) end)
    if not ok2 then return false, tostring(err2) end
    return true, "Opened"
end

-- Main teleport handler per destination
local function doTeleport(dest)
    if dest.useRemote then
        -- PivotTo near NPC first for proximity check
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
        -- open shop UI if applicable
        if dest.shopName then
            openShopUI(dest.shopName)
        end
        local _, _, root = getCharacter()
        return true, root and shortPos(root.Position) or "Done"
    else
        -- Direct PivotTo
        local targetPos = dest.pos
        -- Try to get live NPC position first
        local npc = getNPC(dest.npcName)
        if npc then
            local cf = getInstanceCFrame(npc)
            if cf then targetPos = cf.Position end
        end
        return teleportToPos(targetPos)
    end
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
    for _, cb in ipairs(logRenderCallbacks) do
        pcall(cb, entry)
    end
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
Gui.Parent = PlayerGui

-- Window
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

-- Subtle inner glow top
local TopGlow = Instance.new("Frame")
TopGlow.Size = UDim2.new(1, -4, 0, 2)
TopGlow.Position = UDim2.new(0, 2, 0, 1)
TopGlow.BackgroundColor3 = C.greenMid
TopGlow.BackgroundTransparency = 0.4
TopGlow.BorderSizePixel = 0
TopGlow.ZIndex = 101
TopGlow.Parent = Win
corner(TopGlow, 2)

-- ── HEADER ──────────────────────────────────────────────────
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 48)
Header.BackgroundColor3 = C.header
Header.BorderSizePixel = 0
Header.ZIndex = 101
Header.Active = true
Header.Parent = Win
corner(Header, 14)

-- cover bottom rounded corners of header
local HFill = Instance.new("Frame")
HFill.Size = UDim2.new(1, 0, 0, 14)
HFill.Position = UDim2.new(0, 0, 1, -14)
HFill.BackgroundColor3 = C.header
HFill.BorderSizePixel = 0
HFill.ZIndex = 101
HFill.Parent = Header

-- divider line
local HDivider = Instance.new("Frame")
HDivider.Size = UDim2.new(1, -20, 0, 1)
HDivider.Position = UDim2.new(0, 10, 1, -1)
HDivider.BackgroundColor3 = C.border
HDivider.BorderSizePixel = 0
HDivider.ZIndex = 102
HDivider.Parent = Header

-- Badge
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
VerLbl.Text = "v3.0"
VerLbl.TextColor3 = C.green
VerLbl.TextSize = 10
VerLbl.Font = Enum.Font.GothamBold
VerLbl.TextXAlignment = Enum.TextXAlignment.Left
VerLbl.ZIndex = 103
VerLbl.Parent = Header

-- Header action buttons
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
local CloseBtn = hBtn("✕", -38, C.red)

-- ── STATUS BAR ───────────────────────────────────────────────
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

-- ── BODY ─────────────────────────────────────────────────────
local Body = Instance.new("Frame")
Body.Size = UDim2.new(1, -16, 1, -96)
Body.Position = UDim2.new(0, 8, 0, 88)
Body.BackgroundTransparency = 1
Body.ZIndex = 101
Body.Parent = Win

-- Sidebar
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

-- Content
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -64, 1, 0)
Content.Position = UDim2.new(0, 64, 0, 0)
Content.BackgroundTransparency = 1
Content.ZIndex = 102
Content.Parent = Body

-- ── TABS ─────────────────────────────────────────────────────
local TABS = {
    { id = "teleport", icon = "⊹", label = "TP"  },
    { id = "console",  icon = "≡", label = "LOG" },
    { id = "builder",  icon = "◈", label = "BLD" },
    { id = "soon",     icon = "◌", label = "···" },
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

for _, t in ipairs(TABS) do
    makeTabBtn(t)
end

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
        if tid == id then
            data.btn.BackgroundColor3 = C.greenDark
            data.ico.TextColor3 = C.green
            data.lbl.TextColor3 = C.green
            stroke(data.btn, C.green, 1, 0.2)
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

-- ── SECTION LABEL ────────────────────────────────────────────
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

-- ── ACTION BUTTON ────────────────────────────────────────────
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

-- Destination cards grid
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

local destStatus = {} -- per-destination status

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

    -- Accent bar top
    local accentBar = Instance.new("Frame")
    accentBar.Size = UDim2.new(1, 0, 0, 3)
    accentBar.BackgroundColor3 = dest.color
    accentBar.BackgroundTransparency = 0.4
    accentBar.BorderSizePixel = 0
    accentBar.ZIndex = 106
    accentBar.Parent = card
    corner(accentBar, 2)

    -- Icon
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

    -- Title
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

    -- Sub
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

    -- Status indicator (top right)
    local statDot = Instance.new("Frame")
    statDot.Size = UDim2.new(0, 6, 0, 6)
    statDot.Position = UDim2.new(1, -12, 0, 8)
    statDot.BackgroundColor3 = C.textFaint
    statDot.BorderSizePixel = 0
    statDot.ZIndex = 107
    statDot.Parent = card
    corner(statDot, 3)

    destStatus[dest.id] = statDot

    -- Hover effect
    card.MouseEnter:Connect(function()
        TweenService:Create(card, TweenInfo.new(0.15), {
            BackgroundColor3 = C.cardHover
        }):Play()
        stroke(card, dest.color, 1, 0.5)
    end)
    card.MouseLeave:Connect(function()
        TweenService:Create(card, TweenInfo.new(0.15), {
            BackgroundColor3 = C.card
        }):Play()
        stroke(card, C.border, 1, 0)
    end)

    card.MouseButton1Click:Connect(function()
        setStatus("Teleporting to " .. dest.label .. "...", C.yellow)
        statDot.BackgroundColor3 = C.yellow
        task.spawn(function()
            local ok, msg = doTeleport(dest)
            if ok then
                setStatus("✓ " .. dest.label .. " — " .. msg, C.green)
                statDot.BackgroundColor3 = C.green
                pushLog("TP", dest.label .. " → " .. msg, C.green)
            else
                setStatus("✕ " .. msg, C.red)
                statDot.BackgroundColor3 = C.red
                pushLog("ERR", dest.label .. " → " .. msg, C.red)
            end
        end)
    end)
end

-- update grid height
task.defer(function()
    Grid.Size = UDim2.new(1, 0, 0, GridLayout.AbsoluteContentSize.Y)
end)

GridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Grid.Size = UDim2.new(1, 0, 0, GridLayout.AbsoluteContentSize.Y)
end)

-- Quick actions
sectionLbl(PTP, "QUICK ACTIONS")

local QRow = Instance.new("Frame")
QRow.Size = UDim2.new(1, 0, 0, 30)
QRow.BackgroundTransparency = 1
QRow.ZIndex = 104
QRow.Parent = PTP

local QLayout = Instance.new("UIListLayout")
QLayout.FillDirection = Enum.FillDirection.Horizontal
QLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
QLayout.SortOrder = Enum.SortOrder.LayoutOrder
QLayout.Padding = UDim.new(0, 6)
QLayout.Parent = QRow

local PosQBtn = actionBtn(QRow, "⊹ Position", C.surface, 30)
PosQBtn.Size = UDim2.new(0, 100, 1, 0)
PosQBtn.LayoutOrder = 1

local OpenSeedShopBtn = actionBtn(QRow, "🍯 Open UI", C.surface, 30)
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
        setStatus(ok and "✓ Shop opened" or "✕ " .. msg, ok and C.green or C.red)
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

-- Log area
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
        string.format("%02x%02x%02x", math.floor(entry.col.R*255), math.floor(entry.col.G*255), math.floor(entry.col.B*255)),
        entry.tag,
        entry.msg:gsub("<", "&lt;"):gsub(">", "&gt;")
    )
    row.TextXAlignment = Enum.TextXAlignment.Left
    row.TextTruncate = Enum.TextTruncate.AtEnd
    row.LayoutOrder = #logLines
    row.ZIndex = 106
    row.Parent = LogScroll

    -- auto scroll
    task.defer(function()
        LogScroll.CanvasSize = UDim2.new(0, 0, 0, LogLayout.AbsoluteContentSize.Y + 8)
        LogScroll.CanvasPosition = Vector2.new(0,
            math.max(0, LogScroll.CanvasSize.Y.Offset - LogScroll.AbsoluteSize.Y))
    end)
end

table.insert(logRenderCallbacks, renderLogLine)

-- Render existing logs (from before panel build)
for _, entry in ipairs(logLines) do
    renderLogLine(entry)
end

-- Console toolbar
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

local CopyBtn  = actionBtn(ConToolbar, "⎘ Copy All", C.surface, 28)
CopyBtn.Size = UDim2.new(0, 100, 1, 0)
CopyBtn.LayoutOrder = 1

local ClearLogBtn = actionBtn(ConToolbar, "✕ Clear", C.redDark, 28)
ClearLogBtn.Size = UDim2.new(0, 80, 1, 0)
ClearLogBtn.LayoutOrder = 2

-- Executor
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

local RunBtn = actionBtn(ExecToolbar, "▶ Run", C.greenDark, 28)
RunBtn.Size = UDim2.new(0, 80, 1, 0)
RunBtn.LayoutOrder = 1
stroke(RunBtn, C.greenMid, 1, 0.2)

local ClearExecBtn = actionBtn(ExecToolbar, "✕ Clear", C.redDark, 28)
ClearExecBtn.Size = UDim2.new(0, 80, 1, 0)
ClearExecBtn.LayoutOrder = 2

-- Console connections
CopyBtn.MouseButton1Click:Connect(function()
    local lines = {}
    for _, l in ipairs(logLines) do
        table.insert(lines, string.format("[%s] %s  %s", l.ts, l.tag, l.msg))
    end
    pcall(function()
        setclipboard(table.concat(lines, "\n"))
        pushLog("SYS", "Copied " .. #logLines .. " lines", C.blue)
        setStatus("Copied " .. #logLines .. " log lines", C.blue)
    end)
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
            pushLog("SYS", "Done ✓", C.green)
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
local _, ArgBox  = fieldGroup(PBL, "ARGUMENT (string — leave blank for none)", "Seed Shop", "Seed Shop")

local FireBuildBtn = actionBtn(PBL, "▶  Fire Remote", C.greenDark, 36)
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

-- Tips
local TipCard = Instance.new("Frame")
TipCard.Size = UDim2.new(1, 0, 0, 70)
TipCard.BackgroundColor3 = C.surface
TipCard.BorderSizePixel = 0
TipCard.ZIndex = 104
TipCard.Parent = PBL
corner(TipCard, 8)

local TipLbl = Instance.new("TextLabel")
TipLbl.Size = UDim2.new(1, 0, 1, 0)
TipLbl.BackgroundTransparency = 1
TipLbl.Text = "💡  Path dimulai dari ReplicatedStorage\n    Pisahkan subfolder dengan titik (.)\n    Contoh: GameEvents.TradeEvents.Open\n    Kosongkan arg jika tidak diperlukan"
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
        ResultLbl.Text = "⚠ Path cannot be empty"
        ResultLbl.TextColor3 = C.red
        return
    end
    ResultLbl.Text = "Firing..."
    ResultLbl.TextColor3 = C.yellow
    task.spawn(function()
        local ok, msg = fireRemote(path, arg)
        local display = (ok and "✓ " or "✕ ") .. msg
        ResultLbl.Text = display
        ResultLbl.TextColor3 = ok and C.green or C.red
        setStatus(display, ok and C.green or C.red)
        pushLog(ok and "BLD" or "ERR", path .. (arg ~= "" and (' "' .. arg .. '"') or ""), ok and C.green or C.red)
    end)
end)

-- ============================================================
-- PANEL: COMING SOON
-- ============================================================
local PSN = makePanel("soon")
local PSNLayout = Instance.new("UIListLayout")
PSNLayout.FillDirection = Enum.FillDirection.Vertical
PSNLayout.SortOrder = Enum.SortOrder.LayoutOrder
PSNLayout.Padding = UDim.new(0, 6)
PSNLayout.Parent = PSN
pad(PSN, 2, 4, 4, 8)

sectionLbl(PSN, "COMING SOON")

local SOON_ITEMS = {
    { icon = "🔁", title = "Auto Farm",        desc = "Loop teleport + sell automatically" },
    { icon = "📦", title = "Inventory",         desc = "View & manage player inventory"     },
    { icon = "🌐", title = "Server Hop",        desc = "Find servers with specific items"   },
    { icon = "📡", title = "Remote Spy Lite",   desc = "Monitor incoming RemoteEvent calls" },
    { icon = "🌧️", title = "Seed Rain Alert",  desc = "Notify on MythicalSeedRainEvent"    },
}

for _, item in ipairs(SOON_ITEMS) do
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 50)
    card.BackgroundColor3 = C.card
    card.BorderSizePixel = 0
    card.ZIndex = 104
    card.Parent = PSN
    corner(card, 8)
    stroke(card, C.border, 1, 0)

    local ico = Instance.new("TextLabel")
    ico.Size = UDim2.new(0, 32, 0, 32)
    ico.Position = UDim2.new(0, 10, 0.5, -16)
    ico.BackgroundColor3 = C.surface
    ico.BorderSizePixel = 0
    ico.Text = item.icon
    ico.TextSize = 16
    ico.ZIndex = 105
    ico.Parent = card
    corner(ico, 8)

    local titleL = Instance.new("TextLabel")
    titleL.Size = UDim2.new(1, -100, 0, 18)
    titleL.Position = UDim2.new(0, 52, 0, 8)
    titleL.BackgroundTransparency = 1
    titleL.Text = item.title
    titleL.TextColor3 = C.textMid
    titleL.TextSize = 11
    titleL.Font = Enum.Font.GothamBold
    titleL.TextXAlignment = Enum.TextXAlignment.Left
    titleL.ZIndex = 105
    titleL.Parent = card

    local descL = Instance.new("TextLabel")
    descL.Size = UDim2.new(1, -100, 0, 14)
    descL.Position = UDim2.new(0, 52, 0, 28)
    descL.BackgroundTransparency = 1
    descL.Text = item.desc
    descL.TextColor3 = C.textFaint
    descL.TextSize = 9
    descL.Font = Enum.Font.Gotham
    descL.TextXAlignment = Enum.TextXAlignment.Left
    descL.ZIndex = 105
    descL.Parent = card

    local badge = Instance.new("TextLabel")
    badge.Size = UDim2.new(0, 44, 0, 16)
    badge.Position = UDim2.new(1, -52, 0.5, -8)
    badge.BackgroundColor3 = C.greenDeep
    badge.BorderSizePixel = 0
    badge.Text = "SOON"
    badge.TextColor3 = C.green
    badge.TextSize = 8
    badge.Font = Enum.Font.GothamBold
    badge.ZIndex = 105
    badge.Parent = card
    corner(badge, 4)
    stroke(badge, C.border, 1, 0)
end

-- ============================================================
-- TAB CONNECTIONS
-- ============================================================
for _, t in ipairs(TABS) do
    tabBtns[t.id].btn.MouseButton1Click:Connect(function()
        setActiveTab(t.id)
    end)
end

setActiveTab("teleport")

-- ============================================================
-- MINIMIZE / CLOSE / DRAG
-- ============================================================
local MinIcon = Instance.new("TextButton")
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

MinBtn.MouseButton1Click:Connect(function()
    Win.Visible = false
    MinIcon.Visible = true
end)
MinIcon.MouseButton1Click:Connect(function()
    MinIcon.Visible = false
    Win.Visible = true
end)
CloseBtn.MouseButton1Click:Connect(function()
    print = _origPrint
    warn  = _origWarn
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
        Win.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + d.X,
            startPos.Y.Scale, startPos.Y.Offset + d.Y
        )
    end
end)

-- ============================================================
-- INIT
-- ============================================================
pushLog("SYS", "LowHub v3.0 loaded — Grow a Garden", C.green)
setStatus("Ready", C.green)
print("[LowHub] v3.0 initialized")
