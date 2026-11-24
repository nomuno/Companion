-- Companion: module registry, enable/disable, and discovery of installed Companion_* addons.
-- Feature modules are separate addons with ## Dependencies: Companion. They share CompanionDB
-- and the public Companion table (`_G.Companion`). WoW cannot unload an addon mid-session, so
-- disabling a module turns its features off immediately and uses C_AddOns.DisableAddOn for
-- the next reload.

local addonName, ns = ...

ns.modules = ns.modules or {}
ns.defaults.moduleEnabled = ns.defaults.moduleEnabled or {}
ns.reloadNeeded = false

-- Known modules (shown on the General page even when they are not loaded).
ns.KNOWN_MODULES = {
    { id = "gather",      addon = "Companion_Gather",      title = "Gather" },
    { id = "questhelper", addon = "Companion_QuestHelper", title = "Quest Helper" },
    { id = "nameplates",  addon = "Companion_Nameplates",  title = "Nameplates" },
    { id = "markwheel",   addon = "Companion_MarkerWheel", title = "Marker Wheel" },
    { id = "loot",        addon = "Companion_Loot",        title = "Loot" },
    { id = "reminders",   addon = "Companion_Reminders",   title = "Reminders" },
}

local function PCall(fn, ...)
    if type(fn) ~= "function" then return nil end
    local ok, a, b, c, d, e, f = pcall(fn, ...)
    if ok then return a, b, c, d, e, f end
end

function ns.IsModuleEnabled(id)
    if not id then return true end
    local t = ns.db and ns.db.moduleEnabled
    if not t or t[id] == nil then return true end
    return t[id] and true or false
end

local function Info(name)
    -- returns name, title, notes, loadable, reason (best-effort across Classic / C_AddOns)
    if C_AddOns and C_AddOns.GetAddOnInfo then
        local a, b, c, d, e, f, g = PCall(C_AddOns.GetAddOnInfo, name)
        if a then return a, b, c, d, e, f, g end
    end
    if GetAddOnInfo then
        local a, b, c, d, e, f, g = PCall(GetAddOnInfo, name)
        if a then return a, b, c, d, e, f, g end
    end
    return nil
end

function ns.IsAddOnLoaded(name)
    if C_AddOns and C_AddOns.IsAddOnLoaded then
        local v = PCall(C_AddOns.IsAddOnLoaded, name)
        if v ~= nil then return v and true or false end
    end
    if IsAddOnLoaded then
        local v = PCall(IsAddOnLoaded, name)
        if v ~= nil then return v and true or false end
    end
    return false
end

function ns.IsModuleLoaded(id)
    local m = ns.modules[id]
    if m and m.registered then
        -- If this session ran RegisterModule, the addon is loaded.
        return true
    end
    if m and m.addon then return ns.IsAddOnLoaded(m.addon) end
    for _, k in ipairs(ns.KNOWN_MODULES) do
        if k.id == id then return ns.IsAddOnLoaded(k.addon) end
    end
    return false
end

function ns.AddonInstalled(name)
    local addon = Info(name)
    if type(addon) == "string" and addon ~= "" then return true end
    -- harness / offline: treat a registered module as installed
    for _, k in ipairs(ns.KNOWN_MODULES) do
        if k.addon == name and ns.modules[k.id] then return true end
    end
    return false
end

function ns.EnableAddonForCharacter(name, on)
    local char = (UnitName and UnitName("player")) or nil
    local enable, disable
    if C_AddOns then
        enable, disable = C_AddOns.EnableAddOn, C_AddOns.DisableAddOn
    end
    enable = enable or EnableAddOn
    disable = disable or DisableAddOn
    if on then
        if enable then PCall(enable, name, char); PCall(enable, name) end
    else
        if disable then PCall(disable, name, char); PCall(disable, name) end
    end
end

function ns.RegisterModule(id, info)
    info = info or {}
    info.id = id
    info.title = info.title or id
    info.addon = info.addon or ("Companion_" .. id)
    info.registered = true
    ns.modules[id] = info
    ns.defaults.moduleEnabled = ns.defaults.moduleEnabled or {}
    if ns.defaults.moduleEnabled[id] == nil then
        ns.defaults.moduleEnabled[id] = true
    end
    if ns.SyncDefaults then ns.SyncDefaults() end
    -- If the player already turned it off last session, apply that now (files just loaded).
    if ns.db and ns.db.moduleEnabled and ns.db.moduleEnabled[id] == false then
        if type(info.OnSetEnabled) == "function" then
            pcall(info.OnSetEnabled, false)
        end
    end
    if ns.RefreshModuleList then pcall(ns.RefreshModuleList) end
    return info
end

function ns.SetModuleEnabled(id, on)
    on = not not on
    if not ns.db then
        CompanionDB = CompanionDB or {}
        ns.db = CompanionDB
    end
    ns.db.moduleEnabled = ns.db.moduleEnabled or {}
    ns.db.moduleEnabled[id] = on
    local m = ns.modules[id]
    local addon = (m and m.addon) or nil
    if not addon then
        for _, k in ipairs(ns.KNOWN_MODULES) do
            if k.id == id then addon = k.addon break end
        end
    end
    if addon then ns.EnableAddonForCharacter(addon, on) end
    if m and type(m.OnSetEnabled) == "function" then
        pcall(m.OnSetEnabled, on)
    end
    ns.reloadNeeded = true
    if ns.RefreshModuleList then pcall(ns.RefreshModuleList) end
    if ns.RefreshConfig then pcall(ns.RefreshConfig) end
    return on
end

-- Snapshot of every known module: installed / loaded / enabled.
function ns.ModuleStatus(id)
    local meta
    for _, k in ipairs(ns.KNOWN_MODULES) do
        if k.id == id then meta = k break end
    end
    local m = ns.modules[id]
    local addon = (m and m.addon) or (meta and meta.addon)
    local title = (m and m.title) or (meta and meta.title) or id
    local installed = addon and ns.AddonInstalled(addon) or (m and m.registered) or false
    local loaded = ns.IsModuleLoaded(id)
    local enabled = ns.IsModuleEnabled(id)
    return {
        id = id, title = title, addon = addon,
        installed = installed and true or false,
        loaded = loaded and true or false,
        enabled = enabled and true or false,
    }
end

function ns.AllModuleStatuses()
    local out, seen = {}, {}
    for _, k in ipairs(ns.KNOWN_MODULES) do
        seen[k.id] = true
        out[#out + 1] = ns.ModuleStatus(k.id)
    end
    for id, m in pairs(ns.modules) do
        if not seen[id] then
            out[#out + 1] = ns.ModuleStatus(id)
        end
    end
    return out
end
