-- Companion module: Reminders. Uses the shared Companion table (this file is a separate addon; `ns` is not shared automatically).
-- Companion: Reminders for food buff, ammo and class self-buffs. Spoken through ns:Say.
-- Never in combat (except a once-per-fight Battle Shout nudge), never while dead,
-- a ghost or on a taxi. Less often in cities (resting). Respects Chattiness.

local ns = _G.Companion
if not ns then return end
ns.defaults.remindFood = true
ns.defaults.remindAmmo = true
ns.defaults.remindBuffs = true
ns.defaults.ammoWarnHunter = 600
ns.defaults.ammoLowHunter = 200
ns.defaults.ammoWarnWarrior = 50

local R = {}
ns.reminders = R

local FOOD_MIN_LEVEL   = 10
local FOOD_EXPIRE      = 60    -- seconds
local BUFF_EXPIRE      = 30
local WEAPON_EXPIRE    = 60
local INTERVAL = { food = 600, ammo = 300, buff = 300, pet = 300, weapon = 300 }
local CITY_MULT        = 2     -- resting (cities/inns): remind half as often
local CHECK_THROTTLE   = 2     -- seconds between event-driven checks

local function safe(fn, ...)
    if not fn then return nil end
    local ok, a, b, c, d, e, f, g, h = pcall(fn, ...)
    if ok then return a, b, c, d, e, f, g, h end
end
local function secret(v) return issecretvalue and issecretvalue(v) end

-- ===================== AURAS =====================
-- Returns { [name] = remainingSeconds or math.huge } for the player's buffs.
function R.ReadAuras()
    local out = {}
    local now = GetTime()
    local function put(name, expiration)
        if type(name) ~= "string" or secret(name) then return end
        local left = math.huge
        if type(expiration) == "number" and not secret(expiration) and expiration > 0 then left = expiration - now end
        if not out[name] or left > out[name] then out[name] = left end
    end
    if C_UnitAuras and C_UnitAuras.GetAuraDataByIndex then
        for i = 1, 40 do
            local a = safe(C_UnitAuras.GetAuraDataByIndex, "player", i, "HELPFUL")
            if not a then break end
            put(a.name, a.expirationTime)
        end
        if next(out) then return out end
    end
    if UnitBuff then
        for i = 1, 40 do
            local name, _, _, _, _, expiration = safe(UnitBuff, "player", i)
            if not name then break end
            put(name, expiration)
        end
    end
    return out
end

-- Is this spell in the spellbook? GetSpellInfo(name) only resolves known spells by name.
function R.Knows(name)
    if C_Spell and C_Spell.GetSpellInfo then
        local info = safe(C_Spell.GetSpellInfo, name)
        if info then return true end
    end
    if GetSpellInfo then
        local n = safe(GetSpellInfo, name)
        if n then return true end
    end
    return false
end

local function KnowsAny(list)
    for _, n in ipairs(list) do if R.Knows(n) then return true end end
    return false
end

-- ===================== CLASS BUFF TABLES =====================
-- buff: name used in the line. auras: any of these counts. know: spells that must be
-- known (default = auras). noExpire: don't warn about expiring (toggled auras/aspects).
R.CLASS = {
    PALADIN = {
        { buff = "a Blessing", auras = { "Blessing of Might", "Blessing of Wisdom", "Blessing of Kings",
            "Blessing of Salvation", "Blessing of Light", "Blessing of Sanctuary",
            "Greater Blessing of Might", "Greater Blessing of Wisdom", "Greater Blessing of Kings",
            "Greater Blessing of Salvation", "Greater Blessing of Light", "Greater Blessing of Sanctuary" },
          know = { "Blessing of Might", "Blessing of Wisdom", "Blessing of Kings", "Blessing of Salvation",
            "Blessing of Light", "Blessing of Sanctuary" } },
        { buff = "an Aura", noExpire = true, auras = { "Devotion Aura", "Retribution Aura", "Concentration Aura",
            "Fire Resistance Aura", "Frost Resistance Aura", "Shadow Resistance Aura", "Sanctity Aura" } },
    },
    HUNTER = {
        { buff = "an Aspect", noExpire = true, auras = { "Aspect of the Hawk", "Aspect of the Monkey",
            "Aspect of the Cheetah", "Aspect of the Pack", "Aspect of the Wild", "Aspect of the Beast" } },
        pet = { "Call Pet" },
    },
    MAGE = {
        { buff = "Arcane Intellect", auras = { "Arcane Intellect", "Arcane Brilliance" }, know = { "Arcane Intellect" } },
        { buff = "your armor", auras = { "Frost Armor", "Ice Armor", "Mage Armor" } },
    },
    PRIEST = {
        { buff = "Power Word: Fortitude", auras = { "Power Word: Fortitude", "Prayer of Fortitude" }, know = { "Power Word: Fortitude" } },
        { buff = "Inner Fire", auras = { "Inner Fire" } },
    },
    DRUID = {
        { buff = "Mark of the Wild", auras = { "Mark of the Wild", "Gift of the Wild" }, know = { "Mark of the Wild" } },
        { buff = "Thorns", auras = { "Thorns" } },
    },
    WARLOCK = {
        { buff = "Demon Skin", auras = { "Demon Skin", "Demon Armor" } },
        pet = { "Summon Imp", "Summon Voidwalker", "Summon Succubus", "Summon Felhunter" },
    },
    SHAMAN = {
        { buff = "Lightning Shield", auras = { "Lightning Shield" } },
        weapon = { label = "a weapon imbue", know = { "Rockbiter Weapon", "Flametongue Weapon", "Frostbrand Weapon", "Windfury Weapon" }, offhand = false },
    },
    ROGUE = {
        weapon = { label = "poison", know = { "Poisons", "Instant Poison", "Deadly Poison", "Crippling Poison",
            "Mind-numbing Poison", "Wound Poison" }, minLevel = 20, offhand = true },
    },
    WARRIOR = {},     -- Battle Shout is handled at combat start only
}

-- ===================== STATUS =====================
local function PlayerClass() local _, c = safe(UnitClass, "player") return c end
local function Level() return safe(UnitLevel, "player") or 1 end

-- Each issue: { key, kind, category, vars, state, priority }
function R.BuffIssues(auras)
    local issues = {}
    local def = R.CLASS[PlayerClass() or ""]
    if not def then return issues end
    auras = auras or R.ReadAuras()
    for _, g in ipairs(def) do
        if KnowsAny(g.know or g.auras) then
            local best
            for _, a in ipairs(g.auras) do
                if auras[a] and (not best or auras[a] > best) then best = auras[a] end
            end
            local key = "buff:" .. g.buff
            if not best then
                table.insert(issues, { key = key, kind = "buff", category = "remindBuff", vars = { buff = g.buff }, state = "missing" })
            elseif not g.noExpire and best < BUFF_EXPIRE then
                table.insert(issues, { key = key, kind = "buff", category = "remindBuffExpiring", vars = { buff = g.buff }, state = "expiring" })
            else
                table.insert(issues, { key = key, kind = "buff", state = "ok" })
            end
        end
    end
    if def.pet and KnowsAny(def.pet) then
        local has = safe(UnitExists, "pet") and not safe(UnitIsDead, "pet")
        table.insert(issues, { key = "pet", kind = "pet", category = not has and "remindPet" or nil, state = has and "ok" or "missing" })
    end
    local w = def.weapon
    if w and Level() >= (w.minLevel or 1) and KnowsAny(w.know) and GetWeaponEnchantInfo then
        local hasMain, mainExp, _, _, hasOff, offExp = safe(GetWeaponEnchantInfo)
        local function check(hand, has, exp)
            local key = "weapon:" .. hand
            if not has then
                table.insert(issues, { key = key, kind = "weapon", category = "remindWeapon", vars = { buff = w.label }, state = "missing" })
            elseif type(exp) == "number" and not secret(exp) and exp / 1000 < WEAPON_EXPIRE then
                table.insert(issues, { key = key, kind = "weapon", category = "remindWeapon", vars = { buff = w.label }, state = "expiring" })
            else
                table.insert(issues, { key = key, kind = "weapon", state = "ok" })
            end
        end
        if safe(GetInventoryItemID, "player", 16) then check("main", hasMain, mainExp) end
        if w.offhand and safe(GetInventoryItemID, "player", 17) then check("off", hasOff, offExp) end
    end
    return issues
end

function R.FoodIssue(auras)
    if Level() < FOOD_MIN_LEVEL then return nil end
    if IsOutdoors and safe(IsOutdoors) == false then return nil end
    auras = auras or R.ReadAuras()
    local left = auras["Well Fed"]
    if not left then
        return { key = "food", kind = "food", category = "remindFood", state = "missing" }
    elseif left < FOOD_EXPIRE then
        return { key = "food", kind = "food", category = "remindFoodExpiring", state = "expiring" }
    end
    return { key = "food", kind = "food", state = "ok" }
end

local function ItemCount(itemID)
    if not itemID then return 0 end
    if C_Item and C_Item.GetItemCount then
        local n = safe(C_Item.GetItemCount, itemID)
        if type(n) == "number" then return n end
    end
    return safe(GetItemCount, itemID) or 0
end

-- True if an item is an arrow/bullet, checked every way the client might allow.
function R.IsAmmo(id)
    local inst = GetItemInfoInstant or (C_Item and C_Item.GetItemInfoInstant)
    if inst then
        local _, itype, _, loc, _, classID = safe(inst, id)
        if classID == 6 or loc == "INVTYPE_AMMO" or itype == "Projectile" then return true end
    end
    local info = GetItemInfo or (C_Item and C_Item.GetItemInfo)
    if info then
        local _, _, _, _, _, itype, _, _, loc, _, _, classID = safe(info, id)
        if classID == 6 or loc == "INVTYPE_AMMO" or itype == "Projectile" then return true end
    end
    return false
end

-- Total arrows/bullets in bags (item class 6 = Projectile). Used when the ammo slot
-- reads empty: new arrows not equipped yet, or a client without an ammo slot.
function R.BagAmmo(want)
    local total, bestID, bestN = 0, nil, 0
    local C = C_Container
    local numSlots = (C and C.GetContainerNumSlots) or GetContainerNumSlots
    local itemAt = (C and C.GetContainerItemInfo)
    local idAt = (C and C.GetContainerItemID) or GetContainerItemID
    if not numSlots or not idAt then return 0 end
    local counts = {}
    for bag = 0, 4 do
        local n = safe(numSlots, bag) or 0
        for slot = 1, n do
            local id = safe(idAt, bag, slot)
            if id then
                if R.IsAmmo(id) then
                    local c = 1
                    if itemAt then
                        local info = safe(itemAt, bag, slot)
                        if type(info) == "table" then c = info.stackCount or 1 end
                    elseif GetContainerItemInfo then
                        local ok2, _, cnt = pcall(GetContainerItemInfo, bag, slot)
                        if ok2 and cnt then c = cnt end
                    end
                    counts[id] = (counts[id] or 0) + c
                    total = total + c
                end
            end
        end
    end
    for id, n in pairs(counts) do if n > bestN then bestID, bestN = id, n end end
    return total, bestID
end

-- Returns count, itemID (or nil if this class doesn't track ammo)
function R.AmmoStatus()
    local class = PlayerClass()
    if class == "HUNTER" then
        local id = safe(GetInventoryItemID, "player", 0)
        local n = 0
        if id then
            n = ItemCount(id)
            if n == 0 then n = safe(GetInventoryItemCount, "player", 0) or 0 end
        end
        if n <= 0 then
            local bn, bid = R.BagAmmo()
            if bn > 0 then
                if not R.ammoHinted and id == nil and GetInventorySlotInfo and pcall(GetInventorySlotInfo, "AmmoSlot") then
                    R.ammoHinted = true
                    ns.Print("You have " .. bn .. " ammo in your bags but none equipped - drag it to the ammo slot on your character sheet.")
                end
                return bn, bid, "hunter"
            end
        end
        return n, id, "hunter"
    elseif class == "WARRIOR" then
        local ranged = safe(GetInventoryItemID, "player", 18)
        if not ranged then return nil end          -- no ranged weapon: nothing to nag about
        local equipLoc
        if GetItemInfo then
            local ok, _, _, _, _, _, _, _, _, loc = pcall(GetItemInfo, ranged)
            if ok then equipLoc = loc end
        end
        if not equipLoc and C_Item and C_Item.GetItemInventoryTypeByID then
            local t = safe(C_Item.GetItemInventoryTypeByID, ranged)
            if t == 25 then equipLoc = "INVTYPE_THROWN" end   -- Enum.InventoryType.IndexThrownType
        end
        if equipLoc == "INVTYPE_THROWN" then
            local n = safe(GetInventoryItemCount, "player", 18) or 0
            local total = ItemCount(ranged)
            return math.max(n, total), ranged, "warrior"
        end
        local id = safe(GetInventoryItemID, "player", 0)
        if not id then return 0, nil, "warrior" end
        local n = ItemCount(id)
        if n == 0 then n = safe(GetInventoryItemCount, "player", 0) or 0 end
        return n, id, "warrior"
    end
    return nil
end

function R.AmmoIssue()
    local count, id, who = R.AmmoStatus()
    if count == nil then return nil end
    local db = ns.db
    local vars = { count = count }
    if not id or count <= 0 then
        return { key = "ammo", kind = "ammo", category = "remindAmmoEmpty", vars = vars, state = "empty", priority = true }
    end
    if who == "hunter" then
        if count < (db.ammoLowHunter or 200) then
            return { key = "ammo", kind = "ammo", category = "remindAmmoLow", vars = vars, state = "low", priority = true }
        elseif count < (db.ammoWarnHunter or 600) then
            return { key = "ammo", kind = "ammo", category = "remindAmmo", vars = vars, state = "warn" }
        end
    elseif count < (db.ammoWarnWarrior or 50) then
        return { key = "ammo", kind = "ammo", category = "remindAmmo", vars = vars, state = "warn" }
    end
    return { key = "ammo", kind = "ammo", state = "ok" }
end

-- All current issues (including "ok" entries, used to notice state changes).
function R.Status()
    local auras = R.ReadAuras()
    local list = {}
    if ns.db.remindFood then local f = R.FoodIssue(auras) if f then table.insert(list, f) end end
    if ns.db.remindAmmo then local a = R.AmmoIssue() if a then table.insert(list, a) end end
    if ns.db.remindBuffs then for _, b in ipairs(R.BuffIssues(auras)) do table.insert(list, b) end end
    return list
end

-- ===================== SPEAKING =====================
local lastState, lastAt = {}, {}
R.lastState, R.lastAt = lastState, lastAt

function R.CanRemind()
    if safe(UnitIsDeadOrGhost, "player") then return false end
    if safe(UnitOnTaxi, "player") then return false end
    if safe(UnitAffectingCombat, "player") then return false end
    return true
end

-- Speak at most one reminder per check: priority issues first, then state changes.
function R.Check()
    if ns.IsModuleEnabled and not ns.IsModuleEnabled("reminders") then return nil end
    if not ns.db or not R.CanRemind() then return nil end
    local now = GetTime()
    local mult = (ns.ChattyMult and ns.ChattyMult() or 1)
    local city = safe(IsResting) and CITY_MULT or 1
    local candidates = {}
    for _, issue in ipairs(R.Status()) do
        local changed = lastState[issue.key] ~= issue.state
        if issue.state == "ok" then
            lastState[issue.key] = "ok"
        else
            local interval = (INTERVAL[issue.kind] or 300) * city / mult
            if changed or not lastAt[issue.key] or now - lastAt[issue.key] >= interval then
                issue.changed = changed
                table.insert(candidates, issue)
            end
        end
    end
    table.sort(candidates, function(a, b)
        if (a.priority and 1 or 0) ~= (b.priority and 1 or 0) then return a.priority and true or false end
        return (a.changed and 1 or 0) > (b.changed and 1 or 0)
    end)
    local issue = candidates[1]
    if not issue then return nil end
    -- Several buffs missing at once: use a generic line.
    local category = issue.category
    local buffs = 0
    for _, c in ipairs(candidates) do if c.kind == "buff" and c.state == "missing" then buffs = buffs + 1 end end
    if issue.kind == "buff" and issue.state == "missing" and buffs >= 2 then category = "remindBuffs" end
    local said = ns:Say(category, { vars = issue.vars, priority = issue.priority })
    if said then
        if category == "remindBuffs" then
            for _, c in ipairs(candidates) do
                if c.kind == "buff" then lastState[c.key], lastAt[c.key] = c.state, now end
            end
        end
        lastState[issue.key], lastAt[issue.key] = issue.state, now
    end
    return said, category
end

local lastCheck = -999
local function Throttled()
    local now = GetTime()
    if now - lastCheck < CHECK_THROTTLE then return end
    lastCheck = now
    R.Check()
end
R.Throttled = Throttled
function R.ResetThrottle() lastCheck = -999 end

-- ===================== BATTLE SHOUT (combat start only) =====================
local shoutedThisFight = false
function R.OnCombatStart()
    if PlayerClass() ~= "WARRIOR" or shoutedThisFight or not ns.db.remindBuffs then return nil end
    if not R.Knows("Battle Shout") then return nil end
    if R.ReadAuras()["Battle Shout"] then return nil end
    shoutedThisFight = true
    return ns:Say("remindBattleShout", { priority = true })
end

ns:On("PLAYER_REGEN_DISABLED", function() R.OnCombatStart() end)
ns:On("PLAYER_REGEN_ENABLED", function()
    shoutedThisFight = false
    C_Timer.After(1.5, function() R.ResetThrottle() Throttled() end)
end)
ns:On("BAG_UPDATE_DELAYED", Throttled)
ns:On("UNIT_INVENTORY_CHANGED", function(unit) if unit == "player" then Throttled() end end)
ns:On("PLAYER_EQUIPMENT_CHANGED", Throttled)
ns:On("UNIT_AURA", function(unit) if unit == "player" then Throttled() end end)
ns:On("LOGIN", function()
    C_Timer.After(20, Throttled)
    C_Timer.NewTicker(15, Throttled)
end)

-- ===================== COMMANDS =====================
function ns.SetReminder(key, on) ns.db[key] = on and true or false end
function ns.SetAmmoThreshold(key, v)
    v = math.floor(tonumber(v) or 0)
    if v >= 0 then ns.db[key] = v end
end
local TOGGLES = { food = "remindFood", ammo = "remindAmmo", buffs = "remindBuffs" }

ns:AddCommand("remind", function(rest)
    rest = (rest or ""):lower()
    if TOGGLES[rest] then
        local key = TOGGLES[rest]
        ns.SetReminder(key, not ns.db[key])
        ns.Print(rest .. " reminders " .. (ns.db[key] and "on" or "off"))
        if ns.UpdateGeneralOptions then ns.UpdateGeneralOptions() end
        return
    elseif rest ~= "" then
        ns.Print("usage: /comp remind  (status)  or  /comp remind food|ammo|buffs  (toggle)")
        return
    end
    ns.Print("reminder status:")
    local any = false
    for _, i in ipairs(R.Status()) do
        local what = i.kind == "ammo" and ("ammo (" .. tostring(i.vars and i.vars.count or "?") .. ")")
            or (i.vars and i.vars.buff) or i.kind
        local color = i.state == "ok" and "|cff20ff20" or "|cffff6060"
        print("  " .. what .. ": " .. color .. i.state .. "|r")
        any = true
    end
    if not any then print("  nothing to track for this character") end
    print(string.format("  food %s, ammo %s, buffs %s", ns.db.remindFood and "on" or "off",
        ns.db.remindAmmo and "on" or "off", ns.db.remindBuffs and "on" or "off"))
end)

ns:AddCommand("ammodebug", function()
    local p = ns.Print
    p("ammo slot id: " .. tostring(safe(GetInventoryItemID, "player", 0)) .. "  slot count: " .. tostring(safe(GetInventoryItemCount, "player", 0)))
    p("APIs: C_Container=" .. tostring(C_Container ~= nil) .. " GetItemInfoInstant=" .. tostring(GetItemInfoInstant ~= nil) .. " C_Item.GetItemInfoInstant=" .. tostring(C_Item and C_Item.GetItemInfoInstant ~= nil))
    local C = C_Container
    local numSlots = (C and C.GetContainerNumSlots) or GetContainerNumSlots
    local idAt = (C and C.GetContainerItemID) or GetContainerItemID
    for bag = 0, 4 do
        for slot = 1, (safe(numSlots, bag) or 0) do
            local id = safe(idAt, bag, slot)
            if id then
                local inst = GetItemInfoInstant or (C_Item and C_Item.GetItemInfoInstant)
                local _, itype, _, loc, _, classID = safe(inst, id)
                local name = safe(GetItemInfo, id)
                if classID == 6 or loc == "INVTYPE_AMMO" or (name and name:find("Arrow")) or (name and name:find("Shot")) then
                    p(string.format("bag %d slot %d: %s id=%s type=%s loc=%s class=%s ammo=%s", bag, slot, tostring(name), tostring(id), tostring(itype), tostring(loc), tostring(classID), tostring(R.IsAmmo(id))))
                end
            end
        end
    end
    local n, id = R.BagAmmo()
    p("bag ammo total: " .. tostring(n) .. " (id " .. tostring(id) .. ")")
end, "show what the game reports for your ammo")
