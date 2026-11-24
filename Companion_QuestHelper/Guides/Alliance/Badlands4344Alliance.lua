-- Companion module: Quest Helper. Uses the shared Companion table (this file is a separate addon; `ns` is not shared automatically).
-- Guides/Alliance/Badlands4344Alliance.lua - Badlands 43-44 (Alliance), uiMapID 1418.
-- 2026-10-14: route order from the Polestar addon (alliance/40-50/02-badlands.guide): Polestar is credited in CREDITS.txt; Companion is GPL-3.0.
-- Step data: our existing guides > ForeverDB > Wowhead > Questie classic DB. Coordinates are database values
-- ('approximate', not play-tested on Forever). Class training is not routed here; train when you hearth.
local ns = _G.Companion
if not ns then return end
ns:RegisterGuide("Badlands 43-44 (Alliance)", {
    faction = "Alliance", minLevel = 42, maxLevel = 45, mapID = 1418, startZones = { 1418 }, next = "Feralas 43-46 (Alliance)",
    steps = {
        { type = "note", text = "Fly to Thelsamar", note = "Polestar route note; Next when done" },
        { type = "accept", qid = 706, title = "Fiery Blaze Enchantments", x = 53.8, y = 43.3, note = "approximate coords (database, not play-tested); Sigrun Ironhew" },
        { type = "accept", qid = 732, title = "Tremors of the Earth", x = 61.9, y = 54.3, note = "approximate coords (database, not play-tested); Garek" },
        { type = "accept", qid = 739, title = "Murdaloc", x = 50.9, y = 62.4, note = "approximate coords (database, not play-tested); Battered Dwarven Skeleton" },
        { type = "kill", qid = 739, obj = 1, title = "Murdaloc", x = 49.6, y = 66.3, note = "approximate coords (database, not play-tested)" },
        { type = "kill", qid = 739, obj = 2, title = "Stonevault Bonesnapper", x = 50.5, y = 68.4, note = "approximate coords (database, not play-tested)" },
        { type = "turnin", qid = 705, title = "Pearl Diving", x = 42.4, y = 52.9, note = "approximate coords (database, not play-tested); Rigglefuzz" },
        { type = "collect", qid = 732, title = "Sign of the Earth", x = 12.6, y = 75.5, note = "approximate coords (database, not play-tested); Boss Tho'grun" },
        { type = "turnin", qid = 732, title = "Tremors of the Earth", x = 61.9, y = 54.3, note = "approximate coords (database, not play-tested); Garek" },
        { type = "collect", qid = 706, title = "Black Drake's Heart", x = 79.2, y = 42.8, note = "approximate coords (database, not play-tested); Scalding Whelp" },
        { type = "turnin", qid = 706, title = "Fiery Blaze Enchantments", x = 53.8, y = 43.3, note = "approximate coords (database, not play-tested); Sigrun Ironhew" },
        { type = "note", text = "Fly to Southshore", note = "Polestar route note; Next when done" },
        { type = "turnin", qid = 1052, title = "Down the Scarlet Path", mapID = 1424, x = 51.5, y = 58.4, note = "approximate coords (database, not play-tested); Raleigh the Devout" },
        { type = "note", text = "Get the flight path: Aerie Peak", note = "Polestar route note; Next when done" },
        { type = "turnin", qid = 1449, title = "To The Hinterlands", mapID = 1425, x = 11.8, y = 46.8, note = "approximate coords (database, not play-tested); Falstad Wildhammer" },
        { type = "accept", qid = 1450, title = "Gryphon Master Talonaxe", mapID = 1425, x = 11.8, y = 46.8, note = "approximate coords (database, not play-tested); Falstad Wildhammer" },
        { type = "turnin", qid = 1450, title = "Gryphon Master Talonaxe", mapID = 1425, x = 9.8, y = 44.5, note = "approximate coords (database, not play-tested); Gryphon Master Talonaxe" },
        { type = "accept", qid = 1451, title = "Rhapsody Shindigger", mapID = 1425, x = 9.8, y = 44.5, note = "approximate coords (database, not play-tested); Gryphon Master Talonaxe" },
        { type = "accept", qid = 2988, title = "Witherbark Cages", mapID = 1425, x = 9.8, y = 44.5, note = "approximate coords (database, not play-tested); Gryphon Master Talonaxe" },
        { type = "accept", qid = 2880, title = "Troll Necklace Bounty", mapID = 1425, x = 14.8, y = 44.6, note = "approximate coords (database, not play-tested); Fraggar Thundermantle" },
        { type = "turnin", qid = 1451, title = "Rhapsody Shindigger", mapID = 1425, x = 26.9, y = 48.6, note = "approximate coords (database, not play-tested); Rhapsody Shindigger" },
        { type = "collect", qid = 2988, obj = 1, title = "First Witherbark Cage", mapID = 1425, x = 23.3, y = 58.8, note = "approximate coords (database, not play-tested)" },
        { type = "collect", qid = 2988, obj = 2, title = "Second Witherbark Cage", mapID = 1425, x = 23.1, y = 58.8, note = "approximate coords (database, not play-tested)" },
        { type = "collect", qid = 2988, obj = 3, title = "Third Witherbark Cage", mapID = 1425, x = 32.0, y = 57.3, note = "approximate coords (database, not play-tested)" },
        { type = "collect", qid = 2880, title = "Troll Tribal Necklace", mapID = 1425, x = 63.1, y = 76.2, note = "approximate coords (database, not play-tested); Vilebranch Blood Drinker" },
        { type = "turnin", qid = 2988, title = "Witherbark Cages", mapID = 1425, x = 9.8, y = 44.5, note = "approximate coords (database, not play-tested); Gryphon Master Talonaxe" },
        { type = "turnin", qid = 2880, title = "Troll Necklace Bounty", mapID = 1425, x = 14.8, y = 44.6, note = "approximate coords (database, not play-tested); Fraggar Thundermantle" },
        { type = "accept", qid = 2881, title = "Troll Necklace Bounty", mapID = 1425, x = 14.8, y = 44.6, note = "approximate coords (database, not play-tested); Fraggar Thundermantle" },
        { type = "turnin", qid = 2881, title = "Troll Necklace Bounty", mapID = 1425, x = 14.8, y = 44.6, note = "approximate coords (database, not play-tested); Fraggar Thundermantle" },
        { type = "note", text = "Fly to Menethil Harbor", note = "Polestar route note; Next when done" },
        { type = "turnin", qid = 623, title = "Akiris by the Bundle", mapID = 1445, x = 68.8, y = 53.2, note = "approximate coords (database, not play-tested); Privateer Groy" },
        { type = "note", text = "Fly to Ratchet", note = "Polestar route note; Next when done" },
        { type = "turnin", qid = 4488, title = "Summon Felsteed", mapID = 1413, x = 62.6, y = 35.5, class = { "WARLOCK" }, note = "approximate coords (database, not play-tested); Strahad Farsan" },
        { type = "accept", qid = 4490, title = "Summon Felsteed", mapID = 1413, x = 62.6, y = 35.5, class = { "WARLOCK" }, note = "approximate coords (database, not play-tested); Strahad Farsan" },
        { type = "turnin", qid = 4490, title = "Summon Felsteed", mapID = 1413, x = 62.6, y = 35.5, class = { "WARLOCK" }, note = "approximate coords (database, not play-tested); Strahad Farsan" },
        { type = "note", text = "Fly to Nijel's Point", note = "Polestar route note; Next when done" },
    },
})
