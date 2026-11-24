# Companion

3D companion for WoW: Forever who talks, reacts and points the way: a portrait window with her model, a compass wisp toward your next objective, zone lore and banter in three voices (Nicole, Kahani, Shelley). Every voice's everyday lines are built in; full voices (zone comments and zone histories) are separate voice packs. Gathering, quest guides, nameplates, marker wheel, loot and reminders are separate Companion modules.

**Version 0.72** · Interface 16001 · WoW: Forever · by Darth

## Install with WowUp

1. In WowUp, pick your WoW: Forever installation.
2. Go to **Get Addons** → **Install from URL**.
3. Paste `https://github.com/nomuno/Companion` and install. WowUp checks this repo's releases for updates.

## Manual install

Download `Companion-0.72-forever.zip` from the [latest release](https://github.com/nomuno/Companion/releases/latest) and unzip it into `World of Warcraft/_forever_/Interface/AddOns`.

## Folders in this repo

- `Companion/` — Companion (core)
- `Companion_Gather/` — Companion - Gather: Companion module (requires Companion): ore and herb callouts, a glow on the node's nameplate, and herb/ore-only soft targeting for WoW: Forever.
- `Companion_Loot/` — Companion - Loot: Companion module (requires Companion): a movable, scalable anchor for Need/Greed/Pass loot-roll frames so they stop covering your action bars.
- `Companion_MarkerWheel/` — Companion - Marker Wheel: Companion module (requires Companion): one keybind for raid marks. Tap to cycle marks on your target, hold to open a radial marker wheel. Works in combat.
- `Companion_Nameplates/` — Companion - Nameplates: Companion module (requires Companion): Companion-style enemy nameplates with threat colours, cast bars, raid marks and quest-mob icons, plus a class self-buff ring on the portrait.
- `Companion_QuestHelper/` — Companion - Quest Helper: Companion module (requires Companion): Horde and Alliance leveling guides, a scrolling quest tracker, auto-accept and turn-in, a quest item button, and dungeon quest guides for WoW: Forever.
- `Companion_Reminders/` — Companion - Reminders: Companion module (requires Companion): spoken reminders for food buffs, ammo, class self-buffs, pets and weapon buffs, never in combat.

The release zip contains all of them; each module can be turned off in the AddOns list.

## What's new in 0.72

- Voice packs: each voice is now its own optional download, so you only install the voice you use. Companion keeps every voice's everyday lines (greetings, banter, praise, scolding, encouragement, level-up, quest, loot, combat, bags, reminders, time-of-day and guide lines: 300 per voice). Zone comments and zone histories (1,052 per voice) moved to Companion - Voice: Nicole, Companion - Voice: Kahani and Companion - Voice: Shelley.
- Settings > AddOns > Companion > Audio lists all three voices with a Play sample button, which one is in use, and whether the full pack is installed (green), installed but not loaded (orange, with an Enable button) or samples only (yellow, with a copyable download link).
- Choosing a voice without its pack is fine: the everyday lines are spoken and zone lines show as text. Companion never switches to a different voice to fill a gap.
- `/comp voices` prints each voice's status.
- The Companion download is about 21 MB instead of about 122 MB. After updating, install the pack for your voice and restart WoW fully (new addon folders need a restart).
- All Companion modules are versioned 0.72 with the core.

---

This repository is published automatically from RobForge (Darth's self-hosted addon site). Changes made directly on GitHub are overwritten by the next publish.
