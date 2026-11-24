-- Companion module: Quest Helper. Uses the shared Companion table (this file is a separate addon; `ns` is not shared automatically).
-- 2026-10-14: steps reordered to follow the Polestar addon's route (Polestar is credited in CREDITS.txt; Companion is GPL-3.0). Data/coords/notes unchanged.
-- 0.37: route checked against TUGs' free Guidelime guides for WoW Forever (thanks TUGs!); quests TUGs routes that we lacked were added, notes marked 'TUGs'.
-- Companion guide: Hillsbrad 20-30 (Horde).
--
-- Generated from the Questie Classic database (quest/npc/object/item DBs, areaID 267)
-- with /workspace/qdb/gen.lua and the route spec in /workspace/qdb/specs/hillsbrad.txt, then
-- reviewed. Quest IDs, givers/turn-ins and coords come straight from the DB; kill/collect
-- coords are the centre of the spawns of the objective's best source in this zone.
-- Race/class filters come from the quests' race/class masks. Steps marked TODO have no
-- location in the DB (escorts, summoned or event mobs). uiMapIDs from Questie's
-- areaIdToUiMapId: Hillsbrad 1424, Silverpine 1421.

local ns = _G.Companion
if not ns then return end
local M = 1424

ns:RegisterGuide("Hillsbrad 20-30", {
    faction = "Horde", minLevel = 20, maxLevel = 30, mapID = M,
    startZones = { 1424 },
    next = "Thousand Needles 25-30",
    steps = {
        { type = "accept", qid = 494, title = "Time To Strike", x = 20.8, y = 47.4, note = "Deathstalker Lesh" },
        { type = "turnin", qid = 493, title = "Journey to Hillsbrad Foothills", x = 61.4, y = 19.1, note = "Apothecary Lydon" },
        { type = "complete", qid = 494, title = "Time To Strike", note = "TODO: objective has no location data" },
        { type = "turnin", qid = 494, title = "Time To Strike", x = 62.3, y = 20.4, note = "High Executor Darthalia" },
        { type = "accept", qid = 498, title = "The Rescue", x = 63.2, y = 20.7, note = "Krusk" },
        { type = "accept", qid = 549, title = "WANTED: Syndicate Personnel", x = 62.6, y = 20.8, note = "WANTED" },
        { type = "accept", qid = 567, title = "Dangerous!", x = 62.6, y = 19.7, note = "Dangerous!" },
        { type = "accept", qid = 527, title = "Battle of Hillsbrad", x = 62.3, y = 20.4, note = "High Executor Darthalia" },
        { type = "accept", qid = 496, title = "Elixir of Suffering", x = 61.4, y = 19.1, note = "Apothecary Lydon" },
        { type = "accept", qid = 501, title = "Elixir of Pain", x = 61.4, y = 19.1, note = "Apothecary Lydon" },
        { type = "accept", qid = 509, title = "Elixir of Agony", x = 61.4, y = 19.1, note = "Apothecary Lydon" },
        { type = "collect", qid = 496, obj = 1, title = "Gray Bear Tongue", x = 57.1, y = 48.7, note = "Elder Gray Bear" },
        { type = "collect", qid = 496, obj = 2, title = "Creeper Ichor", x = 53.2, y = 50.8, note = "Giant Moss Creeper" },
        { type = "collect", qid = 501, title = "Mountain Lion Blood", x = 49.7, y = 38.3, note = "Starving Mountain Lion" },
        { type = "kill", qid = 527, obj = 2, title = "Hillsbrad Farmhand", x = 33.4, y = 38.9 },
        { type = "kill", qid = 527, obj = 1, title = "Hillsbrad Farmer", x = 33.4, y = 39.3 },
        { type = "kill", qid = 527, obj = 3, title = "Farmer Ray", x = 33.2, y = 34.8 },
        { type = "kill", qid = 527, obj = 4, title = "Farmer Getz", x = 36.7, y = 39.4 },
        { type = "kill", qid = 567, obj = 4, title = "Farmer Kalaba", x = 35.9, y = 46.6 },
        { type = "turnin", qid = 496, title = "Elixir of Suffering", x = 61.4, y = 19.1, note = "Apothecary Lydon" },
        { type = "accept", qid = 499, title = "Elixir of Suffering", x = 61.4, y = 19.1, note = "Apothecary Lydon" },
        { type = "complete", qid = 499, title = "Elixir of Suffering", note = "TODO: objective has no location data" },
        { type = "turnin", qid = 499, title = "Elixir of Suffering", x = 61.5, y = 19.1, note = "Umpi" },
        { type = "turnin", qid = 501, title = "Elixir of Pain", x = 61.4, y = 19.1, note = "Apothecary Lydon" },
        { type = "accept", qid = 502, title = "Elixir of Pain", x = 61.4, y = 19.1, note = "Apothecary Lydon" },
        { type = "complete", qid = 502, title = "Elixir of Pain", note = "TODO: objective has no location data" },
        { type = "turnin", qid = 527, title = "Battle of Hillsbrad", x = 62.3, y = 20.4, note = "High Executor Darthalia" },
        { type = "accept", qid = 528, title = "Battle of Hillsbrad", x = 62.3, y = 20.4, note = "High Executor Darthalia" },
        { type = "accept", qid = 546, title = "Souvenirs of Death", x = 62.1, y = 19.7, note = "Deathguard Samsa" },
        { type = "kill", qid = 549, obj = 1, title = "Syndicate Rogue", x = 75.3, y = 45.4 },
        { type = "kill", qid = 549, obj = 2, title = "Syndicate Watchman", x = 77.8, y = 43.2 },
        { type = "collect", qid = 498, obj = 1, title = "Locked ball and chain", x = 75.3, y = 41.5 },
        { type = "collect", qid = 498, obj = 2, title = "Locked ball and chain", x = 79.8, y = 39.6 },
        { type = "collect", qid = 509, title = "Mudsnout Blossoms", x = 64.4, y = 61.3, note = "Mudsnout Blossom" },
        { type = "turnin", qid = 549, title = "WANTED: Syndicate Personnel", x = 62.3, y = 20.4, note = "High Executor Darthalia" },
        { type = "turnin", qid = 498, title = "The Rescue", x = 63.2, y = 20.7, note = "Krusk" },
        { type = "turnin", qid = 509, title = "Elixir of Agony", x = 61.4, y = 19.1, note = "Apothecary Lydon" },
        { type = "accept", qid = 541, title = "Battle of Hillsbrad", x = 62.3, y = 20.4, note = "High Executor Darthalia" },
        { type = "kill", qid = 541, obj = 1, title = "Dun Garok Mountaineer", x = 71.3, y = 79.3 },
        { type = "kill", qid = 541, obj = 2, title = "Dun Garok Rifleman", x = 71.0, y = 78.2 },
        { type = "kill", qid = 541, obj = 3, title = "Dun Garok Priest", x = 71.8, y = 79.4 },
        { type = "kill", qid = 541, obj = 4, title = "Captain Ironhill", x = 72.2, y = 79.8 },
        { type = "accept", qid = 513, title = "Elixir of Agony", x = 61.4, y = 19.1, note = "Apothecary Lydon" },
        { type = "turnin", qid = 541, title = "Battle of Hillsbrad", x = 62.3, y = 20.4, note = "High Executor Darthalia" },
        { type = "complete", qid = 513, title = "Elixir of Agony", note = "TODO: objective has no location data" },
        { type = "turnin", qid = 502, title = "Elixir of Pain", x = 32.7, y = 35.3, note = "Stanley" },
        { type = "kill", qid = 528, title = "Hillsbrad Peasant", x = 33.4, y = 44.5 },
        { type = "collect", qid = 546, title = "Hillsbrad Human Skull", x = 77.8, y = 43.2, note = "Syndicate Watchman" },
        { type = "turnin", qid = 528, title = "Battle of Hillsbrad", x = 62.3, y = 20.4, note = "High Executor Darthalia" },
        { type = "accept", qid = 529, title = "Battle of Hillsbrad", x = 62.3, y = 20.4, note = "High Executor Darthalia" },
        { type = "turnin", qid = 546, title = "Souvenirs of Death", x = 62.1, y = 19.7, note = "Deathguard Samsa" },
        { type = "kill", qid = 529, obj = 1, title = "Blacksmith Verringtan", x = 32.1, y = 44.4 },
        { type = "kill", qid = 529, obj = 2, title = "Hillsbrad Apprentice Blacksmith", x = 31.7, y = 45.5 },
        { type = "collect", qid = 529, obj = 3, title = "Shipment of Iron", x = 32.0, y = 45.5 },
        { type = "kill", qid = 567, obj = 2, title = "Citizen Wilkes", x = 32.6, y = 39.8 },
        { type = "turnin", qid = 529, title = "Battle of Hillsbrad", x = 62.3, y = 20.4, note = "High Executor Darthalia" },
        { type = "accept", qid = 532, title = "Battle of Hillsbrad", x = 62.3, y = 20.4, note = "High Executor Darthalia" },
        { type = "kill", qid = 532, obj = 1, title = "Magistrate Burnside", x = 29.7, y = 41.6 },
        { type = "kill", qid = 532, obj = 2, title = "Hillsbrad Councilman", x = 30.4, y = 42.5 },
        { type = "collect", qid = 532, obj = 4, title = "Hillsbrad Town Registry", x = 29.5, y = 41.5 },
        { type = "collect", qid = 532, obj = 3, title = "Hillsbrad Proclamation", x = 29.7, y = 41.8 },
        { type = "kill", qid = 567, obj = 1, title = "Clerk Horrace Whitesteed", x = 29.5, y = 42.4 },
        { type = "turnin", qid = 532, title = "Battle of Hillsbrad", x = 62.3, y = 20.4, note = "High Executor Darthalia" },
        { type = "accept", qid = 539, title = "Battle of Hillsbrad", x = 62.3, y = 20.4, note = "High Executor Darthalia" },
        { type = "kill", qid = 539, obj = 2, title = "Hillsbrad Miner", x = 29.9, y = 55.5 },
        { type = "kill", qid = 539, obj = 1, title = "Foreman Bonds", x = 31.2, y = 56.0 },
        { type = "kill", qid = 567, obj = 3, title = "Miner Hackett", x = 31.1, y = 58.6 },
        { type = "turnin", qid = 539, title = "Battle of Hillsbrad", x = 62.3, y = 20.4, note = "High Executor Darthalia" },
        { type = "turnin", qid = 567, title = "Dangerous!", x = 62.3, y = 20.4, note = "High Executor Darthalia" },
        { type = "turnin", qid = 513, title = "Elixir of Agony", mapID = 1458, x = 48.8, y = 69.3, note = "Master Apothecary Faranell" },
        { type = "note", text = "Hillsbrad done. Zeppelin back to Orgrimmar, then fly to Camp Taurajo and run south into Thousand Needles (Freewind Post)" },
    },
})
