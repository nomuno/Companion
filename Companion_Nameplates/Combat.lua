-- Companion module: Nameplates. Uses the shared Companion table (this file is a separate addon; `ns` is not shared automatically).
-- Companion: Combat helpers (0.56)
--   A) Buff ring: the player's class self-buffs as small icons on the portrait ring (paladin for now).
--   B) Enemy nameplates in Companion style (Threat Plates look) with threat glow.
--   C) Quest-mob icon (crossed swords + number left) on enemy nameplates.
-- Our own code. The threat colour scheme and the quest-widget idea follow Threat Plates
-- (TidyPlates_ThreatPlates, GPL) - see CREDITS.txt. B and C switch themselves off when Threat Plates
-- is loaded. Nothing here touches friendly plates or nameplate CVars (Nodes.lua owns those).

local ns = _G.Companion
if not ns then return end
ns.defaults.buffRing = true
ns.defaults.buffRingWarn = 60
ns.defaults.threatPlates = true
ns.defaults.questPlates = true

local C = {}
ns.combat = C

local function safe(fn, ...)
    if not fn then return nil end
    local ok, a, b, c, d, e = pcall(fn, ...)
    if ok then return a, b, c, d, e end
end
local function secret(v) return issecretvalue ~= nil and issecretvalue(v) == true end
-- 0.63: boolean from a unit API call: true/false, or nil when it errors or is a secret value
-- (secret booleans can't be compared or tested - doing so errors in instances).
local function B(fn, ...)
    if not fn then return nil end
    local ok, v = pcall(fn, ...)
    if not ok or secret(v) then return nil end
    return v == true
end
local function str(v) if type(v) == "string" and not secret(v) then return v end end
local function num(v) if type(v) == "number" and not secret(v) then return v end end

-- ===================== A) BUFF RING =====================
-- Per-class slot lists; each slot shows whichever of its spells is active (or the first learned one
-- greyed red when none is). Add another class by adding an entry here.
C.CLASS_SLOTS = {
    PALADIN = {
        { key = "aura", spells = { "Devotion Aura", "Retribution Aura", "Concentration Aura", "Sanctity Aura",
            "Shadow Resistance Aura", "Frost Resistance Aura", "Fire Resistance Aura" } },
        -- seals only last 30 s: they warn at 5 s, not at the general threshold
        { key = "seal", warn = 5, prefix = "Seal of ", spells = { "Seal of Fury", "Seal of Righteousness", "Seal of the Crusader", "Seal of Command",
            "Seal of Wisdom", "Seal of Light", "Seal of Justice" } },
        { key = "blessing", spells = { "Blessing of Might", "Blessing of Wisdom", "Blessing of Kings",
            "Blessing of Salvation", "Blessing of Light", "Blessing of Sanctuary",
            "Greater Blessing of Might", "Greater Blessing of Wisdom", "Greater Blessing of Kings",
            "Greater Blessing of Salvation", "Greater Blessing of Light", "Greater Blessing of Sanctuary" } },
        { key = "fury", spells = { "Righteous Fury" } },
    },
    -- 0.63j: every class with a self-buff to keep up. prefix/suffix also catch Forever's custom spells.
    MAGE = {
        { key = "armor", suffix = " Armor", spells = { "Mage Armor", "Ice Armor", "Frost Armor", "Molten Armor" } },
        { key = "intellect", spells = { "Arcane Intellect", "Arcane Brilliance" } },
    },
    PRIEST = {
        { key = "fortitude", spells = { "Power Word: Fortitude", "Prayer of Fortitude" } },
        { key = "innerfire", spells = { "Inner Fire" } },
        { key = "shadowform", spells = { "Shadowform" } },
    },
    WARLOCK = {
        { key = "armor", spells = { "Demon Armor", "Demon Skin", "Fel Armor" } },
        { key = "soullink", spells = { "Soul Link" } },
    },
    DRUID = {
        { key = "mark", spells = { "Mark of the Wild", "Gift of the Wild" } },
        { key = "thorns", spells = { "Thorns" } },
    },
    SHAMAN = {
        { key = "shield", suffix = " Shield", spells = { "Lightning Shield", "Water Shield", "Earth Shield" } },
        { key = "mainhand", weapon = 16, label = "Main-hand imbue",
            spells = { "Windfury Weapon", "Flametongue Weapon", "Frostbrand Weapon", "Rockbiter Weapon" } },
        { key = "offhand", weapon = 17, label = "Off-hand imbue", needOffhand = true,
            spells = { "Windfury Weapon", "Flametongue Weapon", "Frostbrand Weapon", "Rockbiter Weapon" } },
    },
    WARRIOR = {
        { key = "shout", spells = { "Battle Shout" } },
    },
    HUNTER = {
        { key = "aspect", prefix = "Aspect of the ", spells = { "Aspect of the Hawk", "Aspect of the Monkey", "Aspect of the Cheetah",
            "Aspect of the Pack", "Aspect of the Wild", "Aspect of the Beast", "Aspect of the Viper", "Aspect of the Dragonhawk" } },
        { key = "trueshot", spells = { "Trueshot Aura" } },
    },
    -- poisons are items, not spells: shown from level 20 (when rogues learn Poisons)
    ROGUE = {
        { key = "mainhand", weapon = 16, label = "Main-hand poison", minLevel = 20, icon = 132273, spells = {} },
        { key = "offhand", weapon = 17, label = "Off-hand poison", minLevel = 20, needOffhand = true, icon = 132273, spells = {} },
    },
}
C.WEAPON_KEY = { [16] = "@weapon16", [17] = "@weapon17" }

-- Does this slot apply right now? (level gate, off-hand weapon present)
function C.SlotAvailable(slot)
    if slot.minLevel then
        local lvl = num(safe(UnitLevel, "player"))
        if not lvl or lvl < slot.minLevel then return false end
    end
    if slot.needOffhand then
        if OffhandHasWeapon then
            local v = safe(OffhandHasWeapon)
            if secret(v) or not v then return false end
        else
            local id = safe(GetInventoryItemID, "player", 17)
            if not num(id) then return false end
        end
    end
    return true
end

local function PlayerClass()
    local _, cls = safe(UnitClass, "player")
    return str(cls)
end

-- spell texture if the player knows it (by name), else nil
function C.KnownSpellIcon(name)
    if C_Spell and C_Spell.GetSpellInfo then
        local info = safe(C_Spell.GetSpellInfo, name)
        if type(info) == "table" then return num(info.iconID) or info.iconID or 134400 end
    end
    if GetSpellInfo then
        local n, _, icon = safe(GetSpellInfo, name)
        if n then return icon or 134400 end
    end
end

-- active spell for a slot: a listed spell, else (slot.prefix) any buff whose name starts with it,
-- e.g. Forever's custom "Seal of ..." seals
function C.SlotMatch(slot, auras)
    if slot.weapon then
        local k = C.WEAPON_KEY[slot.weapon]
        if auras[k] then return k end
        return nil
    end
    for _, sp in ipairs(slot.spells) do if auras[sp] then return sp end end
    if slot.suffix then
        for name in pairs(auras) do
            if type(name) == "string" and #name > #slot.suffix and name:sub(-#slot.suffix) == slot.suffix then return name end
        end
    end
    if slot.prefix then
        for name in pairs(auras) do
            if type(name) == "string" and name:sub(1, #slot.prefix) == slot.prefix then return name end
        end
    end
end

-- Pure: slot states from auras ({name = secondsLeft}), a known(name)->icon function, and the threshold.
-- Returns list of { key, spell, icon, left, state = "ok"|"warn"|"missing" } for slots with a learned spell.
function C.SlotStates(slots, auras, known, warn)
    local out = {}
    for _, slot in ipairs(slots or {}) do
        if C.SlotAvailable(slot) then
            local firstSpell, firstIcon, active
            for _, sp in ipairs(slot.spells) do
                local icon = known(sp)
                if icon and not firstSpell then firstSpell, firstIcon = sp, icon end
            end
            if slot.weapon then   -- weapon slots show their label; rogues need no learned spell
                if firstSpell or slot.icon then firstSpell, firstIcon = slot.label, firstIcon or slot.icon end
            end
            local hit = C.SlotMatch(slot, auras)
            if hit and slot.weapon and not firstSpell then hit = nil end
            if hit then active = { spell = slot.weapon and slot.label or hit, icon = (not slot.weapon and known(hit)) or firstIcon, left = auras[hit] } end
            if active then
                local w = slot.warn or warn or 60
                out[#out + 1] = { key = slot.key, spell = active.spell, icon = active.icon or 134400, left = active.left,
                    state = (active.left < w) and "warn" or "ok" }
            elseif firstSpell then
                out[#out + 1] = { key = slot.key, spell = firstSpell, icon = firstIcon, state = "missing" }
            end
        end
    end
    return out
end

local ICON = 40   -- 0.57: about twice the first size
-- outer diameter of an icon with its gold ring (measured: ring ~1.32x the icon) and the gap between rings
C.ICON_OUTER, C.ICON_GAP = math.floor(ICON * 1.32 + 0.5), 4
local icons = {}
local function GetIcon(i)
    if icons[i] then return icons[i] end
    local f = CreateFrame("Frame", nil, ns.frame)
    f:SetSize(ICON, ICON)
    f.tex = f:CreateTexture(nil, "ARTWORK")
    f.tex:SetAllPoints()
    -- 0.61: round icons - circular mask (built-in portrait mask) or, without masks, a tight crop
    if f.CreateMaskTexture and f.tex.AddMaskTexture then
        local m = f:CreateMaskTexture()
        if m then
            m:SetAllPoints(f.tex)
            m:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
            f.tex:AddMaskTexture(m)
            f.mask = m
        end
    end
    if f.tex.SetTexCoord then f.tex:SetTexCoord(0.07, 0.93, 0.07, 0.93) end
    -- gold minimap-button ring; its art is off-centre in a 64px file, so place it like a minimap
    -- button (20px icon in a 53px border at 7,-5 -> scaled to our icon size)
    local sc = ICON / 20
    f.border = f:CreateTexture(nil, "ARTWORK", nil, 7)   -- above the icon, below the countdown text
    f.border:SetSize(53 * sc, 53 * sc)
    f.border:SetPoint("TOPLEFT", f, "CENTER", -17 * sc, 15 * sc)
    f.border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    f.text = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    f.text:SetPoint("CENTER", f, "CENTER", 0, 0)
    if f.text.SetFont and STANDARD_TEXT_FONT then f.text:SetFont(STANDARD_TEXT_FONT, 16, "THICKOUTLINE") end
    f:EnableMouse(true)
    f:SetScript("OnEnter", function(self)
        if not (GameTooltip and self.spell) then return end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(self.spell)
        GameTooltip:AddLine(self.state == "missing" and "missing" or (self.left and self.left < 1e9 and string.format("%d s left", self.left) or "active"), 1, 1, 1)
        GameTooltip:Show()
    end)
    f:SetScript("OnLeave", function() if GameTooltip then GameTooltip:Hide() end end)
    icons[i] = f
    return f
end

-- placement: on the ring's lower-left arc in round style, along the box's bottom edge in classic
function C.IconPoint(i, n, round)
    if round then
        local R = ns.ROUND or { MID = 121 }
        local step = (C.ICON_OUTER + C.ICON_GAP) / R.MID     -- arc length -> angle
        local rel = math.pi * 0.55 + (i - 1) * step   -- from lower-left, going round the bottom
        local x, y = ns.RingPoint(rel, R.MID)
        return "CENTER", ns.roundFrame, "CENTER", x, y
    end
    local pad = (C.ICON_OUTER - ICON) / 2
    return "BOTTOMLEFT", ns.classicBox or ns.frame, "BOTTOMLEFT", 10 + pad + (i - 1) * (C.ICON_OUTER + C.ICON_GAP), 18
end

-- 0.60: aura reads can be secret in combat. ReadSlotAuras returns { [spell] = secondsLeft } plus
-- `unreliable` = true when any read came back secret/unusable, and the aura instance IDs seen.
local function SpellID(name)
    if C_Spell and C_Spell.GetSpellInfo then
        local info = safe(C_Spell.GetSpellInfo, name)
        if type(info) == "table" then return num(info.spellID) end
    end
    if GetSpellInfo then local _, _, _, _, _, _, id = safe(GetSpellInfo, name) return num(id) end
end
function C.ReadSlotAuras(slots, dbg)
    local out, inst, unreliable = {}, {}, false
    local now = GetTime and GetTime() or 0
    local function put(name, exp, id, how)
        if not name then return end
        local left = math.huge
        if num(exp) and exp > 0 then left = exp - now end
        if not out[name] or left > out[name] then out[name] = left end
        if num(id) then inst[name] = id end
        if dbg then dbg[name] = (dbg[name] and dbg[name] .. ", " or "") .. how end
    end
    -- 1) full aura scan
    local scanned = 0
    if C_UnitAuras and C_UnitAuras.GetAuraDataByIndex then
        for i = 1, 40 do
            local a = safe(C_UnitAuras.GetAuraDataByIndex, "player", i, "HELPFUL")
            if type(a) ~= "table" then break end
            scanned = scanned + 1
            if secret(a.name) or secret(a.expirationTime) then unreliable = true
            else put(str(a.name), a.expirationTime, a.auraInstanceID, "scan") end
        end
    elseif UnitBuff then
        for i = 1, 40 do
            local n, _, _, _, _, exp = safe(UnitBuff, "player", i)
            if not secret(n) and n == nil then break end
            scanned = scanned + 1
            if secret(n) or secret(exp) then unreliable = true else put(str(n), exp, nil, "UnitBuff") end
        end
    end
    -- 2) by spell ID / name for the slot spells (may work when the scan is secret)
    for _, slot in ipairs(slots or {}) do
        for _, sp in ipairs(slot.spells) do
            local id = SpellID(sp)
            if id and C_UnitAuras and C_UnitAuras.GetPlayerAuraBySpellID then
                local a = safe(C_UnitAuras.GetPlayerAuraBySpellID, id)
                if type(a) == "table" then
                    if secret(a.expirationTime) then put(sp, nil, nil, "bySpellID(secret time)") unreliable = true
                    else put(sp, a.expirationTime, a.auraInstanceID, "bySpellID") end
                end
            end
            if AuraUtil and AuraUtil.FindAuraByName and not out[sp] then
                local n, _, _, _, _, exp = safe(AuraUtil.FindAuraByName, sp, "player", "HELPFUL")
                if secret(n) or n ~= nil then if secret(exp) then put(sp, nil, nil, "FindAuraByName(secret time)") else put(sp, exp, nil, "FindAuraByName") end end
            end
        end
    end
    -- 2b) weapon imbues / poisons (shaman, rogue): GetWeaponEnchantInfo, times in ms
    local wantWeapon
    for _, slot in ipairs(slots or {}) do if slot.weapon then wantWeapon = true end end
    if wantWeapon and GetWeaponEnchantInfo then
        local ok, hasMain, mainExp, _, _, hasOff, offExp = pcall(GetWeaponEnchantInfo)
        if ok then
            local function weapon(has, ms, slotId)
                if secret(has) or secret(ms) then unreliable = true return end
                if has then put(C.WEAPON_KEY[slotId], num(ms) and (now + ms / 1000) or nil, nil, "weapon") end
            end
            weapon(hasMain, mainExp, 16)
            weapon(hasOff, offExp, 17)
        end
    end
    -- 3) shapeshift-style auras (paladin auras can be forms on Classic clients)
    if GetNumShapeshiftForms and GetShapeshiftFormInfo then
        local n = num(safe(GetNumShapeshiftForms)) or 0
        for i = 1, n do
            local _, active, _, id = safe(GetShapeshiftFormInfo, i)
            if not secret(active) and active == true and num(id) then
                local name
                if C_Spell and C_Spell.GetSpellName then name = str(safe(C_Spell.GetSpellName, id)) end
                if not name and GetSpellInfo then name = str(safe(GetSpellInfo, id)) end
                put(name, nil, nil, "form")
            end
        end
    end
    -- 0.60b: in combat Forever's scan can return nothing at all (not secret, just empty), so an absence
    -- seen in combat is never trusted; and an empty scan while something else proves we have a buff
    -- (e.g. the aura via forms) is not trusted either.
    local fighting = B(InCombatLockdown) == true or B(UnitAffectingCombat, "player") == true
    if fighting or (scanned == 0 and next(out) ~= nil) then unreliable = true end
    if dbg then dbg._scanned, dbg._fighting = scanned, fighting end
    return out, unreliable, inst
end

-- Pure: merge a read with the per-slot cache. A slot that reads missing keeps its cached spell and
-- counts down from the cached expiry when the read was unreliable and no removal was confirmed.
C.cache = {}
function C.MergeCache(slots, auras, unreliable, now, cache)
    cache = cache or C.cache
    local merged = {}
    for k, v in pairs(auras) do merged[k] = v end
    for _, slot in ipairs(slots or {}) do
        local found = C.SlotMatch(slot, auras)
        local c = cache[slot.key]
        if found then
            local left = auras[found]
            cache[slot.key] = { spell = found, exp = (left == math.huge) and math.huge or (now + left), inst = c and c.spell == found and c.inst or nil }
        elseif c and unreliable and not c.removed then
            local left = (c.exp == math.huge) and math.huge or (c.exp - now)
            if left > 0 then merged[c.spell] = left else cache[slot.key] = nil end
        else
            cache[slot.key] = nil
        end
    end
    return merged
end

function C.UpdateBuffRing()
    local cls = PlayerClass()
    local slots = cls and C.CLASS_SLOTS[cls]
    local states = {}
    if slots and ns.db and ns.db.buffRing and (not ns.IsModuleEnabled or ns.IsModuleEnabled("nameplates")) and ns.reminders and ns.reminders.ReadAuras then
        local auras, unreliable, inst = C.ReadSlotAuras(slots)
        auras = C.MergeCache(slots, auras, unreliable, GetTime and GetTime() or 0)
        for _, c in pairs(C.cache) do if inst[c.spell] then c.inst = inst[c.spell] end end
        states = C.SlotStates(slots, auras, C.KnownSpellIcon, ns.db.buffRingWarn or 60)
    end
    local round = ns.IsRoundStyle and ns.IsRoundStyle()
    for i, s in ipairs(states) do
        local f = GetIcon(i)
        f:ClearAllPoints()
        f:SetPoint(C.IconPoint(i, #states, round))
        f:SetFrameLevel((ns.modelArea and ns.modelArea:GetFrameLevel() or 10) + 8)
        f.tex:SetTexture(s.icon)
        f.spell, f.state, f.left = s.spell, s.state, s.left
        if f.tex.SetDesaturated then f.tex:SetDesaturated(s.state == "missing") end
        if s.state == "ok" then f.tex:SetVertexColor(1, 1, 1) f.border:SetVertexColor(1, 1, 1)
        elseif s.state == "warn" then f.tex:SetVertexColor(1, 0.45, 0.45) f.border:SetVertexColor(1, 0.15, 0.15)
        else f.tex:SetVertexColor(0.9, 0.3, 0.3) f.border:SetVertexColor(1, 0.1, 0.1) end
        f.text:SetText((s.state == "warn" and s.left and s.left < 1e9) and tostring(math.floor(s.left)) or "")
        f:Show()
    end
    for i = #states + 1, #icons do icons[i]:Hide() end
    C.ringStates = states
    return states
end

function ns.SetBuffRing(on) ns.db.buffRing = on and true or false C.UpdateBuffRing() end
function ns.SetBuffRingWarn(v) ns.db.buffRingWarn = math.max(5, math.min(300, tonumber(v) or 60)) C.UpdateBuffRing() end

-- ===================== shared nameplate helpers =====================
local function TPLoaded()
    local f = (C_AddOns and C_AddOns.IsAddOnLoaded) or IsAddOnLoaded
    return f and safe(f, "TidyPlates_ThreatPlates") and true or false
end
C.TPLoaded = TPLoaded

local function IsEnemy(unit)
    if B(UnitExists, unit) ~= true then return false end
    local can = safe(UnitCanAttack, "player", unit)
    if secret(can) or not can then return false end
    if B(UnitIsFriend, "player", unit) == true then return false end
    return true
end
C.IsEnemy = IsEnemy

local function PlateHealthBar(plate)
    local uf = plate and plate.UnitFrame
    return uf and (uf.healthBar or uf.HealthBar or (uf.HealthBarsContainer and uf.HealthBarsContainer.healthBar))
end

-- ===================== B) THREAT COLOURS =====================
C.COLORS = { safe = { 0.15, 0.8, 0.15 }, warn = { 1, 0.85, 0 }, pull = { 1, 0.5, 0 }, aggro = { 0.9, 0.1, 0.1 } }
C.OVERTAKE = 80   -- % of your threat at which someone else "is close" while you tank

-- Pure: colour key for a threat status. 0.59: 3 = securely tanking (red), 2 = tanking but someone else
-- has more threat, about to lose it (yellow), 1 = not tanking but above the tank, about to pull
-- (orange), 0 = safe (no spikes). othersPct: highest threat % of anyone else (only used at 3).
function C.ThreatKey(status, othersPct)
    if type(status) ~= "number" then return nil end
    if status >= 3 then
        if type(othersPct) == "number" and othersPct >= C.OVERTAKE then return "warn" end
        return "aggro"
    elseif status == 2 then return "warn" elseif status == 1 then return "pull" end
    return "safe"
end

-- highest scaled threat % of your pet and group members (and their pets) on this unit
function C.OthersThreat(unit)
    local list = { "pet" }
    local raid = IsInRaid and safe(IsInRaid)
    local n = (GetNumGroupMembers and num(safe(GetNumGroupMembers))) or 0
    if raid then for i = 1, math.min(n, 40) do list[#list + 1] = "raid" .. i list[#list + 1] = "raidpet" .. i end
    else for i = 1, 4 do list[#list + 1] = "party" .. i list[#list + 1] = "partypet" .. i end end
    local best, who
    for _, u in ipairs(list) do
        if B(UnitExists, u) == true and B(UnitIsUnit, u, "player") ~= true then
            local ok, _, _, scaled = pcall(UnitDetailedThreatSituation or error, u, unit)
            scaled = ok and num(scaled)
            if scaled and (not best or scaled > best) then best, who = scaled, u end
        end
    end
    return best, who
end

-- Threat state for a unit: key, threat percent (or nil), and a debug table.
-- Falls back to "is its target me?" when the threat API returns nothing or a secret value.
function C.ThreatState(unit)
    local d = {}
    local ok, tanking, status, scaled = pcall(UnitDetailedThreatSituation or error, "player", unit)
    d.detailedOk, d.tanking, d.status, d.scaled = ok, tanking, status, scaled
    d.statusSecret = secret(status)
    local st = ok and num(status) or nil
    if not st and UnitThreatSituation then
        local ok2, s2 = pcall(UnitThreatSituation, "player", unit)
        d.simple, d.simpleSecret = ok2 and s2, ok2 and secret(s2)
        st = ok2 and num(s2) or nil
    end
    local others, who
    if st == 3 then others, who = C.OthersThreat(unit) end
    d.others, d.othersWho = others, who
    local key = C.ThreatKey(st, others)
    d.source = key and "threat API" or nil
    if not key then
        local tgt = B(UnitIsUnit, unit .. "target", "player")
        d.targetIsMe = (tgt == nil) and "unknown/secret" or tgt
        local fight = B(UnitAffectingCombat, unit)
        d.inCombat = (fight == nil) and "unknown/secret" or fight
        if tgt == true then key = "aggro" d.source = "fallback: its target is me"
        elseif fight == true and B(UnitAffectingCombat, "player") == true then key = "safe" d.source = "fallback: in combat, not on me" end
    end
    d.key = key
    return key, ok and num(scaled) or nil, d
end

function C.IsTank()
    if str(safe(UnitGroupRolesAssigned, "player")) == "TANK" then return true end
    local a = ns.reminders and ns.reminders.ReadAuras and ns.reminders.ReadAuras()
    return a and a["Righteous Fury"] ~= nil or false
end

function C.ThreatActive()
    if ns.IsModuleEnabled and not ns.IsModuleEnabled("nameplates") then return false end
    return ns.db and ns.db.threatPlates and not TPLoaded()
end
function C.QuestActive()
    if ns.IsModuleEnabled and not ns.IsModuleEnabled("nameplates") then return false end
    return ns.db and ns.db.questPlates and not TPLoaded()
end

-- 0.57: Companion-style enemy plates (look follows Threat Plates): our own bar with a border,
-- health % in the middle, level on the right, name above, threat % on the left and spiky threat
-- glows on both sides. Blizzard's plate visuals are faded (alpha 0) only on enemy plates we style,
-- and restored when the plate is released or the option is off.
local TEX = "Interface\\AddOns\\Companion\\Textures\\"
local BAR_W, BAR_H = 150, 16
local skins = {}
local function Skin(plate)
    local k = skins[plate]
    if k then return k end
    k = CreateFrame("Frame", nil, plate)
    k:SetSize(BAR_W, BAR_H)
    k:SetPoint("CENTER", plate, "CENTER", 0, 0)
    local border = CreateFrame("Frame", nil, k, "BackdropTemplate")
    border:SetPoint("TOPLEFT", -2, 2) border:SetPoint("BOTTOMRIGHT", 2, -2)
    if border.SetBackdrop then
        border:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 2 })
        border:SetBackdropColor(0, 0, 0, 0.85)
        border:SetBackdropBorderColor(0.1, 0.1, 0.1, 1)
    end
    k.border = border
    local bar = CreateFrame("StatusBar", nil, k)
    bar:SetAllPoints()
    bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    bar:SetStatusBarColor(0.8, 0.05, 0.05)
    bar:SetMinMaxValues(0, 1) bar:SetValue(1)
    k.bar = bar
    local function fs(font, size)
        local f = bar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        if f.SetFont and STANDARD_TEXT_FONT then f:SetFont(STANDARD_TEXT_FONT, size, "OUTLINE") end
        return f
    end
    k.hp = fs(nil, 11) k.hp:SetPoint("CENTER", bar, "CENTER", 0, 0) k.hp:SetTextColor(1, 1, 1)
    k.level = fs(nil, 11) k.level:SetPoint("RIGHT", bar, "RIGHT", -4, 0)
    k.name = fs(nil, 12) k.name:SetPoint("BOTTOM", bar, "TOP", 0, 4) k.name:SetTextColor(1, 1, 1)
    k.threat = fs(nil, 12) k.threat:SetPoint("RIGHT", k, "LEFT", -14, 0)   -- clear of the raid mark
    k.spikeL = k:CreateTexture(nil, "BACKGROUND")
    k.spikeL:SetSize(36, 36) k.spikeL:SetPoint("RIGHT", k, "LEFT", 6, 0)
    k.spikeL:SetTexture(TEX .. "threat_spikes")
    k.spikeR = k:CreateTexture(nil, "BACKGROUND")
    k.spikeR:SetSize(36, 36) k.spikeR:SetPoint("LEFT", k, "RIGHT", -6, 0)
    k.spikeR:SetTexture(TEX .. "threat_spikes")
    if k.spikeR.SetTexCoord then k.spikeR:SetTexCoord(1, 0, 0, 1) end
    -- 0.62: "about to lose threat" = yellow (( )) on both sides
    k.parenL = k:CreateTexture(nil, "ARTWORK")
    k.parenL:SetSize(28, 28) k.parenL:SetPoint("RIGHT", k, "LEFT", -8, 0)
    k.parenL:SetTexture(TEX .. "threat_parens")
    k.parenR = k:CreateTexture(nil, "ARTWORK")
    k.parenR:SetSize(28, 28) k.parenR:SetPoint("LEFT", k, "RIGHT", 8, 0)
    k.parenR:SetTexture(TEX .. "threat_parens")
    if k.parenR.SetTexCoord then k.parenR:SetTexCoord(1, 0, 0, 1) end
    k.parenL:Hide() k.parenR:Hide()
    -- 0.61: cast bar under the health bar (icon left, spell name inside)
    local cb = CreateFrame("StatusBar", nil, k)
    cb:SetSize(BAR_W - 12, 8)
    cb:SetPoint("TOPRIGHT", k, "BOTTOMRIGHT", 0, -4)
    cb:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    cb:SetMinMaxValues(0, 1) cb:SetValue(0)
    cb.bg = cb:CreateTexture(nil, "BACKGROUND") cb.bg:SetAllPoints() cb.bg:SetColorTexture(0, 0, 0, 0.8)
    cb.icon = cb:CreateTexture(nil, "OVERLAY") cb.icon:SetSize(11, 11) cb.icon:SetPoint("RIGHT", cb, "LEFT", -1, 0)
    cb.text = cb:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    if cb.text.SetFont and STANDARD_TEXT_FONT then cb.text:SetFont(STANDARD_TEXT_FONT, 8, "OUTLINE") end
    cb.text:SetPoint("CENTER", cb, "CENTER", 0, 0) cb.text:SetTextColor(1, 1, 1)
    cb:SetScript("OnUpdate", function(self)
        if not (self.startMS and self.endMS) then return end
        local now = (GetTime and GetTime() or 0) * 1000
        local f = (now - self.startMS) / math.max(1, self.endMS - self.startMS)
        if f >= 1 then self:Hide() self.startMS = nil return end
        self:SetValue(self.channel and (1 - f) or f)
    end)
    cb:Hide()
    k.cast = cb
    -- 0.60: raid target mark, left of the name (the quest icon sits above the name, spikes on the bar sides)
    -- 0.61b: own frame above the health bar, centred on the bar's left end
    local mf = CreateFrame("Frame", nil, k)
    mf:SetSize(20, 20)
    mf:SetPoint("CENTER", bar, "LEFT", 0, 0)
    mf:SetFrameLevel((bar:GetFrameLevel() or 1) + 5)
    k.markFrame = mf
    k.mark = mf:CreateTexture(nil, "OVERLAY")
    k.mark:SetAllPoints()
    k.mark:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
    k.mark:Hide()
    skins[plate] = k
    return k
end
C.Skin = Skin

local function Release(plate)
    local k = skins[plate]
    if k then k:Hide() end
    local uf = plate and plate.UnitFrame
    if uf and uf.SetAlpha and uf.companionFaded then uf:SetAlpha(1) uf.companionFaded = nil end
end
C.Release = Release

-- tapped by someone outside your group (grey on Blizzard's plates)
function C.IsTapDenied(unit)
    if UnitIsTapDenied then
        local v = safe(UnitIsTapDenied, unit)
        if not secret(v) and v ~= nil then return v == true end
    end
    if UnitIsTapped then
        local t = safe(UnitIsTapped, unit)
        if secret(t) or t ~= true then return false end
        local mine = B(UnitIsTappedByPlayer, unit)
        local all = B(UnitIsTappedByAllThreatList, unit)
        if mine == nil and all == nil and (UnitIsTappedByPlayer or UnitIsTappedByAllThreatList) then return false end
        return not (mine == true or all == true)
    end
    return false
end

-- Pure: cast info -> table or nil. casting: UnitCastingInfo returns, channel: UnitChannelInfo returns.
function C.CastInfo(cast, chan)
    local function pick(t, isChan)
        local name, _, tex, st, en = t[1], t[2], t[3], t[4], t[5]
        local noInt = isChan and t[7] or t[8]
        if not (str(name) and num(st) and num(en)) then return nil end
        return { name = name, icon = num(tex) or str(tex), startMS = st, endMS = en, channel = isChan, notInterruptible = (not secret(noInt) and noInt == true) }
    end
    return (cast and str(cast[1]) and pick(cast, false)) or (chan and str(chan[1]) and pick(chan, true)) or nil
end
function C.UpdateCast(k, unit)
    local cb = k and k.cast
    if not cb then return end
    local cast = UnitCastingInfo and { safe(UnitCastingInfo, unit) } or nil
    local chan = UnitChannelInfo and { safe(UnitChannelInfo, unit) } or nil
    if cast and #cast == 0 then cast = nil end
    if chan and #chan == 0 then chan = nil end
    local ok, info = pcall(C.CastInfo, cast, chan)
    if not (ok and info) then cb:Hide() cb.startMS = nil return end
    cb.startMS, cb.endMS, cb.channel = info.startMS, info.endMS, info.channel
    if info.notInterruptible then cb:SetStatusBarColor(0.7, 0.7, 0.75) else cb:SetStatusBarColor(1, 0.7, 0) end
    cb.icon:SetTexture(info.icon or 136243)
    cb.text:SetText(info.name)
    cb:Show()
end

-- Pure: health bar colour: tapped-by-others grey > neutral (not fighting) yellow > normal red
function C.BarColor(tapped, reaction, fighting)
    if tapped then return 0.5, 0.5, 0.5 end
    if reaction == 4 and not fighting then return 1, 0.85, 0 end
    return 0.8, 0.05, 0.05
end

-- Pure: bar outline colour
function C.BorderColor(isTarget, look)
    if look == "parens" then local c = C.COLORS.warn return c[1], c[2], c[3], 1 end
    if isTarget then return 1, 1, 1, 1 end
    return 0.1, 0.1, 0.1, 1
end

-- Pure: what to draw beside the bar for a threat key: red/orange spikes, yellow (( )), or nothing
function C.ThreatLook(key)
    if key == "warn" then return "parens" end
    if key == "aggro" or key == "pull" then return "spikes" end
end

-- Pure: texcoords of raid mark 1-8 in UI-RaidTargetingIcons (4x4 grid)
function C.MarkCoords(i)
    if type(i) ~= "number" or i < 1 or i > 8 then return nil end
    local col, row = (i - 1) % 4, math.floor((i - 1) / 4)
    return col / 4, (col + 1) / 4, row / 4, (row + 1) / 4
end
-- GetRaidTargetIndex can be a secret value on Forever: we can't compare it then, but Blizzard's
-- SetRaidTargetIconTexture accepts it (that's how its own plates show marks).
function C.UpdateMark(k, unit)
    local idx = safe(GetRaidTargetIndex, unit)
    if secret(idx) then
        if SetRaidTargetIconTexture and pcall(SetRaidTargetIconTexture, k.mark, idx) then k.mark:Show() else k.mark:Hide() end
        return "secret"
    end
    local l, r, t, b = C.MarkCoords(num(idx))
    if l then k.mark:SetTexCoord(l, r, t, b) k.mark:Show() else k.mark:Hide() end
    return idx
end

-- Pure: health percent text ("50%") from cur/max, nil when unreadable
function C.HealthPct(cur, max)
    cur, max = num(cur), num(max)
    if not (cur and max and max > 0) then return nil end
    return math.floor(cur / max * 100 + 0.5)
end

local function UpdateThreat(unit, plate, tank)
    if not (C.ThreatActive() and IsEnemy(unit)) then Release(plate) return end
    local k = Skin(plate)
    local uf = plate.UnitFrame
    if uf and uf.SetAlpha then uf:SetAlpha(0) uf.companionFaded = true end
    -- health
    local cur, max = safe(UnitHealth, unit), safe(UnitHealthMax, unit)
    local pct = C.HealthPct(cur, max)
    if pct then k.bar:SetMinMaxValues(0, 100) k.bar:SetValue(pct) k.hp:SetText(pct .. "%")
    else pcall(k.bar.SetMinMaxValues, k.bar, 0, max or 1) pcall(k.bar.SetValue, k.bar, cur or 1) k.hp:SetText("") end
    -- name / level
    local name = safe(UnitName, unit)
    pcall(k.name.SetText, k.name, name or "")
    local lvl = num(safe(UnitLevel, unit))
    if lvl and lvl > 0 then
        k.level:SetText(tostring(lvl))
        local c = GetCreatureDifficultyColor and safe(GetCreatureDifficultyColor, lvl) or (GetQuestDifficultyColor and safe(GetQuestDifficultyColor, lvl))
        if type(c) == "table" and c.r then k.level:SetTextColor(c.r, c.g, c.b) else k.level:SetTextColor(1, 0.82, 0) end
    else
        k.level:SetText("??") k.level:SetTextColor(1, 0.1, 0.1)
    end
    -- target highlight: white border
    local isTarget = B(UnitIsUnit, unit, "target") == true
    if k.border.SetBackdropBorderColor then
        if isTarget then k.border:SetBackdropBorderColor(1, 1, 1, 1) else k.border:SetBackdropBorderColor(0.1, 0.1, 0.1, 1) end
    end
    -- threat (none on mobs tapped by others: grey bar, no spikes)
    local tapped = C.IsTapDenied(unit)
    local reaction = num(safe(UnitReaction, unit, "player"))
    local fighting = B(UnitAffectingCombat, unit) == true or B(UnitIsUnit, unit .. "target", "player") == true
    k.bar:SetStatusBarColor(C.BarColor(tapped, reaction, fighting))
    local key, pctThreat
    if not tapped then key, pctThreat = C.ThreatState(unit) end
    local col = key and C.COLORS[key]
    local look = C.ThreatLook(key)
    for _, t in ipairs({ k.spikeL, k.spikeR }) do
        if look == "spikes" then t:SetVertexColor(col[1], col[2], col[3]) t:Show() else t:Hide() end
    end
    for _, t in ipairs({ k.parenL, k.parenR }) do
        if look == "parens" then t:SetVertexColor(col[1], col[2], col[3]) t:Show() else t:Hide() end
    end
    -- 0.62b: yellow outline while about to lose aggro, otherwise the usual target/normal border
    if k.border.SetBackdropBorderColor then k.border:SetBackdropBorderColor(C.BorderColor(isTarget, look)) end
    k.threat:ClearAllPoints()
    k.threat:SetPoint("RIGHT", k, "LEFT", look == "parens" and -38 or -14, 0)
    if col and pctThreat then
        k.threat:SetText(string.format("%d%%", math.floor(pctThreat + 0.5)))
        k.threat:SetTextColor(col[1], col[2], col[3])
    else
        k.threat:SetText("")
    end
    C.UpdateMark(k, unit)
    C.UpdateCast(k, unit)
    k:Show()
end

-- ===================== C) QUEST MOB ICON =====================
-- Pure: progress "done/needed" from tooltip/objective lines like "Rot Hide Brute slain: 3/8".
-- Finished objectives are skipped; with several, the one with the most left wins.
-- 0.60: also returns the kind - "kill" (lines with slain/killed) or "item"; kill wins over item.
local function Better(kind, left, bKind, bLeft)
    if not bKind then return true end
    if kind ~= bKind then return kind == "kill" end
    return left > bLeft
end
function C.ProgressFromLines(lines)
    local best, bestLeft, bestKind
    for _, l in ipairs(lines or {}) do
        l = str(l)
        if l then
            local a, b = l:match("(%d+)%s*/%s*(%d+)")
            a, b = tonumber(a), tonumber(b)
            if a and b and b > a then
                local low = l:lower()
                local kind = (low:find("slain", 1, true) or low:find("killed", 1, true)) and "kill" or "item"
                if Better(kind, b - a, bestKind, bestLeft) then best, bestLeft, bestKind = a .. "/" .. b, b - a, kind end
            end
        end
    end
    return best, bestKind
end

local function TooltipLines(unit)
    if not (C_TooltipInfo and C_TooltipInfo.GetUnit) then return nil end
    local data = safe(C_TooltipInfo.GetUnit, unit)
    if type(data) ~= "table" or type(data.lines) ~= "table" then return nil end
    local out = {}
    local QO = Enum and Enum.TooltipDataLineType and Enum.TooltipDataLineType.QuestObjective
    for i = 2, #data.lines do
        local line = data.lines[i]
        local t = line and str(line.leftText)
        -- only quest objective lines (when the client tags line types)
        local lt = line and line.type
        if secret(lt) then lt = nil end
        if t and (not QO or lt == nil or lt == QO) then out[#out + 1] = t end
    end
    return out
end

-- 0.61: only quests actually in the log (GetQuestObjectives also answers for quests you don't have)
function C.InLog(qid)
    if type(qid) ~= "number" or not C_QuestLog then return false end
    if C_QuestLog.IsOnQuest then
        local v = safe(C_QuestLog.IsOnQuest, qid)
        if not secret(v) and v ~= nil then return v == true end
    end
    if C_QuestLog.GetLogIndexForQuestID then
        local i = num(safe(C_QuestLog.GetLogIndexForQuestID, qid))
        return i ~= nil and i > 0
    end
    return false
end
local function ObjectiveLeft(qid, obj)
    if not (C_QuestLog and C_QuestLog.GetQuestObjectives) then return nil end
    if not C.InLog(qid) then return nil end
    if B(C_QuestLog.IsComplete, qid) == true then return nil end
    local list = safe(C_QuestLog.GetQuestObjectives, qid)
    if type(list) ~= "table" then return nil end
    local o = list[obj or 1]
    if type(o) ~= "table" or o.finished then return nil end
    local have, need = num(o.numFulfilled), num(o.numRequired)
    if have and need and need > have then return have .. "/" .. need, (o.type == "monster") and "kill" or "item" end
end

-- guide fallback: active guide kill/collect steps whose title or note names this mob.
-- Returns progress, kind ("kill" for kill steps, "item" for collect); a kill step wins.
function C.GuideLeft(name, steps, isDone, objLeft)
    if not (name and steps) then return nil end
    local lname = name:lower()
    local best, bestKind
    for i, st in ipairs(steps) do
        if (st.type == "kill" or st.type == "collect") and st.qid and not (isDone and isDone(st, i)) then
            local t = ((st.title or "") .. " " .. (st.note or "")):lower()
            if t:find(lname, 1, true) then
                local q = type(st.qid) == "table" and st.qid[1] or st.qid
                local left = objLeft and objLeft(q, st.obj)
                local kind = st.type == "kill" and "kill" or "item"
                if left and (not bestKind or (kind == "kill" and bestKind ~= "kill")) then best, bestKind = left, kind end
                if bestKind == "kill" then break end
            end
        end
    end
    return best, bestKind
end

function C.QuestLeft(unit)
    local left, kind = C.ProgressFromLines(TooltipLines(unit))
    if left then return left, kind end
    local name = str(safe(UnitName, unit))
    local G = ns.guide
    local steps = G and G.active and G.active.steps
    local done = G and G.IsStepDone and function(st, i) return safe(G.IsStepDone, st, i) end
    return C.GuideLeft(name, steps, done, ObjectiveLeft)
end

local qicons = {}
local function QuestIcon(plate)
    local f = qicons[plate]
    if f then return f end
    f = CreateFrame("Frame", nil, plate)
    f:SetSize(32, 32)
    f.tex = f:CreateTexture(nil, "OVERLAY")
    f.tex:SetAllPoints()
    f.tex:SetTexture("Interface\\WorldStateFrame\\CombatSwords")
    if f.tex.SetTexCoord then f.tex:SetTexCoord(0, 0.5, 0, 0.5) end
    f.text = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    f.text:SetPoint("LEFT", f, "RIGHT", 1, 0)
    if f.text.SetFont and STANDARD_TEXT_FONT then f.text:SetFont(STANDARD_TEXT_FONT, 16, "THICKOUTLINE") end
    f.text:SetTextColor(1, 0.82, 0)
    qicons[plate] = f
    return f
end

local function UpdateQuest(unit, plate)
    local left, kind
    if C.QuestActive() and IsEnemy(unit) then left, kind = C.QuestLeft(unit) end
    if left then
        local f = QuestIcon(plate)
        if f.kind ~= kind then
            f.kind = kind
            if kind == "item" then
                -- 0.62c: the loot cursor's pouch (Interface\Cursor\Pickup, the LOOT_CURSOR art); bag icon if missing
                local ok = f.tex:SetTexture("Interface\\Cursor\\Pickup")
                if ok == false then f.tex:SetTexture("Interface\\Icons\\INV_Misc_Bag_07") end
                if f.tex.SetTexCoord then f.tex:SetTexCoord(0, 1, 0, 1) end
            else
                f.tex:SetTexture("Interface\\WorldStateFrame\\CombatSwords")
                if f.tex.SetTexCoord then f.tex:SetTexCoord(0, 0.5, 0, 0.5) end
            end
        end
        f:ClearAllPoints()
        local k = skins[plate]
        f.text:SetText(tostring(left))
        -- centre icon + counter together above the name (or above Blizzard's plate)
        local tw = 0
        if f.text.GetStringWidth then local ok, w = pcall(f.text.GetStringWidth, f.text) if ok and num(w) then tw = w end end
        local dx = -(tw + 1) / 2
        if k and k:IsShown() then
            f:SetPoint("BOTTOM", k.name, "TOP", dx, 2)
        else
            f:SetPoint("BOTTOM", plate, "TOP", dx, 2)
        end
        f:Show()
    elseif qicons[plate] then
        qicons[plate]:Hide()
    end
end

-- ===================== plate loop =====================
local function PlateUnit(plate)
    local u = plate and (plate.namePlateUnitToken or (plate.UnitFrame and plate.UnitFrame.unit))
    return str(u)
end

function C.UpdatePlates()
    if not (C_NamePlate and C_NamePlate.GetNamePlates) then return end
    local tank = C.IsTank()
    for _, plate in ipairs(safe(C_NamePlate.GetNamePlates) or {}) do
        local unit = PlateUnit(plate)
        if unit then
            UpdateThreat(unit, plate, tank)
            UpdateQuest(unit, plate)
        end
    end
end

local hinted, tpNoted = false, false
function C.CheckHints()
    if TPLoaded() then
        if not tpNoted and ns.db and (ns.db.threatPlates or ns.db.questPlates) then
            tpNoted = true
            ns.Print("Threat Plates is loaded, so Companion's threat colours and quest-mob icons are off.")
        end
        return
    end
    if hinted or not (ns.db and (ns.db.threatPlates or ns.db.questPlates)) then return end
    local v = (C_CVar and C_CVar.GetCVar and safe(C_CVar.GetCVar, "nameplateShowEnemies")) or (GetCVar and safe(GetCVar, "nameplateShowEnemies"))
    if v ~= nil and tostring(v) ~= "1" then
        hinted = true
        ns.Print("enemy nameplates are off (Esc > Options > Nameplates, or press V) - threat colours and quest icons need them.")
    end
end

function ns.SetThreatPlates(on)
    ns.db.threatPlates = on and true or false
    if not C.ThreatActive() then for plate in pairs(skins) do Release(plate) end end
    C.CheckHints() C.UpdatePlates()
end
function ns.SetQuestPlates(on) ns.db.questPlates = on and true or false C.CheckHints() C.UpdatePlates() end

-- ===================== events =====================
ns:AddCommand("threat", function()
    local unit = "target"
    if B(UnitExists, unit) ~= true then ns.Print("threat: target an enemy first") return end
    local _, _, d = C.ThreatState(unit)
    local function v(x) if secret(x) then return "SECRET" end return tostring(x) end
    ns.Print(string.format("threat: Detailed ok=%s tanking=%s status=%s scaled=%s | Simple=%s | targetIsMe=%s inCombat=%s",
        v(d.detailedOk), v(d.tanking), v(d.status), v(d.scaled), v(d.simple), v(d.targetIsMe), v(d.inCombat)))
    ns.Print(string.format("threat: others' highest=%s (%s), yellow at %d%%", v(d.others), v(d.othersWho), C.OVERTAKE))
    ns.Print("threat: state=" .. tostring(d.key or "none") .. " via " .. tostring(d.source or "nothing")
        .. " | enemy=" .. tostring(IsEnemy(unit)) .. " plates on=" .. tostring(C.ThreatActive()))
end)
table.insert(ns.HELP, "/comp threat - threat readings for your target (debug)")

ns:On("LOGIN", function()
    C.CheckHints()
    C.UpdateBuffRing()
    if C_Timer and C_Timer.NewTicker then
        C_Timer.NewTicker(0.5, function()
            if ns.db and ns.db.buffRing then C.UpdateBuffRing() end
            if C.ThreatActive() or C.QuestActive() then C.UpdatePlates() end
        end)
    end
end)
ns:On("NAME_PLATE_UNIT_ADDED", function() C.UpdatePlates() end)
ns:On("NAME_PLATE_UNIT_REMOVED", function(unit)
    local plate = C_NamePlate and C_NamePlate.GetNamePlateForUnit and safe(C_NamePlate.GetNamePlateForUnit, unit)
    if plate then Release(plate) if qicons[plate] then qicons[plate]:Hide() end end
end)
ns:On("UNIT_FLAGS", function(unit) if C.ThreatActive() and type(unit) == "string" and unit:find("^nameplate") then C.UpdatePlates() end end)
local function CastEvent(unit)
    if not (C.ThreatActive() and type(unit) == "string" and unit:find("^nameplate")) then return end
    local plate = C_NamePlate and C_NamePlate.GetNamePlateForUnit and safe(C_NamePlate.GetNamePlateForUnit, unit)
    local k = plate and skins[plate]
    if k and k:IsShown() then C.UpdateCast(k, unit) end
end
for _, e in ipairs({ "UNIT_SPELLCAST_START", "UNIT_SPELLCAST_STOP", "UNIT_SPELLCAST_FAILED", "UNIT_SPELLCAST_INTERRUPTED",
    "UNIT_SPELLCAST_DELAYED", "UNIT_SPELLCAST_CHANNEL_START", "UNIT_SPELLCAST_CHANNEL_UPDATE", "UNIT_SPELLCAST_CHANNEL_STOP",
    "UNIT_SPELLCAST_SUCCEEDED" }) do
    ns:On(e, CastEvent)
end
ns:On("RAID_TARGET_UPDATE", function() if C.ThreatActive() then C.UpdatePlates() end end)
ns:On("PLAYER_TARGET_CHANGED", function() if C.ThreatActive() then C.UpdatePlates() end end)
-- UNIT_AURA payload: a removed aura instance we cached is a confirmed removal
function C.NoteAuraUpdate(info, cache)
    cache = cache or C.cache
    if type(info) ~= "table" or secret(info) then return end
    local added = info.addedAuras
    if type(added) == "table" and not secret(added) then
        local slots = C.CLASS_SLOTS[PlayerClass() or ""] or {}
        local now = GetTime and GetTime() or 0
        for _, a in ipairs(added) do
            local n = type(a) == "table" and str(a.name)
            if n then
                for _, slot in ipairs(slots) do
                    if not slot.weapon and C.SlotMatch(slot, { [n] = 1 }) == n then
                        local exp = num(a.expirationTime)
                        cache[slot.key] = { spell = n, exp = (exp and exp > 0) and exp or math.huge, inst = num(a.auraInstanceID) }
                    end
                end
            end
        end
    end
    local removed = info.removedAuraInstanceIDs
    if type(removed) ~= "table" then return end
    for _, id in ipairs(removed) do
        if num(id) then for _, c in pairs(cache) do if c.inst == id then c.removed = true end end end
    end
end
ns:On("UNIT_AURA", function(unit, info)
    if unit == "player" then pcall(C.NoteAuraUpdate, info) C.UpdateBuffRing() end
end)

ns:AddCommand("buffs", function()
    local slots = C.CLASS_SLOTS[PlayerClass() or ""]
    if not slots then ns.Print("buffs: no buff ring for your class") return end
    local dbg = {}
    local auras, unreliable, inst = C.ReadSlotAuras(slots, dbg)
    ns.Print("buffs: scan found " .. tostring(dbg._scanned) .. " buffs, " .. (unreliable and "not trusted for 'missing'" or "trusted") .. ", in combat=" .. tostring(dbg._fighting))
    for _, slot in ipairs(slots) do
        local sp = C.SlotMatch(slot, auras)
        local hit = sp ~= nil
        if sp then
            local l = auras[sp]
            ns.Print(string.format("  %s: %s, %s via %s%s", slot.key, slot.label or sp, l == math.huge and "no expiry" or string.format("%.0fs", l), dbg[sp] or "?", inst[sp] and (" inst " .. inst[sp]) or ""))
        end
        local c = C.cache[slot.key]
        if not hit then ns.Print("  " .. slot.key .. ": not read" .. (c and (" (cached " .. c.spell .. (c.removed and ", removed" or "") .. ")") or "")) end
    end
end)
table.insert(ns.HELP, "/comp buffs - buff ring readings per slot (debug; works in combat)")
ns:On("QUEST_LOG_UPDATE", function() if C.QuestActive() then C.UpdatePlates() end end)
