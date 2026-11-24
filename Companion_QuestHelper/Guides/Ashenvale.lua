-- Companion module: Quest Helper. Uses the shared Companion table (this file is a separate addon; `ns` is not shared automatically).
-- 2026-10-14: steps reordered to follow the Polestar addon's route (Polestar is credited in CREDITS.txt; Companion is GPL-3.0). Data/coords/notes unchanged.
-- 0.37: route checked against TUGs' free Guidelime guides for WoW Forever (thanks TUGs!); quests TUGs routes that we lacked were added, notes marked 'TUGs'.
-- Companion guide: Ashenvale 18-30 (Horde).
--
-- Generated from the Questie Classic database (quest/npc/object/item DBs, areaID 331)
-- with /workspace/qdb/gen.lua and the route spec in /workspace/qdb/specs/ashenvale.txt, then
-- reviewed. Quest IDs, givers/turn-ins and coords come straight from the DB; kill/collect
-- coords are the centre of the spawns of the objective's best source in this zone.
-- Race/class filters come from the quests' race/class masks. Steps marked TODO have no
-- location in the DB (escorts, summoned or event mobs). uiMapIDs from Questie's
-- areaIdToUiMapId: Ashenvale 1440.

local ns = _G.Companion
if not ns then return end
local M = 1440

ns:RegisterGuide("Ashenvale 18-30", {
    faction = "Horde", minLevel = 18, maxLevel = 30, mapID = M,
    startZones = { 1440 },
    next = "Hillsbrad 20-30",
    steps = {
        { type = "note", text = "Ashenvale done. Take the zeppelin from Orgrimmar to the Undercity, then go south through Silverpine to Tarren Mill" },
        { type = "accept", qid = 6383, title = "The Ashenvale Hunt", x = 73.8, y = 61.5, note = "Senani Thunderheart" },
        { type = "complete", qid = 6383, title = "The Ashenvale Hunt", note = "TODO: objective has no location data" },
        { type = "turnin", qid = 6383, title = "The Ashenvale Hunt", x = 73.8, y = 61.5, note = "Senani Thunderheart" },
        { type = "accept", qid = 6442, title = "Naga at the Zoram Strand", x = 11.7, y = 34.9, note = "Marukai" },
        { type = "collect", qid = 6442, title = "Wrathtail Head", x = 13.9, y = 21.8, note = "Wrathtail Sorceress" },
        { type = "turnin", qid = 6442, title = "Naga at the Zoram Strand", x = 11.7, y = 34.9, note = "Marukai" },
        { type = "turnin", qid = 6562, title = "Trouble in the Deeps", x = 11.6, y = 34.3, dungeon = "BFD", optional = true, note = "Je'neu Sancrea" },
        { type = "accept", qid = 6563, title = "The Essence of Aku'Mai", x = 11.6, y = 34.3, dungeon = "BFD", optional = true, note = "Je'neu Sancrea" },
        { type = "accept", qid = 6921, title = "Amongst the Ruins", x = 11.6, y = 34.3, dungeon = "BFD", optional = true, note = "Je'neu Sancrea" },
        { type = "accept", qid = 216, title = "Between a Rock and a Thistlefur", x = 11.9, y = 34.5, note = "Karang Amakkar" },
        { type = "accept", qid = 6462, title = "Troll Charm", x = 11.7, y = 34.9, note = "Mitsuwa" },
        { type = "accept", qid = 6641, title = "Vorsha the Lasher", x = 12.1, y = 34.6, note = "Muglash" },
        { type = "complete", qid = 6641, title = "Vorsha the Lasher", note = "TODO: objective has no location data" },
        { type = "turnin", qid = 6641, title = "Vorsha the Lasher", x = 12.2, y = 34.2, note = "Warsong Runner" },
        { type = "kill", qid = 216, obj = 1, title = "Thistlefur Avenger", x = 35.4, y = 37.5 },
        { type = "kill", qid = 216, obj = 2, title = "Thistlefur Shaman", x = 34.6, y = 38.2 },
        { type = "collect", qid = 6462, title = "Troll Charm", x = 40.7, y = 33.6, note = "Troll Chest" },
        { type = "accept", qid = 6482, title = "Freedom to Ruul", x = 41.5, y = 34.5, note = "Ruul Snowhoof" },
        { type = "complete", qid = 6482, title = "Freedom to Ruul", note = "TODO: objective has no location data" },
        { type = "turnin", qid = 216, title = "Between a Rock and a Thistlefur", x = 11.9, y = 34.5, note = "Karang Amakkar" },
        { type = "accept", qid = 6621, title = "King of the Foulweald", x = 11.9, y = 34.5, note = "Karang Amakkar" },
        { type = "turnin", qid = 6462, title = "Troll Charm", x = 11.7, y = 34.9, note = "Mitsuwa" },
        { type = "collect", qid = 6621, title = "Murgut's Totem", note = "TODO: no spawn data" },
        { type = "accept", qid = 6544, title = "Torek's Assault", x = 68.3, y = 75.3, note = "Torek" },
        { type = "complete", qid = 6544, title = "Torek's Assault", note = "TODO: objective has no location data" },
        { type = "accept", qid = 6503, title = "Ashenvale Outrunners", x = 71.1, y = 68.1, note = "Kuray'bin" },
        { type = "kill", qid = 6503, title = "Ashenvale Outrunner", x = 73.5, y = 72.3 },
        { type = "turnin", qid = 6503, title = "Ashenvale Outrunners", x = 71.1, y = 68.1, note = "Kuray'bin" },
        { type = "turnin", qid = 6544, title = "Torek's Assault", x = 73.0, y = 62.5, note = "Ertog Ragetusk" },
        { type = "turnin", qid = 6482, title = "Freedom to Ruul", x = 74.1, y = 60.9, note = "Yama Snowhoof" },
        { type = "accept", qid = 6571, title = "Warsong Supplies", x = 71.4, y = 67.6, note = "Locke Okarr" },
        { type = "accept", qid = 824, title = "Je'neu of the Earthen Ring", x = 73.7, y = 60.0, note = "Mastok Wrilehiss" },
        { type = "complete", qid = 824, title = "Je'neu of the Earthen Ring", note = "TODO: objective has no location data" },
        { type = "accept", qid = 25, title = "Stonetalon Standstill", x = 73.7, y = 60.0, note = "Mastok Wrilehiss" },
        { type = "accept", qid = 6441, title = "Satyr Horns", x = 73.1, y = 61.5, note = "Pixel" },
        { type = "accept", qid = 6581, title = "Warsong Saw Blades", x = 73.1, y = 61.5, note = "Pixel" },
        { type = "accept", qid = 6504, title = "The Lost Pages", x = 70.0, y = 71.2, note = "Gurda Ragescar" },
        { type = "collect", qid = 6504, obj = 3, title = "Shredder Operating Manual - Chapter 3", note = "TODO: no spawn data" },
        { type = "collect", qid = 6504, obj = 2, title = "Shredder Operating Manual - Chapter 2", note = "TODO: no spawn data" },
        { type = "collect", qid = 6504, obj = 1, title = "Shredder Operating Manual - Chapter 1", note = "TODO: no spawn data" },
        { type = "turnin", qid = 6504, title = "The Lost Pages", x = 70.0, y = 71.2, note = "Gurda Ragescar" },
        { type = "collect", qid = 6441, title = "Satyr Horns", x = 81.2, y = 49.5, note = "Bleakheart Shadowstalker" },
        { type = "kill", qid = 25, title = "Befouled Water Elemental", x = 49.0, y = 70.4 },
        { type = "complete", qid = 25, title = "Scout the gazebo on Mystral Lake that overlooks the nearby Alliance outpost.", x = 48.9, y = 69.6 },
        { type = "turnin", qid = 25, title = "Stonetalon Standstill", x = 73.7, y = 60.0, note = "Mastok Wrilehiss" },
        { type = "turnin", qid = 6441, title = "Satyr Horns", x = 73.1, y = 61.5, note = "Pixel" },
        { type = "collect", qid = 6581, title = "Deadly Blunderbuss", note = "TODO: no spawn data" },
        { type = "turnin", qid = 6581, title = "Warsong Saw Blades", x = 73.1, y = 61.5, note = "Pixel" },
        { type = "collect", qid = 6571, obj = 1, title = "Warsong Saw Blades", note = "TODO: no spawn data" },
        { type = "collect", qid = 6571, obj = 2, title = "Warsong Axe Shipment", note = "TODO: no spawn data" },
        { type = "collect", qid = 6571, obj = 3, title = "Warsong Oil", x = 73.8, y = 51.8 },
        { type = "collect", qid = 6571, obj = 4, title = "Logging Rope", x = 34.6, y = 38.2, note = "Thistlefur Shaman" },
        { type = "turnin", qid = 6571, title = "Warsong Supplies", x = 71.4, y = 67.6, note = "Locke Okarr" },
        { type = "turnin", qid = 6621, title = "King of the Foulweald", x = 11.9, y = 34.5, note = "Karang Amakkar" },
        { type = "turnin", qid = 824, title = "Je'neu of the Earthen Ring", x = 11.6, y = 34.3, note = "Je'neu Sancrea" },
    },
})
