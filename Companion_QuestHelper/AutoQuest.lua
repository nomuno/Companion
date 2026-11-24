-- Companion module: Quest Helper. Uses the shared Companion table (this file is a separate addon; `ns` is not shared automatically).
-- AutoQuest: auto-accept and auto-turn-in quests. Hold Shift to skip.
-- Stops on reward choices, quests that cost money, and gray (trivial) quests.
local ns = _G.Companion
if not ns then return end
ns.defaults.autoAccept = true
ns.defaults.autoTurnIn = true

local function Off() return IsShiftKeyDown() or not ns.db end
local function A() return ns.db and ns.db.autoAccept end
local function T() return ns.db and ns.db.autoTurnIn end

ns:On("QUEST_DETAIL", function()
    if Off() or not A() then return end
    if QuestGetAutoAccept and QuestGetAutoAccept() then return end
    AcceptQuest()
end)

ns:On("QUEST_PROGRESS", function()
    if Off() or not T() then return end
    if IsQuestCompletable() then CompleteQuest() end
end)

ns:On("QUEST_COMPLETE", function()
    if Off() or not T() then return end
    if (GetQuestMoneyToGet and GetQuestMoneyToGet() or 0) > 0 then return end
    local n = GetNumQuestChoices() or 0
    if n <= 1 then GetQuestReward(n == 1 and 1 or nil) end
end)

ns:On("QUEST_GREETING", function()
    if Off() then return end
    if T() then
        for i = 1, (GetNumActiveQuests() or 0) do
            local _, done = GetActiveTitle(i)
            if done then SelectActiveQuest(i) return end
        end
    end
    if A() then
        for i = 1, (GetNumAvailableQuests() or 0) do
            local trivial = IsAvailableQuestTrivial and IsAvailableQuestTrivial(i)
            if not trivial then SelectAvailableQuest(i) return end
        end
    end
end)

ns:On("GOSSIP_SHOW", function()
    if Off() then return end
    local G = C_GossipInfo
    if T() then
        if G and G.GetActiveQuests then
            for _, q in ipairs(G.GetActiveQuests() or {}) do
                if q.isComplete then G.SelectActiveQuest(q.questID) return end
            end
        elseif GetGossipActiveQuests then
            local t = { GetGossipActiveQuests() }
            local per = (#t > 0 and type(t[2]) == "number") and 6 or 4
            for i = 1, #t / per do
                if t[(i - 1) * per + 4] then SelectGossipActiveQuest(i) return end
            end
        end
    end
    if A() then
        if G and G.GetAvailableQuests then
            for _, q in ipairs(G.GetAvailableQuests() or {}) do
                if not q.isTrivial then G.SelectAvailableQuest(q.questID) return end
            end
        elseif GetGossipAvailableQuests and GetNumGossipAvailableQuests and GetNumGossipAvailableQuests() > 0 then
            SelectGossipAvailableQuest(1)
        end
    end
end)
