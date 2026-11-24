-- Companion: zone and subzone lore (0.44). Keys are the names GetZoneText()/GetSubZoneText() return.
-- Clips: auto_lore_<slug>.ogg (voice_lines.tsv). Keep texts free of {placeholders}.
local _, ns = ...
ns.zoneLore = {
    -- ===== Horde: Durotar =====
    ["Durotar"] = "Durotar. Thrall named this land for his father, Durotan, when he led the freed orcs to Kalimdor. It's harsh and red, but it's theirs.",
    ["Valley of Trials"] = "The Valley of Trials. Young orcs and trolls prove themselves here before they're sent out into the world.",
    ["Sen'jin Village"] = "Sen'jin Village is named for the old Darkspear witch doctor Sen'jin. He gave his life when Thrall helped his people escape to Kalimdor.",
    ["Echo Isles"] = "The Echo Isles were the Darkspear trolls' home, until the witch doctor Zalazane turned to dark voodoo and enslaved his own people.",
    ["Razor Hill"] = "Razor Hill. A fortified orc town that keeps watch over Durotar's coast.",
    ["Tiragarde Keep"] = "Tiragarde Keep. Kul Tiran soldiers built it after Admiral Proudmoore's fleet attacked Durotar, and some of them never left.",
    ["Thunder Ridge"] = "Thunder Ridge. Storms and thunder lizards, and very little shelter. Keep your head down.",
    ["Drygulch Ravine"] = "Drygulch Ravine. The harpies have made it their roost, so watch the cliffs.",
    ["Skull Rock"] = "Skull Rock. The Burning Blade cultists hide in these caves, still serving the demons the orcs fought to escape.",
    ["Orgrimmar"] = "Orgrimmar, the capital of the Horde. Thrall built it and named it for Orgrim Doomhammer, the Warchief who came before him.",
    ["Ragefire Chasm"] = "Ragefire Chasm runs right under Orgrimmar. Troglodytes and Burning Blade cultists lurk in its burning caves.",
    -- ===== Horde: Mulgore =====
    ["Mulgore"] = "Mulgore, the tauren homeland. Cairne Bloodhoof led the tribes here after the orcs helped them drive back the centaur.",
    ["Camp Narache"] = "Camp Narache. Young tauren learn the ways of the hunt and the Earth Mother here.",
    ["Bloodhoof Village"] = "Bloodhoof Village, home of Cairne Bloodhoof's own tribe, in the heart of the plains.",
    ["Thunder Bluff"] = "Thunder Bluff. The tauren built their city on top of these mesas, and they ride lifts up and down the cliffs.",
    ["Brambleblade Ravine"] = "Brambleblade Ravine. Quilboar have dug in here among the thorns.",
    ["The Venture Co. Mine"] = "The Venture Company. Goblins who'll strip any land bare for profit, sacred ground or not.",
    ["Palemane Rock"] = "Palemane Rock. The Palemane gnolls hole up here and raid the plains.",
    ["Red Cloud Mesa"] = "Red Cloud Mesa, where the tauren raise their young under the open sky.",
    -- ===== Horde: Tirisfal / Undercity =====
    ["Tirisfal Glades"] = "Tirisfal Glades was farmland of the kingdom of Lordaeron, until the Scourge swept through it. Now the Forsaken claim what's left.",
    ["Deathknell"] = "Deathknell. Forsaken who break free of the Lich King's control wake here, in the old graveyard.",
    ["Brill"] = "Brill was a human town once. The Forsaken took it over, and the inn still keeps its doors open.",
    ["Agamand Mills"] = "Agamand Mills. The Agamand family fell to the plague, and now they walk their own fields as undead.",
    ["Undercity"] = "The Undercity lies beneath the ruins of Lordaeron's capital. Lady Sylvanas rules the Forsaken from its old crypts and sewers.",
    ["Scarlet Monastery"] = "The Scarlet Monastery. The Scarlet Crusade hates all undead and trusts no one, living or not.",
    -- ===== Horde: Silverpine =====
    ["Silverpine Forest"] = "Silverpine Forest. Gray woods between Lordaeron and the great wall of Gilneas. Worgen prowl here now.",
    ["The Sepulcher"] = "The Sepulcher. The Forsaken hold this crypt as their outpost in Silverpine.",
    ["Pyrewood Village"] = "Pyrewood Village. The villagers are cursed, and when night falls they turn into worgen.",
    ["Ambermill"] = "Ambermill. Mages of Dalaran have taken over the town, and they don't want visitors.",
    ["Shadowfang Keep"] = "Shadowfang Keep. The archmage Arugal summoned the worgen here, and Baron Silverlaine's keep fell under his madness.",
    -- ===== Horde: Barrens =====
    ["The Barrens"] = "The Barrens. Dry grassland all the way across central Kalimdor, full of centaur, quilboar and harpies.",
    ["The Crossroads"] = "The Crossroads. The Horde built this fort where the Barrens' main roads meet, and it's been fighting off raiders ever since.",
    ["Ratchet"] = "Ratchet, a goblin port of the Steamwheedle Cartel. Gold matters more than banners here.",
    ["Camp Taurajo"] = "Camp Taurajo, a tauren camp on the southern Barrens.",
    ["Lushwater Oasis"] = "Lushwater Oasis. The oases of the Barrens appeared along with the druids' work in the caverns below, and something is wrong with them now.",
    ["The Forgotten Pools"] = "The Forgotten Pools, another of the Barrens' strange oases.",
    ["Wailing Caverns"] = "The Wailing Caverns. Druids of the Fang went down there to heal the land, and the Emerald Dream's nightmare turned them.",
    ["Northwatch Hold"] = "Northwatch Hold, a Theramore fort on the Barrens' eastern coast.",
    ["Razorfen Kraul"] = "Razorfen Kraul. The quilboar live inside giant thorny vines. They say they grew from the body of the demigod Agamaggan.",
    ["Razorfen Downs"] = "Razorfen Downs. The Scourge has crept into the quilboar's home, and their dead don't stay buried.",
    -- ===== Horde: Stonetalon / Ashenvale / Hillsbrad / Thousand Needles =====
    ["Stonetalon Mountains"] = "The Stonetalon Mountains. Peaks sacred to the druids, and the Venture Company is cutting them bare.",
    ["Sun Rock Retreat"] = "Sun Rock Retreat, a Horde haven high in the Stonetalon peaks.",
    ["Stonetalon Peak"] = "Stonetalon Peak, where the night elf druids keep their watch over the mountains.",
    ["Ashenvale"] = "Ashenvale, the ancient forest of the night elves. Here Grom Hellscream slew the demigod Cenarius, and the war over these trees has never stopped.",
    ["Splintertree Post"] = "Splintertree Post. Warsong orcs log Ashenvale from here, and the sentinels hate them for it.",
    ["Astranaar"] = "Astranaar, a night elf town on an island in the heart of Ashenvale.",
    ["Zoram'gar Outpost"] = "Zoram'gar Outpost, a Horde foothold on Ashenvale's shore.",
    ["Blackfathom Deeps"] = "Blackfathom Deeps was once a temple to Elune. Now it's sunken, and naga and the Twilight's Hammer fill it.",
    ["Hillsbrad Foothills"] = "Hillsbrad Foothills. Rolling farmland split between Southshore and Tarren Mill, and both sides want it.",
    ["Tarren Mill"] = "Tarren Mill. The Forsaken hold it now, just across the hills from Southshore.",
    ["Southshore"] = "Southshore, a human town on the coast of Hillsbrad that stands against the Forsaken.",
    ["Durnholde Keep"] = "Durnholde Keep. Thrall was raised there as a slave and a gladiator, before he broke free.",
    ["Thousand Needles"] = "Thousand Needles. A canyon of stone spires so tall they cast the whole valley in shadow.",
    ["Freewind Post"] = "Freewind Post. The tauren built it on top of the needles, linked by rope bridges.",
    ["The Shimmering Flats"] = "The Shimmering Flats. A huge salt flat where gnomes and goblins race their machines.",
    -- ===== Skyborne (WoW Forever) =====
    ["Zephras Isle"] = "Zephras Isle, home of the Skyborne. I don't know much of its story yet, so let's learn it together.",
    -- ===== Alliance: Elwynn / Stormwind =====
    ["Elwynn Forest"] = "Elwynn Forest, the green heart of the kingdom of Stormwind. It was burned in the First War and has been rebuilt since.",
    ["Northshire Valley"] = "Northshire Valley. The abbey's priests train new recruits here before sending them out into Elwynn.",
    ["Northshire Abbey"] = "Northshire Abbey, where the Light's priests and paladins train Stormwind's newest heroes.",
    ["Goldshire"] = "Goldshire, the busy crossroads town of Elwynn. Everyone ends up at the Lion's Pride Inn eventually.",
    ["Fargodeep Mine"] = "Fargodeep Mine. Kobolds have taken over the tunnels. You no take candle!",
    ["Jasperlode Mine"] = "Jasperlode Mine, another mine lost to kobolds.",
    ["Eastvale Logging Camp"] = "Eastvale Logging Camp, on Elwynn's eastern edge near Redridge.",
    ["Stormwind City"] = "Stormwind City. The orcs destroyed it in the First War, and the stonemasons rebuilt it. Many of them were never paid, and that's how the Defias began.",
    ["The Stockade"] = "The Stockade, Stormwind's prison. The prisoners have rioted and taken it over.",
    -- ===== Alliance: Dun Morogh / Ironforge / Loch Modan =====
    ["Dun Morogh"] = "Dun Morogh. Snowy mountain valleys in the land of the dwarves and gnomes.",
    ["Coldridge Valley"] = "Coldridge Valley. Young dwarves and gnomes train here, with troggs and troll raiders close by.",
    ["Kharanos"] = "Kharanos, a cozy dwarf town. The Thunderbrew brewery keeps it warm.",
    ["Ironforge"] = "Ironforge, carved into the heart of the mountain. King Magni Bronzebeard rules from the great forge.",
    ["Gnomeregan"] = "Gnomeregan was the gnomes' great city, until troggs rose up from below. Mekkatorque flooded it with radiation to stop them, and it's been lost ever since.",
    ["Gol'Bolar Quarry"] = "Gol'Bolar Quarry, a dwarven quarry overrun by troggs.",
    ["Loch Modan"] = "Loch Modan. The great Stonewrought Dam holds back the loch, and the dwarves guard it closely.",
    ["Thelsamar"] = "Thelsamar, the dwarf town on Loch Modan's road.",
    ["Stonewrought Dam"] = "The Stonewrought Dam. The dwarves built it to hold back the whole loch.",
    ["Algaz Station"] = "Algaz Station guards the pass between Dun Morogh and Loch Modan.",
    -- ===== Alliance: Teldrassil / Darnassus / Darkshore =====
    ["Teldrassil"] = "Teldrassil. The night elf druids grew this great tree without the blessing of the dragons, and its roots don't feel quite right.",
    ["Shadowglen"] = "Shadowglen, where young night elves begin their training among the branches.",
    ["Dolanaar"] = "Dolanaar, a quiet night elf village on Teldrassil.",
    ["Darnassus"] = "Darnassus, the night elf capital, high in the boughs of Teldrassil. Tyrande Whisperwind rules from the Temple of the Moon.",
    ["Rut'theran Village"] = "Rut'theran Village, at the foot of Teldrassil, where boats leave for Darkshore.",
    ["Darkshore"] = "Darkshore. A long, misty coast of ancient night elf ruins, and the furbolgs here have been corrupted.",
    ["Auberdine"] = "Auberdine, the night elves' harbor town on Darkshore.",
    -- ===== Alliance: Westfall / Redridge / Duskwood =====
    ["Westfall"] = "Westfall was Stormwind's farmland. The farms were left empty and the Defias Brotherhood moved in.",
    ["Sentinel Hill"] = "Sentinel Hill. The People's Militia holds out here against the Defias.",
    ["Moonbrook"] = "Moonbrook. The Defias own this town now, and the Deadmines lie beneath it.",
    ["The Deadmines"] = "The Deadmines. Edwin VanCleef leads the Defias from a hidden harbor deep inside the mine.",
    ["Jangolode Mine"] = "Jangolode Mine, held by the Defias.",
    ["Saldean's Farm"] = "Saldean's Farm, one of the last families still farming in Westfall.",
    ["Redridge Mountains"] = "The Redridge Mountains. Blackrock orcs and gnolls raid down from the hills.",
    ["Lakeshire"] = "Lakeshire, a lakeside town that keeps getting raided by orcs and gnolls.",
    ["Stonewatch Keep"] = "Stonewatch Keep. The Blackrock orcs have taken it over.",
    ["Duskwood"] = "Duskwood. This forest was once part of Elwynn, but darkness fell over it, and now the dead and the worgen roam.",
    ["Darkshire"] = "Darkshire. The Night Watch guards this town from the horrors of the woods.",
    ["Raven Hill"] = "Raven Hill. The cemetery here doesn't keep its dead in the ground.",
    ["Raven Hill Cemetery"] = "Raven Hill Cemetery. The dead don't rest here.",
    -- ===== Alliance: Wetlands / Stranglethorn =====
    ["Wetlands"] = "The Wetlands. Swamps between Ironforge and Lordaeron, and the Dragonmaw orcs still hold Grim Batol.",
    ["Menethil Harbor"] = "Menethil Harbor, a human port where ships sail for Kalimdor and Theramore.",
    ["Dun Modr"] = "Dun Modr, a dwarven hold in the north of the Wetlands, overrun by the Dark Iron dwarves.",
    ["Whelgar's Excavation Site"] = "Whelgar's Excavation Site, where dwarf explorers are digging up the past.",
    ["Stranglethorn Vale"] = "Stranglethorn Vale. Jungle and ruins of the Gurubashi troll empire. It's beautiful, and it'll try to kill you.",
    ["Booty Bay"] = "Booty Bay, a goblin pirate port carved into a cliff. Watch your purse.",
    ["Grom'gol Base Camp"] = "Grom'gol Base Camp, the Horde's base in Stranglethorn.",
    ["Nesingwary's Expedition"] = "Nesingwary's Expedition. Hemet Nesingwary hunts the biggest game in the jungle.",
    ["Rebel Camp"] = "Rebel Camp, on the jungle's northern edge.",
    -- ===== Alliance Ashenvale =====
    ["Maestra's Post"] = "Maestra's Post, a sentinel outpost in northern Ashenvale.",
    -- ===== 0.71: levels 30-60 =====
    ["Aerie Peak"] = "Aerie Peak, the Wildhammer dwarf hold high in the Hinterlands, with gryphons on every ledge.",
    ["Altar of Storms"] = "The Altar of Storms in the Burning Steppes, a warlock's rise where the ground itself feels listened-to.",
    ["Alterac Mountains"] = "The Alterac Mountains. The old human kingdom of Alterac betrayed the Alliance in the Second War, and ogres live in its ruins now.",
    ["Andorhal"] = "Andorhal, once Lordaeron's granary town. The Scourge still holds the ruins, and the grain is long since poison.",
    ["Angor Fortress"] = "Angor Fortress, a Shadowforge hold in the Badlands. The Dark Irons do not like visitors.",
    ["Arathi Highlands"] = "Arathi Highlands. Rolling hills that once belonged to the kingdom of Stromgarde, now split between the Horde, the Alliance, and everyone in between.",
    ["Azshara"] = "Azshara. Cliffs and ruins named for the elven queen who called the Sundering down. The naga have never really left.",
    ["Badlands"] = "The Badlands. A dry, cracked waste east of Khaz Modan, full of coyotes, dragons, and dwarves digging up things better left buried.",
    ["Bay of Storms"] = "The Bay of Storms, a wide, wreck-strewn water in Azshara. The naga feel at home here.",
    ["Blackchar Cave"] = "Blackchar Cave, a dark hole in the Searing Gorge. What lives in there likes the heat.",
    ["Blackrock Depths"] = "Blackrock Depths, the Dark Iron city under the mountain, ruled from the Shadowforge and the dark iron throne.",
    ["Blackrock Mountain"] = "Blackrock Mountain, the great volcano between the Searing Gorge and the Burning Steppes, and a door to more trouble than I can count.",
    ["Blackrock Spire"] = "Blackrock Spire, where orcs of the Blackrock and Dragonmaw clans hold the upper halls of the mountain.",
    ["Blackrock Stronghold"] = "Blackrock Stronghold, an orc fortress in the Steppes, still flying the old Horde's colors in all but name.",
    ["Blasted Lands"] = "The Blasted Lands. When the Dark Portal opened, it tore this place apart. The ground still looks like the wound never closed.",
    ["Bloodvenom Post"] = "Bloodvenom Post, a Horde camp in Felwood, right in the sickest part of the woods.",
    ["Brackenwall Village"] = "Brackenwall Village, the ogre-built Horde town in western Dustwallow Marsh.",
    ["Burning Steppes"] = "The Burning Steppes. Blackrock's doorstep: a volcanic plain of ash, orcs, and the black dragonflight.",
    ["Caer Darrow"] = "Caer Darrow, an island keep on Darrowmere Lake. Scholomance is under it, and the barov family paid dearly for that.",
    ["Camp Boff"] = "Camp Boff, a small ogre camp in the Badlands. They are not known for their hospitality.",
    ["Camp Mojache"] = "Camp Mojache, the Horde's tauren camp on the river in Feralas. Grab the flight path.",
    ["Caverns of Time"] = "The Caverns of Time, a bronze dragon shrine hidden in the Tanaris mountains, where the past is not as still as it looks.",
    ["Cenarion Hold"] = "Cenarion Hold, the Cenarion Circle's fortress in Silithus, standing between the desert and the hives.",
    ["Chillwind Camp"] = "Chillwind Camp, the Alliance and Argent Dawn camp at the south edge of the Western Plaguelands.",
    ["Corin's Crossing"] = "Corin's Crossing, a ruined crossroads in the Eastern Plaguelands, thick with the Scourge.",
    ["Crown Guard Tower"] = "Crown Guard Tower, an Argent Dawn tower watching the road through the Eastern Plaguelands.",
    ["Dalson's Tears"] = "Dalson's Tears, a ruined farm and another Scourge cauldron in the Western Plaguelands.",
    ["Darkwhisper Gorge"] = "Darkwhisper Gorge, a deep, fel-touched cut in southern Winterspring. Something down there is listening.",
    ["Darrowshire"] = "Darrowshire, a little town that stood against the Scourge and was lost anyway. The dead here remember.",
    ["Deadwind Pass"] = "Deadwind Pass. A dead, windy ravine between Duskwood and the Swamp of Sorrows, and the tower of Karazhan still watches the road.",
    ["Desolace"] = "Desolace. A blasted, ashen land the night elves once called a garden. The centaur clans still war over what's left.",
    ["Dire Maul"] = "Dire Maul is Eldre'Thalas, a night elf city ruined in the Sundering and now split between ogres, satyrs, and the old ghosts of the Highborne.",
    ["Dreadmaul Hold"] = "Dreadmaul Hold, an ogre fortress in the Blasted Lands, close enough to the Portal to be a bad idea.",
    ["Dreadmaul Rock"] = "Dreadmaul Rock, an ogre mound in the Burning Steppes, under a constant rain of ash.",
    ["Dustwallow Marsh"] = "Dustwallow Marsh. A foggy stretch of mud and crocolisks on Kalimdor's east coast, with Theramore on one shore and ogres in the west.",
    ["Eastern Plaguelands"] = "The Eastern Plaguelands. The worst of the Scourge's work on Lordaeron: plague cauldrons, ruined towns, and Stratholme at the end of the road.",
    ["Eastwall Tower"] = "Eastwall Tower, another Argent Dawn lookout in the Eastern Plaguelands.",
    ["Emerald Sanctuary"] = "The Emerald Sanctuary, an Emerald Circle camp in southern Felwood, trying to heal a forest that does not want to heal.",
    ["Ethel Rethor"] = "Ethel Rethor, a lonely stretch of Desolace shoreline, with old elven ruins in the water.",
    ["Everlook"] = "Everlook, a goblin town in the snows of Winterspring. Warm rooms, high prices, and a very welcome fire.",
    ["Faldir's Cove"] = "Faldir's Cove, a hidden beach under the Arathi cliffs, used by sailors who don't want to be found.",
    ["Fallow Sanctuary"] = "The Fallow Sanctuary, a lost, overgrown corner of the Swamp of Sorrows.",
    ["Feathermoon Stronghold"] = "Feathermoon Stronghold, a night elf keep on an island off the Feralas coast.",
    ["Felstone Field"] = "Felstone Field, a plagued farm in the west, still watched by the Scourge cauldron.",
    ["Felwood"] = "Felwood. This was once a living night elf forest. The Legion's corruption turned it sick and green, and it hasn't recovered.",
    ["Feralas"] = "Feralas. Ancient night elf rainforest on Kalimdor's west coast, older than the Sundering, with the ruined city of Eldre'Thalas at its heart.",
    ["Fire Plume Ridge"] = "Fire Plume Ridge, the volcanic heart of Un'Goro, still breathing smoke and fire elementals.",
    ["Firewatch Ridge"] = "Firewatch Ridge, a burned overlook in the Searing Gorge, watched by Dark Iron patrols.",
    ["Flame Crest"] = "Flame Crest, a Horde camp on a burned rise in the Burning Steppes.",
    ["Frostsaber Rock"] = "Frostsaber Rock, where the frostsabers den in Winterspring, and the night elf huntresses know them by name.",
    ["Gadgetzan"] = "Gadgetzan, a goblin town in the Tanaris sand. If you can pay, they can find it.",
    ["Gahrron's Withering"] = "Gahrron's Withering, the eastern cauldron farm in the Western Plaguelands. Nothing good grows here.",
    ["Ghost Walker Post"] = "Ghost Walker Post, a tauren camp watching the roads and the centaur in central Desolace.",
    ["Go'Shek Farm"] = "Go'Shek Farm, a Horde farm in the Highlands, right on the edge of trouble.",
    ["Golakka Hot Springs"] = "Golakka Hot Springs, steaming pools in western Un'Goro, watched by elementals and the odd brave researcher.",
    ["Gordunni Outpost"] = "The Gordunni Outpost. Ogres have claimed this part of Feralas, and they do not share.",
    ["Grimesilt Dig Site"] = "The Grimesilt Dig Site, where dwarves keep digging in the Gorge no matter how hot it gets.",
    ["Hammerfall"] = "Hammerfall, a Horde town built from an internment camp in the Arathi Highlands.",
    ["Hearthglen"] = "Hearthglen, a Scarlet Crusade hold in the Western Plaguelands. They fight the Scourge, and nearly everyone else.",
    ["Hive'Ashi"] = "Hive'Ashi, the northern silithid hive in Silithus, close enough to Cenarion Hold to keep everyone awake.",
    ["Hive'Regal"] = "Hive'Regal, a great silithid hive in eastern Silithus. Do not go in lightly.",
    ["Hive'Zora"] = "Hive'Zora, the western silithid hive in Silithus, no friendlier than the others.",
    ["Irontree Woods"] = "Irontree Woods. The trees here walk, and they are not gentle about it.",
    ["Isle of Dread"] = "The Isle of Dread, south of Feralas, where naga and old ruins wait in the spray.",
    ["Jadefire Run"] = "Jadefire Run, a satyr camp in Felwood. They have been corrupting this forest for a long time.",
    ["Jaedenar"] = "Jaedenar. The Shadow Council and the Legion took this ruined barrow, and the name itself is a curse.",
    ["Jintha'Alor"] = "Jintha'Alor, a great Vilebranch troll city terraced into the Hinterlands cliffs.",
    ["Karazhan"] = "Karazhan, Medivh's tower in Deadwind Pass. The lights are still on. That is not comforting.",
    ["Kargath"] = "Kargath, the Horde's outpost in the Badlands, named for a great orc warrior.",
    ["Kodo Graveyard"] = "The Kodo Graveyard, where the great beasts come to die. The earth is white with their bones.",
    ["Lake Kel'Theril"] = "Lake Kel'Theril, a frozen Highborne ruin in Winterspring. The ice has a memory.",
    ["Lakkari Tar Pits"] = "The Lakkari Tar Pits in northern Un'Goro. Things fall in. They do not always climb out.",
    ["Lethlor Ravine"] = "Lethlor Ravine, a blackened canyon in the eastern Badlands, watched by the black dragonflight.",
    ["Light's Hope Chapel"] = "Light's Hope Chapel, the Argent Dawn's hold in the Eastern Plaguelands. It's a small light in a very dark land.",
    ["Lost Rigger Cove"] = "Lost Rigger Cove, a Southsea pirate hideout on the Tanaris shore.",
    ["Mannoroc Coven"] = "Mannoroc Coven. Demons crawl over these ruins, and the ground itself feels wrong.",
    ["Maraudon"] = "Maraudon. A vast cavern temple of the earth, claimed by the Maraudine centaur and fouled by the princess Theradras.",
    ["Marshal's Refuge"] = "Marshal's Refuge, a cave camp in Un'Goro Crater, full of goblins, gnomes, and very stubborn researchers.",
    ["Mazthoril"] = "Mazthoril, a blue dragon cave in Winterspring. They are not always in the mood for visitors.",
    ["Molten Core"] = "The Molten Core, Ragnaros's prison and palace under Blackrock, where the Firelord was summoned and never sent back.",
    ["Moonglade"] = "Moonglade. A hidden, moonlit valley the druids kept safe through every war. Nighthaven sits quiet under the trees.",
    ["Morgan's Vigil"] = "Morgan's Vigil, an Alliance camp on the eastern edge of the Burning Steppes.",
    ["Nethergarde Keep"] = "Nethergarde Keep, a Kirin Tor and Alliance fortress watching the Dark Portal in the Blasted Lands.",
    ["Nighthaven"] = "Nighthaven, the druids' village in Moonglade. Even the inn feels like it's listening to the moon.",
    ["Nijel's Point"] = "Nijel's Point, an Alliance holdfast in the hills of northern Desolace.",
    ["Noonshade Ruins"] = "Noonshade Ruins, Wastewander bandit ground in the Tanaris waste.",
    ["Northpass Tower"] = "Northpass Tower, the northern Argent Dawn tower on the Plaguelands road.",
    ["Owl Wing Thicket"] = "Owl Wing Thicket, a quiet, wooded hollow in Winterspring, if anything under these trees stays quiet.",
    ["Pillar of Ash"] = "The Pillar of Ash, a burned landmark in the Burning Steppes, easy to see and hard to like.",
    ["Plaguewood"] = "Plaguewood, a thick, sick forest in the north of the Eastern Plaguelands, in the shadow of Stratholme.",
    ["Pool of Tears"] = "The Pool of Tears, the wide water around the Sunken Temple. Watch the shore.",
    ["Refuge Pointe"] = "Refuge Pointe, the League of Arathor's camp in the Highlands.",
    ["Revantusk Village"] = "Revantusk Village, a troll port on the Hinterlands coast, loyal to the Horde.",
    ["Rise of the Defiler"] = "The Rise of the Defiler, a demon's rise in the Blasted Lands. You can feel it before you see it.",
    ["Ruins of Alterac"] = "The Ruins of Alterac. The old capital sits broken in the mountains, and Crushridge ogres live in the halls.",
    ["Ruins of Andorhal"] = "The Ruins of Andorhal. The Scourge hasn't finished with this town, and it shows.",
    ["Ruins of Eldarath"] = "The Ruins of Eldarath, a drowned Highborne city on Azshara's coast.",
    ["Ruins of Isildien"] = "The Ruins of Isildien, crumbling night elf stone deep in Feralas.",
    ["Sandsorrow Watch"] = "Sandsorrow Watch, a lonely rise over the western dunes of Tanaris.",
    ["Scholomance"] = "Scholomance, a school of necromancy beneath Caer Darrow, run by the Cult of the Damned.",
    ["Searing Gorge"] = "Searing Gorge. A burned, slag-choked canyon the Dark Iron dwarves carved under Blackrock, still coughing smoke into the sky.",
    ["Seradane"] = "Seradane, an ancient part of the Hinterlands forest the green dragons still watch.",
    ["Shadowprey Village"] = "Shadowprey Village, a troll port on Desolace's coast. It's one of the few green places left in this land.",
    ["Shadra'Alor"] = "Shadra'Alor, a troll temple in the Hinterlands dedicated to the spider loa Shadra.",
    ["Shatter Scar Vale"] = "Shatter Scar Vale, where infernals fell during the Third War and the ground never cooled.",
    ["Shrine of Remulos"] = "The Shrine of Remulos, a druid shrine in Moonglade watched by the son of Cenarius.",
    ["Silithus"] = "Silithus. A wind-scoured waste at the foot of Ahn'Qiraj, where the silithid hive and the Twilight's Hammer both want you gone.",
    ["Sorrow Hill"] = "Sorrow Hill, a graveyard in the Western Plaguelands, close to Uther's Tomb.",
    ["Starfall Village"] = "Starfall Village, a night elf camp in Winterspring, watching the ruins and the dragons.",
    ["Steamwheedle Port"] = "Steamwheedle Port, a goblin harbor on the Tanaris coast. Smells like fish and opportunity.",
    ["Stonard"] = "Stonard, the Horde's muddy outpost in the Swamp of Sorrows.",
    ["Stratholme"] = "Stratholme. Arthas purged this city, and the Scourge and the Scarlet Crusade still fight over what's left of the streets.",
    ["Stromgarde Keep"] = "Stromgarde Keep. Once the seat of a great human kingdom; now its walls are split between syndicates, ogres, and whoever is left.",
    ["Swamp of Sorrows"] = "The Swamp of Sorrows. A green, sinking marsh on the edge of the Blasted Lands, and the trolls' Temple of Atal'Hakkar lies out in the water.",
    ["Tabetha's Farm"] = "Tabetha's Farm, a mage's home in the middle of the marsh. She does not scare easily.",
    ["Talonbranch Glade"] = "Talonbranch Glade, a night elf camp in northern Felwood, close to Timbermaw Hold.",
    ["Talrendis Point"] = "Talrendis Point, a night elf post on Azshara's western edge.",
    ["Tanaris"] = "Tanaris. An endless desert at the foot of Kalimdor, home to goblins, Wastewander bandits, and the lurking city of Zul'Farrak.",
    ["Temple of Arkkoran"] = "The Temple of Arkkoran, a sea-giant shrine on Azshara's shore.",
    ["Temple of Atal'Hakkar"] = "The Temple of Atal'Hakkar, also called the Sunken Temple. Atal'ai trolls raised it to Hakkar, and the green dragons sank it for a reason.",
    ["Terror Run"] = "Terror Run, where the biggest dinosaurs in Un'Goro make the earth shake.",
    ["Terrordale"] = "Terrordale, a broken village in the Plaguewood. The name is not an exaggeration.",
    ["Thalanaar"] = "Thalanaar, a lonely night elf post on the eastern edge of Feralas, looking out over Thousand Needles.",
    ["The Altar of Zul"] = "The Altar of Zul, a high troll altar in the Hinterlands. The view is better than the company.",
    ["The Bulwark"] = "The Bulwark, the Argent Dawn and Forsaken line holding the edge of the Western Plaguelands.",
    ["The Cauldron"] = "The Cauldron, the slag pit at the heart of the Searing Gorge. Stay on the rims if you can.",
    ["The Crystal Vale"] = "The Crystal Vale, a strange, shining hollow in northern Silithus.",
    ["The Dark Portal"] = "The Dark Portal. It was here the Horde first entered Azeroth, and the land around it has never been the same.",
    ["The Fungal Vale"] = "The Fungal Vale, a sick, mushroom-choked hollow in the Eastern Plaguelands.",
    ["The Harborage"] = "The Harborage, a quiet draenei camp hidden in the Swamp of Sorrows.",
    ["The Headland"] = "The Headland, a high ridge over the Alterac valley, with a long view and a cold wind.",
    ["The Hinterlands"] = "The Hinterlands. Forested hills east of the Plaguelands, where the Wildhammer dwarves and the Vilebranch trolls have been neighbors for far too long.",
    ["The Marshlands"] = "The Marshlands, a wet, biting stretch of southern Un'Goro, thick with raptors and plants that bite back.",
    ["The Noxious Glade"] = "The Noxious Glade, a poisoned stretch of the Eastern Plaguelands near the plaguewoods.",
    ["The Quagmire"] = "The Quagmire. Deep mud, angry crocolisks, and very few dry paths.",
    ["The Slithering Scar"] = "The Slithering Scar, a silithid hive-scar in southern Un'Goro. Watch the ground.",
    ["The Temple of Atal'Hakkar"] = "The Temple of Atal'Hakkar, also called the Sunken Temple. Atal'ai trolls raised it to Hakkar, and the green dragons sank it for a reason.",
    ["The Twin Colossals"] = "The Twin Colossals, two huge rock pillars standing over western Feralas.",
    ["Theramore Isle"] = "Theramore Isle, Jaina Proudmoore's keep on the marsh. Ships from Menethil dock here.",
    ["Thistleshrub Valley"] = "Thistleshrub Valley, a dry, thorny basin in southern Tanaris, full of elementals and very little shade.",
    ["Thorium Point"] = "Thorium Point, a Thorium Brotherhood camp overlooking the Searing Gorge. They know the Dark Irons better than anyone.",
    ["Thunder Axe Fortress"] = "Thunder Axe Fortress. The Burning Blade has a hold here, and they are not the welcoming kind.",
    ["Timbermaw Hold"] = "Timbermaw Hold, the great furbolg tunnel through the mountains between Felwood, Winterspring, and Azshara. Earn their trust, or don't go in.",
    ["Twilight Base Camp"] = "The Twilight Base Camp, where the Twilight's Hammer preaches the end of everything in the Silithus waste.",
    ["Tyr's Hand"] = "Tyr's Hand, a great Scarlet Crusade city in the east. They trust almost no one who walks in alive.",
    ["Uldaman"] = "Uldaman. A titan vault the dwarves cracked open, full of troggs, ancient stone, and secrets of the earthen.",
    ["Un'Goro Crater"] = "Un'Goro Crater. A lost, steaming basin of dinosaurs and crystal pylons, sealed off from Tanaris by the mountains around it.",
    ["Uther's Tomb"] = "Uther's Tomb, where the Lightbringer was laid to rest after the fall of Lordaeron.",
    ["Valley of Spears"] = "The Valley of Spears, a Maraudine stronghold in the canyons of Desolace.",
    ["Valor's Rest"] = "Valor's Rest, a graveyard in Silithus for those who came to hold the line against the hives.",
    ["Valormok"] = "Valormok, the Horde outpost in Azshara, under the cliffs of the old elven kingdom.",
    ["Valorwind Lake"] = "Valorwind Lake, a quiet stretch of water in the Hinterlands, when anything here can be called quiet.",
    ["Western Plaguelands"] = "The Western Plaguelands. Lordaeron's farmland, ruined by the Scourge. The fields still grow, but nothing that grows here is right.",
    ["Winterfall Village"] = "Winterfall Village, a hostile furbolg town in the Winterspring snow.",
    ["Winterspring"] = "Winterspring. High, snowy country above Felwood, quiet under the trees until the Winterfall furbolg or the blue dragons remind you it isn't.",
    ["Witch Hill"] = "Witch Hill. The farmsteads out here have a bad name, and the wildlife is worse.",
    ["Zul'Farrak"] = "Zul'Farrak, the sand troll city in western Tanaris. The Farraki have been here longer than the goblins, and they have not forgiven anyone.",
}
-- Lore that mentions one faction's capital as "home" is fine for both; nothing here is faction-tagged.

-- ===================== PLAYBACK =====================
-- First visit (per character) to a zone or listed subzone: she tells its story.
-- After that: a small chance to retell it, at most once per LORE_REPLAY_CD per place.
-- Never talks over guide lines: waits until the guide has been quiet for LORE_GUIDE_GAP seconds.
ns.defaults.zoneLore = true
ns.LORE_REPLAY_CD = 3600 * 2      -- seconds (real time) before a place can be retold
ns.LORE_REPLAY_CHANCE = 0.2
ns.LORE_GUIDE_GAP = 8
ns.LORE_RETRY = 4                 -- seconds between waits behind guide speech / combat
ns.LORE_MAX_WAIT = 60

local GUIDE_CATS = { "guideStep", "guideArrive", "guideTurnIn", "guideHearth", "guideTrain",
    "guideDone", "guideNext", "dungeonMissing", "classQuest10", "levelUp" }

local function safe(f, ...) if not f then return nil end local ok, a = pcall(f, ...) if ok then return a end end

function ns.LoreSlug(place) return ns.ZoneSlug(place) end
function ns.LoreClip(place) return "auto_lore_" .. ns.ZoneSlug(place) .. ".ogg" end

local function LoreState()
    local key = (safe(GetRealmName) or "Realm") .. "-" .. (safe(UnitName, "player") or "Unknown")
    ns.db.lore = ns.db.lore or {}
    local st = ns.db.lore[key]
    if not st then st = { seen = {} } ns.db.lore[key] = st end
    st.seen = st.seen or {}
    return st
end
ns.LoreState = LoreState

local function Now() return (time and time()) or 0 end

-- Which place's story fits where we are: the subzone if it has one, else the zone.
function ns.LorePlace()
    local sub, zone = safe(GetSubZoneText) or "", safe(GetZoneText) or ""
    if sub ~= "" and ns.zoneLore[sub] then return sub end
    if zone ~= "" and ns.zoneLore[zone] then return zone end
end

function ns.GuideSpeaking()
    local last = ns.speechState and ns.speechState.lastCat or {}
    local t = GetTime()
    for _, c in ipairs(GUIDE_CATS) do
        if last[c] and t - last[c] < ns.LORE_GUIDE_GAP then return true end
    end
    return false
end

-- Speak one place's lore now (no checks). Returns the text said.
function ns.SpeakLore(place)
    local text = place and ns.zoneLore[place]
    if not text then return nil end
    ns.loreSpokeAt = GetTime()
    return ns:Say("lore", { text = text, sound = ns.LoreClip(place), force = true })
end

-- Decide whether this place should be told now. Returns "first", "replay" or nil.
function ns.LoreDecision(place, roll)
    if not place or not ns.zoneLore[place] then return nil end
    local seen = LoreState().seen
    local last = seen[place]
    if not last then return "first" end
    if Now() - last < ns.LORE_REPLAY_CD then return nil end
    roll = roll or math.random()
    if roll < ns.LORE_REPLAY_CHANCE * (ns.ChattyMult and ns.ChattyMult() or 1) then return "replay" end
    -- not this time; don't roll again for this place for a while
    seen[place] = Now() - ns.LORE_REPLAY_CD + 600
    return nil
end

local pending
-- Called a moment after a zone change; waits behind guide speech and combat.
function ns.TryLore(waited)
    waited = waited or 0
    if not (ns.db and ns.db.zoneLore) then return end
    if not (ns.frame and ns.frame:IsShown()) then return end
    local place = ns.LorePlace()
    if not place then return end
    if pending and pending ~= place and waited > 0 then return end   -- moved on; newer check owns it
    local busy = ns.GuideSpeaking() or (UnitAffectingCombat and UnitAffectingCombat("player"))
    if busy then
        if waited >= ns.LORE_MAX_WAIT then pending = nil return end
        pending = place
        C_Timer.After(ns.LORE_RETRY, function() ns.TryLore(waited + ns.LORE_RETRY) end)
        return "queued"
    end
    pending = nil
    local why = ns.LoreDecision(place)
    if not why then return end
    LoreState().seen[place] = Now()
    ns.SpeakLore(place)
    return why
end

local function OnZone() if C_Timer then C_Timer.After(1.5, function() ns.TryLore(0) end) end end
ns:On("ZONE_CHANGED_NEW_AREA", OnZone)
ns:On("ZONE_CHANGED", OnZone)
ns:On("ZONE_CHANGED_INDOORS", OnZone)
ns:On("LOGIN", function() if C_Timer then C_Timer.After(8, function() ns.TryLore(0) end) end end)

ns:AddCommand("lore", function(rest)
    rest = strtrim and strtrim(rest or "") or (rest or "")
    if rest == "on" or rest == "off" then
        ns.db.zoneLore = rest == "on"
        ns.Print("zone histories " .. (ns.db.zoneLore and "ON" or "OFF"))
        return
    end
    if rest == "reset" then LoreState().seen = {} ns.Print("zone histories: every place is new again") return end
    local place = ns.LorePlace()
    if not place then
        ns.Print("I don't know a story for " .. ((safe(GetSubZoneText) or "") ~= "" and safe(GetSubZoneText) or safe(GetZoneText) or "here") .. " yet.")
        return
    end
    LoreState().seen[place] = Now()
    ns.SpeakLore(place)
end)
