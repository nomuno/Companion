-- SettingsPanel.lua: settings controls painted onto Blizzard Settings > AddOns canvases (0.61).
-- Each Header() starts (or continues) a scrollable canvas registered by SettingsUI.lua.
-- Every control reads ns.db when the page is shown and writes back immediately through
-- the same functions the slash commands use (ns.Set*, ns.RunCommand, guide.*).
-- Open with /comp options [page], /comp config, or the gear button on the companion window.

local _, ns = ...

local PANEL_W = ns.SETTINGS_PAGE_W or 594
local LEFT = 16
local controls = {}          -- every control: { kind, key, refresh = fn }
ns.configControls = controls

local function safe(fn, ...)
    if type(fn) ~= "function" then return nil end
    local ok, a, b, c = pcall(fn, ...)
    if ok then return a, b, c end
end

local function TryCreate(kind, name, parent, ...)
    for _, tpl in ipairs({ ... }) do
        local ok, f = pcall(CreateFrame, kind, name, parent, tpl)
        if ok and f then return f end
    end
    return CreateFrame(kind, name, parent)
end

-- 0.61: the General canvas registered in SettingsUI.lua is the parent AddOns category.

-- current page being filled
local content
local PAGE_KEYS = { ["Navigation"] = "navigation", ["Wisp"] = "wisp", ["Portrait / 3D scene"] = "portrait",
    ["Speech"] = "speech", ["Reminders"] = "reminders", ["Guide"] = "guide",
    ["Quest recorder"] = "recorder", ["Quest tracker"] = "tracker", ["Ore & herbs"] = "nodes", ["About"] = "about" }
local LABELS = { portrait = "3D scene", dungeons = "Dungeons", recorder = "Recorder", tracker = "Tracker", nodes = "Ore & herbs" }

local y = -12
local function Gap(h) y = y - (h or 8) end

local function Text(str, font, x)
    local fs = content:CreateFontString(nil, "ARTWORK", font or "GameFontHighlightSmall")
    fs:SetPoint("TOPLEFT", x or LEFT, y)
    fs:SetJustifyH("LEFT")
    fs:SetWidth(PANEL_W - 2 * LEFT)
    fs:SetText(str)
    return fs
end

-- Header(title, pageKey, label): first header for a page creates it (or continues an
-- Options.lua page below its nextY); later headers on the same page are sub-headings.
local curKey
local canvasMode = false
local function Header(str, key, label)
    key = key or PAGE_KEYS[str] or str:lower():gsub("%W", "")
    if canvasMode then
        -- Painting onto a Blizzard Settings canvas: never create a Settings window page.
        if key ~= curKey then
            if curKey then Gap(14) end
            curKey = key
        else
            Gap(14)
        end
    elseif key ~= curKey then
        if content then content:SetHeight(math.max(content:GetHeight() or 0, -y + 20)) end
        local existing = ns.SettingsPages and ns.SettingsPages[key]
        content = ns.AddSettingsPage(key, label or LABELS[key] or str, 400)
        curKey = key
        local ny = existing and existing.nextY
        y = (type(ny) == "number") and ny or -10
    else
        Gap(14)
    end
    Text(str, "GameFontNormalLarge")
    y = y - 24
    local line = content:CreateTexture(nil, "ARTWORK")
    line:SetColorTexture(1, 0.82, 0, 0.25)
    line:SetPoint("TOPLEFT", LEFT, y + 4)
    line:SetSize(PANEL_W - 2 * LEFT, 1)
    Gap(4)
    if ns.GrowSettingsPage then ns.GrowSettingsPage(content, y) end
end

local function Register(c)
    local list = controls
    if canvasMode then
        ns.blizzControls = ns.blizzControls or {}
        list = ns.blizzControls
    end
    table.insert(list, c)
    return c
end

local nameN = 0
local function NextName(kind) nameN = nameN + 1 return "CompanionCfg" .. kind .. nameN end

-- checkbox bound to a db key; setter(value) does the work
local function Check(label, key, setter, x)
    local name = NextName("Check")
    local cb = TryCreate("CheckButton", name, content, "InterfaceOptionsCheckButtonTemplate", "UICheckButtonTemplate")
    cb:SetSize(26, 26)
    cb:SetPoint("TOPLEFT", x or LEFT, y)
    local fs = cb.Text or _G[name .. "Text"]
    if not fs then fs = cb:CreateFontString(nil, "ARTWORK", "GameFontHighlight") end
    fs:ClearAllPoints()
    fs:SetPoint("LEFT", cb, "RIGHT", 2, 0)
    fs:SetText(label)
    cb.label = fs
    local c = Register({ kind = "check", key = key, widget = cb })
    cb:SetScript("OnClick", function(self)
        local on = self:GetChecked() and true or false
        if setter then setter(on) else ns.db[key] = on end
        c.refresh()
    end)
    c.refresh = function() cb:SetChecked(ns.db[key] and true or false) end
    if not x then y = y - 28 end
    return cb, c
end

-- checkbox with custom get/set (for nested settings)
local function CheckFn(label, key, get, set)
    local cb, c = Check(label, key, function(on) set(on) end)
    c.refresh = function() cb:SetChecked(get() and true or false) end
    return cb, c
end

local function Button(label, width, fn, x)
    local b = TryCreate("Button", NextName("Btn"), content, "UIPanelButtonTemplate")
    b:SetSize(width or 140, 22)
    b:SetPoint("TOPLEFT", x or LEFT, y)
    b:SetText(label)
    b:SetScript("OnClick", fn)
    return b
end

-- slider bound to a db key
local function Slider(label, key, minV, maxV, step, setter, fmt, default)
    local name = NextName("Slider")
    Gap(14)
    local s = TryCreate("Slider", name, content, "OptionsSliderTemplate")
    s:SetPoint("TOPLEFT", LEFT + 8, y)
    s:SetWidth(260)
    s:SetHeight(16)
    s:SetOrientation("HORIZONTAL")
    s:SetMinMaxValues(minV, maxV)
    s:SetValueStep(step)
    safe(s.SetObeyStepOnDrag, s, true)
    fmt = fmt or "%.2f"
    local low, high = s.Low or _G[name .. "Low"], s.High or _G[name .. "High"]
    if low and low.SetText then low:SetText(string.format(fmt, minV)) end
    if high and high.SetText then high:SetText(string.format(fmt, maxV)) end
    local title = s.Text or _G[name .. "Text"]
    if not (title and title.SetText) then
        title = s:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
        title:SetPoint("BOTTOM", s, "TOP", 0, 2)
    end
    local val = content:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    val:SetPoint("LEFT", s, "RIGHT", 12, 0)
    local c = Register({ kind = "slider", key = key, widget = s, min = minV, max = maxV })
    local function Show(v) title:SetText(label) val:SetText(string.format(fmt, v)) end
    s:SetScript("OnValueChanged", function(self, v)
        v = math.floor(v / step + 0.5) * step
        Show(v)
        if c.updating then return end
        if setter then setter(v) else ns.db[key] = v end
    end)
    c.refresh = function()
        local v = tonumber(ns.db[key]) or default or minV
        c.updating = true
        s:SetValue(math.max(minV, math.min(maxV, v)))
        c.updating = false
        Show(v)
    end
    y = y - 34
    return s, c
end

-- edit box + Apply button; apply(text) returns true when accepted
local function Edit(label, key, width, apply, numeric)
    Text(label, "GameFontHighlight")
    local e = TryCreate("EditBox", NextName("Edit"), content, "InputBoxTemplate")
    e:SetSize(width or 80, 20)
    e:SetAutoFocus(false)
    if numeric then safe(e.SetNumeric, e, true) end
    e:SetPoint("TOPLEFT", LEFT + 180, y + 3)
    local c = Register({ kind = "edit", key = key, widget = e })
    local function Do()
        if apply(e:GetText()) == false then ns.Print("not a valid value.") end
        e:ClearFocus()
        c.refresh()
    end
    e:SetScript("OnEnterPressed", Do)
    e:SetScript("OnEscapePressed", function() e:ClearFocus() c.refresh() end)
    local b = Button("Apply", 70, Do, LEFT + 190 + (width or 80))
    b:SetPoint("TOPLEFT", LEFT + 190 + (width or 80), y + 4)
    c.apply = Do
    c.refresh = function() e:SetText(tostring(ns.db[key] or "")) end
    y = y - 28
    return e, c
end

-- button that cycles through a list of values; get() -> current label
local function Cycle(label, width, values, get, set, key)
    Text(label, "GameFontHighlight")
    local b = Button("", width or 160, nil, LEFT + 180)
    b:SetPoint("TOPLEFT", LEFT + 180, y + 4)
    local c = Register({ kind = "cycle", key = key, widget = b })
    b:SetScript("OnClick", function()
        local list = type(values) == "function" and values() or values
        local cur, idx = get(), 0
        for i, v in ipairs(list) do if v == cur then idx = i end end
        local nextV = list[(idx % #list) + 1]
        if nextV ~= nil then set(nextV) end
        c.refresh()
    end)
    c.refresh = function() b:SetText(tostring(get() or "-")) end
    y = y - 28
    return b, c
end

-- ===================== CONFIRM DIALOGS =====================
StaticPopupDialogs["COMPANION_RESET_GUIDE"] = {
    text = "Reset progress for this guide on this character?",
    button1 = YES or "Yes", button2 = NO or "No",
    OnAccept = function() if ns.guide then ns.guide.Reset() ns.Print("guide progress reset.") end end,
    timeout = 0, whileDead = true, hideOnEscape = true, preferredIndex = 3,
}
StaticPopupDialogs["COMPANION_CLEAR_RECORDS"] = {
    text = "Delete ALL recorded quest data? This can't be undone. Export it first if you want to keep it.",
    button1 = DELETE or "Delete", button2 = CANCEL or "Cancel",
    OnAccept = function() ns.ClearQuestRecords() ns.Print("recorded quest data cleared.") if ns.RefreshConfig then ns.RefreshConfig() end end,
    timeout = 0, whileDead = true, hideOnEscape = true, showAlert = true, preferredIndex = 3,
}
local function Confirm(which) if StaticPopup_Show then StaticPopup_Show(which) end end

-- Export helpers so dependent modules can build their own pages/tabs.
ns.Header, ns.Check, ns.CheckFn, ns.Button, ns.Slider = Header, Check, CheckFn, Button, Slider
ns.Edit, ns.Cycle, ns.Text, ns.Gap, ns.Confirm, ns.Register = Edit, Cycle, Text, Gap, Confirm, Register
ns.TryCreate, ns.NextName = TryCreate, NextName
ns.Opt = {}
function ns.Opt.GetY() return y end
function ns.Opt.SetY(v) y = v end
function ns.Opt.Content() return content end
function ns.Opt.Left() return LEFT end
function ns.Opt.PanelW() return PANEL_W end

-- Run a builder against the current Settings-window cursor (y/content) OR a raw canvas.
-- Bare Header/Check/y/content/LEFT locals in the builder resolve through this environment.
function ns.BindOptEnv(fn)
    if type(fn) ~= "function" or not setfenv then return fn end
    local env = {}
    setmetatable(env, {
        __index = function(_, k)
            if k == "y" then return y end
            if k == "content" then return content end
            if k == "curKey" then return curKey end
            if k == "LEFT" then return LEFT end
            if k == "PANEL_W" then return PANEL_W end
            if k == "controls" then return controls end
            if k == "Header" then return Header end
            if k == "Check" then return Check end
            if k == "CheckFn" then return CheckFn end
            if k == "Button" then return Button end
            if k == "Slider" then return Slider end
            if k == "Edit" then return Edit end
            if k == "Cycle" then return Cycle end
            if k == "Text" then return Text end
            if k == "Gap" then return Gap end
            if k == "Confirm" then return Confirm end
            if k == "Register" then return Register end
            if k == "TryCreate" then return TryCreate end
            if k == "NextName" then return NextName end
            if k == "safe" then return safe end
            if k == "ModuleEnableCheckbox" then return ns.ModuleEnableCheckbox end
            if k == "ns" then return ns end
            if k == "_G" then return _G end
            local v = ns[k]
            if v ~= nil then return v end
            return _G[k]
        end,
        __newindex = function(_, k, v)
            if k == "y" then y = v
            elseif k == "content" then content = v
            elseif k == "curKey" then curKey = v
            else rawset(env, k, v) end
        end,
    })
    setfenv(fn, env)
    return fn
end

function ns.WithCanvas(frame, fn)
    if not frame or type(fn) ~= "function" then return end
    local prevC, prevY, prevKey, prevMode = content, y, curKey, canvasMode
    content, y, curKey, canvasMode = frame, -10, nil, true
    local ok, err = pcall(fn)
    if content and content.SetHeight then content:SetHeight(math.max(content:GetHeight() or 0, -y + 20)) end
    content, y, curKey, canvasMode = prevC, prevY, prevKey, prevMode
    if not ok then error(err) end
end

-- 0.61: pages ARE the Blizzard canvases (see SettingsUI.AddSettingsPage).
-- These remain as thin wrappers so a module that still calls them cannot
-- create a second, redirect-only tab.
function ns.CreateBlizzardCanvas(id, title)
    local aliases = ns.SETTINGS_ALIASES or {}
    local key = aliases[id] or id
    local page = ns.SettingsPages and (ns.SettingsPages[key] or ns.SettingsPages[id])
    if page then return page end
    return ns.AddSettingsPage(key, title or id, 800)
end

function ns.RegisterAddOnSubcategory(panel, title)
    -- Already registered by AddSettingsPage. No-op kept for old callers.
    return panel and panel.blizzardCategory
end

function ns.RegisterCoreSubcategory(pageKey, title)
    -- Core pages are registered when Header()/Options.lua call AddSettingsPage.
    return ns.SettingsPages and ns.SettingsPages[pageKey]
end

function ns.ModuleEnableCheckbox(id)
    local m = ns.modules[id] or { title = id }
    local title = m.title or id
    local cb, c = CheckFn("Enable " .. title, "moduleEnabled_" .. id,
        function() return ns.IsModuleEnabled(id) end,
        function(on) ns.SetModuleEnabled(id, on) end)
    Text("Unticking turns this module off now and disables it for this character. Reload the UI to fully unload it.", "GameFontDisableSmall", LEFT + 8)
    y = y - 20
    local hint = Text("", "GameFontHighlightSmall", LEFT + 8)
    y = y - 18
    local btn = Button("Reload UI", 120, function() if ReloadUI then ReloadUI() end end)
    local function refreshHint()
        local pending = ns.reloadNeeded and true or false
        if hint and hint.SetText then
            hint:SetText(pending and "Reload the UI to fully apply the change." or "")
        end
        if btn then
            if btn.SetShown then btn:SetShown(pending)
            elseif pending then btn:Show() else btn:Hide() end
        end
    end
    local prev = c.refresh
    c.refresh = function()
        if prev then prev() end
        refreshHint()
        -- Grey out the rest of the page's later controls when disabled? Applied in RefreshConfig.
    end
    y = y - 30
    refreshHint()
    m.enableControl = c
    return cb, c
end

-- Module list on the General settings page (and the Blizzard parent canvas).
function ns.RefreshModuleList()
    local page = ns.SettingsPages and ns.SettingsPages.general
    if not page then return end
    ns._moduleList = ns._moduleList or {}
    local rows = ns._moduleList
    local list = (ns.AllModuleStatuses and ns.AllModuleStatuses()) or {}
    local startY = page.nextY or -196
    if not page.moduleHeader then
        local h = page:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
        h:SetPoint("TOPLEFT", 18, startY - 8)
        h:SetText("Modules")
        page.moduleHeader = h
        local sub = page:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
        sub:SetPoint("TOPLEFT", 20, startY - 28)
        sub:SetWidth(540)
        sub:SetJustifyH("LEFT")
        sub:SetText("Each module is a separate addon that nests under Companion. Disabled modules can be turned back on here, then reload.")
        page.moduleSub = sub
        startY = startY - 52
        page.moduleListY = startY
    else
        startY = page.moduleListY or (startY - 52)
    end
    for i, st in ipairs(list) do
        local row = rows[i]
        if not row then
            row = {}
            row.label = page:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
            row.btn = CreateFrame("Button", "CompanionModuleEnable_" .. st.id, page, "UIPanelButtonTemplate")
            row.btn:SetSize(110, 20)
            rows[i] = row
        end
        local yOff = startY - (i - 1) * 24
        row.label:ClearAllPoints()
        row.label:SetPoint("TOPLEFT", 20, yOff)
        local status
        if not st.installed and not st.loaded then
            status = "|cff999999not installed|r"
        elseif st.loaded and st.enabled then
            status = "|cff55ff55loaded|r"
        elseif st.loaded and not st.enabled then
            status = "|cffffcc00loaded, disabled|r"
        elseif st.installed and not st.loaded then
            status = "|cffff5555installed, not loaded|r"
        else
            status = "|cff999999unknown|r"
        end
        row.label:SetText(string.format("%s  –  %s", st.title, status))
        row.label:Show()
        row.btn:ClearAllPoints()
        row.btn:SetPoint("TOPLEFT", 360, yOff)
        row.st = st
        if st.loaded and st.enabled then
            row.btn:SetText("Disable")
            row.btn:SetScript("OnClick", function() ns.SetModuleEnabled(st.id, false) end)
            row.btn:Show()
        elseif st.loaded and not st.enabled then
            row.btn:SetText("Enable")
            row.btn:SetScript("OnClick", function() ns.SetModuleEnabled(st.id, true) end)
            row.btn:Show()
        elseif st.installed and not st.loaded then
            row.btn:SetText("Enable + reload")
            row.btn:SetSize(130, 20)
            row.btn:SetScript("OnClick", function()
                ns.SetModuleEnabled(st.id, true)
                if ReloadUI then ReloadUI() end
            end)
            row.btn:Show()
        else
            row.btn:Hide()
        end
    end
    for i = #list + 1, #rows do
        if rows[i].label then rows[i].label:Hide() end
        if rows[i].btn then rows[i].btn:Hide() end
    end
    if ns.reloadNeeded and not page.reloadBtn then
        local b = CreateFrame("Button", "CompanionModuleReload", page, "UIPanelButtonTemplate")
        b:SetSize(120, 22)
        b:SetPoint("TOPLEFT", 20, startY - (#list * 24) - 8)
        b:SetText("Reload UI")
        b:SetScript("OnClick", function() if ReloadUI then ReloadUI() end end)
        page.reloadBtn = b
    elseif page.reloadBtn then
        page.reloadBtn:SetShown(ns.reloadNeeded and true or false)
    end
end

-- ===================== SECTIONS (0.48: every option exactly once) =====================
-- Audio (continues Options.lua's Audio page)
Header("Sound tools", "audio")
Button("Sound debug", 140, function() ns.RunCommand("sounddebug") end)
y = y - 30

-- Speech
Header("Speech", "speech")
Cycle("Speech text", 120, { "window", "chat", "both" },
    function() return ns.SpeechTextMode() end,
    function(v) ns.SetSpeechText(v) end, "speechText")
Cycle("Chattiness", 120, { "quiet", "normal", "chatty" },
    function() return ns.db.chattiness or "normal" end,
    function(v) ns.SetChattiness(v) end, "chattiness")
Check("Idle emotes", "idleEmotes", ns.SetIdleEmotes)
local sayCat = "praise"
local function Categories()
    local names = {}
    for k in pairs(ns.dialogue or {}) do if type(ns.dialogue[k]) == "table" then table.insert(names, k) end end
    table.sort(names)
    return names
end
Cycle("Test line category", 160, Categories, function() return sayCat end, function(v) sayCat = v end)
local play = Button("Play", 70, function() ns.RunCommand("say", sayCat) end, LEFT + 350)
play:SetPoint("TOPLEFT", LEFT + 350, y + 32)
ns.configSayCategory = function(v) if v then sayCat = v end return sayCat end
Header("Zone histories", "speech")
Check("Tell a zone's history (first visit, then now and then)", "zoneLore")
Button("Replay this zone's history", 190, function() ns.RunCommand("lore") end)
y = y - 30

-- Appearance (continues Options.lua's model presets)
Header("Window style", "models")
Cycle("Companion window", 120, { "Round", "Classic" },
    function() return (ns.db.windowStyle == "classic") and "Classic" or "Round" end,
    function(v) ns.ApplyWindowStyle(v:lower()) end, "windowStyle")
Cycle("Title bar", 120, { "Above", "Below" },
    function() return (ns.db.windowBar == "below") and "Below" or "Above" end,
    function(v) ns.SetWindowBar(v:lower()) end, "windowBar")
Slider("Title bar size", "titleBarSize", 0.5, 2.0, 0.05, ns.SetTitleBarSize, "%.2f", 1)
Header("3D scene", "models")
Check("3D scene renderer (needs /reload)", "useScene", ns.SetUseScene)
Button("Reload UI", 120, function() if ReloadUI then ReloadUI() end end)
y = y - 30
Cycle("Light", 160, function()
    local l = {}
    for _, d in ipairs(ns.LIGHT_DIRS or {}) do table.insert(l, d.name) end
    return l
end, function()
    local d = ns.LIGHT_DIRS and ns.LIGHT_DIRS[ns.db.sceneLight or 1]
    return d and d.name
end, function() ns.CycleSceneLight() end, "sceneLight")
Slider("Ambient light", "sceneAmbient", 0.2, 1.5, 0.05, ns.SetSceneAmbient, "%.2f", 1)
Slider("Camera zoom (higher = farther)", "camDistance", 0.15, 5.0, 0.05, ns.SetCamDistance, "%.2f", 1)
Button("Reset pan/zoom", 140, function() ns.ResetView() ns.RefreshConfig() end)
Button("Scene debug", 140, function() ns.RunCommand("scenedebug") end, LEFT + 180)
y = y - 30

-- Navigation + wisp
Header("Navigation", "navigation", "Navigation")
Check("Navigation (she looks toward your next objective)", "navEnabled", function(on) ns:SetNavEnabled(on) end)
Check("Flip left/right (if she turns the wrong way)", "navInvert", ns.SetNavInvert)
Slider("Arrival distance (yards)", "navArriveYards", 5, 40, 1, ns.SetNavArrive, "%d", 15)
Button("Clear manual waypoint", 170, function() ns.ClearWaypoint() ns.Print("waypoint cleared.") end)
Button("Run nav debug", 140, function() ns.RunCommand("navdebug") end, LEFT + 180)
y = y - 30
Header("Wisp", "navigation")
Edit("Wisp display ID", "wispDisplayID", 80, function(t) return ns.SetWispDisplayID(t) end, true)
Slider("Size", "wispScale", 0.1, 1.5, 0.05, function(v) ns.SetWispValue("wispScale", v) end, "%.2f", 0.5)
Slider("Orbit", "wispOrbit", 0.1, 1.0, 0.05, function(v) ns.SetWispValue("wispOrbit", v) end, "%.2f", 0.3)
Slider("Height offset", "wispZ", -3, 3, 0.1, function(v) ns.SetWispValue("wispZ", v) end, "%.1f", 2)
Slider("Height when in front", "wispFrontZ", 0.2, 1.0, 0.05, function(v) ns.SetWispValue("wispFrontZ", v) end, "%.2f", 0.45)
Button("Reset wisp to defaults", 170, function() ns.ResetWisp() ns.RefreshConfig() end)
Button("Wisp debug", 140, function() ns.RunCommand("wispdebug") end, LEFT + 180)
y = y - 30

-- Module pages (Guides, Dungeons, Tracker, Reminders, Combat,
-- Marker wheel, Loot, Ore & herbs, Quest recorder) are built by each
-- loaded Companion_* module from its own Options.lua.

Header("About", "about")
Text("Companion " .. tostring(ns.VERSION) .. ". Slash commands:")
y = y - 16
for _, line in ipairs(ns.HELP or {}) do Text(line, "GameFontDisableSmall", LEFT + 8) y = y - 14 end
Gap(20)
content:SetHeight(-y)
    if ns.GrowSettingsPage then ns.GrowSettingsPage(content, y) end

-- ===================== REFRESH / OPEN =====================
function ns.RefreshConfig()
    for _, c in ipairs(controls) do if c.refresh then pcall(c.refresh) end end
    for _, c in ipairs(ns.blizzControls or {}) do if c.refresh then pcall(c.refresh) end end
    if ns.RefreshModuleList then pcall(ns.RefreshModuleList) end
end
if ns.configPanel then ns.configPanel.OnRefresh = ns.RefreshConfig end

if ns.On then
    ns:On("LOGIN", function()
        if ns.RefreshModuleList then pcall(ns.RefreshModuleList) end
    end)
end

-- 0.47: "config" opens the standalone window too (everything lives there now)
function ns.OpenConfig(key) return ns.OpenSettings(key) end
ns:AddCommand("config", function(rest) ns.OpenConfig(rest ~= "" and rest or nil) end)
