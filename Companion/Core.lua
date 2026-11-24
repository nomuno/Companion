-- Companion: Core
-- Namespace, saved settings, a shared event dispatcher, and slash commands.

local addonName, ns = ...
_G.Companion = ns

ns.VERSION = "0.72"
ns.SOUND_DIR = "Interface\\AddOns\\" .. addonName .. "\\sounds\\"

ns.defaults = {
    point = "CENTER",
    x = 0,
    y = 0,
    scale = 1.0,
    modelID = 2043,                 -- Inquisitor Whitemaine
    name = "Companion",
    voiceEnabled = true,
    useCustomSounds = true,
    voiceID = nil,
    voiceRate = 0,
    voiceVolume = 85,
    camDistance = 1.15,
    posX = 0,
    posY = 0,
    posZ = 0,
    modelLocked = false,
    speechText = "chat",            -- 0.50: window | chat | both
}

local function CopyDefaults(src, dst)
    for k, v in pairs(src) do
        if type(v) == "table" then
            dst[k] = dst[k] or {}
            CopyDefaults(v, dst[k])
        elseif dst[k] == nil then
            dst[k] = v
        end
    end
end

ns.CopyDefaults = CopyDefaults
function ns.SyncDefaults()
    if ns.db then CopyDefaults(ns.defaults, ns.db) end
end

function ns.Print(msg)
    print("|cffFF69B4Companion|r " .. tostring(msg))
end

-- 0.68: capture ADDON_ACTION_FORBIDDEN / BLOCKED (the popup does not write taint.log
-- on this client). Print to chat and keep a short list in CompanionDB.taintEvents.
-- Must be registered at file load, before other addons/modules run.
local taintBuf = {}
local TAINT_MAX = 20
local function TaintStack()
    if debugstack then
        local ok, s = pcall(debugstack, 3)
        if ok and type(s) == "string" and s ~= "" then return s end
    end
    if debug and debug.traceback then
        local ok, s = pcall(debug.traceback)
        if ok and type(s) == "string" then return s end
    end
end
function ns.NoteTaint(kind, addon, func, extra)
    local rec = {
        kind = tostring(kind or "?"),
        addon = addon ~= nil and tostring(addon) or "?",
        func = func ~= nil and tostring(func) or "?",
        time = (date and pcall(date, "%Y-%m-%d %H:%M:%S") and date("%Y-%m-%d %H:%M:%S")) or tostring((GetTime and GetTime()) or 0),
        stack = TaintStack(),
    }
    if extra ~= nil then rec.extra = tostring(extra) end
    local line = "taint: " .. rec.kind .. " addon=" .. rec.addon .. " func=" .. rec.func
    print("|cffFF69B4Companion|r " .. line)
    local db = ns.db or rawget(_G, "CompanionDB")
    if type(db) ~= "table" then
        taintBuf[#taintBuf + 1] = rec
        return rec
    end
    db.taintEvents = db.taintEvents or {}
    db.taintEvents[#db.taintEvents + 1] = rec
    while #db.taintEvents > TAINT_MAX do table.remove(db.taintEvents, 1) end
    return rec
end
function ns.FlushTaintLog()
    local db = ns.db or rawget(_G, "CompanionDB")
    if type(db) ~= "table" or #taintBuf == 0 then return end
    db.taintEvents = db.taintEvents or {}
    for i = 1, #taintBuf do
        db.taintEvents[#db.taintEvents + 1] = taintBuf[i]
    end
    taintBuf = {}
    while #db.taintEvents > TAINT_MAX do table.remove(db.taintEvents, 1) end
end
do
    local tf = CreateFrame("Frame")
    tf:RegisterEvent("ADDON_ACTION_FORBIDDEN")
    tf:RegisterEvent("ADDON_ACTION_BLOCKED")
    tf:SetScript("OnEvent", function(_, event, a, b, c)
        ns.NoteTaint(event, a, b, c)
    end)
    if hooksecurefunc then
        hooksecurefunc("StaticPopup_Show", function(which, t1, t2)
            if which == "ADDON_ACTION_FORBIDDEN" or which == "ADDON_ACTION_BLOCKED" then
                ns.NoteTaint(which, t1, t2)
            end
        end)
    end
end

-- ===================== EVENT DISPATCHER =====================
-- Any module can call ns:On("EVENT_NAME", handler) to listen to a game event.
-- ns:On("LOGIN", handler) runs after saved settings are ready.

local handlers = {}
local eventFrame = CreateFrame("Frame")

function ns:On(event, fn)
    if not handlers[event] then
        handlers[event] = {}
        if event ~= "LOGIN" then
            local ok, err = pcall(eventFrame.RegisterEvent, eventFrame, event)
            if not ok and ns.NoteTaint then
                ns.NoteTaint("RegisterEvent", "Companion", tostring(event), err)
            end
        end
    end
    table.insert(handlers[event], fn)
end

local function Fire(event, ...)
    local list = handlers[event]
    if not list then return end
    for _, fn in ipairs(list) do
        local ok, err = pcall(fn, ...)
        if not ok then
            ns.Print("|cffff5555error in " .. event .. ":|r " .. tostring(err))
        end
    end
end

eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:SetScript("OnEvent", function(_, event, ...)
    if event == "ADDON_LOADED" then
        if ... == addonName then
            CompanionDB = CompanionDB or {}
            CopyDefaults(ns.defaults, CompanionDB)
            ns.db = CompanionDB
            if ns.FlushTaintLog then ns.FlushTaintLog() end
        end
    elseif event == "PLAYER_LOGIN" then
        Fire("LOGIN")
        ns.Print(ns.VERSION .. " loaded. Type /comp to show or hide.")
    end
    Fire(event, ...)
end)

-- ===================== SLASH COMMANDS =====================
-- Modules add subcommands with ns:AddCommand("name", fn).

local commands = {}

function ns:AddCommand(name, fn)
    commands[name] = fn
end

-- Run a subcommand by name (the settings panel uses this so buttons and slash
-- commands share one code path).
function ns.RunCommand(name, rest)
    local fn = commands[name]
    if fn then fn(rest or "") return true end
    return false
end

ns.HELP = {
    "/comp - show or hide the companion",
    "/comp config - open Settings > AddOns > Companion (same as /comp options or the Settings button)",
    "/comp options [page] - open Settings > AddOns > Companion (pages: general, audio, speech, models, nodes, ...)",
    "/comp voice nicole|kahani|shelley - companion voice (also /comp pitch)",
    "/comp guide [next|prev|skip|reset|list|off|nextguide|<name>]",
    "/comp dungeons - dungeon quests (have / can get / done) and the Quest Helper settings tab",
    "/comp tracker, /comp quests",
    "/comp nav, /comp way x y, /comp navflip, /comp navdebug",
    "/comp scene, /comp light [ambient], /comp scenedebug",
    "/comp wisp <id>, /comp orbit n, /comp wispsize n, /comp wispz n, /comp wispfront n, /comp wispdebug",
    "/comp text window|chat|both - where her spoken lines appear (chat is visible only to you)",
    "/comp emotes, /comp chatty quiet|normal|chatty, /comp say <category>, /comp sounddebug",
    "/comp remind [food|ammo|buffs]",
    "/comp debug taint [on|2|off] - write Logs/taint.log so blocked actions can be identified",
    "/comp recorder, /comp export",
}

ns:AddCommand("text", function(rest)
    rest = (rest or ""):match("^(%S*)")
    if rest == "window" or rest == "chat" or rest == "both" then
        ns.Print("speech text: " .. ns.SetSpeechText(rest))
        if ns.RefreshConfig then ns.RefreshConfig() end
    else
        ns.Print("speech text: " .. ns.SpeechTextMode() .. " (use /comp text window|chat|both)")
    end
end)

ns:AddCommand("debug", function(rest)
    rest = (rest or ""):lower()
    local a, b = rest:match("^(%S*)%s*(.-)$")
    a, b = a or "", b or ""
    local function getTaint()
        local f = (C_CVar and C_CVar.GetCVar) or GetCVar
        if not f then return nil end
        local ok, v = pcall(f, "taintLog")
        if ok then return v end
    end
    local function setTaint(v)
        if InCombatLockdown and InCombatLockdown() then
            ns.Print("taint log: can't change CVars in combat. Try /console taintLog " .. tostring(v) .. " or wait until combat ends.")
            return false
        end
        local f = (C_CVar and C_CVar.SetCVar) or SetCVar
        if not f then
            ns.Print("taint log: SetCVar missing. Use /console taintLog " .. tostring(v))
            return false
        end
        local ok = pcall(f, "taintLog", tostring(v))
        if not ok then
            ns.Print("taint log: SetCVar was refused. Use /console taintLog " .. tostring(v) .. " in chat instead.")
            return false
        end
        return true
    end
    if a ~= "taint" and a ~= "taintlog" and a ~= "taintLog" then
        ns.Print("debug: /comp debug taint on   (or 2 for verbose, off to disable)")
        ns.Print("  current taintLog=" .. tostring(getTaint() or "unset (off)"))
        local ev = ns.db and ns.db.taintEvents
        if type(ev) == "table" and #ev > 0 then
            ns.Print("  captured " .. #ev .. " forbidden/blocked event(s) in CompanionDB.taintEvents:")
            for i = 1, #ev do
                local r = ev[i]
                ns.Print(string.format("    %s  %s  addon=%s  func=%s", tostring(r.time), tostring(r.kind), tostring(r.addon), tostring(r.func)))
            end
        else
            ns.Print("  no captured ADDON_ACTION_* events yet (CompanionDB.taintEvents is empty)")
        end
        return
    end
    local mode = (b ~= "" and b) or "on"
    if mode == "on" or mode == "1" or mode == "" then mode = "1"
    elseif mode == "verbose" or mode == "2" then mode = "2"
    elseif mode == "off" or mode == "0" then mode = "0"
    else
        ns.Print("debug taint: use on, 2, or off")
        return
    end
    if not setTaint(mode) then return end
    if mode == "0" then
        ns.Print("taint log off (taintLog=0).")
    else
        ns.Print("taint log on (taintLog=" .. mode .. "). Reproduce the popup, then /reload or log out so the file is written.")
        ns.Print("  File: World of Warcraft/_forever_/Logs/taint.log  (it is only created while taintLog is on).")
        ns.Print("  Or type /console taintLog " .. mode .. " if the CVar did not stick.")
    end
end)

SLASH_COMPANION1 = "/comp"
SLASH_COMPANION2 = "/companion"
SlashCmdList["COMPANION"] = function(msg)
    msg = strtrim((msg or ""):lower())
    local cmd, rest = msg:match("^(%S*)%s*(.-)$")
    if cmd == "" then cmd = "toggle" end
    local fn = commands[cmd]
    if fn then
        fn(rest)
    else
        ns.Print("commands:")
        for _, line in ipairs(ns.HELP) do print("  " .. line) end
    end
end
