-- Companion module: Quest Helper. Uses the shared Companion table (this file is a separate addon; `ns` is not shared automatically).
-- Companion: Guide section at the bottom of the companion window (below her portrait).
-- Shows the guide name and progress, the current step (full text), the next two steps,
-- and Prev / Next plus the quest item button (QuestItem.lua). Hidden (and the window shrinks)
-- when the guide is off. Toggle with /comp guide. 0.48: Skip merged into Next (G.Skip was
-- already G.Next); the section can dock under the quest tracker (/comp guide dock tracker).

local ns = _G.Companion
if not ns then return end
local G = ns.guide
local L = ns.LAYOUT
local PAD     = 4
local BTN_H   = 18
local SEC_W   = L.WIN_W - L.SIDE_PAD * 2      -- 256
local host    = ns.frame

ns.defaults.guideDock = "companion"   -- or "tracker"
ns.defaults.guideNearbyObjectives = true
ns.defaults.guideNearbyMax = 5
ns.defaults.guideNearbyRadius = 8
local section = CreateFrame("Frame", "CompanionGuideSection", host, "BackdropTemplate")
section:SetWidth(SEC_W)
section:SetPoint("TOP", host, "TOP", 0, L.MODEL_TOP - ns.MODEL_H - 2)
ns.GUIDE_SEC_W = SEC_W
section:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 10,
    insets = { left = 2, right = 2, top = 2, bottom = 2 },
})
section:SetBackdropColor(0, 0, 0, 0.35)
section:SetBackdropBorderColor(0.6, 0.5, 0.3, 0.6)
section:Hide()
ns.GuidePanel = section          -- kept name so older callers still find it

local header = section:CreateFontString(nil, "OVERLAY", "GameFontNormal")
header:SetPoint("TOPLEFT", PAD + 4, -6)
header:SetPoint("RIGHT", section, "RIGHT", -PAD - 4, 0)
header:SetJustifyH("LEFT")

local lines = {}
for i = 1, 3 do
    local fs = section:CreateFontString(nil, "OVERLAY", i == 1 and "GameFontHighlight" or "GameFontDisableSmall")
    fs:SetJustifyH("LEFT")
    fs:SetWordWrap(true)
    fs:SetWidth(SEC_W - (PAD + 4) * 2)
    lines[i] = fs
end
lines[1]:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -4)
lines[2]:SetPoint("TOPLEFT", lines[1], "BOTTOMLEFT", 0, -4)
lines[3]:SetPoint("TOPLEFT", lines[2], "BOTTOMLEFT", 0, -2)

local function Height(fs)
    local ok, h = pcall(fs.GetStringHeight, fs)
    return (ok and type(h) == "number") and h or 12
end

-- 0.52: "Also here" - other objectives nearby, with live counts
local alsoHead = section:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
alsoHead:SetPoint("TOPLEFT", lines[3], "BOTTOMLEFT", 0, -4)
alsoHead:SetJustifyH("LEFT")
alsoHead:SetText("Also here")
alsoHead:Hide()
local also = {}
for i = 1, 8 do
    local fs = section:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    fs:SetJustifyH("LEFT")
    fs:SetWidth(SEC_W - (PAD + 4) * 2 - 8)
    fs:SetPoint("TOPLEFT", i == 1 and alsoHead or also[i - 1], "BOTTOMLEFT", i == 1 and 8 or 0, -1)
    fs:Hide()
    also[i] = fs
end

local function PlayerMapPos()
    if not (C_Map and C_Map.GetBestMapForUnit and C_Map.GetPlayerMapPosition) then return nil end
    local ok, mapID = pcall(C_Map.GetBestMapForUnit, "player")
    if not ok or not mapID then return nil end
    local ok2, pos = pcall(C_Map.GetPlayerMapPosition, mapID, "player")
    if not ok2 or not pos then return nil end
    local x, y = pos.x, pos.y
    if not x and pos.GetXY then x, y = pos:GetXY() end
    if not x then return nil end
    return x * 100, y * 100, mapID
end

-- returns the extra height used
local function UpdateAlso(cur)
    local list = {}
    if ns.db.guideNearbyObjectives ~= false and cur and G.NearbyObjectives then
        local px, py, m = PlayerMapPos()
        list = G.NearbyObjectives(px, py, m, { radius = ns.db.guideNearbyRadius or 8, max = math.min(8, ns.db.guideNearbyMax or 5) })
    end
    alsoHead:SetShown(#list > 0)
    local h = 0
    for i = 1, 8 do
        local e = list[i]
        if e then
            also[i]:SetText(e.need and string.format("%s |cffffffff%d/%d|r", e.text, e.have or 0, e.need) or e.text)
            also[i]:Show()
            h = h + Height(also[i]) + 1
        else
            also[i]:SetText(""); also[i]:Hide()
        end
    end
    if #list > 0 then h = h + 4 + Height(alsoHead) end
    return h
end

local function Button(label, x, onClick)
    local b = CreateFrame("Button", nil, section, "UIPanelButtonTemplate")
    b:SetSize(56, BTN_H)
    b:SetPoint("BOTTOMLEFT", x, 5)
    b:SetText(label)
    b:SetScript("OnClick", onClick)
    return b
end
Button("Prev", PAD + 4, function() G.Prev() end)
local stepNextBtn = Button("Next", PAD + 64, function() G.Next() end)
ns.GuideNextButton = stepNextBtn
ns.GUIDE_ITEM_X = PAD + 124   -- the quest item button sits where Skip used to be
local nextBtn = CreateFrame("Button", nil, section, "UIPanelButtonTemplate")
nextBtn:SetSize(120, BTN_H)
nextBtn:SetPoint("BOTTOMLEFT", PAD + 64, 5)
nextBtn:SetText("Start next guide")
nextBtn:SetScript("OnClick", function() G.StartNext() end)
nextBtn:Hide()
ns.NextGuideButton = nextBtn


-- True when the guide section is visible and has a step (used by navigation text).
function ns.GuideSectionActive()
    if ns.IsModuleEnabled and not ns.IsModuleEnabled("questhelper") then return false end
    return ns.db and ns.db.guideShown and G.active ~= nil
end

function ns.UpdateGuidePanel()
    if not ns.db then return end
    if not ns.GuideSectionActive() then
        section:Hide()
        if ns.SetBottomSectionHeight then ns.SetBottomSectionHeight(0) end
        return
    end
    section:Show()
    local steps = G.active.steps
    local cur = G.Current()
    header:SetText(string.format("%s  |cffaaaaaa%d/%d|r", G.active.name, math.min(G.step, #steps), #steps))
    if cur then
        lines[1]:SetText("|cffffd100>|r " .. G.StepText(cur, true))
    else
        local n = G.NextGuideName and G.NextGuideName()
        lines[1]:SetText("|cff20ff20Guide complete!|r" .. (n and (" Next: " .. n) or ""))
    end
    local offerNext = cur == nil and G.NextGuideName and G.NextGuideName() ~= nil
    nextBtn:SetShown(offerNext)
    stepNextBtn:SetShown(not offerNext)
    local up = G.Upcoming(2)
    for i = 2, 3 do
        local s = up[i - 1]
        lines[i]:SetText(s and ("  " .. G.StepText(s)) or "")
    end
    local h = 6 + 14 + 4 + Height(lines[1]) + 4 + Height(lines[2]) + 2 + Height(lines[3]) + 6 + BTN_H + 5
    h = h + UpdateAlso(cur)
    section:SetHeight(h)
    if ns.SetBottomSectionHeight then ns.SetBottomSectionHeight(ns.GuideDock() == "companion" and (h + 4) or 0) end
    if ns.UpdateQuestItemButton then ns.UpdateQuestItemButton() end
end

-- ===================== DOCK (0.48) =====================
function ns.GuideDock()
    return (ns.db and ns.db.guideDock == "tracker" and ns.Tracker) and "tracker" or "companion"
end
local function SetWidths(w)
    section:SetWidth(w)
    for i = 1, 3 do lines[i]:SetWidth(w - (PAD + 4) * 2) end
    for i = 1, #also do also[i]:SetWidth(w - (PAD + 4) * 2 - 8) end
end
function ns.ApplyGuideDock()
    if InCombatLockdown and InCombatLockdown() then ns.guideDockPending = true return false end
    ns.guideDockPending = nil
    section:ClearAllPoints()
    if ns.GuideDock() == "tracker" then
        section:SetParent(ns.Tracker)
        section:SetPoint("TOPLEFT", ns.Tracker, "BOTTOMLEFT", 0, -2)
        SetWidths(ns.Tracker:GetWidth() or 240)
    else
        section:SetParent(host)
        if L.GUIDE_TOP then   -- round window style: under the circle
            section:SetPoint("TOPLEFT", host, "TOPLEFT", 0, L.GUIDE_TOP)
        else
            section:SetPoint("TOP", host, "TOP", 0, L.MODEL_TOP - ns.MODEL_H - 2)
        end
        SetWidths(SEC_W)
    end
    ns.UpdateGuidePanel()
    return true
end
function ns.SetGuideDock(where)
    if where ~= "tracker" then where = "companion" end
    ns.db.guideDock = where
    if where == "tracker" and ns.Tracker and not ns.db.trackerShown and ns.SetTrackerShown then ns:SetTrackerShown(true) end
    if not ns.ApplyGuideDock() then ns.Print("guide will move after combat.") end
end
ns:On("PLAYER_REGEN_ENABLED", function() if ns.guideDockPending then ns.ApplyGuideDock() end end)

ns:On("LOGIN", function()
    ns.db.guidePoint = nil       -- the old floating panel's position is no longer used
    ns.ApplyGuideDock()
end)
ns:On("QUEST_LOG_UPDATE", function() ns.UpdateGuidePanel() end)
ns:On("BAG_UPDATE_DELAYED", function() ns.UpdateGuidePanel() end)
-- light position refresh for "Also here" (only while the list is on and the guide is shown)
ns:On("LOGIN", function()
    if C_Timer and C_Timer.NewTicker then
        C_Timer.NewTicker(2, function()
            if ns.db and ns.db.guideNearbyObjectives ~= false and ns.GuideSectionActive() then ns.UpdateGuidePanel() end
        end)
    end
end)
