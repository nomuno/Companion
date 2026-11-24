Companion - a 3D companion, quest tracker and leveling guide for WoW Forever
============================================================================

INSTALL
1. Close WoW completely.
2. Extract the zip so you get a folder called "Companion" inside your AddOns folder:
     World of Warcraft/_forever_/Interface/AddOns/Companion
   Your folder might be called _classic_ or _classic_era_ instead of _forever_;
   use the one you actually play with.
3. Start WoW. On the character screen, click AddOns and make sure Companion is enabled
   (tick "Load out of date AddOns" if it's greyed out).

COMMANDS
  /comp            show or hide the companion
  /comp guide      show or hide the leveling guide (Prev / Next / Skip buttons in the window)
  /comp options    settings (or click the gear, speaker and portrait tabs on the right edge)
  /comp recorder   how many quests have been recorded so far
  /comp export     quest data in a copyable window
  /comp config     all settings (also in Options > AddOns > Companion)
  /comp help       lists all commands

SENDING QUEST DATA BACK (thank you!)
The addon quietly records where quests are picked up, turned in and done.
Send it back either way:
  A) Type /comp export, press Ctrl+C (the text is already selected), and paste it
     into a message or a text file.
  B) Log out (so WoW saves the file), then send this file:
       World of Warcraft/_forever_/WTF/Account/<YOUR ACCOUNT>/SavedVariables/Companion.lua
     (again, _classic_ or _classic_era_ depending on your install)

Have fun!

Credits
- Route order for many guides (and the Skyborne 1-6 guide) follows TUGs' free Guidelime guides for
  WoW Forever. Thanks TUGs! Quest data: ForeverDB, Wowhead (Forever), Questie and our own recorder.
- Skyborne players (Zephras Isle) get the "Skyborne 1-6" guide automatically.
- Alliance 1-35 (0.43): rebuilt from TUGs' updated Guidelime pack (v2): new Darkshore/Westfall/
  Redridge/Duskwood/Wetlands/Ashenvale splits, Stranglethorn and Gnomeregan to 35, and the new WoW
  Forever quests TUGs added (Hall of Thanes, Darkshore, Wetlands, Teldrassil camping). Renamed guides
  remember their old names, so a saved guide and its skipped steps carry over. Thanks TUGs!
- Alliance 1-30 (0.40): Northshire / Coldridge / Shadowglen starts through Darkshore, Westfall,
  Loch Modan, Redridge, Duskwood, Ashenvale and Wetlands to 30, in the order of TUGs' Alliance
  Guidelime guides (thanks again, TUGs). Alliance dungeon quests: Deadmines, Stockade, Gnomeregan,
  Wailing Caverns, Blackfathom Deeps, and the new Hall of Thanes in Ironforge.

0.44
- Resizable window: drag the grip in the bottom-right corner (right-click it to reset), or use
  Options > General > Window size. 60%-180%, saved. /comp scale <0.6-1.8>.
- Zone histories: the first time each character enters a zone or major town/landmark she tells a
  short bit of its history; later visits sometimes retell it (at most every 2 hours per place).
  She waits until guide lines are finished. Toggle in Options > General; /comp lore replays the
  current place, /comp lore on|off|reset.
- Ore/herb callouts: mouse over a minimap blip; if it's a vein/herb and you have Mining/Herbalism,
  she points it out. Toggle in Options > General; /comp nodes [on|off].
- New voice clips: auto_lore_*.ogg and auto_node*.ogg (listed in voice_lines.tsv). Run
  generate_sound.sh to make them; until then those lines use TTS (or text only).
