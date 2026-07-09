-- Reconnect V2 - Glass Morphism UI v2.1.0
-- Loadstring compatible - CoreGui - Image Icons
-- Pro Plus Theme
--
-- Usage:
-- getgenv().ReconnectConfig = {
--     -- Launcher
--     ShowUI                  = false,          -- true = full UI, false = minimal panel
--     BypassPlayerLoading     = false,          -- skip character load wait

--     -- General
--     UpdateInterval          = 5,             -- seconds between status updates
--     AutoRejoin              = true,          -- rejoin on teleport fail
--     RejoinDelay             = 3,             -- seconds before rejoin attempt
--     AntiKick                = false,         -- block server kicks
--     AntiIdle                = false,         -- prevent AFK disconnect
--     MemoryWarningThreshold  = 500,           -- MB before warning
--     HeartbeatEnabled        = true,          -- heartbeat monitoring

--     -- FPS
--     ShowFPS                 = true,          -- display FPS counter
--     FPSLockEnabled          = false,         -- cap FPS
--     FPSLockValue            = 60,            -- FPS cap target

--     -- Map Optimization
--     MapOptimization         = false,         -- strip decor/particles/etc
--     OptimizationLevel       = "Extreme",     -- Low / Medium / High / Extreme

--     -- Webhook
--     WebhookURL              = "",            -- Discord webhook URL
--     WebhookOnDisconnect     = false,         -- notify on disconnect
--     WebhookOnRejoin         = false,         -- notify on rejoin
--     WebhookOnStart          = false,         -- notify on start

--     -- Display
--     BlackScreen             = false,         -- black overlay mode
-- }
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/kattie21/test/main/test2.lua"))()

-- ============================================================
-- PHASE 1: ANTI-DETECTION WRAPPERS (WindUI-style)
-- ============================================================

local cloneref = cloneref or clonereference or function(inst) return inst end
local ProtectGui = protectgui or (syn and syn.protect_gui) or function() end
local GUIParent = gethui and gethui() or cloneref(game:GetService("CoreGui"))

-- ============================================================
-- PHASE 1: SERVICES (cloneref-wrapped)
-- ============================================================

local GuiService       = cloneref(game:GetService("GuiService"))
local Players          = cloneref(game:GetService("Players"))
local HttpService      = cloneref(game:GetService("HttpService"))
local RunService       = cloneref(game:GetService("RunService"))
local TweenService     = cloneref(game:GetService("TweenService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local TeleportService  = cloneref(game:GetService("TeleportService"))
local Stats            = cloneref(game:GetService("Stats"))
local Lighting         = cloneref(game:GetService("Lighting"))

-- ============================================================
-- PHASE 1: WAIT FOR GAME
-- ============================================================

local function waitForGame()
    local bypassLoading = false
    if getgenv then
        if getgenv().ReconnectConfig and getgenv().ReconnectConfig.BypassPlayerLoading then
            bypassLoading = true
        elseif getgenv().BypassPlayerLoading then
            bypassLoading = true
        end
    end
    if not game:IsLoaded() then game.Loaded:Wait() end
    if bypassLoading then
        repeat task.wait() until Players.LocalPlayer
        return
    end
    repeat task.wait() until Players.LocalPlayer and Players.LocalPlayer.Character
    task.wait(1)
end

waitForGame()

-- ============================================================
-- PHASE 1: THEME (Pro Plus - Dashboard-matched)
-- ============================================================
-- Mirrors reconnect_user_dashboard color system:
-- Surfaces: slate-900/95, slate-800/90 with transparency
-- Cards: slate-800/90 border slate-700/50
-- Active: bg-cyan-500/15 with left cyan accent bar
-- Text gradient: cyan-400 to blue-500

local Theme = {
    -- Brand (cyan-400 / blue-500 gradient)
    Primary       = Color3.fromRGB(34, 211, 238),
    PrimaryDark   = Color3.fromRGB(6, 182, 212),
    Secondary     = Color3.fromRGB(59, 130, 246),
    Accent        = Color3.fromRGB(100, 220, 255),
    GradStart     = Color3.fromRGB(34, 211, 238),
    GradEnd       = Color3.fromRGB(59, 130, 246),

    -- Surfaces (slate palette)
    BgDeep        = Color3.fromRGB(8, 10, 18),
    BgBase        = Color3.fromRGB(15, 23, 42),
    BgElevated    = Color3.fromRGB(22, 28, 45),
    BgCard        = Color3.fromRGB(30, 41, 59),
    BgCardHover   = Color3.fromRGB(38, 50, 70),
    BgHover       = Color3.fromRGB(30, 41, 59),
    BgInput       = Color3.fromRGB(15, 23, 42),
    BgSidebar     = Color3.fromRGB(12, 17, 32),

    -- Glass transparency values
    GlassWindow   = 0.05,
    GlassSidebar  = 0.05,
    GlassCard     = 0.1,
    GlassTopBar   = 0.15,
    GlassOverlay  = 0.4,

    -- Toggle
    ToggleOn      = Color3.fromRGB(34, 211, 238),
    ToggleOff     = Color3.fromRGB(51, 65, 85),
    ToggleKnob    = Color3.fromRGB(255, 255, 255),

    -- Active state
    ActiveBg      = Color3.fromRGB(34, 211, 238),
    ActiveBgTrans = 0.85,

    -- Text
    Text          = Color3.fromRGB(248, 250, 252),
    TextSub       = Color3.fromRGB(203, 213, 225),
    TextDim       = Color3.fromRGB(148, 163, 184),
    TextMuted     = Color3.fromRGB(100, 116, 139),

    -- Semantic
    Success       = Color3.fromRGB(52, 211, 153),
    Error         = Color3.fromRGB(248, 113, 113),
    Warning       = Color3.fromRGB(251, 191, 36),
    Info          = Color3.fromRGB(96, 165, 250),

    -- Borders
    Border        = Color3.fromRGB(51, 65, 85),
    BorderTrans   = 0.5,
    BorderLight   = Color3.fromRGB(71, 85, 105),

    -- Radius
    R_SM   = UDim.new(0, 8),
    R_MD   = UDim.new(0, 12),
    R_LG   = UDim.new(0, 16),
    R_XL   = UDim.new(0, 20),
    R_2XL  = UDim.new(0, 24),
    R_PILL = UDim.new(1, 0),

    -- Fonts
    Font     = Enum.Font.Gotham,
    FontMed  = Enum.Font.GothamMedium,
    FontBold = Enum.Font.GothamBold,
    FontSB   = Enum.Font.GothamSemibold,
}

-- ============================================================
-- PHASE 1: CONFIGURATION
-- ============================================================

local function getConfigValue(key, default)
    if getgenv then
        if getgenv().ReconnectConfig and getgenv().ReconnectConfig[key] ~= nil then
            return getgenv().ReconnectConfig[key]
        end
        if getgenv()[key] ~= nil then return getgenv()[key] end
    end
    return default
end

local Config = {
    UpdateInterval          = getConfigValue("UpdateInterval", 5),
    AutoRejoin              = getConfigValue("AutoRejoin", true),
    RejoinDelay             = getConfigValue("RejoinDelay", 3),
    ShowUI                  = getConfigValue("ShowUI", true),
    BypassPlayerLoading     = getConfigValue("BypassPlayerLoading", false),
    AntiKick                = getConfigValue("AntiKick", false),
    AntiIdle                = getConfigValue("AntiIdle", false),
    MemoryWarningThreshold  = getConfigValue("MemoryWarningThreshold", 500),
    HeartbeatEnabled        = getConfigValue("HeartbeatEnabled", true),
    ShowFPS                 = getConfigValue("ShowFPS", true),
    FPSLockEnabled          = getConfigValue("FPSLockEnabled", false),
    FPSLockValue            = getConfigValue("FPSLockValue", 60),
    MapOptimization         = getConfigValue("MapOptimization", false),
    OptimizationLevel       = getConfigValue("OptimizationLevel", "Extreme"),
    WebhookURL              = getConfigValue("WebhookURL", ""),
    WebhookOnDisconnect     = getConfigValue("WebhookOnDisconnect", false),
    WebhookOnRejoin         = getConfigValue("WebhookOnRejoin", false),
    WebhookOnStart          = getConfigValue("WebhookOnStart", false),
    BlackScreen             = getConfigValue("BlackScreen", false),
}

-- ============================================================
-- PHASE 1: STATE
-- ============================================================

local State = {
    StopUpdate          = false,
    SessionStart        = os.time(),
    TotalPings          = 0,
    FailedPings         = 0,
    LastPingTime        = 0,
    Reconnects          = 0,
    CurrentStatus       = "Initializing",
    MemoryUsage         = 0,
    CurrentFPS          = 0,
    CurrentPing         = 0,
    Connections         = {},
    OptimizationApplied = false,
    RemovedObjects      = 0,
}

local LP      = Players.LocalPlayer
local VERSION = "2.2.1"
local Terrain = Workspace:FindFirstChildOfClass("Terrain")
local LogoImage = "rbxassetid://73879916935249"

-- ============================================================
-- PHASE 1: EMBEDDED ICONS (no external fetching)
-- ============================================================

local Icons = {
    Home       = "rbxassetid://98755624629571",
    Dashboard  = "rbxassetid://139929981863901",
    Shield     = "rbxassetid://87354736164608",
    Zap        = "rbxassetid://130551565616516",
    Settings   = "rbxassetid://80758916183665",
    Globe      = "rbxassetid://114238209622913",
    Monitor    = "rbxassetid://72664649203050",
    Cpu        = "rbxassetid://77549309870247",
    Activity   = "rbxassetid://94212016861936",
    Check      = "rbxassetid://93898873302694",
    X          = "rbxassetid://110786993356448",
    Info       = "rbxassetid://124560466474914",
    Warning    = "rbxassetid://125920361880643",
    Bell       = "rbxassetid://97392696311902",
    Clock      = "rbxassetid://121808839832144",
    Map        = "rbxassetid://95107167260947",
    Lock       = "rbxassetid://134724289526879",
    Unlock     = "rbxassetid://93597915325122",
    Wifi       = "rbxassetid://104669375183960",
    Memory     = "rbxassetid://126791525623846",
    Target     = "rbxassetid://87563802520297",
    Ping       = "rbxassetid://85611589536956",
    Rocket     = "rbxassetid://87412317685854",
    Star       = "rbxassetid://136141469398409",
    User       = "rbxassetid://81589895647169",
    Power      = "rbxassetid://96479131758775",
    Eye        = "rbxassetid://100033680381365",
    Server     = "rbxassetid://92188766517878",
    Reload     = "rbxassetid://138133190015277",
    Play       = "rbxassetid://135609604299893",
    Pause      = "rbxassetid://74873705394436",
    ChevDown   = "rbxassetid://134243273101015",
    ChevUp     = "rbxassetid://122444883127455",
    ChevRight  = "rbxassetid://92473583511724",
    ArrowRight = "rbxassetid://113692007244654",
    Minus      = "rbxassetid://118026365011536",
    Trash      = "rbxassetid://109843431391323",
    Save       = "rbxassetid://126116963775616",
    FileText   = "rbxassetid://90496405707281",
}

-- ============================================================
-- PHASE 1: UTILITIES
-- ============================================================

local function formatTime(seconds)
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = seconds % 60
    if h > 0 then return string.format("%dh %dm %ds", h, m, s)
    elseif m > 0 then return string.format("%dm %ds", m, s)
    else return string.format("%ds", s) end
end

local function formatMemory(mb)
    return mb >= 1000 and string.format("%.1f GB", mb / 1000) or string.format("%.0f MB", mb)
end

local function lerpColor(a, b, t)
    return Color3.new(a.R + (b.R - a.R) * t, a.G + (b.G - a.G) * t, a.B + (b.B - a.B) * t)
end

-- ============================================================
-- PHASE 1: FILE OPS / LOGGING
-- ============================================================

local function safeWriteFile(filename, data)
    local ok = pcall(function()
        if not writefile or not makefolder or not isfolder then return end
        if not isfolder("ReconnectX") then makefolder("ReconnectX") end
        writefile("ReconnectX/" .. filename, data)
    end)
    return ok
end

local function safeReadFile(filename)
    local ok, result = pcall(function()
        if not readfile or not isfile then return nil end
        local path = "ReconnectX/" .. filename
        return isfile(path) and readfile(path) or nil
    end)
    return ok and result or nil
end

local SETTINGS_FILE = "reconnect_settings.json"

local SAVE_KEYS = {
    "ShowUI", "BypassPlayerLoading",
    "AntiKick", "AntiIdle", "AutoRejoin", "RejoinDelay",
    "FPSLockEnabled", "FPSLockValue", "MapOptimization", "OptimizationLevel",
    "HeartbeatEnabled", "ShowFPS",
    "UpdateInterval",
    "BlackScreen",
}

local function saveSettings()
    pcall(function()
        local data = {}
        for _, key in ipairs(SAVE_KEYS) do
            data[key] = Config[key]
        end
        safeWriteFile(SETTINGS_FILE, HttpService:JSONEncode(data))
    end)
end

-- A key explicitly passed in getgenv().ReconnectConfig (or getgenv() directly)
-- for THIS run always wins over whatever was persisted from a previous
-- session's in-game toggle — otherwise a stale saved value silently
-- overrides the autoexecute config and makes it look like the config
-- option "does nothing".
local function isExplicitlyConfigured(key)
    if getgenv then
        if getgenv().ReconnectConfig and getgenv().ReconnectConfig[key] ~= nil then
            return true
        end
        if getgenv()[key] ~= nil then return true end
    end
    return false
end

local function loadSettings()
    pcall(function()
        local raw = safeReadFile(SETTINGS_FILE)
        if not raw then return end
        local data = HttpService:JSONDecode(raw)
        if type(data) ~= "table" then return end
        for _, key in ipairs(SAVE_KEYS) do
            if data[key] ~= nil and not isExplicitlyConfigured(key) then
                Config[key] = data[key]
            end
        end
    end)
end

loadSettings()

-- ============================================================
-- PHASE 1: WEBHOOK NOTIFICATIONS
-- ============================================================

local function sendWebhook(title, description, color)
    if Config.WebhookURL == "" then return end
    pcall(function()
        local data = HttpService:JSONEncode({
            embeds = {{
                title = title,
                description = description,
                color = color or 3447003,
                fields = {
                    {name = "Player", value = LP.Name, inline = true},
                    {name = "Place", value = tostring(game.PlaceId), inline = true},
                    {name = "Uptime", value = formatTime(os.time() - State.SessionStart), inline = true},
                },
                footer = {text = "Reconnect V" .. VERSION},
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }}
        })

        local httpRequest = request or http_request
        if not httpRequest then
            if syn and syn.request then httpRequest = syn.request
            elseif http and http.request then httpRequest = http.request
            elseif fluxus and fluxus.request then httpRequest = fluxus.request end
        end

        if httpRequest then
            httpRequest({
                Url = Config.WebhookURL,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = data
            })
        elseif HttpPost then
            HttpPost(Config.WebhookURL, data)
        end
    end)
end

-- ============================================================
-- PHASE 1: PROTECTION SYSTEMS
-- ============================================================

local function setupAntiKick()
    if not Config.AntiKick then return true end
    return pcall(function()
        if hookmetamethod then
            local old; old = hookmetamethod(game, "__namecall", function(self, ...)
                if self == LP and getnamecallmethod():lower() == "kick" then return nil end
                return old(self, ...)
            end)
        end
        if hookfunction and LP.Kick then
            hookfunction(LP.Kick, function() return nil end)
        end
    end)
end

local function setupAntiIdle()
    if not Config.AntiIdle then return end
    pcall(function()
        local conn = LP.Idled:Connect(function()
            pcall(function()
                local cam = Workspace.CurrentCamera
                if cam then
                    cam.CFrame = cam.CFrame * CFrame.Angles(0, math.rad(0.001), 0)
                    task.wait(0.1)
                    cam.CFrame = cam.CFrame * CFrame.Angles(0, math.rad(-0.001), 0)
                end
            end)
        end)
        table.insert(State.Connections, conn)
    end)
end

-- ============================================================
-- PHASE 1: MAP OPTIMIZATION
-- ============================================================

local function optimizeMap()
    if not Config.MapOptimization or State.OptimizationApplied then return end
    local level = Config.OptimizationLevel
    local removed = 0

    local presets = {
        Low     = { decor=true, particles=true, beams=false, sounds=false, lighting=false, terrain=false, textures=false, transparency=false },
        Medium  = { decor=true, particles=true, beams=true,  sounds=true,  lighting=true,  terrain=false, textures=false, transparency=false },
        High    = { decor=true, particles=true, beams=true,  sounds=true,  lighting=true,  terrain=true,  textures=true,  transparency=false },
        Extreme = { decor=true, particles=true, beams=true,  sounds=true,  lighting=true,  terrain=true,  textures=true,  transparency=true  },
    }
    local opts = presets[level] or presets.Medium

    local decorKeywords = {
        "tree","grass","plant","flower","bush","rock","stone","decor","decoration","prop",
        "detail","foliage","leaf","cloud","bird","butterfly","fish","animal","npc","sign",
        "poster","banner","flag","lamp","light","bench","chair","table","fence","barrel",
        "crate","trash","debris","rubble","pile","clutter"
    }

    pcall(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if not obj:IsDescendantOf(LP.Character or Instance.new("Part")) then
                local n, done, remove = obj.Name:lower(), false, false
                if opts.particles and not done and (obj:IsA("ParticleEmitter") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles")) then
                    pcall(function() obj:Destroy() end); removed = removed + 1; done = true
                end
                if opts.beams and not done and (obj:IsA("Beam") or obj:IsA("Trail")) then
                    pcall(function() obj:Destroy() end); removed = removed + 1; done = true
                end
                if opts.sounds and not done and obj:IsA("Sound") and not obj:IsDescendantOf(LP) then
                    pcall(function() obj:Stop(); obj.Volume = 0 end); removed = removed + 1; done = true
                end
                if opts.decor and not done then
                    for _, kw in ipairs(decorKeywords) do if n:find(kw) then remove = true; break end end
                    if obj:IsA("BasePart") and not obj.CanCollide then
                        local s = obj.Size; if s.X < 10 and s.Y < 10 and s.Z < 10 then remove = true end
                    end
                end
                if opts.textures and not done and (obj:IsA("Texture") or obj:IsA("Decal")) then
                    pcall(function() obj.Transparency = 1 end); removed = removed + 1; done = true
                end
                if opts.transparency and not done and obj:IsA("BasePart") then
                    pcall(function() obj.Material = Enum.Material.SmoothPlastic; obj.Reflectance = 0; obj.CastShadow = false end)
                end
                if remove and not done then
                    pcall(function()
                        if obj:IsA("BasePart") then obj.Transparency = 1; obj.CanCollide = false
                        elseif obj:IsA("Model") then
                            for _, p in ipairs(obj:GetDescendants()) do
                                if p:IsA("BasePart") then p.Transparency = 1; p.CanCollide = false end
                            end
                        end
                    end)
                    removed = removed + 1
                end
            end
        end
    end)

    if opts.lighting then pcall(function()
        Lighting.GlobalShadows = false; Lighting.FogEnd = 100000; Lighting.Brightness = 2
        for _, e in ipairs(Lighting:GetChildren()) do
            if e:IsA("BlurEffect") or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect") then
                pcall(function() e.Enabled = false end)
            end
        end
    end) end

    if opts.terrain and Terrain then pcall(function()
        Terrain.WaterWaveSize = 0; Terrain.WaterWaveSpeed = 0; Terrain.WaterReflectance = 0; Terrain.WaterTransparency = 0
    end) end

    pcall(function() settings().Rendering.QualityLevel = 1 end)
    State.OptimizationApplied = true; State.RemovedObjects = removed
end

-- ============================================================
-- PHASE 1: AUTO-REJOIN
-- ============================================================

local function setupAutoRejoin()
    if not Config.AutoRejoin then return end
    pcall(function()
        local conn = TeleportService.TeleportInitFailed:Connect(function(player, result)
            if player == LP then
                task.wait(Config.RejoinDelay)
                State.Reconnects = State.Reconnects + 1
                if Config.WebhookOnRejoin then
                    sendWebhook("Rejoining", "Attempt #" .. State.Reconnects .. " - Teleport failed: " .. tostring(result), 16776960)
                end
                pcall(function() TeleportService:Teleport(game.PlaceId, LP) end)
            end
        end)
        table.insert(State.Connections, conn)
    end)
end

-- ============================================================
-- PHASE 1: MONITORS
-- ============================================================

local function updateMemoryUsage()
    pcall(function() State.MemoryUsage = math.floor(Stats:GetTotalMemoryUsageMb()) end)
end

local function updatePing()
    pcall(function() State.CurrentPing = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
end

local fpsValues, lastFPSUpdate = {}, tick()

local function setupFPSCounter()
    if not Config.ShowFPS then return end
    local conn = RunService.RenderStepped:Connect(function(dt)
        table.insert(fpsValues, 1 / dt)
        if tick() - lastFPSUpdate >= 0.5 then
            if #fpsValues > 0 then
                local sum = 0; for _, v in ipairs(fpsValues) do sum = sum + v end
                State.CurrentFPS = math.floor(sum / #fpsValues); fpsValues = {}
            end
            lastFPSUpdate = tick()
        end
        if #fpsValues > 60 then table.remove(fpsValues, 1) end
    end)
    table.insert(State.Connections, conn)
end

local function setFPSLock(target)
    local cap = setfpscap or setfps or set_fps_cap or SetFPSCap
    if not cap and getgenv then local g = getgenv(); cap = g.setfpscap or g.setfps end
    if not cap and setrenderproperty then
        local ok = pcall(function() setrenderproperty("MaxFrameRate", target or 9999) end)
        if ok then return true end
    end
    if target and target < 60 and not cap then
        local ft, lf = 1/target, tick()
        local conn = RunService.RenderStepped:Connect(function()
            local n = tick(); if n - lf < ft then local s = tick(); while tick()-s < (ft-(n-lf)) do end end; lf = tick()
        end)
        table.insert(State.Connections, conn); return true
    end
    if not cap then return false end
    return pcall(function() cap(target and target > 0 and target or 9999) end)
end

local function setupFPSLock()
    if Config.FPSLockEnabled and Config.FPSLockValue > 0 then setFPSLock(Config.FPSLockValue) end
end

local function setupConnectionMonitoring()
    local c1 = GuiService.ErrorMessageChanged:Connect(function()
        local code = GuiService:GetErrorCode()
        if code and code.Value >= Enum.ConnectionError.DisconnectErrors.Value then
            State.StopUpdate = true; State.CurrentStatus = "Disconnected"
            if Config.WebhookOnDisconnect then
                sendWebhook("Disconnected", "Player was disconnected: " .. code.Name, 15548997)
            end
        end
    end)
    table.insert(State.Connections, c1)
    local c2 = Players.PlayerRemoving:Connect(function(p)
        if p == LP then
            State.StopUpdate = true
            if Config.WebhookOnDisconnect then
                sendWebhook("Left Game", "Player left the game", 16776960)
            end
        end
    end)
    table.insert(State.Connections, c2)
end

local function runHeartbeat()
    if not Config.HeartbeatEnabled then return end
    local conn = RunService.Heartbeat:Connect(function() State.LastPingTime = tick() end)
    table.insert(State.Connections, conn)
end

local function cleanup()
    for _, c in ipairs(State.Connections) do pcall(function() c:Disconnect() end) end
    State.Connections = {}
end

-- ============================================================
-- PHASE 1: BLACK SCREEN SYSTEM
-- ============================================================

local BlackScreenGui = nil
local BlackScreenActive = false

local function createBlackScreen()
    if BlackScreenGui then return end
    local bsg = Instance.new("ScreenGui")
    bsg.Name = "ReconnectBlackScreen"
    bsg.ResetOnSpawn = false
    bsg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    bsg.IgnoreGuiInset = true
    bsg.DisplayOrder = 998
    bsg.Parent = GUIParent
    ProtectGui(bsg)

    local bg = Instance.new("Frame")
    bg.Name = "Overlay"
    bg.BackgroundColor3 = Color3.fromRGB(2, 2, 8)
    bg.BackgroundTransparency = 0
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BorderSizePixel = 0
    bg.ZIndex = 1
    bg.Parent = bsg

    local logoImg = Instance.new("ImageLabel")
    logoImg.Name = "Logo"
    logoImg.BackgroundTransparency = 1
    logoImg.Image = LogoImage
    logoImg.ScaleType = Enum.ScaleType.Fit
    logoImg.ImageTransparency = 0.6
    logoImg.Size = UDim2.new(0, 64, 0, 64)
    logoImg.Position = UDim2.new(0.5, -32, 0.5, -50)
    logoImg.ZIndex = 2
    logoImg.Parent = bg

    local brandLbl = Instance.new("TextLabel")
    brandLbl.Name = "Brand"
    brandLbl.BackgroundTransparency = 1
    brandLbl.Text = "Reconnect"
    brandLbl.Font = Enum.Font.GothamBold
    brandLbl.TextSize = 22
    brandLbl.TextColor3 = Color3.fromRGB(34, 211, 238)
    brandLbl.TextTransparency = 0.5
    brandLbl.Size = UDim2.new(0, 200, 0, 30)
    brandLbl.Position = UDim2.new(0.5, -100, 0.5, 22)
    brandLbl.ZIndex = 2
    brandLbl.Parent = bg

    local subLbl = Instance.new("TextLabel")
    subLbl.Name = "Sub"
    subLbl.BackgroundTransparency = 1
    subLbl.Text = "Session Active - Screen Off"
    subLbl.Font = Enum.Font.Gotham
    subLbl.TextSize = 12
    subLbl.TextColor3 = Color3.fromRGB(100, 116, 139)
    subLbl.TextTransparency = 0.3
    subLbl.Size = UDim2.new(0, 200, 0, 20)
    subLbl.Position = UDim2.new(0.5, -100, 0.5, 52)
    subLbl.ZIndex = 2
    subLbl.Parent = bg

    BlackScreenGui = bsg
end

local function setBlackScreen(enabled)
    BlackScreenActive = enabled
    Config.BlackScreen = enabled
    if enabled then
        createBlackScreen()
        BlackScreenGui.Enabled = true
        pcall(function() settings().Rendering.QualityLevel = 1 end)
        pcall(function() Lighting.GlobalShadows = false end)
        pcall(function()
            for _, e in ipairs(Lighting:GetChildren()) do
                if e:IsA("BlurEffect") or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") or e:IsA("SunRaysEffect") then
                    pcall(function() e.Enabled = false end)
                end
            end
        end)
    else
        if BlackScreenGui then
            BlackScreenGui.Enabled = false
        end
    end
end

-- ============================================================
-- PHASE 2: SCREENGUI (anti-detection: gethui + cloneref + protectgui)
-- ============================================================

-- Kill any previous Reconnect GUI
pcall(function()
    for _, v in ipairs(GUIParent:GetChildren()) do
        if v:IsA("ScreenGui") and v.Name == "ReconnectV2" then v:Destroy() end
    end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name                = "ReconnectV2"
ScreenGui.ResetOnSpawn        = false
ScreenGui.ZIndexBehavior      = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset      = true
ScreenGui.DisplayOrder        = 999
ScreenGui.Parent              = GUIParent
ProtectGui(ScreenGui)

-- ============================================================
-- PHASE 2: INSTANCE FACTORY
-- ============================================================

local function new(class, props, children)
    local inst = Instance.new(class)
    if props then
        for k, v in pairs(props) do
            if k ~= "Parent" then inst[k] = v end
        end
        if props.Parent then inst.Parent = props.Parent end
    end
    if children then
        for _, child in ipairs(children) do child.Parent = inst end
    end
    return inst
end

-- ============================================================
-- PHASE 2: UI CONSTRAINT HELPERS
-- ============================================================

local function corner(parent, r)
    if type(r) == "number" then r = UDim.new(0, r) end
    return new("UICorner", { CornerRadius = r or Theme.R_LG, Parent = parent })
end

local function stroke(parent, color, transparency, thickness)
    return new("UIStroke", {
        Color        = color or Theme.Border,
        Transparency = transparency or Theme.BorderTrans,
        Thickness    = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent       = parent,
    })
end

local function pad(parent, t, b, l, r)
    if type(t) == "number" and not b then
        b, l, r = t, t, t
    end
    return new("UIPadding", {
        PaddingTop    = UDim.new(0, t or 0),
        PaddingBottom = UDim.new(0, b or 0),
        PaddingLeft   = UDim.new(0, l or 0),
        PaddingRight  = UDim.new(0, r or 0),
        Parent        = parent,
    })
end

local function uiList(parent, dir, spacing, alignX, alignY, sortOrder)
    return new("UIListLayout", {
        FillDirection       = dir or Enum.FillDirection.Vertical,
        Padding             = UDim.new(0, spacing or 8),
        HorizontalAlignment = alignX or Enum.HorizontalAlignment.Left,
        VerticalAlignment   = alignY or Enum.VerticalAlignment.Top,
        SortOrder           = sortOrder or Enum.SortOrder.LayoutOrder,
        Parent              = parent,
    })
end

local function label(parent, props)
    return new("TextLabel", {
        BackgroundTransparency = 1,
        Font          = props.Font or Theme.Font,
        TextColor3    = props.Color or Theme.Text,
        TextSize      = props.Size or 14,
        Text          = props.Text or "",
        TextXAlignment = props.AlignX or Enum.TextXAlignment.Left,
        TextYAlignment = props.AlignY or Enum.TextYAlignment.Center,
        TextTruncate  = props.Truncate or Enum.TextTruncate.AtEnd,
        Size          = props.FrameSize or UDim2.new(1, 0, 0, 20),
        Position      = props.Position or UDim2.new(0, 0, 0, 0),
        LayoutOrder   = props.Order or 0,
        RichText      = props.Rich or false,
        TextWrapped   = props.Wrap or false,
        ZIndex        = props.ZIndex or 1,
        Parent        = parent,
    })
end

-- ============================================================
-- PHASE 2: TWEEN HELPERS
-- ============================================================

local TI_FAST   = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TI_NORMAL = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TI_SMOOTH = TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local TI_SPRING = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local TI_SLOW   = TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

local function tween(obj, info, props)
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

-- ============================================================
-- PHASE 2: GLASS-MORPHISM FACTORY
-- ============================================================
-- Creates glass-style frames mimicking the dashboard's
-- backdrop-blur + translucent dark surfaces.

-- Variants whose Size is always scale/formula-driven (never swapped to
-- AutomaticSize after creation) — safe to auto-attach a synced drop shadow.
local function glass(parent, variant, props)
    props = props or {}
    local bgMap = {
        window  = { bg = Theme.BgBase,      trans = Theme.GlassWindow },
        sidebar = { bg = Theme.BgSidebar,    trans = Theme.GlassSidebar },
        card    = { bg = Theme.BgCard,       trans = Theme.GlassCard },
        topbar  = { bg = Theme.BgElevated,   trans = Theme.GlassTopBar },
        input   = { bg = Theme.BgInput,      trans = 0.3 },
        overlay = { bg = Theme.BgBase,       trans = Theme.GlassOverlay },
        active  = { bg = Theme.ActiveBg,     trans = Theme.ActiveBgTrans },
    }
    local style = bgMap[variant] or bgMap.card

    local frame = new("Frame", {
        Name                   = props.Name or (variant .. "Glass"),
        BackgroundColor3       = props.Bg or style.bg,
        BackgroundTransparency = props.Trans or style.trans,
        Size                   = props.Size or UDim2.new(1, 0, 1, 0),
        Position               = props.Position or UDim2.new(0, 0, 0, 0),
        AnchorPoint            = props.Anchor or Vector2.new(0, 0),
        ClipsDescendants       = props.Clip ~= false,
        LayoutOrder            = props.Order or 0,
        ZIndex                 = props.ZIndex or 1,
        Visible                = props.Visible ~= false,
        Parent                 = parent,
    })

    corner(frame, props.Radius or Theme.R_LG)

    if props.NoBorder ~= true then
        stroke(frame, props.BorderColor or Theme.Border, props.BorderTrans or Theme.BorderTrans, props.BorderThick or 1)
    end

    -- Subtle diagonal glass sheen — lighter at the top-left, settling into
    -- the base color — instead of a flat single-tone surface.
    if props.NoSheen ~= true and (variant == "window" or variant == "card" or variant == "sidebar" or variant == "topbar") then
        local baseColor = props.Bg or style.bg
        new("UIGradient", {
            Color    = ColorSequence.new(lerpColor(baseColor, Color3.new(1, 1, 1), 0.06), baseColor),
            Rotation = 105,
            Parent   = frame,
        })
    end

    return frame
end

-- ============================================================
-- PHASE 2: GRADIENT HELPERS
-- ============================================================

local function applyGradient(obj, c1, c2, rotation)
    return new("UIGradient", {
        Color    = ColorSequence.new(c1 or Theme.GradStart, c2 or Theme.GradEnd),
        Rotation = rotation or 0,
        Parent   = obj,
    })
end

local function gradientLabel(parent, props)
    local lbl = label(parent, props)
    applyGradient(lbl, props.GradFrom or Theme.GradStart, props.GradTo or Theme.GradEnd, props.GradRotation or 0)
    return lbl
end

-- ============================================================
-- PHASE 2: HOVER + RIPPLE EFFECTS
-- ============================================================

local function addHover(frame, hoverBg, hoverTrans, normalBg, normalTrans)
    hoverBg    = hoverBg    or Theme.BgHover
    hoverTrans = hoverTrans or 0.85
    normalBg   = normalBg   or frame.BackgroundColor3
    normalTrans = normalTrans or frame.BackgroundTransparency

    frame.MouseEnter:Connect(function()
        tween(frame, TI_FAST, { BackgroundColor3 = hoverBg, BackgroundTransparency = hoverTrans })
    end)
    frame.MouseLeave:Connect(function()
        tween(frame, TI_FAST, { BackgroundColor3 = normalBg, BackgroundTransparency = normalTrans })
    end)
end

local function addRipple(button)
    button.ClipsDescendants = true
    button.MouseButton1Click:Connect(function()
        pcall(function()
            local mouse = UserInputService:GetMouseLocation()
            local absPos = button.AbsolutePosition
            local relX = mouse.X - absPos.X
            local relY = mouse.Y - absPos.Y
            local maxDim = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2

            local ripple = new("Frame", {
                Name                   = "Ripple",
                BackgroundColor3       = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 0.85,
                AnchorPoint            = Vector2.new(0.5, 0.5),
                Position               = UDim2.new(0, relX, 0, relY),
                Size                   = UDim2.new(0, 0, 0, 0),
                Parent                 = button,
            })
            corner(ripple, UDim.new(1, 0))

            local t = tween(ripple, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, maxDim, 0, maxDim),
                BackgroundTransparency = 1,
            })
            t.Completed:Connect(function() ripple:Destroy() end)
        end)
    end)
end

-- ============================================================
-- PHASE 2: SCROLLING FRAME
-- ============================================================

local function scrollFrame(parent, props)
    props = props or {}
    local sf = new("ScrollingFrame", {
        Name                        = props.Name or "Scroll",
        BackgroundTransparency      = 1,
        Size                        = props.Size or UDim2.new(1, 0, 1, 0),
        Position                    = props.Position or UDim2.new(0, 0, 0, 0),
        CanvasSize                  = props.CanvasSize or UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize         = props.AutoCanvas or Enum.AutomaticSize.Y,
        ScrollBarThickness          = props.BarThickness or 3,
        ScrollBarImageColor3        = props.BarColor or Theme.Primary,
        ScrollBarImageTransparency  = props.BarTrans or 0.5,
        TopImage                    = "rbxassetid://0",
        BottomImage                 = "rbxassetid://0",
        MidImage                    = "rbxasset://textures/ui/Scroll/scroll-middle.png",
        BorderSizePixel             = 0,
        ClipsDescendants            = true,
        Parent                      = parent,
    })
    return sf
end

-- ============================================================
-- PHASE 2: IMAGE ICON HELPERS
-- ============================================================

-- Create an image icon (uses library asset IDs)
local function createIcon(parent, iconId, size, color)
    if not iconId or iconId == "" then return nil end
    local s = size or 16
    local icon = new("ImageLabel", {
        BackgroundTransparency = 1,
        Size                   = UDim2.new(0, s, 0, s),
        Position               = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint            = Vector2.new(0.5, 0.5),
        Image                  = iconId,
        ImageColor3            = color or Color3.new(1, 1, 1),
        ScaleType              = Enum.ScaleType.Fit,
        Parent                 = parent,
    })
    return icon
end

-- Create an icon box (colored bg rounded-xl with image icon)
local function iconBox(parent, iconId, bgColor, size, iconSize)
    size = size or 36
    local box = new("Frame", {
        Name                   = "IconBox",
        BackgroundColor3       = bgColor or Theme.BgCard,
        BackgroundTransparency = 0.5,
        Size                   = UDim2.new(0, size, 0, size),
        Parent                 = parent,
    })
    corner(box, math.floor(size * 0.3))

    -- Soft glow ring bleeding out from behind the icon box for extra depth.
    local glow = new("Frame", {
        Name                   = "Glow",
        BackgroundColor3       = bgColor or Theme.Primary,
        BackgroundTransparency = 0.86,
        Size                   = UDim2.new(1, 12, 1, 12),
        AnchorPoint            = Vector2.new(0.5, 0.5),
        Position               = UDim2.new(0.5, 0, 0.5, 0),
        ZIndex                 = 0,
        Parent                 = box,
    })
    corner(glow, math.floor(size * 0.35))

    local iSize = iconSize or math.floor(size * 0.5)
    local icon = createIcon(box, iconId, iSize, Theme.Text)
    if icon then icon.ZIndex = 1 end

    return box
end

-- ============================================================
-- PHASE 2: PROGRESS BAR
-- ============================================================

local function progressBar(parent, props)
    props = props or {}
    local height = props.Height or 6

    local track = new("Frame", {
        Name                   = props.Name or "ProgressBar",
        BackgroundColor3       = Color3.fromRGB(51, 65, 85),
        BackgroundTransparency = 0,
        Size                   = props.Size or UDim2.new(1, 0, 0, height),
        Position               = props.Position or UDim2.new(0, 0, 0, 0),
        LayoutOrder            = props.Order or 0,
        Parent                 = parent,
    })
    corner(track, UDim.new(1, 0))

    local fill = new("Frame", {
        Name                   = "Fill",
        BackgroundColor3       = Theme.Primary,
        BackgroundTransparency = 0,
        Size                   = UDim2.new(math.clamp(props.Value or 0, 0, 1), 0, 1, 0),
        Parent                 = track,
    })
    corner(fill, UDim.new(1, 0))
    applyGradient(fill, Theme.GradStart, Theme.GradEnd)

    return track, fill
end

-- ============================================================
-- PHASE 2: STATUS DOT
-- ============================================================

local function statusDot(parent, color, size)
    size = size or 8
    local container = new("Frame", {
        Name = "StatusDot",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, size + 6, 0, size + 6),
        Parent = parent,
    })

    -- Glow ring
    new("Frame", {
        Name                   = "Glow",
        BackgroundColor3       = color or Theme.Success,
        BackgroundTransparency = 0.6,
        Size                   = UDim2.new(1, 0, 1, 0),
        AnchorPoint            = Vector2.new(0.5, 0.5),
        Position               = UDim2.new(0.5, 0, 0.5, 0),
        Parent                 = container,
    })
    corner(container:FindFirstChild("Glow"), UDim.new(1, 0))

    -- Solid dot
    new("Frame", {
        Name                   = "Dot",
        BackgroundColor3       = color or Theme.Success,
        BackgroundTransparency = 0,
        Size                   = UDim2.new(0, size, 0, size),
        AnchorPoint            = Vector2.new(0.5, 0.5),
        Position               = UDim2.new(0.5, 0, 0.5, 0),
        Parent                 = container,
    })
    corner(container:FindFirstChild("Dot"), UDim.new(1, 0))

    return container
end

-- ============================================================
-- PHASE 2: DIVIDER + BADGE
-- ============================================================

local function divider(parent, order)
    return new("Frame", {
        Name                   = "Divider",
        BackgroundColor3       = Theme.Border,
        BackgroundTransparency = 0.7,
        Size                   = UDim2.new(1, -16, 0, 1),
        LayoutOrder            = order or 0,
        Parent                 = parent,
    })
end

local function badge(parent, text, color, props)
    props = props or {}
    local bg = new("Frame", {
        Name                   = "Badge",
        BackgroundColor3       = color or Theme.Primary,
        BackgroundTransparency = 0.85,
        Size                   = props.Size or UDim2.new(0, 0, 0, 22),
        AutomaticSize          = Enum.AutomaticSize.X,
        LayoutOrder            = props.Order or 0,
        Parent                 = parent,
    })
    corner(bg, UDim.new(1, 0))
    stroke(bg, color or Theme.Primary, 0.65, 1)
    pad(bg, 2, 2, 10, 10)

    local lbl = label(bg, {
        Text = text, Size = 11, Font = Theme.FontSB, Color = color or Theme.Primary,
        FrameSize = UDim2.new(0, 0, 1, 0), AlignX = Enum.TextXAlignment.Center,
    })
    lbl.AutomaticSize = Enum.AutomaticSize.X

    return bg
end

-- ============================================================
-- PHASE 3: NOTIFICATION SYSTEM (Bottom-Right)
-- ============================================================

local NotificationContainer = new("Frame", {
    Name                   = "Notifications",
    BackgroundTransparency = 1,
    Size                   = UDim2.new(0, 300, 0, 400),
    Position               = UDim2.new(1, -310, 1, -410),
    ZIndex                 = 100,
    Parent                 = ScreenGui,
})
uiList(NotificationContainer, Enum.FillDirection.Vertical, 8,
    Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Bottom)

local activeNotifications = {}

local function notify(title, message, variant, duration)
    variant  = variant or "info"
    duration = duration or 4

    local colors = {
        info    = { accent = Theme.Info,    iconId = Icons.Info },
        success = { accent = Theme.Success, iconId = Icons.Check },
        warning = { accent = Theme.Warning, iconId = Icons.Warning },
        error   = { accent = Theme.Error,   iconId = Icons.X },
    }
    local style = colors[variant] or colors.info

    -- Card container
    local card = glass(NotificationContainer, "card", {
        Name     = "Toast",
        Size     = UDim2.new(1, 0, 0, 72),
        Clip     = true,
        ZIndex   = 100,
    })
    card.BackgroundTransparency = 0.05
    card.Position = UDim2.new(1, 40, 0, 0) -- start off-screen right

    -- Icon badge
    local iconBg = new("Frame", {
        Name                   = "IconBg",
        BackgroundColor3       = style.accent,
        BackgroundTransparency = 0.85,
        Size                   = UDim2.new(0, 34, 0, 34),
        Position               = UDim2.new(0, 14, 0.5, -17),
        ZIndex                 = 101,
        Parent                 = card,
    })
    corner(iconBg, 10)
    createIcon(iconBg, style.iconId, 16, style.accent)

    -- Title
    label(card, {
        Text     = title or "Notification",
        Font     = Theme.FontBold,
        Size     = 13,
        Color    = Theme.Text,
        FrameSize = UDim2.new(1, -70, 0, 18),
        Position  = UDim2.new(0, 56, 0, 14),
        ZIndex   = 101,
    })

    -- Message
    label(card, {
        Text     = message or "",
        Font     = Theme.Font,
        Size     = 11,
        Color    = Theme.TextDim,
        FrameSize = UDim2.new(1, -70, 0, 28),
        Position  = UDim2.new(0, 56, 0, 32),
        Wrap     = true,
        ZIndex   = 101,
    })

    -- Close button
    local closeBtn = new("TextButton", {
        Name                   = "Close",
        BackgroundTransparency = 1,
        Size                   = UDim2.new(0, 24, 0, 24),
        Position               = UDim2.new(1, -28, 0, 4),
        Text                   = "X",
        TextSize               = 12,
        Font                   = Theme.FontBold,
        TextColor3             = Theme.TextMuted,
        ZIndex                 = 102,
        Parent                 = card,
    })

    table.insert(activeNotifications, card)

    -- Slide in
    task.defer(function()
        tween(card, TI_SPRING, { Position = UDim2.new(0, 0, 0, 0) })
    end)

    -- Dismiss
    local dismissed = false
    local function dismiss()
        if dismissed then return end
        dismissed = true
        tween(card, TI_NORMAL, { Position = UDim2.new(1, 40, 0, 0), BackgroundTransparency = 1 })
        task.delay(0.3, function()
            for i, n in ipairs(activeNotifications) do
                if n == card then table.remove(activeNotifications, i); break end
            end
            card:Destroy()
        end)
    end

    closeBtn.MouseButton1Click:Connect(dismiss)
    closeBtn.MouseEnter:Connect(function() tween(closeBtn, TI_FAST, { TextColor3 = Theme.Text }) end)
    closeBtn.MouseLeave:Connect(function() tween(closeBtn, TI_FAST, { TextColor3 = Theme.TextMuted }) end)

    task.delay(duration, dismiss)
    return card
end

-- ============================================================
-- PHASE 4: MAIN WINDOW FRAME (no decorative orbs)
-- ============================================================

local WINDOW_WIDTH  = 620
local WINDOW_HEIGHT = 440
local SIDEBAR_WIDTH = 156
local TOPBAR_HEIGHT = 46

-- Outer wrapper (centered, handles drag)
local WindowWrapper = new("Frame", {
    Name                   = "WindowWrapper",
    BackgroundTransparency = 1,
    Size                   = UDim2.new(0, WINDOW_WIDTH + 4, 0, WINDOW_HEIGHT + 4),
    Position               = UDim2.new(0.5, 0, 0.5, 0),
    AnchorPoint            = Vector2.new(0.5, 0.5),
    Visible                = false,
    Parent                 = ScreenGui,
})

-- Main glass panel
local Window = glass(WindowWrapper, "window", {
    Name     = "MainWindow",
    Size     = UDim2.new(1, 0, 1, 0),
    Position = UDim2.new(0, 0, 0, 0),
    Radius   = Theme.R_2XL,
    Clip     = true,
})

-- ============================================================
-- PHASE 4: DRAGGING
-- ============================================================

local dragging, dragStart, startPos = false, nil, nil

local function onDragStart(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or
       input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = WindowWrapper.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end

local function onDragMove(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or
                     input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        tween(WindowWrapper, TI_FAST, {
            Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        })
    end
end

-- ============================================================
-- PHASE 4: TOP BAR
-- ============================================================

local TopBar = glass(Window, "topbar", {
    Name     = "TopBar",
    Size     = UDim2.new(1, -16, 0, TOPBAR_HEIGHT),
    Position = UDim2.new(0, 8, 0, 8),
    Radius   = Theme.R_LG,
    ZIndex   = 10,
})
TopBar.BackgroundTransparency = 0.12

-- Make topbar draggable
TopBar.InputBegan:Connect(onDragStart)
UserInputService.InputChanged:Connect(onDragMove)

-- Left side
local TopBarLeft = new("Frame", {
    Name = "Left", BackgroundTransparency = 1,
    Size = UDim2.new(0.5, 0, 1, 0), ZIndex = 11, Parent = TopBar,
})

-- Brand icon (full logo image)
local brandIcon = new("ImageLabel", {
    Name                   = "BrandIcon",
    BackgroundTransparency = 1,
    Size                   = UDim2.new(0, 28, 0, 28),
    Position               = UDim2.new(0, 12, 0.5, -14),
    Image                  = LogoImage,
    ScaleType              = Enum.ScaleType.Fit,
    ZIndex                 = 12,
    Parent                 = TopBarLeft,
})

-- Gradient title
local titleLabel = gradientLabel(TopBarLeft, {
    Text      = "Reconnect",
    Font      = Theme.FontBold,
    Size      = 16,
    FrameSize = UDim2.new(0, 100, 1, 0),
    Position  = UDim2.new(0, 50, 0, 0),
    AlignX    = Enum.TextXAlignment.Left,
})
titleLabel.ZIndex = 12

-- Version badge
local versionBadge = badge(TopBarLeft, "v" .. VERSION, Theme.Primary, {
    Size = UDim2.new(0, 0, 0, 18),
})
versionBadge.Position = UDim2.new(0, 155, 0.5, -9)
versionBadge.ZIndex   = 12

-- Center: Status
local TopBarCenter = new("Frame", {
    Name = "Center", BackgroundTransparency = 1,
    Size = UDim2.new(0, 200, 1, 0),
    Position = UDim2.new(0.5, -100, 0, 0),
    ZIndex = 11, Parent = TopBar,
})

local statusContainer = new("Frame", {
    Name = "StatusContainer", BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 1, 0), ZIndex = 12, Parent = TopBarCenter,
})

local topStatusDot = statusDot(statusContainer, Theme.Success, 7)
topStatusDot.Position   = UDim2.new(0.5, -60, 0.5, -7)
topStatusDot.ZIndex     = 12

local topStatusLabel = label(statusContainer, {
    Text     = "Running",
    Font     = Theme.FontMed,
    Size     = 12,
    Color    = Theme.TextSub,
    FrameSize = UDim2.new(0, 120, 1, 0),
    Position  = UDim2.new(0.5, -42, 0, 0),
    AlignX   = Enum.TextXAlignment.Left,
    ZIndex   = 12,
})

-- Right side: Window controls
local TopBarRight = new("Frame", {
    Name = "Right", BackgroundTransparency = 1,
    Size = UDim2.new(0, 80, 1, 0),
    Position = UDim2.new(1, -80, 0, 0),
    ZIndex = 11, Parent = TopBar,
})

-- Minimize button (simple dash text)
local minBtn = new("TextButton", {
    Name = "Minimize",
    BackgroundColor3 = Theme.BgCard, BackgroundTransparency = 0.6,
    Size = UDim2.new(0, 30, 0, 30),
    Position = UDim2.new(0, 8, 0.5, -15),
    Text = "-", TextSize = 18, Font = Theme.FontBold,
    TextColor3 = Theme.TextDim, ZIndex = 12,
    AutoButtonColor = false, Parent = TopBarRight,
})
corner(minBtn, 8)

-- Close button (simple X text)
local closeWindowBtn = new("TextButton", {
    Name = "Close",
    BackgroundColor3 = Color3.fromRGB(127, 29, 29), BackgroundTransparency = 0.7,
    Size = UDim2.new(0, 30, 0, 30),
    Position = UDim2.new(0, 42, 0.5, -15),
    Text = "X", TextSize = 13, Font = Theme.FontBold,
    TextColor3 = Theme.TextDim, ZIndex = 12,
    AutoButtonColor = false, Parent = TopBarRight,
})
corner(closeWindowBtn, 8)

-- Hover effects for controls
minBtn.MouseEnter:Connect(function()
    tween(minBtn, TI_FAST, { BackgroundTransparency = 0.3, TextColor3 = Theme.Text })
end)
minBtn.MouseLeave:Connect(function()
    tween(minBtn, TI_FAST, { BackgroundTransparency = 0.6, TextColor3 = Theme.TextDim })
end)
closeWindowBtn.MouseEnter:Connect(function()
    tween(closeWindowBtn, TI_FAST, { BackgroundTransparency = 0.3, BackgroundColor3 = Theme.Error, TextColor3 = Theme.Text })
end)
closeWindowBtn.MouseLeave:Connect(function()
    tween(closeWindowBtn, TI_FAST, { BackgroundTransparency = 0.7, BackgroundColor3 = Color3.fromRGB(127, 29, 29), TextColor3 = Theme.TextDim })
end)

-- ============================================================
-- PHASE 4: WINDOW SHOW/HIDE
-- ============================================================

local windowOpen = false

local function showWindow()
    if windowOpen then return end
    windowOpen = true
    WindowWrapper.Visible = true
    Window.Size = UDim2.new(1, 0, 1, 0)
    Window.Position = UDim2.new(0, 0, 0, 0)
    Window.BackgroundTransparency = Theme.GlassWindow
end

local function hideWindow()
    if not windowOpen then return end
    windowOpen = false
    WindowWrapper.Visible = false
end

minBtn.MouseButton1Click:Connect(hideWindow)
closeWindowBtn.MouseButton1Click:Connect(hideWindow)
addRipple(minBtn)
addRipple(closeWindowBtn)

-- ============================================================
-- PHASE 5: SIDEBAR
-- ============================================================

local Sidebar = glass(Window, "sidebar", {
    Name     = "Sidebar",
    Size     = UDim2.new(0, SIDEBAR_WIDTH, 1, -(TOPBAR_HEIGHT + 20)),
    Position = UDim2.new(0, 8, 0, TOPBAR_HEIGHT + 14),
    Radius   = Theme.R_LG,
    ZIndex   = 5,
})
pad(Sidebar, 8, 8, 6, 6)

local SidebarScroll = scrollFrame(Sidebar, {
    Name       = "SidebarScroll",
    Size       = UDim2.new(1, 0, 1, -70),
    BarThickness = 0,
})
SidebarScroll.ZIndex = 6

uiList(SidebarScroll, Enum.FillDirection.Vertical, 2)
pad(SidebarScroll, 4, 4, 2, 2)

-- ============================================================
-- PHASE 5: SIDEBAR NAV ITEMS
-- ============================================================

local tabs = {}
local currentTab = nil

local function addSidebarSection(text, order)
    local header = label(SidebarScroll, {
        Text      = text,
        Font      = Theme.FontBold,
        Size      = 10,
        Color     = Theme.TextMuted,
        FrameSize = UDim2.new(1, 0, 0, 24),
        AlignX    = Enum.TextXAlignment.Left,
        Order     = order,
    })
    pad(header, 6, 2, 10, 0)
    return header
end

-- Sidebar nav item with IMAGE icon
local function addSidebarItem(name, iconId, order)
    local item = new("TextButton", {
        Name                   = "Nav_" .. name,
        BackgroundColor3       = Theme.ActiveBg,
        BackgroundTransparency = 1,
        Size                   = UDim2.new(1, 0, 0, 36),
        Text                   = "",
        AutoButtonColor        = false,
        LayoutOrder            = order,
        ZIndex                 = 7,
        Parent                 = SidebarScroll,
    })
    corner(item, 10)

    -- Left accent bar — only visible while this tab is active
    local accentBar = new("Frame", {
        Name                   = "Accent",
        BackgroundColor3       = Theme.Primary,
        BackgroundTransparency = 1,
        Size                   = UDim2.new(0, 3, 0, 0),
        Position               = UDim2.new(0, 0, 0.5, 0),
        AnchorPoint            = Vector2.new(0, 0.5),
        BorderSizePixel        = 0,
        ZIndex                 = 9,
        Parent                 = item,
    })
    corner(accentBar, UDim.new(1, 0))

    -- Icon (ImageLabel)
    local iconFrame = new("Frame", {
        Name = "IconFrame",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 28, 0, 36),
        Position = UDim2.new(0, 10, 0, 0),
        ZIndex = 8,
        Parent = item,
    })
    local iconImg = createIcon(iconFrame, iconId, 16, Theme.TextDim)
    if iconImg then iconImg.ZIndex = 8 end

    -- Label
    local textLabel = new("TextLabel", {
        Name                   = "Label",
        BackgroundTransparency = 1,
        Size                   = UDim2.new(1, -48, 0, 36),
        Position               = UDim2.new(0, 40, 0, 0),
        Text                   = name,
        TextSize               = 13,
        Font                   = Theme.FontMed,
        TextColor3             = Theme.TextDim,
        TextXAlignment         = Enum.TextXAlignment.Left,
        TextTruncate           = Enum.TextTruncate.AtEnd,
        ZIndex                 = 8,
        Parent                 = item,
    })

    -- Hover
    item.MouseEnter:Connect(function()
        if currentTab ~= name then
            tween(item, TI_FAST, { BackgroundTransparency = 0.9 })
        end
    end)
    item.MouseLeave:Connect(function()
        if currentTab ~= name then
            tween(item, TI_FAST, { BackgroundTransparency = 1 })
        end
    end)

    table.insert(tabs, {
        name    = name,
        button  = item,
        iconImg = iconImg,
        textLbl = textLabel,
        accent  = accentBar,
        page    = nil,
    })

    return item
end

-- Build sidebar navigation
addSidebarSection("MAIN", 1)
addSidebarItem("Dashboard", Icons.Home, 2)
addSidebarItem("Protection", Icons.Shield, 3)

addSidebarSection("SYSTEM", 10)
addSidebarItem("Performance", Icons.Zap, 11)
addSidebarItem("Settings", Icons.Settings, 12)

-- ============================================================
-- PHASE 5: TAB SWITCHING
-- ============================================================

local function switchTab(name)
    if currentTab == name then return end
    currentTab = name

    for _, tab in ipairs(tabs) do
        local isActive = (tab.name == name)

        if isActive then
            tween(tab.button, TI_NORMAL, { BackgroundTransparency = Theme.ActiveBgTrans })
            if tab.iconImg then
                tween(tab.iconImg, TI_NORMAL, { ImageColor3 = Theme.Primary })
            end
            tween(tab.textLbl, TI_NORMAL, { TextColor3 = Theme.Text })
            if tab.accent then
                tween(tab.accent, TI_SPRING, { BackgroundTransparency = 0, Size = UDim2.new(0, 3, 0, 18) })
            end
        else
            tween(tab.button, TI_NORMAL, { BackgroundTransparency = 1 })
            if tab.iconImg then
                tween(tab.iconImg, TI_NORMAL, { ImageColor3 = Theme.TextDim })
            end
            tween(tab.textLbl, TI_NORMAL, { TextColor3 = Theme.TextDim })
            if tab.accent then
                tween(tab.accent, TI_NORMAL, { BackgroundTransparency = 1, Size = UDim2.new(0, 3, 0, 0) })
            end
        end

        if tab.page then
            tab.page.Visible = isActive
        end
    end
end

for _, tab in ipairs(tabs) do
    tab.button.MouseButton1Click:Connect(function()
        switchTab(tab.name)
    end)
end

-- ============================================================
-- PHASE 5: PLAYER INFO CARD
-- ============================================================

local PlayerCard = new("Frame", {
    Name                   = "PlayerCard",
    BackgroundColor3       = Theme.BgCard,
    BackgroundTransparency = 0.7,
    Size                   = UDim2.new(1, -12, 0, 56),
    Position               = UDim2.new(0, 6, 1, -62),
    ZIndex                 = 6,
    Parent                 = Sidebar,
})
corner(PlayerCard, 12)
stroke(PlayerCard, Theme.Border, 0.7)

-- Avatar
local avatarFrame = new("Frame", {
    Name = "Avatar",
    BackgroundColor3 = Theme.BgElevated, BackgroundTransparency = 0,
    Size = UDim2.new(0, 34, 0, 34),
    Position = UDim2.new(0, 8, 0.5, -17),
    ZIndex = 7, Parent = PlayerCard,
})
corner(avatarFrame, UDim.new(1, 0))

pcall(function()
    local thumbUrl = Players:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
    local img = new("ImageLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Image = thumbUrl, ZIndex = 8, Parent = avatarFrame,
    })
    corner(img, UDim.new(1, 0))
end)

-- Fallback initial
new("TextLabel", {
    Name = "Initial", BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 1, 0),
    Text = LP.DisplayName:sub(1, 1):upper(),
    TextSize = 16, Font = Theme.FontBold,
    TextColor3 = Theme.Primary, ZIndex = 7, Parent = avatarFrame,
})

-- Display name (fixed: no chained .ZIndex)
local dispNameLbl = label(PlayerCard, {
    Text      = LP.DisplayName,
    Font      = Theme.FontSB,
    Size      = 12,
    Color     = Theme.Text,
    FrameSize = UDim2.new(1, -56, 0, 16),
    Position  = UDim2.new(0, 48, 0, 12),
    ZIndex    = 7,
})

-- Username
local userNameLbl = label(PlayerCard, {
    Text      = "@" .. LP.Name,
    Font      = Theme.Font,
    Size      = 10,
    Color     = Theme.TextMuted,
    FrameSize = UDim2.new(1, -56, 0, 14),
    Position  = UDim2.new(0, 48, 0, 30),
    ZIndex    = 7,
})

-- Online dot
local playerDot = statusDot(PlayerCard, Theme.Success, 6)
playerDot.Position = UDim2.new(0, 34, 0, 6)
playerDot.ZIndex   = 9

-- ============================================================
-- PHASE 6: CONTENT AREA & PAGE SYSTEM
-- ============================================================

local ContentArea = new("Frame", {
    Name                   = "ContentArea",
    BackgroundTransparency = 1,
    Size                   = UDim2.new(1, -(SIDEBAR_WIDTH + 22), 1, -(TOPBAR_HEIGHT + 20)),
    Position               = UDim2.new(0, SIDEBAR_WIDTH + 14, 0, TOPBAR_HEIGHT + 14),
    ClipsDescendants       = true,
    ZIndex                 = 5,
    Parent                 = Window,
})

local function createPage(tabName)
    local page = scrollFrame(ContentArea, {
        Name         = tabName .. "Page",
        Size         = UDim2.new(1, 0, 1, 0),
        BarThickness = 3,
        BarColor     = Theme.Primary,
        BarTrans     = 0.6,
    })
    page.Visible = false
    page.ZIndex  = 6

    uiList(page, Enum.FillDirection.Vertical, 12)
    pad(page, 4, 12, 4, 8)

    for _, tab in ipairs(tabs) do
        if tab.name == tabName then
            tab.page = page
            break
        end
    end

    return page
end

local DashboardPage   = createPage("Dashboard")
local ProtectionPage  = createPage("Protection")
local PerformancePage = createPage("Performance")
local SettingsPage    = createPage("Settings")

-- ============================================================
-- PHASE 6: PAGE HEADER + SECTION + STAT CARD
-- ============================================================

local function addPageHeader(page, title, subtitle, order)
    local header = new("Frame", {
        Name = "PageHeader", BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, subtitle and 52 or 32),
        LayoutOrder = order or 0, Parent = page,
    })
    gradientLabel(header, {
        Text = title, Font = Theme.FontBold, Size = 20,
        FrameSize = UDim2.new(1, 0, 0, 26), AlignX = Enum.TextXAlignment.Left,
    })
    if subtitle then
        label(header, {
            Text = subtitle, Font = Theme.Font, Size = 12, Color = Theme.TextDim,
            FrameSize = UDim2.new(1, 0, 0, 18), Position = UDim2.new(0, 0, 0, 30),
            AlignX = Enum.TextXAlignment.Left,
        })
    end
    return header
end

local function addSection(page, title, props)
    props = props or {}
    local section = glass(page, "card", {
        Name   = props.Name or "Section",
        Size   = UDim2.new(1, 0, 0, props.Height or 0),
        Order  = props.Order or 0,
        Radius = Theme.R_LG,
    })
    if props.Height == 0 or not props.Height then
        section.AutomaticSize = Enum.AutomaticSize.Y
    end
    pad(section, 16, 16, 16, 16)
    uiList(section, Enum.FillDirection.Vertical, props.Spacing or 10)
    if title then
        label(section, {
            Text = title, Font = Theme.FontBold, Size = 14, Color = Theme.Text,
            FrameSize = UDim2.new(1, 0, 0, 22), AlignX = Enum.TextXAlignment.Left, Order = 0,
        })
    end
    return section
end

-- Stat card with image icon (fixed text positioning)
local function addStatCard(parent, props)
    props = props or {}
    local card = new("Frame", {
        Name = props.Name or "StatCard",
        BackgroundColor3 = Color3.fromRGB(51, 65, 85),
        BackgroundTransparency = 0.8,
        Size = props.Size or UDim2.new(0.48, 0, 0, 80),
        LayoutOrder = props.Order or 0,
        Parent = parent,
    })
    corner(card, 12)

    -- Icon (top-left, image-based)
    if props.Icon then
        local ib = new("Frame", {
            Name = "IconBg",
            BackgroundColor3 = props.IconColor or Theme.Primary,
            BackgroundTransparency = 0.85,
            Size = UDim2.new(0, 28, 0, 28),
            Position = UDim2.new(0, 10, 0, 10),
            Parent = card,
        })
        corner(ib, 8)
        createIcon(ib, props.Icon, 14, props.IconColor or Theme.Primary)
    end

    -- Value (below icon with spacing)
    local valueLbl = label(card, {
        Text = props.Value or "0",
        Font = Theme.FontBold,
        Size = 22,
        Color = Theme.Text,
        FrameSize = UDim2.new(1, -16, 0, 26),
        Position = UDim2.new(0, 10, 0, props.Icon and 44 or 10),
        AlignX = Enum.TextXAlignment.Left,
    })

    -- Label (at bottom with clear gap from value)
    local descLbl = label(card, {
        Text = props.Label or "",
        Font = Theme.FontMed,
        Size = 11,
        Color = Theme.TextSub,
        FrameSize = UDim2.new(1, -16, 0, 14),
        Position = UDim2.new(0, 10, 1, -22),
        AlignX = Enum.TextXAlignment.Left,
    })

    return card, valueLbl, descLbl
end

local function addStatsRow(page, order)
    local row = new("Frame", {
        Name = "StatsRow", BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = order or 0, Parent = page,
    })
    new("UIGridLayout", {
        CellSize      = UDim2.new(0.48, 0, 0, 94),
        CellPadding   = UDim2.new(0.04, 0, 0, 8),
        FillDirection  = Enum.FillDirection.Horizontal,
        SortOrder      = Enum.SortOrder.LayoutOrder,
        Parent         = row,
    })
    return row
end

-- Set default tab
switchTab("Dashboard")

-- ============================================================
-- PHASE 7: TOGGLE SWITCH
-- ============================================================

local function addToggle(parent, props)
    props = props or {}
    local enabled = props.Default or false
    local TRACK_W, TRACK_H = 44, 24
    local KNOB_SIZE, KNOB_PAD = 18, 3

    local row = new("Frame", {
        Name = props.Name or "ToggleRow", BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 40),
        LayoutOrder = props.Order or 0, Parent = parent,
    })

    -- Icon (image-based)
    if props.Icon then
        local ib = iconBox(row, props.Icon, props.IconColor or Theme.BgCard, 32, 14)
        ib.Position = UDim2.new(0, 0, 0.5, -16)
    end

    local labelOffset = props.Icon and 40 or 0
    label(row, {
        Text = props.Label or "Toggle", Font = Theme.FontMed, Size = 13, Color = Theme.Text,
        FrameSize = UDim2.new(1, -(TRACK_W + labelOffset + 16), 0, 20),
        Position = UDim2.new(0, labelOffset, 0, 4),
    })

    if props.Desc then
        label(row, {
            Text = props.Desc, Font = Theme.Font, Size = 11, Color = Theme.TextMuted,
            FrameSize = UDim2.new(1, -(TRACK_W + labelOffset + 16), 0, 16),
            Position = UDim2.new(0, labelOffset, 0, 22),
        })
        row.Size = UDim2.new(1, 0, 0, 48)
    end

    local track = new("TextButton", {
        Name = "Track",
        BackgroundColor3 = enabled and Theme.ToggleOn or Theme.ToggleOff,
        BackgroundTransparency = 0,
        Size = UDim2.new(0, TRACK_W, 0, TRACK_H),
        Position = UDim2.new(1, -TRACK_W, 0.5, -TRACK_H / 2),
        Text = "", AutoButtonColor = false, Parent = row,
    })
    corner(track, UDim.new(1, 0))

    local knob = new("Frame", {
        Name = "Knob",
        BackgroundColor3 = Theme.ToggleKnob, BackgroundTransparency = 0,
        Size = UDim2.new(0, KNOB_SIZE, 0, KNOB_SIZE),
        Position = enabled
            and UDim2.new(1, -(KNOB_SIZE + KNOB_PAD), 0.5, -KNOB_SIZE / 2)
            or  UDim2.new(0, KNOB_PAD, 0.5, -KNOB_SIZE / 2),
        Parent = track,
    })
    corner(knob, UDim.new(1, 0))

    local function setToggle(state, silent)
        enabled = state
        tween(track, TI_SPRING, { BackgroundColor3 = enabled and Theme.ToggleOn or Theme.ToggleOff })
        tween(knob, TI_SPRING, {
            Position = enabled
                and UDim2.new(1, -(KNOB_SIZE + KNOB_PAD), 0.5, -KNOB_SIZE / 2)
                or  UDim2.new(0, KNOB_PAD, 0.5, -KNOB_SIZE / 2)
        })
        if not silent and props.Callback then props.Callback(enabled) end
    end

    track.MouseButton1Click:Connect(function() setToggle(not enabled) end)
    return row, setToggle, function() return enabled end
end

-- ============================================================
-- PHASE 7: BUTTON COMPONENT
-- ============================================================

local function addButton(parent, props)
    props = props or {}
    local variant = props.Variant or "primary"

    local styles = {
        primary   = { bg = Theme.Primary,                     trans = 0,    text = Color3.fromRGB(10, 10, 20), font = Theme.FontBold, border = false },
        secondary = { bg = Color3.fromRGB(51, 65, 85),        trans = 0.5,  text = Theme.TextSub,              font = Theme.FontMed,  border = true },
        danger    = { bg = Theme.Error,                        trans = 0.8,  text = Theme.Error,                font = Theme.FontMed,  border = true, borderColor = Theme.Error },
        ghost     = { bg = Theme.BgCard,                       trans = 1,    text = Theme.TextDim,              font = Theme.FontMed,  border = false },
        success   = { bg = Theme.Success,                      trans = 0.8,  text = Theme.Success,              font = Theme.FontMed,  border = true, borderColor = Theme.Success },
    }
    local s = styles[variant] or styles.primary

    local btn = new("TextButton", {
        Name = props.Name or "Button",
        BackgroundColor3 = s.bg, BackgroundTransparency = s.trans,
        Size = props.Size or UDim2.new(0, 140, 0, 34),
        Position = props.Position or UDim2.new(0, 0, 0, 0),
        Text = props.Text or "Button",
        TextSize = props.TextSize or 12,
        Font = s.font, TextColor3 = s.text,
        AutoButtonColor = false,
        LayoutOrder = props.Order or 0, Parent = parent,
    })
    corner(btn, props.Radius or 10)

    if s.border then stroke(btn, s.borderColor or Theme.Border, 0.5) end
    if variant == "primary" then applyGradient(btn, Theme.GradStart, Theme.GradEnd) end

    -- Add image icon to the left of text if provided
    if props.Icon then
        local iconImg = createIcon(btn, props.Icon, 14, s.text)
        if iconImg then
            iconImg.Position = UDim2.new(0, 12, 0.5, 0)
            iconImg.AnchorPoint = Vector2.new(0, 0.5)
            iconImg.ZIndex = 2
        end
        -- Shift text right to accommodate icon
        btn.TextXAlignment = Enum.TextXAlignment.Center
        pad(btn, 0, 0, 24, 0)
    end

    btn.MouseEnter:Connect(function()
        tween(btn, TI_FAST, { BackgroundTransparency = math.max(0, s.trans - 0.15) })
    end)
    btn.MouseLeave:Connect(function()
        tween(btn, TI_FAST, { BackgroundTransparency = s.trans })
    end)
    addRipple(btn)
    if props.Callback then btn.MouseButton1Click:Connect(props.Callback) end
    return btn
end

-- ============================================================
-- PHASE 7: DROPDOWN (Fixed: popup on ScreenGui, high ZIndex)
-- ============================================================

local function addDropdown(parent, props)
    props = props or {}
    local options  = props.Options or {"Option 1", "Option 2"}
    local selected = props.Default or options[1]
    local isOpen   = false

    local row = new("Frame", {
        Name = props.Name or "DropdownRow", BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 40),
        LayoutOrder = props.Order or 0, ZIndex = 20, Parent = parent,
    })

    if props.Label then
        label(row, {
            Text = props.Label, Font = Theme.FontMed, Size = 13, Color = Theme.Text,
            FrameSize = UDim2.new(0.5, 0, 1, 0), AlignX = Enum.TextXAlignment.Left,
        })
    end

    local trigger = new("TextButton", {
        Name = "Trigger",
        BackgroundColor3 = Color3.fromRGB(51, 65, 85), BackgroundTransparency = 0.7,
        Size = UDim2.new(0, 150, 0, 32),
        Position = UDim2.new(1, -150, 0.5, -16),
        Text = "", AutoButtonColor = false, ZIndex = 21, Parent = row,
    })
    corner(trigger, 8)
    stroke(trigger, Color3.fromRGB(71, 85, 105), 0.7)

    local selectedLabel = label(trigger, {
        Text = selected, Font = Theme.FontMed, Size = 12, Color = Theme.TextSub,
        FrameSize = UDim2.new(1, -28, 1, 0), Position = UDim2.new(0, 10, 0, 0),
        AlignX = Enum.TextXAlignment.Left, ZIndex = 22,
    })

    local chevron = label(trigger, {
        Text = "v", Font = Theme.FontBold, Size = 10, Color = Theme.TextMuted,
        FrameSize = UDim2.new(0, 20, 1, 0), Position = UDim2.new(1, -22, 0, 0),
        AlignX = Enum.TextXAlignment.Center, ZIndex = 22,
    })

    -- Popup parented to ScreenGui to avoid clipping
    local popup = glass(ScreenGui, "overlay", {
        Name     = "DropdownPopup",
        Size     = UDim2.new(0, 150, 0, #options * 30 + 8),
        Position = UDim2.new(0, 0, 0, 0),
        Radius   = Theme.R_MD,
        ZIndex   = 500,
        Visible  = false,
    })
    popup.BackgroundTransparency = 0.02
    pad(popup, 4, 4, 4, 4)
    uiList(popup, Enum.FillDirection.Vertical, 2)

    local optionButtons = {}

    for i, opt in ipairs(options) do
        local optBtn = new("TextButton", {
            Name = "Opt_" .. opt,
            BackgroundColor3 = Theme.ActiveBg,
            BackgroundTransparency = (opt == selected) and Theme.ActiveBgTrans or 1,
            Size = UDim2.new(1, 0, 0, 28),
            Text = opt, TextSize = 12,
            Font = (opt == selected) and Theme.FontSB or Theme.Font,
            TextColor3 = (opt == selected) and Theme.Text or Theme.TextSub,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutoButtonColor = false, LayoutOrder = i,
            ZIndex = 501, Parent = popup,
        })
        corner(optBtn, 6)
        pad(optBtn, 0, 0, 10, 0)
        table.insert(optionButtons, optBtn)

        optBtn.MouseEnter:Connect(function()
            if opt ~= selected then tween(optBtn, TI_FAST, { BackgroundTransparency = 0.9 }) end
        end)
        optBtn.MouseLeave:Connect(function()
            if opt ~= selected then tween(optBtn, TI_FAST, { BackgroundTransparency = 1 }) end
        end)

        optBtn.MouseButton1Click:Connect(function()
            selected = opt
            selectedLabel.Text = opt
            for _, child in ipairs(optionButtons) do
                local isThis = (child.Text == opt)
                tween(child, TI_FAST, {
                    BackgroundTransparency = isThis and Theme.ActiveBgTrans or 1,
                    TextColor3 = isThis and Theme.Text or Theme.TextSub,
                })
                child.Font = isThis and Theme.FontSB or Theme.Font
            end
            isOpen = false
            popup.Visible = false
            chevron.Text = "v"
            if props.Callback then props.Callback(opt) end
        end)
    end

    -- Toggle popup and position it at trigger's absolute position
    trigger.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            local absPos = trigger.AbsolutePosition
            local absSize = trigger.AbsoluteSize
            popup.Position = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y + 4)
            popup.Size = UDim2.new(0, absSize.X, 0, #options * 30 + 8)
        end
        popup.Visible = isOpen
        chevron.Text = isOpen and "^" or "v"
    end)

    -- Close popup when clicking elsewhere
    local closeConn
    closeConn = UserInputService.InputBegan:Connect(function(input)
        if not isOpen then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            task.defer(function()
                if isOpen then
                    local mouse = UserInputService:GetMouseLocation()
                    local pPos = popup.AbsolutePosition
                    local pSize = popup.AbsoluteSize
                    local tPos = trigger.AbsolutePosition
                    local tSize = trigger.AbsoluteSize
                    -- Check if click is outside both popup and trigger
                    local inPopup = mouse.X >= pPos.X and mouse.X <= pPos.X + pSize.X and
                                    mouse.Y >= pPos.Y and mouse.Y <= pPos.Y + pSize.Y
                    local inTrigger = mouse.X >= tPos.X and mouse.X <= tPos.X + tSize.X and
                                      mouse.Y >= tPos.Y and mouse.Y <= tPos.Y + tSize.Y
                    if not inPopup and not inTrigger then
                        isOpen = false
                        popup.Visible = false
                        chevron.Text = "v"
                    end
                end
            end)
        end
    end)

    return row, function() return selected end
end

-- ============================================================
-- PHASE 7: SETTING ROW + INFO ROW + QUICK ACTION
-- ============================================================

local function addSettingRow(parent, props)
    props = props or {}
    local row = new("TextButton", {
        Name = props.Name or "SettingRow",
        BackgroundColor3 = Theme.BgCard, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 52), Text = "",
        AutoButtonColor = false, LayoutOrder = props.Order or 0, Parent = parent,
    })
    corner(row, 10)
    addHover(row, Theme.BgCard, 0.5, Theme.BgCard, 1)

    if props.Icon then
        local ib = iconBox(row, props.Icon, props.IconColor or Theme.BgCard, 38, 16)
        ib.Position = UDim2.new(0, 8, 0.5, -19)
    end

    label(row, {
        Text = props.Label or "Setting", Font = Theme.FontMed, Size = 13, Color = Theme.Text,
        FrameSize = UDim2.new(1, -82, 0, 18), Position = UDim2.new(0, 54, 0, 8),
    })

    if props.Desc then
        label(row, {
            Text = props.Desc, Font = Theme.Font, Size = 11, Color = Theme.TextMuted,
            FrameSize = UDim2.new(1, -82, 0, 16), Position = UDim2.new(0, 54, 0, 28),
        })
    end

    -- Right chevron (simple text)
    label(row, {
        Text = ">", Font = Theme.FontBold, Size = 16, Color = Theme.TextMuted,
        FrameSize = UDim2.new(0, 20, 1, 0), Position = UDim2.new(1, -28, 0, 0),
        AlignX = Enum.TextXAlignment.Center,
    })

    if props.Callback then row.MouseButton1Click:Connect(props.Callback) end
    addRipple(row)
    return row
end

local function addInfoRow(parent, props)
    props = props or {}
    local row = new("Frame", {
        Name = props.Name or "InfoRow", BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 26),
        LayoutOrder = props.Order or 0, Parent = parent,
    })

    label(row, {
        Text = props.Label or "Label", Font = Theme.Font, Size = 12, Color = Theme.TextDim,
        FrameSize = UDim2.new(0.5, 0, 1, 0),
    })

    local valueLbl = label(row, {
        Text = props.Value or "--", Font = Theme.FontMed, Size = 12,
        Color = props.ValueColor or Theme.Text,
        FrameSize = UDim2.new(0.5, 0, 1, 0), Position = UDim2.new(0.5, 0, 0, 0),
        AlignX = Enum.TextXAlignment.Right,
    })

    return row, valueLbl
end

local function addQuickAction(parent, props)
    props = props or {}
    local card = new("TextButton", {
        Name = props.Name or "QuickAction",
        BackgroundColor3 = Theme.BgCard, BackgroundTransparency = Theme.GlassCard,
        Size = props.Size or UDim2.new(1, 0, 0, 80),
        Text = "", AutoButtonColor = false,
        LayoutOrder = props.Order or 0, Parent = parent,
    })
    corner(card, 14)
    stroke(card, Theme.Border, Theme.BorderTrans)

    local ib = iconBox(card, props.Icon, props.IconColor or Theme.Primary, 36, 16)
    ib.Position = UDim2.new(0, 12, 0, 12)

    label(card, {
        Text = props.Label or "Action", Font = Theme.FontSB, Size = 13, Color = Theme.Text,
        FrameSize = UDim2.new(1, -24, 0, 18), Position = UDim2.new(0, 12, 0, 54),
    })

    addHover(card, Theme.BgCardHover, Theme.GlassCard - 0.05, Theme.BgCard, Theme.GlassCard)
    addRipple(card)
    if props.Callback then card.MouseButton1Click:Connect(props.Callback) end
    return card
end

-- ============================================================
-- PHASE 8A: DASHBOARD TAB
-- ============================================================

-- Welcome Card (clean, no decorative orbs)
local welcomeCard = glass(DashboardPage, "card", {
    Name = "WelcomeCard", Size = UDim2.new(1, 0, 0, 72),
    Order = 1, Clip = true,
})

gradientLabel(welcomeCard, {
    Text = "Welcome back, " .. LP.DisplayName,
    Font = Theme.FontBold, Size = 17,
    FrameSize = UDim2.new(1, -32, 0, 22),
    Position = UDim2.new(0, 16, 0, 14),
})

label(welcomeCard, {
    Text = "Reconnect v" .. VERSION .. " is active and monitoring your session.",
    Font = Theme.Font, Size = 12, Color = Theme.TextSub,
    FrameSize = UDim2.new(1, -32, 0, 16),
    Position = UDim2.new(0, 16, 0, 40),
})

-- Stats Grid (2x2)
local statsRow = addStatsRow(DashboardPage, 2)

local _, fpsValueLbl = addStatCard(statsRow, {
    Name = "FPS", Icon = Icons.Target, IconColor = Theme.Primary,
    Value = "0", Label = "FPS", Order = 1,
})

local _, pingValueLbl = addStatCard(statsRow, {
    Name = "Ping", Icon = Icons.Ping, IconColor = Theme.Info,
    Value = "0 ms", Label = "Ping", Order = 2,
})

local _, memValueLbl = addStatCard(statsRow, {
    Name = "Memory", Icon = Icons.Memory, IconColor = Theme.Warning,
    Value = "0 MB", Label = "Memory", Order = 3,
})

local _, uptimeValueLbl = addStatCard(statsRow, {
    Name = "Uptime", Icon = Icons.Clock, IconColor = Theme.Success,
    Value = "0s", Label = "Uptime", Order = 4,
})

-- Session Info
local sessionSection = addSection(DashboardPage, "Session Details", { Order = 3, Spacing = 6 })

local _, sessionPlaceLbl     = addInfoRow(sessionSection, { Label = "Game",       Value = "Loading...",  Order = 1 })
local _, sessionJobLbl       = addInfoRow(sessionSection, { Label = "Server ID",  Value = "--",          Order = 2 })
local _, sessionPlayersLbl   = addInfoRow(sessionSection, { Label = "Players",    Value = "0",           Order = 3 })
local _, sessionPingsLbl     = addInfoRow(sessionSection, { Label = "Total Pings",Value = "0",           Order = 4 })
local _, sessionFailedLbl    = addInfoRow(sessionSection, { Label = "Failed",     Value = "0",           Order = 5, ValueColor = Theme.Error })
local _, sessionReconnectsLbl = addInfoRow(sessionSection, { Label = "Reconnects", Value = "0",          Order = 6 })

-- Quick Actions
label(DashboardPage, {
    Text = "Quick Actions", Font = Theme.FontBold, Size = 14, Color = Theme.Text,
    FrameSize = UDim2.new(1, 0, 0, 22), Order = 4,
})

local actionsGrid = new("Frame", {
    Name = "ActionsGrid", BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
    LayoutOrder = 5, Parent = DashboardPage,
})
new("UIGridLayout", {
    CellSize = UDim2.new(0.48, 0, 0, 80),
    CellPadding = UDim2.new(0.04, 0, 0, 8),
    FillDirection = Enum.FillDirection.Horizontal,
    SortOrder = Enum.SortOrder.LayoutOrder, Parent = actionsGrid,
})

addQuickAction(actionsGrid, {
    Icon = Icons.Reload, IconColor = Color3.fromRGB(59, 130, 246),
    Label = "Force Rejoin", Order = 1,
    Callback = function()
        notify("Rejoining", "Teleporting to server...", "info", 3)
        task.delay(1, function() pcall(function() TeleportService:Teleport(game.PlaceId, LP) end) end)
    end,
})

addQuickAction(actionsGrid, {
    Icon = Icons.Map, IconColor = Color3.fromRGB(251, 191, 36),
    Label = "Optimize Map", Order = 2,
    Callback = function()
        Config.MapOptimization = true; optimizeMap()
        notify("Optimized", State.RemovedObjects .. " objects processed", "success", 3)
    end,
})

addQuickAction(actionsGrid, {
    Icon = Icons.Rocket, IconColor = Color3.fromRGB(168, 85, 247),
    Label = "Boost FPS", Order = 3,
    Callback = function()
        setFPSLock(30)
        notify("FPS Locked", "Locked to 30 FPS for stability", "info", 3)
    end,
})

-- ============================================================
-- PHASE 8B: PROTECTION TAB
-- ============================================================

addPageHeader(ProtectionPage, "Protection", "Shield your session from disconnects and interruptions", 0)

local protectSection = addSection(ProtectionPage, "Session Protection", { Order = 1, Spacing = 4 })

local _, setAntiKick = addToggle(protectSection, {
    Label = "Anti-Kick", Desc = "Prevent server-side kicks",
    Icon = Icons.Shield, IconColor = Theme.Primary,
    Default = Config.AntiKick, Order = 1,
    Callback = function(v)
        Config.AntiKick = v; saveSettings()
        if v then setupAntiKick() end
        notify(v and "Enabled" or "Disabled", "Anti-Kick " .. (v and "activated" or "deactivated"), v and "success" or "info", 2)
    end,
})

local _, setAntiIdle = addToggle(protectSection, {
    Label = "Anti-Idle", Desc = "Prevent AFK disconnection",
    Icon = Icons.Clock, IconColor = Theme.Info,
    Default = Config.AntiIdle, Order = 2,
    Callback = function(v)
        Config.AntiIdle = v; saveSettings()
        if v then setupAntiIdle() end
        notify(v and "Enabled" or "Disabled", "Anti-Idle " .. (v and "activated" or "deactivated"), v and "success" or "info", 2)
    end,
})

local _, setAutoRejoin = addToggle(protectSection, {
    Label = "Auto-Rejoin", Desc = "Automatically rejoin on disconnect",
    Icon = Icons.Reload, IconColor = Theme.Success,
    Default = Config.AutoRejoin, Order = 3,
    Callback = function(v)
        Config.AutoRejoin = v; saveSettings()
        if v then setupAutoRejoin() end
        notify(v and "Enabled" or "Disabled", "Auto-Rejoin " .. (v and "activated" or "deactivated"), v and "success" or "info", 2)
    end,
})

-- Rejoin delay
local rejoinDelaySection = addSection(ProtectionPage, "Rejoin Settings", { Order = 2, Spacing = 6 })

addDropdown(rejoinDelaySection, {
    Label = "Rejoin Delay", Options = {"1", "2", "3", "5", "10"},
    Default = tostring(Config.RejoinDelay), Order = 1,
    Callback = function(v)
        Config.RejoinDelay = tonumber(v) or 3; saveSettings()
        notify("Updated", "Rejoin delay set to " .. v .. "s", "info", 2)
    end,
})

-- Connection status
local connSection = addSection(ProtectionPage, "Connection Status", { Order = 3, Spacing = 6 })

local _, connStatusLbl = addInfoRow(connSection, { Label = "Status",     Value = "Connected",  Order = 1, ValueColor = Theme.Success })
local _, connPingLbl   = addInfoRow(connSection, { Label = "Latency",   Value = "0 ms",        Order = 2 })
local _, connUptimeLbl = addInfoRow(connSection, { Label = "Uptime",    Value = "0s",           Order = 3 })
local _, connKicksLbl  = addInfoRow(connSection, { Label = "Kicks Blocked", Value = "0",        Order = 4, ValueColor = Theme.Primary })

-- Protection actions
local protectActions = addSection(ProtectionPage, nil, { Order = 4, Spacing = 8 })

addButton(protectActions, {
    Text = "Test Rejoin", Icon = Icons.Play,
    Variant = "secondary", Size = UDim2.new(1, 0, 0, 36), Order = 1,
    Callback = function()
        notify("Testing", "Simulating reconnect in 3s...", "warning", 3)
        task.delay(3, function() pcall(function() TeleportService:Teleport(game.PlaceId, LP) end) end)
    end,
})

-- ============================================================
-- PHASE 8C: PERFORMANCE TAB
-- ============================================================

addPageHeader(PerformancePage, "Performance", "Monitor and optimize game performance", 0)

-- Live metrics
local metricsSection = addSection(PerformancePage, "Live Metrics", { Order = 1, Spacing = 8 })

-- FPS
local fpsRow = new("Frame", {
    Name = "FPSRow", BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 40), LayoutOrder = 1, Parent = metricsSection,
})
label(fpsRow, { Text = "FPS", Font = Theme.FontMed, Size = 12, Color = Theme.Text,
    FrameSize = UDim2.new(0.3, 0, 0, 16) })
local perfFpsLbl = label(fpsRow, { Text = "0", Font = Theme.FontBold, Size = 14, Color = Theme.Primary,
    FrameSize = UDim2.new(0.3, 0, 0, 16), Position = UDim2.new(0.7, 0, 0, 0), AlignX = Enum.TextXAlignment.Right })
local _, perfFpsFill = progressBar(fpsRow, { Value = 0.5, Height = 6, Position = UDim2.new(0, 0, 0, 22), Size = UDim2.new(1, 0, 0, 6) })

-- Ping
local pingRow = new("Frame", {
    Name = "PingRow", BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 40), LayoutOrder = 2, Parent = metricsSection,
})
label(pingRow, { Text = "Ping", Font = Theme.FontMed, Size = 12, Color = Theme.Text,
    FrameSize = UDim2.new(0.3, 0, 0, 16) })
local perfPingLbl = label(pingRow, { Text = "0 ms", Font = Theme.FontBold, Size = 14, Color = Theme.Info,
    FrameSize = UDim2.new(0.3, 0, 0, 16), Position = UDim2.new(0.7, 0, 0, 0), AlignX = Enum.TextXAlignment.Right })
local _, perfPingFill = progressBar(pingRow, { Value = 0.1, Height = 6, Position = UDim2.new(0, 0, 0, 22), Size = UDim2.new(1, 0, 0, 6) })

-- Memory
local memRow = new("Frame", {
    Name = "MemRow", BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 40), LayoutOrder = 3, Parent = metricsSection,
})
label(memRow, { Text = "Memory", Font = Theme.FontMed, Size = 12, Color = Theme.Text,
    FrameSize = UDim2.new(0.3, 0, 0, 16) })
local perfMemLbl = label(memRow, { Text = "0 MB", Font = Theme.FontBold, Size = 14, Color = Theme.Warning,
    FrameSize = UDim2.new(0.3, 0, 0, 16), Position = UDim2.new(0.7, 0, 0, 0), AlignX = Enum.TextXAlignment.Right })
local _, perfMemFill = progressBar(memRow, { Value = 0.3, Height = 6, Position = UDim2.new(0, 0, 0, 22), Size = UDim2.new(1, 0, 0, 6) })

-- FPS Control
local fpsSection = addSection(PerformancePage, "FPS Control", { Order = 2, Spacing = 6 })

addToggle(fpsSection, {
    Label = "FPS Lock", Desc = "Cap frame rate for stability",
    Icon = Icons.Target, IconColor = Theme.Primary,
    Default = Config.FPSLockEnabled, Order = 1,
    Callback = function(v)
        Config.FPSLockEnabled = v; saveSettings()
        if v then setFPSLock(Config.FPSLockValue) else setFPSLock(nil) end
        notify(v and "Enabled" or "Disabled", "FPS Lock " .. (v and ("set to " .. Config.FPSLockValue) or "removed"), v and "success" or "info", 2)
    end,
})

addDropdown(fpsSection, {
    Label = "Target FPS", Options = {"15", "20", "30", "45", "60"},
    Default = tostring(Config.FPSLockValue), Order = 2,
    Callback = function(v)
        Config.FPSLockValue = tonumber(v) or 60; saveSettings()
        if Config.FPSLockEnabled then setFPSLock(Config.FPSLockValue) end
        notify("Updated", "FPS target set to " .. v, "info", 2)
    end,
})

-- Map optimization
local mapSection = addSection(PerformancePage, "Map Optimization", { Order = 3, Spacing = 6 })

addToggle(mapSection, {
    Label = "Enable Optimization", Desc = "Remove decorations & effects",
    Icon = Icons.Map, IconColor = Theme.Warning,
    Default = Config.MapOptimization, Order = 1,
    Callback = function(v)
        Config.MapOptimization = v; saveSettings()
        if v then optimizeMap() end
        notify(v and "Optimizing" or "Disabled", v and (State.RemovedObjects .. " objects processed") or "Map optimization off", v and "success" or "info", 2)
    end,
})

addDropdown(mapSection, {
    Label = "Optimization Level", Options = {"Low", "Medium", "High", "Extreme"},
    Default = Config.OptimizationLevel, Order = 2,
    Callback = function(v)
        Config.OptimizationLevel = v; saveSettings()
        State.OptimizationApplied = false
        notify("Updated", "Optimization level: " .. v, "info", 2)
    end,
})

local _, perfRemovedLbl = addInfoRow(mapSection, { Label = "Objects Processed", Value = "0", Order = 3 })

-- Black Screen
local blackSection = addSection(PerformancePage, "Black Screen", { Order = 4, Spacing = 6 })

addToggle(blackSection, {
    Label = "Black Screen Mode", Desc = "Cover game to save CPU/GPU resources",
    Icon = Icons.Monitor, IconColor = Theme.Primary,
    Default = Config.BlackScreen, Order = 1,
    Callback = function(v)
        setBlackScreen(v); saveSettings()
        notify(v and "Enabled" or "Disabled", v and "Black screen active - saving resources" or "Black screen removed", v and "success" or "info", 2)
    end,
})

-- ============================================================
-- PHASE 8D: SETTINGS TAB
-- ============================================================

addPageHeader(SettingsPage, "Settings", "Configure Reconnect preferences", 0)

-- General
local generalSection = addSection(SettingsPage, "General", { Order = 1, Spacing = 4 })

addToggle(generalSection, {
    Label = "Heartbeat Monitor", Desc = "Track connection health",
    Icon = Icons.Wifi, IconColor = Theme.Success,
    Default = Config.HeartbeatEnabled, Order = 1,
    Callback = function(v) Config.HeartbeatEnabled = v; saveSettings(); if v then runHeartbeat() end end,
})

addToggle(generalSection, {
    Label = "Show FPS Counter", Desc = "Display FPS in dashboard",
    Icon = Icons.Monitor, IconColor = Theme.Primary,
    Default = Config.ShowFPS, Order = 2,
    Callback = function(v) Config.ShowFPS = v; saveSettings(); if v then setupFPSCounter() end end,
})

-- Monitoring
local intervalSection = addSection(SettingsPage, "Monitoring", { Order = 2, Spacing = 6 })

addDropdown(intervalSection, {
    Label = "Update Interval", Options = {"1", "3", "5", "10", "15", "30"},
    Default = tostring(Config.UpdateInterval), Order = 1,
    Callback = function(v)
        Config.UpdateInterval = tonumber(v) or 5; saveSettings()
        notify("Updated", "Update interval: " .. v .. "s", "info", 2)
    end,
})

-- About
local aboutSection = addSection(SettingsPage, "About", { Order = 3, Spacing = 6 })

addInfoRow(aboutSection, { Label = "Version",   Value = "v" .. VERSION,     Order = 1, ValueColor = Theme.Primary })
addInfoRow(aboutSection, { Label = "Plan",       Value = "Pro Plus",        Order = 2, ValueColor = Theme.Primary })
addInfoRow(aboutSection, { Label = "Engine",     Value = "Roblox Glass UI", Order = 3 })
addInfoRow(aboutSection, { Label = "Player",     Value = LP.DisplayName,    Order = 4 })
addInfoRow(aboutSection, { Label = "User ID",    Value = tostring(LP.UserId), Order = 5 })

-- Danger Zone
local dangerSection = addSection(SettingsPage, "Danger Zone", { Order = 4, Spacing = 8 })

addButton(dangerSection, {
    Text = "Force Rejoin Server", Icon = Icons.Reload,
    Variant = "danger", Size = UDim2.new(1, 0, 0, 36), Order = 1,
    Callback = function()
        notify("Rejoining", "Teleporting in 2s...", "warning", 2)
        task.delay(2, function() pcall(function() TeleportService:Teleport(game.PlaceId, LP) end) end)
    end,
})

addButton(dangerSection, {
    Text = "Destroy UI", Icon = Icons.Power,
    Variant = "danger", Size = UDim2.new(1, 0, 0, 36), Order = 2,
    Callback = function()
        cleanup()
        ScreenGui:Destroy()
    end,
})

-- ============================================================
-- PHASE 9: FLOATING OPEN BUTTON (Logo image)
-- ============================================================

local OB_SIZE = 44

-- Soft brand glow behind the button. Kept as a ScreenGui sibling (not a
-- child of OpenButton) and synced manually on drag, since addRipple()
-- below turns on ClipsDescendants for the button itself, which would
-- otherwise clip the glow's bleed.
local obGlow = new("Frame", {
    Name                   = "OpenButtonGlow",
    BackgroundColor3       = Theme.Primary,
    BackgroundTransparency = 0.8,
    Size                   = UDim2.new(0, OB_SIZE + 14, 0, OB_SIZE + 14),
    AnchorPoint            = Vector2.new(0.5, 0.5),
    Position               = UDim2.new(0, 14 + OB_SIZE / 2, 0, 50 + OB_SIZE / 2),
    ZIndex                 = 199,
    Parent                 = ScreenGui,
})
corner(obGlow, 18)

local OpenButton = new("TextButton", {
    Name = "OpenButton",
    BackgroundColor3 = Theme.BgElevated,
    BackgroundTransparency = 0.05,
    Size = UDim2.new(0, OB_SIZE, 0, OB_SIZE),
    Position = UDim2.new(0, 14, 0, 50),
    Text = "", AutoButtonColor = false,
    ZIndex = 200, Parent = ScreenGui,
})
corner(OpenButton, 14)
stroke(OpenButton, Theme.Primary, 0.35, 1.5)
applyGradient(OpenButton, lerpColor(Theme.BgElevated, Color3.new(1, 1, 1), 0.08), Theme.BgElevated, 105)

-- Logo image, inset from the edges instead of touching the button border
new("ImageLabel", {
    Name        = "Logo", BackgroundTransparency = 1,
    Size        = UDim2.new(1, -10, 1, -10),
    Position    = UDim2.new(0.5, 0, 0.5, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    Image       = LogoImage, ScaleType = Enum.ScaleType.Fit,
    ZIndex      = 201, Parent = OpenButton,
})

-- Hover: brighten the chip + intensify the glow
OpenButton.MouseEnter:Connect(function()
    tween(OpenButton, TI_FAST, { BackgroundTransparency = 0 })
    tween(obGlow, TI_FAST, { BackgroundTransparency = 0.55 })
end)
OpenButton.MouseLeave:Connect(function()
    tween(OpenButton, TI_FAST, { BackgroundTransparency = 0.05 })
    tween(obGlow, TI_FAST, { BackgroundTransparency = 0.8 })
end)

-- Click to toggle
OpenButton.MouseButton1Click:Connect(function()
    if windowOpen then hideWindow() else showWindow() end
end)
addRipple(OpenButton)

-- Draggable open button
local obDragging, obDragStart, obStartPos = false, nil, nil
OpenButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or
       input.UserInputType == Enum.UserInputType.Touch then
        obDragging = true
        obDragStart = input.Position
        obStartPos = OpenButton.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then obDragging = false end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if obDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or
                       input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - obDragStart
        if delta.Magnitude > 5 then
            OpenButton.Position = UDim2.new(
                obStartPos.X.Scale, obStartPos.X.Offset + delta.X,
                obStartPos.Y.Scale, obStartPos.Y.Offset + delta.Y
            )
            obGlow.Position = UDim2.new(
                obStartPos.X.Scale, obStartPos.X.Offset + delta.X + OB_SIZE / 2,
                obStartPos.Y.Scale, obStartPos.Y.Offset + delta.Y + OB_SIZE / 2
            )
        end
    end
end)

-- ============================================================
-- PHASE 9: KEYBIND (RightShift to toggle)
-- ============================================================

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        if windowOpen then hideWindow() else showWindow() end
    end
end)

-- ============================================================
-- PHASE 9: UPDATE UI (optimized - batched, reduced tweens)
-- ============================================================

local lastUIUpdate = 0

local function updateUI()
    local now = tick()
    local uptime = os.time() - State.SessionStart

    -- Dashboard stats (direct text updates, no tweens)
    pcall(function() fpsValueLbl.Text = tostring(State.CurrentFPS) end)
    pcall(function() pingValueLbl.Text = State.CurrentPing .. " ms" end)
    pcall(function() memValueLbl.Text = formatMemory(State.MemoryUsage) end)
    pcall(function() uptimeValueLbl.Text = formatTime(uptime) end)

    -- Session info
    pcall(function()
        local placeName = "Unknown"
        pcall(function() placeName = cloneref(game:GetService("MarketplaceService")):GetProductInfo(game.PlaceId).Name end)
        sessionPlaceLbl.Text = placeName
    end)
    pcall(function() sessionJobLbl.Text = game.JobId ~= "" and game.JobId:sub(1, 12) .. "..." or "Studio" end)
    pcall(function() sessionPlayersLbl.Text = tostring(#Players:GetPlayers()) .. " / " .. tostring(Players.MaxPlayers) end)
    pcall(function() sessionPingsLbl.Text = tostring(State.TotalPings) end)
    pcall(function() sessionFailedLbl.Text = tostring(State.FailedPings) end)
    pcall(function() sessionReconnectsLbl.Text = tostring(State.Reconnects) end)

    -- TopBar status
    pcall(function()
        topStatusLabel.Text = State.CurrentStatus
        local dotColor = Theme.Success
        if State.CurrentStatus == "Disconnected" then dotColor = Theme.Error
        elseif State.CurrentStatus == "Warning" then dotColor = Theme.Warning end
        local dot = topStatusDot:FindFirstChild("Dot")
        local glow = topStatusDot:FindFirstChild("Glow")
        if dot then dot.BackgroundColor3 = dotColor end
        if glow then glow.BackgroundColor3 = dotColor end
    end)

    -- Protection tab
    pcall(function() connPingLbl.Text = State.CurrentPing .. " ms" end)
    pcall(function() connUptimeLbl.Text = formatTime(uptime) end)

    -- Performance tab (only tween progress bars every other update to reduce lag)
    local shouldTween = (now - lastUIUpdate) >= 2
    pcall(function()
        perfFpsLbl.Text = tostring(State.CurrentFPS)
        perfFpsLbl.TextColor3 = State.CurrentFPS >= 30 and Theme.Success or (State.CurrentFPS >= 15 and Theme.Warning or Theme.Error)
        if shouldTween then
            local fpsPct = math.clamp(State.CurrentFPS / 60, 0, 1)
            perfFpsFill.Size = UDim2.new(fpsPct, 0, 1, 0)
        end
    end)
    pcall(function()
        perfPingLbl.Text = State.CurrentPing .. " ms"
        perfPingLbl.TextColor3 = State.CurrentPing <= 100 and Theme.Success or (State.CurrentPing <= 250 and Theme.Warning or Theme.Error)
        if shouldTween then
            local pingPct = math.clamp(State.CurrentPing / 500, 0, 1)
            perfPingFill.Size = UDim2.new(pingPct, 0, 1, 0)
        end
    end)
    pcall(function()
        perfMemLbl.Text = formatMemory(State.MemoryUsage)
        perfMemLbl.TextColor3 = State.MemoryUsage <= 300 and Theme.Success or (State.MemoryUsage <= 500 and Theme.Warning or Theme.Error)
        if shouldTween then
            local memPct = math.clamp(State.MemoryUsage / 1000, 0, 1)
            perfMemFill.Size = UDim2.new(memPct, 0, 1, 0)
        end
    end)
    pcall(function() perfRemovedLbl.Text = tostring(State.RemovedObjects) end)

    if shouldTween then lastUIUpdate = now end

    -- Memory warning
    if State.MemoryUsage > Config.MemoryWarningThreshold then
        if not State._memWarned then
            State._memWarned = true
            notify("Memory Warning", formatMemory(State.MemoryUsage) .. " used", "warning", 5)
        end
    else
        State._memWarned = false
    end
end

-- ============================================================
-- PHASE 9: INITIALIZATION & MAIN LOOP
-- ============================================================

setupAntiKick()
setupAntiIdle()
setupAutoRejoin()
setupFPSCounter()
setupFPSLock()
setupConnectionMonitoring()
runHeartbeat()
optimizeMap()
if Config.BlackScreen then setBlackScreen(true) end

State.CurrentStatus = "Running"

if Config.WebhookOnStart and Config.WebhookURL ~= "" then
    sendWebhook("Reconnect Started", "v" .. VERSION .. " initialized for " .. LP.DisplayName, 3066993)
end

task.delay(0.5, function()
    notify("Reconnect Active", "v" .. VERSION .. " - Pro Plus", "success", 4)
end)

-- Main monitoring loop
task.spawn(function()
    while not State.StopUpdate do
        pcall(function()
            State.TotalPings = State.TotalPings + 1
            updateMemoryUsage()
            updatePing()

            if Config.HeartbeatEnabled and State.LastPingTime > 0 then
                local timeSince = tick() - State.LastPingTime
                if timeSince > 10 then
                    State.CurrentStatus = "Warning"
                    State.FailedPings = State.FailedPings + 1
                else
                    State.CurrentStatus = "Running"
                end
            end

            updateUI()
        end)

        task.wait(Config.UpdateInterval)
    end
end)

-- ============================================================
-- PHASE 9: RETURN API
-- ============================================================

return {
    show     = showWindow,
    hide     = hideWindow,
    toggle   = function() if windowOpen then hideWindow() else showWindow() end end,
    notify   = notify,
    cleanup  = function() cleanup(); ScreenGui:Destroy() end,
    getState = function() return State end,
    getConfig = function() return Config end,
    setConfig = function(key, value)
        if Config[key] ~= nil then Config[key] = value; return true end
        return false
    end,
    forceUpdate = function()
        updateUI()
    end,
    setFPS = function(fps)
        Config.FPSLockValue = fps
        Config.FPSLockEnabled = true
        return setFPSLock(fps)
    end,
    unlockFPS = function()
        Config.FPSLockEnabled = false
        return setFPSLock(nil)
    end,
    getFPS = function() return State.CurrentFPS end,
    optimizeMap = function(level)
        if level then Config.OptimizationLevel = level end
        Config.MapOptimization = true
        State.OptimizationApplied = false
        optimizeMap()
        return State.RemovedObjects
    end,
    getOptimizationStats = function()
        return {
            applied = State.OptimizationApplied,
            objectsProcessed = State.RemovedObjects,
            level = Config.OptimizationLevel,
        }
    end,
    sendWebhook = sendWebhook,
    setBlackScreen = function(on)
        if on == nil then on = not BlackScreenActive end
        setBlackScreen(on); saveSettings()
        return BlackScreenActive
    end,
    VERSION = VERSION,
}
