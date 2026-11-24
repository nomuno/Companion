-- Companion module: Quest Helper. Uses the shared Companion table (this file is a separate addon; `ns` is not shared automatically).
-- Companion: Quest tracker window.
-- Lists active quests and their objectives, updated live from ns.quests.

local ns = _G.Companion
if not ns then return end
ns.defaults.trackerShown = true
ns.defaults.trackerPoint = { "TOPRIGHT", -220, -220 }
ns.defaults.hideDefaultTracker = false
ns.defaults.trackerCollapsed = {}
ns.defaults.trackerMaxQuests = 10   -- 0.38: quests visible at once; the rest scroll

local WIDTH, ROW_H, PAD = 240, 14, 10
local MAX_ROWS = 150
local function MaxQuests()
    if C_QuestLog and C_QuestLog.GetMaxNumQuestsCanAccept then
        local ok, n = pcall(C_QuestLog.GetMaxNumQuestsCanAccept)
        if ok and type(n) == "number" and n > 0 then return n end
    end
    return 40
end

local tracker = CreateFrame("Frame", "CompanionTracker", UIParent, "BackdropTemplate")
tracker:SetSize(WIDTH, 60)
tracker:SetMovable(true)
tracker:EnableMouse(true)
tracker:RegisterForDrag("LeftButton")
tracker:SetClampedToScreen(true)
tracker:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 },
})
tracker:SetBackdropColor(0, 0, 0, 0.55)
tracker:SetBackdropBorderColor(0.6, 0.5, 0.3, 0.8)
tracker:Hide()
ns.Tracker = tracker

tracker:SetScript("OnDragStart", tracker.StartMoving)
tracker:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, _, _, x, y = self:GetPoint()
    ns.db.trackerPoint = { point, x, y }
end)

local header = tracker:CreateFontString(nil, "OVERLAY", "GameFontNormal")
header:SetPoint("TOPLEFT", PAD, -8)
header:SetText("Quests")

local count = tracker:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
count:SetPoint("TOPRIGHT", -PAD, -9)

-- Pool of reusable text rows. Quest title rows are clickable to collapse.
local rows = {}
local function GetRow(i)
    local row = rows[i]
    if not row then
        row = CreateFrame("Button", nil, tracker)
        row:SetHeight(ROW_H)
        row.text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        row.text:SetAllPoints()
        row.text:SetJustifyH("LEFT")
        row.text:SetWordWrap(false)
        row:SetScript("OnClick", function(self)
            if self.questID then
                ns.db.trackerCollapsed[self.questID] = not ns.db.trackerCollapsed[self.questID] or nil
                ns:RefreshTracker()
            end
        end)
        rows[i] = row
    end
    return row
end

local function Color(r, g, b) return string.format("|cff%02x%02x%02x", r * 255, g * 255, b * 255) end

local function SortedQuests()
    local list = {}
    for _, q in pairs(ns.quests) do table.insert(list, q) end
    table.sort(list, function(a, b)
        if a.complete ~= b.complete then return a.complete end   -- turn-ins first
        if (a.level or 0) ~= (b.level or 0) then return (a.level or 0) < (b.level or 0) end
        return (a.title or "") < (b.title or "")
    end)
    return list
end

-- 0.38: the list is built as logical lines (one per quest title/objective); only the lines of
-- trackerMaxQuests quests starting at the scroll offset get pooled rows. The wheel moves by quest.
local scrollQ = 0         -- index of the first visible quest (0-based)
local lastQuestCount = 0
ns.trackerScroll = function() return scrollQ end

local upMark = tracker:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
upMark:SetPoint("TOP", 0, -9)
upMark:SetText("|cffaaaaaa^ more|r")
upMark:Hide()
local downMark = tracker:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
downMark:SetPoint("BOTTOM", 0, 2)
downMark:SetText("|cffaaaaaav more|r")
downMark:Hide()
-- slim scrollbar thumb on the right edge
local bar = tracker:CreateTexture(nil, "OVERLAY")
bar:SetColorTexture(0.8, 0.7, 0.4, 0.6)
bar:SetWidth(3)
bar:Hide()
tracker.upMark, tracker.downMark, tracker.bar = upMark, downMark, bar

local function MaxVisible()
    local m = tonumber(ns.db and ns.db.trackerMaxQuests) or 10
    if m < 1 then m = 1 end
    return math.floor(m)
end

function ns:RefreshTracker()
    if not tracker:IsShown() then return end
    local n = 0
    local playerLevel = UnitLevel("player")

    local function AddLine(text, indent, questID)
        if n >= MAX_ROWS then return end
        n = n + 1
        local row = GetRow(n)
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", PAD + indent, -26 - (n - 1) * ROW_H)
        row:SetPoint("RIGHT", tracker, "RIGHT", -PAD - 4, 0)
        row.text:SetText(text)
        row.questID = questID
        row:EnableMouse(questID ~= nil)
        row:Show()
    end

    local list = SortedQuests()
    local total, maxV = #list, MaxVisible()
    lastQuestCount = total
    local maxScroll = math.max(0, total - maxV)
    if scrollQ > maxScroll then scrollQ = maxScroll end    -- list shrank: clamp
    if scrollQ < 0 then scrollQ = 0 end

    for qi = scrollQ + 1, math.min(total, scrollQ + maxV) do
        local q = list[qi]
        local lc = GetQuestDifficultyColor and GetQuestDifficultyColor(q.level or playerLevel)
        local titleColor = lc and Color(lc.r, lc.g, lc.b) or "|cffffd100"
        local collapsed = ns.db.trackerCollapsed[q.id]
        local suffix = q.complete and " |cff20ff20(Turn in)|r" or ""
        AddLine(string.format("%s[%d] %s|r%s%s", titleColor, q.level or 0, q.title or "?", suffix,
            collapsed and " |cff888888+|r" or ""), 0, q.id)
        if not collapsed and not q.complete then
            for _, o in ipairs(q.objectives) do
                AddLine((o.done and "|cff20ff20" or "|cffcccccc") .. "- " .. (o.text or "") .. "|r", 8)
            end
        end
    end

    if n == 0 then AddLine("|cff888888No quests. Go find some!|r", 0) end
    for i = n + 1, #rows do rows[i]:Hide() end
    tracker.visibleRows = n
    count:SetText(total .. "/" .. MaxQuests())
    local h = 26 + n * ROW_H + 8 + (maxScroll > 0 and 10 or 0)
    tracker:SetHeight(h)
    upMark:SetShown(scrollQ > 0)
    downMark:SetShown(scrollQ < maxScroll)
    if maxScroll > 0 then
        local trackH = h - 34
        local thumb = math.max(10, trackH * maxV / total)
        bar:ClearAllPoints()
        bar:SetHeight(thumb)
        bar:SetPoint("TOPRIGHT", tracker, "TOPRIGHT", -4, -26 - (trackH - thumb) * scrollQ / maxScroll)
        bar:Show()
    else
        bar:Hide()
    end
end

function ns.TrackerScroll(delta)   -- delta > 0 scrolls up (wheel up), by one quest
    local maxScroll = math.max(0, lastQuestCount - MaxVisible())
    local new = math.max(0, math.min(maxScroll, scrollQ - (delta or 0)))
    if new ~= scrollQ then scrollQ = new; ns:RefreshTracker() end
    return scrollQ
end
tracker:EnableMouseWheel(true)
tracker:SetScript("OnMouseWheel", function(_, delta) ns.TrackerScroll(delta) end)
function ns.SetTrackerMaxQuests(v)
    ns.db.trackerMaxQuests = math.floor(tonumber(v) or 10)
    ns:RefreshTracker()
end

-- Default Blizzard tracker.
-- Do not hook Show/OnShow to call Hide: that runs inside Blizzard's Show at login
-- (quest watch, party/raid layout) and is a common ADDON_ACTION_FORBIDDEN cause.
-- Keep it hidden with RegisterStateDriver (out of combat) instead.
local function trackerLocked()
    return InCombatLockdown and InCombatLockdown() == true
end
local function ApplyDefaultTrackerVisibility()
    local frames = { ObjectiveTrackerFrame, QuestWatchFrame, WatchFrame }
    if trackerLocked() then
        ns._trackerVisPending = true
        return
    end
    for _, blizz in pairs(frames) do
        if blizz then
            if ns.db.hideDefaultTracker then
                local ok = false
                if RegisterStateDriver then
                    ok = pcall(RegisterStateDriver, blizz, "visibility", "hide")
                end
                if not ok then
                    -- one-shot Hide from our event handler, never from a Show hook
                    pcall(blizz.Hide, blizz)
                end
            else
                if UnregisterStateDriver then
                    pcall(UnregisterStateDriver, blizz, "visibility")
                end
                if ns._trackerVisRestore then pcall(blizz.Show, blizz) end
            end
        end
    end
end
ns.ApplyDefaultTrackerVisibility = ApplyDefaultTrackerVisibility

function ns:SetTrackerShown(shown)
    ns.db.trackerShown = shown
    if ns.IsModuleEnabled and not ns.IsModuleEnabled("questhelper") then shown = false end
    tracker:SetShown(shown)
    if shown then ns:RefreshTracker() end
end

-- Refresh a moment after quest changes so the log has settled.
local pending = false
local function QueueRefresh()
    if pending then return end
    pending = true
    C_Timer.After(0.2, function()
        pending = false
        ns.ScanQuestLog()
        ns:RefreshTracker()
    end)
end

ns:On("LOGIN", function()
    local p = ns.db.trackerPoint
    tracker:ClearAllPoints()
    tracker:SetPoint(p[1], UIParent, p[1], p[2], p[3])
    ns:SetTrackerShown(ns.db.trackerShown)
    ApplyDefaultTrackerVisibility()
end)
ns:On("QUEST_LOG_UPDATE", QueueRefresh)
ns:On("UNIT_QUEST_LOG_CHANGED", QueueRefresh)
ns:On("PLAYER_LEVEL_UP", QueueRefresh)
ns:On("PLAYER_ENTERING_WORLD", function() C_Timer.After(1, ApplyDefaultTrackerVisibility) end)
ns:On("PLAYER_REGEN_ENABLED", function() if ns._trackerVisPending then ns._trackerVisPending = nil ApplyDefaultTrackerVisibility() end end)

function ns.SetHideDefaultTracker(on)
    ns.db.hideDefaultTracker = on and true or false
    ns._trackerVisRestore = not ns.db.hideDefaultTracker
    ApplyDefaultTrackerVisibility()
    ns._trackerVisRestore = nil
end
ns:AddCommand("tracker", function()
    ns:SetTrackerShown(not tracker:IsShown())
end)
