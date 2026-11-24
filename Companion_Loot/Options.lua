-- Options for the Loot module. Builds Settings window pages and a Blizzard AddOns subcategory.
local ns = _G.Companion
if not ns then return end

ns.RegisterModule("loot", {
    title = "Loot",
    addon = "Companion_Loot",
    OnSetEnabled = function(on)
        if on then
            if ns.Loot and ns.Loot.Apply then ns.Loot.Apply() end
        else
            if ns.Loot and ns.Loot.HideTest then ns.Loot.HideTest() end
            if ns.LootAnchor and ns.LootAnchor.Hide then ns.LootAnchor:Hide() end
        end
    end,
})

local function Fill()
Header("Loot rolls", "loot", "Loot")
ModuleEnableCheckbox("loot")

Text("Need/Greed/Pass roll frames attach to a movable bar instead of covering your action bars.", "GameFontHighlightSmall", LEFT + 8)
y = y - 22
Check("Lock position (untick to show the bar and drag it)", "lootLocked", ns.SetLootLocked)
Slider("Roll frame size", "lootScale", 0.5, 2.0, 0.05, ns.SetLootScale, "%.2f", 1.0)
Button("Test rolls", 120, function() ns.Loot.Test(3) end)
Button("Reset position", 120, function() ns.Loot.Reset() for _, c in ipairs(controls) do if c.refresh then pcall(c.refresh) end end end, LEFT + 130)
y = y - 30
Text("Also: /comp loot unlock | lock | test | reset", "GameFontDisableSmall", LEFT + 8)
y = y - 16

end

if ns.BindOptEnv then ns.BindOptEnv(Fill) end
Fill()
