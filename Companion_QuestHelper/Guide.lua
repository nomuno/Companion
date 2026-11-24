-- Companion module: Quest Helper. Uses the shared Companion table (this file is a separate addon; `ns` is not shared automatically).
-- Companion: Leveling guide engine.
-- Guides register with ns:RegisterGuide(name, {faction, minLevel, maxLevel, mapID, steps}).
--
-- Step fields:
--   type   "accept" | "turnin" | "complete" | "kill" | "collect" | "goto"
--          | "hearth" | "fly" | "train" | "vendor" | "note"
--   qid    questID or { questIDs }          (accept/turnin/complete, optional for kill/collect)
--   obj    objective index (complete/kill/collect: only that objective must be done)
--   questName  quest title (or list) for quests whose ID is unknown (e.g. new WoW Forever
--          quests). Resolved through the quest log; learned IDs are kept in
--          CompanionDB.learnedQuests so turn-ins are detected after the quest leaves the log.
--   key    optional stable id for the step (default: type:ids/names[:obj]); skips are saved by key
--   title  quest name or place, used to build the instruction text
--   mapID  uiMapID (defaults to the guide's mapID)
--   x, y   coordinates in 0-100, the way players read them
--   text   instruction override; note: extra hint ("cave, go down")
--   class  only for these classes, e.g. "WARLOCK" or {"WARRIOR","ROGUE"}; notClass excludes
--   race   only for these races (e.g. "Orc", "Troll")
--
-- Auto-completion: accept = quest in log (or already turned in); turnin = quest flagged
-- completed; complete/kill/collect with qid = objectives done; goto = within 10 yards.
-- Everything else (hearth, train, vendor, kill without qid...) is done with Next.
--   item   itemID of the quest item to use for this step (guide button); auto-detected if absent

local ns = _G.Companion
if not ns then return end
ns.defaults.guideShown = true
ns.defaults.guide = {}            -- per character: ["Realm-Name"] = { name, step, skipped = {} }

local GOTO_YARDS = 10
local guides, order, dungeonOrder = {}, {}, {}
ns.guides = guides

local G = { active = nil, step = 0 }
G.renamed = {}
ns.guide = G

local function safe(fn, ...)
    if not fn then return nil end
    local ok, a, b, c = pcall(fn, ...)
    if ok then return a, b, c end
end

local function NameList(n)
    if type(n) == "table" then return n end
    if n then return { n } end
    return {}
end

-- Stable step key: type + quest IDs / quest names (+ objective), else type + title/text.
function G.BaseKey(s)
    local parts = {}
    for _, id in ipairs(type(s.qid) == "table" and s.qid or { s.qid }) do parts[#parts + 1] = tostring(id) end
    for _, n in ipairs(NameList(s.questName)) do parts[#parts + 1] = n:lower() end
    local body = table.concat(parts, ",")
    if body == "" then body = (s.title or s.text or ""):lower() end
    return s.type .. ":" .. body .. (s.obj and (":" .. s.obj) or "")
end

-- ===================== QUEST NAMES -> IDS =====================
local function Learned()
    ns.db.learnedQuests = ns.db.learnedQuests or {}
    return ns.db.learnedQuests
end

-- Remember every title currently in the quest log.
function G.LearnFromLog()
    if not ns.db then return end
    local L = Learned()
    for id, q in pairs(ns.quests) do
        if q.title then L[q.title:lower()] = id end
    end
end

-- questID for a quest title: from the log first, then from what we've learned.
function G.ResolveName(name)
    if not name then return nil end
    local lname = name:lower()
    for id, q in pairs(ns.quests) do
        if q.title and q.title:lower() == lname then return id end
    end
    return ns.db and Learned()[lname]
end

-- ===================== REGISTRATION =====================

function ns:RegisterGuide(name, def)
    def.name = name
    def.steps = def.steps or {}
    local seen = {}
    for i, s in ipairs(def.steps) do
        s.index = i
        s.mapID = s.mapID or def.mapID
        local k = s.key or G.BaseKey(s)
        seen[k] = (seen[k] or 0) + 1
        if seen[k] > 1 then k = k .. "#" .. seen[k] end
        s.key = k
    end
    if not guides[name] then table.insert(def.isDungeon and dungeonOrder or order, name) end
    guides[name] = def
    -- 0.43: renamed guides keep their old names here so a saved guide (and its skips) carries over
    for _, old in ipairs(def.oldNames or {}) do G.renamed[old] = name end
end

-- ===================== CHARACTER STATE =====================

local function CharKey()
    local name = safe(UnitName, "player") or "Unknown"
    local realm = safe(GetRealmName) or "Realm"
    return realm .. "-" .. name
end

local function CharState()
    ns.db.guide = ns.db.guide or {}
    local key = CharKey()
    local st = ns.db.guide[key]
    if not st then
        st = { name = nil, step = 1, skipped = {}, turnedIn = {} }
        ns.db.guide[key] = st
    end
    st.skipped = st.skipped or {}
    st.turnedIn = st.turnedIn or {}
    return st
end
G.CharState = CharState

-- ===================== QUEST STATE =====================

local completedCache
local function IsTurnedIn(qid)
    local st = CharState()
    if st.turnedIn[qid] then return true end
    if C_QuestLog and C_QuestLog.IsQuestFlaggedCompleted then
        local done = safe(C_QuestLog.IsQuestFlaggedCompleted, qid)
        if done ~= nil then return done and true or false end
    end
    if GetQuestsCompleted then
        if not completedCache then
            completedCache = {}
            safe(GetQuestsCompleted, completedCache)
        end
        return completedCache[qid] and true or false
    end
    return false
end
G.IsTurnedIn = IsTurnedIn

local function QuestList(q)
    if type(q) == "table" then return q end
    if q then return { q } end
    return {}
end


-- true if an item with this name is in the bags (for collect steps whose quest objective only ticks later)
local function HasItemNamed(name)
    if not name then return false end
    local CC = C_Container
    local numSlots = (CC and CC.GetContainerNumSlots) or GetContainerNumSlots
    local itemLink = (CC and CC.GetContainerItemLink) or GetContainerItemLink
    if not numSlots or not itemLink then return false end
    for bag = 0, 4 do
        for slot = 1, (numSlots(bag) or 0) do
            local link = itemLink(bag, slot)
            if link and link:find("%[" .. name:gsub("%p", "%%%0") .. "%]") then return true end
        end
    end
    return false
end

local function ObjectivesDone(qid, objIndex)
    if IsTurnedIn(qid) then return true end
    local q = ns.quests[qid]
    if not q then return false end
    if objIndex then
        local o = q.objectives and q.objectives[objIndex]
        return (o and o.done) and true or false
    end
    if q.complete then return true end
    if q.objectives and #q.objectives > 0 then
        for _, o in ipairs(q.objectives) do
            if not o.done then return false end
        end
        return true
    end
    return false
end

-- ===================== STEP FILTERS / TEXT =====================

local function Matches(want, have)
    if not want then return true end
    if not have then return true end
    for _, w in ipairs(QuestList(want)) do
        if w:upper() == have:upper() then return true end
    end
    return false
end

local function Applies(step)
    local _, class = safe(UnitClass, "player")
    local _, race = safe(UnitRace, "player")
    if step.class and not Matches(step.class, class) then return false end
    if step.notClass and class and Matches(step.notClass, class) then return false end
    if step.race and not Matches(step.race, race) then return false end
    if step.notRace and race and Matches(step.notRace, race) then return false end
    if step.onlyIfActive then
        -- shown only while the quest is in the log (e.g. tame a Surf Crawler while you're on the isles anyway)
        local id = type(step.qid) == "table" and step.qid[1] or step.qid
        if not (id and ns.quests and ns.quests[id]) then return false end
    end
    if step.requires then
        -- shown only once these quests are turned in
        for _, id in ipairs(step.requires) do if not (G.IsTurnedIn and G.IsTurnedIn(id)) then return false end end
    end
    if step.unless then
        for _, id in ipairs(step.unless) do if G.IsTurnedIn and G.IsTurnedIn(id) then return false end end
    end
    if step.minLevel and (safe(UnitLevel, "player") or 1) < step.minLevel then return false end
    return true
end

local VERB = {
    accept = "Accept", turnin = "Turn in", complete = "Complete", kill = "Kill",
    collect = "Collect", ["goto"] = "Go to", hearth = "Hearth to", fly = "Fly to",
    train = "Train", vendor = "Vendor / repair", note = "",
}

function G.StepText(step, withCoords)
    if not step then return "" end
    local t = step.text
    if not t then
        local name = step.title or (step.questName and table.concat(NameList(step.questName), ", "))
        -- 0.37: TUGs routes some Forever quests no database names yet ("Quest 92598"); ask the client
        if name and name:match("^Quest %d+$") and type(step.qid) == "number" and C_QuestLog and C_QuestLog.GetTitleForQuestID then
            local t = safe(C_QuestLog.GetTitleForQuestID, step.qid)
            if type(t) == "string" and t ~= "" then name = t end
        end
        if not name and step.qid then
            local q = ns.quests[QuestList(step.qid)[1]]
            name = q and q.title or ("quest " .. tostring(QuestList(step.qid)[1]))
        end
        t = (VERB[step.type] or step.type) .. (name and (" " .. name) or "")
    end
    if step.dungeon then t = "[Dungeon: " .. step.dungeon .. "] " .. t end
    if withCoords and step.x then t = t .. string.format(" (%.1f, %.1f)", step.x, step.y) end
    if step.note then t = t .. " - " .. step.note end
    return t
end


-- ===================== ALSO HERE (0.52) =====================
-- Other incomplete objectives worth doing nearby: quests in the log whose upcoming
-- kill/collect/complete step (applies, not skipped, not done) is on this map within
-- `radius` map-% of the player, or among the next `ahead` steps. The current step's
-- own objective(s) are left out. Returns { {qid=, obj=, text=, have=, need=} ... }.
local OBJ_KIND = { kill = true, collect = true, complete = true }
local function CleanObjective(text)
    if type(text) ~= "string" then return nil end
    local name, have, need = text:match("^(.-):%s*(%d+)%s*/%s*(%d+)$")
    if not name then have, need, name = text:match("^(%d+)%s*/%s*(%d+)%s+(.+)$") end
    if not name then return text end
    name = name:gsub("%s+slain$", ""):gsub("%s+killed$", "")
    return name, tonumber(have), tonumber(need)
end
G.CleanObjective = CleanObjective
function G.NearbyObjectives(px, py, mapID, opts)
    opts = opts or {}
    local radius, ahead, max = opts.radius or 8, opts.ahead or 15, opts.max or 5
    local out, seen = {}, {}
    if not G.active then return out end
    local steps = G.active.steps
    local cur = G.Current()
    local skip = {}
    if cur and OBJ_KIND[cur.type] then
        for _, id in ipairs(QuestList(cur.qid)) do skip[id .. ":" .. tostring(cur.obj or "*")] = true end
    end
    local st = CharState()
    for i = G.step, #steps do
        local s = steps[i]
        if s ~= cur and OBJ_KIND[s.type] and s.qid and Applies(s) and not st.skipped[s.key] then
            local near = (i - G.step) <= ahead
            if not near and px and s.x and s.mapID == mapID then
                near = math.sqrt((s.x - px) ^ 2 + (s.y - py) ^ 2) <= radius
            end
            if near then
                for _, id in ipairs(QuestList(s.qid)) do
                    local q = ns.quests[id]
                    if q and not q.complete and q.objectives and not skip[id .. ":*"] then
                        for oi, o in ipairs(q.objectives) do
                            if (not s.obj or s.obj == oi) and not o.done and not skip[id .. ":" .. oi] and not seen[id .. ":" .. oi] then
                                seen[id .. ":" .. oi] = true
                                local name, have, need = CleanObjective(o.text)
                                if name then
                                    out[#out + 1] = { qid = id, obj = oi, text = name, have = have, need = need }
                                    if #out >= max then return out end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return out
end

-- ===================== DISTANCE =====================

local function DistanceTo(step)
    if not (step.x and step.mapID) then return nil end
    local nav = ns.nav
    if not (nav and nav.PlayerWorldPos and nav.MapToWorld) then return nil end
    local px, py = nav.PlayerWorldPos()
    if not px then return nil end
    local tx, ty = nav.MapToWorld(step.mapID, step.x / 100, step.y / 100)
    if not tx then return nil end
    return math.sqrt((tx - px) ^ 2 + (ty - py) ^ 2)
end

-- ===================== COMPLETION =====================

local MANUAL = { hearth = true, fly = true, train = true, vendor = true, note = true }

function G.IsStepDone(step)
    local st = CharState()
    if st.skipped[step.key] then return true end
    if not Applies(step) then return true end
    local kind = step.type
    local list = {}
    for _, id in ipairs(QuestList(step.qid)) do list[#list + 1] = id end
    for _, n in ipairs(NameList(step.questName)) do
        local id = G.ResolveName(n)
        if not id then
            -- unknown title: not accepted/finished yet as far as we can tell
            if kind == "accept" or kind == "turnin" or kind == "complete" or kind == "kill" or kind == "collect" then
                return false
            end
        else
            list[#list + 1] = id
        end
    end

    if kind == "accept" then
        if #list == 0 then return false end
        for _, id in ipairs(list) do
            if not (ns.quests[id] or IsTurnedIn(id)) then return false end
        end
        return true
    elseif kind == "turnin" then
        if #list == 0 then return false end
        for _, id in ipairs(list) do
            if not IsTurnedIn(id) then return false end
        end
        return true
    elseif kind == "complete" or kind == "kill" or kind == "collect" then
        if #list == 0 then return false end
        if step.haveItem and HasItemNamed(step.haveItem) then return true end
        if step.haveItemOnly then return false end
        for _, id in ipairs(list) do
            if not ObjectivesDone(id, step.obj) then return false end
        end
        return true
    elseif kind == "goto" then
        local d = DistanceTo(step)
        return d ~= nil and d <= GOTO_YARDS
    elseif MANUAL[kind] then
        return false
    end
    return false
end

-- ===================== ENGINE =====================

local function Steps() return G.active and G.active.steps or {} end

function G.Current() return Steps()[G.step] end

-- Next n applicable, not-yet-done steps after the current one.
function G.Upcoming(n)
    local list, steps = {}, Steps()
    local i = G.step + 1
    while #list < n and steps[i] do
        if Applies(steps[i]) and not CharState().skipped[steps[i].key] then table.insert(list, steps[i]) end
        i = i + 1
    end
    return list
end

local STEP_CATEGORY = { turnin = "guideTurnIn", hearth = "guideHearth", train = "guideTrain" }

local function Announce()
    local s = G.Current()
    if s then
        local text = G.StepText(s)
        if ns.Say then
            local said = ns:Say(STEP_CATEGORY[s.type] or "guideStep", { vars = { step = text }, priority = true, fallback = text })
            if said then return end
        end
        if ns.ShowLine and not ns.Say then ns:ShowLine(text) end
    elseif G.active then
        local nextName = G.NextGuideName()
        if nextName and ns.Say and ns:Say("guideNext", { priority = true, vars = { guide = nextName },
            fallback = "Route done! Next up: " .. nextName .. "." }) then
            return
        end
        if ns.Say then
            ns:Say("guideDone", { priority = true })
        elseif ns.ShowLine then
            ns:ShowLine("That's the end of " .. G.active.name .. ". Well done!")
        end
    end
end

-- Moves forward past every finished step. Returns true if the step changed.
function G.Evaluate(silent)
    if not G.active then return false end
    local steps = Steps()
    if G.pinned == G.step then return false end   -- user went back with Prev
    G.pinned = nil
    local start = G.step
    while steps[G.step] and G.IsStepDone(steps[G.step]) do
        G.step = G.step + 1
    end
    if G.step ~= start then
        CharState().step = G.step
        if not silent then Announce() end
        if ns.UpdateGuidePanel then ns.UpdateGuidePanel() end
        return true
    end
    return false
end

function G.SetStep(i, silent)
    if not G.active then return end
    local n = #Steps()
    if i < 1 then i = 1 end
    if i > n + 1 then i = n + 1 end
    G.step = i
    CharState().step = i
    if not silent then Announce() end
    if ns.UpdateGuidePanel then ns.UpdateGuidePanel() end
end

function G.Next()      -- advance by hand (marks manual steps done)
    if not G.active then return end
    G.pinned = nil
    local s = G.Current()
    if s and not G.IsStepDone(s) then CharState().skipped[s.key] = true end
    G.SetStep(G.step + 1)
    G.Evaluate()
end
G.Skip = G.Next

-- 0.51: a class-trainer visit (TRAINER_SHOW then TRAINER_CLOSED) completes train steps.
-- Profession and pet trainers are ignored, as are train steps about professions/pets.
local NON_CLASS_TRAIN = { "skinning", "mining", "herbalism", "herb", "first aid", "cooking",
    "fishing", "alchemy", "blacksmith", "engineering", "enchanting", "leatherworking",
    "tailoring", "profession", "pet" }
function G.IsClassTrainStep(step)
    if not step or step.type ~= "train" then return false end
    local t = ((step.text or "") .. " " .. (step.note or "")):lower()
    for _, w in ipairs(NON_CLASS_TRAIN) do
        if t:find(w, 1, true) and not (w == "pet" and t:find("class trainer", 1, true)) then return false end
    end
    return true
end
local trainerOpen = false
function G.OnTrainerShow()
    trainerOpen = not (IsTradeskillTrainer and IsTradeskillTrainer())
end
function G.OnTrainerClosed()
    if not trainerOpen then return false end
    trainerOpen = false
    if not G.active then return false end
    local steps, st = Steps(), CharState()
    local target
    local cur = steps[G.step]
    if G.IsClassTrainStep(cur) and not G.IsStepDone(cur) then
        target = cur
    else
        local _, class = safe(UnitClass, "player")
        for i = G.step + 1, #steps do
            local s = steps[i]
            if G.IsClassTrainStep(s) and s.class and class and Matches(s.class, class)
                and not G.IsStepDone(s) then target = s break end
        end
    end
    if not target then return false end
    st.skipped[target.key] = true
    if target == cur then
        G.pinned = nil
        G.SetStep(G.step + 1)
        G.Evaluate()
    elseif ns.UpdateGuidePanel then ns.UpdateGuidePanel() end
    return true
end

function G.Prev()
    if not G.active then return end
    local i = G.step - 1
    local st = CharState()
    while i > 1 and not Applies(Steps()[i]) do i = i - 1 end
    if Steps()[i] then st.skipped[Steps()[i].key] = nil end
    G.SetStep(i)
    G.pinned = G.step
end

function G.Reset()
    if not G.active then return end
    local st = CharState()
    st.skipped = {}
    G.pinned = nil
    G.SetStep(1, true)
    G.Evaluate(true)
    Announce()
end

-- Old saves stored skipped steps by index. Convert them to keys using the guide's
-- legacyKeys (the step order of the version that saved them), else drop them.
local function MigrateSkipped(st, def)
    local numeric = false
    for k in pairs(st.skipped) do if type(k) == "number" then numeric = true break end end
    if not numeric then return end
    local out = {}
    for k, v in pairs(st.skipped) do
        if type(k) == "number" then
            local key = def.legacyKeys and def.legacyKeys[k]
            if key and v then out[key] = true end
        else
            out[k] = v
        end
    end
    st.skipped = out
end
G.MigrateSkipped = MigrateSkipped

local QUESTY = { accept = true, turnin = true, complete = true, kill = true, collect = true }

local function HasQuestRef(s) return s.qid ~= nil or s.questName ~= nil end

-- Start from step 1 and land on the first step that isn't done. Manual / goto steps
-- that come before the furthest finished quest step count as passed.
function G.FastForward()
    local steps = Steps()
    local furthest = 0
    for i, s in ipairs(steps) do
        if QUESTY[s.type] and HasQuestRef(s) and Applies(s) and G.IsStepDone(s) then furthest = i end
    end
    local i = 1
    while steps[i] do
        local s = steps[i]
        local passed = (not (QUESTY[s.type] and HasQuestRef(s))) and i < furthest
        -- a quest you never picked up, behind steps you've already done (e.g. a quest added to
        -- the guide in an update), is a missed pickup: don't drag you back for it
        if not passed and i < furthest and QUESTY[s.type] and HasQuestRef(s) then
            local inLog = false
            for _, id in ipairs(QuestList(s.qid)) do if ns.quests[id] then inLog = true end end
            if not inLog and not G.IsStepDone(s) then passed = true end
        end
        if not passed and not G.IsStepDone(s) then break end
        i = i + 1
    end
    G.step = i
    CharState().step = i
    return i
end

function G.Load(name, silent)
    local def = guides[name]
    if not def then return false end
    local st = CharState()
    if st.name ~= name then
        st.name = name
        st.step = 1
        st.skipped = {}
    end
    MigrateSkipped(st, def)
    G.active = def
    G.pinned = nil
    G.LearnFromLog()
    G.FastForward()
    if not silent then Announce() end
    if ns.UpdateGuidePanel then ns.UpdateGuidePanel() end
    return true
end

-- Guide chaining: def.next names the guide to offer when this one is finished.
function G.NextGuideName()
    local def = G.active
    if not (def and def.next) then return nil end
    local n = def.next
    if type(n) == "function" then
        local _, race = safe(UnitRace, "player")
        local ok, r = pcall(n, safe(UnitLevel, "player") or 1, race)
        n = ok and r or nil
    end
    if n and guides[n] and G.FactionOK(guides[n]) then return n end
end
function G.IsComplete() return G.active ~= nil and G.Current() == nil end
function G.StartNext()
    local n = G.NextGuideName()
    if not n then return false end
    ns.db.guideShown = true
    G.Load(n)
    ns.Print("guide loaded: " .. n)
    return true
end
function G.IsTurnedIn(qid) return IsTurnedIn(qid) end
G.Applies = function(step) return Applies(step) end

-- Level-gated steps (minLevel) are passed while you're too low. When you level up into
-- one that is behind you and not done, the guide jumps back to it and she mentions it.
function G.OnLevelUp(newLevel)
    if not G.active then return nil end
    local steps = Steps()
    local back, ahead
    for i, s in ipairs(steps) do
        if s.minLevel and not s.noRecall and s.minLevel <= newLevel and Applies(s) and not G.IsStepDone(s) then
            if i < G.step then back = back or i else ahead = ahead or i end
        end
    end
    local target = back or ahead
    if not target then return nil end
    local s = steps[target]
    if ns.Say and s.classQuest then
        local name = s.title or s.text or "your class quest"
        ns:Say("classQuest10", { priority = true, vars = { quest = name, level = newLevel },
            fallback = "Level " .. newLevel .. "! Time for " .. name .. "." })
    end
    if back then
        G.pinned = nil
        G.SetStep(back, true)
        if ns.UpdateGuidePanel then ns.UpdateGuidePanel() end
    end
    return target, back ~= nil
end
ns:On("PLAYER_LEVEL_UP", function(level)
    local lv = tonumber(level) or (safe(UnitLevel, "player") or 1)
    pcall(G.OnLevelUp, lv)
end)

function G.Unload()
    G.active = nil
    G.step = 0
    CharState().name = nil
    if ns.UpdateGuidePanel then ns.UpdateGuidePanel() end
end

-- Navigation target for the current step (Navigation.lua asks for this).
function ns:GuideTarget()
    if not G.active or not ns.db.guideShown then return nil end
    local s = G.Current()
    if not s then return nil end
    if s.x and s.mapID then
        return { mapID = s.mapID, x = s.x / 100, y = s.y / 100, label = G.StepText(s), guide = true }
    end
    -- No coords: point at the game's own map marker for this quest, if it's in the log.
    local ids = {}
    for _, id in ipairs(QuestList(s.qid)) do ids[id] = true end
    for _, n in ipairs(NameList(s.questName)) do
        local id = G.ResolveName(n)
        if id then ids[id] = true end
    end
    if not next(ids) then return nil end
    local mapID = safe(C_Map.GetBestMapForUnit, "player")
    local onMap = mapID and C_QuestLog and safe(C_QuestLog.GetQuestsOnMap, mapID)
    if type(onMap) ~= "table" then return nil end
    for _, info in ipairs(onMap) do
        if info.questID and ids[info.questID] and info.x and info.y then
            return { mapID = mapID, x = info.x, y = info.y, label = G.StepText(s), guide = true, fromMarker = true }
        end
    end
    return nil
end

-- Pick a guide for this character. Order of preference (all need matching faction
-- and level range): a guide whose startZones contains the current map, then one whose
-- races list has the character's race, then the first guide that fits at all.
local function Contains(list, v)
    if not (list and v) then return false end
    for _, x in ipairs(list) do
        if type(x) == "string" and type(v) == "string" then
            if x:lower() == v:lower() then return true end
        elseif x == v then return true end
    end
    return false
end

-- faction may be one string or a list (Skyborne pick either side)
local function FactionOK(g, faction)
    if not g.faction then return true end
    if type(g.faction) == "table" then return Contains(g.faction, faction) end
    return g.faction == faction
end
function G.FactionOK(g)
    return FactionOK(g, safe(UnitFactionGroup, "player"))
end
-- raceMatch: a case-insensitive name fragment ("skyborne"), so a guide still finds its race when the
-- client's race token isn't known yet (WindshaperSkyborne? Skyborne?)
local function RaceLike(pat, race)
    if not pat or type(race) ~= "string" or race == "" then return false end
    return race:lower():gsub("[^%a]", ""):find(pat:lower(), 1, true) ~= nil
end

local function AutoPick()
    local faction = safe(UnitFactionGroup, "player")
    local level = safe(UnitLevel, "player") or 1
    local raceName, raceFile = safe(UnitRace, "player")
    local mapID = C_Map and safe(C_Map.GetBestMapForUnit, "player")
    local byZone, byRace, any
    for _, name in ipairs(order) do
        local g = guides[name]
        if FactionOK(g, faction)
            and level >= (g.minLevel or 1) and level <= (g.maxLevel or 60) then
            if not byZone and Contains(g.startZones, mapID) then byZone = name end
            if not byRace and (Contains(g.races, raceFile) or Contains(g.races, raceName)
                or RaceLike(g.raceMatch, raceFile) or RaceLike(g.raceMatch, raceName)) then byRace = name end
            if not any and not g.races and not g.raceMatch then any = name end
        end
    end
    if not any then
        for _, name in ipairs(order) do
            local g = guides[name]
            if FactionOK(g, faction) and not g.raceMatch and level >= (g.minLevel or 1) and level <= (g.maxLevel or 60) then
                any = name break
            end
        end
    end
    return byZone or byRace or any
end
G.AutoPick = AutoPick

-- ===================== EVENTS =====================

ns:On("LOGIN", function()
    local st = CharState()
    local name = st.name
    if name and not guides[name] and G.renamed[name] then name = G.renamed[name]; st.name = name end
    -- 0.40: a saved guide of the other faction (shared SavedVariables) is never reloaded
    if not (name and guides[name] and G.FactionOK(guides[name])) then name = AutoPick() end
    if name then G.Load(name, true) end
end)

ns:On("TRAINER_SHOW", function() G.OnTrainerShow() end)
ns:On("TRAINER_CLOSED", function() G.OnTrainerClosed() end)
ns:On("QUEST_LOG_UPDATE", function() G.LearnFromLog() G.Evaluate() end)
ns:On("BAG_UPDATE_DELAYED", function() G.Evaluate() if ns.UpdateGuidePanel then ns.UpdateGuidePanel() end end)
ns:On("QUEST_TURNED_IN", function(questID)
    G.LearnFromLog()
    if questID then CharState().turnedIn[questID] = true end
    completedCache = nil
    G.Evaluate()
end)
ns:On("QUEST_ACCEPTED", function(a, b)
    if ns.ScanQuestLog then pcall(ns.ScanQuestLog) end
    G.LearnFromLog()
    -- (questID) on newer clients, (logIndex, questID) on older ones
    local id = (type(b) == "number" and b > 0) and b or a
    if type(id) == "number" and C_QuestLog and C_QuestLog.GetTitleForQuestID then
        local title = safe(C_QuestLog.GetTitleForQuestID, id)
        if type(title) == "string" and title ~= "" then ns.db.learnedQuests[title:lower()] = id end
    end
    G.Evaluate()
end)

-- goto steps need polling; once a second is plenty.
local ticker = CreateFrame("Frame")
local acc = 0
ticker:SetScript("OnUpdate", function(_, elapsed)
    acc = acc + elapsed
    if acc < 1 then return end
    acc = 0
    if ns.db and G.active then
        local s = G.Current()
        if s and s.type == "goto" then G.Evaluate() end
    end
end)

-- ===================== COMMANDS =====================

function ns.SetGuideShown(on)
    ns.db.guideShown = on and true or false
    if ns.IsModuleEnabled and not ns.IsModuleEnabled("questhelper") then
        if ns.UpdateGuidePanel then ns.UpdateGuidePanel() end
        return
    end
    if ns.db.guideShown and not G.active then
        local name = AutoPick()
        if name then G.Load(name) end
    end
    if ns.UpdateGuidePanel then ns.UpdateGuidePanel() end
end
function G.List() return order end
function G.DungeonList() return dungeonOrder end
function G.Get(name) return guides[name] end

ns:AddCommand("guide", function(rest)
    rest = rest or ""
    local cmd = rest:match("^(%S*)")
    if cmd == "" then
        ns.SetGuideShown(not ns.db.guideShown)
        ns.Print("guide " .. (ns.db.guideShown and "shown" or "hidden"))
    elseif cmd == "dock" then
        local where = rest:match("^%S+%s+(%S+)")
        if where ~= "companion" and where ~= "tracker" then
            ns.Print("usage: /comp guide dock companion|tracker (now: " .. (ns.GuideDock and ns.GuideDock() or "companion") .. ")")
        else
            ns.SetGuideDock(where)
            ns.Print("guide shown on the " .. where .. " window.")
        end
    elseif cmd == "next" or cmd == "skip" then
        G.Next()
    elseif cmd == "prev" then
        G.Prev()
    elseif cmd == "reset" then
        G.Reset()
        ns.Print("guide progress reset.")
    elseif cmd == "list" then
        ns.Print("guides:")
        local hidden = 0
        for _, name in ipairs(order) do
            local g = guides[name]
            if not G.FactionOK(g) then hidden = hidden + 1 else
            print(string.format("  %s (%s %d-%d, %d steps)%s", name, type(g.faction) == "table" and table.concat(g.faction, "/") or g.faction or "any",
                g.minLevel or 1, g.maxLevel or 60, #g.steps,
                (G.active == g) and " |cff20ff20<- active|r" or ""))
            end
        end
        if hidden > 0 then print(string.format("  |cff888888(%d guides for the other faction hidden)|r", hidden)) end
    elseif cmd == "nextguide" then
        if not G.StartNext() then ns.Print("no next guide to start.") end
    elseif cmd == "off" then
        G.Unload()
        ns.Print("guide unloaded.")
    else
        local found
        for _, name in ipairs(order) do
            if name:lower() == rest:lower() then found = name end
        end
        if not found then   -- partial names: your faction's guides first
            for pass = 1, 2 do
                for _, name in ipairs(order) do
                    if not found and name:lower():find(rest:lower(), 1, true) and (pass == 2 or G.FactionOK(guides[name])) then found = name end
                end
            end
        end
        if found then
            ns.db.guideShown = true
            G.Load(found)
            ns.Print("guide loaded: " .. found)
        else
            ns.Print("no guide called '" .. rest .. "'. Try /comp guide list")
        end
    end
end)
