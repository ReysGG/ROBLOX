-- ╔═══════════════════════════════════════════════════════════╗
-- ║                      LOW HUB                              ║
-- ║           v2.4 • AUTO-REFRESH PET DETECTION               ║
-- ║         Tries multiple methods every 5 seconds!           ║
-- ╚═══════════════════════════════════════════════════════════╝

-- ═══════════════════════════════════════════════════════════
--           PET NAME CAPTURE & REFRESH SYSTEM
-- ═══════════════════════════════════════════════════════════

local PET_NAMES = {}
local REFRESH_INTERVAL = 5 -- seconds
local lastRefresh = 0

print("════════════════════════════════════════════════════════")
print("🎣 LOW HUB v2.4 - Auto-Refresh Pet Detection")
print("")

-- Method 1: Hook RemoteEvent (for NEW ready eggs)
local hookSuccess = pcall(function()
    local RemoteEvent = game:GetService("ReplicatedStorage").GameEvents.EggReadyToHatch_RE
    
    RemoteEvent.OnClientEvent:Connect(function(petData, eggUUID)
        if eggUUID and petData then
            PET_NAMES[eggUUID] = petData
            
            local displayName = type(petData) == "string" and petData or 
                               (type(petData) == "table" and (petData.Name or petData.PetName or tostring(petData))) or 
                               tostring(petData)
            
            print("✅ Captured: " .. displayName)
        end
    end)
end)

if hookSuccess then
    print("✅ RemoteEvent hook active!")
else
    print("⚠️ RemoteEvent hook failed")
end

-- Method 2: Try to access module data (multiple approaches)
local function TryAccessModuleData()
    local foundCount = 0
    
    -- Approach 1: Try to require and access module
    pcall(function()
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local PetEggRenderer = require(ReplicatedStorage.Modules.PetServices.PetEggRenderer)
        
        -- Try to get shared state
        if type(PetEggRenderer) == "table" then
            for key, value in pairs(PetEggRenderer) do
                if type(value) == "table" then
                    -- Check if this looks like pet data
                    for k, v in pairs(value) do
                        if type(k) == "string" and k:match("^{[%x%-]+}$") then
                            if not PET_NAMES[k] then
                                PET_NAMES[k] = v
                                foundCount = foundCount + 1
                            end
                        end
                    end
                end
            end
        end
    end)
    
    -- Approach 2: Try debug functions (might work on some executors)
    if foundCount == 0 then
        pcall(function()
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local moduleScript = ReplicatedStorage.Modules.PetServices.PetEggRenderer
            
            if debug and debug.getupvalue then
                local module = require(moduleScript)
                
                -- Try to scan through all functions
                for name, func in pairs(module) do
                    if type(func) == "function" then
                        for i = 1, 30 do
                            local ok, upname, upvalue = pcall(debug.getupvalue, func, i)
                            if ok and type(upvalue) == "table" then
                                -- Check if this is the pet names table
                                for k, v in pairs(upvalue) do
                                    if type(k) == "string" and k:match("^{[%x%-]+}$") then
                                        if not PET_NAMES[k] then
                                            PET_NAMES[k] = v
                                            foundCount = foundCount + 1
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
    
    -- Approach 3: Check workspace for any pet data
    pcall(function()
        local farm = workspace:FindFirstChild("Farm")
        if farm then
            for _, plot in pairs(farm:GetChildren()) do
                local important = plot:FindFirstChild("Important")
                if important then
                    local objects = important:FindFirstChild("Objects_Physical")
                    if objects then
                        for _, egg in pairs(objects:GetChildren()) do
                            if egg.Name == "PetEgg" and egg:GetAttribute("READY") then
                                local uuid = egg:GetAttribute("OBJECT_UUID")
                                if uuid and not PET_NAMES[uuid] then
                                    -- Try to find pet name in children
                                    for _, child in pairs(egg:GetDescendants()) do
                                        if child:IsA("StringValue") and child.Name:lower():find("pet") then
                                            PET_NAMES[uuid] = child.Value
                                            foundCount = foundCount + 1
                                            break
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
    
    return foundCount
end

-- Method 3: Monitor game events for pet data
pcall(function()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    
    -- Monitor all RemoteEvents for pet data
    for _, event in pairs(ReplicatedStorage:GetDescendants()) do
        if event:IsA("RemoteEvent") then
            pcall(function()
                event.OnClientEvent:Connect(function(...)
                    local args = {...}
                    -- Check if any argument looks like pet data
                    for i, arg in ipairs(args) do
                        if type(arg) == "string" and args[i+1] and type(args[i+1]) == "string" and args[i+1]:match("^{[%x%-]+}$") then
                            -- Possible pet name + UUID pair
                            PET_NAMES[args[i+1]] = arg
                        elseif type(arg) == "string" and arg:match("^{[%x%-]+}$") and args[i-1] and type(args[i-1]) == "string" then
                            -- Possible UUID + pet name pair (reversed)
                            PET_NAMES[arg] = args[i-1]
                        end
                    end
                end)
            end)
        end
    end
end)

print("✅ Multi-method detection active!")
print("🔄 Auto-refresh every " .. REFRESH_INTERVAL .. " seconds")
print("════════════════════════════════════════════════════════")
print("")

-- ═══════════════════════════════════════════════════════════
--                    SERVICES & SETUP
-- ═══════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

if PlayerGui:FindFirstChild("LowHub") then
    PlayerGui:FindFirstChild("LowHub"):Destroy()
end

wait(0.3)

local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

_G.LowHubSettings = _G.LowHubSettings or {
    Speed = 16,
    WalkspeedEnabled = false,
    NoClip = false,
    InfJump = false,
    EggESP = false
}

local Settings = _G.LowHubSettings

-- ═══════════════════════════════════════════════════════════
--                         COLORS
-- ═══════════════════════════════════════════════════════════

local C = {
    Glass = Color3.fromRGB(15, 20, 15),
    GlassLight = Color3.fromRGB(20, 30, 20),
    Neon = Color3.fromRGB(57, 255, 20),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(156, 163, 175),
    Ready = Color3.fromRGB(255, 215, 0),
    Orange = Color3.fromRGB(255, 165, 0)
}

-- ═══════════════════════════════════════════════════════════
--                      HELPER FUNCTIONS
-- ═══════════════════════════════════════════════════════════

local function Tween(obj, props, time)
    TweenService:Create(obj, TweenInfo.new(time or 0.3, Enum.EasingStyle.Quad), props):Play()
end

local function Round(obj, r)
    Instance.new("UICorner", obj).CornerRadius = UDim.new(0, r)
end

local function Glass(obj, t)
    obj.BackgroundTransparency = t or 0.2
    local s = Instance.new("UIStroke", obj)
    s.Color = Color3.fromRGB(255, 255, 255)
    s.Thickness = 1
    s.Transparency = 0.8
end

local function GetPetName(egg)
    local uuid = egg:GetAttribute("OBJECT_UUID")
    if not uuid then return nil end
    
    local petData = PET_NAMES[uuid]
    if not petData then return nil end
    
    if type(petData) == "string" then
        return petData
    elseif type(petData) == "table" then
        return petData.Name or petData.PetName or petData.Pet or tostring(petData)
    end
    
    return tostring(petData)
end

-- ═══════════════════════════════════════════════════════════
--                      CREATE GUI
-- ═══════════════════════════════════════════════════════════

local GUI = Instance.new("ScreenGui")
GUI.Name = "LowHub"
GUI.ResetOnSpawn = false
GUI.DisplayOrder = 999
GUI.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 560, 0, 380)
Main.Position = UDim2.new(0.5, -280, 0.5, -190)
Main.BackgroundColor3 = C.Glass
Main.BorderSizePixel = 0
Main.ZIndex = 100
Main.Parent = GUI
Round(Main, 16)
Glass(Main, 0.15)

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = C.GlassLight
Header.BorderSizePixel = 0
Header.ZIndex = 102
Header.Parent = Main
Round(Header, 16)
Glass(Header, 0.3)

local Cover = Instance.new("Frame")
Cover.Size = UDim2.new(1, 0, 0, 16)
Cover.Position = UDim2.new(0, 0, 1, -16)
Cover.BackgroundColor3 = C.GlassLight
Cover.BackgroundTransparency = 0.3
Cover.BorderSizePixel = 0
Cover.ZIndex = 102
Cover.Parent = Header

local Logo = Instance.new("Frame")
Logo.Size = UDim2.new(0, 36, 0, 36)
Logo.Position = UDim2.new(0, 12, 0.5, -18)
Logo.BackgroundColor3 = C.Neon
Logo.BorderSizePixel = 0
Logo.ZIndex = 103
Logo.Parent = Header
Round(Logo, 10)

local LogoText = Instance.new("TextLabel")
LogoText.Size = UDim2.new(1, 0, 1, 0)
LogoText.BackgroundTransparency = 1
LogoText.Text = "🔄"
LogoText.TextSize = 20
LogoText.TextColor3 = Color3.fromRGB(0, 0, 0)
LogoText.Font = Enum.Font.GothamBold
LogoText.ZIndex = 104
LogoText.Parent = Logo

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 200, 1, 0)
Title.Position = UDim2.new(0, 55, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Low Hub"
Title.TextColor3 = C.Neon
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.ZIndex = 103
Title.Parent = Header

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(0, 200, 0, 16)
Subtitle.Position = UDim2.new(0, 55, 1, -20)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "v2.4 🔄 Auto-Refresh"
Subtitle.TextColor3 = C.TextDim
Subtitle.TextSize = 9
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Font = Enum.Font.Gotham
Subtitle.ZIndex = 103
Subtitle.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -38, 0.5, -16)
CloseBtn.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
CloseBtn.BackgroundTransparency = 0.3
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = C.Text
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.ZIndex = 103
CloseBtn.Parent = Header
Round(CloseBtn, 8)
Glass(CloseBtn, 0.3)

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 32, 0, 32)
MinBtn.Position = UDim2.new(1, -75, 0.5, -16)
MinBtn.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
MinBtn.BackgroundTransparency = 0.3
MinBtn.BorderSizePixel = 0
MinBtn.Text = "─"
MinBtn.TextColor3 = C.Text
MinBtn.TextSize = 16
MinBtn.Font = Enum.Font.GothamBold
MinBtn.ZIndex = 103
MinBtn.Parent = Header
Round(MinBtn, 8)
Glass(MinBtn, 0.3)

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -20, 1, -60)
Content.Position = UDim2.new(0, 10, 0, 55)
Content.BackgroundTransparency = 1
Content.ZIndex = 102
Content.Parent = Main

local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Size = UDim2.new(0, 140, 1, 0)
Sidebar.BackgroundColor3 = C.GlassLight
Sidebar.BackgroundTransparency = 0.4
Sidebar.BorderSizePixel = 0
Sidebar.ScrollBarThickness = 0
Sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
Sidebar.ZIndex = 103
Sidebar.Parent = Content
Round(Sidebar, 12)
Glass(Sidebar, 0.4)

local SidebarPad = Instance.new("UIPadding", Sidebar)
SidebarPad.PaddingTop = UDim.new(0, 8)
SidebarPad.PaddingBottom = UDim.new(0, 8)
SidebarPad.PaddingLeft = UDim.new(0, 6)
SidebarPad.PaddingRight = UDim.new(0, 6)

local SidebarLayout = Instance.new("UIListLayout", Sidebar)
SidebarLayout.Padding = UDim.new(0, 5)

SidebarLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Sidebar.CanvasSize = UDim2.new(0, 0, 0, SidebarLayout.AbsoluteContentSize.Y + 16)
end)

local Panel = Instance.new("Frame")
Panel.Size = UDim2.new(1, -150, 1, 0)
Panel.Position = UDim2.new(0, 145, 0, 0)
Panel.BackgroundColor3 = C.GlassLight
Panel.BackgroundTransparency = 0.5
Panel.BorderSizePixel = 0
Panel.ZIndex = 103
Panel.Parent = Content
Round(Panel, 12)
Glass(Panel, 0.5)

local PanelPad = Instance.new("UIPadding", Panel)
PanelPad.PaddingTop = UDim.new(0, 12)
PanelPad.PaddingBottom = UDim.new(0, 12)
PanelPad.PaddingLeft = UDim.new(0, 12)
PanelPad.PaddingRight = UDim.new(0, 12)

local PanelTitle = Instance.new("TextLabel")
PanelTitle.Size = UDim2.new(1, 0, 0, 28)
PanelTitle.BackgroundTransparency = 1
PanelTitle.Text = "Home"
PanelTitle.TextColor3 = C.Text
PanelTitle.TextSize = 18
PanelTitle.TextXAlignment = Enum.TextXAlignment.Left
PanelTitle.Font = Enum.Font.GothamBold
PanelTitle.ZIndex = 104
PanelTitle.Parent = Panel

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, 0, 1, -35)
Scroll.Position = UDim2.new(0, 0, 0, 35)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 3
Scroll.ScrollBarImageColor3 = C.Neon
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.ZIndex = 104
Scroll.Parent = Panel

local ScrollLayout = Instance.new("UIListLayout", Scroll)
ScrollLayout.Padding = UDim.new(0, 8)

ScrollLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Scroll.CanvasSize = UDim2.new(0, 0, 0, ScrollLayout.AbsoluteContentSize.Y + 8)
end)

local Icon = Instance.new("TextButton")
Icon.Size = UDim2.new(0, 50, 0, 50)
Icon.Position = UDim2.new(1, -60, 0, 10)
Icon.BackgroundColor3 = C.Neon
Icon.BorderSizePixel = 0
Icon.Text = "🔄"
Icon.TextSize = 26
Icon.TextColor3 = Color3.fromRGB(0, 0, 0)
Icon.Font = Enum.Font.GothamBold
Icon.ZIndex = 1000
Icon.Visible = false
Icon.Parent = GUI
Round(Icon, 25)

-- ═══════════════════════════════════════════════════════════
--                      TAB SYSTEM
-- ═══════════════════════════════════════════════════════════

local ActiveTab = nil

local function CreateTab(name, icon, order)
    local Tab = Instance.new("TextButton")
    Tab.Size = UDim2.new(1, 0, 0, 38)
    Tab.BackgroundColor3 = C.GlassLight
    Tab.BackgroundTransparency = 0.7
    Tab.BorderSizePixel = 0
    Tab.Text = ""
    Tab.AutoButtonColor = false
    Tab.LayoutOrder = order
    Tab.ZIndex = 104
    Tab.Parent = Sidebar
    Round(Tab, 8)
    Glass(Tab, 0.7)
    
    local TabIcon = Instance.new("TextLabel", Tab)
    TabIcon.Size = UDim2.new(0, 20, 0, 20)
    TabIcon.Position = UDim2.new(0, 8, 0.5, -10)
    TabIcon.BackgroundTransparency = 1
    TabIcon.Text = icon
    TabIcon.TextSize = 14
    TabIcon.TextColor3 = C.TextDim
    TabIcon.Font = Enum.Font.GothamBold
    TabIcon.ZIndex = 105
    
    local TabLabel = Instance.new("TextLabel", Tab)
    TabLabel.Size = UDim2.new(1, -35, 1, 0)
    TabLabel.Position = UDim2.new(0, 32, 0, 0)
    TabLabel.BackgroundTransparency = 1
    TabLabel.Text = name
    TabLabel.TextSize = 11
    TabLabel.TextColor3 = C.TextDim
    TabLabel.TextXAlignment = Enum.TextXAlignment.Left
    TabLabel.Font = Enum.Font.Gotham
    TabLabel.ZIndex = 105
    
    local Indicator = Instance.new("Frame", Tab)
    Indicator.Size = UDim2.new(0, 2, 0, 0)
    Indicator.Position = UDim2.new(0, 0, 0.5, 0)
    Indicator.AnchorPoint = Vector2.new(0, 0.5)
    Indicator.BackgroundColor3 = C.Neon
    Indicator.BorderSizePixel = 0
    Indicator.ZIndex = 106
    Round(Indicator, 1)
    
    Tab.MouseButton1Click:Connect(function()
        if ActiveTab == name then return end
        
        for _, tab in pairs(Sidebar:GetChildren()) do
            if tab:IsA("TextButton") then
                Tween(tab, {BackgroundTransparency = 0.7})
                local ind = tab:FindFirstChild("Frame")
                if ind then Tween(ind, {Size = UDim2.new(0, 2, 0, 0)}) end
                for _, lbl in pairs(tab:GetChildren()) do
                    if lbl:IsA("TextLabel") then lbl.TextColor3 = C.TextDim end
                end
            end
        end
        
        Tween(Tab, {BackgroundTransparency = 0.3})
        Tween(Indicator, {Size = UDim2.new(0, 2, 0, 24)})
        TabIcon.TextColor3 = C.Neon
        TabLabel.TextColor3 = C.Text
        TabLabel.Font = Enum.Font.GothamBold
        PanelTitle.Text = name
        ActiveTab = name
        
        for _, item in pairs(Scroll:GetChildren()) do
            if item:IsA("Frame") or item:IsA("TextLabel") then item:Destroy() end
        end
        
        if name == "Player" then LoadPlayerTab()
        elseif name == "Home" then LoadHomeTab()
        elseif name == "Egg" then LoadEggTab() end
    end)
    
    Tab.MouseEnter:Connect(function()
        if ActiveTab ~= name then Tween(Tab, {BackgroundTransparency = 0.5}) end
    end)
    
    Tab.MouseLeave:Connect(function()
        if ActiveTab ~= name then Tween(Tab, {BackgroundTransparency = 0.7}) end
    end)
end

-- ═══════════════════════════════════════════════════════════
--                      COMPONENTS
-- ═══════════════════════════════════════════════════════════

local function CreateToggle(title, setting, callback)
    local Opt = Instance.new("Frame")
    Opt.Size = UDim2.new(1, 0, 0, 40)
    Opt.BackgroundColor3 = C.Glass
    Opt.BackgroundTransparency = 0.3
    Opt.BorderSizePixel = 0
    Opt.ZIndex = 105
    Opt.Parent = Scroll
    Round(Opt, 8)
    Glass(Opt, 0.3)
    
    local TitleLbl = Instance.new("TextLabel", Opt)
    TitleLbl.Size = UDim2.new(1, -50, 1, 0)
    TitleLbl.Position = UDim2.new(0, 10, 0, 0)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Text = title
    TitleLbl.TextSize = 11
    TitleLbl.TextColor3 = C.Text
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    TitleLbl.Font = Enum.Font.GothamMedium
    TitleLbl.ZIndex = 106
    
    local ToggleBG = Instance.new("Frame", Opt)
    ToggleBG.Size = UDim2.new(0, 38, 0, 20)
    ToggleBG.Position = UDim2.new(1, -45, 0.5, -10)
    ToggleBG.BackgroundColor3 = Settings[setting] and C.Neon or Color3.fromRGB(60, 60, 70)
    ToggleBG.BackgroundTransparency = 0.2
    ToggleBG.BorderSizePixel = 0
    ToggleBG.ZIndex = 106
    Round(ToggleBG, 10)
    Glass(ToggleBG, 0.2)
    
    local Circle = Instance.new("Frame", ToggleBG)
    Circle.Size = UDim2.new(0, 14, 0, 14)
    Circle.Position = Settings[setting] and UDim2.new(0, 21, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
    Circle.BackgroundColor3 = C.Text
    Circle.BorderSizePixel = 0
    Circle.ZIndex = 107
    Round(Circle, 7)
    
    local Btn = Instance.new("TextButton", ToggleBG)
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundTransparency = 1
    Btn.Text = ""
    Btn.ZIndex = 108
    
    Btn.MouseButton1Click:Connect(function()
        Settings[setting] = not Settings[setting]
        Tween(ToggleBG, {BackgroundColor3 = Settings[setting] and C.Neon or Color3.fromRGB(60, 60, 70)})
        Tween(Circle, {Position = Settings[setting] and UDim2.new(0, 21, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)})
        if callback then callback(Settings[setting]) end
    end)
end

local function CreateInput(title, setting, callback)
    local Opt = Instance.new("Frame")
    Opt.Size = UDim2.new(1, 0, 0, 40)
    Opt.BackgroundColor3 = C.Glass
    Opt.BackgroundTransparency = 0.3
    Opt.BorderSizePixel = 0
    Opt.ZIndex = 105
    Opt.Parent = Scroll
    Round(Opt, 8)
    Glass(Opt, 0.3)
    
    local TitleLbl = Instance.new("TextLabel", Opt)
    TitleLbl.Size = UDim2.new(0.4, 0, 1, 0)
    TitleLbl.Position = UDim2.new(0, 10, 0, 0)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Text = title
    TitleLbl.TextSize = 11
    TitleLbl.TextColor3 = C.Text
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    TitleLbl.Font = Enum.Font.GothamMedium
    TitleLbl.ZIndex = 106
    
    local Input = Instance.new("TextBox", Opt)
    Input.Size = UDim2.new(0, 110, 0, 26)
    Input.Position = UDim2.new(1, -120, 0.5, -13)
    Input.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    Input.BackgroundTransparency = 0.3
    Input.BorderSizePixel = 0
    Input.Text = tostring(Settings[setting])
    Input.PlaceholderText = "Enter..."
    Input.TextColor3 = C.Text
    Input.PlaceholderColor3 = C.TextDim
    Input.TextSize = 10
    Input.Font = Enum.Font.Gotham
    Input.ZIndex = 106
    Round(Input, 6)
    Glass(Input, 0.3)
    
    Input.FocusLost:Connect(function(enter)
        if enter then
            local value = tonumber(Input.Text)
            if value then
                Settings[setting] = value
                if callback then callback(value) end
            else
                Input.Text = tostring(Settings[setting])
            end
        end
    end)
end

-- ═══════════════════════════════════════════════════════════
--                  EGG ESP SYSTEM  
-- ═══════════════════════════════════════════════════════════

local ESPConnections = {}
local ActiveESPs = {}

local function GetEggPart(egg)
    if egg:IsA("Model") then
        return egg.PrimaryPart or egg:FindFirstChildWhichIsA("BasePart")
    elseif egg:IsA("BasePart") then
        return egg
    end
    return nil
end

local function CreateEggESP(egg)
    local oldESP = egg:FindFirstChild("LowHubESP")
    if oldESP then oldESP:Destroy() end
    
    local eggPart = GetEggPart(egg)
    if not eggPart then return end
    
    local Billboard = Instance.new("BillboardGui")
    Billboard.Name = "LowHubESP"
    Billboard.Adornee = eggPart
    Billboard.Size = UDim2.new(0, 200, 0, 75)
    Billboard.StudsOffset = Vector3.new(0, 3, 0)
    Billboard.AlwaysOnTop = true
    Billboard.Parent = egg
    
    local Container = Instance.new("Frame", Billboard)
    Container.Size = UDim2.new(1, 0, 1, 0)
    Container.BackgroundTransparency = 1
    
    local EggNameLabel = Instance.new("TextLabel", Container)
    EggNameLabel.Size = UDim2.new(1, 0, 0, 22)
    EggNameLabel.Position = UDim2.new(0, 0, 0, 0)
    EggNameLabel.BackgroundTransparency = 1
    EggNameLabel.Text = egg:GetAttribute("EggName") or "Egg"
    EggNameLabel.TextColor3 = C.Neon
    EggNameLabel.TextSize = 14
    EggNameLabel.Font = Enum.Font.GothamBold
    EggNameLabel.TextStrokeTransparency = 0.3
    EggNameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    
    local PetNameLabel = Instance.new("TextLabel", Container)
    PetNameLabel.Size = UDim2.new(1, 0, 0, 24)
    PetNameLabel.Position = UDim2.new(0, 0, 0, 24)
    PetNameLabel.BackgroundTransparency = 1
    PetNameLabel.Text = ""
    PetNameLabel.TextColor3 = C.Ready
    PetNameLabel.TextSize = 16
    PetNameLabel.Font = Enum.Font.GothamBold
    PetNameLabel.TextStrokeTransparency = 0.2
    PetNameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    
    local TimeLabel = Instance.new("TextLabel", Container)
    TimeLabel.Size = UDim2.new(1, 0, 0, 20)
    TimeLabel.Position = UDim2.new(0, 0, 0, 50)
    TimeLabel.BackgroundTransparency = 1
    TimeLabel.Text = ""
    TimeLabel.TextColor3 = C.Text
    TimeLabel.TextSize = 12
    TimeLabel.Font = Enum.Font.Gotham
    TimeLabel.TextStrokeTransparency = 0.3
    TimeLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    
    local Highlight = Instance.new("Highlight", egg)
    Highlight.FillColor = C.Neon
    Highlight.FillTransparency = 0.7
    Highlight.OutlineColor = C.Neon
    Highlight.OutlineTransparency = 0
    
    -- Store ESP reference
    ActiveESPs[egg] = {
        Billboard = Billboard,
        PetNameLabel = PetNameLabel,
        Highlight = Highlight
    }
    
    local conn = RunService.RenderStepped:Connect(function()
        if not egg or not egg.Parent or not Settings.EggESP then
            Billboard:Destroy()
            Highlight:Destroy()
            conn:Disconnect()
            ActiveESPs[egg] = nil
            return
        end
        
        local time = egg:GetAttribute("TimeToHatch")
        local isReady = egg:GetAttribute("READY")
        
        EggNameLabel.Text = egg:GetAttribute("EggName") or "Egg"
        
        if isReady then
            local petName = GetPetName(egg)
            if petName then
                PetNameLabel.Text = "🐾 " .. petName
                PetNameLabel.TextColor3 = C.Ready
            else
                PetNameLabel.Text = "🔄 Detecting..."
                PetNameLabel.TextColor3 = C.Orange
            end
            Highlight.FillColor = petName and C.Ready or C.Orange
            Highlight.OutlineColor = petName and C.Ready or C.Orange
        else
            PetNameLabel.Text = ""
            Highlight.FillColor = C.Neon
            Highlight.OutlineColor = C.Neon
        end
        
        if time and time > 0 then
            local h = math.floor(time / 3600)
            local m = math.floor((time % 3600) / 60)
            local s = math.floor(time % 60)
            
            TimeLabel.Text = h > 0 and string.format("⏱️ %dh %dm %ds", h, m, s) or 
                            m > 0 and string.format("⏱️ %dm %ds", m, s) or 
                            string.format("⏱️ %ds", s)
            TimeLabel.TextColor3 = C.Text
            TimeLabel.Font = Enum.Font.Gotham
        elseif isReady then
            TimeLabel.Text = "✅ READY!"
            TimeLabel.TextColor3 = C.Ready
            TimeLabel.Font = Enum.Font.GothamBold
        else
            TimeLabel.Text = ""
        end
    end)
    
    table.insert(ESPConnections, conn)
end

local function FindEggs()
    local eggs = {}
    local farm = workspace:FindFirstChild("Farm")
    if not farm then return eggs end
    
    for _, plot in pairs(farm:GetChildren()) do
        local important = plot:FindFirstChild("Important")
        if important then
            local objects = important:FindFirstChild("Objects_Physical")
            if objects then
                for _, obj in pairs(objects:GetChildren()) do
                    if obj.Name == "PetEgg" then
                        table.insert(eggs, obj)
                    end
                end
            end
        end
    end
    
    return eggs
end

local function EnableEggESP()
    for _, egg in pairs(FindEggs()) do
        CreateEggESP(egg)
    end
    
    local conn = workspace.DescendantAdded:Connect(function(desc)
        if Settings.EggESP and desc.Name == "PetEgg" then
            wait(0.5)
            CreateEggESP(desc)
        end
    end)
    
    table.insert(ESPConnections, conn)
end

local function DisableEggESP()
    for _, conn in pairs(ESPConnections) do
        if conn then conn:Disconnect() end
    end
    ESPConnections = {}
    ActiveESPs = {}
    
    for _, egg in pairs(FindEggs()) do
        local esp = egg:FindFirstChild("LowHubESP")
        if esp then esp:Destroy() end
        local hl = egg:FindFirstChild("Highlight")
        if hl then hl:Destroy() end
    end
end

-- ═══════════════════════════════════════════════════════════
--                  AUTO-REFRESH SYSTEM
-- ═══════════════════════════════════════════════════════════

spawn(function()
    while wait(REFRESH_INTERVAL) do
        if Settings.EggESP then
            local currentTime = tick()
            if currentTime - lastRefresh >= REFRESH_INTERVAL then
                lastRefresh = currentTime
                
                -- Try to get more pet names
                local newFound = TryAccessModuleData()
                if newFound > 0 then
                    print("🔄 Auto-refresh: Found " .. newFound .. " new pet names!")
                end
                
                -- Update existing ESPs that might have new data
                for egg, espData in pairs(ActiveESPs) do
                    if egg and egg.Parent and egg:GetAttribute("READY") then
                        local petName = GetPetName(egg)
                        if petName and espData.PetNameLabel then
                            espData.PetNameLabel.Text = "🐾 " .. petName
                            espData.PetNameLabel.TextColor3 = C.Ready
                            if espData.Highlight then
                                espData.Highlight.FillColor = C.Ready
                                espData.Highlight.OutlineColor = C.Ready
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════
--                      TAB CONTENTS
-- ═══════════════════════════════════════════════════════════

function LoadHomeTab()
    local welcome = Instance.new("TextLabel")
    welcome.Size = UDim2.new(1, 0, 0, 90)
    welcome.BackgroundColor3 = C.Glass
    welcome.BackgroundTransparency = 0.3
    welcome.BorderSizePixel = 0
    welcome.Text = "🔄 AUTO-REFRESH ACTIVE!\n\nTries to detect pet names\nevery " .. REFRESH_INTERVAL .. " seconds"
    welcome.TextColor3 = C.Neon
    welcome.TextSize = 12
    welcome.Font = Enum.Font.GothamBold
    welcome.ZIndex = 105
    welcome.Parent = Scroll
    Round(welcome, 8)
    Glass(welcome, 0.3)
    
    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1, 0, 0, 150)
    info.BackgroundColor3 = C.Glass
    info.BackgroundTransparency = 0.3
    info.BorderSizePixel = 0
    info.Text = "🔍 Detection Methods:\n\n✅ RemoteEvent hook (new eggs)\n🔄 Module data access (old eggs)\n🔄 Workspace scanning\n🔄 Event monitoring\n\n🟠 Orange = Detecting...\n🟢 Gold = Pet name found!\n\nJust enable ESP and wait!"
    info.TextColor3 = C.TextDim
    info.TextSize = 10
    info.Font = Enum.Font.Gotham
    info.TextYAlignment = Enum.TextYAlignment.Top
    info.ZIndex = 105
    info.Parent = Scroll
    Round(info, 8)
    Glass(info, 0.3)
    
    local pad = Instance.new("UIPadding", info)
    pad.PaddingTop = UDim.new(0, 8)
    pad.PaddingLeft = UDim.new(0, 8)
end

function LoadPlayerTab()
    CreateInput("Set Speed", "Speed", function(value)
        Humanoid.WalkSpeed = value
    end)
    
    CreateToggle("Enable Walkspeed", "WalkspeedEnabled", function(enabled)
        Humanoid.WalkSpeed = enabled and 100 or Settings.Speed
    end)
    
    CreateToggle("No Clip", "NoClip", function(enabled)
        if enabled then
            _G.NoClip = RunService.Stepped:Connect(function()
                for _, part in pairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end)
        else
            if _G.NoClip then
                _G.NoClip:Disconnect()
                for _, part in pairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = true end
                end
            end
        end
    end)
    
    CreateToggle("Infinite Jump", "InfJump", function(enabled)
        if enabled then
            _G.InfJump = UserInputService.JumpRequest:Connect(function()
                Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end)
        else
            if _G.InfJump then _G.InfJump:Disconnect() end
        end
    end)
    
    if Settings.WalkspeedEnabled then
        Humanoid.WalkSpeed = 100
    else
        Humanoid.WalkSpeed = Settings.Speed
    end
    
    if Settings.NoClip and not _G.NoClip then
        _G.NoClip = RunService.Stepped:Connect(function()
            for _, part in pairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end)
    end
    
    if Settings.InfJump and not _G.InfJump then
        _G.InfJump = UserInputService.JumpRequest:Connect(function()
            Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end)
    end
end

function LoadEggTab()
    CreateToggle("Egg ESP", "EggESP", function(enabled)
        if enabled then
            EnableEggESP()
        else
            DisableEggESP()
        end
    end)
    
    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1, 0, 0, 140)
    info.BackgroundColor3 = C.Glass
    info.BackgroundTransparency = 0.3
    info.BorderSizePixel = 0
    info.Text = "🥚 Smart ESP + Auto-Refresh\n\n✅ Shows egg name always\n🔄 Auto-detects pet names\n⏱️ Real-time countdown\n🟠 Orange = Detecting\n🟢 Gold = Pet found\n\nRefreshes every " .. REFRESH_INTERVAL .. "s\nautomatically!"
    info.TextColor3 = C.TextDim
    info.TextSize = 10
    info.Font = Enum.Font.Gotham
    info.TextYAlignment = Enum.TextYAlignment.Top
    info.ZIndex = 105
    info.Parent = Scroll
    Round(info, 8)
    Glass(info, 0.3)
    
    local pad = Instance.new("UIPadding", info)
    pad.PaddingTop = UDim.new(0, 8)
    pad.PaddingLeft = UDim.new(0, 8)
    
    if Settings.EggESP then
        EnableEggESP()
    end
end

CreateTab("Home", "🏠", 1)
CreateTab("Player", "👤", 2)
CreateTab("Egg", "🥚", 3)

-- ═══════════════════════════════════════════════════════════
--                     FUNCTIONALITY
-- ═══════════════════════════════════════════════════════════

Icon.MouseButton1Click:Connect(function()
    Main.Visible = true
    Icon.Visible = false
    Main.Size = UDim2.new(0, 0, 0, 0)
    Tween(Main, {Size = UDim2.new(0, 560, 0, 380)}, 0.4)
end)

CloseBtn.MouseButton1Click:Connect(function()
    Tween(Main, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
    Tween(Icon, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
    wait(0.4)
    GUI:Destroy()
end)

MinBtn.MouseButton1Click:Connect(function()
    Tween(Main, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
    wait(0.3)
    Main.Visible = false
    Icon.Visible = true
end)

CloseBtn.MouseEnter:Connect(function() Tween(CloseBtn, {BackgroundTransparency = 0.1}) end)
CloseBtn.MouseLeave:Connect(function() Tween(CloseBtn, {BackgroundTransparency = 0.3}) end)
MinBtn.MouseEnter:Connect(function() Tween(MinBtn, {BackgroundTransparency = 0.1}) end)
MinBtn.MouseLeave:Connect(function() Tween(MinBtn, {BackgroundTransparency = 0.3}) end)

local dragging, dragStart, startPos
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local iconDrag, iconStart, iconStartPos
Icon.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        iconDrag = true
        iconStart = input.Position
        iconStartPos = Icon.Position
    end
end)

Icon.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        iconDrag = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if iconDrag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - iconStart
        Icon.Position = UDim2.new(iconStartPos.X.Scale, iconStartPos.X.Offset + delta.X, iconStartPos.Y.Scale, iconStartPos.Y.Offset + delta.Y)
    end
end)

wait(0.3)

for _, tab in pairs(Sidebar:GetChildren()) do
    if tab:IsA("TextButton") then
        tab.MouseButton1Click:Fire()
        break
    end
end

print("✅ LOW HUB v2.4 LOADED!")
print("🔄 Auto-refresh active - checking every " .. REFRESH_INTERVAL .. "s")
print("════════════════════════════════════════════")