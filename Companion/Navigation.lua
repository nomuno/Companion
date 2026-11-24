-- Companion: Navigation. The companion model turns to face your next objective.
--
-- Target sources, in order:
--   1. A manual waypoint set with /comp way <x> <y>
--   2. The map pin you placed on the world map (if the client supports it)
--   3. The current leveling guide step (Guide.lua), if one is loaded
--   4. The nearest quest objective/turn-in the game marks on the map
-- Use /comp navdebug to see which of these this client supports.

local _, ns = ...

ns.defaults.navEnabled = true
ns.defaults.navInvert = false     -- flip left/right if she turns the wrong way
ns.defaults.navArriveYards = 15

local nav = { target = nil, manual = nil, current = 0, lastPick = 0 }
ns.nav = nav

local function safe(fn, ...)
    if not fn then return nil end
    local ok, a, b, c, d = pcall(fn, ...)
    if ok then return a, b, c, d end
end

local function IsSecret(v) return issecretvalue and issecretvalue(v) end

-- ===================== POSITIONS =====================

-- Player's position in world coordinates (yards), plus the map it's on.
local function PlayerWorldPos()
    local mapID = safe(C_Map.GetBestMapForUnit, "player")
    if not mapID then return nil end
    local pos = safe(C_Map.GetPlayerMapPosition, mapID, "player")
    if not pos then return nil end
    local _, world = safe(C_Map.GetWorldPosFromMapPos, mapID, pos)
    if not world then return nil end
    local x, y = world:GetXY()
    if IsSecret(x) or IsSecret(y) then return nil end
    return x, y, mapID
end

-- Convert a map coordinate (0-1) on a map into world coordinates.
local function MapToWorld(mapID, mx, my)
    local _, world = safe(C_Map.GetWorldPosFromMapPos, mapID, CreateVector2D(mx, my))
    if not world then return nil end
    return world:GetXY()
end

-- ===================== TARGET PICKING =====================

local function QuestTargets(mapID)
    local list = {}
    local onMap = C_QuestLog and safe(C_QuestLog.GetQuestsOnMap, mapID)
    if type(onMap) == "table" then
        for _, info in ipairs(onMap) do
            if info.questID and info.x and info.y then
                local q = ns.quests[info.questID]
                table.insert(list, {
                    mapID = mapID, x = info.x, y = info.y,
                    label = q and q.title or ("Quest " .. info.questID),
                    turnIn = q and q.complete,
                })
            end
        end
    end
    return list
end

local function PickTarget()
    if nav.manual then return nav.manual end

    local pin = C_Map and safe(C_Map.GetUserWaypoint)
    if pin and pin.uiMapID and pin.position then
        return { mapID = pin.uiMapID, x = pin.position.x, y = pin.position.y, label = "your map pin" }
    end

    local guide = ns.GuideTarget and ns:GuideTarget()
    if guide then return guide end

    local px, py, mapID = PlayerWorldPos()
    if not px then return nil end
    local best, bestDist
    for _, t in ipairs(QuestTargets(mapID)) do
        local wx, wy = MapToWorld(t.mapID, t.x, t.y)
        if wx then
            local d = (wx - px) ^ 2 + (wy - py) ^ 2
            if not bestDist or d < bestDist then best, bestDist = t, d end
        end
    end
    return best
end

nav.PlayerWorldPos = PlayerWorldPos
nav.MapToWorld = MapToWorld
nav.PickTarget = PickTarget

-- ===================== MODEL TURNING =====================

local function NormalizeAngle(a)
    while a > math.pi do a = a - 2 * math.pi end
    while a < -math.pi do a = a + 2 * math.pi end
    return a
end

-- Returns the angle she should face (0 = toward you) and the distance in yards.
local function DesiredFacing()
    local t = nav.target
    if not t then return nil end
    local px, py = PlayerWorldPos()
    if not px then return nil end
    local tx, ty = MapToWorld(t.mapID, t.x, t.y)
    if not tx then return nil end

    local facing = safe(GetPlayerFacing)
    if not facing or IsSecret(facing) then return nil end

    -- World x points north, y points west; facing is radians counter-clockwise from north.
    local dx, dy = tx - px, ty - py
    local dist = math.sqrt(dx * dx + dy * dy)
    local bearing = math.atan2(dy, dx)
    local relative = NormalizeAngle(bearing - facing)    -- 0 ahead, + left, - right
    if ns.db.navInvert then relative = -relative end
    return relative, dist, relative
end

local function DirectionWord(relative)
    local deg = math.deg(relative)
    if math.abs(deg) < 25 then return "Straight ahead"
    elseif math.abs(deg) > 150 then return "Behind us"
    elseif deg > 0 then return deg > 75 and "To the left" or "Ahead, a bit left"
    else return deg < -75 and "To the right" or "Ahead, a bit right" end
end

local arrived = false

local function Update(elapsed)
    if not ns.db.navEnabled or not ns.model or not ns.frame:IsShown() then return end

    nav.lastPick = nav.lastPick + elapsed
    if nav.lastPick > 1 then
        nav.lastPick = 0
        nav.target = PickTarget()
    end

    local want, dist, relative = DesiredFacing()

    if dist and dist <= ns.db.navArriveYards then
        if not arrived then
            arrived = true
            local label = nav.target.label or ""
            if ns.Say then
                ns:Say("guideArrive", { vars = { target = label }, priority = true, force = true })
            else
                ns:ShowLine("We're here! " .. label)
            end
            if ns.PlayEmote then ns:PlayEmote(67, 2.5) end   -- wave
        end
    elseif dist then
        arrived = false
    end

    -- She always faces you; the wisp orbits her to show direction.
    ns.model:SetFacing(0)
    if want and not arrived then
        local diff = NormalizeAngle(want - nav.current)
        nav.current = NormalizeAngle(nav.current + diff * math.min(1, elapsed * 5))
        ns:SetWispAngle(nav.current, elapsed)
    else
        ns:SetWispAngle(nil)
    end

    if dist and not arrived and ns.ShowNavLine then
        -- With the guide section showing, the full step text is already at the bottom
        -- of the window, so the speech area only gets the direction and distance.
        if nav.target.guide and ns.GuideSectionActive and ns.GuideSectionActive() then
            ns:ShowNavLine(string.format("%s, %d yds", DirectionWord(relative), math.floor(dist + 0.5)))
        else
            ns:ShowNavLine(string.format("%s: %s, %d yds", nav.target.label or "Target",
                DirectionWord(relative), math.floor(dist + 0.5)))
        end
    end
end

local driver = CreateFrame("Frame")
driver:SetScript("OnUpdate", function(_, elapsed) Update(elapsed) end)

function ns:SetNavEnabled(on)
    ns.db.navEnabled = on
    if not on and ns.model then
        nav.current = 0
        ns.model:SetFacing(0)
        ns:SetWispAngle(nil)
        if ns.ShowNavLine then ns:ShowNavLine(nil) end
    end
end

-- ===================== COMMANDS =====================

ns:AddCommand("nav", function()
    ns:SetNavEnabled(not ns.db.navEnabled)
    ns.Print("navigation " .. (ns.db.navEnabled and "on" or "off"))
end)

function ns.ClearWaypoint() nav.manual = nil end
-- x, y in 0-100 map percent. Works for any map; she only points while you're on it.
function ns.SetManualWaypoint(mapID, x, y, label)
    nav.manual = { mapID = mapID, x = x / 100, y = y / 100, label = label or string.format("%.1f, %.1f", x, y) }
    nav.lastPick = 99
    return nav.manual
end
function ns.GetManualWaypoint() return nav.manual end
function ns.SetNavInvert(on) ns.db.navInvert = on and true or false end
function ns.SetNavArrive(yards) ns.db.navArriveYards = math.max(1, tonumber(yards) or 15) end

ns:AddCommand("way", function(rest)
    local x, y = rest:match("([%d%.]+)[,%s]+([%d%.]+)")
    x, y = tonumber(x), tonumber(y)
    if not x then
        ns.ClearWaypoint()
        ns.Print("waypoint cleared. Usage: /comp way 45.2 63.1")
        return
    end
    local mapID = safe(C_Map.GetBestMapForUnit, "player")
    if not mapID then ns.Print("can't tell what zone you're in.") return end
    ns.SetManualWaypoint(mapID, x, y)
    ns.Print("heading to " .. nav.manual.label .. ". /comp way to clear.")
end)

ns:AddCommand("navflip", function()
    ns.SetNavInvert(not ns.db.navInvert)
    ns.Print("left/right " .. (ns.db.navInvert and "flipped" or "normal"))
end)

ns:AddCommand("navdebug", function()
    local function has(v) return v and "|cff20ff20yes|r" or "|cffff4040no|r" end
    local mapID = safe(C_Map.GetBestMapForUnit, "player")
    local px, py = PlayerWorldPos()
    local facing = safe(GetPlayerFacing)
    local onMap = mapID and C_QuestLog and safe(C_QuestLog.GetQuestsOnMap, mapID)
    ns.Print("navigation check:")
    print("  map ID: " .. tostring(mapID))
    print("  player position: " .. has(px) .. (px and string.format(" (%.0f, %.0f)", px, py) or ""))
    print("  facing: " .. has(facing and not IsSecret(facing)))
    print("  quest map markers: " .. has(C_QuestLog and C_QuestLog.GetQuestsOnMap)
        .. (type(onMap) == "table" and (" (" .. #onMap .. " here)") or ""))
    print("  map pin support: " .. has(C_Map.GetUserWaypoint))
    local t = nav.target
    print("  current target: " .. (t and (t.label or "?") or "none"))
end)
