-- Options for the Gather module. Builds Settings window pages and a Blizzard AddOns subcategory.
local ns = _G.Companion
if not ns then return end

-- Bring forward settings from the short-lived standalone Companion Gather addon.
function ns.MigrateGatherSettings()
    if type(_G.CompanionGatherDB) ~= "table" then return false end
    if type(ns.db) ~= "table" then return false end
    if ns.db.gatherMigrated then return false end
    for _, k in ipairs({ "nodeCallouts", "nodeGlow", "nodeSavedCVars" }) do
        if CompanionGatherDB[k] ~= nil then
            ns.db[k] = CompanionGatherDB[k]
        end
    end
    ns.db.gatherMigrated = true
    return true
end
if ns.SyncDefaults then ns.SyncDefaults() end
ns.MigrateGatherSettings()
SLASH_CGATHER1 = "/cgather"
SLASH_CGATHER2 = "/compgather"
SlashCmdList = SlashCmdList or {}
SlashCmdList.CGATHER = function(msg)
    if ns.RunCommand then ns.RunCommand("nodes", msg or "") end
end

ns.RegisterModule("gather", {
    title = "Gather",
    addon = "Companion_Gather",
    OnSetEnabled = function(on)
        if on then
            if ns.db and ns.db.nodeCallouts and ns.ApplyNodeCVars then ns.ApplyNodeCVars() end
        else
            if ns.HideNodeGlow then ns.HideNodeGlow() end
            if ns.RestoreNodeCVars then ns.RestoreNodeCVars() end
        end
    end,
})

local function Fill()
Header("Ore & herbs", "nodes", "Gather")
ModuleEnableCheckbox("gather")
Check("Call out ore/herb nodes you can gather", "nodeCallouts", function(on) ns.SetNodeCallouts(on) end)
Check("Glow on the node in the world", "nodeGlow", function(on)
    ns.db.nodeGlow = on
    if not on and ns.HideNodeGlow then ns.HideNodeGlow() end
end)
Button("Print node diagnostics", 170, function() ns.RunCommand("nodes") end)
y = y - 30

end

if ns.BindOptEnv then ns.BindOptEnv(Fill) end
Fill()
