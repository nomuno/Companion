-- Companion: quick option pages (General, Audio, Models) in Settings > AddOns > Companion (SettingsUI.lua). 0.61: the standalone settings window is gone.

local _, ns = ...

local PANEL_PAD  = 18

local panels = {}
ns.OptionsPanels = panels

local function NewPanel(key, titleText, w, h)
    local p = ns.AddSettingsPage(key, titleText, h)
    local t = p:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    t:SetPoint("TOPLEFT", PANEL_PAD, -10)
    t:SetText(titleText)
    p.key = key
    panels[key] = p
    return p
end

local function Btn(parent, text, w, x, y, onClick)
    local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    b:SetSize(w, 22)
    b:SetPoint("TOPLEFT", x, y)
    if text then b:SetText(text) end
    if onClick then b:SetScript("OnClick", onClick) end
    return b
end

local function Label(parent, text, y, font)
    local l = parent:CreateFontString(nil, "OVERLAY", font or "GameFontNormal")
    l:SetPoint("TOPLEFT", PANEL_PAD + 2, y)
    l:SetText(text)
    return l
end

-- ===================== GENERAL (0.48: only window options; the rest lives on its own page) =====================
local general = NewPanel("general", "General", 300, 200)
Label(general, "Companion window:", -44)
local lockToggle = Btn(general, nil, 150, PANEL_PAD, -62)
Label(general, "Window size:", -96)
local scaleSlider = CreateFrame("Slider", "CompanionScaleSlider", general, "OptionsSliderTemplate")
scaleSlider:SetPoint("TOPLEFT", PANEL_PAD + 2, -118)
scaleSlider:SetMinMaxValues(ns.SCALE_MIN or 0.6, ns.SCALE_MAX or 1.8)
scaleSlider:SetValueStep(0.05)
scaleSlider:SetObeyStepOnDrag(true)
scaleSlider:SetWidth(250)
scaleSlider.Low:SetText("Small")
scaleSlider.High:SetText("Large")
local scaleBusy = false
scaleSlider:SetScript("OnValueChanged", function(self, value)
    if scaleBusy or not ns.db then return end
    scaleBusy = true
    local v = ns.SetWindowScale and ns.SetWindowScale(value) or value
    if self.Text then self.Text:SetText(string.format("Scale: %d%%", v * 100 + 0.5)) end
    scaleBusy = false
end)
ns.ScaleSlider = scaleSlider
function ns.UpdateScaleSlider()
    if scaleBusy or not ns.db then return end
    scaleBusy = true
    local v = ns.db.windowScale or 1
    scaleSlider:SetValue(v)
    if scaleSlider.Text then scaleSlider.Text:SetText(string.format("Scale: %d%%", v * 100 + 0.5)) end
    scaleBusy = false
end
Label(general, "Other options are in the Companion tabs under Settings > AddOns.", -156, "GameFontDisableSmall")
Label(general, "Commands: /comp options, /comp guide, /comp lore, /comp scale", -172, "GameFontDisableSmall")
general.nextY = -196

local function UpdateGeneral()
    if not ns.db then return end
    lockToggle:SetText(ns.db.modelLocked and "Portrait: Locked" or "Portrait: Unlocked")
    ns.UpdateScaleSlider()
    if ns.RefreshConfig then pcall(ns.RefreshConfig) end
end
ns.UpdateGeneralOptions = UpdateGeneral
lockToggle:SetScript("OnClick", function()
    if ns.lockButton then ns.lockButton:Click() else ns.db.modelLocked = not ns.db.modelLocked end
    UpdateGeneral()
end)
ns.LockOptionButton = lockToggle

-- ===================== AUDIO =====================
local audio = NewPanel("audio", "Audio", 330, 400)
Label(audio, "Voice:", -44)
local voiceToggle = Btn(audio, nil, 110, PANEL_PAD, -62)
local modeToggle  = Btn(audio, nil, 170, PANEL_PAD + 118, -62)


local ttsControls = {}
local function UpdateVoiceToggle()
    voiceToggle:SetText(ns.db.voiceEnabled and "Audio: ON" or "Audio: OFF")
end
local function UpdateAudioModeUI()
    local useClips = ns.db.useCustomSounds
    modeToggle:SetText(useClips and "Mode: Sound Clips" or "Mode: Built-in TTS")
    for _, control in ipairs(ttsControls) do control:SetShown(not useClips) end
end
voiceToggle:SetScript("OnClick", function()
    ns.db.voiceEnabled = not ns.db.voiceEnabled UpdateVoiceToggle()
end)
modeToggle:SetScript("OnClick", function()
    ns.db.useCustomSounds = not ns.db.useCustomSounds UpdateAudioModeUI()
end)

local function MakeSlider(y, minV, maxV, step, low, high, key)
    local s = CreateFrame("Slider", nil, audio, "OptionsSliderTemplate")
    s:SetPoint("TOPLEFT", PANEL_PAD + 2, y)
    s:SetMinMaxValues(minV, maxV)
    s:SetValueStep(step)
    s:SetObeyStepOnDrag(true)
    s:SetWidth(280)
    s.Low:SetText(low)
    s.High:SetText(high)
    s:SetScript("OnValueChanged", function(_, value) ns.db[key] = value end)
    table.insert(ttsControls, s)
    return s
end
local rateSlider = MakeSlider(-104, -5, 5, 1, "Slow", "Fast", "voiceRate")
local volSlider  = MakeSlider(-144, 0, 100, 5, "0%", "100%", "voiceVolume")

Label(audio, "Test:", -182)
local function TestBtn(label, category, x, y)
    Btn(audio, label, 140, x, y, function() ns:SpeakCategory(category, true) end)
end
TestBtn("Test Praise", "praise", PANEL_PAD, -200)
TestBtn("Test Scold", "scolding", PANEL_PAD + 148, -200)
TestBtn("Test Encourage", "encouragement", PANEL_PAD, -228)
TestBtn("Test Quest", "questAccept", PANEL_PAD + 148, -228)

-- 0.39: voice pitch (Low / Normal / High), gender (female only for now), pet-name clips
Label(audio, "Voice:", -288)
local pitchBtns = {}
for i, p in ipairs({ "low", "normal", "high" }) do
    pitchBtns[p] = Btn(audio, ns.VOICE_NAMES[p], 92, PANEL_PAD + (i - 1) * 98, -306, function()
        ns.SetVoicePitch(p)
        ns:SpeakCategory("praise", true)   -- hear the new voice
    end)
end
Label(audio, "Voice:", -336)
local femaleBtn = Btn(audio, "Female", 92, PANEL_PAD + 50, -332, function() ns.db.voiceGender = "female" end)
local maleBtn = Btn(audio, "Male", 92, PANEL_PAD + 148, -332)
maleBtn:Disable()
maleBtn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT") GameTooltip:SetText("Male voice: coming later") GameTooltip:Show()
end)
maleBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
local petToggle = Btn(audio, nil, 290, PANEL_PAD, -362)
petToggle:SetScript("OnClick", function()
    ns.db.petNameClips = not (ns.db.petNameClips ~= false)
    ns.UpdateAudioOptions()
end)
ns.PitchButtons, ns.PetNameButton, ns.MaleVoiceButton = pitchBtns, petToggle, maleBtn
function ns.UpdateAudioOptions()
    local cur = ns.db.voicePitch or "normal"
    for p, b in pairs(pitchBtns) do
        if p == cur then b:LockHighlight() else b:UnlockHighlight() end
        b.selected = (p == cur)
    end
    femaleBtn:LockHighlight()
    petToggle:SetText((ns.db.petNameClips ~= false) and "Pet names in voice clips: ON" or "Pet names in voice clips: OFF (TTS)")
end

-- ===================== MODELS =====================
local ROW_H, VISIBLE_ROWS, LIST_W = 22, 8, 230
local models = NewPanel("models", "Models", 300, 110 + VISIBLE_ROWS * ROW_H)
Label(models, "Presets:", -44)

local scroll = CreateFrame("ScrollFrame", "CompanionPresetScroll", models, "UIPanelScrollFrameTemplate")
scroll:SetPoint("TOPLEFT", PANEL_PAD, -62)
scroll:SetSize(LIST_W, VISIBLE_ROWS * ROW_H)
local list = CreateFrame("Frame", nil, scroll)
list:SetSize(LIST_W, 1)
scroll:SetScrollChild(list)

local presetButtons = {}
ns.presetButtons = presetButtons

local function RefreshPresetHighlight()
    if not ns.db then return end
    for _, b in ipairs(presetButtons) do
        local selected = (b.presetID == ns.db.modelID)
        b.selected = selected
        if selected then b:LockHighlight() else b:UnlockHighlight() end
        local fs = b.GetFontString and b:GetFontString()
        if fs and fs.SetTextColor then
            if selected then fs:SetTextColor(0.2, 1, 0.2) else fs:SetTextColor(1, 0.82, 0) end
        end
    end
end
ns.RefreshPresetHighlight = RefreshPresetHighlight

local function SelectModel(id)
    ns.db.modelID = id
    ns:ApplyModelSettings()
    RefreshPresetHighlight()
end

local function BuildPresetList()
    for i, p in ipairs(ns.modelPresets or {}) do
        local b = presetButtons[i] or CreateFrame("Button", nil, list, "UIPanelButtonTemplate")
        presetButtons[i] = b
        b:SetSize(LIST_W - 4, ROW_H - 2)
        b:SetPoint("TOPLEFT", 0, -(i - 1) * ROW_H)
        b:SetText(p.name or ("Display " .. tostring(p.id)))
        b.presetID = p.id
        b:SetScript("OnClick", function() SelectModel(p.id) end)
        b:Show()
    end
    list:SetHeight(math.max(1, #(ns.modelPresets or {}) * ROW_H))
    RefreshPresetHighlight()
end
ns.BuildPresetList = BuildPresetList

local customY = -62 - VISIBLE_ROWS * ROW_H - 14
local customLabel = Label(models, "Custom Display ID:", customY - 4, "GameFontHighlightSmall")
local customBox = CreateFrame("EditBox", nil, models, "InputBoxTemplate")
customBox:SetSize(80, 20)
customBox:SetPoint("TOPLEFT", PANEL_PAD + 122, customY)
customBox:SetAutoFocus(false)
customBox:SetNumeric(true)
ns.customModelBox = customBox
Btn(models, "Apply", 60, PANEL_PAD + 210, customY, function()
    local id = tonumber(customBox:GetText())
    if id then SelectModel(id) end
end)
models.nextY = customY - 34   -- SettingsPanel.lua appends the 3D scene section below
audio.nextY = -392            -- and the sound debug button below the audio controls

-- ===================== STARTUP =====================
ns:On("LOGIN", function()
    ns.UpdateAudioOptions()
    UpdateVoiceToggle()
    UpdateAudioModeUI()
    rateSlider:SetValue(ns.db.voiceRate or 0)
    volSlider:SetValue(ns.db.voiceVolume or 85)
    UpdateGeneral()
    BuildPresetList()
end)

