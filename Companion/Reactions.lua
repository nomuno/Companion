-- Companion: Reacting to what happens in game (combat, quests, level-ups, AFK).

local _, ns = ...

local lastActivity, isAFK, idleWarned, lowHealthWarned = GetTime(), false, false, false
local IDLE_SECONDS = 100

local function ResetActivity()
    lastActivity = GetTime()
    idleWarned = false
end

ns:On("LOGIN", function()
    C_Timer.After(3, function() ns:SpeakCategory("welcome") end)
    C_Timer.NewTicker(20, function()
        if ns.frame:IsShown() and not idleWarned and not UnitAffectingCombat("player")
            and GetTime() - lastActivity > IDLE_SECONDS then
            idleWarned = true
            ns:SpeakCategory("idle")
        end
    end)
end)

ns:On("PLAYER_STARTED_MOVING", ResetActivity)
ns:On("PLAYER_REGEN_DISABLED", ResetActivity)

ns:On("CHAT_MSG_COMBAT_XP_GAIN", function()
    ResetActivity()
    ns:Say("praise", { chance = 0.30 })
end)

-- Newer clients hide exact health values from addons in combat ("secret" values).
-- Try the percent API first, and skip quietly if the numbers aren't readable.
local function HealthRatio()
    if UnitHealthPercent then
        local ok, pct = pcall(UnitHealthPercent, "player")
        if ok and type(pct) == "number" and not (issecretvalue and issecretvalue(pct)) then
            local ok2, r = pcall(function() return pct > 1 and pct / 100 or pct end)
            if ok2 then return r end
        end
    end
    local cur, max = UnitHealth("player"), UnitHealthMax("player")
    if issecretvalue and (issecretvalue(cur) or issecretvalue(max)) then return nil end
    local ok, ratio = pcall(function()
        if not max or max <= 0 then return nil end
        return cur / max
    end)
    if ok then return ratio end
    return nil
end

ns:On("UNIT_HEALTH", function(unit)
    if unit ~= "player" or not UnitAffectingCombat("player") then return end
    local ratio = HealthRatio()
    if not ratio then return end
    if ratio < 0.25 and not lowHealthWarned then
        lowHealthWarned = true
        ns:SpeakCategory("scolding")
    elseif ratio > 0.50 then
        lowHealthWarned = false
    end
end)

-- With a guide running, the guide's own "next step" line covers quest accepts/turn-ins,
-- so these only speak some of the time to avoid two lines at once.
local function GuideBusy() return ns.GuideSectionActive and ns.GuideSectionActive() end

ns:On("QUEST_ACCEPTED", function()
    ResetActivity()
    ns:Say("questAccept", { chance = GuideBusy() and 0 or nil })
end)

ns:On("QUEST_TURNED_IN", function()
    ResetActivity()
    ns:Say("questTurnIn", { chance = GuideBusy() and 0 or nil })
end)

ns:On("PLAYER_LEVEL_UP", function()
    ResetActivity()
    ns:SpeakCategory("levelUp")
end)

ns:On("PLAYER_DEAD", function()
    ns:SpeakCategory("encouragement")
end)

ns:On("PLAYER_FLAGS_CHANGED", function(unit)
    if unit ~= "player" then return end
    local afk = UnitIsAFK("player")
    if afk and not isAFK then
        isAFK = true
        ns:SpeakCategory("idle")
    elseif not afk and isAFK then
        isAFK = false
        ResetActivity()
        ns:SpeakCategory("welcome")
    end
end)
