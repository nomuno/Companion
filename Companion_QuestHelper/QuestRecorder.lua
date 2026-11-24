-- Companion module: Quest Helper. Uses the shared Companion table (this file is a separate addon; `ns` is not shared automatically).
-- Companion: Quest recorder. WoW Forever has quests that aren't in any database, so this
-- writes what it sees into CompanionDB.questRecords[questID] (SavedVariables), to be turned
-- into guide steps later:
--   { id, title, level, objectives = {text...},
--     accept = { npc, npcID, mapID, zone, subzone, x, y, time },
--     turnin = { npc, npcID, mapID, zone, subzone, x, y, time } }
-- x/y are 0-100 map coords. /comp recorder prints a summary.

local ns = _G.Companion
if not ns then return end
local function safe(fn, ...)
    if not fn then return nil end
    local ok, a, b, c, d, e, f, g, h = pcall(fn, ...)
    if ok then return a, b, c, d, e, f, g, h end
end
local function secret(v) return issecretvalue and issecretvalue(v) end

local function Records()
    ns.db.questRecords = ns.db.questRecords or {}
    return ns.db.questRecords
end

-- NPC ID from a creature GUID: "Creature-0-serverID-instanceID-zoneUID-npcID-spawnUID"
function ns.NpcIDFromGUID(guid)
    if type(guid) ~= "string" or secret(guid) then return nil end
    local kind, id = guid:match("^(%a+)%-%d+%-%d+%-%d+%-%d+%-(%d+)")
    if kind == "Creature" or kind == "Vehicle" or kind == "GameObject" then return tonumber(id) end
end

local function Where()
    local mapID = safe(C_Map.GetBestMapForUnit, "player")
    local x, y
    local pos = mapID and safe(C_Map.GetPlayerMapPosition, mapID, "player")
    if pos then
        local px, py = safe(pos.GetXY, pos)
        if px and not secret(px) and not secret(py) then
            x, y = math.floor(px * 1000 + 0.5) / 10, math.floor(py * 1000 + 0.5) / 10
        end
    end
    return {
        mapID = mapID, x = x, y = y,
        zone = safe(GetZoneText), subzone = safe(GetSubZoneText),
        time = safe(time),
    }
end

local function NpcInfo()
    local where = Where()
    local name = safe(UnitName, "npc")
    if name and not secret(name) then where.npc = name end
    where.npcID = ns.NpcIDFromGUID(safe(UnitGUID, "npc"))
    return where
end

local pendingAccept, pendingTurnin       -- NPC/location captured when the quest window opened
local function clean(v) if type(v) == "string" and not secret(v) and v ~= "" then return v end end
ns:On("QUEST_DETAIL", function()
    pendingAccept = NpcInfo()
    -- quest window text: title, story text, objective summary, suggested group size
    pendingAccept.title = clean(safe(GetTitleText))
    pendingAccept.text = clean(safe(GetQuestText))
    pendingAccept.objectiveText = clean(safe(GetObjectiveText))
    pendingAccept.questID = safe(GetQuestID)
    local group = safe(GetSuggestedGroupNum)
    if type(group) == "number" and group > 0 then pendingAccept.suggestedGroup = group end
end)
ns:On("QUEST_COMPLETE", function() pendingTurnin = NpcInfo() end)
ns:On("QUEST_PROGRESS", function() pendingTurnin = pendingTurnin or NpcInfo() end)

local function FillFromLog(rec)
    local q = ns.quests and ns.quests[rec.id]
    if not q then return end
    rec.title = q.title or rec.title
    rec.level = q.level or rec.level
    if q.objectives and #q.objectives > 0 then
        rec.objectives = {}
        for _, o in ipairs(q.objectives) do table.insert(rec.objectives, o.text) end
    end
end

-- QUEST_ACCEPTED is (questID) on newer clients and (logIndex, questID) on older ones.
local function QuestIDFromArgs(a, b)
    if type(b) == "number" and b > 0 then return b end
    return type(a) == "number" and a or nil
end

-- djb2-style hash of the quest text so changed text is detectable without storing it twice
function ns.TextHash(str)
    if type(str) ~= "string" or str == "" then return nil end
    local h = 5381
    for i = 1, #str do h = (h * 33 + str:byte(i)) % 4294967296 end
    return string.format("%08x", h)
end

local function NextSeq()
    ns.db.recorderSeq = (ns.db.recorderSeq or 0) + 1
    return ns.db.recorderSeq
end

function ns.RecordAccept(questID)
    if not questID then return end
    local rec = Records()[questID] or { id = questID }
    Records()[questID] = rec
    local detail = pendingAccept
    if detail and detail.questID and detail.questID ~= questID then detail = nil end
    rec.accept = detail or NpcInfo()
    pendingAccept = nil
    if detail then
        rec.text = detail.text or rec.text
        rec.objectiveText = detail.objectiveText or rec.objectiveText
        rec.suggestedGroup = detail.suggestedGroup or rec.suggestedGroup
        rec.title = rec.title or detail.title
        detail.text, detail.objectiveText, detail.title, detail.questID, detail.suggestedGroup = nil, nil, nil, nil, nil
    end
    local className, classFile = safe(UnitClass, "player")
    local raceName, raceFile = safe(UnitRace, "player")
    rec.player = { class = classFile or className, race = raceFile or raceName, level = safe(UnitLevel, "player") }
    -- ordering hints: what was turned in last overall, and last at this same NPC
    rec.seq = NextSeq()
    rec.acceptTime = (rec.accept and rec.accept.time) or safe(time)
    local last = ns.db.recorderLastTurnin
    rec.prevQuest = last and last.id or nil
    local npcID = rec.accept and rec.accept.npcID
    local byNpc = ns.db.recorderNpcLast
    rec.sameNpcPrev = (npcID and byNpc and byNpc[npcID]) or nil
    rec.textHash = ns.TextHash((rec.text or "") .. "|" .. (rec.objectiveText or "")) or rec.textHash
    ns.UpdateRecorderMeta()
    if ns.ScanQuestLog then pcall(ns.ScanQuestLog) end
    FillFromLog(rec)
    if not rec.title and C_QuestLog and C_QuestLog.GetTitleForQuestID then
        rec.title = safe(C_QuestLog.GetTitleForQuestID, questID)
    end
    -- objectives can arrive a moment later
    if C_Timer and C_Timer.After then C_Timer.After(1, function() pcall(FillFromLog, rec) end) end
    return rec
end

function ns.RecordTurnIn(questID)
    if not questID then return end
    local rec = Records()[questID] or { id = questID }
    Records()[questID] = rec
    rec.turnin = pendingTurnin or NpcInfo()
    pendingTurnin = nil
    rec.turninSeq = NextSeq()
    ns.db.recorderLastTurnin = { id = questID, npcID = rec.turnin and rec.turnin.npcID, time = rec.turnin and rec.turnin.time }
    if rec.turnin and rec.turnin.npcID then
        ns.db.recorderNpcLast = ns.db.recorderNpcLast or {}
        ns.db.recorderNpcLast[rec.turnin.npcID] = questID
    end
    if not rec.title and ns.db.learnedQuests then
        for name, id in pairs(ns.db.learnedQuests) do if id == questID then rec.title = name end end
    end
    return rec
end

ns:On("QUEST_ACCEPTED", function(a, b) pcall(ns.RecordAccept, QuestIDFromArgs(a, b)) end)
ns:On("QUEST_TURNED_IN", function(questID) pcall(ns.RecordTurnIn, questID) end)

-- ===================== OBJECTIVE SAMPLING =====================
-- When an objective's text changes (e.g. "Boar killed: 3/10" -> "4/10"), store where the
-- player was, per quest and objective (capped). Gives hotspots for kill/collect steps.
local MAX_POINTS = 30
-- Only sample real progress: "2/8" -> "3/8" counts, a reset or a vanishing count doesn't.
function ns.ObjectiveProgressed(old, new)
    local a = tonumber(tostring(old):match("(%d+)%s*/%s*%d+"))
    local b = tonumber(tostring(new):match("(%d+)%s*/%s*%d+"))
    if a and b then return b > a end
    return b ~= nil or a == nil
end

-- Continent/world maps (seen during loading screens) give useless coordinates.
function ns.IsZoneMap(mapID)
    if not mapID then return false end
    local info = C_Map and C_Map.GetMapInfo and safe(C_Map.GetMapInfo, mapID)
    if type(info) ~= "table" or info.mapType == nil then return true end
    return info.mapType >= 3
end

local lastText = {}          -- [questID] = { [objIndex] = text }
ns.recorderLastText = lastText

function ns.SampleObjectives()
    if not (ns.db and ns.quests) then return end
    local where
    for id, q in pairs(ns.quests) do
        local prev = lastText[id]
        local cur = {}
        for i, o in ipairs(q.objectives or {}) do
            local t = o.text
            if type(t) == "string" and not secret(t) then
                cur[i] = t
                if prev and prev[i] and prev[i] ~= t and ns.ObjectiveProgressed(prev[i], t) then
                    where = where or Where()
                    if where.x and ns.IsZoneMap(where.mapID) then
                        local rec = Records()[id] or { id = id, title = q.title, level = q.level }
                        Records()[id] = rec
                        rec.points = rec.points or {}
                        local list = rec.points[i] or {}
                        rec.points[i] = list
                        if #list < MAX_POINTS then
                            table.insert(list, { mapID = where.mapID, x = where.x, y = where.y })
                        end
                        rec.objectives = rec.objectives or {}
                        rec.objectives[i] = t
                    end
                end
            end
        end
        lastText[id] = cur
    end
    for id in pairs(lastText) do if not ns.quests[id] then lastText[id] = nil end end
end
ns:On("QUEST_LOG_UPDATE", function() pcall(ns.SampleObjectives) end)

function ns.UpdateRecorderMeta()
    if not ns.db then return end
    local _, classFile = safe(UnitClass, "player")
    local _, raceFile = safe(UnitRace, "player")
    ns.db.recorderMeta = {
        addonVersion = ns.VERSION, realm = safe(GetRealmName), char = safe(UnitName, "player"),
        class = classFile, race = raceFile, level = safe(UnitLevel, "player"),
        updated = safe(time),
    }
end
ns:On("LOGIN", function() pcall(ns.UpdateRecorderMeta) end)

-- ===================== EXPORT =====================
-- Plain text, one record per line, fields separated by "^" (WoW edit boxes treat "|"
-- as an escape character). Format "CQX1":
--   H^version^realm^char^class^race
--   Q^id^title^level^class^race^plevel^group^ACC^TIN    ACC/TIN = npcID,npc,mapID,x,y
--   T^id^objective summary text
--   O^id^index^objective text^mapID:x,y mapID:x,y ...
local function f(v)
    if v == nil then return "" end
    return (tostring(v):gsub("[%^\r\n|]", " "))
end
local function where(w)
    if not w then return "" end
    return table.concat({ f(w.npcID), f(w.npc):gsub(",", " "), f(w.mapID), f(w.x), f(w.y) }, ",")
end

function ns.BuildExport()
    local meta = ns.db.recorderMeta or {}
    local lines = { table.concat({ "H", f(meta.addonVersion or ns.VERSION), f(meta.realm), f(meta.char), f(meta.class), f(meta.race) }, "^") }
    local ids = {}
    for id in pairs(Records()) do table.insert(ids, id) end
    table.sort(ids)
    for _, id in ipairs(ids) do
        local r = Records()[id]
        local p = r.player or {}
        table.insert(lines, table.concat({ "Q", id, f(r.title), f(r.level), f(p.class), f(p.race), f(p.level),
            f(r.suggestedGroup), where(r.accept), where(r.turnin) }, "^"))
        if r.objectiveText then table.insert(lines, "T^" .. id .. "^" .. f(r.objectiveText)) end
        if r.seq or r.turninSeq or r.prevQuest or r.textHash then
            -- S line (added in 0.35; older readers skip unknown line types)
            table.insert(lines, table.concat({ "S", id, f(r.seq), f(r.turninSeq), f(r.prevQuest), f(r.sameNpcPrev),
                f(r.acceptTime), f(r.textHash) }, "^"))
        end
        local n = 0
        for i in pairs(r.objectives or {}) do if i > n then n = i end end
        for i in pairs(r.points or {}) do if i > n then n = i end end
        for i = 1, n do
            local pts = {}
            for _, pt in ipairs((r.points or {})[i] or {}) do
                table.insert(pts, string.format("%s:%s,%s", f(pt.mapID), f(pt.x), f(pt.y)))
            end
            table.insert(lines, table.concat({ "O", id, i, f((r.objectives or {})[i]), table.concat(pts, " ") }, "^"))
        end
    end
    return "CQX1\n" .. table.concat(lines, "\n") .. "\n"
end

local popup
local function ShowExport()
    local text = ns.BuildExport()
    if not popup then
        popup = CreateFrame("Frame", "CompanionExportFrame", UIParent, "BackdropTemplate")
        popup:SetSize(520, 400)
        popup:SetPoint("CENTER")
        popup:SetFrameStrata("DIALOG")
        popup:SetMovable(true)
        popup:EnableMouse(true)
        popup:RegisterForDrag("LeftButton")
        popup:SetScript("OnDragStart", popup.StartMoving)
        popup:SetScript("OnDragStop", popup.StopMovingOrSizing)
        popup:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true, tileSize = 32, edgeSize = 32,
            insets = { left = 8, right = 8, top = 8, bottom = 8 },
        })
        local title = popup:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        title:SetPoint("TOP", 0, -14)
        title:SetText("Companion quest data")
        local help = popup:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        help:SetPoint("TOPLEFT", 18, -38)
        help:SetPoint("RIGHT", popup, "RIGHT", -18, 0)
        help:SetJustifyH("LEFT")
        help:SetText("Press Ctrl+C to copy (it's already selected), then paste it in a message or file.\n"
            .. "Or log out and send WTF/Account/<ACCOUNT>/SavedVariables/Companion.lua")
        local close = CreateFrame("Button", nil, popup, "UIPanelCloseButton")
        close:SetPoint("TOPRIGHT", -4, -4)
        local scroll = CreateFrame("ScrollFrame", "CompanionExportScroll", popup, "UIPanelScrollFrameTemplate")
        scroll:SetPoint("TOPLEFT", 18, -72)
        scroll:SetPoint("BOTTOMRIGHT", -36, 18)
        local edit = CreateFrame("EditBox", "CompanionExportEdit", scroll)
        edit:SetMultiLine(true)
        edit:SetAutoFocus(false)
        edit:SetFontObject(ChatFontNormal or GameFontHighlightSmall)
        edit:SetWidth(450)
        edit:SetScript("OnEscapePressed", function() popup:Hide() end)
        -- read-only-ish: put the text back if the user types into it
        edit:SetScript("OnTextChanged", function(self, userInput)
            if userInput then self:SetText(popup.text or "") self:HighlightText() end
        end)
        edit:SetScript("OnEditFocusGained", function(self) self:HighlightText() end)
        scroll:SetScrollChild(edit)
        popup.edit = edit
    end
    popup.text = text
    popup.edit:SetText(text)
    popup:Show()
    popup.edit:SetFocus()
    popup.edit:HighlightText()
    return text
end
ns.ShowExport = ShowExport
ns:AddCommand("export", function()
    local text = ShowExport()
    local n = 0 for _ in text:gmatch("\nQ%^") do n = n + 1 end
    ns.Print("export ready: " .. n .. " quests. Ctrl+C to copy.")
end)

local function Summary()
    local n, accepts, turnins = 0, 0, 0
    for _, r in pairs(Records()) do
        n = n + 1
        if r.accept then accepts = accepts + 1 end
        if r.turnin then turnins = turnins + 1 end
    end
    ns.Print(string.format("quest recorder: %d quests (%d pickups, %d turn-ins) saved in CompanionDB.questRecords. They are written to disk on logout or /reload.", n, accepts, turnins))
    return n
end
ns.RecorderSummary = Summary
function ns.RecordCount()
    local n = 0
    for _ in pairs(ns.db.questRecords or {}) do n = n + 1 end
    return n
end
function ns.ClearQuestRecords()
    ns.db.questRecords = {}
    wipe(lastText)
end
ns:AddCommand("recorder", Summary)
ns:AddCommand("questlog-export", Summary)

-- ===================== /comp model (0.56) =====================
-- Name, NPC ID and (when the client exposes it) display/model file ID of the target or mouseover.
local probe
local function num(v) if type(v) == "number" and not secret(v) and v > 0 then return v end end
local function ReadModel(m)
    local disp, file
    if m.GetDisplayInfo then local ok, v = pcall(m.GetDisplayInfo, m) if ok then disp = num(v) end end
    if m.GetModelFileID then local ok, v = pcall(m.GetModelFileID, m) if ok then file = num(v) end end
    return disp, file
end
function ns.ModelInfo(unit, done)
    if not (UnitExists and UnitExists(unit)) then return false end
    local name = UnitName and UnitName(unit)
    if secret(name) then name = nil end
    local guid = UnitGUID and UnitGUID(unit)
    local npc = ns.NpcIDFromGUID(guid)
    if not probe and CreateFrame then
        local ok, f = pcall(CreateFrame, "PlayerModel", nil, UIParent)
        if ok and f then probe = f probe:SetSize(1, 1) probe:SetAlpha(0) end
    end
    local function finish(disp, file)
        local parts = { "model: " .. tostring(name or "?") }
        parts[#parts + 1] = "NPC ID " .. (npc and tostring(npc) or "n/a")
        if disp or file then
            if disp then parts[#parts + 1] = "display ID " .. disp end
            if file then parts[#parts + 1] = "model file ID " .. file end
        else
            parts[#parts + 1] = "display ID not available on this client"
        end
        local msg = table.concat(parts, ", ")
        if npc and not disp then msg = msg .. " (see foreverdb.net/npc/" .. npc .. ")" end
        ns.Print(msg)
        if done then done(msg, disp, file) end
    end
    if not probe then finish(nil, nil) return true end
    if probe.Show then probe:Show() end
    pcall(probe.SetUnit, probe, unit)
    local disp, file = ReadModel(probe)
    if disp or file or not (C_Timer and C_Timer.After) then finish(disp, file) return true end
    C_Timer.After(0.2, function() finish(ReadModel(probe)) end)
    return true
end
ns:AddCommand("model", function()
    if not ns.ModelInfo("target") and not ns.ModelInfo("mouseover") then
        ns.Print("model: target or mouse over an NPC first")
    end
end)
table.insert(ns.HELP, "/comp model - name, NPC ID and display ID of your target (or mouseover)")
