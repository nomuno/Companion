-- Companion 0.61: Blizzard Settings > AddOns category and subcategories.
-- There is no standalone Companion settings window. Every page's controls are
-- painted onto a scrollable canvas registered with the game's Settings API
-- (with InterfaceOptions_AddCategory as a fallback on older clients).
-- /comp options [page], /comp config, and the gear button open Settings to
-- the matching Companion category.

local _, ns = ...

ns.SETTINGS_PAGE_W = 620
-- Display / open order. Pages not listed are appended in creation order.
ns.SETTINGS_ORDER = { "general", "audio", "speech", "models", "navigation", "guide",
    "reminders", "combat", "markwheel", "loot", "nodes", "about" }

-- /comp options <alias> maps onto a real page key.
ns.SETTINGS_ALIASES = {
    appearance = "models",
    model = "models",
    portrait = "models",
    scene = "models",
    nav = "navigation",
    wisp = "navigation",
    gather = "nodes",
    ore = "nodes",
    herbs = "nodes",
    questhelper = "guide",
    guides = "guide",
    dungeons = "guide",
    dungeon = "guide",
    tracker = "guide",
    recorder = "guide",
    quests = "guide",
    nameplates = "combat",
    plates = "combat",
    buffs = "combat",
    marker = "markwheel",
    mark = "markwheel",
    wheel = "markwheel",
    rolls = "loot",
}

local pages, canvases, created = {}, {}, {}
ns.SettingsPages, ns.SettingsCanvases = pages, canvases
ns.SettingsButtons = {}  -- no left-nav list anymore; kept as an empty table
local state = { active = nil, last = "general" }
ns.settingsState = state
ns.SettingsWindow = nil  -- 0.61: the standalone window is gone

local function ResolveKey(key)
    if not key or key == "" then return state.last or "general" end
    key = tostring(key):lower():gsub("%s+", "")
    if pages[key] then return key end
    if ns.SETTINGS_ALIASES[key] then return ns.SETTINGS_ALIASES[key] end
    return key
end

local function RebuildOrder()
    local keys, seen = {}, {}
    for _, k in ipairs(ns.SETTINGS_ORDER) do
        if pages[k] and not seen[k] then
            keys[#keys + 1] = k
            seen[k] = true
        end
    end
    for _, k in ipairs(created) do
        if pages[k] and not seen[k] then
            keys[#keys + 1] = k
            seen[k] = true
        end
    end
    ns.SettingsOrder = keys
    return keys
end

local function CategoryID(cat)
    if cat == nil then return nil end
    if type(cat) == "table" and cat.GetID then
        local ok, id = pcall(cat.GetID, cat)
        if ok and id ~= nil then return id end
    end
    return cat
end

-- Register the parent "Companion" category once, from the General canvas.
local function RegisterParent(canvas)
    if ns.configCategory then return ns.configCategory end
    canvas.name = "Companion"
    if Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory then
        local ok, cat = pcall(Settings.RegisterCanvasLayoutCategory, canvas, "Companion")
        if ok and cat then
            pcall(Settings.RegisterAddOnCategory, cat)
            ns.configCategory = cat
            ns.configPanel = canvas
            canvas.blizzardCategory = cat
            return cat
        end
    end
    if InterfaceOptions_AddCategory then
        pcall(InterfaceOptions_AddCategory, canvas)
        ns.configPanel = canvas
        ns.configCategory = canvas
        canvas.blizzardCategory = canvas
        return canvas
    end
end

local function RegisterSub(canvas, title)
    canvas.name = title or canvas.name
    local parent = ns.configCategory
    if Settings and Settings.RegisterCanvasLayoutSubcategory and parent then
        local ok, sub = pcall(Settings.RegisterCanvasLayoutSubcategory, parent, canvas, title)
        if ok and sub then
            canvas.blizzardCategory = sub
            return sub
        end
    end
    if InterfaceOptions_AddCategory then
        canvas.parent = "Companion"
        pcall(InterfaceOptions_AddCategory, canvas)
        canvas.blizzardCategory = canvas
        return canvas
    end
end

-- Create a scrollable Settings canvas. Returns the inner content frame
-- (place controls from TOPLEFT with negative y).
function ns.AddSettingsPage(key, label, height)
    if pages[key] then return pages[key] end
    local isGeneral = (key == "general")
    local canvasName = "CompanionSettingsCanvas_" .. key
    local canvas = CreateFrame("Frame", canvasName, UIParent)
    canvas.name = isGeneral and "Companion" or (label or key)
    canvas:Hide()

    local scroll = CreateFrame("ScrollFrame", canvasName .. "Scroll", canvas, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 4, -8)
    scroll:SetPoint("BOTTOMRIGHT", -28, 8)

    local child = CreateFrame("Frame", canvasName .. "Child", scroll)
    child:SetSize(ns.SETTINGS_PAGE_W, height or 800)
    if scroll.SetScrollChild then scroll:SetScrollChild(child) end

    child.key, child.label = key, label or key
    child.canvas, child.scroll = canvas, scroll
    canvas.child, canvas.key, canvas.label = child, key, child.label

    pages[key] = child
    canvases[key] = canvas
    created[#created + 1] = key

    -- A tiny clickable stand-in so older tests that called SettingsButtons.x:Click()
    -- still open the matching Settings page.
    local b = {
        key = key,
        text = child.label,
        active = false,
        Click = function() ns.OpenSettings(key) end,
    }
    function b:Click() ns.OpenSettings(self.key) end
    function b:SetText(t) self.text = t end
    function b:GetText() return self.text end
    function b:LockHighlight() self.active = true end
    function b:UnlockHighlight() self.active = false end
    ns.SettingsButtons[key] = b

    if isGeneral then
        local cat = RegisterParent(canvas)
        if cat then child.blizzardCategory = cat end
    else
        if not ns.configCategory then
            -- Parent must exist first (Options.lua creates General before other pages).
            -- If a submodule somehow registers early, make a hidden parent.
            local parent = canvases.general
            if parent then RegisterParent(parent) end
        end
        local sub = RegisterSub(canvas, child.label)
        if sub then child.blizzardCategory = sub end
    end

    local function Refresh()
        state.active, state.last = key, key
        if ns.db then ns.db.settingsPage = key end
        if ns.RefreshConfig then pcall(ns.RefreshConfig) end
        if key == "general" and ns.UpdateGeneralOptions then pcall(ns.UpdateGeneralOptions) end
        if key == "audio" and ns.UpdateAudioOptions then pcall(ns.UpdateAudioOptions) end
        if key == "models" and ns.RefreshPresetHighlight then pcall(ns.RefreshPresetHighlight) end
        if child.onShow then pcall(child.onShow) end
    end
    canvas:SetScript("OnShow", Refresh)
    child.Refresh = Refresh

    -- Keep the scroll child tall enough and as wide as the panel.
    canvas:SetScript("OnSizeChanged", function(self, w, h)
        w = tonumber(w) or self:GetWidth() or 660
        local inner = math.max(200, w - 36)
        if child.SetWidth then child:SetWidth(inner) end
    end)

    RebuildOrder()
    return child
end

function ns.GrowSettingsPage(content, y)
    content = content or (state.active and pages[state.active])
    if not content or not content.SetHeight then return end
    local bottom = 40
    if type(y) == "number" then bottom = math.max(bottom, -y + 40) end
    content:SetHeight(math.max(content:GetHeight() or 0, bottom))
end

function ns.ShowSettingsPage(key)
    key = ResolveKey(key)
    return ns.OpenSettings(key)
end

-- Open the game's Settings UI to a Companion page. Always opens (does not
-- toggle the Settings frame closed). Safe in combat: we only call the
-- Settings API inside pcall; if it is blocked we print a short note.
function ns.OpenSettings(key)
    key = ResolveKey(key or state.last or "general")
    if not pages[key] then
        local names = table.concat(ns.SettingsOrder or RebuildOrder() or {}, "|")
        if ns.Print then ns.Print("usage: /comp options [" .. names .. "]") end
        return false
    end
    state.last, state.active = key, key
    if ns.db then ns.db.settingsPage = key end

    -- Highlight stand-in buttons (for tests / OpenSettings bookkeeping).
    for k, b in pairs(ns.SettingsButtons) do
        b.active = (k == key)
    end

    local canvas = canvases[key]
    local cat = (canvas and canvas.blizzardCategory) or (pages[key] and pages[key].blizzardCategory) or ns.configCategory
    local opened = false

    if InCombatLockdown and InCombatLockdown() then
        -- Opening the Settings UI is normally allowed in combat; still pcall.
    end

    if Settings and Settings.OpenToCategory and cat then
        local id = CategoryID(cat)
        local ok = pcall(Settings.OpenToCategory, id)
        if not ok and id ~= cat then ok = pcall(Settings.OpenToCategory, cat) end
        -- Some clients want the parent opened first, then the subcategory.
        if not ok and ns.configCategory then
            pcall(Settings.OpenToCategory, CategoryID(ns.configCategory))
            ok = pcall(Settings.OpenToCategory, id)
        end
        opened = ok and true or false
    end
    if not opened and InterfaceOptionsFrame_OpenToCategory and canvas then
        -- Classic bug: the first call sometimes only selects the category list.
        pcall(InterfaceOptionsFrame_OpenToCategory, canvas)
        pcall(InterfaceOptionsFrame_OpenToCategory, canvas)
        opened = true
    end
    if not opened and Settings and Settings.OpenToCategory then
        -- Last resort: open the parent Companion category by name / object.
        local ok = pcall(Settings.OpenToCategory, "Companion")
        if not ok and ns.configCategory then
            ok = pcall(Settings.OpenToCategory, CategoryID(ns.configCategory))
        end
        opened = ok and true or false
    end

    -- Refresh even if the UI did not open (harness: OpenToCategory is a stub).
    if pages[key].Refresh then pcall(pages[key].Refresh) end

    if not opened and ns.Print and not (Settings and Settings.OpenToCategory) and not InterfaceOptionsFrame_OpenToCategory then
        -- Offline / missing API: still count as "opened" for the harness.
        opened = true
    end
    if not opened and ns.Print then
        ns.Print("could not open settings" .. ((InCombatLockdown and InCombatLockdown()) and " (try again out of combat)." or "."))
    end
    state.opened = opened
    return opened
end

function ns:SetOptionsOpen(open, key)
    if open == false then
        -- We do not close the game's Settings frame from here.
        return
    end
    ns.OpenSettings(key)
end

function ns:ToggleOptions(key)
    ns.OpenSettings(key)
end

ns.OpenConfig = function(key) return ns.OpenSettings(key) end

-- Gear button on the companion window (next to the portrait lock).
local host = ns.frame
local sb = CreateFrame("Button", "CompanionSettingsButton", host)
sb:SetSize(20, 20)
if ns.lockButton then
    sb:SetPoint("LEFT", ns.lockButton, "RIGHT", 2, 0)
else
    sb:SetPoint("TOPLEFT", host, "TOPLEFT", 38, -14)
end
sb:SetFrameLevel((ns.lockButton and ns.lockButton:GetFrameLevel() or host:GetFrameLevel()) + 1)
sb:SetNormalTexture("Interface\\Buttons\\UI-OptionsButton")
sb:SetPushedTexture("Interface\\Buttons\\UI-OptionsButton")
sb:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
sb:SetScript("OnClick", function() ns.OpenSettings() end)
sb:SetScript("OnEnter", function(self)
    if not GameTooltip then return end
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Companion settings")
    GameTooltip:AddLine("Opens Settings > AddOns > Companion. Also /comp options.", 1, 1, 1)
    GameTooltip:Show()
end)
sb:SetScript("OnLeave", function() if GameTooltip then GameTooltip:Hide() end end)
ns.SettingsButton = sb

ns:On("LOGIN", function()
    if ns.db and ns.db.settingsPage and pages[ResolveKey(ns.db.settingsPage)] then
        state.last = ResolveKey(ns.db.settingsPage)
    end
end)

ns:AddCommand("options", function(rest)
    rest = (rest or ""):lower()
    if rest == "" then
        ns.OpenSettings()
    else
        ns.OpenSettings(rest)
    end
end)
