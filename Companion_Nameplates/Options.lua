-- Options for the Nameplates module. Builds Settings window pages and a Blizzard AddOns subcategory.
local ns = _G.Companion
if not ns then return end

ns.RegisterModule("nameplates", {
    title = "Nameplates",
    addon = "Companion_Nameplates",
    OnSetEnabled = function(on)
        local db = ns.db or {}
        if on then
            if ns.SetBuffRing then ns.SetBuffRing(db.buffRing ~= false) end
            if ns.SetThreatPlates then ns.SetThreatPlates(db.threatPlates ~= false) end
            if ns.SetQuestPlates then ns.SetQuestPlates(db.questPlates ~= false) end
        else
            local br, tp, qp = db.buffRing, db.threatPlates, db.questPlates
            if ns.SetBuffRing then ns.SetBuffRing(false) end
            if ns.SetThreatPlates then ns.SetThreatPlates(false) end
            if ns.SetQuestPlates then ns.SetQuestPlates(false) end
            db.buffRing, db.threatPlates, db.questPlates = br, tp, qp
        end
    end,
})

local function Fill()
Header("Buff reminders", "combat", "Nameplates")
ModuleEnableCheckbox("nameplates")

Check("Buff reminders: my class self-buffs around the portrait (red when nearly gone or missing)", "buffRing", ns.SetBuffRing)
Slider("Warn when less than (seconds) left", "buffRingWarn", 5, 300, 5, ns.SetBuffRingWarn, "%d", 60)
Header("Enemy nameplates", "combat")
Check("Companion enemy nameplates: health %, level, threat glow (red aggro, yellow close)", "threatPlates", ns.SetThreatPlates)
Check("Quest-mob icon with the number left on enemy nameplates", "questPlates", ns.SetQuestPlates)
Text("Both are off while Threat Plates is loaded. They need enemy nameplates on (V).", "GameFontDisableSmall", LEFT + 8)
y = y - 16

end

if ns.BindOptEnv then ns.BindOptEnv(Fill) end
Fill()
