# 0.73

- Navigation no longer errors when Companion_QuestHelper is disabled or has not created the quest-log cache yet (the "attempt to index field 'quests'" error on map pins). Pins still work, and they use the quest title when Quest Helper is loaded.

# 0.72

- Voice packs: each voice is now its own optional download, so you only install the voice you use. Companion keeps every voice's everyday lines (greetings, banter, praise, scolding, encouragement, level-up, quest, loot, combat, bags, reminders, time-of-day and guide lines: 300 per voice). Zone comments and zone histories (1,052 per voice) moved to Companion - Voice: Nicole, Companion - Voice: Kahani and Companion - Voice: Shelley.
- Settings > AddOns > Companion > Audio lists all three voices with a Play sample button, which one is in use, and whether the full pack is installed (green), installed but not loaded (orange, with an Enable button) or samples only (yellow, with a copyable download link).
- Choosing a voice without its pack is fine: the everyday lines are spoken and zone lines show as text. Companion never switches to a different voice to fill a gap.
- `/comp voices` prints each voice's status.
- The Companion download is about 21 MB instead of about 122 MB. After updating, install the pack for your voice and restart WoW fully (new addon folders need a restart).
- All Companion modules are versioned 0.72 with the core.

# 0.71

- 753 new female voice lines for levels 30 to 60: zone and landmark lore plus zone comments on the road from 30 to 60.
- Voices: Low (Nicole), Normal (Kahani) and High (Shelley). Most of the new High lines are the Normal voice raised in pitch for now; they will be re-recorded in Shelley's own voice later.
- New sound files need a full WoW restart, not just /reload.
- All Companion modules are versioned 0.71 with the core.

# 0.70

- Suite release for the Marker Wheel mark memory fix (see Companion - Marker Wheel).

# 0.69

- Fixed the login popup "Companion has been blocked from an action only available to the Blizzard UI". WoW: Forever forbids addons from registering COMBAT_LOG_EVENT_UNFILTERED, so Companion no longer registers it.
- The event helper now logs the event name if the game refuses a registration.

# 0.68

- Taint log: blocked and forbidden actions (ADDON_ACTION_FORBIDDEN / ADDON_ACTION_BLOCKED) are saved with a stack trace. `/comp debug taint` shows them and `/comp debug taint off` turns logging off.

# 0.65 - 0.67

- Login and tracker taint fixes. The quest tracker is hidden with a state driver instead of Show hooks, and Gather no longer changes CVars at login.

# 0.61

- Settings moved into the game's Settings > AddOns > Companion pages (no separate settings window). `/comp options`, `/comp config` and the gear button open them.

# 0.59 - 0.63

- Features split into separate Companion modules: Gather, Quest Helper, Nameplates, Loot and Reminders, then the new Marker Wheel in 0.63. Each module can be turned on or off, and modules share Companion's settings.

# 0.55 - 0.58

- Round window style with the wisp as a marker on the ring, and a slim floating title bar for both the round and square styles.

# 0.49 - 0.50

- Each voice slot uses its own recorded voice.
- Her lines can go to the window, your chat frame, or both.

# 0.44

- Resizable window (drag the corner grip, right-click to reset, or `/comp scale 0.6-1.8`).
- Zone histories: the first time you enter a zone or major landmark she tells a short bit of its lore. `/comp lore` replays it.

# 0.39 - 0.40

- Voice pitch choice (Low, Normal, High) and clips for lines that use your name.
- Alliance characters get their own zone lines.

# 0.22 - 0.34

- First versions: a 3D companion that faces your next objective, a guide wisp, idle emotes, reactions to combat, quests, level-ups and AFK, banter, and voiced lines with text-to-speech as a fallback.

# Companion - Gather

# 0.72

- Version bump with the Companion 0.72 suite.

# 0.71

- Version bump with the Companion 0.71 suite.

# 0.66

- No longer changes CVars at login, as part of the login taint fix.

# 0.63k - 0.63m

- Soft targeting never picks friendly units; only a confirmed friendly, living NPC or player pauses it.
- Detection range raised to 25 yards (the client may cap it lower).

# 0.59 - 0.60

- Split out of Companion (0.59), then became a Companion module (0.60).

# 0.44 - 0.46

- Ore and herb callouts when you have Mining or Herbalism. Uses the game's interact soft target, with the minimap tooltip as a fallback, and puts a glow on the node's nameplate.

# Companion - Loot

# 0.72

- Version bump with the Companion 0.72 suite.

# 0.71

- Version bump with the Companion 0.71 suite.

# 0.60

- Moved out of Companion into its own module.

# 0.58

- First version: a movable anchor for Need/Greed/Pass loot-roll frames, with lock and scale settings. Changes wait until combat ends if the client protects the frames.

# Companion - Marker Wheel

# 0.72

- Version bump with the Companion 0.72 suite.

# 0.71

- Version bump with the Companion 0.71 suite.

# 0.70

- Tap cycling remembers marks. Each tap cycles skull, cross, square, moon, triangle, diamond, circle, star, then none on the same target. A new target starts at the next unused mark, and marks already on other units are skipped. The memory clears when you change zones.

# 0.69

- Fixed the login "blocked from an action only available to the Blizzard UI" popup that only showed with the Marker Wheel enabled.

# 0.67 - 0.68

- Secure frames are created after login, out of combat.

# 0.62 - 0.64

- Tap the key to cycle marks, hold it to open the wheel. Marks already used on other units are always skipped.

# 0.63e - 0.63i

- Larger round target portrait with a thin ring, and wheel scale from 0.6 to 1.8.

# 0.63 (module)

- First version: a secure radial raid-marker wheel on one keybind (layout inspired by EasyMarks Forever).

# Companion - Nameplates

# 0.72

- Version bump with the Companion 0.72 suite.

# 0.71

- Version bump with the Companion 0.71 suite.

# 0.63j

- Class buff ring covers every class with a self-buff to keep up, including Forever's custom spells.

# 0.62

- Yellow threat brackets and outline when you are about to lose threat.
- Item objectives on the quest-mob icon use a loot pouch, kill objectives use crossed swords.

# 0.61

- Cast bar under the health bar. Quest icons only for quests in your log. Round icons.

# 0.60

- Raid target mark left of the name. Quest-mob icon shows kill or item objectives.

# 0.60 (module)

- Moved out of Companion into its own module.

# 0.56 - 0.57

- First version: class buff ring on the portrait, Companion-style enemy nameplates with threat colours (look follows Threat Plates), and the quest-mob icon. Plates switch off when Threat Plates is loaded.

# Companion - Quest Helper

# 0.72

- Version bump with the Companion 0.72 suite.

# 0.71

- Version bump with the Companion 0.71 suite.

# 0.66

- Quest tracker hiding uses a state driver instead of Show hooks (login taint fix).

# 0.60

- Guides, tracker, auto quest and dungeon quests moved out of Companion into this module.

# 0.52

- Scrollable guide list with Horde and Alliance tabs and search.
- "Also here" shows other nearby objectives with live counts.

# 0.51

- Visiting a class trainer completes "train" steps.

# 0.48

- Quest item button for the current guide step.

# 0.43

- Alliance 1-35 rebuilt from TUGs' updated Guidelime pack. Renamed guides keep their saved progress and skipped steps.

# 0.40

- Alliance guides 1-30 and Alliance dungeon quests. Skyborne guide for levels 1-6.

# 0.37 - 0.38

- Routes checked against TUGs' Guidelime guides. Quest tracker scrolls when it has more quests than fit.

# 0.22 - 0.32

- Leveling guide with Prev / Next / Skip, quest tracker, quest recorder (`/comp recorder`, `/comp export`), guide chaining and the dungeon ready check.

# Companion - Reminders

# 0.72

- Version bump with the Companion 0.72 suite.

# 0.71

- Version bump with the Companion 0.71 suite.

# 0.60

- Moved out of Companion into its own module.

# 0.28

- First version: spoken reminders for food buffs, ammo and class self-buffs (`/comp remind`).
