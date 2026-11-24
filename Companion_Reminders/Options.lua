-- Options for the Reminders module. Builds Settings window pages and a Blizzard AddOns subcategory.
local ns = _G.Companion
if not ns then return end

ns.RegisterModule("reminders", {
    title = "Reminders",
    addon = "Companion_Reminders",
    OnSetEnabled = function(on)
        -- Feature checks honour ns.IsModuleEnabled("reminders"). Prefs are kept.
        return

    end,
})

local function Fill()
Header("Reminders", "reminders")
ModuleEnableCheckbox("reminders")

Check("Food buff", "remindFood", function(on) ns.SetReminder("remindFood", on) end)
Check("Ammo", "remindAmmo", function(on) ns.SetReminder("remindAmmo", on) end)
Check("Class buffs", "remindBuffs", function(on) ns.SetReminder("remindBuffs", on) end)
Slider("Hunter: warn below (ammo)", "ammoWarnHunter", 100, 2000, 50, function(v) ns.SetAmmoThreshold("ammoWarnHunter", v) end, "%d", 600)
Slider("Hunter: urgent below (ammo)", "ammoLowHunter", 25, 1000, 25, function(v) ns.SetAmmoThreshold("ammoLowHunter", v) end, "%d", 200)
Slider("Warrior: warn below (thrown/ammo)", "ammoWarnWarrior", 10, 400, 10, function(v) ns.SetAmmoThreshold("ammoWarnWarrior", v) end, "%d", 50)
Button("Check now", 120, function() ns.RunCommand("remind") end)
y = y - 30

end

if ns.BindOptEnv then ns.BindOptEnv(Fill) end
Fill()
