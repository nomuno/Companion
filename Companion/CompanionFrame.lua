-- Companion: The main window.
-- Layout, top to bottom: title (lock top-left, close top-right), speech text,
-- 3D portrait, guide section (GuidePanel.lua). Settings open in Settings > AddOns > Companion (SettingsUI.lua).

local _, ns = ...

ns.defaults.companionShown = true
ns.defaults.useScene = true

-- ===================== LAYOUT CONSTANTS =====================
local MODEL_W, MODEL_H = 240, 250
ns.MODEL_W, ns.MODEL_H = MODEL_W, MODEL_H

local WIN_W      = 280
local SPEECH_TOP = -36                        -- speech text starts under the title
local SPEECH_H   = 40                         -- about 3 lines of text
local MODEL_TOP  = SPEECH_TOP - SPEECH_H - 4  -- -80
local BOTTOM_PAD = 14
local BASE_H     = -MODEL_TOP + MODEL_H + BOTTOM_PAD   -- 344 without the guide section
ns.LAYOUT = { WIN_W = WIN_W, MODEL_TOP = MODEL_TOP, BASE_H = BASE_H, SIDE_PAD = 12 }

local frame = CreateFrame("Frame", "CompanionFrame", UIParent, "BackdropTemplate")
frame:SetSize(WIN_W, BASE_H)
frame:SetPoint("CENTER")
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetClampedToScreen(true)
-- 0.48: thin border, the same as the quest tracker window
frame:SetBackdrop({
    bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 },
})
frame:SetBackdropColor(0.1, 0.1, 0.15, 0.95)
frame:SetBackdropBorderColor(0.6, 0.5, 0.3, 0.8)
frame:Hide()
ns.frame = frame

frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    -- Save the TOP edge so the window grows/shrinks downward when the guide section toggles.
    local left, top = self:GetLeft(), self:GetTop()
    if left and top then
        -- 0.44: offsets are in the window's own scale, so UIParent's height is converted too
        ns.db.point, ns.db.x, ns.db.y = "TOPLEFT", left, top - UIParent:GetHeight() / (self:GetScale() or 1)
        self:ClearAllPoints()
        self:SetPoint("TOPLEFT", UIParent, "TOPLEFT", ns.db.x, ns.db.y)
    else
        local point, _, _, x, y = self:GetPoint()
        ns.db.point, ns.db.x, ns.db.y = point, x, y
    end
end)

-- Extra height requested by bottom sections (the guide). Window resizes to fit.
local extraH = 0
function ns.SetBottomSectionHeight(h)
    extraH = h or 0
    frame:SetHeight(ns.LAYOUT.BASE_H + extraH)
end

local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOP", 0, -14)
title:SetText("Companion")

local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
close:SetPoint("TOPRIGHT", -4, -4)
close:SetScript("OnClick", function() frame:Hide() end)
frame:HookScript("OnShow", function() if ns.db then ns.db.companionShown = true end end)
frame:HookScript("OnHide", function() if ns.db then ns.db.companionShown = false end end)

-- ===================== SPEECH (top) =====================
local dialogue = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
dialogue:SetPoint("TOP", 0, SPEECH_TOP)
dialogue:SetSize(WIN_W - 30, SPEECH_H)
dialogue:SetJustifyH("CENTER")
dialogue:SetJustifyV("MIDDLE")
dialogue:SetText("Ready for action!")
ns.speechText = dialogue

-- ===================== PORTRAIT =====================
-- The 3D display comes from a renderer (SceneModel.lua or LegacyModel.lua) chosen at
-- login; both anchor their display to this input area. ns.model is a stable proxy.
local input = CreateFrame("Frame", nil, frame)
input:SetSize(MODEL_W, MODEL_H)
input:SetPoint("TOP", 0, MODEL_TOP)
input:SetFrameLevel(frame:GetFrameLevel() + 10)
ns.modelArea = input

local renderer
local model = {}
function model:SetAnimation(anim) if renderer then renderer:SetAnimation(anim) end end
function model:SetFacing(r) if renderer and renderer.SetFacing then renderer:SetFacing(r) end end
ns.model = model

function ns:GetRenderer() return renderer end

local function PickRenderer()
    if renderer then return renderer end
    if ns.db.useScene and ns.CreateSceneRenderer then
        local ok, r = pcall(ns.CreateSceneRenderer, frame, input)
        if ok and r then renderer = r
        else
            ns.Print("3D scene not available on this client, using the classic model view."
                .. (ok and "" or (" (" .. tostring(r) .. ")")))
        end
    end
    if not renderer and ns.CreateLegacyRenderer then
        renderer = ns.CreateLegacyRenderer(frame, input)
    end
    return renderer
end
ns.PickRenderer = PickRenderer

-- ===================== CAMERA & MODEL =====================

local function ApplyCamera()
    if renderer then pcall(renderer.ApplyCamera, renderer) end
end
ns.ApplyCamera = function() ApplyCamera() end
function ns.SetCamDistance(v)
    ns.db.camDistance = math.max(0.15, math.min(5.0, tonumber(v) or 1.0))
    ApplyCamera()
end
function ns.ResetView()
    ns.db.camDistance = 1.0
    ns.db.posX, ns.db.posY, ns.db.posZ = 0, 0, 0
    ApplyCamera()
end

function ns:ApplyModelSettings()
    if renderer then pcall(renderer.Apply, renderer) end
end

local function PlayTalkAnimation()
    if ns.PlayEmote then ns:PlayEmote(60, 2.0) return end
    pcall(model.SetAnimation, model, 60)
    C_Timer.After(2.0, function() pcall(model.SetAnimation, model, 0) end)
end

-- Spoken lines take over the speech area for a few seconds; otherwise it shows directions.
local lineUntil = 0
-- 0.50: speech text destination. "chat" sends her lines to the player's own chat frame
-- (local AddMessage only, never SendChatMessage) and collapses the speech area to a
-- single status line for directions; "window" is the old behaviour; "both" does both.
local SPEECH_H_CHAT = 14
local CHAT_DUP_WINDOW = 8
local lastChatText, lastChatAt = nil, -1000
function ns.SpeechTextMode()
    local m = ns.db and ns.db.speechText
    if m == "window" or m == "both" then return m end
    return "chat"
end
function ns.ApplySpeechLayout()
    if ns.ApplyWindowStyle then ns.ApplyWindowStyle() return end   -- 0.58: both styles use the title bar
    local h = (ns.SpeechTextMode() == "chat") and SPEECH_H_CHAT or SPEECH_H
    local top = SPEECH_TOP - h - 4
    dialogue:SetSize(WIN_W - 30, h)
    input:ClearAllPoints()
    input:SetPoint("TOP", 0, top)
    ns.LAYOUT.MODEL_TOP = top
    ns.LAYOUT.BASE_H = -top + MODEL_H + BOTTOM_PAD
    frame:SetHeight(ns.LAYOUT.BASE_H + extraH)
    if ns.ApplyGuideDock then ns.ApplyGuideDock() end
end
function ns.SetSpeechText(mode)
    if mode ~= "window" and mode ~= "both" then mode = "chat" end
    ns.db.speechText = mode
    if mode == "chat" then dialogue:SetText("") lineUntil = 0 end
    ns.ApplySpeechLayout()
    return mode
end
function ns.SpeechToChat(text)
    if not text or text == "" then return false end
    local now = GetTime()
    if text == lastChatText and now - lastChatAt < CHAT_DUP_WINDOW then return false end
    lastChatText, lastChatAt = text, now
    local cf = (ns.db and ns.db.speechChatFrame and _G["ChatFrame" .. ns.db.speechChatFrame]) or DEFAULT_CHAT_FRAME
    if not cf then return false end
    local name = (ns.db and ns.db.name) or "Companion"
    cf:AddMessage("|cffDA70D6" .. name .. ":|r " .. text, 1.0, 0.82, 0.95)
    return true
end
function ns:ShowLine(text)
    local mode = ns.SpeechTextMode()
    if mode ~= "chat" then
        dialogue:SetText(text)
        lineUntil = GetTime() + 4
    end
    if mode ~= "window" then ns.SpeechToChat(text) end
    PlayTalkAnimation()
end

function ns:ShowNavLine(text)
    if GetTime() < lineUntil then return end
    dialogue:SetText(text or "")
end

-- Drag to move the model, mouse wheel to zoom
local isDragging, lastX, lastY = false, 0, 0
local SENSITIVITY = 0.006

input:SetScript("OnMouseDown", function(self, button)
    if button ~= "LeftButton" or ns.db.modelLocked then return end
    isDragging = true
    lastX, lastY = GetCursorPosition()
    self:SetScript("OnUpdate", function()
        if not isDragging then return end
        local x, y = GetCursorPosition()
        ns.db.posY = (ns.db.posY or 0) + (x - lastX) * SENSITIVITY
        ns.db.posZ = (ns.db.posZ or 0) + (y - lastY) * SENSITIVITY
        ApplyCamera()
        lastX, lastY = x, y
    end)
end)

input:SetScript("OnMouseUp", function(self)
    isDragging = false
    self:SetScript("OnUpdate", nil)
end)

input:SetScript("OnMouseWheel", function(_, delta)
    if ns.db.modelLocked then return end
    local step = 0.09
    if delta > 0 then
        ns.db.camDistance = math.max(0.15, (ns.db.camDistance or 1.15) - step)
    else
        ns.db.camDistance = math.min(5.0, (ns.db.camDistance or 1.15) + step)
    end
    ApplyCamera()
end)

-- ===================== LOCK (top-left) =====================
local lockBtn = CreateFrame("Button", nil, frame)
lockBtn:SetSize(24, 24)
lockBtn:SetPoint("TOPLEFT", 12, -12)
lockBtn:SetFrameLevel(input:GetFrameLevel() + 1)
ns.lockButton = lockBtn

local function UpdateLockButton()
    local locked = ns.db.modelLocked
    lockBtn:SetNormalTexture(locked and "Interface\\Buttons\\LockButton-Locked-Up" or "Interface\\Buttons\\LockButton-Unlocked-Up")
    lockBtn:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
    input:EnableMouse(not locked)
    input:EnableMouseWheel(not locked)
end

lockBtn:SetScript("OnClick", function()
    ns.db.modelLocked = not ns.db.modelLocked
    UpdateLockButton()
end)

-- ===================== SIZE (0.44) =====================
-- The whole window (speech, 3D model, guide section) scales as one, so
-- every piece keeps its layout at any size. Drag the grip in the bottom-right corner, or use the
-- Scale slider in Options > General. Saved in CompanionDB.windowScale. The top-left corner stays put.
ns.defaults.windowScale = 1.0
ns.SCALE_MIN, ns.SCALE_MAX = 0.6, 1.8

function ns.ClampScale(s)
    s = tonumber(s) or 1
    s = math.max(ns.SCALE_MIN, math.min(ns.SCALE_MAX, s))
    return math.floor(s * 100 + 0.5) / 100
end

function ns.SetWindowScale(s, noSave)
    s = ns.ClampScale(s)
    local old = frame:GetScale() or 1
    local left, top = frame:GetLeft(), frame:GetTop()
    frame:SetScale(s)
    if left and top and old > 0 then
        -- keep the top-left corner on the same spot of the screen
        local x, y = left * old / s, (top * old - UIParent:GetHeight()) / s
        frame:ClearAllPoints()
        frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", x, y)
        if ns.db then ns.db.point, ns.db.x, ns.db.y = "TOPLEFT", x, y end
    end
    if ns.db and not noSave then ns.db.windowScale = s end
    if ns.UpdateScaleSlider then ns.UpdateScaleSlider() end
    return s
end

local grip = CreateFrame("Button", "CompanionResizeGrip", frame)
grip:SetSize(16, 16)
grip:SetPoint("BOTTOMRIGHT", -6, 6)
grip:SetFrameLevel(input:GetFrameLevel() + 2)
grip:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
grip:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
grip:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
grip:EnableMouse(true)
ns.resizeGrip = grip

-- Scale from a drag: how far the cursor is from the window's top-left, against the window's size.
function ns.ScaleFromDrag(startScale, startDX, startDY, dx, dy)
    local rx = startDX > 1 and dx / startDX or 1
    local ry = startDY > 1 and dy / startDY or 1
    return ns.ClampScale(startScale * math.max(rx, ry))
end

local drag
grip:SetScript("OnMouseDown", function(self, button)
    if button ~= "LeftButton" then return end
    local s = frame:GetScale() or 1
    local left, top = frame:GetLeft(), frame:GetTop()
    if not (left and top) then return end
    local ui = UIParent:GetEffectiveScale() or 1
    local cx, cy = GetCursorPosition()
    cx, cy = cx / ui, cy / ui
    -- top-left of the window in UIParent units
    drag = { s = s, lx = left * s, ty = top * s }
    drag.dx, drag.dy = cx - drag.lx, drag.ty - cy
    self:SetScript("OnUpdate", function()
        if not drag then return end
        local x, y = GetCursorPosition()
        x, y = x / ui, y / ui
        local ns2 = ns.ScaleFromDrag(drag.s, drag.dx, drag.dy, x - drag.lx, drag.ty - y)
        if ns2 ~= (frame:GetScale() or 1) then ns.SetWindowScale(ns2) end
    end)
end)
grip:SetScript("OnMouseUp", function(self)
    drag = nil
    self:SetScript("OnUpdate", nil)
end)
grip:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Drag to resize")
    GameTooltip:AddLine("Right-click: reset size", 1, 1, 1)
    GameTooltip:Show()
end)
grip:SetScript("OnLeave", function() GameTooltip:Hide() end)
grip:RegisterForClicks("RightButtonUp")
grip:SetScript("OnClick", function(_, button) if button == "RightButton" then ns.SetWindowScale(1) end end)

ns:AddCommand("scale", function(rest)
    local v = tonumber((rest or ""):match("[%d%.]+"))
    if v then ns.Print("window scale: " .. ns.SetWindowScale(v))
    else ns.Print(string.format("usage: /comp scale %.1f-%.1f (now %.2f)", ns.SCALE_MIN, ns.SCALE_MAX, ns.db.windowScale or 1)) end
end)

-- ===================== ROUND WINDOW STYLE (0.55) =====================
-- A minimap-style circular portrait: Textures\ring.tga is a bevelled ring with a transparent
-- outside, Textures\disk.tga the dark inside. Classic can't mask a 3D model, so the model is
-- sized to the square inscribed in the ring's inner circle and never reaches past it.
-- The wisp becomes a round marker on the ring pointing at the target (up = straight ahead),
-- lock (top-left) and settings (top-right) sit on the ring, and direction/distance and her
-- lines go into a slim title bar above or below the circle (0.57).
ns.defaults.windowStyle = "round"
local TEX = "Interface\\AddOns\\Companion\\Textures\\"
local RING_D     = 250                          -- ring diameter
local RING_INNER = RING_D / 2 * (118 / 128)     -- inner radius of the ring art (~115)
local RING_MID   = RING_D / 2 - 4               -- radius the wisp/buttons sit on
local SQ         = math.floor(RING_INNER * math.sqrt(2))   -- inscribed model square (~153)
ns.ROUND = { D = RING_D, INNER = RING_INNER, MID = RING_MID, SQ = SQ }

function ns.IsRoundStyle() return not (ns.db and ns.db.windowStyle == "classic") end

-- Screen offset on the ring for a navigation angle (0 = ahead/top, + = left, - = right).
function ns.RingPoint(rel, radius)
    return -radius * math.sin(rel), radius * math.cos(rel)
end

local round = CreateFrame("Frame", nil, frame)
round:SetSize(RING_D, RING_D)
round:SetPoint("TOPLEFT", 0, 0)
round:Hide()
local disk = round:CreateTexture(nil, "BACKGROUND")
disk:SetAllPoints()
disk:SetTexture(TEX .. "disk")
disk:SetVertexColor(0.08, 0.08, 0.12, 0.92)
-- ring overlay above the model
local ringOver = CreateFrame("Frame", nil, round)
ringOver:SetAllPoints()
ringOver:SetFrameLevel(input:GetFrameLevel() + 3)
local ring = ringOver:CreateTexture(nil, "OVERLAY")
ring:SetAllPoints()
ring:SetTexture(TEX .. "ring")
ns.roundFrame, ns.roundRing = round, ring

-- 0.57: slim title bar like the minimap zone bar, floating above (or below) the circle.
-- It shows the direction/distance (and her lines briefly in "window" speech mode), holds the
-- lock (left) and settings gear (right), and works as a drag handle.
ns.defaults.windowBar = "above"
local BAR_H, BAR_GAP = 29, 4          -- 0.61: 20% smaller than 0.59
local BAR_ICON, BAR_FONT = 21, 12
local BAR_W_ROUND = 260
ns.defaults.titleBarSize = 1.0
-- 'Title bar size' multiplier relative to the window; the bar scales with the window.
function ns.BarScale()
    local sz = tonumber(ns.db and ns.db.titleBarSize) or 1
    sz = math.max(0.5, math.min(2.0, sz))
    return sz   -- 0.60: relative to the window (scales with it)
end
ns.ROUND.BAR_H, ns.ROUND.BAR_GAP = BAR_H, BAR_GAP
local bar = CreateFrame("Frame", nil, frame, "BackdropTemplate")
bar:SetSize(BAR_W_ROUND, BAR_H)
bar:SetFrameLevel(input:GetFrameLevel() + 5)
if bar.SetBackdrop then
    bar:SetBackdrop({
        bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    bar:SetBackdropColor(0.04, 0.04, 0.06, 0.9)
    bar:SetBackdropBorderColor(0.8, 0.66, 0.36, 1)
end
bar:EnableMouse(true)
bar:RegisterForDrag("LeftButton")
bar:SetScript("OnDragStart", function() frame:StartMoving() end)
bar:SetScript("OnDragStop", function() local f = frame:GetScript("OnDragStop") if f then f(frame) end end)
bar:Hide()
ns.roundBar = bar
function ns.BarPosition() return (ns.db and ns.db.windowBar == "below") and "below" or "above" end

-- 0.58: square (classic) body: the model in a bordered box, title bar floating above/below
local BOX_PAD = 8
local BOX_H = MODEL_H + BOX_PAD * 2
local box = CreateFrame("Frame", nil, frame, "BackdropTemplate")
box:SetSize(WIN_W, BOX_H)
box:SetFrameLevel(frame:GetFrameLevel())
if box.SetBackdrop then
    box:SetBackdrop({
        bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    box:SetBackdropColor(0.1, 0.1, 0.15, 0.95)
    box:SetBackdropBorderColor(0.6, 0.5, 0.3, 0.8)
end
box:Hide()
ns.classicBox = box

local function PlaceOnRing(f, rel, radius)
    local x, y = ns.RingPoint(rel, radius or RING_MID)
    f:ClearAllPoints()
    f:SetPoint("CENTER", round, "CENTER", x, y)
end
-- 0.56: no settings button on the ring (settings via /comp and the menu)
-- lock: the existing button, given a ring border in round style

-- wisp arrow (0.56): the minimap's player arrow on the ring, pointing outward toward the target
local marker = CreateFrame("Frame", nil, ringOver)
marker:SetSize(44, 44)
marker:SetFrameLevel(ringOver:GetFrameLevel() + 4)
marker.icon = marker:CreateTexture(nil, "OVERLAY")
marker.icon:SetAllPoints()
marker.icon:SetTexture("Interface\\Minimap\\MinimapArrow")
marker.icon:SetVertexColor(0.55, 0.85, 1)
marker:Hide()
ns.wispMarker = marker
-- rotate a texture counter-clockwise by a radians (SetRotation, else SetTexCoord math)
local function Rotate(tex, a)
    if tex.SetRotation then tex:SetRotation(a) return end
    if not tex.SetTexCoord then return end
    local c, s2 = math.cos(a), math.sin(a)
    local function p(x, y) x, y = x - 0.5, y - 0.5 return 0.5 + c * x + s2 * y, 0.5 - s2 * x + c * y end
    local ulx, uly = p(0, 0) local llx, lly = p(0, 1) local urx, ury = p(1, 0) local lrx, lry = p(1, 1)
    tex:SetTexCoord(ulx, uly, llx, lly, urx, ury, lrx, lry)
end
-- called from Wisp.lua with the (already smoothed) navigation angle; nil hides it.
-- The arrow art points up; rotating it by the angle (+ = left = counter-clockwise) points it outward.
function ns.SetRoundWisp(angle)
    if angle == nil then marker:Hide() marker.angle = nil return end
    marker.angle = angle
    marker.rotation = angle
    PlaceOnRing(marker, angle)
    Rotate(marker.icon, angle)
    marker:Show()
end

local classicSaved = false
function ns.ApplyWindowStyle(style)
    if style then ns.db.windowStyle = (style == "classic") and "classic" or "round" end
    local r = renderer
    local isRound = ns.IsRoundStyle()
    local below = ns.BarPosition() == "below"
    local body, bodyW, bodyH, mw, mh
    frame:SetBackdrop(nil)
    title:Hide() close:Hide()
    bar:Show()
    round:ClearAllPoints() box:ClearAllPoints() bar:ClearAllPoints()
    if isRound then
        round:Show() box:Hide() grip:Hide()
        body, bodyW, bodyH, mw, mh = round, RING_D, RING_D, SQ, SQ
    else
        -- 0.58: the square (classic) window gets the same floating title bar
        round:Hide() marker:Hide() box:Show() grip:Show()
        body, bodyW, bodyH, mw, mh = box, WIN_W, BOX_H, MODEL_W, MODEL_H
    end
    frame:SetWidth(bodyW)
    local bs = ns.BarScale()
    if bar.SetScale then bar:SetScale(bs) end
    -- width in window units: round ~300 on screen at size 1, classic matches the box
    local barWWin = isRound and BAR_W_ROUND * bs or WIN_W
    bar:SetSize(barWWin / bs, BAR_H)
    local barHWin = BAR_H * bs           -- bar height in window units
    if below then
        body:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
        bar:SetPoint("TOP", body, "BOTTOM", 0, -BAR_GAP / bs)
    else
        bar:SetPoint("TOP", frame, "TOP", 0, 0)
        body:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -(barHWin + BAR_GAP))
    end
    input:ClearAllPoints()
    input:SetSize(mw, mh)
    input:SetPoint("CENTER", body, "CENTER", 0, 0)
    if r and r.display then r.display:SetSize(mw, mh) end
    dialogue:ClearAllPoints()
    dialogue:SetParent(bar)
    dialogue:SetPoint("CENTER", bar, "CENTER", 0, 0)
    dialogue:SetSize(bar:GetWidth() - 2 * (BAR_ICON + 12), BAR_FONT + 4)
    dialogue:SetJustifyH("CENTER")
    if dialogue.SetWordWrap then dialogue:SetWordWrap(false) end
    if dialogue.SetFontObject and GameFontNormal then dialogue:SetFontObject(GameFontNormal) end
    if dialogue.SetFont and STANDARD_TEXT_FONT then dialogue:SetFont(STANDARD_TEXT_FONT, BAR_FONT, "OUTLINE") end
    if dialogue.SetTextColor then dialogue:SetTextColor(1, 0.82, 0) end
    lockBtn:SetParent(bar)
    lockBtn:SetSize(BAR_ICON, BAR_ICON)
    lockBtn:ClearAllPoints()
    lockBtn:SetPoint("LEFT", bar, "LEFT", 6, 0)
    lockBtn:SetFrameLevel(bar:GetFrameLevel() + 2)
    local sb = ns.SettingsButton
    if sb then
        sb:SetParent(bar)
        sb:SetSize(BAR_ICON, BAR_ICON)
        sb:ClearAllPoints()
        sb:SetPoint("RIGHT", bar, "RIGHT", -6, 0)
        sb:SetFrameLevel(bar:GetFrameLevel() + 2)
    end
    if not isRound then
        grip:ClearAllPoints()
        grip:SetPoint("BOTTOMRIGHT", box, "BOTTOMRIGHT", -4, 4)
    end
    local top = below and 0 or (barHWin + BAR_GAP)
    ns.LAYOUT.MODEL_TOP = -top - (bodyH - mh) / 2
    ns.LAYOUT.BASE_H = bodyH + barHWin + BAR_GAP + 4
    ns.LAYOUT.GUIDE_TOP = -ns.LAYOUT.BASE_H + 2
    frame:SetHeight(ns.LAYOUT.BASE_H + extraH)
    ApplyCamera()
    if ns.ApplyGuideDock then ns.ApplyGuideDock() end
    if ns.RefreshConfig then pcall(ns.RefreshConfig) end
    return ns.db.windowStyle or "round"
end
function ns.SetWindowStyle(v) return ns.ApplyWindowStyle(v) end
function ns.SetTitleBarSize(v)
    ns.db.titleBarSize = math.max(0.5, math.min(2.0, tonumber(v) or 1))
    ns.ApplyWindowStyle()
    return ns.db.titleBarSize
end
function ns.SetWindowBar(v)
    ns.db.windowBar = (v == "below") and "below" or "above"
    ns.ApplyWindowStyle()
    return ns.db.windowBar
end
ns:AddCommand("style", function(rest)
    rest = (rest or ""):lower()
    local v = (rest == "classic" or rest == "round") and rest or (ns.IsRoundStyle() and "classic" or "round")
    ns.Print("window style: " .. ns.ApplyWindowStyle(v))
end)

-- ===================== STARTUP =====================

ns:On("LOGIN", function()
    ns.ApplySpeechLayout()
    ns.db.windowScale = ns.ClampScale(ns.db.windowScale or 1)
    frame:SetScale(ns.db.windowScale)
    frame:ClearAllPoints()
    frame:SetPoint(ns.db.point or "CENTER", UIParent, ns.db.point or "CENTER", ns.db.x or 0, ns.db.y or 0)
    PickRenderer()
    ns.ApplyWindowStyle()
    ns:ApplyModelSettings()
    UpdateLockButton()
    frame:SetShown(ns.db.companionShown)
end)

ns:AddCommand("toggle", function() frame:SetShown(not frame:IsShown()) end)

function ns.SetUseScene(on) ns.db.useScene = on and true or false end
ns:AddCommand("scene", function()
    ns.SetUseScene(not ns.db.useScene)
    ns.Print("3D scene renderer " .. (ns.db.useScene and "ON" or "OFF (classic model + wisp)")
        .. ". Type /reload to apply.")
end)
