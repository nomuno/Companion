-- Companion module: Quest Helper. Uses the shared Companion table (this file is a separate addon; `ns` is not shared automatically).
-- 2026-10-14: steps reordered to follow the Polestar addon's route (Polestar is credited in CREDITS.txt; Companion is GPL-3.0). Data/coords/notes unchanged.
-- Guides/Alliance/Ashenvale2324Alliance.lua - Ashenvale 23-24 (Alliance) (Alliance), uiMapID 1440.
-- Route order from TUGs' free Guidelime guides for WoW Forever (23-24 Ashenvale.lua); thanks TUGs!
-- Data: ForeverDB (Forever-seen first) > Wowhead Forever tooltips > Questie classic DB. TODO where unknown.
local ns = _G.Companion
if not ns then return end
ns:RegisterGuide("Ashenvale 23-24 (Alliance)", {
    faction = "Alliance", minLevel = 21, maxLevel = 25, mapID = 1440, startZones = { 1440 }, next = "Duskwood 24-25", oldNames = { "Ashenvale 22 (Alliance)" },
    steps = {
        { type = "turnin", qid = 2139, title = "Tharnariun's Hope", mapID = 1439, x = 38.8, y = 43.4, note = "Tharnariun Treetender" },
        { type = "turnin", qid = 4763, title = "The Blackwood Corrupted", mapID = 1439, x = 37.4, y = 40.1, note = "Thundris Windweaver" },
        { type = "turnin", qid = 87760, title = "Quest 87760", forever = true, note = "WoW Forever quest; TODO: hand-in not recorded yet" },
        { type = "turnin", qid = 951, title = "Mathystra Relics", mapID = 1439, x = 43.5, y = 76.3, note = "Onu" },
        { type = "turnin", qid = 98013, title = "Swelling Forces", forever = true, note = "WoW Forever quest; TODO: hand-in not recorded yet" },
        { type = "note", text = "ESCORT QUEST INCOMING,make sure all group members are on the same questprogress", note = "TUGs route note; Next when done" },
        { type = "turnin", qid = 993, title = "A Lost Master", mapID = 1439, x = 45, y = 85.3, note = "Volcor" },
        { type = "accept", qid = 994, title = "Escape Through Force", mapID = 1439, x = 45, y = 85.3, note = "Volcor" },
        { type = "complete", qid = 994, title = "Escape Through Force", note = "TODO: objective has no location data" },
        { type = "turnin", qid = 5713, title = "One Shot. One Kill.", x = 26.6, y = 36.7, note = "Sentinel Onaeya" },
        { type = "turnin", qid = 967, title = "The Tower of Althalaxx", x = 26.2, y = 38.7, note = "Delgren the Purifier" },
        { type = "accept", qid = 970, title = "The Tower of Althalaxx", x = 26.2, y = 38.7, note = "Delgren the Purifier" },
        { type = "accept", qid = 1010, title = "Bathran's Hair", x = 26.4, y = 38.6, note = "Orendil Broadleaf" },
        { type = "collect", qid = 1010, title = "Bathran's Hair", x = 31.7, y = 23, note = "Plant Bundle" },
        { type = "collect", qid = 970, title = "Glowing Soul Gem", x = 31.1, y = 30.6, note = "Dark Strand Cultist" },
        { type = "turnin", qid = 1010, title = "Bathran's Hair", x = 26.4, y = 38.6, note = "Orendil Broadleaf" },
        { type = "accept", qid = 1020, title = "Orendil's Cure", x = 26.4, y = 38.6, note = "Orendil Broadleaf" },
        { type = "turnin", qid = 970, title = "The Tower of Althalaxx", x = 26.2, y = 38.7, note = "Delgren the Purifier" },
        { type = "accept", qid = 973, title = "The Tower of Althalaxx", x = 26.2, y = 38.7, note = "Delgren the Purifier" },
        { type = "accept", qid = 991, title = "Raene's Cleansing", x = 36.6, y = 49.6, note = "Raene Wolfrunner" },
        { type = "note", text = "Get the flight path: Get the flightpath at", note = "TUGs route note; Next when done" },
        { type = "accept", qid = 1070, title = "On Guard in Stonetalon", x = 34.9, y = 49.8, note = "Sentinel Thenysil" },
        { type = "turnin", qid = 1020, title = "Orendil's Cure", x = 37.4, y = 51.8, note = "Pelturas Whitemoon" },
        { type = "accept", qid = 1033, title = "Elune's Tear", x = 37.4, y = 51.8, note = "Pelturas Whitemoon" },
        { type = "turnin", qid = 991, title = "Raene's Cleansing", x = 20.3, y = 42.3, note = "Teronis' Corpse" },
        { type = "accept", qid = 1023, title = "Raene's Cleansing", x = 20.3, y = 42.3, note = "Teronis' Corpse" },
        { type = "collect", qid = 1023, title = "Glowing Gem", x = 20.1, y = 42.9, note = "Saltspittle Puddlejumper" },
        { type = "turnin", qid = 945, title = "Therylune's Escape", x = 22.6, y = 51.9, note = "Therysil" },
        { type = "accept", qid = 1008, title = "The Zoram Strand", x = 34.7, y = 48.8, note = "Shindrell Swiftfire" },
        { type = "accept", qid = 1007, title = "The Ancient Statuette", x = 14.8, y = 31.3, note = "Talen" },
        { type = "collect", qid = 1007, title = "Ancient Statuette", x = 14.2, y = 20.6 },
        { type = "turnin", qid = 1007, title = "The Ancient Statuette", x = 14.8, y = 31.3, note = "Talen" },
        { type = "accept", qid = 1009, title = "Ruuzel", x = 14.8, y = 31.3, note = "Talen" },
        { type = "note", text = "As a Group do Ruuzel, if youre solo skip it. (Some classes can do it solo too, Mage,Warlock,Hunter especially)", note = "TUGs route note; Next when done" },
        { type = "collect", qid = 1009, title = "Ring of Zoram", x = 11.8, y = 19.5, note = "Lady Vespia" },
        { type = "collect", qid = 1008, title = "Wrathtail Head", x = 13.9, y = 21.8, note = "Wrathtail Sorceress" },
        { type = "turnin", qid = 1009, title = "Ruuzel", x = 14.8, y = 31.3, note = "Talen" },
        { type = "turnin", qid = 1008, title = "The Zoram Strand", x = 34.7, y = 48.8, note = "Shindrell Swiftfire" },
        { type = "accept", qid = 1134, title = "Pridewings of Stonetalon", x = 34.7, y = 48.8, note = "Shindrell Swiftfire" },
        { type = "turnin", qid = 1023, title = "Raene's Cleansing", x = 36.6, y = 49.6, note = "Raene Wolfrunner" },
        { type = "hearth", text = "Use your Hearthstone", note = "TUGs route note; Next when done" },
    },
})
