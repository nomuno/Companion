-- Companion module: Quest Helper. Uses the shared Companion table (this file is a separate addon; `ns` is not shared automatically).
-- 2026-10-14: steps reordered to follow the Polestar addon's route (Polestar is credited in CREDITS.txt; Companion is GPL-3.0). Data/coords/notes unchanged.
-- 0.37: route checked against TUGs' free Guidelime guides for WoW Forever (thanks TUGs!); quests TUGs routes that we lacked were added, notes marked 'TUGs'.
-- Companion guide: Thousand Needles 25-30 (Horde).
--
-- Generated from the Questie Classic database (quest/npc/object/item DBs, areaID 400)
-- with /workspace/qdb/gen.lua and the route spec in /workspace/qdb/specs/needles.txt, then
-- reviewed. Quest IDs, givers/turn-ins and coords come straight from the DB; kill/collect
-- coords are the centre of the spawns of the objective's best source in this zone.
-- Race/class filters come from the quests' race/class masks. Steps marked TODO have no
-- location in the DB (escorts, summoned or event mobs). uiMapIDs from Questie's
-- areaIdToUiMapId: Thousand Needles 1441.

local ns = _G.Companion
if not ns then return end
local M = 1441

ns:RegisterGuide("Thousand Needles 25-30", {
    faction = "Horde", minLevel = 25, maxLevel = 30, mapID = M,
    startZones = { 1441 }, next = "Desolace 30-33",
    steps = {
        { type = "accept", qid = 4542, title = "Message to Freewind Post", x = 32.2, y = 22.2, note = "Brave Moonhorn" },
        { type = "turnin", qid = 4542, title = "Message to Freewind Post", x = 45.7, y = 50.7, note = "Cliffwatcher Longhorn" },
        { type = "accept", qid = 4841, title = "Pacify the Centaur", x = 45.7, y = 50.7, note = "Cliffwatcher Longhorn" },
        { type = "accept", qid = 4821, title = "Alien Egg", x = 44.6, y = 50.3, note = "Hagar Lightninghoof" },
        { type = "accept", qid = 4767, title = "Wind Rider", x = 44.9, y = 48.9, note = "Elu" },
        { type = "accept", qid = 5147, title = "Wanted - Arnak Grimtotem", x = 46.0, y = 50.9, note = "Wanted Poster - Arnak Grimtotem" },
        { type = "collect", qid = 4821, title = "Alien Egg", x = 48.8, y = 53.9 },
        { type = "turnin", qid = 4821, title = "Alien Egg", x = 44.6, y = 50.3, note = "Hagar Lightninghoof" },
        { type = "accept", qid = 4865, title = "Serpent Wild", x = 44.6, y = 50.3, note = "Hagar Lightninghoof" },
        { type = "complete", qid = 4865, title = "Serpent Wild", note = "TODO: objective has no location data" },
        { type = "kill", qid = 4841, obj = 1, title = "Galak Scout", x = 43.4, y = 38.6 },
        { type = "kill", qid = 4841, obj = 2, title = "Galak Wrangler", x = 43.5, y = 39.1 },
        { type = "kill", qid = 4841, obj = 3, title = "Galak Windchaser", x = 43.6, y = 38.9 },
        { type = "accept", qid = 1149, title = "Test of Faith", x = 54.0, y = 41.5, note = "Dorn Plainstalker" },
        { type = "complete", qid = 1149, title = "If you have faith, leap from the planks overlooking Thousand Needles.", x = 26.4, y = 32.9 },
        { type = "turnin", qid = 1149, title = "Test of Faith", x = 54.0, y = 41.5, note = "Dorn Plainstalker" },
        { type = "accept", qid = 1150, title = "Test of Endurance", x = 54.0, y = 41.5, note = "Dorn Plainstalker" },
        { type = "turnin", qid = 4841, title = "Pacify the Centaur", x = 45.7, y = 50.7, note = "Cliffwatcher Longhorn" },
        { type = "accept", qid = 5064, title = "Grimtotem Spying", x = 45.7, y = 50.7, note = "Cliffwatcher Longhorn" },
        { type = "collect", qid = 5064, obj = 3, title = "Secret Note #3", x = 35.0, y = 38.0, note = "Document Chest" },
        { type = "collect", qid = 5064, obj = 2, title = "Secret Note #2", x = 35.0, y = 38.0, note = "Document Chest" },
        { type = "collect", qid = 5064, obj = 1, title = "Secret Note #1", x = 35.0, y = 38.0, note = "Document Chest" },
        { type = "collect", qid = 5147, title = "Arnak's Hoof", x = 38.1, y = 26.9, note = "Arnak Grimtotem" },
        { type = "accept", qid = 4904, title = "Free at Last", x = 38.0, y = 26.4, note = "Lakota Windsong" },
        { type = "complete", qid = 4904, title = "Free at Last", note = "TODO: objective has no location data" },
        { type = "turnin", qid = 4865, title = "Serpent Wild", x = 21.5, y = 32.4, note = "Motega Firemane" },
        { type = "collect", qid = 4767, title = "Highperch Wyvern Egg", x = 13.4, y = 37.3 },
        { type = "accept", qid = 4770, title = "Homeward Bound", x = 17.9, y = 40.6, note = "Pao'ka Swiftmountain" },
        { type = "complete", qid = 4770, title = "Homeward Bound", note = "TODO: objective has no location data" },
        { type = "turnin", qid = 4770, title = "Homeward Bound", x = 21.5, y = 32.4, note = "Motega Firemane" },
        { type = "accept", qid = 5062, title = "Sacred Fire", x = 21.5, y = 32.4, note = "Motega Firemane" },
        { type = "accept", qid = 5151, title = "Hypercapacitor Gizmo", x = 21.4, y = 32.5, note = "Wizlo Bearingshiner" },
        { type = "collect", qid = 5062, title = "Incendia Agave", x = 35.4, y = 35.4 },
        { type = "collect", qid = 1150, title = "Grenka's Claw", note = "TODO: no spawn data" },
        { type = "turnin", qid = 5064, title = "Grimtotem Spying", x = 45.7, y = 50.7, note = "Cliffwatcher Longhorn" },
        { type = "turnin", qid = 5062, title = "Sacred Fire", mapID = 1456, x = 69.8, y = 30.9, note = "Magatha Grimtotem" },
        { type = "collect", qid = 5151, title = "Hypercapacitor Gizmo", x = 22.8, y = 24.6, note = "Enraged Panther" },
        { type = "turnin", qid = 5151, title = "Hypercapacitor Gizmo", x = 21.4, y = 32.5, note = "Wizlo Bearingshiner" },
        { type = "turnin", qid = 5147, title = "Wanted - Arnak Grimtotem", x = 45.7, y = 50.7, note = "Cliffwatcher Longhorn" },
        { type = "turnin", qid = 4904, title = "Free at Last", x = 46.0, y = 51.6, note = "Thalia Amberhide" },
        { type = "turnin", qid = 4767, title = "Wind Rider", x = 44.9, y = 48.9, note = "Elu" },
        { type = "turnin", qid = 1150, title = "Test of Endurance", x = 54.0, y = 41.5, note = "Dorn Plainstalker" },
        { type = "accept", qid = 1104, title = "Salt Flat Venom", x = 78.1, y = 77.1, note = "Fizzle Brassbolts" },
        { type = "accept", qid = 1105, title = "Hardened Shells", x = 78.1, y = 77.1, note = "Wizzle Brassbolts" },
        { type = "accept", qid = 1176, title = "Load Lightening", x = 80.2, y = 75.9, note = "Pozzik" },
        { type = "collect", qid = 1104, title = "Salty Scorpid Venom", x = 76.6, y = 62.2, note = "Scorpid Reaver" },
        { type = "collect", qid = 1105, title = "Hardened Tortoise Shell", x = 81.8, y = 65.0, note = "Sparkleshell Snapper" },
        { type = "collect", qid = 1176, title = "Hollow Vulture Bone", x = 81.4, y = 63.9, note = "Salt Flats Scavenger" },
        { type = "turnin", qid = 1104, title = "Salt Flat Venom", x = 78.1, y = 77.1, note = "Fizzle Brassbolts" },
        { type = "turnin", qid = 1105, title = "Hardened Shells", x = 78.1, y = 77.1, note = "Wizzle Brassbolts" },
        { type = "turnin", qid = 1176, title = "Load Lightening", x = 80.2, y = 75.9, note = "Pozzik" },
        { type = "note", text = "Level 30 reached! That's the end of the 1-30 route", note = "click Next to finish" },
    },
})
