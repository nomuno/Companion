-- Companion module: Quest Helper. Uses the shared Companion table (this file is a separate addon; `ns` is not shared automatically).
-- Dungeons.lua: Horde dungeon quests for the 1-30 dungeons, plus the 'Dungeon quests'
-- pickup-only dungeon guides (Dungeons settings page, /comp dungeons) and the entrance ready check.
--
-- Data from the Questie Classic database (quest/npc/object/item DBs): quest IDs, names,
-- min/quest levels, givers and their coords, prerequisite chains and objectives.
-- Entrances from Questie's dungeons.lua (classic values). uiMapIDs from Questie's
-- areaIdToUiMapId: Orgrimmar 1454, Thunder Bluff 1456, Undercity 1458, the Barrens 1413,
-- Silverpine 1421, Ashenvale 1440, Stonetalon 1442.
-- Dungeon level ranges are not in Questie: TODO verify (common classic ranges used).
-- Quests whose giver is inside the dungeon (or that start from a drop there) use the
-- entrance as their location and have inside = true.

local ns = _G.Companion
if not ns then return end
local ORG, TB, UC, BAR, SP, ASH, STM = 1454, 1456, 1458, 1413, 1421, 1440, 1442

ns.DUNGEONS = {
    {
        code = "RFC", name = "Ragefire Chasm", levels = { 13, 18 }, -- TODO verify range
        zone = "Orgrimmar", mapID = ORG, x = 52.6, y = 49.0,
        places = { "Ragefire Chasm" },
        quests = {
            { id = 5726, name = "Hidden Enemies", min = 9, level = 12, giver = "Thrall", mapID = ORG, x = 31.7, y = 37.8,
              objective = "Lieutenant's Insignia (chain start, outside the dungeon)" },
            { id = 5727, name = "Hidden Enemies (part 2)", min = 9, level = 12, giver = "Thrall", mapID = ORG, x = 31.7, y = 37.8,
              pre = { 5726 }, objective = "talk to Thrall (chain step)" },
            { id = 5728, name = "Hidden Enemies (part 3)", min = 9, level = 16, giver = "Thrall", mapID = ORG, x = 31.7, y = 37.8,
              pre = { 5727 }, objective = "kill Bazzalan and Jergosh the Invoker" },
            { id = 5761, name = "Slaying the Beast", min = 9, level = 16, giver = "Neeru Fireblade", mapID = ORG, x = 49.5, y = 50.6,
              objective = "Taragaman the Hungerer's Heart" },
            { id = 5723, name = "Testing an Enemy's Strength", min = 9, level = 15, giver = "Rahauro", mapID = TB, x = 70.1, y = 29.5,
              objective = "kill Ragefire Troggs and Ragefire Shamans" },
            { id = 5722, name = "Searching for the Lost Satchel", min = 9, level = 16, giver = "Rahauro", mapID = TB, x = 70.1, y = 29.5,
              objective = "find Maur Grimtotem's body" },
            { id = 5724, name = "Returning the Lost Satchel", min = 9, level = 16, giver = "Maur Grimtotem (inside)", mapID = ORG, x = 52.6, y = 49.0,
              inside = true, pre = { 5722 }, objective = "bring the satchel back to Rahauro (Thunder Bluff)" },
            { id = 5725, name = "The Power to Destroy...", min = 9, level = 16, giver = "Varimathras", mapID = UC, x = 56.2, y = 92.2,
              objective = "Spells of Shadow and Incantations from the Nether" },
        },
    },
    {
        code = "WC", name = "Wailing Caverns", levels = { 17, 24 }, -- TODO verify range
        zone = "The Barrens", mapID = BAR, x = 46.0, y = 36.5,
        places = { "Wailing Caverns" },
        quests = {
            { id = 1489, name = "Hamuul Runetotem", min = 12, level = 16, giver = "Tonga Runetotem", mapID = BAR, x = 52.3, y = 31.9,
              pre = { 880 }, objective = "chain to Leaders of the Fang (needs Altered Beings done)" },
            { id = 1490, name = "Nara Wildmane", min = 12, level = 16, giver = "Arch Druid Hamuul Runetotem", mapID = TB, x = 78.6, y = 28.6,
              pre = { 1489 }, objective = "talk to Nara Wildmane (chain step)" },
            { id = 914, name = "Leaders of the Fang", min = 11, level = 22, giver = "Nara Wildmane", mapID = TB, x = 75.7, y = 31.6,
              pre = { 1490 }, objective = "Gems of Cobrahn, Anacondra, Pythas and Serpentis" },
            { id = 962, name = "Serpentbloom", min = 14, level = 18, giver = "Apothecary Zamah", mapID = TB, x = 22.8, y = 20.9,
              objective = "Serpentbloom" },
            { id = 1486, name = "Deviate Hides", min = 13, level = 17, giver = "Nalpak", mapID = BAR, x = 46.0, y = 35.7,
              objective = "Deviate Hides" },
            { id = 1487, name = "Deviate Eradication", min = 15, level = 21, giver = "Ebru", mapID = BAR, x = 46.0, y = 35.7,
              objective = "kill Deviate Ravagers, Vipers, Shamblers and Dreadfangs" },
            { id = 959, name = "Trouble at the Docks", min = 14, level = 18, giver = "Crane Operator Bigglefuzz", mapID = BAR, x = 63.1, y = 37.6,
              objective = "99-Year-Old Port" },
            { id = 1491, name = "Smart Drinks", min = 13, level = 18, giver = "Mebok Mizzyrix", mapID = BAR, x = 62.4, y = 37.6,
              pre = { 865 }, objective = "Wailing Essence (needs Raptor Horns done)" },
            { id = 6981, name = "The Glowing Shard", min = 15, level = 26, giver = "drops in the dungeon", mapID = BAR, x = 46.0, y = 36.5,
              inside = true, objective = "take the shard to Falla Sagewind (Barrens 48.2, 32.8)" },
        },
    },
    {
        code = "SFK", name = "Shadowfang Keep", levels = { 22, 30 }, -- TODO verify range
        zone = "Silverpine Forest", mapID = SP, x = 44.8, y = 67.8,
        places = { "Shadowfang Keep" },
        quests = {
            { id = 1098, name = "Deathstalkers in Shadowfang", min = 18, level = 25, giver = "High Executor Hadrec", mapID = SP, x = 43.4, y = 40.9,
              objective = "find Deathstalker Vincent inside" },
            { id = 1014, name = "Arugal Must Die", min = 18, level = 27, giver = "Dalar Dawnweaver", mapID = SP, x = 44.2, y = 39.8,
              objective = "Head of Arugal" },
            { id = 1013, name = "The Book of Ur", min = 16, level = 26, giver = "Keeper Bel'dugur", mapID = UC, x = 53.7, y = 54.5,
              objective = "The Book of Ur" },
        },
    },
    {
        code = "BFD", name = "Blackfathom Deeps", levels = { 24, 32 }, -- TODO verify range
        zone = "Ashenvale", mapID = ASH, x = 14.5, y = 14.2,
        places = { "Blackfathom Deeps" },
        quests = {
            { id = 6562, name = "Trouble in the Deeps", min = 17, level = 22, giver = "Tsunaman", mapID = STM, x = 47.4, y = 64.2,
              objective = "talk to Je'neu Sancrea at Zoram'gar (Ashenvale 11.6, 34.3)" },
            { id = 6563, name = "The Essence of Aku'Mai", min = 17, level = 22, giver = "Je'neu Sancrea", mapID = ASH, x = 11.6, y = 34.3,
              pre = { 6562 }, objective = "Sapphires of Aku'Mai" },
            { id = 6921, name = "Amongst the Ruins", min = 21, level = 27, giver = "Je'neu Sancrea", mapID = ASH, x = 11.6, y = 34.3,
              objective = "Fathom Core" },
            { id = 6564, name = "Allegiance to the Old Gods", min = 17, level = 22, giver = "Damp Note (drops inside)", mapID = ASH, x = 14.5, y = 14.2,
              inside = true, objective = "take the note to Je'neu Sancrea" },
            { id = 6565, name = "Allegiance to the Old Gods (part 2)", min = 17, level = 26, giver = "Je'neu Sancrea", mapID = ASH, x = 11.6, y = 34.3,
              pre = { 6564 }, objective = "kill Lorgus Jett" },
            { id = 6561, name = "Blackfathom Villainy", min = 18, level = 27, giver = "Argent Guard Thaelrid (inside)", mapID = ASH, x = 14.5, y = 14.2,
              inside = true, objective = "Head of Kelris" },
        },
    },
}


-- ===================== ALLIANCE (0.40) =====================
-- Alliance quests from the Questie Classic DB (race mask includes Human/Dwarf/Night Elf/Gnome),
-- entrances from Questie's classic dungeons. The Hall of Thanes is new in WoW Forever
-- (ForeverDB /dungeon/3065: levels 13-20, entrance Ironforge 77.1, 51.3); no quests known yet.
-- faction on a dungeon or quest hides it from the other faction (nil = both).
local SW, IF, DAR, WF, DM_, DK = 1453, 1455, 1457, 1436, 1426, 1439
for _, d in ipairs(ns.DUNGEONS) do
    if d.code == "RFC" or d.code == "SFK" then d.faction = "Horde" end
    for _, q in ipairs(d.quests) do
        if not q.faction and ({ [5726]=1,[5727]=1,[5728]=1,[5761]=1,[5723]=1,[5722]=1,[5724]=1,[5725]=1,
            [1489]=1,[1490]=1,[914]=1,[962]=1,[1098]=1,[1014]=1,[1013]=1,[6562]=1,[6563]=1,[6921]=1,[6564]=1,[6565]=1,[6561]=1 })[q.id] then
            q.faction = "Horde"
        end
    end
end
local function Extra(code, list) for _, d in ipairs(ns.DUNGEONS) do if d.code == code then for _, q in ipairs(list) do table.insert(d.quests, q) end end end end
Extra("WC", {

})
Extra("BFD", {
            { id = 1198, name = "In Search of Thaelrid", min = 18, level = 24, giver = "Dawnwatcher Shaedlass", mapID = 1457, x = 55.4, y = 25.0, faction = "Alliance", objective = "Seek out Argent Guard Thaelrid in Blackfathom Deeps." },
            { id = 1199, name = "Twilight Falls", min = 20, level = 25, giver = "Argent Guard Manados", mapID = 1457, x = 55.2, y = 24.0, faction = "Alliance", objective = "Bring 10 Twilight Pendants to Argent Guard Manados in Darnassus." },
            { id = 1200, name = "Blackfathom Villainy", min = 18, level = 27, giver = "Argent Guard Thaelrid (inside)", mapID = 1440, x = 14.5, y = 14.2, faction = "Alliance", pre = { 1198 }, inside = true, objective = "Bring the head of Twilight Lord Kelris to Dawnwatcher Selgorm in Darnassus." },
            { id = 1275, name = "Researching the Corruption", min = 18, level = 24, giver = "Gershala Nightwhisper", mapID = 1439, x = 38.3, y = 43.0, faction = "Alliance", pre = { 3765 }, objective = "Gershala Nightwhisper in Auberdine wants 8 Corrupt Brain stems." },
            { id = 971, name = "Knowledge in the Deeps", min = 10, level = 23, giver = "Gerrig Bonegrip", mapID = 1455, x = 50.8, y = 5.6, faction = "Alliance", objective = "Bring the Lorgalis Manuscript to Gerrig Bonegrip in the Forlorn Cavern in Ironforge." },
})
table.insert(ns.DUNGEONS, {
    code = "DM", name = "The Deadmines", levels = { 17, 26 }, faction = "Alliance", -- TODO verify range
    zone = "Westfall", mapID = WF, x = 42.6, y = 71.7, places = { "The Deadmines", "Moonbrook" },
    quests = {
            { id = 166, name = "The Defias Brotherhood", min = 14, level = 22, giver = "Gryan Stoutmantle", mapID = 1436, x = 56.3, y = 47.5, faction = "Alliance", pre = { 155 }, objective = "Kill Edwin VanCleef and bring his head to Gryan Stoutmantle." },
            { id = 167, name = "Oh Brother. . .", min = 15, level = 20, giver = "Wilder Thistlenettle", mapID = 1453, x = 65.4, y = 21.2, faction = "Alliance", objective = "Bring Foreman Thistlenettle's Explorers' League Badge to Wilder Thistlenettle in Stormwind" },
            { id = 168, name = "Collecting Memories", min = 14, level = 18, giver = "Wilder Thistlenettle", mapID = 1453, x = 65.4, y = 21.2, faction = "Alliance", objective = "Retrieve 4 Miners' Union Cards and return them to Wilder Thistlenettle in Stormwind." },
            { id = 2040, name = "Underground Assault", min = 15, level = 20, giver = "Shoni the Shilent", mapID = 1453, x = 55.5, y = 12.5, faction = "Alliance", objective = "Retrieve the Gnoam Sprecklesprocket from the Deadmines and return it to Shoni the Shilent " },
            { id = 214, name = "Red Silk Bandanas", min = 14, level = 17, giver = "Scout Riell", mapID = 1436, x = 56.7, y = 47.4, faction = "Alliance", pre = { 155 }, objective = "Scout Riell at the Sentinel Hill Tower wants you to bring her 10 Red Silk Bandanas." },
            { id = 65, name = "The Defias Brotherhood", min = 14, level = 18, giver = "Gryan Stoutmantle", mapID = 1436, x = 56.3, y = 47.5, faction = "Alliance", objective = "chain start: talk to Wiley in Lakeshire (leads to the Deadmines finale)" },
            { id = 373, name = "The Unsent Letter", min = 16, level = 22, giver = "An Unsent Letter (drops from Edwin VanCleef)", mapID = WF, x = 42.6, y = 71.7, faction = "Alliance", inside = true, objective = "deliver the letter to Baros Alexston in Stormwind" },
            { id = 389, name = "Bazil Thredd", min = 16, level = 22, giver = "Baros Alexston", mapID = SW, x = 49.2, y = 30.3, faction = "Alliance", pre = { 373 }, objective = "speak with Warden Thelwater in the Stockade" },
            { id = 2041, name = "Speak with Shoni", min = 15, level = 15, giver = "Gnoarn", mapID = IF, x = 69.2, y = 50.6, faction = "Alliance", objective = "breadcrumb to Underground Assault (Shoni in Stormwind)" },
    },
})
table.insert(ns.DUNGEONS, {
    code = "HOT", name = "The Hall of Thanes", levels = { 13, 20 }, faction = "Alliance", forever = true,
    zone = "Ironforge", mapID = IF, x = 77.1, y = 51.3, places = { "The Hall of Thanes", "Hall of Thanes" },
    quests = {},  -- new in WoW Forever; no quests known yet (the recorder will capture them)
})
table.insert(ns.DUNGEONS, {
    code = "STOCKS", name = "The Stockade", levels = { 22, 30 }, faction = "Alliance", -- TODO verify range
    zone = "Stormwind City", mapID = SW, x = 40.5, y = 55.9, places = { "The Stockade", "Stormwind Stockade" },
    quests = {
            { id = 392, name = "The Curious Visitor", min = 16, level = 29, giver = "Warden Thelwater", mapID = SW, x = 41.1, y = 58.1, faction = "Alliance", pre = { 391 }, objective = "Sealed Description of Thredd's Visitor to Baros Alexston" },
            { id = 393, name = "Shadow of the Past", min = 16, level = 29, giver = "Baros Alexston", mapID = SW, x = 49.2, y = 30.3, faction = "Alliance", pre = { 392 }, objective = "bring the description to Master Mathias Shaw" },
            { id = 377, name = "Crime and Punishment", min = 22, level = 26, giver = "Councilman Millstipe", mapID = 1431, x = 71.9, y = 47.8, faction = "Alliance", objective = "Councilman Millstipe of Darkshire wants you to bring him the hand of Dextren Ward." },
            { id = 378, name = "The Fury Runs Deep", min = 22, level = 27, giver = "Motley Garmason", mapID = 1437, x = 49.7, y = 18.2, faction = "Alliance", pre = { 303 }, objective = "Motley Garmason wants Kam Deepfury's head brought to him at Dun Modr." },
            { id = 386, name = "What Comes Around...", min = 22, level = 25, giver = "Guard Berton", mapID = 1433, x = 26.3, y = 46.6, faction = "Alliance", objective = "Bring the head of Targorr the Dread to Guard Berton in Lakeshire." },
            { id = 387, name = "Quell The Uprising", min = 22, level = 26, giver = "Warden Thelwater", mapID = 1453, x = 41.1, y = 58.1, faction = "Alliance", objective = "Warden Thelwater of Stormwind wants you to kill 10 Defias Prisoners, 8 Defias Convicts, an" },
            { id = 388, name = "The Color of Blood", min = 22, level = 26, giver = "Nikova Raskol", mapID = 1453, x = 69.9, y = 39.0, faction = "Alliance", objective = "Nikova Raskol of Stormwind wants you to collect 10 Red Wool Bandanas." },
            { id = 391, name = "The Stockade Riots", min = 16, level = 29, giver = "Warden Thelwater", mapID = 1453, x = 41.1, y = 58.1, faction = "Alliance", pre = { 389 }, objective = "Kill Bazil Thredd and bring his head back to Warden Thelwater at the Stockade." },
    },
})
table.insert(ns.DUNGEONS, {
    code = "GNOMER", name = "Gnomeregan", levels = { 24, 33 }, faction = "Alliance", -- TODO verify range
    zone = "Dun Morogh", mapID = DM_, x = 24.4, y = 39.8, places = { "Gnomeregan" },
    quests = {
            { id = 2904, name = "A Fine Mess", min = 24, level = 30, giver = "Kernobee (inside)", mapID = 1426, x = 24.4, y = 39.8, faction = "Alliance", inside = true, objective = "Escort Kernobee to the Clockwerk Run exit and then report to Scooty in Booty Bay." },
            { id = 2922, name = "Save Techbot's Brain!", min = 20, level = 26, giver = "Tinkmaster Overspark", mapID = 1455, x = 69.5, y = 50.3, faction = "Alliance", pre = { 2923 }, objective = "Bring Techbot's Memory Core to Tinkmaster Overspark in Ironforge." },
            { id = 2923, name = "Tinkmaster Overspark", min = 20, level = 26, giver = "Brother Sarno", mapID = 1453, x = 40.5, y = 31.0, faction = "Alliance", objective = "Speak with Tinkmaster Overspark in Ironforge." },
            { id = 2924, name = "Essential Artificials", min = 24, level = 30, giver = "Klockmort Spannerspan", mapID = 1455, x = 67.9, y = 46.1, faction = "Alliance", objective = "Bring 12 Essential Artificials to Klockmort Spannerspan in Ironforge." },
            { id = 2925, name = "Klockmort's Essentials", min = 24, level = 30, giver = "Mathiel", mapID = 1457, x = 59.5, y = 45.4, faction = "Alliance", objective = "Speak with Klockmort Spannerspan in Ironforge." },
            { id = 2926, name = "Gnogaine", min = 20, level = 27, giver = "Ozzie Togglevolt", mapID = 1426, x = 45.9, y = 49.4, faction = "Alliance", pre = { 2927 }, objective = "Use the Empty Leaden Collection Phial on Irradiated Invaders or Irradiated Pillagers to co" },
            { id = 2927, name = "The Day After", min = 20, level = 27, giver = "Gnoarn", mapID = 1455, x = 69.2, y = 50.5, faction = "Alliance", objective = "Speak with Ozzie Togglevolt in Kharanos." },
            { id = 2928, name = "Gyrodrillmatic Excavationators", min = 20, level = 30, giver = "Shoni the Shilent", mapID = 1453, x = 55.5, y = 12.5, faction = "Alliance", objective = "Bring twenty-four Robo-mechanical Guts to Shoni in Stormwind." },
            { id = 2929, name = "The Grand Betrayal", min = 25, level = 35, giver = "High Tinker Mekkatorque", mapID = 1455, x = 68.8, y = 49.0, faction = "Alliance", objective = "Venture to Gnomeregan and kill Mekgineer Thermaplugg. Return to High Tinker Mekkatorque wh" },
            { id = 2930, name = "Data Rescue", min = 25, level = 30, giver = "Master Mechanic Castpipe", mapID = 1455, x = 69.8, y = 48.1, faction = "Alliance", objective = "Bring a Prismatic Punch Card to Master Mechanic Castpipe in Ironforge." },
            { id = 2931, name = "Castpipe's Task", min = 25, level = 28, giver = "Gaxim Rustfizzle", mapID = 1442, x = 59.5, y = 67.2, faction = "Alliance", objective = "Speak with Master Mechanic Castpipe in Ironforge." },
            { id = 2962, name = "The Only Cure is More Green Glow", min = 20, level = 30, giver = "Ozzie Togglevolt", mapID = 1426, x = 45.9, y = 49.4, faction = "Alliance", pre = { 2926 }, objective = "Travel to Gnomeregan and bring back High Potency Radioactive Fallout. Be warned, the fallo" },
    },
})


-- ===================== NEW IN WOW FOREVER (0.54) =====================
-- From /workspace/new_dungeons_research.md (foreverchanges.pro, Wowhead, conquestcapped, ForeverDB;
-- beta build 1.60.1.70374). All quests are quest level 31 / 33, minimum level 24.
-- Coordinates marked "approximate coords, not play-tested" are zone-level estimates or Classic
-- Questie spawns; entrances are unverified. Quests with no known ID are 'note' steps (extra).
local WET, HB, ALT, RR = 1437, 1424, 1416, 1433
local APX = " (approximate coords, not play-tested)"
local EX_X, EX_Y = 38.8, 50.5      -- Whelgar's Excavation Site (Prospector Whelgar, Classic spawn)
local DAL_X, DAL_Y = 18.5, 78.0    -- Dalaran dome, Alterac Mountains
table.insert(ns.DUNGEONS, {
    code = "EXCAV", name = "Excavation Site: Wetlands", levels = { 24, 31 }, forever = true,
    zone = "Wetlands", mapID = WET, x = EX_X, y = EX_Y, places = { "Excavation Site: Wetlands", "Excavation Site" },
    entranceNote = "Entrance at Whelgar's Excavation Site; exact spot unverified" .. APX .. ".",
    extra = {
        { faction = "Horde", step = { type = "note", title = "Optional: Dragonmaw Rumors (95663)", mapID = WET, x = 47.0, y = 30.0,
            note = "breadcrumb to Open the Maw; giver unverified. If you have it, turn it in to the Deathstalker Agent in the hills above the Dragonmaw camp" .. APX } },
    },
    quests = {
        { id = 95682, name = "Open the Maw", min = 24, level = 31, giver = "Deathstalker Agent, hills near the entrance" .. APX, mapID = WET, x = 41.0, y = 47.0, faction = "Horde", objective = "kill in the Excavation Site (Dragonmaw)" },
        { id = 95697, name = "Changing Tastes", min = 24, level = 31, giver = "Borstan, cooking trainer (Orgrimmar)", mapID = ORG, x = 57.3, y = 53.4, faction = "Horde", objective = "cooking ingredients from the dungeon for Borstan" },
        { id = 95664, name = "Elder Knowledge", min = 24, level = 31, giver = "Titan Relic (last boss drop)", mapID = WET, x = EX_X, y = EX_Y, faction = "Horde", inside = true, objective = "take the Titan Relic to Elder Rise, Thunder Bluff" },
        { id = 95772, name = "Songblade Search", min = 24, level = 31, giver = "Dorin Songblade, Lakeshire" .. APX, mapID = RR, x = 25.6, y = 46.6, faction = "Alliance", objective = "find Daewyn inside" },
        { id = 95795, name = "Fallen in the Fen", min = 24, level = 31, giver = "Daewyn's body (inside)", mapID = WET, x = EX_X, y = EX_Y, faction = "Alliance", inside = true, pre = { 95772 }, objective = "return to Dorin Songblade, Lakeshire" },
        { id = 95647, name = "Lost in the Thicket Things", min = 24, level = 31, giver = "Caitlin Grassman, Menethil Harbor" .. APX, mapID = WET, x = 11.8, y = 58.6, faction = "Alliance", pre = { 95737 }, objective = "find Ardin Grassman inside" },
        { id = 95809, name = "Heartwoven", min = 24, level = 31, giver = "Ardin Grassman (inside)", mapID = WET, x = EX_X, y = EX_Y, faction = "Alliance", inside = true, pre = { 95647 }, objective = "return to Caitlin Grassman" },
        { id = 95646, name = "Horrors in the Highland", min = 24, level = 31, giver = "Rethiel the Greenwarden" .. APX .. "; may need The Greenwarden / Blisters on the Land first (unverified)", mapID = WET, x = 56.2, y = 40.6, faction = "Alliance", objective = "horrors inside the Excavation Site" },
        { id = 95810, name = "Lost Relic Carry", min = 24, level = 31, giver = "Titan Relic (last boss drop)", mapID = WET, x = EX_X, y = EX_Y, faction = "Alliance", inside = true, objective = "take the Titan Relic to Prospector Whelgar" },
    },
})
table.insert(ns.DUNGEONS, {
    code = "DAL", name = "City of Dalaran", levels = { 24, 33 }, forever = true,
    zone = "Alterac Mountains", mapID = ALT, x = DAL_X, y = DAL_Y, places = { "City of Dalaran", "Dalaran" },
    entranceNote = "Enter through the Dalaran sewers; you need the Dalaran Sewer Key, but one key-holder can open the gate for the group. The Image of Archmage Modera stands outside. Entrance spot unverified" .. APX .. ".",
    extra = {
        { faction = "Horde", step = { type = "note", title = "Prison Break In and Key to the City (Grimy Key)", mapID = HB, x = 62.0, y = 20.0,
            note = "Magus Wordeen Voidglare, Tarren Mill; no quest IDs known" .. APX } },
        { faction = "Horde", step = { type = "note", title = "Dalaran Patrols: 6 Dalaran Summoners, 12 Elemental Slaves", mapID = ALT, x = 20.0, y = 75.0,
            note = "from Magus Wordeen Voidglare; no quest ID known" .. APX } },
        { faction = "Horde", step = { type = "note", title = "Blood in the Streets: turn in to the Image of Archmage Modera", mapID = ALT, x = DAL_X, y = DAL_Y,
            note = "from Voidglare, turned in outside Dalaran; no quest ID known. Next comes Heart of Disruption (gives the Sewer Key)" .. APX } },
        { faction = "Alliance", step = { type = "note", title = "An Alarming Request (Emissary Jacques)", mapID = HB, x = 50.5, y = 57.0,
            note = "Southshore; needed before Modera offers her quests and the key. No quest ID known" .. APX } },
    },
    quests = {
        { id = 96984, name = "Heart of Disruption", min = 24, level = 33, giver = "end of the Voidglare chain; turn in to Voidglare in Tarren Mill for the Dalaran Sewer Key" .. APX, mapID = ALT, x = DAL_X, y = DAL_Y, faction = "Horde", objective = "Dalaran Sewer Key chain finale" },
        { id = 96986, name = "The Grave Knight", min = 24, level = 33, giver = "Melisara, Tarren Mill" .. APX, mapID = HB, x = 62.6, y = 20.7, faction = "Horde", objective = "The Grave Knight inside Dalaran" },
        { id = 96988, name = "Source of Power", min = 24, level = 33, giver = "Doctor Martin Felben, Apothecarium" .. APX, mapID = UC, x = 46.6, y = 74.1, faction = "Horde", objective = "for Doctor Martin Felben" },
        { id = 96987, name = "Opportunistic Education", min = 24, level = 33, giver = "Rexxie Copperclutch, sewer entrance" .. APX, mapID = ALT, x = DAL_X, y = DAL_Y, faction = "Horde", objective = "for Rexxie Copperclutch" },
        { id = 92458, name = "Heart of Disruption", min = 24, level = 33, giver = "Image of Archmage Modera, outside the entrance (after An Alarming Request)" .. APX, mapID = ALT, x = DAL_X, y = DAL_Y, faction = "Alliance", objective = "inside Dalaran, for Modera" },
        { id = 92457, name = "Starving Arcane", min = 24, level = 33, giver = "Image of Archmage Modera, outside the entrance" .. APX, mapID = ALT, x = DAL_X, y = DAL_Y, faction = "Alliance", objective = "inside Dalaran, for Modera" },
        { id = 92489, name = "Power Overwhelming", min = 24, level = 33, giver = "High Sorcerer Andromath, Mage Quarter" .. APX, mapID = SW, x = 37.5, y = 81.7, faction = "Alliance", objective = "for High Sorcerer Andromath" },
        { id = 92456, name = "A Green Sample", min = 24, level = 33, giver = "Shylamiir, The Park" .. APX, mapID = SW, x = 15.3, y = 49.3, faction = "Alliance", objective = "for Shylamiir" },
    },
})

local function PlayerFaction() local ok, f = pcall(UnitFactionGroup, "player") return ok and f or nil end
function ns.DungeonForPlayer(d)
    local f = PlayerFaction()
    return not (d.faction and f and d.faction ~= f)
end
local function QuestForPlayer(q)
    local f = PlayerFaction()
    return not (q.faction and f and q.faction ~= f)
end

local byCode = {}
for _, d in ipairs(ns.DUNGEONS) do byCode[d.code] = d end
ns.DUNGEON_BY_CODE = byCode

-- 0.52: the per-dungeon checkboxes, hideDungeonSteps and the Dungeon quests window are gone.
-- Dungeons are now loaded as pickup-only guides from the Dungeons settings page.
-- Old saved keys (db.dungeons, db.hideDungeonSteps) are cleared at login.
ns:On("LOGIN", function() if ns.db then ns.db.dungeons = nil ns.db.hideDungeonSteps = nil end end)

local function safe(fn, ...)
    if type(fn) ~= "function" then return nil end
    local ok, a, b = pcall(fn, ...)
    if ok then return a, b end
end

local function Done(id)
    local G = ns.guide
    if G and G.IsTurnedIn then return G.IsTurnedIn(id) and true or false end
    return false
end

-- status: "done" | "log" (in quest log; .complete when objectives are done) |
--         "available" (prereqs met, level ok) | "later" (level too low) | "locked" (prereqs missing)
function ns.DungeonQuestStatus(q)
    if Done(q.id) then return "done" end
    local logged = ns.quests and ns.quests[q.id]
    if logged then return "log", logged.complete end
    for _, p in ipairs(q.pre or {}) do
        if not Done(p) then return "locked" end
    end
    local level = safe(UnitLevel, "player") or 1
    if level < (q.min or 1) then return "later" end
    return "available"
end

function ns.DungeonSummary(d)
    local out = { log = {}, available = {}, done = {}, later = {}, locked = {} }
    for _, q in ipairs(d.quests) do
        if QuestForPlayer(q) then
        local st, complete = ns.DungeonQuestStatus(q)
        table.insert(out[st], { quest = q, complete = complete })
        end
    end
    return out
end

local function ZoneName(mapID)
    local info = C_Map and safe(C_Map.GetMapInfo, mapID)
    if type(info) == "table" and info.name then return info.name end
    for _, d in ipairs(ns.DUNGEONS) do if d.mapID == mapID then return d.zone end end
    local names = { [1454] = "Orgrimmar", [1456] = "Thunder Bluff", [1458] = "Undercity", [1413] = "The Barrens",
        [1421] = "Silverpine Forest", [1440] = "Ashenvale", [1442] = "Stonetalon Mountains" }
    return names[mapID] or ("map " .. tostring(mapID))
end
ns.DungeonZoneName = ZoneName

-- ===================== PRINT =====================
local function QLine(entry, status)
    local q = entry.quest
    if status == "log" then
        return string.format("  |cffffd100[have]|r %s%s", q.name, entry.complete and " |cff20ff20(objectives done)|r" or "")
    elseif status == "available" then
        return string.format("  |cff20ff20[get]|r %s - %s, %s (%.1f, %.1f)%s", q.name, q.giver, ZoneName(q.mapID), q.x, q.y, q.inside and " (inside)" or "")
    elseif status == "done" then
        return "  |cff888888[done]|r " .. q.name
    elseif status == "later" then
        return string.format("  |cff888888[level %d]|r %s", q.min or 1, q.name)
    end
end

function ns.PrintDungeons()
    for _, d in ipairs(ns.DUNGEONS) do if ns.DungeonForPlayer(d) then
        local s = ns.DungeonSummary(d)
        print(string.format("|cffffd100%s|r (%d-%d, %s %.1f, %.1f)", d.name, d.levels[1], d.levels[2], d.zone, d.x, d.y))
        for _, st in ipairs({ "log", "available", "done", "later" }) do
            for _, e in ipairs(s[st]) do print(QLine(e, st)) end
        end
        if #d.quests == 0 then print("  |cff888888no quests known yet (new in WoW Forever)|r") end
    end end
end

-- ===================== PREREQUISITE CHAINS (0.53) =====================
-- Full steps (accept, objectives, turn-in) for quests that must be turned in before a dungeon
-- quest can be picked up. Coordinates come from our leveling guides (Barrens, Redridge 20-23,
-- Westfall, Wetlands 31-32, Stonetalon, Ashenvale, Loch Modan, Darkshore, Duskwood, Gnomeregan
-- 32-34) unless the note says "approximate" (then Questie's database spawns).
-- pre = the quests this one needs turned in first (walked recursively).
local function A(id, t, m, x, y, n, lv) return { type = "accept", qid = id, title = t, mapID = m, x = x, y = y, note = n, minLevel = lv } end
local function T(id, t, m, x, y, n) return { type = "turnin", qid = id, title = t, mapID = m, x = x, y = y, note = n } end
ns.DUNGEON_PREREQS = {
    [870] = { A(870, "The Forgotten Pools", BAR, 52.3, 31.9, "Tonga Runetotem", 10),
        { type = "complete", qid = 870, title = "Explore the Forgotten Pools", mapID = BAR, x = 45.1, y = 22.5 },
        T(870, "The Forgotten Pools", BAR, 52.3, 31.9, "Tonga Runetotem") },
    [877] = { pre = { 870 }, A(877, "The Stagnant Oasis", BAR, 52.3, 31.9, "Tonga Runetotem", 10),
        { type = "complete", qid = 877, title = "Bubbling Fissure", mapID = BAR, x = 55.6, y = 42.8, note = "the Stagnant Oasis" },
        T(877, "The Stagnant Oasis", BAR, 52.3, 31.9, "Tonga Runetotem") },
    [880] = { pre = { 877 }, A(880, "Altered Beings", BAR, 52.3, 31.9, "Tonga Runetotem", 10),
        { type = "collect", qid = 880, title = "Altered Snapjaw Shells", mapID = BAR, x = 50.1, y = 40.8, note = "turtles in the Stagnant Oasis" },
        T(880, "Altered Beings", BAR, 52.3, 31.9, "Tonga Runetotem") },
    [865] = { A(865, "Raptor Horns", BAR, 62.4, 37.6, "Mebok Mizzyrix, Ratchet", 13),
        { type = "collect", qid = 865, title = "Intact Raptor Horns", mapID = BAR, x = 52.4, y = 36.7, note = "Sunscale Scytheclaws" },
        T(865, "Raptor Horns", BAR, 62.4, 37.6, "Mebok Mizzyrix, Ratchet") },
    [1489] = { pre = { 880 }, A(1489, "Hamuul Runetotem", BAR, 52.3, 31.9, "Tonga Runetotem", 12),
        T(1489, "Hamuul Runetotem", TB, 78.6, 28.6, "Arch Druid Hamuul Runetotem, Elder Rise") },
    [1490] = { pre = { 1489 }, A(1490, "Nara Wildmane", TB, 78.6, 28.6, "Arch Druid Hamuul Runetotem", 12),
        T(1490, "Nara Wildmane", TB, 75.7, 31.6, "Nara Wildmane") },
    [5726] = { A(5726, "Hidden Enemies", ORG, 31.7, 37.8, "Thrall, Grommash Hold", 9),
        { type = "collect", qid = 5726, title = "Lieutenant's Insignia", mapID = 1411, x = 53.0, y = 9.5,
          note = "Burning Blade Fanatics and Apprentices at Skull Rock, Durotar (approximate)" },
        T(5726, "Hidden Enemies", ORG, 31.7, 37.8, "Thrall") },
    [5727] = { pre = { 5726 }, A(5727, "Hidden Enemies", ORG, 31.7, 37.8, "Thrall", 9),
        { type = "complete", qid = 5727, title = "Hidden Enemies", mapID = ORG, x = 31.7, y = 37.8, note = "talk to Thrall" },
        T(5727, "Hidden Enemies", ORG, 31.7, 37.8, "Thrall") },
    [6562] = { A(6562, "Trouble in the Deeps", STM, 47.4, 64.2, "Tsunaman, Sun Rock Retreat", 17),
        T(6562, "Trouble in the Deeps", ASH, 11.6, 34.3, "Je'neu Sancrea, Zoram'gar Outpost") },
    [3765] = { A(3765, "The Corruption Abroad", SW, 21.4, 55.8, "Argos Nightwhisper", 18),
        T(3765, "The Corruption Abroad", DK, 38.3, 43.0, "Gershala Nightwhisper, Auberdine") },
    [65] = { A(65, "The Defias Brotherhood", WF, 56.3, 47.5, "Gryan Stoutmantle, Sentinel Hill", 14),
        T(65, "The Defias Brotherhood", 1433, 26.5, 45.4, "Wiley the Black, Lakeshire") },
    [132] = { pre = { 65 }, A(132, "The Defias Brotherhood", 1433, 21.4, 45.3, "Wiley the Black", 14),
        T(132, "The Defias Brotherhood", WF, 56.3, 47.5, "Gryan Stoutmantle") },
    [135] = { pre = { 132 }, A(135, "The Defias Brotherhood", WF, 56.3, 47.5, "Gryan Stoutmantle", 14),
        T(135, "The Defias Brotherhood", SW, 78.3, 70.7, "Master Mathias Shaw, Old Town") },
    [141] = { pre = { 135 }, A(141, "The Defias Brotherhood", SW, 78.3, 70.7, "Master Mathias Shaw", 14),
        T(141, "The Defias Brotherhood", WF, 56.3, 47.5, "Gryan Stoutmantle") },
    [142] = { pre = { 141 }, A(142, "The Defias Brotherhood", WF, 56.3, 47.5, "Gryan Stoutmantle", 14),
        { type = "complete", qid = 142, obj = 1, title = "The Defias Brotherhood", mapID = WF, x = 45.1, y = 69.3, note = "objective area (ForeverDB quest map)" },
        T(142, "The Defias Brotherhood", WF, 56.3, 47.5, "Gryan Stoutmantle") },
    [155] = { pre = { 142 }, A(155, "The Defias Brotherhood", WF, 55.7, 47.5, "The Defias Traitor, Sentinel Hill", 14),
        { type = "complete", qid = 155, title = "Escort the Defias Traitor", mapID = WF, x = 42.5, y = 71.7, note = "he leads you to Moonbrook (approximate)" },
        T(155, "The Defias Brotherhood", WF, 56.3, 47.5, "Gryan Stoutmantle") },
    [303] = { A(303, "The Dark Iron War", 1437, 49.7, 18.2, "Motley Garmason, Dun Modr", 25),
        { type = "complete", qid = 303, title = "The Dark Iron War", mapID = 1437, x = 60.0, y = 23.9, note = "Dark Iron camp east of Dun Modr (ForeverDB quest map)" },
        T(303, "The Dark Iron War", 1437, 49.7, 18.2, "Motley Garmason") },
    [2923] = { A(2923, "Tinkmaster Overspark", SW, 40.5, 31.0, "Brother Sarno, Cathedral Square", 20),
        T(2923, "Tinkmaster Overspark", IF, 69.5, 50.3, "Tinkmaster Overspark, Tinker Town") },
    [2927] = { A(2927, "The Day After", IF, 69.2, 50.5, "Gnoarn, Tinker Town", 20),
        T(2927, "The Day After", DM_, 45.9, 49.4, "Ozzie Togglevolt, Kharanos") },
    [95737] = { A(95737, "Seeking Caitlin", ASH, 35.0, 48.6, "Llana, Ashenvale (approximate coords, not play-tested)", 24),
        T(95737, "Seeking Caitlin", 1437, 11.8, 58.6, "Caitlin Grassman, Menethil Harbor (approximate coords, not play-tested)") },
    [2926] = { pre = { 2927 }, A(2926, "Gnogaine", DM_, 45.9, 49.4, "Ozzie Togglevolt", 20),
        { type = "collect", qid = 2926, title = "Full Leaden Collection Phial", mapID = DM_, x = 20.8, y = 35.6,
          note = "use the phial on Irradiated Invaders outside Gnomeregan (approximate)" },
        T(2926, "Gnogaine", DM_, 45.9, 49.4, "Ozzie Togglevolt") },
}

-- ===================== DUNGEON GUIDES (0.52) =====================
-- One pickup-only guide per dungeon (per faction when its quests differ by faction): accept
-- steps for every quest picked up outside, in prerequisite order. Chain follow-ups and quests
-- that need an outside quest first use requires = { pre } so they show once that is turned in.
-- No turn-in or objective steps: the dungeon itself is a group effort.
ns.DUNGEON_GUIDES = {}
local function Sorted(quests)
    local byId, out, seen = {}, {}, {}
    for _, q in ipairs(quests) do byId[q.id] = q end
    local function visit(q)
        if seen[q.id] then return end
        seen[q.id] = true
        for _, p in ipairs(q.pre or {}) do if byId[p] then visit(byId[p]) end end
        table.insert(out, q)
    end
    for _, q in ipairs(quests) do visit(q) end
    return out
end
local function BuildDungeonGuide(d, faction)
    local steps, emitted = {}, {}
    local P = ns.DUNGEON_PREREQS
    local function Emit(id)   -- full prerequisite chain, deepest first
        if emitted[id] or not P[id] then return end
        emitted[id] = true
        for _, p in ipairs(P[id].pre or {}) do Emit(p) end
        for _, st in ipairs(P[id]) do
            local c = {} for k, v in pairs(st) do c[k] = v end
            c.prereq = true
            table.insert(steps, c)
        end
    end
    for _, e in ipairs(d.extra or {}) do
        if not (faction and e.faction and e.faction ~= faction) then
            local c = {} for k, v in pairs(e.step) do c[k] = v end
            table.insert(steps, c)
        end
    end
    for _, q in ipairs(Sorted(d.quests)) do
        if not q.inside and not (faction and q.faction and q.faction ~= faction) then
            local gated = false
            for _, p in ipairs(q.pre or {}) do if P[p] then Emit(p) else gated = true end end
            if P[q.id] then Emit(q.id)   -- an unlock step itself: fully guided above
            else
                table.insert(steps, { type = "accept", qid = q.id, title = q.name, mapID = q.mapID, x = q.x, y = q.y,
                    minLevel = q.min, requires = gated and q.pre or nil, class = q.class, race = q.race,
                    note = q.giver .. (gated and " (unlocks after its earlier quest)" or "") })
            end
        end
    end
    local inside = {}
    for _, q in ipairs(d.quests) do
        if q.inside and not (faction and q.faction and q.faction ~= faction) then table.insert(inside, q.name) end
    end
    local entrance = string.format("%s entrance: %s (%.1f, %.1f).", d.name, d.zone, d.x, d.y)
    if #inside > 0 then entrance = entrance .. " Picked up inside: " .. table.concat(inside, ", ") .. "." end
    if d.entranceNote then entrance = entrance .. " " .. d.entranceNote end
    if #d.quests == 0 then entrance = entrance .. " No quests known yet (new in WoW Forever)." end
    table.insert(steps, { type = "note", title = entrance, mapID = d.mapID, x = d.x, y = d.y })
    local name = "Dungeon: " .. d.name .. ((faction and not d.faction) and (" (" .. faction .. ")") or "")
    ns:RegisterGuide(name, { faction = faction, minLevel = d.levels[1], maxLevel = d.levels[2], mapID = d.mapID,
        isDungeon = true, dungeonCode = d.code, steps = steps })
    table.insert(ns.DUNGEON_GUIDES, name)
end
for _, d in ipairs(ns.DUNGEONS) do
    if d.faction then BuildDungeonGuide(d, d.faction)
    else
        local h, a = false, false
        for _, q in ipairs(d.quests) do
            if q.faction == "Horde" then h = true elseif q.faction == "Alliance" then a = true else h, a = true, true end
        end
        if h or #d.quests == 0 then BuildDungeonGuide(d, "Horde") end
        if a or #d.quests == 0 then BuildDungeonGuide(d, "Alliance") end
    end
end

ns:AddCommand("dungeons", function(rest)
    ns.PrintDungeons()
    if rest ~= "list" and ns.OpenSettings then ns.OpenSettings("guide") end
end)

-- ===================== READY CHECK =====================
-- Entering a dungeon (or its entrance area) with obtainable quests still missing.
local lastWarn = {}
local WARN_CD = 600

function ns.DungeonAt(zone, subzone)
    for _, d in ipairs(ns.DUNGEONS) do
        for _, p in ipairs(d.places) do
            if (p == zone or p == subzone) and ns.DungeonForPlayer(d) then return d end
        end
    end
end

function ns.DungeonReadyCheck()
    local d = ns.DungeonAt(safe(GetRealZoneText) or safe(GetZoneText), safe(GetSubZoneText))
    if not d then return nil end
    local now = (GetTime and GetTime()) or 0
    if lastWarn[d.code] and now - lastWarn[d.code] < WARN_CD then return nil end
    local s = ns.DungeonSummary(d)
    local missing
    for _, e in ipairs(s.available) do
        if not e.quest.inside then missing = e.quest break end
    end
    if not missing then return nil end
    lastWarn[d.code] = now
    if ns.Say then
        ns:Say("dungeonMissing", { priority = true, vars = { quest = missing.name, dungeon = d.name },
            fallback = "Wait! We don't have " .. missing.name .. " yet." })
    end
    return missing, d
end

for _, ev in ipairs({ "ZONE_CHANGED", "ZONE_CHANGED_NEW_AREA", "ZONE_CHANGED_INDOORS" }) do
    ns:On(ev, function() pcall(ns.DungeonReadyCheck) end)
end
