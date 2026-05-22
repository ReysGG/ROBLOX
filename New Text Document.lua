-- LOW HUB v2.0
-- LocalScript — 1 file, sidebar navigation
-- Sections: TELEPORT | CONSOLE | BUILDER | COMING SOON

local Players          = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local HttpService      = game:GetService("HttpService")

local Player    = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local GUI_NAME  = "LowHubV2"
local NPC_FOLDER = "NPCS"
local NPC_NAME   = "HoneySeedShop"
local SHOP_NAME  = "Honey Seed Shop"

-- Cleanup existing
local old = PlayerGui:FindFirstChild(GUI_NAME)
if old then old:Destroy() end
pcall(function()
    local c = game:GetService("CoreGui"):FindFirstChild(GUI_NAME)
    if c then c:Destroy() end
end)

-- ============================================================
-- HELPERS
-- ============================================================

local function corner(obj, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = obj
end

local function stroke(obj, col, thick, trans)
    local s = Instance.new("UIStroke")
    s.Color = col or Color3.fromRGB(57, 255, 20)
    s.Thickness = thick or 1
    s.Transparency = trans or 0
    s.Parent = obj
end

local function pad(obj, l, r, t, b)
    local p = Instance.new("UIPadding")
    p.PaddingLeft   = UDim.new(0, l or 8)
    p.PaddingRight  = UDim.new(0, r or 8)
    p.PaddingTop    = UDim.new(0, t or 0)
    p.PaddingBottom = UDim.new(0, b or 0)
    p.Parent = obj
end

local function shortPos(v)
    return string.format("%.1f, %.1f, %.1f", v.X, v.Y, v.Z)
end

local function getCharacter()
    local ch = Player.Character or Player.CharacterAdded:Wait()
    local hum  = ch:FindFirstChildOfClass("Humanoid") or ch:WaitForChild("Humanoid", 5)
    local root = ch:FindFirstChild("HumanoidRootPart") or ch:WaitForChild("HumanoidRootPart", 5)
    return ch, hum, root
end

local function getHoneySeedNPC()
    local folder = workspace:FindFirstChild(NPC_FOLDER) or workspace:WaitForChild(NPC_FOLDER, 5)
    if not folder then return nil, "workspace.NPCS not found" end
    local npc = folder:FindFirstChild(NPC_NAME) or folder:WaitForChild(NPC_NAME, 5)
    if not npc then return nil, "workspace.NPCS.HoneySeedShop not found" end
    return npc, nil
end

local function getInstanceCFrame(inst)
    if inst:IsA("Model")      then return inst:GetPivot() end
    if inst:IsA("BasePart")   then return inst.CFrame end
    if inst:IsA("Attachment") then return inst.WorldCFrame end
    local m = inst:FindFirstAncestorOfClass("Model")
    if m then return m:GetPivot() end
    local p = inst:FindFirstChildWhichIsA("BasePart", true)
    if p then return p.CFrame end
    return nil
end

local function getGroundedCFrameNear(targetCFrame, dist)
    dist = dist or 2
    local back = (targetCFrame * CFrame.new(0, 0, dist)).Position
    local origin = Vector3.new(back.X, back.Y + 100, back.Z)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.IgnoreWater = true
    local excl = {}
    if Player.Character then table.insert(excl, Player.Character) end
    local npc = getHoneySeedNPC()
    if npc then table.insert(excl, npc) end
    params.FilterDescendantsInstances = excl
    local result = workspace:Raycast(origin, Vector3.new(0, -300, 0), params)
    local gPos = result and (result.Position + Vector3.new(0, 0.5, 0))
        or Vector3.new(back.X, 0.5, back.Z)
    return CFrame.new(gPos, Vector3.new(targetCFrame.Position.X, gPos.Y, targetCFrame.Position.Z))
end

-- ============================================================
-- CORE FUNCTIONS
-- ============================================================

local function fireRemote(remotePath, arg)
    -- remotePath format: "GameEvents.PlayerTeleportTriggered"
    local parts = string.split(remotePath, ".")
    local obj = ReplicatedStorage
    for _, part in ipairs(parts) do
        obj = obj:WaitForChild(part, 5)
        if not obj then return false, "Path not found: " .. part end
    end
    if not obj:IsA("RemoteEvent") then
        return false, "Not a RemoteEvent: " .. remotePath
    end
    if arg and arg ~= "" then
        obj:FireServer(arg)
    else
        obj:FireServer()
    end
    return true, "Fired: " .. remotePath .. (arg ~= "" and (' | arg: "' .. arg .. '"') or " | no arg")
end

local function teleportAndFire()
    local npc, err = getHoneySeedNPC()
    if not npc then return false, err end
    local npcCF = getInstanceCFrame(npc)
    if not npcCF then return false, "Could not get NPC CFrame" end
    local ch, _, root = getCharacter()
    if not ch or not root then return false, "Character not found" end

    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
    pcall(function() ch:PivotTo(getGroundedCFrameNear(npcCF, 2)) end)
    task.wait(0.6)

    local ok, msg = fireRemote("GameEvents.PlayerTeleportTriggered", "Seed Shop")
    if not ok then return false, msg end
    task.wait(1.5)
    return true, "Teleported. Pos: " .. shortPos(root.Position)
end

local function openShopUI()
    local ok, ctrl = pcall(function()
        return require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("EventShopUIController"))
    end)
    if not ok then return false, "Require failed: " .. tostring(ctrl) end
    local ok2, err2 = pcall(function() ctrl:Open(SHOP_NAME) end)
    if not ok2 then return false, "Open failed: " .. tostring(err2) end
    return true, "Opened: " .. SHOP_NAME
end

local function autoAll()
    local ok1, msg1 = teleportAndFire()
    if not ok1 then return false, msg1 end
    task.wait(0.5)
    local ok2, msg2 = openShopUI()
    if not ok2 then return true, msg1 .. " | UI failed: " .. msg2 end
    return true, "AUTO done. " .. msg2
end

-- ============================================================
-- GUI BUILD
-- ============================================================

-- Colors
local C = {
    bg        = Color3.fromRGB(12, 17, 12),
    sidebar   = Color3.fromRGB(16, 24, 16),
    panel     = Color3.fromRGB(18, 26, 18),
    card      = Color3.fromRGB(22, 32, 22),
    green     = Color3.fromRGB(57, 255, 20),
    greenDim  = Color3.fromRGB(30, 100, 15),
    greenDark = Color3.fromRGB(20, 60, 10),
    text      = Color3.fromRGB(200, 220, 200),
    textDim   = Color3.fromRGB(130, 160, 130),
    textFaint = Color3.fromRGB(70, 100, 70),
    red       = Color3.fromRGB(200, 50, 50),
    yellow    = Color3.fromRGB(255, 210, 60),
    blue      = Color3.fromRGB(60, 140, 255),
    white     = Color3.fromRGB(255, 255, 255),
    header    = Color3.fromRGB(20, 30, 20),
}

local Gui = Instance.new("ScreenGui")
Gui.Name = GUI_NAME
Gui.ResetOnSpawn = false
Gui.DisplayOrder = 999999
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = PlayerGui

-- Main window
local Win = Instance.new("Frame")
Win.Name = "Win"
Win.Size = UDim2.new(0, 520, 0, 440)
Win.Position = UDim2.new(0, 40, 0.5, -220)
Win.BackgroundColor3 = C.bg
Win.BorderSizePixel = 0
Win.Active = true
Win.ZIndex = 100
Win.Parent = Gui
corner(Win, 12)
stroke(Win, C.green, 1.5, 0.1)

-- Drop shadow illusion
local Shadow = Instance.new("Frame")
Shadow.Size = UDim2.new(1, 16, 1, 16)
Shadow.Position = UDim2.new(0, -8, 0, -8)
Shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Shadow.BackgroundTransparency = 0.6
Shadow.BorderSizePixel = 0
Shadow.ZIndex = 99
Shadow.Parent = Win
corner(Shadow, 16)

-- ── HEADER ──────────────────────────────────────────────────
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 44)
Header.BackgroundColor3 = C.header
Header.BorderSizePixel = 0
Header.ZIndex = 101
Header.Active = true
Header.Parent = Win
corner(Header, 12)

-- Cover bottom corners of header
local HCover = Instance.new("Frame")
HCover.Size = UDim2.new(1, 0, 0, 12)
HCover.Position = UDim2.new(0, 0, 1, -12)
HCover.BackgroundColor3 = C.header
HCover.BorderSizePixel = 0
HCover.ZIndex = 101
HCover.Parent = Header

local Badge = Instance.new("TextLabel")
Badge.Size = UDim2.new(0, 36, 0, 26)
Badge.Position = UDim2.new(0, 10, 0, 9)
Badge.BackgroundColor3 = C.green
Badge.BorderSizePixel = 0
Badge.Text = "LH"
Badge.TextColor3 = Color3.fromRGB(0, 0, 0)
Badge.TextSize = 12
Badge.Font = Enum.Font.GothamBold
Badge.ZIndex = 102
Badge.Parent = Header
corner(Badge, 6)

local TitleLbl = Instance.new("TextLabel")
TitleLbl.Size = UDim2.new(1, -160, 1, 0)
TitleLbl.Position = UDim2.new(0, 54, 0, 0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Text = "LOW HUB  •  v2.0"
TitleLbl.TextColor3 = C.green
TitleLbl.TextSize = 13
TitleLbl.Font = Enum.Font.GothamBold
TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
TitleLbl.ZIndex = 102
TitleLbl.Parent = Header

-- Header buttons
local function headerBtn(name, txt, xOffset, bg)
    local b = Instance.new("TextButton")
    b.Name = name
    b.Size = UDim2.new(0, 30, 0, 26)
    b.Position = UDim2.new(1, xOffset, 0, 9)
    b.BackgroundColor3 = bg
    b.BorderSizePixel = 0
    b.Text = txt
    b.TextColor3 = C.white
    b.TextSize = 13
    b.Font = Enum.Font.GothamBold
    b.ZIndex = 103
    b.Parent = Header
    corner(b, 6)
    return b
end

local MinBtn   = headerBtn("Min",   "-", -76, Color3.fromRGB(50, 120, 50))
local CloseBtn = headerBtn("Close", "✕", -40, C.red)

-- ── STATUS BAR ───────────────────────────────────────────────
local StatusBar = Instance.new("Frame")
StatusBar.Name = "StatusBar"
StatusBar.Size = UDim2.new(1, -12, 0, 30)
StatusBar.Position = UDim2.new(0, 6, 0, 48)
StatusBar.BackgroundColor3 = C.card
StatusBar.BorderSizePixel = 0
StatusBar.ZIndex = 101
StatusBar.Parent = Win
corner(StatusBar, 6)

local StatusDot = Instance.new("Frame")
StatusDot.Size = UDim2.new(0, 8, 0, 8)
StatusDot.Position = UDim2.new(0, 10, 0.5, -4)
StatusDot.BackgroundColor3 = C.green
StatusDot.BorderSizePixel = 0
StatusDot.ZIndex = 102
StatusDot.Parent = StatusBar
corner(StatusDot, 4)

local StatusLbl = Instance.new("TextLabel")
StatusLbl.Size = UDim2.new(1, -28, 1, 0)
StatusLbl.Position = UDim2.new(0, 26, 0, 0)
StatusLbl.BackgroundTransparency = 1
StatusLbl.Text = "Ready"
StatusLbl.TextColor3 = C.textDim
StatusLbl.TextSize = 11
StatusLbl.Font = Enum.Font.Gotham
StatusLbl.TextXAlignment = Enum.TextXAlignment.Left
StatusLbl.TextTruncate = Enum.TextTruncate.AtEnd
StatusLbl.ZIndex = 102
StatusLbl.Parent = StatusBar

local function setStatus(txt, col)
    StatusLbl.Text = txt
    StatusLbl.TextColor3 = col or C.textDim
    StatusDot.BackgroundColor3 = col or C.green
end

-- ── BODY (sidebar + content) ─────────────────────────────────
local Body = Instance.new("Frame")
Body.Name = "Body"
Body.Size = UDim2.new(1, -12, 1, -92)
Body.Position = UDim2.new(0, 6, 0, 84)
Body.BackgroundTransparency = 1
Body.ZIndex = 101
Body.Parent = Win

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 52, 1, 0)
Sidebar.BackgroundColor3 = C.sidebar
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 102
Sidebar.Parent = Body
corner(Sidebar, 8)

local SideLayout = Instance.new("UIListLayout")
SideLayout.FillDirection = Enum.FillDirection.Vertical
SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SideLayout.VerticalAlignment = Enum.VerticalAlignment.Top
SideLayout.Padding = UDim.new(0, 4)
SideLayout.Parent = Sidebar

local SidePad = Instance.new("UIPadding")
SidePad.PaddingTop = UDim.new(0, 8)
SidePad.Parent = Sidebar

-- Content area
local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -58, 1, 0)
Content.Position = UDim2.new(0, 58, 0, 0)
Content.BackgroundTransparency = 1
Content.ZIndex = 102
Content.Parent = Body

-- ── SIDEBAR TABS ─────────────────────────────────────────────
local TABS = {
    { id = "teleport",  icon = "🌿", label = "TP"  },
    { id = "console",   icon = "📟", label = "CON" },
    { id = "builder",   icon = "🔧", label = "BLD" },
    { id = "soon",      icon = "🔮", label = "···" },
}

local tabButtons = {}
local panels = {}
local activeTab = "teleport"

local function sideBtn(tabId, icon, label)
    local btn = Instance.new("TextButton")
    btn.Name = "Tab_" .. tabId
    btn.Size = UDim2.new(0, 44, 0, 44)
    btn.BackgroundColor3 = C.greenDark
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.ZIndex = 103
    btn.Parent = Sidebar
    corner(btn, 8)

    local ico = Instance.new("TextLabel")
    ico.Size = UDim2.new(1, 0, 0, 22)
    ico.Position = UDim2.new(0, 0, 0, 4)
    ico.BackgroundTransparency = 1
    ico.Text = icon
    ico.TextSize = 16
    ico.Font = Enum.Font.GothamBold
    ico.TextXAlignment = Enum.TextXAlignment.Center
    ico.ZIndex = 104
    ico.Parent = btn

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 14)
    lbl.Position = UDim2.new(0, 0, 0, 26)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = C.textFaint
    lbl.TextSize = 8
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Center
    lbl.ZIndex = 104
    lbl.Parent = btn

    tabButtons[tabId] = { btn = btn, lbl = lbl }
    return btn
end

for _, t in ipairs(TABS) do
    sideBtn(t.id, t.icon, t.label)
end

local function setActiveTab(id)
    activeTab = id
    for tid, data in pairs(tabButtons) do
        if tid == id then
            data.btn.BackgroundColor3 = C.greenDim
            data.lbl.TextColor3 = C.green
            stroke(data.btn, C.green, 1, 0.3)
        else
            data.btn.BackgroundColor3 = C.greenDark
            data.lbl.TextColor3 = C.textFaint
            -- remove stroke
            local s = data.btn:FindFirstChildOfClass("UIStroke")
            if s then s:Destroy() end
        end
    end
    for pid, panel in pairs(panels) do
        panel.Visible = (pid == id)
    end
end

-- ── PANEL FACTORY ────────────────────────────────────────────
local function makePanel(id)
    local p = Instance.new("Frame")
    p.Name = "Panel_" .. id
    p.Size = UDim2.new(1, 0, 1, 0)
    p.BackgroundTransparency = 1
    p.Visible = false
    p.ZIndex = 103
    p.Parent = Content
    panels[id] = p
    return p
end

-- ── BUTTON FACTORY ───────────────────────────────────────────
local function makeBtn(parent, name, text, y, h, bgCol)
    local b = Instance.new("TextButton")
    b.Name = name
    b.Size = UDim2.new(1, 0, 0, h or 34)
    b.Position = UDim2.new(0, 0, 0, y)
    b.BackgroundColor3 = bgCol or C.card
    b.BorderSizePixel = 0
    b.Text = text
    b.TextColor3 = C.white
    b.TextSize = 11
    b.Font = Enum.Font.GothamBold
    b.ZIndex = 104
    b.Parent = parent
    corner(b, 7)
    stroke(b, C.green, 1, 0.5)
    return b
end

-- ============================================================
-- PANEL: TELEPORT
-- ============================================================

local PTP = makePanel("teleport")

local function sectionLabel(parent, text, y)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 18)
    lbl.Position = UDim2.new(0, 0, 0, y)
    lbl.BackgroundTransparency = 1
    lbl.Text = "  " .. text
    lbl.TextColor3 = C.textFaint
    lbl.TextSize = 9
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 104
    lbl.Parent = parent
end

sectionLabel(PTP, "HONEY SEED SHOP", 4)

local AutoBtn = makeBtn(PTP, "Auto", "⚡  AUTO — Teleport + Fire + Open Shop", 24, 38, Color3.fromRGB(18, 70, 18))
stroke(AutoBtn, C.green, 1.5, 0)

sectionLabel(PTP, "INDIVIDUAL STEPS", 72)
local FireBtn  = makeBtn(PTP, "Fire",  "① Fire Server Remote",        90, 32, C.card)
local ShopBtn  = makeBtn(PTP, "Shop",  "② Open Honey Seed Shop UI",   128, 32, C.card)
local PosBtn   = makeBtn(PTP, "Pos",   "⊹ Print Current Position",    168, 28, C.greenDark)

-- NPC info card
local InfoCard = Instance.new("Frame")
InfoCard.Size = UDim2.new(1, 0, 0, 52)
InfoCard.Position = UDim2.new(0, 0, 0, 204)
InfoCard.BackgroundColor3 = C.card
InfoCard.BorderSizePixel = 0
InfoCard.ZIndex = 104
InfoCard.Parent = PTP
corner(InfoCard, 7)
pad(InfoCard, 10, 10, 6, 6)

local InfoLbl = Instance.new("TextLabel")
InfoLbl.Size = UDim2.new(1, 0, 1, 0)
InfoLbl.BackgroundTransparency = 1
InfoLbl.Text = "NPC: workspace.NPCS.HoneySeedShop\nRemote: GameEvents.PlayerTeleportTriggered"
InfoLbl.TextColor3 = C.textFaint
InfoLbl.TextSize = 9
InfoLbl.Font = Enum.Font.Gotham
InfoLbl.TextXAlignment = Enum.TextXAlignment.Left
InfoLbl.TextYAlignment = Enum.TextYAlignment.Center
InfoLbl.TextWrapped = true
InfoLbl.ZIndex = 105
InfoLbl.Parent = InfoCard

-- Teleport button connections
AutoBtn.MouseButton1Click:Connect(function()
    setStatus("AUTO running...", C.yellow)
    task.spawn(function()
        local ok, msg = autoAll()
        setStatus(msg, ok and C.green or C.red)
    end)
end)

FireBtn.MouseButton1Click:Connect(function()
    setStatus("PivotTo NPC → FireServer...", C.yellow)
    task.spawn(function()
        local ok, msg = teleportAndFire()
        setStatus(msg, ok and C.green or C.red)
    end)
end)

ShopBtn.MouseButton1Click:Connect(function()
    setStatus("Opening shop UI...", C.yellow)
    task.spawn(function()
        local ok, msg = openShopUI()
        setStatus(msg, ok and C.green or C.red)
    end)
end)

PosBtn.MouseButton1Click:Connect(function()
    local _, _, root = getCharacter()
    if root then
        local p = shortPos(root.Position)
        setStatus("Pos: " .. p, C.blue)
        print("[LowHub] Position:", p)
    else
        setStatus("HumanoidRootPart not found", C.red)
    end
end)

-- ============================================================
-- PANEL: CONSOLE
-- ============================================================

local PCS = makePanel("console")

-- Log storage
local logLines = {}
local MAX_LOGS = 200

local function addLog(tag, msg, col)
    local ts = os.date("%H:%M:%S")
    local line = { tag = tag, msg = tostring(msg), col = col, ts = ts }
    table.insert(logLines, line)
    if #logLines > MAX_LOGS then table.remove(logLines, 1) end
    return line
end

-- Console scroll frame
local ConScroll = Instance.new("ScrollingFrame")
ConScroll.Name = "ConScroll"
ConScroll.Size = UDim2.new(1, 0, 0, 188)
ConScroll.Position = UDim2.new(0, 0, 0, 0)
ConScroll.BackgroundColor3 = C.card
ConScroll.BorderSizePixel = 0
ConScroll.ScrollBarThickness = 4
ConScroll.ScrollBarImageColor3 = C.greenDim
ConScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
ConScroll.ZIndex = 104
ConScroll.Parent = PCS
corner(ConScroll, 7)

local ConLayout = Instance.new("UIListLayout")
ConLayout.FillDirection = Enum.FillDirection.Vertical
ConLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
ConLayout.SortOrder = Enum.SortOrder.LayoutOrder
ConLayout.Padding = UDim.new(0, 1)
ConLayout.Parent = ConScroll

local ConPad = Instance.new("UIPadding")
ConPad.PaddingLeft   = UDim.new(0, 6)
ConPad.PaddingRight  = UDim.new(0, 6)
ConPad.PaddingTop    = UDim.new(0, 4)
ConPad.PaddingBottom = UDim.new(0, 4)
ConPad.Parent = ConScroll

local function renderLog(line)
    local row = Instance.new("TextLabel")
    row.Size = UDim2.new(1, 0, 0, 16)
    row.BackgroundTransparency = 1
    row.Text = string.format("[%s] %s  %s", line.ts, line.tag, line.msg)
    row.TextColor3 = line.col or C.text
    row.TextSize = 9
    row.Font = Enum.Font.Code
    row.TextXAlignment = Enum.TextXAlignment.Left
    row.TextTruncate = Enum.TextTruncate.AtEnd
    row.ZIndex = 105
    row.LayoutOrder = #logLines
    row.Parent = ConScroll
    ConScroll.CanvasSize = UDim2.new(0, 0, 0, ConLayout.AbsoluteContentSize.Y + 8)
    ConScroll.CanvasPosition = Vector2.new(0, math.max(0, ConScroll.CanvasSize.Y.Offset - ConScroll.AbsoluteSize.Y))
end

local function pushLog(tag, msg, col)
    local line = addLog(tag, msg, col)
    renderLog(line)
end

-- Hook global print/warn
local _origPrint = print
local _origWarn  = warn

print = function(...)
    local args = {...}
    local parts = {}
    for _, v in ipairs(args) do table.insert(parts, tostring(v)) end
    local msg = table.concat(parts, "  ")
    _origPrint(...)
    pcall(function() pushLog("OUT", msg, C.text) end)
end

warn = function(...)
    local args = {...}
    local parts = {}
    for _, v in ipairs(args) do table.insert(parts, tostring(v)) end
    local msg = table.concat(parts, "  ")
    _origWarn(...)
    pcall(function() pushLog("WRN", msg, C.yellow) end)
end

-- Console toolbar
local ConToolbar = Instance.new("Frame")
ConToolbar.Size = UDim2.new(1, 0, 0, 26)
ConToolbar.Position = UDim2.new(0, 0, 0, 193)
ConToolbar.BackgroundTransparency = 1
ConToolbar.ZIndex = 104
ConToolbar.Parent = PCS

local CopyAllBtn = makeBtn(ConToolbar, "CopyAll", "⎘ Copy All", 0, 26, C.greenDark)
CopyAllBtn.Size = UDim2.new(0.48, 0, 1, 0)
CopyAllBtn.Position = UDim2.new(0, 0, 0, 0)

local ClearConBtn = makeBtn(ConToolbar, "ClearCon", "✕ Clear", 0, 26, Color3.fromRGB(60, 20, 20))
ClearConBtn.Size = UDim2.new(0.48, 0, 1, 0)
ClearConBtn.Position = UDim2.new(0.52, 0, 0, 0)

-- Executor area
local ExecLabel = Instance.new("TextLabel")
ExecLabel.Size = UDim2.new(1, 0, 0, 14)
ExecLabel.Position = UDim2.new(0, 0, 0, 226)
ExecLabel.BackgroundTransparency = 1
ExecLabel.Text = "  SCRIPT EXECUTOR"
ExecLabel.TextColor3 = C.textFaint
ExecLabel.TextSize = 9
ExecLabel.Font = Enum.Font.GothamBold
ExecLabel.TextXAlignment = Enum.TextXAlignment.Left
ExecLabel.ZIndex = 104
ExecLabel.Parent = PCS

local ExecBox = Instance.new("TextBox")
ExecBox.Name = "ExecBox"
ExecBox.Size = UDim2.new(1, 0, 0, 68)
ExecBox.Position = UDim2.new(0, 0, 0, 242)
ExecBox.BackgroundColor3 = C.card
ExecBox.BorderSizePixel = 0
ExecBox.Text = "-- paste script here\nprint(\"hello from LowHub\")"
ExecBox.TextColor3 = Color3.fromRGB(140, 220, 140)
ExecBox.TextSize = 10
ExecBox.Font = Enum.Font.Code
ExecBox.TextXAlignment = Enum.TextXAlignment.Left
ExecBox.TextYAlignment = Enum.TextYAlignment.Top
ExecBox.MultiLine = true
ExecBox.ClearTextOnFocus = false
ExecBox.ZIndex = 104
ExecBox.Parent = PCS
corner(ExecBox, 7)
stroke(ExecBox, C.greenDim, 1, 0.3)
pad(ExecBox, 8, 8, 6, 6)

local RunBtn = makeBtn(PCS, "Run", "▶  Run Script", 316, 30, Color3.fromRGB(18, 70, 18))
stroke(RunBtn, C.green, 1.5, 0)

local ClearExecBtn = makeBtn(PCS, "ClearExec", "✕ Clear Editor", 316, 30, Color3.fromRGB(50, 20, 20))
ClearExecBtn.Size = UDim2.new(0.36, 0, 0, 30)
ClearExecBtn.Position = UDim2.new(0.64, 0, 0, 316)
RunBtn.Size = UDim2.new(0.60, 0, 0, 30)
RunBtn.Position = UDim2.new(0, 0, 0, 316)

-- Console connections
CopyAllBtn.MouseButton1Click:Connect(function()
    local lines = {}
    for _, l in ipairs(logLines) do
        table.insert(lines, string.format("[%s] %s  %s", l.ts, l.tag, l.msg))
    end
    local full = table.concat(lines, "\n")
    pcall(function()
        setclipboard(full)
        pushLog("SYS", "Copied " .. #logLines .. " lines to clipboard", C.blue)
        setStatus("Copied " .. #logLines .. " log lines", C.blue)
    end)
end)

ClearConBtn.MouseButton1Click:Connect(function()
    logLines = {}
    for _, child in ipairs(ConScroll:GetChildren()) do
        if child:IsA("TextLabel") then child:Destroy() end
    end
    ConScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    pushLog("SYS", "Console cleared", C.textFaint)
end)

ClearExecBtn.MouseButton1Click:Connect(function()
    ExecBox.Text = ""
end)

RunBtn.MouseButton1Click:Connect(function()
    local code = ExecBox.Text
    if code == "" or code == "-- paste script here\nprint(\"hello from LowHub\")" then
        pushLog("ERR", "No script to run", C.red)
        return
    end
    pushLog("SYS", "Running script...", C.textFaint)
    setStatus("Running script...", C.yellow)
    task.spawn(function()
        local fn, compErr = loadstring(code)
        if not fn then
            pushLog("ERR", "Compile error: " .. tostring(compErr), C.red)
            setStatus("Script error", C.red)
            return
        end
        local ok, runErr = pcall(fn)
        if not ok then
            pushLog("ERR", "Runtime error: " .. tostring(runErr), C.red)
            setStatus("Script error", C.red)
        else
            pushLog("SYS", "Script finished OK", C.green)
            setStatus("Script finished", C.green)
        end
    end)
end)

-- ============================================================
-- PANEL: BUILDER
-- ============================================================

local PBL = makePanel("builder")

local BlderLabel = Instance.new("TextLabel")
BlderLabel.Size = UDim2.new(1, 0, 0, 14)
BlderLabel.Position = UDim2.new(0, 0, 0, 4)
BlderLabel.BackgroundTransparency = 1
BlderLabel.Text = "  REMOTE FIRE BUILDER"
BlderLabel.TextColor3 = C.textFaint
BlderLabel.TextSize = 9
BlderLabel.Font = Enum.Font.GothamBold
BlderLabel.TextXAlignment = Enum.TextXAlignment.Left
BlderLabel.ZIndex = 104
BlderLabel.Parent = PBL

local function inputBox(parent, placeholder, y, h)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, 0, 0, h or 30)
    box.Position = UDim2.new(0, 0, 0, y)
    box.BackgroundColor3 = C.card
    box.BorderSizePixel = 0
    box.PlaceholderText = placeholder
    box.PlaceholderColor3 = C.textFaint
    box.Text = ""
    box.TextColor3 = C.text
    box.TextSize = 10
    box.Font = Enum.Font.Code
    box.TextXAlignment = Enum.TextXAlignment.Left
    box.ClearTextOnFocus = false
    box.ZIndex = 104
    box.Parent = parent
    corner(box, 7)
    stroke(box, C.greenDim, 1, 0.4)
    pad(box, 8, 8, 0, 0)
    return box
end

local function fieldLabel(parent, txt, y)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, 14)
    l.Position = UDim2.new(0, 0, 0, y)
    l.BackgroundTransparency = 1
    l.Text = "  " .. txt
    l.TextColor3 = C.textDim
    l.TextSize = 9
    l.Font = Enum.Font.GothamBold
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.ZIndex = 104
    l.Parent = parent
end

fieldLabel(PBL, "REMOTE PATH (from ReplicatedStorage)", 24)
local PathBox = inputBox(PBL, "GameEvents.PlayerTeleportTriggered", 40, 30)
PathBox.Text = "GameEvents.PlayerTeleportTriggered"

fieldLabel(PBL, "ARGUMENT (string, leave blank for none)", 78)
local ArgBox = inputBox(PBL, "Seed Shop", 94, 30)
ArgBox.Text = "Seed Shop"

local FireBuilderBtn = makeBtn(PBL, "FireBuilder", "▶  Fire Remote", 134, 34, Color3.fromRGB(18, 70, 18))
stroke(FireBuilderBtn, C.green, 1.5, 0)

local BlderResult = Instance.new("TextLabel")
BlderResult.Size = UDim2.new(1, 0, 0, 40)
BlderResult.Position = UDim2.new(0, 0, 0, 176)
BlderResult.BackgroundColor3 = C.card
BlderResult.BorderSizePixel = 0
BlderResult.Text = "Result will appear here"
BlderResult.TextColor3 = C.textFaint
BlderResult.TextSize = 10
BlderResult.Font = Enum.Font.Code
BlderResult.TextXAlignment = Enum.TextXAlignment.Left
BlderResult.TextWrapped = true
BlderResult.ZIndex = 104
BlderResult.Parent = PBL
corner(BlderResult, 7)
pad(BlderResult, 8, 8, 6, 6)

-- Tip card
local TipCard = Instance.new("Frame")
TipCard.Size = UDim2.new(1, 0, 0, 80)
TipCard.Position = UDim2.new(0, 0, 0, 226)
TipCard.BackgroundColor3 = C.card
TipCard.BorderSizePixel = 0
TipCard.ZIndex = 104
TipCard.Parent = PBL
corner(TipCard, 7)
pad(TipCard, 10, 10, 8, 8)

local TipLbl = Instance.new("TextLabel")
TipLbl.Size = UDim2.new(1, 0, 1, 0)
TipLbl.BackgroundTransparency = 1
TipLbl.Text = "💡 Tips:\n• Path dimulai dari ReplicatedStorage\n• Pisahkan subfolder dengan titik (.)\n• Contoh: GameEvents.TradeEvents.Open"
TipLbl.TextColor3 = C.textFaint
TipLbl.TextSize = 9
TipLbl.Font = Enum.Font.Gotham
TipLbl.TextXAlignment = Enum.TextXAlignment.Left
TipLbl.TextYAlignment = Enum.TextYAlignment.Top
TipLbl.TextWrapped = true
TipLbl.ZIndex = 105
TipLbl.Parent = TipCard

FireBuilderBtn.MouseButton1Click:Connect(function()
    local path = PathBox.Text
    local arg  = ArgBox.Text
    if path == "" then
        BlderResult.Text = "⚠ Remote path cannot be empty"
        BlderResult.TextColor3 = C.red
        return
    end
    BlderResult.Text = "Firing..."
    BlderResult.TextColor3 = C.yellow
    task.spawn(function()
        local ok, msg = fireRemote(path, arg)
        BlderResult.Text = (ok and "✓ " or "✕ ") .. msg
        BlderResult.TextColor3 = ok and C.green or C.red
        setStatus(msg, ok and C.green or C.red)
        pushLog(ok and "BLD" or "ERR", msg, ok and C.green or C.red)
    end)
end)

-- ============================================================
-- PANEL: COMING SOON
-- ============================================================

local PSN = makePanel("soon")

local function comingSoonCard(parent, icon, title, desc, y)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 56)
    card.Position = UDim2.new(0, 0, 0, y)
    card.BackgroundColor3 = C.card
    card.BorderSizePixel = 0
    card.ZIndex = 104
    card.Parent = parent
    corner(card, 8)

    local ico = Instance.new("TextLabel")
    ico.Size = UDim2.new(0, 36, 1, 0)
    ico.Position = UDim2.new(0, 8, 0, 0)
    ico.BackgroundTransparency = 1
    ico.Text = icon
    ico.TextSize = 20
    ico.Font = Enum.Font.GothamBold
    ico.TextXAlignment = Enum.TextXAlignment.Center
    ico.ZIndex = 105
    ico.Parent = card

    local titleL = Instance.new("TextLabel")
    titleL.Size = UDim2.new(1, -60, 0, 22)
    titleL.Position = UDim2.new(0, 50, 0, 8)
    titleL.BackgroundTransparency = 1
    titleL.Text = title
    titleL.TextColor3 = C.textDim
    titleL.TextSize = 11
    titleL.Font = Enum.Font.GothamBold
    titleL.TextXAlignment = Enum.TextXAlignment.Left
    titleL.ZIndex = 105
    titleL.Parent = card

    local descL = Instance.new("TextLabel")
    descL.Size = UDim2.new(1, -60, 0, 18)
    descL.Position = UDim2.new(0, 50, 0, 30)
    descL.BackgroundTransparency = 1
    descL.Text = desc
    descL.TextColor3 = C.textFaint
    descL.TextSize = 9
    descL.Font = Enum.Font.Gotham
    descL.TextXAlignment = Enum.TextXAlignment.Left
    descL.ZIndex = 105
    descL.Parent = card

    local badge = Instance.new("TextLabel")
    badge.Size = UDim2.new(0, 60, 0, 16)
    badge.Position = UDim2.new(1, -68, 0, 20)
    badge.BackgroundColor3 = C.greenDark
    badge.BorderSizePixel = 0
    badge.Text = "SOON"
    badge.TextColor3 = C.green
    badge.TextSize = 8
    badge.Font = Enum.Font.GothamBold
    badge.TextXAlignment = Enum.TextXAlignment.Center
    badge.ZIndex = 105
    badge.Parent = card
    corner(badge, 4)
end

local SoonTitle = Instance.new("TextLabel")
SoonTitle.Size = UDim2.new(1, 0, 0, 20)
SoonTitle.Position = UDim2.new(0, 0, 0, 4)
SoonTitle.BackgroundTransparency = 1
SoonTitle.Text = "  COMING SOON"
SoonTitle.TextColor3 = C.textFaint
SoonTitle.TextSize = 9
SoonTitle.Font = Enum.Font.GothamBold
SoonTitle.TextXAlignment = Enum.TextXAlignment.Left
SoonTitle.ZIndex = 104
SoonTitle.Parent = PSN

comingSoonCard(PSN, "🔁", "Auto Farm",         "Loop teleport + buy seeds automatically",       30)
comingSoonCard(PSN, "📦", "Inventory Viewer",  "View & manage player inventory",                 94)
comingSoonCard(PSN, "🌐", "Server Hop",        "Hop to servers with specific conditions",       158)
comingSoonCard(PSN, "📡", "Remote Spy Lite",   "Monitor incoming RemoteEvent calls",            222)

-- ============================================================
-- TAB CLICK CONNECTIONS
-- ============================================================

for _, t in ipairs(TABS) do
    tabButtons[t.id].btn.MouseButton1Click:Connect(function()
        setActiveTab(t.id)
    end)
end

setActiveTab("teleport")

-- ============================================================
-- MINIMIZE / CLOSE / DRAG
-- ============================================================

local Icon = Instance.new("TextButton")
Icon.Name = "MinIcon"
Icon.Size = UDim2.new(0, 52, 0, 52)
Icon.Position = UDim2.new(0, 20, 0.5, -26)
Icon.BackgroundColor3 = C.green
Icon.BorderSizePixel = 0
Icon.Text = "LH"
Icon.TextColor3 = Color3.fromRGB(0, 0, 0)
Icon.TextSize = 14
Icon.Font = Enum.Font.GothamBold
Icon.Visible = false
Icon.Active = true
Icon.ZIndex = 2000
Icon.Parent = Gui
corner(Icon, 10)

MinBtn.MouseButton1Click:Connect(function()
    Win.Visible = false
    Icon.Visible = true
end)

Icon.MouseButton1Click:Connect(function()
    Icon.Visible = false
    Win.Visible = true
end)

CloseBtn.MouseButton1Click:Connect(function()
    -- restore print/warn
    print = _origPrint
    warn  = _origWarn
    Gui:Destroy()
end)

-- Drag
local dragging, dragStart, startPos = false, nil, nil

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Win.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
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

local npc, npcErr = getHoneySeedNPC()
if npc then
    setStatus("Ready — " .. npc:GetFullName(), C.green)
    pushLog("SYS", "NPC found: " .. npc:GetFullName(), C.green)
else
    setStatus(npcErr, C.red)
    pushLog("ERR", npcErr, C.red)
end

pushLog("SYS", "LowHub v2.0 loaded", C.green)
print("[LowHub] v2.0 initialized")
