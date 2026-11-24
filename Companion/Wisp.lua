-- Companion: The guide wisp. Orbits the companion to show direction.
--   Target ahead  -> wisp floats behind her, above her head
--   Target right  -> wisp swings out to her right (screen right)
--   Target left   -> wisp swings out to her left (screen left)
--   Target behind -> wisp comes around in front of her, lower
-- The actual drawing is done by the active renderer (SceneModel.lua or LegacyModel.lua).

local _, ns = ...

ns.defaults.wispDisplayID = 10045
ns.defaults.wispSize = 70          -- legacy renderer: pixel size
ns.defaults.wispScale = 0.5        -- scene renderer: actor scale
ns.defaults.wispOrbit = 0.3        -- scene renderer: orbit radius as a fraction of her height
ns.defaults.wispZ = 2              -- scene renderer: height offset

local function Apply()
    local r = ns.GetRenderer and ns:GetRenderer()
    if r and r.ApplyWisp then pcall(r.ApplyWisp, r) end
end
ns.ApplyWisp = Apply

-- angle: 0 = target ahead, positive = left, negative = right, pi = behind. nil hides it.
-- 0.55: in the round window style the wisp is a marker on the ring instead (up = ahead).
function ns:SetWispAngle(angle, elapsed)
    local r = ns:GetRenderer()
    if ns.IsRoundStyle and ns.IsRoundStyle() and ns.SetRoundWisp then
        if r and r.SetWispAngle then r:SetWispAngle(nil, elapsed) end
        ns.SetRoundWisp(angle)
        return
    end
    if ns.SetRoundWisp then ns.SetRoundWisp(nil) end
    if r and r.SetWispAngle then r:SetWispAngle(angle, elapsed) end
end

ns:On("LOGIN", Apply)

function ns.SetWispDisplayID(id)
    id = tonumber(id)
    if not id or id <= 0 then return false end
    ns.db.wispDisplayID = id
    Apply()
    return true
end
-- numeric wisp settings (wispScale, wispOrbit, wispZ, wispFrontZ)
function ns.SetWispValue(key, v)
    ns.db[key] = tonumber(v)
    Apply()
end
ns.WISP_DEFAULTS = { wispDisplayID = 10045, wispScale = 0.5, wispOrbit = 0.3, wispZ = 2, wispFrontZ = 0.45 }
function ns.ResetWisp()
    for k, v in pairs(ns.WISP_DEFAULTS) do ns.db[k] = v end
    Apply()
end

ns:AddCommand("wisp", function(rest)
    local id = tonumber(rest)
    if id then
        ns.SetWispDisplayID(id)
        ns.Print("wisp model set to " .. id)
    else
        ns.Print("usage: /comp wisp <displayID>  (current " .. ns.db.wispDisplayID .. ")")
    end
end)

ns:AddCommand("orbit", function(rest)
    local v = tonumber(rest)
    if v and v > 0 then
        ns.SetWispValue("wispOrbit", v)
        ns.Print("wisp orbit set to " .. v .. " x her height")
    else
        ns.Print("usage: /comp orbit <number>  (current " .. ns.db.wispOrbit .. ", default 0.3)")
    end
end)
