-- Companion: Legacy renderer. The original PlayerModel display plus a separate
-- PlayerModel wisp that floats around her. Overlapping model frames can't
-- depth-sort, so the wisp can't truly pass in front of her here; the ModelScene
-- renderer (SceneModel.lua) fixes that. Used when /comp scene is off or the
-- client has no ModelScene support.

local _, ns = ...

function ns.CreateLegacyRenderer(frame, area)
    local r = {}

    local model = CreateFrame("PlayerModel", nil, frame)
    model:SetSize(ns.MODEL_W, ns.MODEL_H)
    model:SetPoint("CENTER", area, "CENTER", 0, 0)
    model:EnableMouse(false)
    r.display = model

    function r:ApplyCamera()
        model:SetCamDistanceScale(ns.db.camDistance or 1.15)
        model:SetPosition(ns.db.posX or 0, ns.db.posY or 0, ns.db.posZ or 0)
    end
    function r:Apply()
        model:SetDisplayInfo(ns.db.modelID or 2043)
        self:ApplyCamera()
    end
    function r:SetAnimation(anim) pcall(model.SetAnimation, model, anim) end
    function r:SetFacing(rad) pcall(model.SetFacing, model, rad) end

    -- ===== wisp (unchanged behaviour from 0.22) =====
    local wisp = CreateFrame("PlayerModel", "CompanionWisp", frame)
    wisp:SetSize(70, 70)
    wisp:EnableMouse(false)
    wisp:Hide()
    ns.wisp = wisp

    local RADIUS_X = 85
    local HEAD_Y   = 75
    local FRONT_Y  = -40
    local bob = 0

    local function ApplyWisp()
        wisp:SetDisplayInfo(ns.db.wispDisplayID)
        wisp:SetCamDistanceScale(1.0)
        wisp:SetPosition(0, 0, 0)
    end
    r.ApplyWisp = function() ApplyWisp() end

    function r:SetWispAngle(angle, elapsed)
        if not angle or not frame:IsShown() then
            wisp:Hide()
            return
        end
        bob = bob + (elapsed or 0) * 3
        local side  = -math.sin(angle)
        local depth = math.cos(angle)
        local x = side * RADIUS_X
        local y = (depth > 0) and (FRONT_Y + (HEAD_Y - FRONT_Y) * depth) or (FRONT_Y + 10 * depth)
        y = y + math.sin(bob) * 4
        local scale = 1 - 0.35 * depth
        local size = ns.db.wispSize * scale
        wisp:SetSize(size, size)
        wisp:SetAlpha(0.75 + 0.25 * (1 - depth) / 2)
        wisp:ClearAllPoints()
        wisp:SetPoint("CENTER", model, "CENTER", x, y)
        local inFront = depth <= 0
        if wisp.inFront ~= inFront then
            wisp.inFront = inFront
            wisp:SetParent(inFront and UIParent or frame)
            wisp:SetFrameStrata(inFront and "HIGH" or frame:GetFrameStrata())
            wisp:SetFrameLevel(inFront and 50 or math.max(frame:GetFrameLevel(), model:GetFrameLevel() - 1))
            wisp:SetScale(frame:GetEffectiveScale() / UIParent:GetEffectiveScale())
            C_Timer.After(0, ApplyWisp)
        end
        wisp:SetShown(frame:IsShown())
        if not wisp.applied then
            wisp.applied = true
            ApplyWisp()
        end
    end

    return r
end
