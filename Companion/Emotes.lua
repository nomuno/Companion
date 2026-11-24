-- Companion: Idle emotes so she feels alive while facing you.

local _, ns = ...

ns.defaults.idleEmotes = true

local EMOTES = {
    67, -- wave
    68, -- cheer
    70, -- laugh
    66, -- bow
    60, -- talk
    69, -- dance (short)
}

local busyUntil = 0

function ns:PlayEmote(anim, seconds)
    if not ns.model then return end
    busyUntil = GetTime() + (seconds or 2.5)
    pcall(ns.model.SetAnimation, ns.model, anim)
    C_Timer.After(seconds or 2.5, function()
        if GetTime() >= busyUntil - 0.05 then pcall(ns.model.SetAnimation, ns.model, 0) end
    end)
end

local function ScheduleNext()
    C_Timer.After(math.random(18, 35), function()
        if ns.db.idleEmotes and ns.frame:IsShown() and GetTime() > busyUntil
            and not UnitAffectingCombat("player") then
            ns:PlayEmote(EMOTES[math.random(#EMOTES)], 3)
        end
        ScheduleNext()
    end)
end

ns:On("LOGIN", ScheduleNext)

function ns.SetIdleEmotes(on) ns.db.idleEmotes = on and true or false end
ns:AddCommand("emotes", function()
    ns.SetIdleEmotes(not ns.db.idleEmotes)
    ns.Print("idle emotes " .. (ns.db.idleEmotes and "on" or "off"))
end)
