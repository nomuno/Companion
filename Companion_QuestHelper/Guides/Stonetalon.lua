-- Companion module: Quest Helper. Uses the shared Companion table (this file is a separate addon; `ns` is not shared automatically).
-- 2026-10-14: steps reordered to follow the Polestar addon's route (Polestar is credited in CREDITS.txt; Companion is GPL-3.0). Data/coords/notes unchanged.
-- 0.37: route checked against TUGs' free Guidelime guides for WoW Forever (thanks TUGs!); quests TUGs routes that we lacked were added, notes marked 'TUGs'.
-- Companion guide: Stonetalon 15-27 (Horde).
--
-- Generated from the Questie Classic database (quest/npc/object/item DBs, areaID 406)
-- with /workspace/qdb/gen.lua and the route spec in /workspace/qdb/specs/stonetalon.txt, then
-- reviewed. Quest IDs, givers/turn-ins and coords come straight from the DB; kill/collect
-- coords are the centre of the spawns of the objective's best source in this zone.
-- Race/class filters come from the quests' race/class masks. Steps marked TODO have no
-- location in the DB (escorts, summoned or event mobs). uiMapIDs from Questie's
-- areaIdToUiMapId: Stonetalon 1442, the Barrens 1413.

local ns = _G.Companion
if not ns then return end
local M = 1442

ns:RegisterGuide("Stonetalon 15-27", {
    faction = "Horde", minLevel = 15, maxLevel = 27, mapID = M,
    startZones = { 1442 },
    next = "Ashenvale 18-30",
    steps = {
        { type = "accept", qid = 1062, title = "Goblin Invaders", mapID = 1413, x = 35.3, y = 27.9, note = "Seereth Stonebreak" },
        { type = "accept", qid = 6548, title = "Avenge My Village", mapID = 1413, x = 35.2, y = 27.8, note = "Makaba Flathoof" },
        { type = "kill", qid = 6548, obj = 1, title = "Grimtotem Ruffian", x = 82.0, y = 87.2 },
        { type = "kill", qid = 6548, obj = 2, title = "Grimtotem Mercenary", x = 82.2, y = 87.9 },
        { type = "turnin", qid = 6548, title = "Avenge My Village", mapID = 1413, x = 35.2, y = 27.8, note = "Makaba Flathoof" },
        { type = "accept", qid = 6629, title = "Kill Grundig Darkcloud", mapID = 1413, x = 35.2, y = 27.8, note = "Makaba Flathoof" },
        { type = "kill", qid = 6629, obj = 1, title = "Grundig Darkcloud", x = 73.7, y = 86.1 },
        { type = "kill", qid = 6629, obj = 2, title = "Grimtotem Brute", x = 76.7, y = 86.1 },
        { type = "accept", qid = 6523, title = "Protect Kaya", x = 73.5, y = 85.6, note = "Kaya Flathoof" },
        { type = "complete", qid = 6523, title = "Protect Kaya", note = "TODO: objective has no location data" },
        { type = "turnin", qid = 6629, title = "Kill Grundig Darkcloud", mapID = 1413, x = 35.2, y = 27.8, note = "Makaba Flathoof" },
        { type = "kill", qid = 1062, title = "Venture Co. Logger", x = 67.2, y = 51.9 },
        { type = "turnin", qid = 1062, title = "Goblin Invaders", mapID = 1413, x = 35.3, y = 27.9, note = "Seereth Stonebreak" },
        { type = "accept", qid = 1093, title = "Super Reaper 6000", x = 59.0, y = 62.6, note = "Ziz Fizziks" },
        { type = "collect", qid = 1093, title = "Super Reaper 6000 Blueprints", x = 68.6, y = 51.2, note = "Venture Co. Operator" },
        { type = "note", text = "From the Crossroads, head west along the road toward Stonetalon; the first quests are on the Barrens side" },
        { type = "accept", qid = 1090, title = "Gerenzo's Orders", x = 71.9, y = 60.0, note = "Piznik" },
        { type = "complete", qid = 1090, title = "Gerenzo's Orders", note = "TODO: objective has no location data" },
        { type = "turnin", qid = 1090, title = "Gerenzo's Orders", x = 71.9, y = 60.0, note = "Piznik" },
        { type = "accept", qid = 1092, title = "Gerenzo's Orders", x = 71.9, y = 60.0, note = "Piznik" },
        { type = "turnin", qid = 1092, title = "Gerenzo's Orders", x = 59.0, y = 62.6, note = "Ziz Fizziks" },
        { type = "turnin", qid = 1093, title = "Super Reaper 6000", x = 59.0, y = 62.6, note = "Ziz Fizziks" },
        { type = "accept", qid = 6284, title = "Arachnophobia", x = 59.1, y = 75.7, note = "Wanted Poster: Besseleth" },
        { type = "collect", qid = 6284, title = "Besseleth's Fang", x = 53.1, y = 72.5, note = "Besseleth" },
        { type = "accept", qid = 6421, title = "Boulderslide Ravine", x = 47.2, y = 64.0, note = "Mor'rogal" },
        { type = "turnin", qid = 6284, title = "Arachnophobia", x = 47.2, y = 61.2, note = "Maggran Earthbinder" },
        { type = "accept", qid = 6562, title = "Trouble in the Deeps", x = 47.4, y = 64.2, dungeon = "BFD", optional = true, note = "Tsunaman" },
        { type = "collect", qid = 6421, title = "Resonite Crystal", x = 59.6, y = 91.6, note = "Gogger Geomancer" },
        { type = "complete", qid = 6421, title = "Investigate Cave in Boulderslide Ravine", x = 58.2, y = 89.5 },
        { type = "turnin", qid = 6421, title = "Boulderslide Ravine", x = 47.2, y = 64.0, note = "Mor'rogal" },
        { type = "accept", qid = 6481, title = "Earthen Arise", x = 47.2, y = 64.0, note = "Mor'rogal" },
        { type = "kill", qid = 6481, title = "Goggeroc", note = "TODO: no spawn data" },
        { type = "turnin", qid = 6481, title = "Earthen Arise", x = 47.2, y = 64.0, note = "Mor'rogal" },
        { type = "accept", qid = 6301, title = "Cycle of Rebirth", x = 47.5, y = 58.4, note = "Tammra Windfield" },
        { type = "collect", qid = 6301, title = "Gaea Seed", x = 48.8, y = 40.7 },
        { type = "turnin", qid = 6301, title = "Cycle of Rebirth", x = 47.5, y = 58.4, note = "Tammra Windfield" },
        { type = "accept", qid = 6381, title = "New Life", x = 47.5, y = 58.4, note = "Tammra Windfield" },
        { type = "collect", qid = 6381, title = "Gaea Dirt Mound", x = 32.9, y = 68.1 },
        { type = "turnin", qid = 6381, title = "New Life", x = 47.5, y = 58.4, note = "Tammra Windfield" },
        { type = "turnin", qid = 6523, title = "Protect Kaya", mapID = 1413, x = 35.2, y = 27.8, note = "Makaba Flathoof" },
        { type = "accept", qid = 6461, title = "Blood Feeders", x = 71.2, y = 95.0, note = "Xen'Zilla" },
        { type = "kill", qid = 6461, obj = 1, title = "Deepmoss Creeper", x = 59.4, y = 78.9 },
        { type = "kill", qid = 6461, obj = 2, title = "Deepmoss Venomspitter", x = 55.7, y = 61.0 },
        { type = "turnin", qid = 6461, title = "Blood Feeders", x = 71.2, y = 95.0, note = "Xen'Zilla" },
        { type = "note", text = "Stonetalon done. Run north from Sun Rock Retreat into Ashenvale to Zoram'gar Outpost on the coast (or fly to Splintertree Post if you have the flight path)" },
    },
})
