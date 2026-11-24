-- Options for the Marker Wheel module. Builds Settings window pages and a Blizzard AddOns subcategory.
local ns = _G.Companion
if not ns then return end

ns.RegisterModule("markwheel", {
    title = "Marker Wheel",
    addon = "Companion_MarkerWheel",
    OnSetEnabled = function(on)
        local db = ns.db or {}
        if on then
            if ns.SetMarkWheel then ns.SetMarkWheel(db.markWheel ~= false) end
        else
            local pref = db.markWheel
            if ns.SetMarkWheel then ns.SetMarkWheel(false) end
            db.markWheel = pref ~= false
            if ns.MarkWheel and ns.MarkWheel.Hide then ns.MarkWheel:Hide() end
        end
    end,
})

local function Fill()
Header("Marker wheel", "markwheel", "Marker Wheel")
ModuleEnableCheckbox("markwheel")

Check("Raid-marker wheel: hold its key over a unit, release on a mark", "markWheel", ns.SetMarkWheel)
Check("Tap to cycle markers", "markWheelTap", ns.SetMarkWheelTap)
Slider("Hold time (seconds) to open the wheel", "markWheelHoldTime", 0.15, 0.6, 0.05, ns.SetMarkWheelHoldTime, "%.2f", 0.25)
Text("A shorter tap cycles the mark on the unit under the cursor, or your target. Hold at least this long to open the wheel.", "GameFontDisableSmall", LEFT + 8)
y = y - 22
Text("Tapping skips marks already used on other units. A new unit starts at the first free mark (skull, then cross, and so on); keep tapping the same unit to cycle the free marks until you like it.", "GameFontDisableSmall", LEFT + 8)
y = y - 28
do  -- scale slider, same look as the window size slider
    local M = ns.Marker
    Text("Wheel size:", "GameFontHighlight")
    y = y - 22
    local s = TryCreate("Slider", "CompanionMarkWheelScale", content, "OptionsSliderTemplate")
    s:SetPoint("TOPLEFT", LEFT + 2, y)
    s:SetMinMaxValues(M.SCALE_MIN, M.SCALE_MAX)
    s:SetValueStep(0.05)
    safe(s.SetObeyStepOnDrag, s, true)
    s:SetWidth(250)
    if s.Low then s.Low:SetText("Small") end
    if s.High then s.High:SetText("Large") end
    local c = Register({ kind = "slider", key = "markWheelScale", widget = s })
    local function Label(v) if s.Text then s.Text:SetText(string.format("Scale: %d%%", v * 100 + 0.5)) end end
    s:SetScript("OnValueChanged", function(self, v)
        if c.updating or not ns.db then return end
        Label(ns.SetMarkWheelScale(v))
    end)
    c.refresh = function() c.updating = true local v = M.Scale() s:SetValue(v) Label(v) c.updating = false end
    y = y - 40
    Text("Size changes made in combat apply when combat ends.", "GameFontDisableSmall", LEFT + 8)
    y = y - 10
    -- keybind button: click, press a key; right-click or Escape clears
    Text("Key (tap to cycle, hold for the wheel):", "GameFontHighlight")
    y = y - 22
    local b = Button("", 180, nil)
    b:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    local kc = Register({ kind = "bind", widget = b })
    local function Show(msg) b:SetText(msg or (M.CurrentKey() or "Not bound")) end
    kc.refresh = function() if not b.listening then Show() end end
    local function Stop(msg)
        b.listening = nil
        safe(b.EnableKeyboard, b, false)
        Show() if msg then ns.Print(msg) end
    end
    local function Set(key)
        local ok, why = M.SetKey(key)
        Stop(not ok and (why == "combat" and "marker wheel: can't change key bindings in combat" or "marker wheel: binding failed") or nil)
    end
    M.SettingsBindButton = b
    b:SetScript("OnClick", function(self, button)
        if InCombatLockdown and InCombatLockdown() then Stop("marker wheel: can't change key bindings in combat") return end
        if button == "RightButton" then Set(nil) return end
        self.listening = true
        self:SetText("Press a key...  (Esc clears)")
        safe(self.EnableKeyboard, self, true)
        safe(self.SetPropagateKeyboardInput, self, false)
    end)
    b:SetScript("OnKeyDown", function(self, key)
        if not self.listening then return end
        if key == "ESCAPE" then Set(nil) return end
        local full = M.KeyFromPress(key, IsAltKeyDown and IsAltKeyDown(), IsControlKeyDown and IsControlKeyDown(), IsShiftKeyDown and IsShiftKeyDown())
        if full then Set(full) end
    end)
    b:SetScript("OnHide", function(self) if self.listening then Stop() end end)
    y = y - 30
    Text("Right-click the button to clear. Also in Key Bindings > AddOns > Companion.", "GameFontDisableSmall", LEFT + 8)
    y = y - 16
end
Header("How to use", "markwheel")
for _, line in ipairs(ns.Marker.HOWTO) do
    local fs = Text(line, "GameFontHighlight", LEFT + 8)
    fs:SetWidth(PANEL_W - 2 * LEFT - 16)
    if fs.SetWordWrap then fs:SetWordWrap(true) end
    local h = fs.GetStringHeight and tonumber(fs:GetStringHeight()) or 0
    local est = 15 * math.ceil(#line * 6.5 / (PANEL_W - 2 * LEFT - 16))   -- wrapped height may not be known yet
    if h < est then h = est end
    y = y - h - 6
end

end

if ns.BindOptEnv then ns.BindOptEnv(Fill) end
Fill()
