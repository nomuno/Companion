-- Companion: Chatter. Extra reactions and banter (loot, mana, bags, rares, durability,
-- party, zones, time of day, session length, ambient banter). All lines go through
-- ns:Say, which handles cooldowns, chattiness and combat suppression.

local _, ns = ...

local function safe(fn, ...)
    if not fn then return nil end
    local ok, a, b, c = pcall(fn, ...)
    if ok then return a, b, c end
end
local function secret(v) return issecretvalue and issecretvalue(v) end
local function InCombat() return safe(UnitAffectingCombat, "player") end

-- ===================== LOOT =====================
-- Quality from the item link's color code (works without item cache).
local QUALITY_BY_COLOR = { ["1eff00"] = 2, ["0070dd"] = 3, ["a335ee"] = 4, ["ff8000"] = 5 }
function ns.LinkQuality(link)
    if type(link) ~= "string" then return nil end
    local hex = link:match("|c%x%x(%x%x%x%x%x%x)")
    local q = hex and QUALITY_BY_COLOR[hex:lower()]
    if q then return q end
    if GetItemInfo then
        local _, _, quality = safe(GetItemInfo, link)
        return quality
    end
end

local function IsSelfLoot(msg)
    if type(msg) ~= "string" or secret(msg) then return false end
    if msg:find("^You receive") or msg:find("^You get") then return true end
    if LOOT_ITEM_SELF then
        local prefix = LOOT_ITEM_SELF:match("^(.-)%%s")
        if prefix and prefix ~= "" and msg:sub(1, #prefix) == prefix then return true end
    end
    return false
end
ns.IsSelfLoot = IsSelfLoot

ns:On("CHAT_MSG_LOOT", function(msg)
    if not IsSelfLoot(msg) then return end
    local link = msg:match("(|c%x+|Hitem:.-|h.-|h|r)")
    local q = ns.LinkQuality(link) or 1
    local vars = { item = link or "" }
    if q >= 4 then ns:Say("lootEpic", { vars = vars })
    elseif q == 3 then ns:Say("lootRare", { vars = vars })
    elseif q == 2 then ns:Say("lootGood", { vars = vars, chance = 0.35 })
    else ns:Say("loot", { chance = 0.05 }) end
end)

-- ===================== LOW MANA =====================
local manaWarned = false
local function ManaRatio()
    local ptype = safe(UnitPowerType, "player")
    if ptype ~= 0 then return nil end                 -- 0 = mana; rage/energy users skip
    local cur, max = safe(UnitPower, "player", 0), safe(UnitPowerMax, "player", 0)
    if cur == nil or max == nil or secret(cur) or secret(max) then return nil end
    local ok, r = pcall(function() if max <= 0 then return nil end return cur / max end)
    if ok then return r end
end
ns.ManaRatio = ManaRatio

ns:On("UNIT_POWER_UPDATE", function(unit, powerType)
    if unit ~= "player" or (powerType and powerType ~= "MANA") then return end
    local r = ManaRatio()
    if not r then return end
    if r < 0.20 and not manaWarned then
        manaWarned = true
        ns:Say("lowMana")
    elseif r > 0.50 then
        manaWarned = false
    end
end)

-- ===================== BAGS =====================
local lastFree
function ns.FreeBagSlots()
    local total = 0
    for bag = 0, 4 do
        local free
        if C_Container and C_Container.GetContainerNumFreeSlots then
            free = safe(C_Container.GetContainerNumFreeSlots, bag)
        elseif GetContainerNumFreeSlots then
            free = safe(GetContainerNumFreeSlots, bag)
        end
        total = total + (tonumber(free) or 0)
    end
    return total
end

ns:On("BAG_UPDATE_DELAYED", function()
    local free = ns.FreeBagSlots()
    if lastFree and free < lastFree then
        if free == 0 then ns:Say("bagsFull")
        elseif free <= 2 then ns:Say("bagsAlmost") end
    end
    lastFree = free
end)

-- ===================== RARE / ELITE TARGET =====================
local seenGUID = {}
ns:On("PLAYER_TARGET_CHANGED", function()
    if not safe(UnitExists, "target") or safe(UnitIsDead, "target") then return end
    if not safe(UnitCanAttack, "player", "target") then return end
    local class = safe(UnitClassification, "target")
    local guid = safe(UnitGUID, "target") or "?"
    if secret(guid) or secret(class) then return end
    if seenGUID[guid] then return end
    if class == "rare" or class == "rareelite" then
        seenGUID[guid] = true
        ns:Say("rareMob")
    elseif class == "elite" or class == "worldboss" then
        seenGUID[guid] = true
        ns:Say("eliteMob")
    end
end)

-- ===================== DURABILITY =====================
ns:On("UPDATE_INVENTORY_DURABILITY", function()
    if not GetInventoryItemDurability then return end
    local worst
    for slot = 1, 18 do
        local cur, max = safe(GetInventoryItemDurability, slot)
        if cur and max and max > 0 then
            local r = cur / max
            if not worst or r < worst then worst = r end
        end
    end
    if worst and worst < 0.20 then ns:Say("lowDurability") end
end)

-- ===================== PARTY =====================
local groupSize = 0
ns:On("GROUP_ROSTER_UPDATE", function()
    local n = safe(GetNumGroupMembers) or 0
    if n > groupSize and n > 1 then ns:Say("partyJoin") end
    groupSize = n
end)

-- ===================== ZONES =====================
local zoneSeen, lastZoneAt = {}, -999
local ZONE_REPEAT = 300           -- don't comment on the same place again for 5 minutes

local function ZoneComment()
    local sub = safe(GetSubZoneText) or ""
    local zone = safe(GetZoneText) or ""
    -- 0.40: Alliance characters use their own zone lines (and never hear the Horde ones)
    local alliance = ns.PlayerFaction and ns.PlayerFaction() == "Alliance"
    local ZL = alliance and (ns.zoneLinesAlliance or {}) or ns.zoneLines
    local place = (sub ~= "" and ZL[sub]) and sub or zone
    if place == "" then return end
    local now = GetTime()
    -- 0.44: she just told this place's story; skip the quick comment
    if ns.loreSpokeAt and now - ns.loreSpokeAt < 15 then return end
    if zoneSeen[place] and now - zoneSeen[place] < ZONE_REPEAT then return end
    if now - lastZoneAt < 30 then return end
    local lines = ZL[place]
    local said
    if lines then
        ns.zoneLastIdx = ns.zoneLastIdx or {}
        local i = ns.PickLineIndex("zone:" .. place, #lines)
        local sound = not lines[i]:find("{", 1, true) and ((alliance and "auto_zone_a_" or "auto_zone_") .. ns.ZoneSlug(place) .. "_" .. i .. ".ogg") or nil
        said = ns:Say("zone", { text = lines[i], sound = sound, chance = 0.8 })
        if said then ns.zoneLastIdx[place] = i end
    elseif place == zone then
        said = ns:Say("zone", { vars = { zone = zone }, chance = 0.5 })
    end
    if said then zoneSeen[place], lastZoneAt = now, now end
end
ns.ZoneComment = ZoneComment

ns:On("ZONE_CHANGED_NEW_AREA", function() C_Timer.After(2, ZoneComment) end)
ns:On("ZONE_CHANGED", function() C_Timer.After(2, ZoneComment) end)

-- ===================== TIME OF DAY / SESSION / BANTER =====================
function ns.TimeCategory(hour)
    if not hour then return nil end
    if hour >= 5 and hour < 11 then return "timeMorning" end
    if hour >= 17 and hour < 21 then return "timeEvening" end
    if hour >= 21 or hour < 5 then return "timeNight" end
end

local function TimeComment()
    local h = safe(GetGameTime)
    local cat = ns.TimeCategory(h)
    if cat then ns:Say(cat, { chance = 0.6 }) end
end

local sessionStart, sessionSaid = nil, {}
function ns.SessionCategory(minutes)
    if minutes >= 180 then return "session3h", math.floor(minutes / 60) end
    if minutes >= 120 then return "session2h", 2 end
    if minutes >= 60 then return "session1h", 1 end
end

local function SessionCheck()
    if not sessionStart then return end
    local cat, mark = ns.SessionCategory((GetTime() - sessionStart) / 60)
    if cat and not sessionSaid[mark] then
        if ns:Say(cat) then sessionSaid[mark] = true end
    end
end

local function ScheduleBanter()
    local mult = ns.ChattyMult()
    local delay = math.random(240, 480) / mult
    C_Timer.After(delay, function()
        if not InCombat() then ns:Say("banter") end
        ScheduleBanter()
    end)
end

ns:On("LOGIN", function()
    sessionStart = GetTime()
    C_Timer.After(15, TimeComment)
    C_Timer.After(25, ZoneComment)
    C_Timer.NewTicker(60, SessionCheck)
    C_Timer.NewTicker(45 * 60, TimeComment)
    ScheduleBanter()
end)

-- ===================== COMMANDS =====================
function ns.SetChattiness(v)
    if not ns.CHATTY_MULT[v or ""] then return false end
    ns.db.chattiness = v
    return true
end
ns:AddCommand("chatty", function(rest)
    rest = (rest or ""):lower()
    if ns.SetChattiness(rest) then
        ns.Print("chattiness: " .. rest)
        if ns.UpdateGeneralOptions then ns.UpdateGeneralOptions() end
    else
        ns.Print("usage: /comp chatty quiet|normal|chatty  (now " .. ns.db.chattiness .. ")")
    end
end)

ns:AddCommand("say", function(rest)
    rest = rest or ""
    local cat
    for k in pairs(ns.dialogue) do if k:lower() == rest:lower() then cat = k end end
    if not cat then
        local names = {}
        for k in pairs(ns.dialogue) do table.insert(names, k) end
        table.sort(names)
        ns.Print("usage: /comp say <category>: " .. table.concat(names, ", "))
        return
    end
    ns:Say(cat, { force = true, vars = { step = "Accept Cutting Teeth", target = "Gornek", zone = "Durotar", item = "[Test Item]" } })
end)
