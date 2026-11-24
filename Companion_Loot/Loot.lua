-- Companion module: Loot. Uses the shared Companion table (this file is a separate addon; `ns` is not shared automatically).
-- Loot.lua (0.58): movable anchor for group loot roll frames (Need/Greed/Pass), so they no
-- longer stack over the action bars. Our own code.
-- GroupLootContainer (or GroupLootFrame1..N when there is no container) is re-anchored to our
-- anchor; when the client moves it back (UIParent layout / container update) a SetPoint hook
-- re-applies our position, guarded against loops. Roll frames are not protected on Classic, but
-- if the client ever reports them protected, changes wait until combat ends.
local ns = _G.Companion
if not ns then return end
local L = {}
ns.Loot = L

ns.defaults.lootLocked = true
ns.defaults.lootScale = 1.0
-- ns.db.lootPos = { point, relPoint, x, y } (nil = default spot)

L.DEFAULT_POS = { "BOTTOM", "BOTTOM", 0, 260 }
L.SCALE_MIN, L.SCALE_MAX = 0.5, 2.0
local MAX_FRAMES = 4

local function safe(fn, ...) if not fn then return nil end local ok, a, b = pcall(fn, ...) if ok then return a, b end end
local function locked() return InCombatLockdown and safe(InCombatLockdown) == true end
local function isProtected(f) return f and f.IsProtected and safe(f.IsProtected, f) == true end

local anchor
local function Anchor()
    if anchor then return anchor end
    anchor = CreateFrame("Frame", "CompanionLootAnchor", UIParent, "BackdropTemplate")
    anchor:SetSize(260, 22)
    anchor:SetFrameStrata("MEDIUM")
    anchor:SetClampedToScreen(true)
    anchor:SetMovable(true)
    if anchor.SetBackdrop then
        anchor:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 12, insets = { left = 3, right = 3, top = 3, bottom = 3 } })
        anchor:SetBackdropColor(0.1, 0.1, 0.1, 0.85)
    end
    local t = anchor:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    t:SetPoint("CENTER")
    t:SetText("Loot rolls - drag to move")
    anchor.title = t
    anchor:RegisterForDrag("LeftButton")
    anchor:SetScript("OnDragStart", function(self) if not ns.db.lootLocked then self:StartMoving() end end)
    anchor:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local p, _, rp, x, y = self:GetPoint(1)
        ns.db.lootPos = { p, rp, math.floor((x or 0) + 0.5), math.floor((y or 0) + 0.5) }
        L.Apply()
    end)
    return anchor
end
L.Anchor = Anchor

function L.Position()
    local pos = ns.db and ns.db.lootPos
    if type(pos) ~= "table" or type(pos[1]) ~= "string" then pos = L.DEFAULT_POS end
    return pos
end
function L.Scale()
    local v = tonumber(ns.db and ns.db.lootScale) or 1
    return math.max(L.SCALE_MIN, math.min(L.SCALE_MAX, v))
end

-- Which frames to move: the container, else the individual roll frames.
function L.Targets()
    if GroupLootContainer then return { GroupLootContainer }, true end
    local out = {}
    for i = 1, (NUM_GROUP_LOOT_FRAMES or MAX_FRAMES) do
        local f = _G["GroupLootFrame" .. i]
        if f then out[#out + 1] = f end
    end
    return out, false
end

local applying = false
-- Anchor every target; frames stack upward from the anchor's top edge.
function L.Place()
    if applying then return false end
    local targets, container = L.Targets()
    for _, f in ipairs(targets) do
        if isProtected(f) and locked() then L.pending = true return false end
    end
    applying = true
    local a = Anchor()
    local prev = a
    for _, f in ipairs(targets) do
        f:ClearAllPoints()
        f:SetPoint("BOTTOM", prev, "TOP", 0, container and 2 or 4)
        if f.SetScale then f:SetScale(L.Scale()) end
        if not container then prev = f end
    end
    applying = false
    L.pending = nil
    return true
end

local hooked = {}
local function Hook(f)
    if not f or hooked[f] or not hooksecurefunc then return end
    hooked[f] = true
    hooksecurefunc(f, "SetPoint", function(self)
        if applying then return end
        local _, rel = self:GetPoint(1)
        local wantRel = (GroupLootContainer and self == GroupLootContainer) and Anchor() or nil
        if wantRel and rel == wantRel then return end
        if not GroupLootContainer and rel ~= nil then
            -- individual frames: ours point at the anchor or at the previous roll frame
            local name = rel and rel.GetName and rel:GetName()
            if rel == anchor or (type(name) == "string" and name:match("^GroupLootFrame%d+$")) then return end
        end
        L.Place()
    end)
end

function L.Apply()
    if not ns.db then return end
    if ns.IsModuleEnabled and not ns.IsModuleEnabled("loot") then
        if anchor then anchor:Hide() end
        return
    end
    local a = Anchor()
    local pos = L.Position()
    a:ClearAllPoints()
    a:SetPoint(pos[1], UIParent, pos[2], pos[3], pos[4])
    a:SetScale(L.Scale())
    local unlocked = not ns.db.lootLocked
    a:EnableMouse(unlocked)
    a:Show()
    a:SetAlpha(unlocked and 1 or 0)   -- locked: invisible, still the anchor
    for _, f in ipairs((L.Targets())) do Hook(f) end
    L.Place()
end

-- ===== preview =====
local preview = {}
function L.Test(n)
    n = n or 3
    local a = Anchor()
    if ns.db.lootLocked then a:SetAlpha(0.6) end
    local icons = { 135274, 132940, 134937, 133071 }
    for i = 1, n do
        local f = preview[i]
        if not f then
            f = CreateFrame("Frame", nil, a, "BackdropTemplate")
            f:SetSize(250, 44)
            if f.SetBackdrop then
                f:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                    edgeSize = 14, insets = { left = 4, right = 4, top = 4, bottom = 4 } })
                f:SetBackdropColor(0, 0, 0, 0.8)
            end
            f.icon = f:CreateTexture(nil, "ARTWORK")
            f.icon:SetSize(32, 32)
            f.icon:SetPoint("LEFT", 6, 0)
            f.text = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            f.text:SetPoint("LEFT", f.icon, "RIGHT", 8, 0)
            preview[i] = f
        end
        f:ClearAllPoints()
        f:SetPoint("BOTTOM", a, "TOP", 0, 4 + (i - 1) * 48)
        f.icon:SetTexture(icons[(i - 1) % #icons + 1])
        f.text:SetText("Test roll " .. i .. " (preview)")
        f:Show()
    end
    for i = n + 1, #preview do preview[i]:Hide() end
    L.previewShown = n
    if C_Timer and C_Timer.After then
        C_Timer.After(10, function() L.HideTest() end)
    end
    return n
end
function L.HideTest()
    for _, f in ipairs(preview) do f:Hide() end
    L.previewShown = 0
    if ns.db and ns.db.lootLocked and anchor then anchor:SetAlpha(0) end
end

function ns.SetLootLocked(on) ns.db.lootLocked = on and true or false L.Apply() end
function ns.SetLootScale(v) ns.db.lootScale = math.max(L.SCALE_MIN, math.min(L.SCALE_MAX, tonumber(v) or 1)) L.Apply() end
function L.Reset() ns.db.lootPos = nil ns.db.lootScale = 1.0 L.Apply() end

ns:On("LOGIN", function() L.Apply() end)
ns:On("PLAYER_ENTERING_WORLD", function() L.Apply() end)
ns:On("START_LOOT_ROLL", function()
    for _, f in ipairs((L.Targets())) do Hook(f) end
    L.Place()
end)
ns:On("PLAYER_REGEN_ENABLED", function() if L.pending then L.Place() end end)
local function PlaceIfLootVisible()
    if L.previewShown and L.previewShown > 0 then L.Place() return end
    for _, f in ipairs((L.Targets())) do
        if f and f.IsShown and f:IsShown() then L.Place() return end
    end
end
if hooksecurefunc then
    if type(GroupLootContainer_Update) == "function" then hooksecurefunc("GroupLootContainer_Update", function() L.Place() end) end
    -- UIParent_ManageFramePositions runs at login; do not SetPoint Blizzard loot frames then
    -- unless a roll (or preview) is actually showing.
    if type(UIParent_ManageFramePositions) == "function" then hooksecurefunc("UIParent_ManageFramePositions", PlaceIfLootVisible) end
end

ns:AddCommand("loot", function(rest)
    rest = (rest or ""):lower():match("^%s*(%S*)") or ""
    if rest == "unlock" then ns.SetLootLocked(false) ns.Print("loot rolls: unlocked - drag the bar, then /comp loot lock")
    elseif rest == "lock" then ns.SetLootLocked(true) ns.Print("loot rolls: locked")
    elseif rest == "test" then L.Test(3) ns.Print("loot rolls: showing 3 preview rolls for 10 s")
    elseif rest == "reset" then L.Reset() ns.Print("loot rolls: position and size reset")
    else
        local p = L.Position()
        ns.Print(string.format("loot rolls: %s, %s at %s %d,%d, scale %.2f, frames via %s%s",
            ns.db.lootLocked and "locked" or "unlocked", "anchor", p[1], p[3], p[4], L.Scale(),
            GroupLootContainer and "GroupLootContainer" or "GroupLootFrameN", L.pending and " (waiting for combat to end)" or ""))
        ns.Print("  /comp loot unlock | lock | test | reset")
    end
end)
