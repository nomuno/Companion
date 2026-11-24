-- Companion module: Quest Helper. Uses the shared Companion table (this file is a separate addon; `ns` is not shared automatically).
-- Companion: quest item button in the guide section (0.48).
-- A SecureActionButtonTemplate button (type=item) for the current step's quest item, e.g.
-- Foreman's Blackjack for Lazy Peons. Item source, in order:
--   1. step.item (guide data) or ns.QUEST_ITEMS[qid] (known items)
--   2. the quest log's usable item: GetQuestLogSpecialItemInfo(logIndex)
--   3. a bag scan: quest items tied to the step's quest (GetContainerItemQuestInfo) with a use spell
-- Attributes, Show/Hide and moving are protected in combat: changes are queued until
-- PLAYER_REGEN_ENABLED. Icon, count and cooldown are plain textures/frames and update anytime.
-- The button is parented to UIParent and only anchored to the guide section, so the section
-- itself stays unprotected and can still show/hide/resize in combat.

local ns = _G.Companion
if not ns then return end
ns.QUEST_ITEMS = {
    [5441] = 16114,   -- Lazy Peons: Foreman's Blackjack
}

local function safe(f, ...) if type(f) ~= "function" then return nil end local ok, a, b, c, d, e = pcall(f, ...) if ok then return a, b, c, d, e end end

local SIZE = 22
local btn = CreateFrame("Button", "CompanionQuestItemButton", UIParent, "SecureActionButtonTemplate")
btn:SetSize(SIZE, SIZE)
btn:SetFrameStrata("MEDIUM")
local function InitQuestItemSecure()
    if InCombatLockdown and InCombatLockdown() then return false end
    btn:RegisterForClicks("AnyUp", "AnyDown")
    btn:SetAttribute("type", "item")
    btn:Hide()
    return true
end
if not InitQuestItemSecure() then
    -- file load / reload can happen in combat; attributes wait until regen
    ns:On("PLAYER_REGEN_ENABLED", function()
        if not btn:GetAttribute("type") then InitQuestItemSecure() end
    end)
end
local icon = btn:CreateTexture(nil, "ARTWORK")
icon:SetAllPoints()
btn.icon = icon
btn:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
local count = btn:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmall")
count:SetPoint("BOTTOMRIGHT", -1, 1)
btn.count = count
local cd = CreateFrame("Cooldown", "CompanionQuestItemCooldown", btn, "CooldownFrameTemplate")
cd:SetAllPoints()
btn.cooldown = cd
ns.QuestItemButton = btn

local state = { itemID = nil, how = nil, pending = false, anchored = nil }
ns.questItemState = state

local function InCombat() return InCombatLockdown and InCombatLockdown() and true or false end

local function ItemCount(id)
    if C_Item and C_Item.GetItemCount then local n = safe(C_Item.GetItemCount, id) if n then return n end end
    return safe(GetItemCount, id) or 0
end
local function ItemIcon(id)
    if C_Item and C_Item.GetItemIconByID then local t = safe(C_Item.GetItemIconByID, id) if t then return t end end
    return safe(GetItemIcon, id) or "Interface\\Icons\\INV_Misc_QuestionMark"
end
local function ItemSpell(id)
    if C_Item and C_Item.GetItemSpell then local s = safe(C_Item.GetItemSpell, id) if s then return s end end
    return safe(GetItemSpell, id)
end
local function ItemCooldown(id)
    if C_Container and C_Container.GetItemCooldown then return safe(C_Container.GetItemCooldown, id) end
    return safe(GetItemCooldown, id)
end

local function QIDs(step)
    if type(step.qid) == "table" then return step.qid end
    if step.qid then return { step.qid } end
    return {}
end

local function LogIndex(qid)
    if C_QuestLog and C_QuestLog.GetLogIndexForQuestID then local i = safe(C_QuestLog.GetLogIndexForQuestID, qid) if i then return i end end
    return safe(GetQuestLogIndexByID, qid)
end

local function FromQuestLog(qid)
    if not GetQuestLogSpecialItemInfo then return nil end
    local idx = LogIndex(qid)
    if not idx or idx == 0 then return nil end
    local link = safe(GetQuestLogSpecialItemInfo, idx)
    local id = type(link) == "string" and tonumber(link:match("item:(%d+)"))
    return id
end

local function FromBags(qids)
    local want = {}
    for _, q in ipairs(qids) do want[q] = true end
    local numSlots = (C_Container and C_Container.GetContainerNumSlots) or GetContainerNumSlots
    local itemID = (C_Container and C_Container.GetContainerItemID) or GetContainerItemID
    local qinfo = (C_Container and C_Container.GetContainerItemQuestInfo) or GetContainerItemQuestInfo
    if not (numSlots and itemID) then return nil end
    for bag = 0, 4 do
        for slot = 1, safe(numSlots, bag) or 0 do
            local id = safe(itemID, bag, slot)
            if id and ItemSpell(id) then
                local a, b = safe(qinfo, bag, slot)
                local qid = type(a) == "table" and a.questID or b
                if qid and want[qid] then return id end
            end
        end
    end
end

-- The item for a step (or nil) and how it was found.
function ns.QuestItemForStep(step)
    if not step then return nil end
    if step.item then return step.item, "step data" end
    if step.type == "turnin" or step.type == "accept" then return nil end
    local qids = QIDs(step)
    for _, q in ipairs(qids) do if ns.QUEST_ITEMS[q] then return ns.QUEST_ITEMS[q], "known item" end end
    for _, q in ipairs(qids) do local id = FromQuestLog(q) if id then return id, "quest log" end end
    local id = FromBags(qids)
    if id then return id, "bag scan" end
end

local function Visuals()
    local id = state.itemID
    if not id then return end
    icon:SetTexture(ItemIcon(id))
    local n = ItemCount(id)
    count:SetText(n and n > 1 and tostring(n) or "")
    if icon.SetDesaturated then icon:SetDesaturated(n == 0) end
    local start, dur = ItemCooldown(id)
    if start and dur and dur > 0 then cd:Show() safe(cd.SetCooldown, cd, start, dur) else cd:Hide() end
end
ns.UpdateQuestItemVisuals = Visuals

-- Protected part: attribute, anchor, show/hide. Out of combat only.
local function ApplySecure(id, show)
    if InCombat() then state.pending = true return false end
    state.pending = false
    local parent = ns.GuidePanel
    if show and id and parent and parent:IsShown() then
        btn:SetAttribute("type", "item")
        btn:SetAttribute("item", "item:" .. id)
        btn:ClearAllPoints()
        btn:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", ns.GUIDE_ITEM_X or 128, 3)
        btn:SetFrameLevel((parent:GetFrameLevel() or 1) + 5)
        btn:Show()
        state.shown = true
    else
        btn:SetAttribute("item", nil)
        btn:Hide()
        state.shown = false
    end
    return true
end

function ns.UpdateQuestItemButton()
    local G = ns.guide
    local step = G and ns.GuideSectionActive and ns.GuideSectionActive() and G.Current and G.Current()
    local id, how = ns.QuestItemForStep(step)
    if id and ItemCount(id) == 0 and how ~= "step data" and how ~= "known item" then id = nil end
    state.itemID, state.how = id, how
    Visuals()
    ApplySecure(id, id ~= nil)
end

btn:SetScript("OnEnter", function(self)
    if not state.itemID then return end
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    if GameTooltip.SetItemByID then GameTooltip:SetItemByID(state.itemID) else GameTooltip:SetHyperlink("item:" .. state.itemID) end
    GameTooltip:Show()
end)
btn:SetScript("OnLeave", function() GameTooltip:Hide() end)

ns:On("PLAYER_REGEN_ENABLED", function() if state.pending then ns.UpdateQuestItemButton() end end)
ns:On("BAG_UPDATE_DELAYED", function() ns.UpdateQuestItemButton() end)
ns:On("BAG_UPDATE_COOLDOWN", Visuals)
ns:On("SPELL_UPDATE_COOLDOWN", Visuals)
ns:On("GET_ITEM_INFO_RECEIVED", Visuals)
