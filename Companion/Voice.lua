-- Companion: Voice playback (sound clips or the game's built-in text-to-speech).

local _, ns = ...

local function GetBestVoice()
    local voices = C_VoiceChat and C_VoiceChat.GetTtsVoices and C_VoiceChat.GetTtsVoices()
    if not voices or #voices == 0 then return 0 end
    for _, v in ipairs(voices) do
        local name = (v.name or ""):lower()
        if name:find("neural") or name:find("natural") or name:find("aria") or name:find("jenny")
            or (not name:find("guy") and (name:find("zira") or name:find("female") or name:find("woman")
            or name:find("samantha") or name:find("hazel"))) then
            return v.voiceID
        end
    end
    return voices[1].voiceID or 0
end

local function PlayTTS(text)
    if not text or text == "" then return end
    local voiceID = ns.db.voiceID or GetBestVoice()
    if C_VoiceChat.StopSpeakingText then C_VoiceChat.StopSpeakingText() end
    pcall(C_VoiceChat.SpeakText, voiceID, text, ns.db.voiceRate or 0, ns.db.voiceVolume or 85)
end

-- ===================== CLIP PATHS (0.39) =====================
-- sounds/<voice>/<pitch>/<file>.ogg, e.g. sounds\female\high\auto_praise_3.ogg.
-- No file-exists API: try the chosen pitch, then normal, then the old flat sounds\ path
-- (PlaySoundFile just returns false for a missing file).
ns.defaults.voiceGender = "female"
ns.defaults.voicePitch = "normal"
ns.defaults.petNameClips = true        -- {name} lines play clips that say a pet name instead
ns.VOICE_PITCHES = { "low", "normal", "high" }
-- 0.49: each slot is now its own ElevenLabs voice (stored values stay low/normal/high)
ns.VOICE_NAMES = { low = "Nicole", normal = "Kahani", high = "Shelley" }
local VOICE_ALIAS = { nicole = "low", kahani = "normal", shelley = "high", low = "low", normal = "normal", high = "high" }
function ns.ResolveVoiceSlot(s) return s and VOICE_ALIAS[s:lower()] end
ns.VOICE_GENDERS = { female = true }   -- male: coming later
local PITCH_OK = { low = true, normal = true, high = true }

function ns.ClipPath(file, pitch, gender)
    gender = gender or (ns.db and ns.db.voiceGender) or "female"
    if not ns.VOICE_GENDERS[gender] then gender = "female" end
    pitch = pitch or (ns.db and ns.db.voicePitch) or "normal"
    if not PITCH_OK[pitch] then pitch = "normal" end
    return ns.SOUND_DIR .. gender .. "\\" .. pitch .. "\\" .. file
end

-- Returns true if one of the candidate paths played.
function ns.PlayClipFile(file)
    if not file or file == "" then return false end
    local tried = {}
    for _, path in ipairs({ ns.ClipPath(file), ns.ClipPath(file, "normal"), ns.SOUND_DIR .. file }) do
        if not tried[path] then
            tried[path] = true
            local ok, willPlay = pcall(PlaySoundFile, path, "Master")
            if ok and willPlay then ns.lastClipPath = path return true end
        end
    end
    return false
end

local function PlayClip(soundFile)
    if not soundFile or soundFile == "" then
        soundFile = ns.fallbackSounds[math.random(#ns.fallbackSounds)]
    end
    return ns.PlayClipFile(soundFile)
end

function ns.SetVoicePitch(p)
    if not PITCH_OK[p] then return false end
    ns.db.voicePitch = p
    if ns.UpdateAudioOptions then ns.UpdateAudioOptions() end
    if ns.RefreshConfig then pcall(ns.RefreshConfig) end
    return true
end
local function VoiceCmd(rest)
    local slot = ns.ResolveVoiceSlot((rest or ""):match("%a+"))
    if slot and ns.SetVoicePitch(slot) then
        ns.Print("voice: " .. ns.VOICE_NAMES[slot])
        ns:SpeakCategory("praise", true)
    else
        ns.Print("usage: /comp voice nicole|kahani|shelley (now " .. ns.VOICE_NAMES[ns.db.voicePitch or "normal"] .. ")")
    end
end
ns:AddCommand("pitch", VoiceCmd)
ns:AddCommand("voice", VoiceCmd)

-- ===================== SPEECH: ns:Say =====================
ns.defaults.chattiness = "normal"      -- quiet | normal | chatty

local GLOBAL_CD = 6                    -- seconds between any two lines
local DEFAULT_CAT_CD = 20              -- per-category cooldown unless listed below
ns.CAT_CD = {
    praise = 15, scolding = 20, encouragement = 0, levelUp = 0,
    questAccept = 8, questTurnIn = 8, idle = 60, welcome = 30,
    guideStep = 0, guideArrive = 0, guideTurnIn = 0, guideHearth = 0, guideTrain = 0, guideDone = 0, guideNext = 0, dungeonMissing = 0, classQuest10 = 0,
    loot = 45, lootGood = 20, lootRare = 5, lootEpic = 0,
    lowMana = 60, bagsFull = 180, bagsAlmost = 300, rareMob = 30, eliteMob = 60,
    lowDurability = 600, partyJoin = 30, zone = 20,
    timeMorning = 1800, timeEvening = 1800, timeNight = 1800,
    session1h = 0, session2h = 0, session3h = 0, banter = 60,
    -- reminders throttle themselves (Reminders.lua); these just stop double lines
    remindFood = 30, remindFoodExpiring = 30, remindAmmo = 30, remindAmmoLow = 10, remindAmmoEmpty = 10,
    remindBuff = 10, remindBuffExpiring = 10, remindBuffs = 10, remindPet = 30, remindWeapon = 10,
    remindBattleShout = 0,
    lore = 0, nodeOre = 0, nodeHerb = 0,   -- 0.44: they throttle themselves (Lore.lua, Nodes.lua)
}
-- Skip the global cooldown (they still respect their own category cooldown).
ns.HIGH_PRIORITY = {
    levelUp = true, encouragement = true, lootEpic = true,
    guideStep = true, guideArrive = true, guideTurnIn = true,
    guideHearth = true, guideTrain = true, guideDone = true, guideNext = true, dungeonMissing = true, classQuest10 = true,
}
-- Never spoken during combat.
ns.LOW_PRIORITY = {
    banter = true, zone = true, timeMorning = true, timeEvening = true, timeNight = true,
    loot = true, lootGood = true, bagsFull = true, bagsAlmost = true,
    session1h = true, session2h = true, session3h = true, partyJoin = true, idle = true,
}
ns.CHATTY_MULT = { quiet = 0.4, normal = 1.0, chatty = 1.8 }

local lastAny, lastCat, lastIndex = -999, {}, {}
ns.speechState = { lastCat = lastCat, lastIndex = lastIndex }

function ns.ChattyMult()
    return ns.CHATTY_MULT[ns.db and ns.db.chattiness or "normal"] or 1
end

local function Fill(text, vars)
    local name = (UnitName and UnitName("player")) or "friend"
    text = text:gsub("{name}", function() return name end)
    if vars then
        text = text:gsub("{(%w+)}", function(k) return vars[k] and tostring(vars[k]) or ("{" .. k .. "}") end)
    end
    return text
end

-- Pick a random index, never the same as last time for this category.
local function PickIndex(category, n)
    if n <= 1 then return 1 end
    local i = math.random(n)
    if i == lastIndex[category] then i = (i % n) + 1 end
    return i
end
ns.PickLineIndex = PickIndex

local function Play(entry, text)
    if not ns.db.voiceEnabled then return "muted" end
    if ns.db.useCustomSounds then
        if entry and entry.sound and entry.sound ~= "" then
            if PlayClip(entry.sound) then return "clip" end
        end
        -- Generated clips (ElevenLabs batch script). If the file isn't there yet, fall back below.
        -- {name} lines have pet-name clips; off = TTS with the real name as before.
        if entry and entry.autoSound and not (entry.petClip and ns.db.petNameClips == false) then
            if ns.PlayClipFile(entry.autoSound) then return "clip" end
        end
        return "text" -- lines without a clip are text only
    end
    PlayTTS(text)
    return "tts"
end
ns.PlaySpeech = Play

-- Race fit: entries with races = {...} only play for those races. Untagged lines that
-- mention Durotar/orc things only play for Orcs and Trolls; lines about quilboar are
-- skipped for Undead (Tauren have quilboar at home).
local ORC_WORDS = { "Durotar", "Thrall", "scorpid" }
local KALIMDOR_WORDS = { "quilboar" }
local ORC_RACES = { Orc = true, Troll = true }
local UNDEAD = { Scourge = true, Undead = true }
local function Mentions(text, words)
    if not text then return false end
    for _, w in ipairs(words) do if text:find(w, 1, true) then return true end end
    return false
end
-- 0.40: faction fit. faction = "Alliance"/"Horde" lines only play for that faction; untagged lines
-- with Horde words are skipped for Alliance characters.
local HORDE_WORDS = { "Horde", "Thrall", "Orgrimmar", "Lok'tar", "Dark Lady", "Durotar", "Warchief" }
function ns.PlayerFaction()
    local ok, f = pcall(UnitFactionGroup, "player")
    return ok and f or nil
end
function ns.LineFitsPlayer(entry)
    if not entry then return false end
    local fac = ns.PlayerFaction()
    if entry.faction and fac and entry.faction ~= fac then return false end
    if fac == "Alliance" and not entry.faction and Mentions(entry.text, HORDE_WORDS) then return false end
    local raceName, raceFile = UnitRace and UnitRace("player")
    if entry.races then
        for _, r in ipairs(entry.races) do
            if r == raceFile or r == raceName then return true end
        end
        return false
    end
    if not (raceFile or raceName) then return true end
    if not (ORC_RACES[raceFile or ""] or ORC_RACES[raceName or ""]) and Mentions(entry.text, ORC_WORDS) then return false end
    if (UNDEAD[raceFile or ""] or UNDEAD[raceName or ""]) and Mentions(entry.text, KALIMDOR_WORDS) then return false end
    return true
end

-- ns:Say(category, opts)
--   opts.vars     placeholder values ({step}, {target}, {zone}, {item})
--   opts.text     say this exact text (still counts for the category's cooldowns)
--   opts.chance   0..1 random chance, scaled by the Chattiness setting
--   opts.force    ignore cooldowns, chance and combat (test buttons, /comp say)
--   opts.priority treat as high priority (skip the global cooldown)
--   opts.fallback text to show silently if the line is blocked by cooldowns
-- Returns the text said, or nil plus a reason.
function ns:Say(category, opts)
    opts = opts or {}
    if not ns.db then return nil, "nodb" end
    if not (ns.frame and ns.frame:IsShown()) then return nil, "hidden" end
    local now = GetTime()
    if not opts.force then
        if opts.chance and math.random() > math.min(1, opts.chance * ns.ChattyMult()) then
            return nil, "chance"
        end
        if ns.LOW_PRIORITY[category] and UnitAffectingCombat and UnitAffectingCombat("player") then
            return nil, "combat"
        end
        local cd = ns.CAT_CD[category] or DEFAULT_CAT_CD
        local blocked
        if lastCat[category] and now - lastCat[category] < cd then blocked = "category" end
        if not blocked and not (opts.priority or ns.HIGH_PRIORITY[category]) and now - lastAny < GLOBAL_CD then
            blocked = "global"
        end
        if blocked then
            if opts.fallback then ns:ShowNavLine(opts.fallback) end
            return nil, blocked
        end
    end

    local entry, text
    if opts.text then
        text = opts.text
        if opts.sound then entry = { autoSound = opts.sound } end
    else
        local pool = ns.dialogue[category]
        if not pool or #pool == 0 then return nil, "empty" end
        local i = PickIndex(category, #pool)
        for _ = 1, 12 do
            if ns.LineFitsPlayer(pool[i]) then break end
            i = PickIndex(category, #pool)
        end
        if not ns.LineFitsPlayer(pool[i]) then return nil, "norace" end
        lastIndex[category] = i
        entry = pool[i]
        text = entry.text
    end
    text = Fill(text, opts.vars)
    lastAny, lastCat[category] = now, now
    ns:ShowLine(text)
    local how = Play(entry, text)
    return text, how
end

-- Old entry point; existing callers keep working (subject to cooldowns).
function ns:SpeakCategory(category, force)
    return ns:Say(category, { force = force })
end

-- /comp sounddebug plays one clip and reports what the game said.
ns:AddCommand("sounddebug", function()
    local path = ns.ClipPath("praise_1.ogg")
    local ok, willPlay, handle = pcall(PlaySoundFile, path, "Master")
    ns.Print("trying " .. path)
    ns.Print("played: " .. tostring(ok and willPlay) .. (ok and "" or (" error: " .. tostring(willPlay))))
    print("  sound enabled: " .. tostring(GetCVar("Sound_EnableAllSound")) .. ", SFX: " .. tostring(GetCVar("Sound_EnableSFX"))
        .. ", master volume: " .. tostring(GetCVar("Sound_MasterVolume")))
end)


-- ===================== GENERATED CLIP NAMES =====================
-- Every fixed line (no {placeholders}) without a recorded clip gets a predictable
-- file name: auto_<category>_<n>.ogg, and zone lines auto_zone_<place>_<n>.ogg.
-- The voice generation script reads voice_lines.tsv (same names) to generate them.
-- Only ADD new lines at the end of a category, or the numbering shifts.
-- 0.39: lines whose only placeholder is {name} get a clip too, auto_<category>_<n>.ogg with the
-- same index scheme (those numbers were unused before, so nothing shifts). The clip says a pet
-- name (export_lines.lua picks it; voice_lines.tsv records it); the window/TTS keep your name.
local PET_NAMES = { "Honey", "Babe", "Lover", "Friend", "Master" }
function ns.PetNameFor(cat, i)
    local h = 0
    for c in (cat .. "_" .. i):gmatch(".") do h = (h * 31 + c:byte()) % 1000003 end
    return PET_NAMES[(h % #PET_NAMES) + 1]
end
local function OnlyName(text)
    return text:find("{name}", 1, true) and not text:gsub("{name}", ""):find("{", 1, true)
end
ns.OnlyNamePlaceholder = OnlyName
function ns.ZoneSlug(place)
    return (place:lower():gsub("[^%w]+", "_"):gsub("^_+", ""):gsub("_+$", ""))
end

for cat, pool in pairs(ns.dialogue) do
    for i, e in ipairs(pool) do
        if (not e.sound or e.sound == "") and not e.text:find("{", 1, true) then
            e.autoSound = "auto_" .. cat .. "_" .. i .. ".ogg"
        elseif (not e.sound or e.sound == "") and OnlyName(e.text) then
            e.autoSound, e.petClip = "auto_" .. cat .. "_" .. i .. ".ogg", true
        end
    end
end
