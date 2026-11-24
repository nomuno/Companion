-- Companion module: Quest Helper. Uses the shared Companion table (this file is a separate addon; `ns` is not shared automatically).
-- 2026-10-14: steps reordered to follow the Polestar addon's route (Polestar is credited in CREDITS.txt; Companion is GPL-3.0). Data/coords/notes unchanged.
-- Guides/Alliance/Ashenvale2729Alliance.lua - Ashenvale 27-29 (Alliance) (Alliance), uiMapID 1440.
-- Route order from TUGs' free Guidelime guides for WoW Forever (27-28 Ashenvale.lua, 28-29 Blackfathom Depths.lua); thanks TUGs!
-- Data: ForeverDB (Forever-seen first) > Wowhead Forever tooltips > Questie classic DB. TODO where unknown.
local ns = _G.Companion
if not ns then return end
ns:RegisterGuide("Ashenvale 27-29 (Alliance)", {
    faction = "Alliance", minLevel = 25, maxLevel = 30, mapID = 1440, next = "Wetlands 29-30", oldNames = { "Ashenvale 24-25 (Alliance)" },
    steps = {
        { type = "note", text = "Take the boat to Auberdine", note = "TUGs route note; Next when done" },
        { type = "turnin", qid = 994, title = "Escape Through Force", mapID = 1439, x = 39.4, y = 43.5, note = "Terenthis" },
        { type = "accept", qid = 95737, title = "Seeking Caitlin", forever = true, note = "WoW Forever quest; TODO: giver not recorded yet (TUGs routes it here)" },
        { type = "accept", qid = 1056, title = "Journey to Stonetalon Peak", x = 35.8, y = 49.1, note = "Faldreas Goeth'Shael" },
        { type = "accept", qid = 1054, title = "Culling the Threat", x = 36.6, y = 49.6, note = "Raene Wolfrunner" },
        { type = "collect", qid = 973, title = "Ilkrud Magthrull's Tome", x = 25.3, y = 60.7, note = "Ilkrud Magthrull" },
        { type = "note", text = "Fly to", note = "TUGs route note; Next when done" },
        { type = "accept", qid = 1024, title = "Raene's Cleansing", x = 36.6, y = 49.6, note = "Raene Wolfrunner" },
        { type = "accept", qid = 1025, title = "An Aggressive Defense", x = 36.6, y = 49.6, note = "Raene Wolfrunner" },
        { type = "collect", qid = 1054, title = "Dal Bloodclaw's Skull", x = 37.7, y = 34.7, note = "Dal Bloodclaw" },
        { type = "collect", qid = 1033, title = "Elune's Tear", x = 46.4, y = 46.4 },
        { type = "turnin", qid = 1054, title = "Culling the Threat", x = 36.6, y = 49.6, note = "Raene Wolfrunner" },
        { type = "turnin", qid = 1033, title = "Elune's Tear", x = 37.4, y = 51.8, note = "Pelturas Whitemoon" },
        { type = "accept", qid = 1034, title = "The Ruins of Stardust", x = 37.4, y = 51.8, note = "Pelturas Whitemoon" },
        { type = "turnin", qid = 1024, title = "Raene's Cleansing", x = 53.5, y = 46.2, note = "Shael'dryn" },
        { type = "kill", qid = 1025, title = "Foulweald Den Watcher", obj = 1, x = 52.3, y = 60.9 },
        { type = "kill", qid = 1025, title = "Foulweald Ursa", obj = 2, x = 52.2, y = 60.8 },
        { type = "kill", qid = 1025, title = "Foulweald Totemic", obj = 3, x = 53.7, y = 63 },
        { type = "kill", qid = 1025, title = "Foulweald Warrior", obj = 4, x = 53.3, y = 62.5 },
        { type = "accept", qid = 2931, title = "Castpipe's Task", mapID = 1442, x = 59.5, y = 67.1, forever = true, note = "WoW Forever quest; Gaxim Rustfizzle (ForeverDB)" },
        { type = "collect", qid = 1034, title = "Handful of Stardust", x = 33.3, y = 67.8, note = "Stardust Covered Bush" },
        { type = "turnin", qid = 1034, title = "The Ruins of Stardust", x = 37.4, y = 51.8, note = "Pelturas Whitemoon" },
        { type = "note", text = "Depending on what you do now the route differes", note = "TUGs route note; Next when done" },
        { type = "note", text = "You do BFD now: Go to the 26-27 BFD guide", note = "TUGs route note; Next when done" },
        { type = "note", text = "Continue questing: Fly to Auberdine and take the boat to Wetlands(Menethil Harbor)", note = "TUGs route note; Next when done" },
        { type = "note", text = "This will be added later", note = "TUGs route note; Next when done" },
        { type = "hearth", text = "Use your Hearthstone", note = "TUGs route note; Next when done" },
        { type = "turnin", qid = 1025, title = "An Aggressive Defense", x = 36.6, y = 49.6, note = "Raene Wolfrunner" },
        { type = "note", text = "Go through the cave into Stonetalon Mountains", note = "TUGs route note; Next when done" },
        { type = "turnin", qid = 1070, title = "On Guard in Stonetalon", mapID = 1442, x = 59.9, y = 66.8, note = "Kaela Shadowspear" },
        { type = "accept", qid = 1085, title = "On Guard in Stonetalon", mapID = 1442, x = 59.9, y = 66.8, note = "Kaela Shadowspear" },
        { type = "turnin", qid = 1085, title = "On Guard in Stonetalon", mapID = 1442, x = 59.5, y = 67.2, note = "Gaxim Rustfizzle" },
        { type = "turnin", qid = 1056, title = "Journey to Stonetalon Peak", mapID = 1442, x = 37.1, y = 8.1, note = "Keeper Albagorm" },
        { type = "note", text = "Get the flight path: Get the flightpath at", note = "TUGs route note; Next when done" },
        { type = "note", text = "Fly to", note = "TUGs route note; Next when done" },
        { type = "note", text = "Start looking for a BFD dungeon group", note = "TUGs route note; Next when done" },
        { type = "accept", qid = 4581, title = "Kayneth Stillwind", x = 34.7, y = 48.8, note = "Shindrell Swiftfire" },
        { type = "accept", qid = 1026, title = "Raene's Cleansing", x = 53.5, y = 46.2, note = "Shael'dryn" },
    },
})
