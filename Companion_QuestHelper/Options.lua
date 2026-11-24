-- Options for the Quest Helper module. Builds Settings window pages and a Blizzard AddOns subcategory.
local ns = _G.Companion
if not ns then return end

ns.RegisterModule("questhelper", {
    title = "Quest Helper",
    addon = "Companion_QuestHelper",
    OnSetEnabled = function(on)
        if on then
            if ns.db and ns.db.guideShown and ns.SetGuideShown then ns.SetGuideShown(true) end
            if ns.db and ns.db.trackerShown and ns.SetTrackerShown then ns:SetTrackerShown(true) end
            if ns.UpdateGuidePanel then pcall(ns.UpdateGuidePanel) end
        else
            local db = ns.db or {}
            local gs, ts = db.guideShown, db.trackerShown
            if ns.SetGuideShown then ns.SetGuideShown(false) end
            if ns.SetTrackerShown then ns:SetTrackerShown(false) end
            db.guideShown, db.trackerShown = gs, ts
            if ns.GuidePanel and ns.GuidePanel.Hide then ns.GuidePanel:Hide() end
            if ns.trackerFrame and ns.trackerFrame.Hide then ns.trackerFrame:Hide() end
            if ns.QuestItemButton and ns.QuestItemButton.Hide then ns.QuestItemButton:Hide() end
        end
    end,
})

local function Fill()
Header("Guide", "guide", "Quest Helper")
ModuleEnableCheckbox("questhelper")

Check("Show guide", "guideShown", ns.SetGuideShown)
Cycle("Show the guide on", 160, { "companion", "tracker" },
    function() return ns.db.guideDock or "companion" end,
    function(v) ns.SetGuideDock(v) end, "guideDock")
local pickGuide
local function ActiveName() return ns.guide and ns.guide.active and ns.guide.active.name end
ns.configPickGuide = function(v) if v then pickGuide = v end return pickGuide end
local function LoadGuide(name)
    if name and ns.guide then
        pickGuide = name
        ns.db.guideShown = true
        ns.guide.Load(name)
        ns.Print("guide loaded: " .. name)
        if ns.UpdateGuidePanel then ns.UpdateGuidePanel() end
    end
    ns.RefreshConfig()
end
-- 0.52: scrollable guide list with Horde/Alliance tabs and search; used by Guides and Dungeons
local function GuideList(label, getNames, key)
    -- 0.52: scrollable guide list (replaces the click-through Cycle picker)
    local showFaction, filterText = nil, ""
    local FillList
    Text(label, "GameFontNormal")
    y = y - 18
    local search = TryCreate("EditBox", NextName("Search"), content, "InputBoxTemplate")
    search:SetSize(180, 20)
    search:SetPoint("TOPLEFT", LEFT + 52, y)
    search:SetAutoFocus(false)
    local sLbl = content:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    sLbl:SetPoint("TOPLEFT", LEFT, y - 4)
    sLbl:SetText("Search:")
    y = y - 26
    -- 0.52: Horde / Alliance tabs above the list
    local tabs = {}
    local function SelectTab(f) showFaction = f for _, t in ipairs(tabs) do
        if t.faction == f then
            if PanelTemplates_SelectTab then safe(PanelTemplates_SelectTab, t) end
            t:LockHighlight() if t:GetFontString() then t:GetFontString():SetTextColor(1, 0.82, 0) end
        else
            if PanelTemplates_DeselectTab then safe(PanelTemplates_DeselectTab, t) end
            t:UnlockHighlight() if t:GetFontString() then t:GetFontString():SetTextColor(0.8, 0.8, 0.8) end
        end
    end end
    for i, f in ipairs({ "Horde", "Alliance" }) do
        local t = TryCreate("Button", NextName("GuideTab"), content, "TabButtonTemplate", "UIPanelButtonTemplate")
        t:SetText(f)
        t:SetSize(90, 22)
        if PanelTemplates_TabResize then safe(PanelTemplates_TabResize, t, 0, 90) end
        t:SetPoint("TOPLEFT", LEFT + (i - 1) * 94, y)
        t.faction = f
        tabs[i] = t
    end
    y = y - 22
    local ROW_H, ROWS = 18, 10
    local LIST_W = PANEL_W - 2 * LEFT - 26
    local box = CreateFrame("Frame", nil, content)
    box:SetPoint("TOPLEFT", LEFT, y)
    box:SetSize(LIST_W + 22, ROW_H * ROWS + 6)
    local bg = box:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0, 0, 0, 0.35)
    local sf = TryCreate("ScrollFrame", NextName("GuideScroll"), box, "UIPanelScrollFrameTemplate")
    sf:SetPoint("TOPLEFT", 3, -3)
    sf:SetPoint("BOTTOMRIGHT", -24, 3)
    local child = CreateFrame("Frame", nil, sf)
    child:SetSize(LIST_W, ROW_H)
    sf:SetScrollChild(child)
    y = y - (ROW_H * ROWS + 6) - 8
    local rows = {}
    local function FactionKey(g)
        local f = g.faction
        if type(f) == "table" then return "Both" end
        return f or "Any"
    end
    local function BuildList()
        if not showFaction then
            local me = UnitFactionGroup and safe(UnitFactionGroup, "player")
            SelectTab(me == "Alliance" and "Alliance" or "Horde")
        end
        local list = {}
        local filt = (filterText or ""):lower()
        for _, name in ipairs(ns.guide and getNames() or {}) do
            local g = ns.guide.Get and ns.guide.Get(name) or {}
            local fk = FactionKey(g)
            local mine = (fk == showFaction) or fk == "Both" or fk == "Any"
            if mine and (filt == "" or name:lower():find(filt, 1, true)) then
                table.insert(list, { name = name, fk = fk, mine = mine, lo = g.minLevel or 1, hi = g.maxLevel or 60 })
            end
        end
        table.sort(list, function(a, b)
            if a.fk ~= b.fk then return a.fk < b.fk end
            if a.lo ~= b.lo then return a.lo < b.lo end
            return a.name < b.name
        end)
        return list
    end
    FillList = function()
        local list = BuildList()
        local active = ActiveName()
        for i, e in ipairs(list) do
            local r = rows[i]
            if not r then
                r = CreateFrame("Button", nil, child)
                r:SetSize(LIST_W, ROW_H)
                r:SetPoint("TOPLEFT", 0, -(i - 1) * ROW_H)
                r.hl = r:CreateTexture(nil, "BACKGROUND")
                r.hl:SetAllPoints()
                r.hover = r:CreateTexture(nil, "HIGHLIGHT")
                r.hover:SetAllPoints()
                r.hover:SetColorTexture(1, 1, 1, 0.1)
                r.name = r:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
                r.name:SetPoint("LEFT", 6, 0)
                r.name:SetJustifyH("LEFT")
                r.lvl = r:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
                r.lvl:SetPoint("RIGHT", -6, 0)
                r:SetScript("OnClick", function(self) LoadGuide(self.guideName) end)
                rows[i] = r
            end
            r.guideName = e.name
            r.name:SetText(e.name)
            r.lvl:SetText(string.format("|cff999999%s|r  %d-%d", e.fk, e.lo, e.hi))
            if e.name == active then
                r.hl:SetColorTexture(1, 0.82, 0, 0.25)
                r.name:SetTextColor(1, 0.82, 0)
            else
                r.hl:SetColorTexture(0, 0, 0, 0)
                r.name:SetTextColor(1, 1, 1)
            end
            r:Show()
        end
        for i = #list + 1, #rows do rows[i]:Hide() end
        child:SetHeight(math.max(ROW_H, #list * ROW_H))
    end
    for _, t in ipairs(tabs) do t:SetScript("OnClick", function(self) SelectTab(self.faction) FillList() end) end
    search:SetScript("OnTextChanged", function(self) filterText = self:GetText() or "" FillList() end)
    search:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    search:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
    Register({ kind = "list", key = key, refresh = function() FillList() end, rows = rows, tabs = tabs })
end
GuideList("Guides (click a row to load it):", function() return ns.guide.List() end, "guide")
local status = Text("", "GameFontHighlightSmall")
Register({ kind = "text", refresh = function()
    local g = ns.guide
    if g and g.active then
        status:SetText(string.format("Active: %s, step %d of %d", g.active.name, g.step or 1, #g.active.steps))
    else
        status:SetText("No guide loaded.")
    end
end })
y = y - 20
ns.configResetGuide = Button("Reset progress...", 150, function() Confirm("COMPANION_RESET_GUIDE") end)
Button("Unload", 100, function() if ns.guide then ns.guide.Unload() end ns.RefreshConfig() end, LEFT + 160)
y = y - 30
Check("Show other objectives in this area", "guideNearbyObjectives", function(on) ns.db.guideNearbyObjectives = on if ns.UpdateGuidePanel then ns.UpdateGuidePanel() end end)
Slider("Other objectives shown", "guideNearbyMax", 3, 8, 1, function(v) ns.db.guideNearbyMax = v if ns.UpdateGuidePanel then ns.UpdateGuidePanel() end end, "%d", 5)
Check("Auto-accept quests (hold Shift to skip)", "autoAccept")
Check("Auto-turn-in quests (stops on reward choices)", "autoTurnIn")
y = y - 6

-- Dungeons (0.52): pickup-only dungeon guides
Header("Dungeons", "guide")
Text("Click a dungeon to load it as a guide. It only picks up the dungeon's quests (and the quests that unlock them); the turn-ins happen with your group.", "GameFontHighlightSmall")
y = y - 30
GuideList("Dungeons (click a row to load it):", function() return ns.guide.DungeonList and ns.guide.DungeonList() or {} end, "dungeonList")

-- Tracker
Header("Quest tracker", "guide")
Check("Show Companion quest tracker", "trackerShown", function(on) ns:SetTrackerShown(on) end)
Check("Hide Blizzard's quest tracker", "hideDefaultTracker", ns.SetHideDefaultTracker)
Slider("Quests shown before scrolling", "trackerMaxQuests", 3, 25, 1, function(v) ns.SetTrackerMaxQuests(v) end, "%d", 10)

Header("Quest recorder", "guide")
local recText = Text("", "GameFontHighlight")
Register({ kind = "text", refresh = function()
    recText:SetText(string.format("%d quests recorded on this account. Export them to share with the guide author.", ns.RecordCount()))
end })
y = y - 22
Button("Export...", 120, function() ns.RunCommand("export") end)
ns.configClearRecords = Button("|cffff5050Clear recorded data...|r", 180, function() Confirm("COMPANION_CLEAR_RECORDS") end, LEFT + 130)
y = y - 30

end

if ns.BindOptEnv then ns.BindOptEnv(Fill) end
Fill()
