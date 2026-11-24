-- Companion: Dialogue lines and the sound clip for each one.

local _, ns = ...

ns.dialogue = {
    praise = {
        { text = "Incredible kill! You're unstoppable!", sound = "praise_1.ogg" },
        { text = "That was amazing! Perfect execution!", sound = "praise_2.ogg" },
        { text = "Look at you go! Absolutely brilliant!", sound = "praise_3.ogg" },
        { text = "Another one bites the dust! Great work!", sound = "praise_4.ogg" },
    },
    scolding = {
        { text = "Hey! Be careful out there, you almost died!", sound = "scold_1.ogg" },
        { text = "Focus up! You can't be taking hits like that!", sound = "scold_2.ogg" },
        { text = "Ouch! Watch your health bar!", sound = "scold_3.ogg" },
        { text = "Are you trying to get us killed?", sound = "scold_4.ogg" },
    },
    encouragement = {
        { text = "Don't give up! You've got this!", sound = "encourage_1.ogg" },
        { text = "Shake it off! We'll get them next time!", sound = "encourage_2.ogg" },
        { text = "Take a breath. You're doing great!", sound = "encourage_3.ogg" },
    },
    questAccept = {
        { text = "Ooh, a new quest! Let's do it!", sound = "quest_accept_1.ogg" },
        { text = "Another adventure? Lead the way!", sound = "quest_accept_2.ogg" },
    },
    questTurnIn = {
        { text = "Awesome! Quest complete!", sound = "quest_done_1.ogg" },
        { text = "Great job finishing that up!", sound = "quest_done_2.ogg" },
    },
    levelUp = {
        { text = "Level up! You're getting so strong!", sound = "levelup_1.ogg" },
        { text = "Congratulations! Look at that power increase!", sound = "levelup_2.ogg" },
    },
    idle = {
        { text = "Hey lazybones... are you AFK?", sound = "idle_1.ogg" },
        { text = "Hello? Earth to player?", sound = "idle_2.ogg" },
        { text = "Don't make me come over there...", sound = "idle_3.ogg" },
    },
    welcome = {
        { text = "I'm here! Ready when you are.", sound = "welcome.ogg" },
        { text = "Welcome back! Missed you!", sound = "welcome_back.ogg" },
    },
}

ns.fallbackSounds = { "praise_1.ogg", "encourage_1.ogg", "scold_1.ogg" }

-- =====================================================================
-- More lines (0.26). These have no sound clip: in Sound Clips mode they are
-- shown as text only.
-- Placeholders: {name} = your character, {step} = guide step text,
-- {target} = place/target label, {zone} = zone name, {item} = item link.
-- =====================================================================

local function add(category, lines)
    ns.dialogue[category] = ns.dialogue[category] or {}
    for _, text in ipairs(lines) do table.insert(ns.dialogue[category], { text = text }) end
end
ns.AddLines = add

-- ----- Existing categories, more variety -----
add("praise", {
    "Clean kill, {name}!",
    "Ha! Didn't even see you coming.",
    "Lok'tar! That's how it's done!",
    "You make that look easy.",
    "One less problem in Durotar!",
    "Smooth. Very smooth.",
    "I'd clap, but I'm busy floating here.",
    "Strength and honor, {name}!",
    "That one never stood a chance.",
    "Keep that rhythm going!",
})
add("scolding", {
    "{name}! Bandage, potion, something!",
    "Health is low! Back off a bit!",
    "Don't pull the whole camp at once!",
    "I'm not ready to write your eulogy, {name}.",
    "Easy! Eat something after this one.",
    "That's a lot of red on your health bar...",
    "Breathe, kite, survive!",
    "If you die, I'm telling everyone in Orgrimmar.",
    "Careful! The spirit healer is a long walk.",
})
add("encouragement", {
    "Everyone dies in Durotar at least once. It's tradition.",
    "Back on your feet, {name}. We go again.",
    "That was just a warm-up.",
    "The spirit healer says hi. Let's not visit again soon.",
    "Even Thrall had bad days.",
    "Shake off the dust. You're tougher than that.",
    "We learned something. Mostly: don't do that again.",
    "Run back, regroup, and show them who's boss.",
    "I still believe in you, {name}.",
})
add("questAccept", {
    "Another task for the Horde? On it!",
    "Ooh, this one sounds like XP.",
    "Got it in the log. Let's go!",
    "More work? Good. Work is XP.",
    "I like this one already.",
    "Adventure accepted, {name}!",
    "Quest log's getting fuller. That's a good sign.",
    "Let's get this done quick and clean.",
    "Another errand, another reward!",
})
add("questTurnIn", {
    "Paid in coin and glory!",
    "Done and dusted, {name}!",
    "Ka-ching! Look at that experience.",
    "Another one off the list!",
    "They should name a hut after you.",
    "Quest complete. Next!",
    "Nice! That XP bar jumped.",
    "Efficient. I love it.",
    "The Horde thanks you. So do I.",
})
add("levelUp", {
    "Ding! Look at you, {name}!",
    "New level, new you!",
    "Stronger every day. Lok'tar!",
    "Go check your trainer, {name}! New skills!",
    "Level up! I felt that one from here.",
    "You're growing so fast...",
    "That glow looks good on you.",
    "Higher and higher! Keep climbing!",
    "Another level closer to greatness!",
})
add("idle", {
    "I'll just... float here then.",
    "{name}? You still there?",
    "Counting scorpids while I wait. I'm at forty.",
    "The quests won't do themselves, you know.",
    "Did you fall asleep on your keyboard?",
    "I'm getting bored, {name}.",
    "Psst. Adventure is that way.",
    "Snack break? Bring me something.",
    "Hello? Anyone home?",
})
add("welcome", {
    "Hey {name}! Let's make some progress today.",
    "There you are! Ready to go?",
    "Good to see you, {name}!",
    "Back for more? I like your style.",
    "Strength and honor, {name}. Let's go!",
    "I kept your spot warm.",
    "Welcome back, champion of the Horde!",
    "Let's go level something, {name}!",
})

-- ----- Guide moments -----
add("guideStep", {
    "Next up: {step}.",
    "Okay, next: {step}.",
    "Here's the plan: {step}.",
    "Let's do this: {step}.",
    "Moving on! {step}.",
    "Next on the list: {step}.",
    "Follow me: {step}.",
    "Right, {step}. Easy.",
})
add("guideArrive", {
    "We're here! {target}.",
    "This is the spot! {target}.",
    "Made it! {target}.",
    "Right here, {name}! {target}.",
    "Arrived. {target}.",
    "Stop, stop! This is it. {target}.",
    "Here we are. {target}.",
})
add("guideTurnIn", {
    "Turn-in time: {step}.",
    "Let's cash this in: {step}.",
    "Go collect that reward: {step}.",
    "Hand it over! {step}.",
    "Reward time! {step}.",
    "Done with that one, let's turn it in: {step}.",
})
add("guideHearth", {
    "Hearth time! {step}.",
    "Use your hearthstone. {step}.",
    "Let's take the shortcut home. {step}.",
    "Hearthstone, {name}! {step}.",
    "No walking this time. {step}.",
    "Poof! Hearth us out. {step}.",
})
add("guideTrain", {
    "Visit your trainer! {step}.",
    "New spells are waiting. {step}.",
    "Training time, {name}. {step}.",
    "Don't skip your trainer! {step}.",
    "Spend some coin on skills. {step}.",
    "Let's get stronger. {step}.",
})
add("guideDone", {
    "We finished the whole guide! I'm so proud of you, {name}!",
    "That's the end of the route. You're amazing!",
    "Guide complete! Lok'tar ogar!",
    "Every step done. Time for the next adventure!",
    "Route finished! Durotar is in our dust.",
    "Done! Where to next, {name}?",
})

-- ----- New situations -----
add("loot", {
    "Ooh, shiny.",
    "Into the bag it goes!",
    "Loot is loot!",
    "Every copper counts.",
    "Vendor trash? Still money!",
    "Gimme gimme.",
    "Nice pickup.",
})
add("lootGood", {
    "A green! Nice find, {name}!",
    "Ooh, that one's actually good!",
    "Check your stats, that might be an upgrade!",
    "Look at that glow! Upgrade?",
    "Green means go! Equip it!",
    "Now that's worth picking up!",
})
add("lootRare", {
    "A BLUE?! {name}, look at that!",
    "Rare loot! Today's our lucky day!",
    "Blue item! I'm screaming!",
    "That's a real treasure, {name}!",
    "Rare drop! Lok'tar!",
    "Whoa. That's a blue. Frame it.",
})
add("lootEpic", {
    "PURPLE! {name}, that's EPIC!",
    "An epic?! I need to sit down.",
    "Purple loot! Tell everyone!",
    "That's legendary-level luck. Well, epic-level.",
    "EPIC! Best. Day. Ever!",
    "I'm not crying, you're crying. It's purple!",
})
add("lowMana", {
    "Running low on mana, {name}!",
    "Mana's almost empty. Drink up after this.",
    "Careful, you're out of juice!",
    "Low mana! Wand or drink?",
    "Your blue bar is looking sad.",
    "Time to sit and drink soon.",
})
add("bagsFull", {
    "Your bags are full, {name}!",
    "No more room! Time to vendor.",
    "Bags are stuffed. Sell some junk!",
    "We can't carry any more loot!",
    "Full bags! Find a vendor, quick!",
    "Not one free slot left!",
})
add("bagsAlmost", {
    "Bags are almost full.",
    "Only a couple of slots left!",
    "Think about vendoring soon.",
    "We're running out of bag space.",
    "Two slots left, maybe less!",
    "Room's getting tight in there.",
})
add("rareMob", {
    "A rare! Get it, {name}!",
    "Ooh, that's a rare one. Careful!",
    "Rare spawn! Good loot maybe!",
    "Silver dragon! That's a rare!",
    "Lucky! Rares don't show up often.",
    "That's no ordinary mob. Rare!",
})
add("eliteMob", {
    "Elite! That one hits hard.",
    "Careful, that's an elite!",
    "Gold dragon means trouble. Maybe find a friend?",
    "Elite target! Don't solo it if you're not sure.",
    "That's an elite, {name}. Be smart.",
    "Big one! Elites hit way harder.",
})
add("lowDurability", {
    "Your gear's falling apart! Repair soon.",
    "Armor's almost broken, {name}!",
    "Find a repair vendor, quick!",
    "Your gear's looking battered.",
    "Durability is low! Repair time!",
    "You're held together with string. Repair!",
})
add("partyJoin", {
    "New friend! Hi there!",
    "A party! Let's go!",
    "Strength in numbers!",
    "More company. I love it.",
    "Group up! Quests go faster together.",
    "Welcome to the party!",
})

-- ----- Personality and banter -----
add("timeMorning", {
    "Good morning, {name}! Fresh day, fresh XP.",
    "Morning! The sun's up over Durotar.",
    "Early start? I like it.",
    "Rise and grind, {name}!",
    "Morning adventures are the best ones.",
    "Coffee? Grog? Let's go!",
})
add("timeEvening", {
    "Evening already. The sky's turning red.",
    "Good evening, {name}!",
    "Sunset over the desert. Pretty, right?",
    "An evening of questing. Perfect.",
    "The day's almost done. Let's finish strong.",
    "Evening! Time for a few more quests.",
})
add("timeNight", {
    "It's late, {name}. Night owl?",
    "The stars are out. Careful in the dark.",
    "Night questing! Spooky.",
    "Shouldn't you be sleeping?",
    "Quiet night. Good for leveling.",
    "Moonlight looks good on you.",
})
add("session1h", {
    "One hour in! Great session so far.",
    "An hour already? Time flies.",
    "One hour of adventure. Stretch break?",
    "Hour one done, {name}. Drink some water!",
    "We've been at this an hour. You're doing great.",
    "Sixty minutes of pure progress!",
})
add("session2h", {
    "Two hours! You're on a roll.",
    "Two hours in. Maybe stretch those legs?",
    "Two hours of questing, {name}. Impressive!",
    "Hydrate! Two hours is a long time.",
    "That's a solid two-hour session.",
    "Two hours down. Still going strong!",
})
add("session3h", {
    "Three hours, {name}! Take a real break soon.",
    "We've been here forever. I love it, but rest your eyes.",
    "Marathon session! Snack time?",
    "Three-plus hours. You're a machine.",
    "Long session! Don't forget to eat.",
    "Still here? Legend. Take a breather though.",
})
add("banter", {
    "Did you know scorpids taste like chicken? Don't ask how I know.",
    "I wonder what Thrall's doing right now.",
    "Nice weather for adventuring.",
    "You know, you're pretty good at this, {name}.",
    "If I had legs, I'd race you.",
    "Durotar's hot, dusty, and full of quests. Home sweet home.",
    "I'm keeping a list of everything we've killed. It's long.",
    "Ever wonder where the quilboar get their haircuts?",
    "We make a good team, {name}.",
    "Sometimes I just like watching you run around.",
    "Don't forget to train your skills!",
    "I bet the Barrens has even more quests. Can't wait.",
})
add("zone", {
    "Welcome to {zone}!",
    "{zone}. Let's see what's here.",
    "Ooh, {zone}. New scenery!",
    "We're in {zone} now.",
    "{zone}! Keep your eyes open.",
    "Entering {zone}, {name}.",
})

-- Zone/subzone specific comments, keyed by GetSubZoneText() or GetZoneText().
ns.zoneLines = {
    ["Valley of Trials"] = {
        "The Valley of Trials. Every great orc started here.",
        "So many scorpids. So many boars.",
        "The proving grounds! Show them what you've got.",
    },
    ["Sen'jin Village"] = {
        "Sen'jin! The Darkspear trolls live here. Stay relaxed, mon.",
        "Smell that sea breeze! Sen'jin Village.",
        "The trolls here have some great quests.",
    },
    ["Razor Hill"] = {
        "Razor Hill! Find the inn and set your hearth.",
        "Razor Hill. Gar'Thok has work for us, I bet.",
        "Spiky town! I love the decor.",
    },
    ["Echo Isles"] = {
        "Echo Isles... Zalazane's voodoo is thick here. Careful.",
        "Watch out for the hexed trolls!",
        "Those islands give me the creeps.",
    },
    ["Orgrimmar"] = {
        "Orgrimmar! The heart of the Horde.",
        "Big city! Stay close, I don't want to lose you.",
        "Orgrimmar! Visit the bank, the trainers, the auction house...",
        "Lok'tar! Welcome to Orgrimmar.",
    },
    ["The Barrens"] = {
        "The Barrens! Brace yourself for chat.",
        "So much open space. And so many raptors.",
        "Welcome to the Barrens. Where is Mankrik's wife, anyway?",
    },
    ["Durotar"] = {
        "Durotar. Red rocks and hot sun. Home!",
        "Ah, Durotar. Named after Thrall's father, you know.",
    },
    ["Thunder Ridge"] = { "Thunder Ridge. Lightning and lizards. Fun!" },
    ["Skull Rock"] = { "Skull Rock. The Burning Blade lurks inside. Be careful in there." },
    ["Tiragarde Keep"] = { "Tiragarde Keep. Humans in Durotar? Not for long!" },
}

-- =====================================================================
-- Reminders (0.28). New categories only, appended at the end so the auto clip
-- numbering of existing categories does not change. Lines with {buff}/{count}
-- placeholders are spoken with TTS; lines without placeholders get auto clips.
-- =====================================================================
add("remindFood", {
    "You're not Well Fed, {name}. Eat something tasty!",
    "Snack time! A food buff would help.",
    "No food buff? Let's fix that.",
    "Eat up! Well Fed makes everything easier.",
    "Your tummy's empty. Grab a bite before the next pull.",
    "A good meal goes a long way. Eat something!",
    "Hungry adventurers are sad adventurers. Food buff!",
})
add("remindFoodExpiring", {
    "Your Well Fed is almost gone!",
    "Food buff's running out. Another snack?",
    "Well Fed is about to wear off, {name}.",
    "Better eat again soon, your food buff is fading.",
    "Last minute of Well Fed!",
    "Your meal's wearing off. Refuel!",
})
add("remindAmmo", {
    "Only {count} left in your quiver, {name}. Restock soon.",
    "Ammo's getting low. {count} left.",
    "Running low on ammo! Visit a vendor soon.",
    "Don't forget to buy more ammo.",
    "Your ammo stack is shrinking!",
    "Grab more ammo next time we're in town.",
    "Ammo check: {count}. Time to shop.",
})
add("remindAmmoLow", {
    "Seriously low on ammo! Only {count} left!",
    "Ammo is almost gone! Find a vendor now!",
    "You're nearly out of ammo, {name}!",
    "Ammo emergency! Restock right away!",
    "Just {count} shots left. Don't run dry!",
    "We're about to run out of ammo!",
})
add("remindAmmoEmpty", {
    "You're OUT of ammo, {name}!",
    "No ammo equipped! Your ranged attacks won't work!",
    "Empty quiver! Buy ammo and equip it!",
    "Out of ammo! That's a problem.",
    "Nothing to shoot! Get some ammo!",
    "Zero ammo. Vendor, now!",
})
add("remindBuff", {
    "Your {buff} fell off!",
    "Missing {buff}, {name}! Put it back on.",
    "No {buff}? Let's fix that.",
    "Hey, you forgot {buff}!",
    "Rebuff time: {buff}.",
    "Don't forget {buff}!",
    "{buff} is missing. Cast it before the next fight!",
})
add("remindBuffExpiring", {
    "Your {buff} is about to wear off!",
    "{buff} is running out. Refresh it!",
    "Heads up, {buff} is fading.",
    "Quick, refresh {buff}!",
    "{buff} has seconds left, {name}.",
    "Your {buff} is almost gone.",
})
add("remindBuffs", {
    "Your buffs fell off!",
    "Time to rebuff!",
    "Missing some buffs there.",
    "Buff up before the next fight!",
    "Don't forget your buffs!",
    "Looking a little unbuffed, friend.",
})
add("remindPet", {
    "Where's your pet, {name}? Call it back!",
    "Your companion is missing! Summon it.",
    "No pet out! Don't go alone.",
    "Your pet's not with us. Summon it!",
    "Your pet could use some attention. Bring it back!",
    "Pet's gone! Let's get our buddy back.",
})
add("remindWeapon", {
    "Your weapon needs {buff}!",
    "No {buff} on your weapon, {name}!",
    "Weapon's naked! Apply {buff}.",
    "{buff} wore off your weapon.",
    "Refresh {buff} on your weapon!",
    "Your {buff} is about to run out!",
})
add("remindBattleShout", {
    "Battle Shout!",
    "Shout, {name}! Battle Shout!",
    "Don't forget Battle Shout!",
    "Let them hear you! Battle Shout!",
    "Battle Shout first, then smash!",
    "Roar! Battle Shout time!",
})

-- =====================================================================
-- Race flavor (0.29). Lines tagged with races only play for those races; lines that
-- mention Durotar/Thrall/scorpids/quilboar are skipped for Undead (see Voice.lua).
-- Appended at the END of their categories so existing clip numbers don't shift.
-- =====================================================================
local function addFor(races, category, lines)
    ns.dialogue[category] = ns.dialogue[category] or {}
    for _, text in ipairs(lines) do table.insert(ns.dialogue[category], { text = text, races = races }) end
end
local UNDEAD = { "Scourge", "Undead" }
addFor(UNDEAD, "banter", {
    "Tirisfal is gloomy, but it's our gloom.",
    "The Dark Lady would be proud of you, {name}.",
    "Death was just the beginning, right?",
    "I like your style. Very... decomposed.",
    "Brill's lovely this time of year. It's always this time of year.",
})
addFor(UNDEAD, "praise", {
    "For the Dark Lady!",
    "They'll be joining the Scourge... or us.",
    "Victory for the Forsaken!",
})
addFor(UNDEAD, "encouragement", {
    "Dying again? You're used to it by now, {name}.",
    "Undeath has its perks. Like getting back up.",
    "The Forsaken don't stay down. Up you get!",
})
addFor(UNDEAD, "welcome", {
    "Rise and shine, {name}! Well, rise anyway.",
    "Back from the grave again? Good!",
})

-- Zone banter for Tirisfal (new keys only).
ns.zoneLines["Deathknell"] = {
    "Deathknell. Where we all woke up. Fond memories... sort of.",
    "The Deathknell graveyard. Mind the mindless ones.",
    "Welcome to unlife, {name}. Deathknell's a good place to start.",
}
ns.zoneLines["Brill"] = {
    "Brill! Find the inn and set your hearth.",
    "Brill. Cozy, damp, and full of apothecaries.",
    "Brill's the heart of Tirisfal. Lots of work here.",
}
ns.zoneLines["Tirisfal Glades"] = {
    "Tirisfal Glades. Misty, spooky, perfect.",
    "Home of the Forsaken. Keep an eye out for the Scarlet Crusade.",
    "The Glades. Every tree looks like it's judging us.",
}
ns.zoneLines["Undercity"] = {
    "The Undercity! Mind the slime canals.",
    "Undercity. The Dark Lady's home. Show some respect.",
    "Big, dark, and full of apothecaries. Stay close.",
}
ns.zoneLines["Agamand Mills"] = {
    "Agamand Mills. The Agamand family is still... around.",
    "The mills are overrun. Skeletons everywhere!",
    "Agamand Mills. Creaky and haunted. Lovely.",
}

-- =====================================================================
-- Tauren flavor (0.31), appended only.
-- =====================================================================
local TAUREN = { "Tauren" }
addFor(TAUREN, "banter", {
    "Mulgore's grass smells like home.",
    "The Earthmother is watching over you, {name}.",
    "Walk with the Earthmother.",
    "Those plains go on forever. Perfect for a long run.",
})
addFor(TAUREN, "praise", {
    "The Earthmother smiles on you!",
    "Strong as a kodo!",
    "For Thunder Bluff!",
})
addFor(TAUREN, "encouragement", {
    "Even the mightiest tauren stumbles. Up you get.",
    "The Earthmother doesn't give up on us. Neither will I.",
})
addFor(TAUREN, "welcome", {
    "The winds bring you back, {name}!",
})

ns.zoneLines["Camp Narache"] = {
    "Camp Narache. Every young tauren starts their trials here.",
    "Chief Hawkwind will have work for us.",
}
ns.zoneLines["Red Cloud Mesa"] = {
    "Red Cloud Mesa. Plainstriders, cougars and quilboar. Busy place.",
    "The quilboar camp is to the east. Careful.",
}
ns.zoneLines["Bloodhoof Village"] = {
    "Bloodhoof Village! Set your hearth with Kauth.",
    "Baine's village. Lots of quests here.",
    "Bloodhoof Village. Smells like campfires and kodo.",
}
ns.zoneLines["Mulgore"] = {
    "Mulgore. Rolling green plains as far as I can see.",
    "The plains of Mulgore. Peaceful, mostly.",
    "Mulgore! Watch out for the wandering Venture Co.",
}
ns.zoneLines["Thunder Bluff"] = {
    "Thunder Bluff! Mind the edges, it's a long way down.",
    "The high mesas of Thunder Bluff. Use the elevators!",
    "Thunder Bluff. Cairne Bloodhoof lives at the top.",
}
ns.zoneLines["Brambleblade Ravine"] = {
    "Brambleblade Ravine. Quilboar territory.",
    "Thorny place. The quilboar love it.",
}
ns.zoneLines["The Venture Co. Mine"] = {
    "The Venture Co. Mine. Goblins tearing up the land.",
    "Watch out for the supervisors in here.",
}
ns.zoneLines["Palemane Rock"] = {
    "Palemane Rock. Gnoll poachers everywhere.",
    "The Palemane gnolls don't share well.",
}

-- =====================================================================
-- 0.32: guide chaining, dungeon ready check, Barrens and Orgrimmar zones (appended).
-- =====================================================================
add("guideNext", {
    "Route done! Next up: {guide}.",
    "That's this zone finished. Ready for {guide}?",
    "All done here! Let's start {guide}.",
    "Finished! {guide} is waiting for us.",
})
add("dungeonMissing", {
    "Wait! We don't have {quest} yet.",
    "Hold on, {quest} is still out there. Grab it first!",
    "Before we go in: we're missing {quest}.",
    "Hang on! No {quest} in the log. That's free XP!",
})

ns.zoneLines["The Crossroads"] = {
    "The Crossroads! Every road in the Barrens leads here.",
    "Crossroads. Set your hearth, there's a lot of running ahead.",
    "Busy little fort. Lots of quests on these walls.",
}
ns.zoneLines["Ratchet"] = {
    "Ratchet! Goblins, boats and pirates.",
    "Smell that? Salt water and engine grease.",
    "Ratchet. Neutral town, so mind your manners.",
}
ns.zoneLines["Lushwater Oasis"] = {
    "Lushwater Oasis. The Wailing Caverns are right below us.",
    "Druids of the Fang hang around here. Careful.",
}
ns.zoneLines["The Stagnant Oasis"] = {
    "The Stagnant Oasis. Something's wrong with this water.",
    "Ugh, smell that water. Don't drink it.",
}
ns.zoneLines["The Forgotten Pools"] = {
    "The Forgotten Pools. Watch for the centaur.",
    "Quiet pools out here. Too quiet.",
}
ns.zoneLines["Camp Taurajo"] = {
    "Camp Taurajo. Tauren hospitality in the southern Barrens.",
    "Taurajo! Good spot to rest and sell.",
}
ns.zoneLines["The Sludge Fen"] = {
    "The Sludge Fen. Goblins drilling for oil. Messy.",
    "Venture Co. muck everywhere. Let's be quick.",
}
ns.zoneLines["Far Watch Post"] = {
    "Far Watch Post. Last stop before Durotar.",
    "The watch post. Quilboar keep poking at it.",
}
ns.zoneLines["The Mor'shan Rampart"] = {
    "Mor'shan Rampart. The Warsong front starts here.",
    "Big wall, angry Alliance up north. Stay sharp.",
}
ns.zoneLines["Thorn Hill"] = {
    "Thorn Hill. Razormane quilboar territory.",
    "Thorny place. Mind the quilboar.",
}
ns.zoneLines["The Gold Road"] = {
    "The Gold Road. Caravans used to run here.",
    "Follow the road and we won't get lost.",
}
ns.zoneLines["Ragefire Chasm"] = {
    "Ragefire Chasm. Hot, dark and full of troggs.",
    "Under Orgrimmar! Watch for the Burning Blade.",
    "Ragefire. Stick together in here.",
}
ns.zoneLines["Cleft of Shadow"] = {
    "The Cleft of Shadow. Neeru Fireblade lives down here.",
    "Creepy little corner of Orgrimmar.",
}
ns.zoneLines["Valley of Wisdom"] = {
    "Valley of Wisdom. Thrall's hall is right here.",
    "Thrall's in Grommash Hold. Got anything for him?",
}

-- =====================================================================
-- 0.33: zones on the road to 30 (appended, new keys only).
-- =====================================================================
local function zone(key, lines) if not ns.zoneLines[key] then ns.zoneLines[key] = lines end end
zone("Silverpine Forest", { "Silverpine. Worgen in the woods, so stay close.", "Dark trees, grey sky. Very Forsaken." })
zone("The Sepulcher", { "The Sepulcher. Hadrec and Dalar will have work for us.", "Cozy crypt. Set your hearth here." })
zone("Pyrewood Village", { "Pyrewood. Nice by day. Don't stay for the night.", "Something's off about these villagers." })
zone("Fenris Isle", { "Fenris Isle. Lots of nasty things on that island.", "Swim carefully, the murlocs are watching." })
zone("The Dead Field", { "The Dead Field. Watch out for Nightlash.", "Nothing grows here. Lovely." })
zone("Beren's Peril", { "Beren's Peril. Spiders. So many spiders.", "Mind the webs." })
zone("Stonetalon Mountains", { "Stonetalon. Big peaks, bigger goblin machines.", "The Venture Co. is chewing up these mountains." })
zone("Sun Rock Retreat", { "Sun Rock Retreat. Grab the flight path!", "A Horde camp right in the rocks. Nice." })
zone("Malaka'jin", { "Malaka'jin. The Darkspear outpost.", "Trolls in the mountains. Feels like home for some." })
zone("Windshear Crag", { "Windshear Crag. Shredders everywhere!", "Goblins cutting down the whole forest." })
zone("Ashenvale", { "Ashenvale. Night elf woods. Stay alert.", "Pretty forest. Shame about the Sentinels." })
zone("Splintertree Post", { "Splintertree Post! Warsong lumber camp.", "Splintertree. Grab the flight path and the quests." })
zone("Zoram'gar Outpost", { "Zoram'gar Outpost. The Earthen Ring's little camp.", "Blackfathom Deeps is just up the coast." })
zone("Thistlefur Village", { "Thistlefur furbolgs. Keep moving.", "Furbolg town. Watch the totems." })
zone("Hillsbrad Foothills", { "Hillsbrad. Green hills and angry farmers.", "The Alliance is right over there in Southshore." })
zone("Tarren Mill", { "Tarren Mill! The Forsaken outpost in Hillsbrad.", "Tarren Mill. Set your hearth, there's a lot to do." })
zone("Hillsbrad Fields", { "Hillsbrad Fields. The farmers here won't be happy to see us.", "Lots of targets for the Battle of Hillsbrad." })
zone("Thousand Needles", { "Thousand Needles. Look at those spires!", "The Needles. Centaur below, wind riders above." })
zone("Freewind Post", { "Freewind Post. Up on the mesa. Take the lift!", "Freewind. Great view, longer drop." })
zone("The Shimmering Flats", { "The Shimmering Flats! Race cars and salt.", "Goblins and gnomes racing. Of course." })

-- 0.34: level 10 class quests (appended; keeps clip numbering of older categories)
add("classQuest10", {
    "Level ten! Your class quest is ready: {quest}.",
    "Ten already? Don't skip {quest}. It's a big one.",
    "We hit ten! First stop: {quest}.",
    "Level ten means {quest}. Let's go get it.",
    "You feel that? That's level ten. Time for {quest}.",
    "Level ten! Don't forget your class quest.",
    "Ten! Your trainer has something special for you.",
})

-- 0.40: Alliance lines (appended; existing clip numbers don't move). faction = "Alliance" lines only
-- play for Alliance characters; Horde-flavoured lines (Horde/Thrall/Orgrimmar/Lok'tar...) are skipped
-- for Alliance by Voice.lua.
local function addFaction(faction, category, lines)
    ns.dialogue[category] = ns.dialogue[category] or {}
    for _, text in ipairs(lines) do table.insert(ns.dialogue[category], { text = text, faction = faction }) end
end
addFaction("Alliance", "welcome", { "Welcome back, champion of the Alliance!", "For the Alliance! Let's get going." })
addFaction("Alliance", "praise", { "For the Alliance!", "Stormwind would be proud of that." })
addFaction("Alliance", "questTurnIn", { "The Alliance thanks you. So do I." })
addFaction("Alliance", "banter", { "I wonder if Bolvar ever gets a day off.", "Ironforge ale tonight? You've earned it.", "Darnassus is lovely, but those stairs..." })
addFaction("Alliance", "guideDone", { "Guide complete! For the Alliance!" })

-- Alliance zone lines live in their own table so Horde lines for shared zones (Ashenvale,
-- Hillsbrad...) are never said to the Alliance and vice versa. Clips: auto_zone_a_<place>_<n>.ogg
ns.zoneLinesAlliance = {
    ["Northshire Valley"] = { "Northshire Abbey. Where every Stormwind hero starts.", "Kobolds in the mine and wolves in the woods. Classic." },
    ["Elwynn Forest"] = { "Elwynn Forest. Green, peaceful... mostly.", "Mind the Defias. They're everywhere lately." },
    ["Goldshire"] = { "Goldshire! The Lion's Pride Inn is right there.", "Set your hearth in Goldshire, it's central." },
    ["Stormwind City"] = { "Stormwind! Bank, trainers, auction house.", "The heart of the Alliance. Mind the canals." },
    ["Coldridge Valley"] = { "Coldridge Valley. Brr. Troggs and frost.", "Every dwarf and gnome starts right here." },
    ["Dun Morogh"] = { "Dun Morogh. Snow as far as you can see.", "Watch out for the Frostmane trolls." },
    ["Kharanos"] = { "Kharanos! The Thunderbrew Distillery is right there.", "Set your hearth at the Thunderbrew, it's cosy." },
    ["Ironforge"] = { "Ironforge! Warm forges and good ale.", "The Great Forge. Bank and auction house are close." },
    ["The Hall of Thanes"] = { "The Hall of Thanes. A new dungeon right under Ironforge.", "Careful, the last boss fears. Clear the room first." },
    ["Shadowglen"] = { "Shadowglen. Quiet, ancient and very green.", "Every night elf begins here." },
    ["Teldrassil"] = { "Teldrassil. We're standing on a tree. A really big tree.", "The forest feels sick lately. Stay sharp." },
    ["Dolanaar"] = { "Dolanaar. Set your hearth here.", "Lots of quests in Dolanaar, check every NPC." },
    ["Darnassus"] = { "Darnassus. Beautiful, and very purple.", "The class trainers are spread out. Bring patience." },
    ["Rut'theran Village"] = { "Rut'theran. The boat to Auberdine leaves from here.", "Grab the flight path to Darnassus' docks." },
    ["Darkshore"] = { "Darkshore. Gloomy coast, lots of murlocs.", "Auberdine is the hub. Boats go everywhere from there." },
    ["Auberdine"] = { "Auberdine. Boats to Menethil, Rut'theran and Theramore.", "Set your hearth in Auberdine, we'll be back." },
    ["Westfall"] = { "Westfall. Farms, harvest golems and the Defias.", "Sentinel Hill has all the work we need." },
    ["Sentinel Hill"] = { "Sentinel Hill. Gryan Stoutmantle needs help.", "The People's Militia. Let's lend a hand." },
    ["The Deadmines"] = { "The Deadmines. VanCleef is in there somewhere.", "Moonbrook hides the Deadmines. Stay together." },
    ["Loch Modan"] = { "Loch Modan. The big dam is something, huh?", "Troggs everywhere. Thelsamar has the quests." },
    ["Thelsamar"] = { "Thelsamar. Grab the flight path.", "Set your hearth in Thelsamar for Loch Modan." },
    ["Redridge Mountains"] = { "Redridge. Gnolls and orcs in the hills.", "Lakeshire needs a lot of help." },
    ["Lakeshire"] = { "Lakeshire. Pretty lake, busy bridge.", "Grab the Lakeshire flight path." },
    ["Duskwood"] = { "Duskwood. It's always night here. Creepy.", "Worgen in the woods. Don't wander off." },
    ["Darkshire"] = { "Darkshire. The Night Watch keeps the lights on.", "Set your hearth in Darkshire, we'll be here a while." },
    ["The Stockade"] = { "The Stockade. Time to quell a riot.", "Prisoners loose in the Stockade. Let's tidy up." },
    ["Wetlands"] = { "The Wetlands. Bring boots, it's soggy.", "Raptors and Dark Iron dwarves. Fun." },
    ["Menethil Harbor"] = { "Menethil Harbor. Boats to Auberdine and Theramore.", "Set your hearth in Menethil, it's the crossroads." },
    ["Ashenvale"] = { "Ashenvale. Our night elf allies need help.", "Watch for Horde from Splintertree." },
    ["Astranaar"] = { "Astranaar. Grab the flight path.", "The Sentinels here always have work." },
    ["Hillsbrad Foothills"] = { "Hillsbrad. Southshore's just down the road.", "The Forsaken at Tarren Mill are close. Careful." },
    ["Southshore"] = { "Southshore. Sea air and good fish.", "Set your hearth in Southshore for Hillsbrad." },
    ["Gnomeregan"] = { "Gnomeregan. The gnomes want their city back.", "Radiation and leper gnomes. Stay close." },
}

-- 0.44: node callouts (Nodes.lua). The clips are generic; the window shows the node's name.
ns.AddLines("nodeOre", {
    "There's ore nearby.",
    "Ooh, I see a vein close by.",
    "Ore on the minimap! Want to mine it?",
})
ns.AddLines("nodeHerb", {
    "I see herbs nearby.",
    "Ooh, an herb close by.",
    "Herbs on the minimap! Let's pick them.",
})


-- =====================================================================
-- 0.71: zones on the road from 30 to 60 (appended, new keys only).
-- Horde chatter uses zone(); Alliance chatter uses zoneA() so shared
-- places (Desolace, Tanaris, the Plaguelands...) get both tables.
-- =====================================================================
local function zoneA(key, lines) if not ns.zoneLinesAlliance[key] then ns.zoneLinesAlliance[key] = lines end end

zone("Altar of Storms", { "The Altar of Storms. Warlock ground.", "The stone feels like it's listening. I hate that." })
zone("Alterac Mountains", { "The Alterac Mountains. A kingdom that picked the wrong side.", "Ogres in the ruins, snow on the peaks. Bundle up." })
zone("Andorhal", { "Andorhal. Once a granary town. Now Scourge ground.", "The grain is long since poison. Stay sharp." })
zone("Angor Fortress", { "Angor Fortress. Dark Irons. They won't be glad to see us.", "A Shadowforge hold. Let's not knock politely." })
zone("Arathi Highlands", { "The Arathi Highlands. Old human kingdom, new Horde ground.", "Hills, ogres, and a lot of unfinished fights." })
zone("Azshara", { "Azshara. Beautiful cliffs, terrible history.", "Named for a queen who broke the world. Stay sharp." })
zone("Badlands", { "The Badlands. Hot rock and worse company.", "Dwarves digging, dragons watching. Stay sharp." })
zone("Bay of Storms", { "The Bay of Storms. Wrecks and naga.", "Don't swim farther than you have to." })
zone("Blackchar Cave", { "Blackchar Cave. I do not like that hole.", "Whatever lives in there likes the heat more than we do." })
zone("Blackrock Depths", { "Blackrock Depths. The Dark Iron city under the mountain.", "Shadowforge halls. Stay together, and don't get lost." })
zone("Blackrock Mountain", { "Blackrock Mountain. The door to too many places.", "Depths, spire, and worse under the stone." })
zone("Blackrock Spire", { "Blackrock Spire. Orcs in the upper halls.", "Blackrock and Dragonmaw. This will not be quiet." })
zone("Blackrock Stronghold", { "Blackrock Stronghold. Old Horde colors, new problems.", "An orc fortress in the ash. Careful on the approach." })
zone("Blasted Lands", { "The Blasted Lands. The Portal tore this place open.", "The ground still looks like a wound." })
zone("Bloodvenom Post", { "Bloodvenom Post. Our camp in a poisoned wood.", "Set your hearth if you can stand the air." })
zone("Booty Bay", { "Booty Bay! Goblin pirates and a long walk down.", "Watch your purse in Booty Bay. And your step on those ramps." })
zone("Brackenwall Village", { "Brackenwall Village. Ogres built it, we live in it.", "Set your hearth in Brackenwall for the marsh." })
zone("Burning Steppes", { "The Burning Steppes. Blackrock's front yard.", "Ash, orcs, and dragons. Stay sharp." })
zone("Caer Darrow", { "Caer Darrow. Scholomance is under that keep.", "An island of bad decisions. Let's be careful." })
zone("Camp Boff", { "Camp Boff. Ogres in the Badlands. Charming.", "Let's not overstay this welcome." })
zone("Camp Mojache", { "Camp Mojache! Tauren camp on the river.", "Set your hearth in Mojache. And grab that flight path." })
zone("Caverns of Time", { "The Caverns of Time. Bronze dragons, and a lot of history.", "I wouldn't poke anything in there." })
zone("Cenarion Hold", { "Cenarion Hold. The Circle stands between us and the hives.", "A fortress in the waste. I'm glad it's here." })
zone("Corin's Crossing", { "Corin's Crossing. A ruined crossroads, thick with the Scourge.", "Don't linger in the open." })
zone("Crown Guard Tower", { "Crown Guard Tower. The Argent Dawn is watching the road.", "A little safety in a long, bad walk." })
zone("Dalson's Tears", { "Dalson's Tears. Another cauldron, another ruined farm.", "The name is doing the explaining for me." })
zone("Darkwhisper Gorge", { "Darkwhisper Gorge. Fel-touched, and listening.", "I don't like this cut in the mountain." })
zone("Darrowshire", { "Darrowshire. A little town that stood, and lost.", "The dead here remember. So should we." })
zone("Deadwind Pass", { "Deadwind Pass. A dead ravine with a tower at the end.", "Karazhan is still lit. That is not comforting." })
zone("Desolace", { "Desolace. Grey earth and centaur. Stay close.", "This land used to be a garden. Hard to believe." })
zone("Dire Maul", { "Dire Maul. Eldre'Thalas, what's left of it.", "Ogres, satyrs, and Highborne ghosts. Stay together." })
zone("Dreadmaul Hold", { "Dreadmaul Hold. Ogres, too close to the Portal.", "Let's not hang around after the fight." })
zone("Dreadmaul Rock", { "Dreadmaul Rock. Ogres under a rain of ash.", "Charming neighborhood." })
zone("Dustwallow Marsh", { "Dustwallow Marsh. Mud, fog, and crocolisks.", "Watch your step. The ground lies." })
zone("Eastern Plaguelands", { "The Eastern Plaguelands. This is the worst of it.", "Plague, ruins, and Stratholme at the end of the road." })
zone("Eastwall Tower", { "Eastwall Tower. Another Argent lookout.", "Good to see a friendly banner out here." })
zone("Emerald Sanctuary", { "The Emerald Sanctuary. Druids trying to heal Felwood.", "A small clean place in a dirty forest. I like them." })
zone("Ethel Rethor", { "Ethel Rethor. Old elven ruins and a long shore.", "The sea almost makes Desolace look gentle." })
zone("Everlook", { "Everlook! A goblin town in the snow.", "Set your hearth in Everlook. The fire is worth the price." })
zone("Faldir's Cove", { "Faldir's Cove. A hidden beach under the cliffs.", "Smugglers' water. Watch the landing." })
zone("Fallow Sanctuary", { "The Fallow Sanctuary. Lost and overgrown.", "I wouldn't wander off the path here." })
zone("Felstone Field", { "Felstone Field. A cauldron farm. Don't breathe deep.", "The Scourge still tends this place." })
zone("Felwood", { "Felwood. This forest is sick. So is everything in it.", "The Legion did this. It hasn't gotten better." })
zone("Feralas", { "Feralas. Old forest, older ruins.", "It's beautiful. The ogres and naga didn't get the hint." })
zone("Fire Plume Ridge", { "Fire Plume Ridge. The crater's still cooking.", "Elementals and lava. Stay on the rock." })
zone("Firewatch Ridge", { "Firewatch Ridge. Dark Iron patrols like this overlook.", "Good view of a bad place." })
zone("Flame Crest", { "Flame Crest. Our camp on a burned rise.", "Set your hearth if you can stand the air." })
zone("Frostsaber Rock", { "Frostsaber Rock. The cats den here.", "Beautiful animals. Let's not startle them." })
zone("Gadgetzan", { "Gadgetzan! If you can pay, they can find it.", "Set your hearth in Gadgetzan. Water costs extra. Of course it does." })
zone("Gahrron's Withering", { "Gahrron's Withering. The eastern cauldron.", "Nothing good grows here. Let's not test that." })
zone("Ghost Walker Post", { "Ghost Walker Post. The tauren are watching the roads.", "Grab the flight path while we're here." })
zone("Go'Shek Farm", { "Go'Shek Farm. Horde fields in the Highlands.", "Keep an eye on the road. This farm sits on a fault line." })
zone("Golakka Hot Springs", { "Golakka Hot Springs. Steaming water, short tempers.", "Nice if you like your baths with elementals." })
zone("Gordunni Outpost", { "Gordunni Outpost. Ogres in Feralas.", "They don't share. We don't ask twice." })
zone("Grimesilt Dig Site", { "The Grimesilt Dig Site. Still digging, somehow.", "Dwarves. I have to respect the commitment." })
zone("Grom'gol Base Camp", { "Grom'gol! The Horde's camp in the jungle.", "Set your hearth in Grom'gol if we're hunting here." })
zone("Hammerfall", { "Hammerfall! From internment camp to Horde town.", "Set your hearth in Hammerfall. Good walls, better company." })
zone("Hearthglen", { "Hearthglen. Scarlet Crusade ground.", "They fight the Scourge. They also fight everyone else." })
zone("Hive'Ashi", { "Hive'Ashi. Close enough to the Hold to keep everyone awake.", "Northern hive. Watch the swarms." })
zone("Hive'Regal", { "Hive'Regal. Do not go in lightly.", "A great silithid hive. Stay out unless we mean it." })
zone("Hive'Zora", { "Hive'Zora. The western hive, no friendlier.", "I hear them under the sand." })
zone("Irontree Woods", { "Irontree Woods. The trees walk.", "I would not chop anything in here." })
zone("Isle of Dread", { "The Isle of Dread. Naga and spray.", "The name is doing a lot of work." })
zone("Jadefire Run", { "Jadefire Run. Satyrs, and they've been at this a long time.", "Corruption with a smile. Let's not linger." })
zone("Jaedenar", { "Jaedenar. Shadow Council, Legion, bad news.", "The name alone is a warning. Stay together." })
zone("Jintha'Alor", { "Jintha'Alor. A whole Vilebranch city on the cliffs.", "Lots of stairs. Lots of trolls. Stay together." })
zone("Karazhan", { "Karazhan. Medivh's tower.", "The lights are on. I would not knock." })
zone("Kargath", { "Kargath. Our outpost in the Badlands.", "Set your hearth in Kargath. Shade is precious here." })
zone("Kodo Graveyard", { "The Kodo Graveyard. So many bones.", "The kodo come here to die. Walk softly." })
zone("Lake Kel'Theril", { "Lake Kel'Theril. Frozen Highborne ruins.", "The ice has a memory. Walk carefully." })
zone("Lakkari Tar Pits", { "The Lakkari Tar Pits. Things fall in.", "Do not take a shortcut across the tar." })
zone("Lethlor Ravine", { "Lethlor Ravine. Black dragons like this canyon.", "I would not camp here. Just saying." })
zone("Light's Hope Chapel", { "Light's Hope Chapel. A small light in a dark land.", "The Argent Dawn holds this ground. I'm glad someone's here." })
zone("Lost Rigger Cove", { "Lost Rigger Cove. Southsea pirates.", "They'll rob us if we let them. Let's not let them." })
zone("Mannoroc Coven", { "Mannoroc Coven. Demons, and lots of them.", "This place feels wrong. Let's not linger." })
zone("Maraudon", { "Maraudon. The centaur's cavern temple. Stay together.", "Theradras is down there somewhere. Watch your step." })
zone("Marshal's Refuge", { "Marshal's Refuge. Researchers in a cave, and I respect that.", "Set your hearth in the Refuge if we're staying in the crater." })
zone("Mazthoril", { "Mazthoril. Blue dragons live in there.", "Knock softly. Or maybe don't knock at all." })
zone("Molten Core", { "The Molten Core. Ragnaros is down there.", "I would not go in without a small army." })
zone("Moonglade", { "Moonglade. The druids hid this valley well.", "Quiet, moonlit, and a relief after Felwood." })
zone("Nesingwary's Expedition", { "Nesingwary's camp. He hunts anything that moves.", "Big game, bigger stories. Try to keep up." })
zone("Nethergarde Keep", { "Nethergarde Keep. Alliance watch on the Portal.", "We don't need to pick a fight with the Kirin Tor today." })
zone("Nighthaven", { "Nighthaven. Even the inn feels like it's listening to the moon.", "A good place to rest, if we can be still." })
zone("Noonshade Ruins", { "Noonshade Ruins. Wastewander ground.", "Bandits in the ruins. At least the shade is honest." })
zone("Northpass Tower", { "Northpass Tower. The northern watch on this road.", "Wave to the Dawn, then keep going." })
zone("Owl Wing Thicket", { "Owl Wing Thicket. A quiet hollow in the snow.", "If anything under these trees stays quiet." })
zone("Pillar of Ash", { "The Pillar of Ash. Easy to see, hard to like.", "A burned landmark in a burned land." })
zone("Plaguewood", { "Plaguewood. Sick trees, worse shadows.", "Stratholme is close. Stay together." })
zone("Pool of Tears", { "The Pool of Tears. The temple sits out there.", "Wide water, worse shores. Watch the banks." })
zone("Revantusk Village", { "Revantusk Village! Our port in the Hinterlands.", "Set your hearth in Revantusk. The sea air is a relief." })
zone("Rise of the Defiler", { "The Rise of the Defiler. You can feel it first.", "Demon ground. I already want to leave." })
zone("Ruins of Alterac", { "The Ruins of Alterac. Crushridge ogres live here now.", "A whole capital, left to the ogres. Shame." })
zone("Ruins of Andorhal", { "The Ruins of Andorhal. The Scourge isn't finished here.", "I wouldn't camp in these streets." })
zone("Ruins of Eldarath", { "The Ruins of Eldarath. A drowned Highborne city.", "The naga never really left this shore." })
zone("Ruins of Isildien", { "The Ruins of Isildien. Night elf stone, empty now.", "Something still walks these ruins. Let's be polite." })
zone("Sandsorrow Watch", { "Sandsorrow Watch. A long view over the dunes.", "Good lookout. Bad picnic spot." })
zone("Scholomance", { "Scholomance. A school for necromancers. Of course it is.", "The Cult of the Damned studies downstairs. Stay together." })
zone("Searing Gorge", { "Searing Gorge. Hot air, worse neighbors.", "The Dark Irons built this mess. Watch your boots." })
zone("Seradane", { "Seradane. The green dragons still watch this wood.", "Walk softly. This forest has old eyes." })
zone("Shadowprey Village", { "Shadowprey Village. A green spot on a grey coast.", "Set your hearth in Shadowprey if we're staying in Desolace." })
zone("Shadra'Alor", { "Shadra'Alor. The spider loa is remembered here.", "Watch the webs. And the priests." })
zone("Shatter Scar Vale", { "Shatter Scar Vale. Infernals fell here and the ground never cooled.", "Watch your step. Some of them still move." })
zone("Shrine of Remulos", { "The Shrine of Remulos. Cenarius's son is remembered here.", "Walk softly. This is their ground." })
zone("Silithus", { "Silithus. Wind, hives, and cultists.", "The silithid were here first. They haven't forgotten." })
zone("Sorrow Hill", { "Sorrow Hill. Graves, and Uther's Tomb nearby.", "Walk softly. This ground earned its name." })
zone("Steamwheedle Port", { "Steamwheedle Port. Fish, docks, and deals.", "A goblin harbor. Keep one hand on your coin purse." })
zone("Stonard", { "Stonard. Our muddy home in the swamp.", "Set your hearth in Stonard. Bring spare boots." })
zone("Stranglethorn Vale", { "Stranglethorn Vale. Jungle, trolls, and everything with teeth.", "Beautiful. Also trying to kill us. So, typical." })
zone("Stratholme", { "Stratholme. Arthas purged this city. It never recovered.", "Scourge in one half, Scarlets in the other. Watch every door." })
zone("Stromgarde Keep", { "Stromgarde Keep. A broken kingdom, still worth the trip.", "Syndicate, ogres, and leftovers. Careful in the ruins." })
zone("Swamp of Sorrows", { "The Swamp of Sorrows. Green, wet, and full of bad ideas.", "The temple out on the water is why this place has its name." })
zone("Tabetha's Farm", { "Tabetha's Farm. A mage in the middle of the swamp.", "I would not pick a fight with the woman who lives here." })
zone("Tanaris", { "Tanaris. Sand, sun, and goblins with a price list.", "Cover your mouth. The wind here has opinions." })
zone("Temple of Arkkoran", { "The Temple of Arkkoran. Sea giants, sea problems.", "Big temple, bigger residents." })
zone("Temple of Atal'Hakkar", { "The Sunken Temple. Hakkar's name is still on it.", "Green dragons sank this for a reason. Stay close." })
zone("Terror Run", { "Terror Run. The big dinosaurs run here.", "If the ground shakes, that's not weather." })
zone("Terrordale", { "Terrordale. The name warned us.", "A broken village in the Plaguewood. Let's not add to it." })
zone("The Altar of Zul", { "The Altar of Zul. High, old, and unfriendly.", "The view is great. The welcome is not." })
zone("The Bulwark", { "The Bulwark. Our line at the edge of the Plaguelands.", "The Argent Dawn stands here too. Good." })
zone("The Cauldron", { "The Cauldron. Stay on the rims if you can.", "That's a long way down, and it's all slag." })
zone("The Crystal Vale", { "The Crystal Vale. Pretty, and strange.", "A shining hollow in Silithus. I don't trust pretty out here." })
zone("The Dark Portal", { "The Dark Portal. This is where it all started.", "Even standing here feels like history staring back." })
zone("The Fungal Vale", { "The Fungal Vale. Mushrooms, and worse.", "I would not touch anything in this hollow." })
zone("The Harborage", { "The Harborage. A quiet draenei camp in the swamp.", "They've had a long road to end up here." })
zone("The Headland", { "The Headland. Long view, cold wind.", "Good place to see trouble coming." })
zone("The Hinterlands", { "The Hinterlands. Forest, trolls, and dwarves with gryphons.", "Watch the cliffs. And everything in the trees." })
zone("The Marshlands", { "The Marshlands. Raptors and biting plants.", "Southern Un'Goro is not a stroll." })
zone("The Noxious Glade", { "The Noxious Glade. It smells like the name.", "Poisoned ground. Keep moving." })
zone("The Quagmire", { "The Quagmire. Deep mud, short tempers.", "If it looks like a path, it probably isn't." })
zone("The Slithering Scar", { "The Slithering Scar. Silithid. Watch the ground.", "I already want to leave." })
zone("The Temple of Atal'Hakkar", { "The Sunken Temple. Hakkar's name is still on it.", "Green dragons sank this for a reason. Stay close." })
zone("The Twin Colossals", { "The Twin Colossals. You can't miss them.", "Two big rocks, a lot of forest, and plenty of trouble." })
zone("Thistleshrub Valley", { "Thistleshrub Valley. Thorns, elementals, no shade.", "I already don't like it." })
zone("Thorium Point", { "Thorium Point. The Brotherhood watches the Gorge from here.", "Grab the flight path. And maybe a drink of water." })
zone("Thunder Axe Fortress", { "Thunder Axe Fortress. Burning Blade. Careful in there.", "I do not like the look of that hold." })
zone("Timbermaw Hold", { "Timbermaw Hold. Earn the furbolg's trust, or stay out.", "The tunnel to Winterspring. Be polite in there." })
zone("Twilight Base Camp", { "The Twilight Base Camp. They preach the end of everything.", "The Hammer is here. Let's not sign up." })
zone("Tyr's Hand", { "Tyr's Hand. A whole Scarlet city.", "They won't be glad to see us. Or anyone." })
zone("Uldaman", { "Uldaman. The dwarves opened a titan vault. Of course they did.", "Troggs and ancient stone. Stay together in there." })
zone("Un'Goro Crater", { "Un'Goro Crater. Dinosaurs, crystals, and very little sense.", "How is this just sitting here behind Tanaris?" })
zone("Uther's Tomb", { "Uther's Tomb. The Lightbringer is at rest here.", "Even I can be quiet for this one." })
zone("Valley of Spears", { "The Valley of Spears. Maraudine ground. Heads up.", "Centaur territory. Let's not pick a fight we don't need." })
zone("Valor's Rest", { "Valor's Rest. A graveyard for the ones who held this line.", "We should be careful enough to not join them." })
zone("Valormok", { "Valormok. Our camp under Azshara's cliffs.", "Set your hearth in Valormok if we're staying." })
zone("Valorwind Lake", { "Valorwind Lake. Pretty water, Hinterlands rules.", "Don't let the quiet fool you." })
zone("Western Plaguelands", { "The Western Plaguelands. Lordaeron's farms, ruined.", "The fields still grow. Don't eat anything." })
zone("Winterfall Village", { "Winterfall Village. Hostile furbolg in the snow.", "These ones are not the Timbermaw. Don't mix them up." })
zone("Winterspring", { "Winterspring. Snow, silence, and the occasional dragon.", "Bundle up. It's colder than it looks from Felwood." })
zone("Witch Hill", { "Witch Hill. The farms out here have a bad name.", "Something's off about this place. Stay close." })
zone("Zul'Farrak", { "Zul'Farrak. Sand trolls, and they were here first.", "The Farraki have a long memory. Stay close in the city." })

zoneA("Aerie Peak", { "Aerie Peak! The Wildhammer hold, and the gryphons with it.", "Set your hearth at Aerie Peak. I like this place." })
zoneA("Altar of Storms", { "The Altar of Storms. Warlock ground.", "The stone feels like it's listening. I hate that." })
zoneA("Alterac Mountains", { "The Alterac Mountains. A kingdom that picked the wrong side.", "Ogres in the ruins, snow on the peaks. Bundle up." })
zoneA("Andorhal", { "Andorhal. Once a granary town. Now Scourge ground.", "The grain is long since poison. Stay sharp." })
zoneA("Angor Fortress", { "Angor Fortress. Dark Irons. They won't be glad to see us.", "A Shadowforge hold. Let's not knock politely." })
zoneA("Arathi Highlands", { "The Arathi Highlands. Stromgarde's hills, still contested.", "The League of Arathor is holding on. So should we." })
zoneA("Azshara", { "Azshara. Beautiful cliffs, terrible history.", "Named for a queen who broke the world. Stay sharp." })
zoneA("Badlands", { "The Badlands. Hot rock and worse company.", "Dwarves digging, dragons watching. Stay sharp." })
zoneA("Bay of Storms", { "The Bay of Storms. Wrecks and naga.", "Don't swim farther than you have to." })
zoneA("Blackchar Cave", { "Blackchar Cave. I do not like that hole.", "Whatever lives in there likes the heat more than we do." })
zoneA("Blackrock Depths", { "Blackrock Depths. The Dark Iron city under the mountain.", "Shadowforge halls. Stay together, and don't get lost." })
zoneA("Blackrock Mountain", { "Blackrock Mountain. The door to too many places.", "Depths, spire, and worse under the stone." })
zoneA("Blackrock Spire", { "Blackrock Spire. Orcs in the upper halls.", "Blackrock and Dragonmaw. This will not be quiet." })
zoneA("Blackrock Stronghold", { "Blackrock Stronghold. Old Horde colors, new problems.", "An orc fortress in the ash. Careful on the approach." })
zoneA("Blasted Lands", { "The Blasted Lands. The Portal tore this place open.", "The ground still looks like a wound." })
zoneA("Booty Bay", { "Booty Bay! Goblin pirates and a long walk down.", "Watch your purse in Booty Bay. And your step on those ramps." })
zoneA("Burning Steppes", { "The Burning Steppes. Blackrock's front yard.", "Ash, orcs, and dragons. Stay sharp." })
zoneA("Caer Darrow", { "Caer Darrow. Scholomance is under that keep.", "An island of bad decisions. Let's be careful." })
zoneA("Caverns of Time", { "The Caverns of Time. Bronze dragons, and a lot of history.", "I wouldn't poke anything in there." })
zoneA("Cenarion Hold", { "Cenarion Hold. The Circle stands between us and the hives.", "A fortress in the waste. I'm glad it's here." })
zoneA("Chillwind Camp", { "Chillwind Camp. Our camp at the south edge of these fields.", "Set your hearth at Chillwind. The Dawn is glad of the company." })
zoneA("Corin's Crossing", { "Corin's Crossing. A ruined crossroads, thick with the Scourge.", "Don't linger in the open." })
zoneA("Crown Guard Tower", { "Crown Guard Tower. The Argent Dawn is watching the road.", "A little safety in a long, bad walk." })
zoneA("Dalson's Tears", { "Dalson's Tears. Another cauldron, another ruined farm.", "The name is doing the explaining for me." })
zoneA("Darkwhisper Gorge", { "Darkwhisper Gorge. Fel-touched, and listening.", "I don't like this cut in the mountain." })
zoneA("Darrowshire", { "Darrowshire. A little town that stood, and lost.", "The dead here remember. So should we." })
zoneA("Deadwind Pass", { "Deadwind Pass. A dead ravine with a tower at the end.", "Karazhan is still lit. That is not comforting." })
zoneA("Desolace", { "Desolace. Grey earth and centaur. Stay close.", "This land used to be a garden. Hard to believe." })
zoneA("Dire Maul", { "Dire Maul. Eldre'Thalas, what's left of it.", "Ogres, satyrs, and Highborne ghosts. Stay together." })
zoneA("Dreadmaul Hold", { "Dreadmaul Hold. Ogres, too close to the Portal.", "Let's not hang around after the fight." })
zoneA("Dreadmaul Rock", { "Dreadmaul Rock. Ogres under a rain of ash.", "Charming neighborhood." })
zoneA("Dustwallow Marsh", { "Dustwallow Marsh. Mud, fog, and crocolisks.", "Watch your step. The ground lies." })
zoneA("Eastern Plaguelands", { "The Eastern Plaguelands. This is the worst of it.", "Plague, ruins, and Stratholme at the end of the road." })
zoneA("Eastwall Tower", { "Eastwall Tower. Another Argent lookout.", "Good to see a friendly banner out here." })
zoneA("Emerald Sanctuary", { "The Emerald Sanctuary. Druids trying to heal Felwood.", "A small clean place in a dirty forest. I like them." })
zoneA("Ethel Rethor", { "Ethel Rethor. Old elven ruins and a long shore.", "The sea almost makes Desolace look gentle." })
zoneA("Everlook", { "Everlook! A goblin town in the snow.", "Set your hearth in Everlook. The fire is worth the price." })
zoneA("Faldir's Cove", { "Faldir's Cove. A hidden beach under the cliffs.", "Smugglers' water. Watch the landing." })
zoneA("Fallow Sanctuary", { "The Fallow Sanctuary. Lost and overgrown.", "I wouldn't wander off the path here." })
zoneA("Feathermoon Stronghold", { "Feathermoon Stronghold! Our island keep off the coast.", "Set your hearth at Feathermoon. The boat ride is worth it." })
zoneA("Felstone Field", { "Felstone Field. A cauldron farm. Don't breathe deep.", "The Scourge still tends this place." })
zoneA("Felwood", { "Felwood. This forest is sick. So is everything in it.", "The Legion did this. It hasn't gotten better." })
zoneA("Feralas", { "Feralas. Old night elf forest, older ruins.", "It's beautiful. The ogres and naga didn't get the hint." })
zoneA("Fire Plume Ridge", { "Fire Plume Ridge. The crater's still cooking.", "Elementals and lava. Stay on the rock." })
zoneA("Firewatch Ridge", { "Firewatch Ridge. Dark Iron patrols like this overlook.", "Good view of a bad place." })
zoneA("Frostsaber Rock", { "Frostsaber Rock. The cats den here.", "Beautiful animals. Let's not startle them." })
zoneA("Gadgetzan", { "Gadgetzan! If you can pay, they can find it.", "Set your hearth in Gadgetzan. Water costs extra. Of course it does." })
zoneA("Gahrron's Withering", { "Gahrron's Withering. The eastern cauldron.", "Nothing good grows here. Let's not test that." })
zoneA("Golakka Hot Springs", { "Golakka Hot Springs. Steaming water, short tempers.", "Nice if you like your baths with elementals." })
zoneA("Gordunni Outpost", { "Gordunni Outpost. Ogres in Feralas.", "They don't share. We don't ask twice." })
zoneA("Grimesilt Dig Site", { "The Grimesilt Dig Site. Still digging, somehow.", "Dwarves. I have to respect the commitment." })
zoneA("Hearthglen", { "Hearthglen. Scarlet Crusade ground.", "They fight the Scourge. They also fight everyone else." })
zoneA("Hive'Ashi", { "Hive'Ashi. Close enough to the Hold to keep everyone awake.", "Northern hive. Watch the swarms." })
zoneA("Hive'Regal", { "Hive'Regal. Do not go in lightly.", "A great silithid hive. Stay out unless we mean it." })
zoneA("Hive'Zora", { "Hive'Zora. The western hive, no friendlier.", "I hear them under the sand." })
zoneA("Irontree Woods", { "Irontree Woods. The trees walk.", "I would not chop anything in here." })
zoneA("Isle of Dread", { "The Isle of Dread. Naga and spray.", "The name is doing a lot of work." })
zoneA("Jadefire Run", { "Jadefire Run. Satyrs, and they've been at this a long time.", "Corruption with a smile. Let's not linger." })
zoneA("Jaedenar", { "Jaedenar. Shadow Council, Legion, bad news.", "The name alone is a warning. Stay together." })
zoneA("Jintha'Alor", { "Jintha'Alor. A whole Vilebranch city on the cliffs.", "Lots of stairs. Lots of trolls. Stay together." })
zoneA("Karazhan", { "Karazhan. Medivh's tower.", "The lights are on. I would not knock." })
zoneA("Kodo Graveyard", { "The Kodo Graveyard. So many bones.", "The kodo come here to die. Walk softly." })
zoneA("Lake Kel'Theril", { "Lake Kel'Theril. Frozen Highborne ruins.", "The ice has a memory. Walk carefully." })
zoneA("Lakkari Tar Pits", { "The Lakkari Tar Pits. Things fall in.", "Do not take a shortcut across the tar." })
zoneA("Lethlor Ravine", { "Lethlor Ravine. Black dragons like this canyon.", "I would not camp here. Just saying." })
zoneA("Light's Hope Chapel", { "Light's Hope Chapel. A small light in a dark land.", "The Argent Dawn holds this ground. I'm glad someone's here." })
zoneA("Lost Rigger Cove", { "Lost Rigger Cove. Southsea pirates.", "They'll rob us if we let them. Let's not let them." })
zoneA("Mannoroc Coven", { "Mannoroc Coven. Demons, and lots of them.", "This place feels wrong. Let's not linger." })
zoneA("Maraudon", { "Maraudon. The centaur's cavern temple. Stay together.", "Theradras is down there somewhere. Watch your step." })
zoneA("Marshal's Refuge", { "Marshal's Refuge. Researchers in a cave, and I respect that.", "Set your hearth in the Refuge if we're staying in the crater." })
zoneA("Mazthoril", { "Mazthoril. Blue dragons live in there.", "Knock softly. Or maybe don't knock at all." })
zoneA("Molten Core", { "The Molten Core. Ragnaros is down there.", "I would not go in without a small army." })
zoneA("Moonglade", { "Moonglade. The druids hid this valley well.", "Quiet, moonlit, and a relief after Felwood." })
zoneA("Morgan's Vigil", { "Morgan's Vigil. Our camp on the eastern edge.", "Set your hearth at Morgan's Vigil if we're staying in the ash." })
zoneA("Nesingwary's Expedition", { "Nesingwary's camp. He hunts anything that moves.", "Big game, bigger stories. Try to keep up." })
zoneA("Nethergarde Keep", { "Nethergarde Keep. The Kirin Tor watch the Portal from here.", "Set your hearth in Nethergarde. These walls are a comfort." })
zoneA("Nighthaven", { "Nighthaven. Even the inn feels like it's listening to the moon.", "A good place to rest, if we can be still." })
zoneA("Nijel's Point", { "Nijel's Point. Our holdfast in these hills.", "Set your hearth at Nijel's Point for Desolace." })
zoneA("Noonshade Ruins", { "Noonshade Ruins. Wastewander ground.", "Bandits in the ruins. At least the shade is honest." })
zoneA("Northpass Tower", { "Northpass Tower. The northern watch on this road.", "Wave to the Dawn, then keep going." })
zoneA("Owl Wing Thicket", { "Owl Wing Thicket. A quiet hollow in the snow.", "If anything under these trees stays quiet." })
zoneA("Pillar of Ash", { "The Pillar of Ash. Easy to see, hard to like.", "A burned landmark in a burned land." })
zoneA("Plaguewood", { "Plaguewood. Sick trees, worse shadows.", "Stratholme is close. Stay together." })
zoneA("Pool of Tears", { "The Pool of Tears. The temple sits out there.", "Wide water, worse shores. Watch the banks." })
zoneA("Rebel Camp", { "The Rebel Camp. Our foothold at the north of the jungle.", "A good place to catch your breath before the trees close in." })
zoneA("Refuge Pointe", { "Refuge Pointe. The League's camp in the Highlands.", "Set your hearth at Refuge Pointe. Good people here." })
zoneA("Rise of the Defiler", { "The Rise of the Defiler. You can feel it first.", "Demon ground. I already want to leave." })
zoneA("Ruins of Alterac", { "The Ruins of Alterac. Crushridge ogres live here now.", "A whole capital, left to the ogres. Shame." })
zoneA("Ruins of Andorhal", { "The Ruins of Andorhal. The Scourge isn't finished here.", "I wouldn't camp in these streets." })
zoneA("Ruins of Eldarath", { "The Ruins of Eldarath. A drowned Highborne city.", "The naga never really left this shore." })
zoneA("Ruins of Isildien", { "The Ruins of Isildien. Night elf stone, empty now.", "Something still walks these ruins. Let's be polite." })
zoneA("Sandsorrow Watch", { "Sandsorrow Watch. A long view over the dunes.", "Good lookout. Bad picnic spot." })
zoneA("Scholomance", { "Scholomance. A school for necromancers. Of course it is.", "The Cult of the Damned studies downstairs. Stay together." })
zoneA("Searing Gorge", { "Searing Gorge. Hot air, worse neighbors.", "The Dark Irons built this mess. Watch your boots." })
zoneA("Seradane", { "Seradane. The green dragons still watch this wood.", "Walk softly. This forest has old eyes." })
zoneA("Shadra'Alor", { "Shadra'Alor. The spider loa is remembered here.", "Watch the webs. And the priests." })
zoneA("Shatter Scar Vale", { "Shatter Scar Vale. Infernals fell here and the ground never cooled.", "Watch your step. Some of them still move." })
zoneA("Shrine of Remulos", { "The Shrine of Remulos. Cenarius's son is remembered here.", "Walk softly. This is their ground." })
zoneA("Silithus", { "Silithus. Wind, hives, and cultists.", "The silithid were here first. They haven't forgotten." })
zoneA("Sorrow Hill", { "Sorrow Hill. Graves, and Uther's Tomb nearby.", "Walk softly. This ground earned its name." })
zoneA("Starfall Village", { "Starfall Village. Our camp in the Winterspring woods.", "The night elves here watch the ruins and the dragons." })
zoneA("Steamwheedle Port", { "Steamwheedle Port. Fish, docks, and deals.", "A goblin harbor. Keep one hand on your coin purse." })
zoneA("Stranglethorn Vale", { "Stranglethorn Vale. Jungle, trolls, and everything with teeth.", "Beautiful. Also trying to kill us. So, typical." })
zoneA("Stratholme", { "Stratholme. Arthas purged this city. It never recovered.", "Scourge in one half, Scarlets in the other. Watch every door." })
zoneA("Stromgarde Keep", { "Stromgarde Keep. A broken kingdom, still worth the trip.", "Syndicate, ogres, and leftovers. Careful in the ruins." })
zoneA("Swamp of Sorrows", { "The Swamp of Sorrows. Green, wet, and full of bad ideas.", "The temple out on the water is why this place has its name." })
zoneA("Tabetha's Farm", { "Tabetha's Farm. A mage in the middle of the swamp.", "I would not pick a fight with the woman who lives here." })
zoneA("Talonbranch Glade", { "Talonbranch Glade. Our camp in northern Felwood.", "Close to Timbermaw Hold. Be polite on the way through." })
zoneA("Talrendis Point", { "Talrendis Point. Our post on Azshara's western edge.", "Grab the flight path, then watch the cliffs." })
zoneA("Tanaris", { "Tanaris. Sand, sun, and goblins with a price list.", "Cover your mouth. The wind here has opinions." })
zoneA("Temple of Arkkoran", { "The Temple of Arkkoran. Sea giants, sea problems.", "Big temple, bigger residents." })
zoneA("Temple of Atal'Hakkar", { "The Sunken Temple. Hakkar's name is still on it.", "Green dragons sank this for a reason. Stay close." })
zoneA("Terror Run", { "Terror Run. The big dinosaurs run here.", "If the ground shakes, that's not weather." })
zoneA("Terrordale", { "Terrordale. The name warned us.", "A broken village in the Plaguewood. Let's not add to it." })
zoneA("Thalanaar", { "Thalanaar. A lonely post looking out on Thousand Needles.", "Grab the flight path. It's a long way back otherwise." })
zoneA("The Altar of Zul", { "The Altar of Zul. High, old, and unfriendly.", "The view is great. The welcome is not." })
zoneA("The Bulwark", { "The Bulwark. The line at the edge of the Plaguelands.", "The Argent Dawn stands here. So do the Forsaken. Careful." })
zoneA("The Cauldron", { "The Cauldron. Stay on the rims if you can.", "That's a long way down, and it's all slag." })
zoneA("The Crystal Vale", { "The Crystal Vale. Pretty, and strange.", "A shining hollow in Silithus. I don't trust pretty out here." })
zoneA("The Dark Portal", { "The Dark Portal. This is where it all started.", "Even standing here feels like history staring back." })
zoneA("The Fungal Vale", { "The Fungal Vale. Mushrooms, and worse.", "I would not touch anything in this hollow." })
zoneA("The Harborage", { "The Harborage. A quiet draenei camp in the swamp.", "They've had a long road to end up here." })
zoneA("The Headland", { "The Headland. Long view, cold wind.", "Good place to see trouble coming." })
zoneA("The Hinterlands", { "The Hinterlands. Forest, trolls, and Wildhammer gryphons.", "Watch the cliffs. And everything in the trees." })
zoneA("The Marshlands", { "The Marshlands. Raptors and biting plants.", "Southern Un'Goro is not a stroll." })
zoneA("The Noxious Glade", { "The Noxious Glade. It smells like the name.", "Poisoned ground. Keep moving." })
zoneA("The Quagmire", { "The Quagmire. Deep mud, short tempers.", "If it looks like a path, it probably isn't." })
zoneA("The Slithering Scar", { "The Slithering Scar. Silithid. Watch the ground.", "I already want to leave." })
zoneA("The Temple of Atal'Hakkar", { "The Sunken Temple. Hakkar's name is still on it.", "Green dragons sank this for a reason. Stay close." })
zoneA("The Twin Colossals", { "The Twin Colossals. You can't miss them.", "Two big rocks, a lot of forest, and plenty of trouble." })
zoneA("Theramore Isle", { "Theramore! Jaina's keep on the marsh.", "Set your hearth in Theramore. Ships from Menethil dock here." })
zoneA("Thistleshrub Valley", { "Thistleshrub Valley. Thorns, elementals, no shade.", "I already don't like it." })
zoneA("Thorium Point", { "Thorium Point. The Brotherhood watches the Gorge from here.", "Grab the flight path. And maybe a drink of water." })
zoneA("Thunder Axe Fortress", { "Thunder Axe Fortress. Burning Blade. Careful in there.", "I do not like the look of that hold." })
zoneA("Timbermaw Hold", { "Timbermaw Hold. Earn the furbolg's trust, or stay out.", "The tunnel to Winterspring. Be polite in there." })
zoneA("Twilight Base Camp", { "The Twilight Base Camp. They preach the end of everything.", "The Hammer is here. Let's not sign up." })
zoneA("Tyr's Hand", { "Tyr's Hand. A whole Scarlet city.", "They won't be glad to see us. Or anyone." })
zoneA("Uldaman", { "Uldaman. The dwarves opened a titan vault. Of course they did.", "Troggs and ancient stone. Stay together in there." })
zoneA("Un'Goro Crater", { "Un'Goro Crater. Dinosaurs, crystals, and very little sense.", "How is this just sitting here behind Tanaris?" })
zoneA("Uther's Tomb", { "Uther's Tomb. The Lightbringer is at rest here.", "Even I can be quiet for this one." })
zoneA("Valley of Spears", { "The Valley of Spears. Maraudine ground. Heads up.", "Centaur territory. Let's not pick a fight we don't need." })
zoneA("Valor's Rest", { "Valor's Rest. A graveyard for the ones who held this line.", "We should be careful enough to not join them." })
zoneA("Valorwind Lake", { "Valorwind Lake. Pretty water, Hinterlands rules.", "Don't let the quiet fool you." })
zoneA("Western Plaguelands", { "The Western Plaguelands. Lordaeron's farms, ruined.", "The fields still grow. Don't eat anything." })
zoneA("Winterfall Village", { "Winterfall Village. Hostile furbolg in the snow.", "These ones are not the Timbermaw. Don't mix them up." })
zoneA("Winterspring", { "Winterspring. Snow, silence, and the occasional dragon.", "Bundle up. It's colder than it looks from Felwood." })
zoneA("Witch Hill", { "Witch Hill. The farms out here have a bad name.", "Something's off about this place. Stay close." })
zoneA("Zul'Farrak", { "Zul'Farrak. Sand trolls, and they were here first.", "The Farraki have a long memory. Stay close in the city." })
