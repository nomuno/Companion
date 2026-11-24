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
