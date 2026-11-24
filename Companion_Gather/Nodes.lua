-- Companion module: Gather. Uses the shared Companion table (this file is a separate addon; `ns` is not shared automatically).
-- Companion: mining and herb callouts (0.44–0.46, soft-target 0.45, handoff to Companion Gather in 0.59).
-- 0.45: main detection is Blizzard's interact soft targeting (the "softinteract" unit). With the
-- SoftTargetInteract CVars on, the client picks the nearest interactable object within ~15 m and can
-- give it a nameplate; we read its name, call it out and put a glow on that nameplate. The minimap
-- tooltip check stays as a fallback (now polled, since the tooltip changes text without re-showing).
-- When you mouse over a minimap tracking blip, the minimap tooltip names the node. If it's a vein
-- you can mine or an herb you can pick (you have Mining / Herbalism), she points it out.
-- Only hooks (HookScript); nothing Blizzard is replaced or assigned.

local ns = _G.Companion
if not ns then return end
ns.defaults.nodeCallouts = true
ns.NODE_CD = 20            -- seconds between any two callouts
ns.NODE_SAME_CD = 90       -- seconds before the same node name is called out again

-- Classic veins and herbs up to about level 40 gathering.
ns.ORE_NODES = {
    "Copper Vein", "Tin Vein", "Incendicite Mineral Vein", "Lesser Bloodstone Deposit", "Silver Vein",
    "Iron Deposit", "Indurium Mineral Vein", "Gold Vein", "Mithril Deposit", "Ooze Covered Silver Vein",
    "Ooze Covered Iron Deposit", "Ooze Covered Gold Vein", "Ooze Covered Mithril Deposit",
    "Truesilver Deposit", "Dark Iron Deposit", "Small Thorium Vein",
}
ns.HERB_NODES = {
    "Peacebloom", "Silverleaf", "Earthroot", "Mageroyal", "Briarthorn", "Stranglekelp", "Bruiseweed",
    "Wild Steelbloom", "Grave Moss", "Kingsblood", "Liferoot", "Fadeleaf", "Goldthorn", "Khadgar's Whisker",
    "Wintersbite", "Firebloom", "Purple Lotus", "Arthas' Tears", "Sungrass", "Blindweed",
}
local ORE, HERB = {}, {}
for _, n in ipairs(ns.ORE_NODES) do ORE[n:lower()] = n end
for _, n in ipairs(ns.HERB_NODES) do HERB[n:lower()] = n end

local function safe(f, ...) if not f then return nil end local ok, a, b, c = pcall(f, ...) if ok then return a, b, c end end

-- 0.59: when Companion Gather is loaded (or enabled and about to load), this file
-- does not manage CVars, glow, or callouts. Companion_NodeCallout is the voice hook
-- the other addon calls so she still speaks the node lines.
function ns.GatherAddonActive()
    -- 0.60: gathering is this Companion_Gather module again; no standalone handoff.
    return false
end

-- Hook used by Companion Gather: speak a node callout, ignoring our own toggle
-- (Gather already decided the callout should happen).
function ns.GatherCallout(name, kind, via)
    if not ns.NodeCallout then return nil, "no-fn" end
    local prev = ns.db and ns.db.nodeCallouts
    if ns.db then ns.db.nodeCallouts = true end
    local said, how = ns.NodeCallout(name, via or "gather")
    if ns.db and prev ~= nil then ns.db.nodeCallouts = prev end
    return said, how
end
_G.Companion_NodeCallout = function(name, kind, via)
    return ns.GatherCallout(name, kind, via)
end

-- Profession check (0.46): known spells first, then the skill list (expanding collapsed headers),
-- then GetProfessions. If nothing can tell, the callout is allowed rather than blocked.
ns.GATHER_SPELLS = {
    Mining = { 2575, 2576, 3564, 10248, 2580 },        -- Mining ranks + Find Minerals
    Herbalism = { 2366, 2368, 3570, 11993, 2383 },     -- Herbalism ranks + Find Herbs
}
local skillCache, skillAt, skillHow, scanning = {}, -999, {}, false
ns.gatherHow = skillHow
local function SpellKnown(id)
    if IsPlayerSpell and safe(IsPlayerSpell, id) then return true end
    if IsSpellKnown and safe(IsSpellKnown, id) then return true end
    if C_SpellBook and C_SpellBook.IsSpellKnown and safe(C_SpellBook.IsSpellKnown, id) then return true end
    return false
end
local function SpellApi() return IsPlayerSpell or IsSpellKnown or (C_SpellBook and C_SpellBook.IsSpellKnown) end
local function ScanSkills()
    local found, lines = {}, 0
    if not (GetNumSkillLines and GetSkillLineInfo) then return found, 0 end
    scanning = true
    local function read()
        local collapsed = {}
        for i = 1, safe(GetNumSkillLines) or 0 do
            local sname, header, expanded = safe(GetSkillLineInfo, i)
            if sname then
                lines = lines + 1
                if header then if not expanded then collapsed[#collapsed + 1] = { i, sname } end
                else found[sname] = true end
            end
        end
        return collapsed
    end
    local collapsed = read()
    if not (found.Mining and found.Herbalism) and #collapsed > 0 and ExpandSkillHeader then
        for k = #collapsed, 1, -1 do safe(ExpandSkillHeader, collapsed[k][1]) end
        read()
        if CollapseSkillHeader then -- leave the player's skill window as it was
            local want = {}
            for _, c in ipairs(collapsed) do want[c[2]] = true end
            for i = safe(GetNumSkillLines) or 0, 1, -1 do
                local sname, header = safe(GetSkillLineInfo, i)
                if header and want[sname] then safe(CollapseSkillHeader, i) end
            end
        end
    end
    scanning = false
    return found, lines
end
local function Recheck()
    skillCache, skillAt = {}, GetTime()
    for k in pairs(skillHow) do skillHow[k] = nil end
    local found, lines = ScanSkills()
    local profs = {}
    if GetProfessions and GetProfessionInfo then
        local p1, p2 = safe(GetProfessions)
        for _, p in ipairs({ p1, p2 }) do local nm = p and safe(GetProfessionInfo, p) if nm then profs[nm] = true end end
    end
    for prof, ids in pairs(ns.GATHER_SPELLS) do
        local how
        for _, id in ipairs(ids) do if SpellKnown(id) then how = "spell " .. id break end end
        if not how and found[prof] then how = "skill list" end
        if not how and profs[prof] then how = "GetProfessions" end
        if how then skillCache[prof] = true
        elseif not SpellApi() and lines == 0 and not GetProfessions then skillCache[prof] = "unknown" how = "unknown (allowed)"
        else skillCache[prof] = false how = "not found" end
        skillHow[prof] = how
    end
end
function ns.HasGatherSkill(name)
    if GetTime() - skillAt > 60 then Recheck() end
    return skillCache[name] == true or skillCache[name] == "unknown"
end
function ns.ResetSkillCache() skillAt = -999 end
for _, ev in ipairs({ "SKILL_LINES_CHANGED", "LEARNED_SPELL_IN_TAB", "SPELLS_CHANGED", "PLAYER_ENTERING_WORLD" }) do
    ns:On(ev, function() if not scanning then skillAt = -999 end end)
end
ns:On("LOGIN", function() skillAt = -999 end)

-- Find the first node name in a tooltip text (the minimap tooltip can list several, one per line).
-- Newer clients can hand back "secret" strings (e.g. soft-target names); addons may not read or compare them.
local function IsSecret(v) return issecretvalue ~= nil and issecretvalue(v) == true end
ns.IsSecret = IsSecret
function ns.MatchNode(text)
    if IsSecret(text) then return nil end
    if type(text) ~= "string" or text == "" then return nil end
    text = text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("|T.-|t", ""):gsub("|A.-|a", "")
    for line in (text .. "\n"):gsub("|n", "\n"):gmatch("([^\n]*)\n") do
        local l = line:gsub("^%s+", ""):gsub("%s+$", ""):lower()
        if ORE[l] then return ORE[l], "ore" end
        if HERB[l] then return HERB[l], "herb" end
    end
end

local lastAt, lastByName = -999, {}
-- Returns the text said, or nil plus a reason.
function ns.NodeCallout(text, via)
    if not (ns.db and ns.db.nodeCallouts) then return nil, "off" end
    local name, kind = ns.MatchNode(text)
    if not name then return nil, "nomatch" end
    if not ns.HasGatherSkill(kind == "ore" and "Mining" or "Herbalism") then return nil, "noskill" end
    local t = GetTime()
    if t - lastAt < ns.NODE_CD then return nil, "throttle" end
    if lastByName[name] and t - lastByName[name] < ns.NODE_SAME_CD then return nil, "same" end
    if UnitAffectingCombat and UnitAffectingCombat("player") then return nil, "combat" end
    local cat = kind == "ore" and "nodeOre" or "nodeHerb"
    local pool = ns.dialogue[cat]
    local i = ns.PickLineIndex(cat, #pool)
    ns.speechState.lastIndex[cat] = i
    local shown = "Ooh, " .. name .. " nearby!"
    local said, how = ns:Say(cat, { text = shown, sound = pool[i].autoSound })
    if said then lastAt, lastByName[name] = t, t; ns.nodeLast = { name = name, via = via or "tooltip", at = t } end
    return said, how
end

-- Is this tooltip coming from the minimap?
local function FromMinimap(tt)
    local owner = safe(tt.GetOwner, tt)
    if not owner then return false end
    if owner == Minimap then return true end
    local n = safe(owner.GetName, owner)
    return type(n) == "string" and n:find("^Minimap") ~= nil
end

local function TooltipText(tt)
    local fs = _G[(safe(tt.GetName, tt) or "GameTooltip") .. "TextLeft1"]
    local t = fs and safe(fs.GetText, fs)
    if issecretvalue and issecretvalue(t) then return nil end
    return t
end

local lastTipText
local function OnTooltipShow(tt)
    if ns.GatherAddonActive() then return end
    if not (ns.db and ns.db.nodeCallouts) then return end
    if not FromMinimap(tt) then return end
    local text = TooltipText(tt)
    lastTipText = text
    if text then ns.NodeCallout(text, "minimap tooltip") end
end
ns.OnNodeTooltipShow = OnTooltipShow

-- ===================== SOFT-TARGET DETECTION (0.45) =====================
local SOFT = "softinteract"
-- CVars we manage; originals are saved in CompanionDB.nodeSavedCVars and restored on off / logout.
ns.NODE_CVARS = {
    SoftTargetInteract = "3",            -- interact soft target always on
    SoftTargetInteractRange = "25",      -- 0.63m: 25 yd; the client may cap it lower (Forever seemed to stop near 15)
    SoftTargetInteractArc = "2",         -- all directions, not just in front
    SoftTargetInteractOnlyInRange = "0", -- also outside click range
    SoftTargetInteractRangeIsHard = "0",
    SoftTargetNameplateInteract = "1",   -- the object gets a nameplate (glow anchor)
    SoftTargetIconGameObject = "1",      -- needed for game-object nameplates on Classic clients
    SoftTargetFriend = "0",              -- 0.63k: never soft-target friendly units (helpful spells fall back to you)
}
-- autoSelfCast / TargetAutoFriend are the player's own settings: never touched here.
ns.defaults.nodeGlow = true
local nodeState = { method = "none", softSeen = false, lastSoft = nil, cvars = false }
ns.nodeState = nodeState

local function GetCV(name)
    local f = (C_CVar and C_CVar.GetCVar) or GetCVar
    return safe(f, name)
end
local function SetCV(name, value)
    if GetCV(name) == nil then return false end
    value = tostring(value)
    if GetCV(name) == value then return true end
    if InCombatLockdown and safe(InCombatLockdown) == true then
        nodeState.pending = nodeState.pending or "apply"
        return false
    end
    local f = (C_CVar and C_CVar.SetCVar) or SetCVar
    return safe(f, name, value) ~= false
end
local function OtherOwner() -- another addon (Lueur) already drives soft targeting: don't fight it
    local f = (C_AddOns and C_AddOns.IsAddOnLoaded) or IsAddOnLoaded
    return safe(f, "Lueur") == true
end
function ns.SoftTargetSupported()
    return GetCV("SoftTargetInteract") ~= nil
end

function ns.ApplyNodeCVars()
    if ns.IsModuleEnabled and not ns.IsModuleEnabled("gather") then return false end
    if ns.GatherAddonActive() then nodeState.method = "Companion Gather" nodeState.cvars = false return false end
    if not ns.SoftTargetSupported() then nodeState.method = "minimap tooltip only (client has no soft targeting)" return false end
    if OtherOwner() then nodeState.method = "soft target (CVars left to Lueur)" nodeState.cvars = false return true end
    if InCombatLockdown and InCombatLockdown() then nodeState.pending = "apply" return false end
    ns.db.nodeSavedCVars = ns.db.nodeSavedCVars or {}
    for name, v in pairs(ns.NODE_CVARS) do
        if ns.db.nodeSavedCVars[name] == nil then ns.db.nodeSavedCVars[name] = GetCV(name) or false end
        SetCV(name, v)
    end
    nodeState.cvars, nodeState.method = true, "soft target"
    return true
end
function ns.RestoreNodeCVars()
    if ns.GatherAddonActive() then return end
    local saved = ns.db and ns.db.nodeSavedCVars
    if not saved then return end
    if InCombatLockdown and InCombatLockdown() then nodeState.pending = "restore" return end
    for name, v in pairs(saved) do if v ~= false then SetCV(name, v) end end
    ns.db.nodeSavedCVars = nil
    nodeState.suspended = nil
    nodeState.cvars = false
    nodeState.method = "off"
end

-- Glow: our own frame, anchored to the object's nameplate (never parented into or changing it).
local glow
local function Glow()
    if glow then return glow end
    glow = CreateFrame("Frame", nil, UIParent)
    glow:SetSize(90, 90)
    glow:SetFrameStrata("BACKGROUND")
    local t = glow:CreateTexture(nil, "ARTWORK")
    t:SetAllPoints()
    t:SetTexture("Interface\\Cooldown\\star4")
    if t.SetBlendMode then t:SetBlendMode("ADD") end
    glow.tex = t
    local acc = 0
    glow:SetScript("OnUpdate", function(self, e)
        acc = acc + (e or 0)
        local a = 0.55 + 0.35 * math.sin(acc * 4)
        if self.tex.SetAlpha then self.tex:SetAlpha(a) end
    end)
    glow:Hide()
    return glow
end
function ns.HideNodeGlow() if glow then glow:Hide() glow:ClearAllPoints() end end
local function ShowGlow(unit, kind)
    if not ns.db.nodeGlow then return false end
    local plate = C_NamePlate and safe(C_NamePlate.GetNamePlateForUnit, unit)
    nodeState.glowVia = "softinteract plate"
    if not plate and C_NamePlate and C_NamePlate.GetNamePlates then
        for _, p in ipairs(safe(C_NamePlate.GetNamePlates) or {}) do
            local u = p.namePlateUnitToken or (p.UnitFrame and p.UnitFrame.unit)
            if u and (safe(UnitIsUnit, u, unit) == true or (safe(UnitIsGameObject, u) == true and safe(UnitName, u) == safe(UnitName, unit))) then
                plate = p nodeState.glowVia = "plate scan" break
            end
        end
    end
    if not plate then nodeState.glowVia = "skipped: no nameplate (SoftTargetNameplateInteract=" .. tostring(GetCV("SoftTargetNameplateInteract")) .. ")" return false end
    local g = Glow()
    g:ClearAllPoints()
    g:SetPoint("CENTER", plate, "CENTER", 0, -40)
    if kind == "ore" then g.tex:SetVertexColor(1, 0.6, 0.2) else g.tex:SetVertexColor(0.4, 1, 0.45) end
    g:Show()
    return true
end

-- Look at the current interact soft target. Returns name, kind or nil.
-- Only give ore/herb objects a soft-target nameplate: an NPC keeps its normal name and <title>, no health bar.
local function SyncSoftPlate()
    if not (ns.db and ns.db.nodeCallouts) or OtherOwner() then return end
    if InCombatLockdown and InCombatLockdown() then return end
    -- Plate only for game objects (ore/herb nodes); NPCs, corpses and "nothing" all keep it off.
    local isObj = safe(UnitIsGameObject, SOFT) == true
    local want = isObj and "1" or "0"
    if GetCV("SoftTargetNameplateInteract") ~= nil and GetCV("SoftTargetNameplateInteract") ~= want then
        SetCV("SoftTargetNameplateInteract", want)
    end
end

-- 0.63k: the interact soft target also picks friendly NPCs/players, and with no hard target a
-- helpful spell could land on them. Whenever it grabs a unit (not a game object) and you have no
-- target, interact soft targeting is suspended (your own value, normally off) until you've moved
-- on for a few seconds; ore/herb objects keep it on. Out of combat only (CVars wait in combat).
nodeState.suspended = nil
function ns.SoftUnitGuard(now)
    if ns.IsModuleEnabled and not ns.IsModuleEnabled("gather") then return false end
    if ns.GatherAddonActive() then return false end
    if not nodeState.cvars or OtherOwner() then return false end
    if InCombatLockdown and InCombatLockdown() then return false end
    now = now or (GetTime and GetTime() or 0)
    if nodeState.suspended then
        local moving = (tonumber(safe(GetUnitSpeed, "player")) or 0) > 0
        if moving then nodeState.movedAt = now end
        -- always resumes: after moving on for 3 s, or after 8 s regardless
        if (now - nodeState.suspended >= 3 and nodeState.movedAt and nodeState.movedAt > nodeState.suspended)
            or now - nodeState.suspended >= 8 then
            nodeState.suspended, nodeState.movedAt = nil, nil
            SetCV("SoftTargetInteract", ns.NODE_CVARS.SoftTargetInteract)
            return "resumed"
        end
        return false
    end
    local exists = safe(UnitExists, SOFT)
    if IsSecret(exists) or exists ~= true then return false end
    local obj = safe(UnitIsGameObject, SOFT)
    if IsSecret(obj) or obj == true or UnitIsGameObject == nil then return false end
    -- 0.63l: only a CONFIRMED friendly, living NPC/player pauses it. The 0.63k version paused on any
    -- non-object unit - mob corpses, enemies, skinnable kills - so near nodes it was paused nearly
    -- all the time and herbs/ore lost soft targeting and glows.
    local function yes(fn, ...) local v = safe(fn, ...) return not IsSecret(v) and v == true end
    if not yes(UnitIsFriend, "player", SOFT) then return false end
    if yes(UnitCanAttack, "player", SOFT) or yes(UnitIsDeadOrGhost, SOFT) or yes(UnitIsUnit, SOFT, "player") then return false end
    local hard = safe(UnitExists, "target")
    if not IsSecret(hard) and hard == true then return false end
    local saved = ns.db and ns.db.nodeSavedCVars and ns.db.nodeSavedCVars.SoftTargetInteract
    local off = (saved and saved ~= "3") and saved or "0"
    SetCV("SoftTargetInteract", off)
    nodeState.suspended, nodeState.movedAt = now, nil
    return "suspended"
end

-- allowCVars: false from OnUpdate/timers (SetCVar from a timer is not a hardware event and can
-- trip ADDON_ACTION_FORBIDDEN). Events, slash commands and the options checkbox pass true/nil.
function ns.CheckSoftTarget(allowCVars)
    if allowCVars == nil then allowCVars = true end
    if type(allowCVars) == "table" then allowCVars = allowCVars.cvars ~= false end
    if ns.IsModuleEnabled and not ns.IsModuleEnabled("gather") then ns.HideNodeGlow(); return nil end
    if ns.GatherAddonActive() then ns.HideNodeGlow(); return nil end
    if allowCVars then
        ns.SoftUnitGuard()
        SyncSoftPlate()
    end
    if not (ns.db and ns.db.nodeCallouts) then ns.HideNodeGlow() return nil end
    if safe(UnitIsGameObject, SOFT) ~= true then ns.HideNodeGlow() return nil end
    local name = safe(UnitName, SOFT)
    if IsSecret(name) then ns.HideNodeGlow() return nil end
    nodeState.softSeen = true
    nodeState.lastSoft = name
    local node, kind = ns.MatchNode(name)
    if not node then ns.HideNodeGlow() return nil end
    nodeState.skillOk = ns.HasGatherSkill(kind == "ore" and "Mining" or "Herbalism")
    if not nodeState.skillOk then ns.HideNodeGlow() nodeState.glowing = false nodeState.glowVia = "skipped: profession not detected" return nil end
    nodeState.glowing = ShowGlow(SOFT, kind)
    ns.NodeCallout(node, "soft target")
    return node, kind
end

ns:On("PLAYER_SOFT_INTERACT_CHANGED", function() ns.CheckSoftTarget() end)
ns:On("NAME_PLATE_UNIT_ADDED", function() ns.CheckSoftTarget() end)
ns:On("PLAYER_REGEN_ENABLED", function()
    local p = nodeState.pending; nodeState.pending = nil
    if p == "apply" then ns.ApplyNodeCVars() elseif p == "restore" then ns.RestoreNodeCVars() end
end)
ns:On("PLAYER_LOGOUT", function() ns.RestoreNodeCVars() end) -- hand the player's own settings back
ns:On("PLAYER_ENTERING_WORLD", function()
    if ns.db and ns.db.nodeCallouts then ns.ApplyNodeCVars() end
end)
ns:On("PLAYER_STARTED_MOVING", function() if ns.CheckSoftTarget then ns.CheckSoftTarget(true) end end)
ns:On("PLAYER_STOPPED_MOVING", function() if ns.CheckSoftTarget then ns.CheckSoftTarget(true) end end)

-- Poller: re-checks the soft target (it can move without an event) and the minimap tooltip,
-- whose text changes from blip to blip while it stays shown (why the 0.44 OnShow hook missed most).
local poll = CreateFrame("Frame")
local since = 0
poll:SetScript("OnUpdate", function(_, e)
    since = since + (e or 0)
    if since < 0.3 then return end
    since = 0
    if ns.GatherAddonActive() then return end
    if not (ns.db and ns.db.nodeCallouts) then return end
    ns.CheckSoftTarget(false)   -- glow/tooltip only; never SetCVar from OnUpdate
    if GameTooltip and safe(GameTooltip.IsShown, GameTooltip) and FromMinimap(GameTooltip) then
        local text = TooltipText(GameTooltip)
        if IsSecret(text) then text = nil end
        if text and text ~= lastTipText then lastTipText = text ns.NodeCallout(text, "minimap tooltip") end
    else
        lastTipText = nil
    end
end)
ns.NodePoll = poll

ns:On("LOGIN", function()
    if ns.GatherAddonActive() then
        if ns.UpdateNodeSettingsPage then ns.UpdateNodeSettingsPage() end
        return
    end
    if GameTooltip and GameTooltip.HookScript then
        GameTooltip:HookScript("OnShow", OnTooltipShow)
    end
    -- CVars are applied on PLAYER_ENTERING_WORLD (and when the option is clicked), not here:
    -- a second SetCVar pass at LOGIN is a common ADDON_ACTION_FORBIDDEN timing.
end)

function ns.SetNodeCallouts(on)
    ns.db.nodeCallouts = on and true or false
    if on then ns.ApplyNodeCVars() else ns.RestoreNodeCVars() ns.HideNodeGlow() end
end

ns:AddCommand("nodes", function(rest)
    if ns.GatherAddonActive() then
        ns.Print("ore/herb callouts now live in Companion Gather. Use /cgather (on|off|status|diag).")
        return
    end
    rest = (rest or ""):lower()
    if rest == "on" or rest == "off" then ns.SetNodeCallouts(rest == "on") end
    if rest == "glow" then ns.db.nodeGlow = not ns.db.nodeGlow if not ns.db.nodeGlow then ns.HideNodeGlow() end end
    ns.Print("node callouts " .. (ns.db.nodeCallouts and "ON" or "OFF") .. ", glow " .. (ns.db.nodeGlow and "ON" or "OFF")
        .. " | Mining: " .. tostring(ns.HasGatherSkill("Mining")) .. ", Herbalism: " .. tostring(ns.HasGatherSkill("Herbalism")))
    ns.Print("method: " .. tostring(nodeState.method) .. " | SoftTargetInteract=" .. tostring(GetCV("SoftTargetInteract"))
        .. " range=" .. tostring(GetCV("SoftTargetInteractRange")) .. " nameplate=" .. tostring(GetCV("SoftTargetNameplateInteract"))
        .. " | SoftTargetFriend=" .. tostring(GetCV("SoftTargetFriend")) .. " autoSelfCast=" .. tostring(GetCV("autoSelfCast"))
        .. (nodeState.suspended and " | paused: a friendly unit was soft-targeted" or ""))
    ns.Print("soft target now: " .. tostring(safe(UnitName, SOFT)) .. " (object: " .. tostring(safe(UnitIsGameObject, SOFT))
        .. ") | last seen: " .. tostring(nodeState.lastSoft) .. " | glowing: " .. tostring(nodeState.glowing == true)
        .. " (" .. tostring(nodeState.glowVia or "-") .. ")")
    ns.Print("profession check: Mining=" .. tostring(skillHow.Mining or "-") .. ", Herbalism=" .. tostring(skillHow.Herbalism or "-"))
    local l = ns.nodeLast
    ns.Print("last callout: " .. (l and (l.name .. " via " .. l.via .. ", " .. math.floor(GetTime() - l.at) .. "s ago") or "none yet"))
end)
