-- Companion module: Marker Wheel. Uses the shared Companion table (this file is a separate addon; `ns` is not shared automatically).
-- Marker.lua: radial raid-marker wheel, secure version (0.70).
-- Our own code; the secure approach (target the mouseover, then a secure wheel of
-- "raidtarget" action buttons on the target) follows EasyMarks Forever by
-- Hammerdance (MIT License) - see CREDITS.txt.
-- SetRaidTarget is protected on Forever: nothing here calls it. Marks are set only by
-- SecureActionButtonTemplate buttons; showing, hiding and moving the wheel happen in
-- restricted snippets so they work in combat. Insecure code only touches plain
-- textures/text and changes protected frames out of combat.
local ns = _G.Companion
if not ns then return end
local M = {}
ns.Marker = M

ns.defaults.markWheel = true
ns.defaults.markWheelTap = true          -- short press cycles the unit's raid mark
ns.defaults.markWheelHoldTime = 0.25     -- seconds held before the wheel opens
ns.defaults.markWheelSkipUsed = true     -- always skip marks on other units (checkbox removed in 0.64)

BINDING_HEADER_COMPANION = "Companion"
_G["BINDING_NAME_CLICK CompanionMarkWheelKey:LeftButton"] = "Marker wheel (tap or hold)"

-- 0.63e: centre portrait 1.5x (56 -> 84); marks pushed out to keep the old 25px gap
-- between the portrait edge and the mark buttons (old: 70 - 17 - 28 = 25).
local ICON, PORTRAIT = 34, 84
-- 0.63h: thin drawn ring (RING px) hugging the portrait; marks 15% closer (84 -> 71).
local RING = 4
local RADIUS = 71
local GAP = RADIUS - ICON / 2 - PORTRAIT / 2 - RING   -- 8px between ring and marks
M.PORTRAIT, M.ICON, M.GAP, M.RING = PORTRAIT, ICON, GAP, RING
M.RADIUS = RADIUS
local function secret(v) return issecretvalue ~= nil and issecretvalue(v) == true end
local function safe(fn, ...) if not fn then return nil end local ok, a = pcall(fn, ...) if ok then return a end end
local function B(fn, ...) local v = safe(fn, ...) if secret(v) then return nil end return v == true end
local function locked() return B(InCombatLockdown) == true end

function M.MarkAngle(i) return math.rad(90 - (i - 1) * 45) end
function M.MarkOffset(i, r) local a = M.MarkAngle(i) return math.cos(a) * r, math.sin(a) * r end

-- Key down: target the mouseover (secure "target" action) and place the wheel at the
-- cursor, hidden (alpha 0) until the hold time elapses. Key up: a short press leaves
-- the raidtarget attributes that PreClick set (cycle); a long press picks the mark
-- under the mouse, same as before. SetRaidTarget is never called: the button itself
-- is the secure raidtarget action.
M.KEY_PRE = [[
    if not self:GetAttribute("enabled") then return false end
    local wheel = control
    if down then
        self:SetAttribute("useOnKeyDown", true)
        self:SetAttribute("wasShort", 0)
        if UnitExists("mouseover") then
            self:SetAttribute("type", "target")
            self:SetAttribute("unit", "mouseover")
        elseif UnitExists("target") then
            self:SetAttribute("type", nil)
        else
            return false
        end
        wheel:ClearAllPoints()
        wheel:SetPoint("CENTER", "$cursor", "BOTTOMLEFT", 0, 0)
        if wheel.SetAlpha then wheel:SetAlpha(0) end
        wheel:Show()
        return
    end
    self:SetAttribute("useOnKeyDown", false)
    if wheel.SetAlpha then wheel:SetAlpha(1) end
    local short = self:GetAttribute("wasShort")
    if short == true or short == 1 or short == "1" then
        wheel:Hide()
        return
    end
    local pick
    if wheel:IsShown() then
        for i = 0, 8 do
            local b = control:GetFrameRef("mark" .. i)
            if b and b:IsVisible() and b:IsUnderMouse() then pick = i break end
        end
    end
    wheel:Hide()
    if pick == nil then self:SetAttribute("type", nil) return false end
    self:SetAttribute("type", "raidtarget")
    self:SetAttribute("unit", "target")
    self:SetAttribute("action", pick == 0 and "clear" or "set")
    self:SetAttribute("marker", pick)
    self:SetAttribute("raidtarget", pick)
]]
M.MARK_POST = [[ control:GetFrameRef("wheel"):Hide() ]]

-- ===== short-press cycle (0.62) =====
M.HOLD_MIN, M.HOLD_MAX, M.HOLD_STEP, M.HOLD_DEFAULT = 0.15, 0.60, 0.05, 0.25

local function clampHold(v)
    v = tonumber(v) or M.HOLD_DEFAULT
    v = math.floor(v / M.HOLD_STEP + 0.5) * M.HOLD_STEP
    if v < M.HOLD_MIN then v = M.HOLD_MIN end
    if v > M.HOLD_MAX then v = M.HOLD_MAX end
    return v
end
function M.HoldTime()
    return clampHold(ns.db and ns.db.markWheelHoldTime)
end
function ns.SetMarkWheelHoldTime(v)
    ns.db.markWheelHoldTime = clampHold(v)
    return ns.db.markWheelHoldTime
end
function ns.SetMarkWheelTap(on)
    ns.db.markWheelTap = on and true or false
end
function ns.SetMarkWheelSkipUsed(on)
    ns.db.markWheelSkipUsed = on and true or false
end

-- Released strictly before the threshold is a short press; at or past it is a hold.
function M.IsShortPress(held, hold)
    held = tonumber(held) or 0
    hold = clampHold(hold or (ns.db and ns.db.markWheelHoldTime))
    return held < hold
end

-- Raid leader/assist only, in a raid. Solo and party can always mark. Silent no if not.
function M.CanMark()
    local inRaid = B(IsInRaid)
    if inRaid == nil then
        local n = safe(GetNumRaidMembers)
        if type(n) == "number" then inRaid = n > 0 end
    end
    if inRaid == true then
        if B(UnitIsGroupLeader, "player") or B(UnitIsGroupAssistant, "player") then return true end
        if B(IsRaidLeader) or B(IsRaidOfficer) then return true end
        return false
    end
    return true
end

-- Mouseover if it exists, otherwise target. Nil if neither.
function M.CycleUnit()
    if B(UnitExists, "mouseover") == true then return "mouseover" end
    if B(UnitExists, "target") == true then return "target" end
    return nil
end

-- Current mark 0 (none) .. 8, or nil if the value is secret / unreadable.
-- GetRaidTargetIndex can lag (or stay 0) until RAID_TARGET_UPDATE, so rapid taps
-- must also use the last mark we applied to this GUID.
function M.MarkForGUID(guid)
    if not guid or secret(guid) then return nil end
    for m, info in pairs(M.assigned or {}) do
        if info and info.guid == guid and type(m) == "number" and m >= 1 and m <= 8 then
            return m
        end
    end
end
function M.CurrentMark(unit)
    if not unit then return nil end
    local ok, idx = pcall(GetRaidTargetIndex, unit)
    if ok and secret(idx) then return nil end
    if ok then
        idx = tonumber(idx)
        if idx and idx >= 1 then
            if idx > 8 then idx = 8 end
            return idx
        end
    end
    local remembered = M.MarkForGUID(M.SafeGUID(unit))
    if remembered then return remembered end
    return 0
end

-- ===== used-mark tracker (0.64) =====
-- WoW has no global list of who has which raid mark. We remember marks we set, and
-- we scan anything we can see (group, their targets, nameplates, mouseover/target/focus).
-- An entry is dropped when that mark is seen on another unit, we see this GUID dead
-- or with a different mark, we ourselves clear it, or the zone changes. A live
-- GetRaidTargetIndex of 0 is not enough to forget (it often lags). If we cannot
-- confirm a mark is free, we keep treating it as used so we do not steal it.
M.assigned = {}

function M.ClearAssignments()
    M.assigned = {}
end

function M.SafeGUID(unit)
    if not unit then return nil end
    local ok, g = pcall(UnitGUID, unit)
    if not ok or secret(g) or type(g) ~= "string" or g == "" then return nil end
    return g
end

function M.ForgetGUID(guid)
    if not guid or secret(guid) then return end
    for m, info in pairs(M.assigned) do
        if info and info.guid == guid then M.assigned[m] = nil end
    end
end

function M.OnUnitDead(guid)
    M.ForgetGUID(guid)
end

function M.NoteAssignment(mark, guid, token)
    mark = tonumber(mark) or 0
    if guid then
        for m, info in pairs(M.assigned) do
            if info and info.guid == guid then M.assigned[m] = nil end
        end
    end
    if mark >= 1 and mark <= 8 then
        -- This mark is now on guid; any previous owner loses it (the game moves the mark).
        M.assigned[mark] = { guid = guid, token = token }
    end
end

function M.RememberSet(unit, mark)
    mark = tonumber(mark) or 0
    local guid = unit and M.SafeGUID(unit) or nil
    if mark <= 0 then
        if guid then M.ForgetGUID(guid) end
        return
    end
    M.NoteAssignment(mark, guid, unit)
end

function M.ObserveUnit(unit)
    if not unit or B(UnitExists, unit) ~= true then return end
    local guid = M.SafeGUID(unit)
    local dead = B(UnitIsDead, unit)
    if dead == nil then dead = B(UnitIsDeadOrGhost, unit) end
    if dead == true then
        if guid then M.ForgetGUID(guid) end
        return
    end
    -- Only trust a live 1-8 from GetRaidTargetIndex. A 0 is often stale (the
    -- game has not sent RAID_TARGET_UPDATE yet) and must not erase a mark we
    -- just applied or still remember on an untargeted unit.
    local ok, idx = pcall(GetRaidTargetIndex, unit)
    if not ok or secret(idx) then return end
    idx = tonumber(idx)
    if idx and idx >= 1 and idx <= 8 then
        M.NoteAssignment(idx, guid, unit)
    end
end

local function eachVisibleUnit(fn)
    local seen = {}
    local function consider(u)
        if not u or seen[u] then return end
        seen[u] = true
        fn(u)
    end
    consider("player"); consider("target"); consider("focus"); consider("mouseover"); consider("pet")
    consider("targettarget"); consider("mouseovertarget"); consider("focustarget"); consider("pettarget")
    for i = 1, 4 do
        consider("party" .. i); consider("partypet" .. i); consider("party" .. i .. "target")
    end
    for i = 1, 40 do
        consider("raid" .. i); consider("raidpet" .. i); consider("raid" .. i .. "target")
        consider("nameplate" .. i)
    end
    if C_NamePlate and C_NamePlate.GetNamePlates then
        local ok, plates = pcall(C_NamePlate.GetNamePlates)
        if ok and type(plates) == "table" then
            for _, plate in ipairs(plates) do
                local u = plate and (plate.namePlateUnitToken or plate.unitToken or plate.unit)
                if type(u) == "string" then consider(u) end
            end
        end
    end
end

function M.ScanSeenMarks()
    eachVisibleUnit(M.ObserveUnit)
end

-- Marks on OTHER units (not exceptUnit). Merges the tracker with a live scan.
function M.UsedMarks(exceptUnit)
    M.ScanSeenMarks()
    local exceptGuid = exceptUnit and M.SafeGUID(exceptUnit) or nil
    local used = {}
    for mark, info in pairs(M.assigned) do
        if type(mark) == "number" and mark >= 1 and mark <= 8 and info then
            -- Identity is by GUID only: tokens like "target" go stale when you change targets.
            local same = exceptGuid and info.guid and exceptGuid == info.guid
            if not same then used[mark] = true end
        end
    end
    -- The unit's live mark stays in its own cycle even if the tracker is behind.
    local own = exceptUnit and M.CurrentMark(exceptUnit)
    if own and own > 0 then used[own] = nil end
    return used
end

-- Cycle skull(8) -> cross(7) -> ... -> star(1) -> none -> wrap.
-- Always skips marks used on other units; the current unit's own mark stays in the cycle.
-- An unmarked unit's next mark is the first free one in that order. If 1-8 are all taken, none (clear).
-- skipUsed is accepted for compatibility but ignored (skipping is always on).
function M.NextMark(current, skipUsed, exceptUnit)
    if type(skipUsed) == "string" and exceptUnit == nil then exceptUnit = skipUsed end
    current = tonumber(current) or 0
    if current < 0 or current > 8 then current = 0 end
    local used = M.UsedMarks(exceptUnit) or {}
    for step = 1, 9 do
        local nxt = current - step
        if nxt < 0 then nxt = nxt + 9 end
        if nxt == 0 or not used[nxt] then return nxt end
    end
    return 0
end

-- Combat log parser kept for tests and any future allowed hook-up. Not registered:
-- COMBAT_LOG_EVENT_UNFILTERED is forbidden on this client (see file-load notes below).
function M.OnCombatLog(...)
    local sub, destGUID
    if CombatLogGetCurrentEventInfo then
        local pack = { pcall(CombatLogGetCurrentEventInfo) }
        if pack[1] then
            -- timestamp, subevent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID
            sub, destGUID = pack[3], pack[9]
            if type(sub) ~= "string" then sub, destGUID = pack[3], pack[8] end
        end
    end
    if type(sub) ~= "string" then
        local a = { ... }
        for i = 1, #a do
            if a[i] == "UNIT_DIED" or a[i] == "UNIT_DESTROYED" or a[i] == "PARTY_KILL" then
                sub = a[i]
                destGUID = a[i + 6] or a[i + 5] or a[i + 1]
                break
            end
        end
    end
    if (sub == "UNIT_DIED" or sub == "UNIT_DESTROYED" or sub == "PARTY_KILL") and type(destGUID) == "string" and destGUID ~= "" and not secret(destGUID) then
        M.OnUnitDead(destGUID)
    end
end

-- Resolve the unit captured at key-down, falling back if mouseover was covered by the wheel.
function M.ResolvePressUnit()
    local u = M.pressUnit
    if u and B(UnitExists, u) == true then return u end
    if B(UnitExists, "target") == true then return "target" end
    return M.CycleUnit()
end

-- PreClick on the secure key (hardware event: SetAttribute is allowed in combat).
-- Down: remember the unit and start the hold timer. Up: tag short/long; for a short
-- press, queue the next raidtarget action on this same button.
function M.OnKeyPreClick(self, button, down)
    if not self then return end
    local enabled = self.GetAttribute and self:GetAttribute("enabled")
    if enabled == false or enabled == 0 or enabled == "0" then return end
    if ns.IsModuleEnabled and not ns.IsModuleEnabled("markwheel") then return end

    local isDown
    if down == true or down == false then
        isDown = down
    else
        isDown = not M.pressing
    end

    if isDown then
        M.pressing = true
        M.pressAt = (GetTime and GetTime()) or 0
        M.pressUnit = M.CycleUnit()
        M.lastPressWasShort = nil
        if self.SetAttribute then
            self:SetAttribute("wasShort", 0)
            -- Drop the previous tap's raidtarget so a key-down click cannot re-apply it.
            if B(UnitExists, "mouseover") == true then
                self:SetAttribute("type", "target")
                self:SetAttribute("unit", "mouseover")
            else
                self:SetAttribute("type", nil)
            end
        end
        local started, hold = M.pressAt, M.HoldTime()
        local function arm()
            -- Timer is NOT a hardware event: never SetAttribute, SetRaidTarget, or Show here.
            if not M.pressing or M.pressAt ~= started then return end
            local w = M.wheel
            if w and w.SetAlpha then w:SetAlpha(1) end
            if M.Refresh then M.Refresh() end
        end
        if C_Timer and C_Timer.After then
            C_Timer.After(hold, arm)
        else
            M._armAt = started + hold
        end
        return
    end

    -- key up
    local held = ((GetTime and GetTime()) or 0) - (M.pressAt or 0)
    local short = M.IsShortPress(held)
    M.pressing = false
    M.lastPressWasShort = short
    M._armAt = nil
    if self.SetAttribute then self:SetAttribute("wasShort", short and 1 or 0) end

    if not short then return end
    if ns.db and ns.db.markWheelTap == false then
        if self.SetAttribute then self:SetAttribute("type", nil) end
        return
    end
    local unit = M.ResolvePressUnit()
    if not unit or not M.CanMark() then
        if self.SetAttribute then self:SetAttribute("type", nil) end
        return
    end
    local cur = M.CurrentMark(unit)
    if cur == nil then
        if self.SetAttribute then self:SetAttribute("type", nil) end
        return
    end
    local nxt = M.NextMark(cur, unit)
    self:SetAttribute("type", "raidtarget")
    self:SetAttribute("unit", unit)
    self:SetAttribute("action", nxt == 0 and "clear" or "set")
    self:SetAttribute("marker", nxt)
    self:SetAttribute("raidtarget", nxt)
    M.lastCycle = { unit = unit, from = cur, to = nxt }
    M.RememberSet(unit, nxt)
end

function M.OnKeyPostClick(self, button, down)
    local isDown = (down == true) or (down ~= false and M.pressing)
    if isDown then
        local w = M.wheel
        -- Keep the wheel invisible until the hold timer arms it (insecure SetAlpha is safe).
        if w and w.IsShown and w:IsShown() and w.SetAlpha then w:SetAlpha(0) end
        return
    end
    -- Key up: if the secure action is a raidtarget set/clear (tap or wheel pick), remember it.
    if self and self.GetAttribute and self:GetAttribute("type") == "raidtarget" then
        local unit = self:GetAttribute("unit") or "target"
        local action = self:GetAttribute("action")
        local mark = tonumber(self:GetAttribute("raidtarget") or self:GetAttribute("marker")) or 0
        if action == "clear" then mark = 0 end
        M.RememberSet(unit, mark)
    end
    M.ScanSeenMarks()
end

-- 0.67: Create secure frames at file scope (templates only). Do not SetParent/SetPoint/Show/Hide,
-- SetAttribute, WrapScript, SetFrameRef, or RegisterForClicks until after PLAYER_LOGIN and out
-- of combat. Doing those during addon load (InCombatLockdown is often false, but the client is
-- still in the restricted loading window) is what triggered ADDON_ACTION_FORBIDDEN at login
-- whenever Companion_MarkerWheel was enabled. Frames are created unparented so Blizzard layout
-- does not touch them before setup. The key keeps its name so Bindings.xml can bind to it.
local wheel, key
local secureReady

local function CreateFrames()
    if wheel then return end
    wheel = CreateFrame("Frame", "CompanionMarkerWheel", nil, "SecureHandlerStateTemplate")
    wheel:SetSize((RADIUS + ICON) * 2, (RADIUS + ICON) * 2)
    wheel:SetFrameStrata("DIALOG")
    local ring = wheel:CreateTexture(nil, "BACKGROUND")
    ring:SetSize(RADIUS * 2 + ICON, RADIUS * 2 + ICON)
    ring:SetPoint("CENTER")
    ring:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
    ring:SetVertexColor(0, 0, 0, 0.85)   -- 0.63f: darker so the mob's own world name doesn't show through
    local name = wheel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    name:SetPoint("BOTTOM", wheel, "CENTER", 0, RADIUS + ICON / 2 + 6)
    wheel.name = name

    key = CreateFrame("Button", "CompanionMarkWheelKey", nil, "SecureActionButtonTemplate")
    key:SetSize(1, 1)

    wheel.buttons = {}
    for i = 0, 8 do
        local b = CreateFrame("Button", "CompanionMarkerWheelMark" .. i, wheel, "SecureActionButtonTemplate")
        local size = i == 0 and PORTRAIT or ICON
        b:SetSize(size, size)
        local tex = b:CreateTexture(nil, "ARTWORK")
        tex:SetAllPoints()
        if i == 0 then
            wheel.portrait = tex
            -- 0.63f: round portrait (no square backdrop) via the built-in portrait mask
            if b.CreateMaskTexture and tex.AddMaskTexture then
                local m = b:CreateMaskTexture()
                if m then m:SetAllPoints(tex)
                m:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
                tex:AddMaskTexture(m) end
            end
            -- thin gold ring: a gold disc RING px larger than the portrait, round-masked,
            -- drawn just behind it so only a thin edge shows
            local rim = b:CreateTexture(nil, "BACKGROUND")
            rim:SetSize(size + RING * 2, size + RING * 2)
            rim:SetPoint("CENTER", b, "CENTER", 0, 0)
            rim:SetTexture("Interface\\Buttons\\WHITE8X8")
            rim:SetVertexColor(0.95, 0.78, 0.25, 1)
            if b.CreateMaskTexture and rim.AddMaskTexture then
                local m2 = b:CreateMaskTexture()
                if m2 then m2:SetAllPoints(rim)
                m2:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
                rim:AddMaskTexture(m2) end
            end
            local clr = b:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            clr:SetPoint("TOP", b, "BOTTOM", 0, -2)
            clr:SetText("clear")
        else
            tex:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_" .. i)
        end
        if i > 0 then   -- marks only; the round portrait gets no square highlight
            local hl = b:CreateTexture(nil, "HIGHLIGHT")
            hl:SetAllPoints()
            hl:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
            hl:SetBlendMode("ADD")
        end
        wheel.buttons[i] = b
    end
    M.key, M.wheel = key, wheel
end

-- Protected setup: parent, place, attributes, wrap scripts. Once, after PLAYER_LOGIN, out of combat.
local function SetupSecure()
    if secureReady then return true end
    if not wheel then CreateFrames() end
    if locked() then M.pendingBuild = true return false end
    wheel:SetParent(UIParent)
    wheel:SetClampedToScreen(true)
    wheel:Hide()
    key:SetParent(UIParent)
    key:SetPoint("TOPLEFT", UIParent, "BOTTOMRIGHT", 10, -10)   -- off-screen, never clickable
    key:RegisterForClicks("AnyDown", "AnyUp")
    key:SetAttribute("checkselfcast", false)
    key:SetAttribute("checkfocuscast", false)
    key:SetAttribute("enabled", true)
    -- SecureActionButtonTemplate has no SetFrameRef (0.63c bug: Build died here, so the
    -- wheel never existed). Refs live on the wheel, the header; snippets use "control".
    wheel:SetFrameRef("wheel", wheel)
    for i = 0, 8 do
        local b = wheel.buttons[i]
        if i == 0 then b:SetPoint("CENTER")
        else local x, y = M.MarkOffset(i, RADIUS) b:SetPoint("CENTER", wheel, "CENTER", x, y) end
        b:RegisterForClicks("AnyUp")
        b:SetAttribute("useOnKeyDown", false)
        b:SetAttribute("type1", "raidtarget")
        b:SetAttribute("*type1", "raidtarget")
        b:SetAttribute("unit", "target")
        b:SetAttribute("action", i == 0 and "clear" or "set")
        b:SetAttribute("marker", i)
        b:SetAttribute("raidtarget", i)
        b:SetAttribute("checkselfcast", false)
        b:SetAttribute("checkfocuscast", false)
        wheel:WrapScript(b, "OnClick", "return nil, true", M.MARK_POST)
        wheel:SetFrameRef("mark" .. i, b)
        if b.HookScript then
            b:HookScript("PostClick", function(self)
                local mark = tonumber(self:GetAttribute("raidtarget") or self:GetAttribute("marker")) or 0
                if self:GetAttribute("action") == "clear" then mark = 0 end
                M.RememberSet("target", mark)
                M.ScanSeenMarks()
            end)
        end
    end
    wheel:WrapScript(key, "OnClick", M.KEY_PRE)
    key:SetScript("PreClick", M.OnKeyPreClick)
    key:SetScript("PostClick", M.OnKeyPostClick)
    -- Plain textures/text only: safe in combat.
    wheel:HookScript("OnShow", function(self)
        if C_Timer and C_Timer.After then C_Timer.After(0, function() M.Refresh() end) else M.Refresh() end
    end)
    secureReady = true
    M.secureReady = true
    M.pendingBuild = nil
    M.ApplySettings()
    return true
end

function M.Build()
    CreateFrames()
    SetupSecure()
    return wheel
end

function M.TryBuild()
    return SetupSecure()
end

-- 0.68: do not CreateFrame(Secure*Template) at file load. Creating the named
-- CLICK binding target during the load window still lets Bindings.xml / the
-- client SetAttribute on it, which is what still popped ADDON_ACTION_FORBIDDEN
-- in 0.67. CreateFrames + SetupSecure run after PLAYER_LOGIN (see below).

function M.Refresh()
    if not wheel then return end
    local unit = "target"
    if B(UnitExists, unit) ~= true then unit = "mouseover" end
    if not (SetPortraitTexture and pcall(SetPortraitTexture, wheel.portrait, unit)) then
        wheel.portrait:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
    end
    pcall(wheel.name.SetText, wheel.name, (safe(UnitName, unit)))
end

-- Protected changes only out of combat; retried on PLAYER_REGEN_ENABLED.
function M.ApplySettings()
    if not wheel then return false end
    if not secureReady then
        if locked() then M.pendingBuild = true return false end
        return SetupSecure()
    end
    if locked() then M.pending = true return false end
    M.pending = nil
    local on = not (ns.db and ns.db.markWheel == false)
    if ns.IsModuleEnabled and not ns.IsModuleEnabled("markwheel") then on = false end
    key:SetAttribute("enabled", on)
    wheel:SetScale(M.Scale())
    if not on then wheel:Hide() end
    return true
end

function ns.SetMarkWheel(on) ns.db.markWheel = on and true or false M.ApplySettings() end
-- 0.63i: scale works like the window scale (0.6-1.8, step 0.05); replaces markWheelSize.
M.SCALE_MIN, M.SCALE_MAX = 0.6, 1.8
local function clampScale(v)
    v = tonumber(v) or 1
    v = math.floor(v / 0.05 + 0.5) * 0.05
    return math.max(M.SCALE_MIN, math.min(M.SCALE_MAX, v))
end
function M.Migrate()
    local db = ns.db
    if not db then return end
    if db.markWheelScale == nil and db.markWheelSize ~= nil then db.markWheelScale = clampScale(db.markWheelSize) end
    db.markWheelSize = nil
    -- 0.64: skipping marks on other units is always on (the checkbox is gone).
    db.markWheelSkipUsed = true
end
function M.Scale() return clampScale(ns.db and ns.db.markWheelScale or 1) end
function ns.SetMarkWheelScale(v)
    ns.db.markWheelScale = clampScale(v)
    M.ApplySettings()   -- queued until combat ends if needed
    return ns.db.markWheelScale
end

M.HOWTO = {
    "1) Set a key with the keybind button above (or Key Bindings > AddOns > Companion > \"Marker wheel (tap or hold)\").",
    "2) Short press (tap) the key on a highlighted unit, or with something targeted, to cycle its raid mark: skull, cross, square, moon, triangle, diamond, circle, star, then none. Marks already used on other units are skipped. A new unit starts at the first free mark; keep tapping the same unit to cycle free marks (and its own) until you like it.",
    "3) Hold the key past the hold time to open the wheel at the cursor, just as before. The unit under the cursor becomes your target; with nothing under the cursor, it uses your current target.",
    "4) Keep holding, move onto a mark and let go to set it, or click a mark while holding. Let go on the portrait (\"clear\") to remove the mark, or anywhere else to cancel the wheel.",
    "5) In a raid, only the leader or an assistant can set marks; a tap does nothing (quietly) if you can't. It works in combat; setting changes wait until combat ends.",
}

-- Keybind (settings page button). Bindings can't change in combat.
M.BINDING = "CLICK CompanionMarkWheelKey:LeftButton"
function M.CurrentKey()
    local k = safe(GetBindingKey, M.BINDING)
    if type(k) == "string" and k ~= "" then return k end
end
function M.SetKey(key)
    if locked() then return false, "combat" end
    if not SetBinding then return false, "no api" end
    for _ = 1, 4 do   -- drop every key currently on the wheel binding
        local old = GetBindingKey and GetBindingKey(M.BINDING)
        if not old then break end
        SetBinding(old)
    end
    if key then SetBinding(key, M.BINDING) end
    if SaveBindings then SaveBindings(GetCurrentBindingSet and GetCurrentBindingSet() or 1) end
    return true
end
-- Build "ALT-CTRL-SHIFT-X" from a key press; nil for a bare modifier.
function M.KeyFromPress(key, alt, ctrl, shift)
    if type(key) ~= "string" or key:match("^[LR]?SHIFT$") or key:match("^[LR]?CTRL$") or key:match("^[LR]?ALT$")
        or key == "UNKNOWN" then return nil end
    return (alt and "ALT-" or "") .. (ctrl and "CTRL-" or "") .. (shift and "SHIFT-" or "") .. key
end

-- Local copy of the taint watcher (core already logs; this one is here so a
-- MarkerWheel-only attribution still reaches CompanionDB if core missed it).
do
    local tf = CreateFrame("Frame")
    tf:RegisterEvent("ADDON_ACTION_FORBIDDEN")
    tf:RegisterEvent("ADDON_ACTION_BLOCKED")
    tf:SetScript("OnEvent", function(_, event, a, b, c)
        if ns.NoteTaint then ns.NoteTaint(event, a, b, c) end
    end)
end

ns:On("LOGIN", function()
    M.Migrate()
    if SetupSecure() then M.ScanSeenMarks() end
end)
ns:On("PLAYER_ENTERING_WORLD", function()
    if SetupSecure() and not locked() then M.ApplySettings() end
    M.ScanSeenMarks()
end)
ns:On("ZONE_CHANGED_NEW_AREA", function()
    M.ClearAssignments()
end)
ns:On("PLAYER_REGEN_ENABLED", function()
    if M.pendingBuild or not secureReady then SetupSecure() end
    if M.pending then M.ApplySettings() end
    M.ScanSeenMarks()
end)
ns:On("RAID_TARGET_UPDATE", function() M.ScanSeenMarks() end)
ns:On("PLAYER_TARGET_CHANGED", function() M.ObserveUnit("target"); M.ObserveUnit("targettarget") end)
ns:On("UPDATE_MOUSEOVER_UNIT", function() M.ObserveUnit("mouseover") end)
ns:On("PLAYER_FOCUS_CHANGED", function() M.ObserveUnit("focus") end)
ns:On("UNIT_TARGET", function(unit) if type(unit) == "string" then M.ObserveUnit(unit .. "target") end end)
ns:On("NAME_PLATE_UNIT_ADDED", function(unit) M.ObserveUnit(unit) end)
ns:On("NAME_PLATE_UNIT_REMOVED", function(unit) if type(unit) == "string" then M.ObserveUnit(unit) end end)
-- UNIT_HEALTH is already registered by core Reactions; this only appends a handler.
-- A dead unit still in the client's unit map (nameplate, group, target, etc.) frees its mark.
ns:On("UNIT_HEALTH", function(unit)
    if type(unit) ~= "string" then return end
    local dead = B(UnitIsDead, unit)
    if dead == nil then dead = B(UnitIsDeadOrGhost, unit) end
    if dead == true then M.ObserveUnit(unit) end
end)
-- Do not RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED"): on this client that call is
-- ADDON_ACTION_FORBIDDEN (0.68 taintEvents: Marker.lua:668 -> Core.lua On -> RegisterEvent,
-- func UNKNOWN()). M.OnCombatLog remains callable for tests / manual use. Off-screen
-- deaths we never observe stay "uncertain, keep avoiding" (same skip-used policy).
