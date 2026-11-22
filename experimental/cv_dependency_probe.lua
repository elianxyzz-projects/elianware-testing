-- Read-only dependency checks for CatVape/AeroV4 compatibility.
-- This file does not inject hooks, execute cheat modules, or modify game state.
local Probe = {}

local function check(value, description, results)
    results[#results + 1] = {name = description, ok = value ~= nil and value ~= false}
end

function Probe.Run(context)
    assert(type(context) == "table", "context is required")
    local api = context.vape
    local bedwars = context.bedwars
    local entity = context.Entity
    local results = {}

    check(api and api.Categories and api.Categories["Experimental (Ban)"], "Experimental category", results)
    check(api and api.Categories and api.Categories["Experimental (Ban)"] and
        api.Categories["Experimental (Ban)"].CreateModule, "Experimental module API", results)

    check(bedwars and bedwars.SyncEvents and bedwars.SyncEvents.SwordSwing, "SwordSwing event", results)
    check(bedwars and bedwars.Handler and bedwars.Handler.Get, "SwordHit rate-limit handler", results)
    check(bedwars and bedwars.SwordController, "Sword controller", results)
    check(bedwars and bedwars.ItemMeta, "Item metadata", results)
    check(bedwars and bedwars.StatusEffectUtil, "Status effects", results)

    check(entity and entity.Events and entity.Events.EntityAdded, "Entity added signal", results)
    check(entity and entity.Events and entity.Events.EntityRemoved, "Entity removed signal", results)
    check(entity and entity.List, "Entity list", results)
    check(bedwars and bedwars.ProjectileMeta, "Projectile metadata", results)
    check(context.Prediction and context.Prediction.SolveTrajectory, "Ballistic predictor", results)
    check(context.ProjectileAim and context.ProjectileAim.Bind, "Projectile hook adapter", results)

    local ready = true
    for _, item in ipairs(results) do
        if not item.ok then ready = false end
    end
    return ready, results
end

return Probe
