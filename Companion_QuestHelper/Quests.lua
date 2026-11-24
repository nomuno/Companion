-- Companion module: Quest Helper. Uses the shared Companion table (this file is a separate addon; `ns` is not shared automatically).
-- Companion: Quest tracking (placeholder for the quest tracker and leveling guide).
-- Keeps ns.quests up to date with what's in your quest log, so later modules
-- (tracker window, navigation arrow, leveling guide) can build on it.

local ns = _G.Companion
if not ns then return end
ns.quests = {}

local QL = C_QuestLog or {}

-- Reads one quest log entry. Uses the newer C_QuestLog API when the client
-- has it and falls back to the old global functions otherwise.
local function GetEntry(i)
    if QL.GetInfo then
        local info = QL.GetInfo(i)
        if not info then return nil end
        return info.title, info.level, info.isHeader, info.isComplete, info.questID
    elseif GetQuestLogTitle then
        local title, level, _, isHeader, _, isComplete, _, questID = GetQuestLogTitle(i)
        return title, level, isHeader, isComplete, questID
    end
end

local function GetObjectives(i, questID)
    local objectives = {}
    if QL.GetQuestObjectives and questID then
        for _, o in ipairs(QL.GetQuestObjectives(questID) or {}) do
            table.insert(objectives, { text = o.text, type = o.type, done = o.finished })
        end
    elseif GetNumQuestLeaderBoards then
        for j = 1, GetNumQuestLeaderBoards(i) or 0 do
            local text, objType, finished = GetQuestLogLeaderBoard(j, i)
            table.insert(objectives, { text = text, type = objType, done = finished })
        end
    end
    return objectives
end

local function NumEntries()
    if QL.GetNumQuestLogEntries then return (QL.GetNumQuestLogEntries()) or 0 end
    if GetNumQuestLogEntries then return (GetNumQuestLogEntries()) or 0 end
    return 0
end

local function ScanQuestLog()
    wipe(ns.quests)
    for i = 1, NumEntries() do
        local title, level, isHeader, isComplete, questID = GetEntry(i)
        if title and not isHeader and questID and questID > 0 then
            ns.quests[questID] = {
                id = questID,
                title = title,
                level = level,
                complete = (isComplete == 1 or isComplete == true),
                objectives = GetObjectives(i, questID),
            }
        end
    end
end
ns.ScanQuestLog = ScanQuestLog

ns:On("LOGIN", ScanQuestLog)
ns:On("QUEST_LOG_UPDATE", ScanQuestLog)

-- /comp quests prints what the addon currently sees in your quest log.
ns:AddCommand("quests", function()
    ScanQuestLog()
    local count = 0
    for _, q in pairs(ns.quests) do
        count = count + 1
        ns.Print(string.format("[%d] %s%s", q.level or 0, q.title or "?", q.complete and " |cff00ff00(done)|r" or ""))
        for _, o in ipairs(q.objectives) do
            print("    " .. (o.done and "|cff00ff00" or "|cffaaaaaa") .. (o.text or "") .. "|r")
        end
    end
    if count == 0 then ns.Print("no quests in your log.") end
end)
