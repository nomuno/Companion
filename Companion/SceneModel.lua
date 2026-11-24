-- Companion: ModelScene renderer. She and the wisp are actors in ONE 3D scene,
-- so the wisp depth-sorts naturally (it really passes behind and in front of her).
--
-- Scene axes (same as WoW world space; Blizzard OrbitCameraMixin +
-- Vector3D_CalculateNormalFromYawPitch: yaw 0 / pitch 0 => forward = +x):
--   camera sits on -x looking toward +x  => larger x = farther from the camera
--   +y = screen LEFT, -y = screen right (right-handed, z up)
--   +z = up
-- Actors face +x at yaw 0, so yaw = pi turns her toward the camera.

local _, ns = ...

local FOV         = math.rad(40)   -- camera vertical field of view
local DIST_FACTOR = 0.95           -- camera distance = height * this * camDistance
local LOOK_AT     = 0.78           -- look at this fraction of her height
local PAN_SCALE   = 1.0            -- drag offsets (posY/posZ) in scene units
local BACK_Z      = 0.98           -- wisp height (x her height) when behind her
local FRONT_Z     = 0.45           -- wisp height when in front of her
local BOB         = 0.015           -- bob amplitude (x her height)
local DEFAULT_H   = 2.0            -- height used until the model reports a bounding box

-- Pure math so it can be tested offline: wisp offset relative to her feet.
-- angle 0 = behind her (+x, far), +pi/2 = screen left (+y), pi = in front (-x, near).
function ns.SceneWispOffset(angle, height, orbit, bobPhase)
    local r = height * orbit
    local t = (math.cos(angle) + 1) / 2              -- 1 behind, 0 in front
    local z = height * ((ns.db and ns.db.wispFrontZ or FRONT_Z) + (BACK_Z - (ns.db and ns.db.wispFrontZ or FRONT_Z)) * t) + math.sin(bobPhase or 0) * BOB * height
    return r * math.cos(angle), r * math.sin(angle), z
end

local function call(obj, method, ...)
    local fn = obj and obj[method]
    if not fn then return false end
    local ok, a, b, c, d, e, f = pcall(fn, obj, ...)
    if ok then return true, a, b, c, d, e, f end
    return false
end

ns.LIGHT_DIRS = {
    { 1, 0, -0.5, type = 1, enum = "Directional", name = "front, directional" },
    { -1, 0, -0.5, type = 1, enum = "Directional", name = "back, directional" },
    { 1, 0, -0.5, type = 0, enum = "Point", name = "front, point" },
    { 0.5, 0.5, -1, type = 1, enum = "Directional", name = "top-left, directional" },
    { 1, 0, -0.5, type = 2, name = "front, type 2" },
}

function ns.CreateSceneRenderer(frame, area)
    local ok, scene = pcall(CreateFrame, "ModelScene", "CompanionScene", frame)
    if not ok or not scene or not scene.CreateActor then return nil end
    local okA, her = call(scene, "CreateActor")
    local okW, wisp = call(scene, "CreateActor")
    if not (okA and her and okW and wisp) then return nil end

    scene:SetSize(ns.MODEL_W, ns.MODEL_H)
    scene:SetPoint("CENTER", area, "CENTER", 0, 0)
    call(scene, "EnableMouse", false)
    call(scene, "SetCameraNearClip", 0.01)
    call(scene, "SetCameraFarClip", 100)
    call(scene, "SetCameraFieldOfView", FOV)
    -- Lighting. Without a working light ModelScene actors render as black silhouettes.
    -- /comp light cycles through setups in game; /comp scenedebug lists what this client supports.
    local function ApplyLight()
        local mode = ns.db.sceneLight or 1
        local amb = ns.db.sceneAmbient or 1.0
        local dir = ns.LIGHT_DIRS[mode] or ns.LIGHT_DIRS[1]
        call(scene, "SetLightVisible", true)
        local ltype = dir.type
        if Enum and Enum.ModelLightType and dir.enum then ltype = Enum.ModelLightType[dir.enum] or ltype end
        call(scene, "SetLightType", ltype)
        call(scene, "SetLightDirection", dir[1], dir[2], dir[3])
        call(scene, "SetLightPosition", -dir[1] * 5, -dir[2] * 5, -dir[3] * 5)
        call(scene, "SetLightAmbientColor", amb, amb, amb)
        call(scene, "SetLightDiffuseColor", 1, 1, 1)
        call(scene, "SetLightIntensity", 1)
    end
    ApplyLight()
    ns.ApplySceneLight = ApplyLight
    ns.sceneFrame = scene
    ns.sceneActor = her

    local r = { display = scene, scene = scene, her = her, wisp = wisp }
    local height = DEFAULT_H
    local herX, herY, herZ = 0, 0, 0
    local bob, lastAngle = 0, nil

    local function MeasureHeight()
        local okB, _, _, minZ, _, _, maxZ = call(her, "GetActiveBoundingBox")
        if okB and minZ and maxZ and maxZ - minZ > 0.05 then height = maxZ - minZ end
    end

    function r:ApplyCamera()
        herX = -(ns.db.posX or 0) * PAN_SCALE
        herY = -(ns.db.posY or 0) * PAN_SCALE     -- drag right => screen right => -y
        herZ = (ns.db.posZ or 0) * PAN_SCALE
        call(her, "SetPosition", herX, herY, herZ)
        call(her, "SetYaw", math.pi)               -- face the camera
        local dist = height * DIST_FACTOR * (ns.db.camDistance or 1.15)
        call(scene, "SetCameraPosition", -dist, 0, height * LOOK_AT)
        call(scene, "SetCameraOrientationByYawPitchRoll", 0, 0, 0)
        lastAngle = nil
    end
    r.GetCameraX = function() return -height * DIST_FACTOR * (ns.db.camDistance or 1.15) end
    r.GetHeight = function() return height end

    function r:Apply()
        local id = ns.db.modelID or 2043
        local okM, res = call(her, "SetModelByCreatureDisplayID", id)
        if not okM or res == false then call(her, "SetModelByFileID", id) end
        call(her, "SetAnimation", 0)
        MeasureHeight()
        self:ApplyCamera()
        -- the bounding box is only known once the model has loaded
        C_Timer.After(0.3, function() MeasureHeight() r:ApplyCamera() end)
    end

    call(her, "SetScript", "OnModelLoaded", function() MeasureHeight() r:ApplyCamera() end)

    function r:SetAnimation(anim) call(her, "SetAnimation", anim) end
    function r:SetFacing() call(her, "SetYaw", math.pi) end   -- she always faces you

    function r:ApplyWisp()
        self.wispLoaded = true
        local okM, res = call(wisp, "SetModelByCreatureDisplayID", ns.db.wispDisplayID)
        if not okM or res == false then call(wisp, "SetModelByFileID", ns.db.wispDisplayID) end
        call(wisp, "SetScale", ns.db.wispScale or 1)
        -- Floating models like wisps have their geometry far above their origin.
        -- Center them on their position so the orbit math puts them where we expect.
        call(wisp, "SetUseCenterForOrigin", true, true, true)
        call(wisp, "SetYaw", math.pi)
        lastAngle = nil
    end

    -- Hide/Show may not exist on actors in every client, so alpha is the fallback.
    local function ShowWisp(on)
        if not call(wisp, on and "Show" or "Hide") then call(wisp, "SetAlpha", on and 1 or 0) end
        call(wisp, "SetAlpha", on and 1 or 0)
    end
    ShowWisp(false)
    r.wispShown = false

    function r:SetWispAngle(angle, elapsed)
        if not angle or not frame:IsShown() then
            if self.wispShown then ShowWisp(false) self.wispShown = false end
            lastAngle = nil
            return
        end
        if not self.wispLoaded then self:ApplyWisp() end
        if not self.wispShown then ShowWisp(true) self.wispShown = true end
        bob = bob + (elapsed or 0) * 3
        -- At most once per frame; positions change every frame anyway because of the bob.
        local x, y, z = ns.SceneWispOffset(angle, height, ns.db.wispOrbit or 0.55, bob)
        if not self.wispZFix then
            self.wispZFix = 0
            if not wisp.SetUseCenterForOrigin then
                local okB, _, _, minZ, _, _, maxZ = call(wisp, "GetActiveBoundingBox")
                if okB and minZ and maxZ then self.wispZFix = -(minZ + maxZ) / 2 end
            end
        end
        z = z + self.wispZFix + (ns.db.wispZ or 0)
        call(wisp, "SetPosition", herX + x, herY + y, herZ + z)
        lastAngle = angle
        self.wispPos = { herX + x, herY + y, herZ + z }
    end

    return r
end


function ns.SetSceneAmbient(v)
    ns.db.sceneAmbient = tonumber(v)
    if ns.ApplySceneLight then ns.ApplySceneLight() end
end
function ns.CycleSceneLight()
    ns.db.sceneLight = ((ns.db.sceneLight or 1) % #ns.LIGHT_DIRS) + 1
    if ns.ApplySceneLight then ns.ApplySceneLight() end
    return ns.LIGHT_DIRS[ns.db.sceneLight].name
end

ns:AddCommand("light", function(rest)
    local amb = tonumber(rest)
    if amb then ns.SetSceneAmbient(amb) else ns.CycleSceneLight() end
    local d = ns.LIGHT_DIRS[ns.db.sceneLight or 1]
    ns.Print(string.format("light %d/%d (%s), ambient %.2f", ns.db.sceneLight or 1, #ns.LIGHT_DIRS, d.name, ns.db.sceneAmbient or 1))
end)

ns:AddCommand("scenedebug", function()
    local sc, a = ns.sceneFrame, ns.sceneActor
    if not sc then ns.Print("scene renderer is not active.") return end
    local names = { "SetLightVisible", "SetLightType", "SetLightDirection", "SetLightPosition",
        "SetLightAmbientColor", "SetLightDiffuseColor", "SetLightIntensity", "SetCameraPosition",
        "SetCameraOrientationByYawPitchRoll", "SetCameraFieldOfView" }
    local have, miss = {}, {}
    for _, n in ipairs(names) do table.insert(sc[n] and have or miss, n) end
    ns.Print("scene has: " .. table.concat(have, ", "))
    ns.Print("|cffff6060missing:|r " .. (#miss > 0 and table.concat(miss, ", ") or "none"))
    local aNames = { "SetModelByCreatureDisplayID", "SetModelByFileID", "SetAnimation", "SetYaw", "SetUseCenterForOrigin" }
    local am = {}
    for _, n in ipairs(aNames) do if not (a and a[n]) then table.insert(am, n) end end
    ns.Print("actor missing: " .. (#am > 0 and table.concat(am, ", ") or "none"))
    print("  ModelLightType enum: " .. tostring(Enum and Enum.ModelLightType and "yes" or "no"))
end)

ns:AddCommand("wispsize", function(rest)
    local v = tonumber(rest)
    if v then
        ns.SetWispValue("wispScale", v)
    end
    ns.Print("wisp size " .. tostring(ns.db.wispScale) .. " (try 0.2 to 1)")
end)

-- One-time switch to the torso-up portrait framing.
ns:On("LOGIN", function()
    if (ns.db.portraitVersion or 0) < 1 then
        ns.db.portraitVersion = 1
        ns.db.camDistance = 1.0
        ns.db.posX, ns.db.posY, ns.db.posZ = 0, 0, 0
        ns.db.wispScale = 0.5
        ns.db.wispOrbit = 0.3
        ns.db.wispZ = 2
        local r = ns:GetRenderer()
        if r and r.ApplyCamera then r:ApplyCamera() end
        if ns.ApplyWisp then ns.ApplyWisp() end
    end
end)

ns:AddCommand("wispfront", function(rest)
    ns.SetWispValue("wispFrontZ", tonumber(rest))
    ns.Print("wisp height in front: " .. tostring(ns.db.wispFrontZ or FRONT_Z) .. " (lower = closer to the bottom, try 0.3 to 0.7)")
end)

ns:AddCommand("wispz", function(rest)
    ns.SetWispValue("wispZ", tonumber(rest) or 0)
    ns.Print("wisp height offset " .. ns.db.wispZ .. " (try -1 to 1)")
end)

ns:AddCommand("wispdebug", function()
    local r = ns:GetRenderer()
    if not (r and r.wisp) then ns.Print("scene renderer not active.") return end
    local p = r.wispPos
    ns.Print(string.format("wisp id %s, loaded %s, shown %s, pos %s, her height %.2f",
        tostring(ns.db.wispDisplayID), tostring(r.wispLoaded), tostring(r.wispShown),
        p and string.format("%.2f, %.2f, %.2f", p[1], p[2], p[3]) or "none", r.GetHeight()))
end)
