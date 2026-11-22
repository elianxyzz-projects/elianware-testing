-- CatVape Hitreg Adjuster timing dependency.
-- Extracted from the source file supplied for this integration.
-- This is a pure timing helper, not an executable module or an injection hook.
local Timing = {
    SafeSpacing = 0.296,
    HighSpacing = 0.2925,
    HitFloor = 0.285,
    GapFloor = 0.2915,
    ArrivalFloor = 0.2747,
    CooldownCorrection = 0.015212,
}

local weaponSpacing = {
    [0.21] = 0.229,
    [0.25] = 0.249,
    [0.35] = 0.345,
    [0.4] = 0.341,
    [0.6] = 0.63,
}

function Timing.Calculate(speed, fury, high, budget, hits)
    assert(type(speed) == "number" and speed > 0, "speed must be positive")
    fury = fury or 1
    budget = budget or 0
    local stock = speed == 0.3
    local normal = high and Timing.HighSpacing or Timing.SafeSpacing
    local spacing = stock and normal or weaponSpacing[speed] or (speed + 0.03)
    if hits and hits ~= 35 then
        spacing = math.max(spacing, 10 / math.max(hits - 1, 1))
    end
    spacing = math.max(spacing * fury, budget)
    local scale = spacing / (stock and normal or Timing.SafeSpacing)
    local gap = (scale < 1 and Timing.GapFloor or Timing.HitFloor) * scale
    if stock and high then
        gap = math.max(gap, Timing.GapFloor * fury, budget)
    end
    return spacing, scale, gap, math.max(speed * fury - Timing.CooldownCorrection, 0), stock
end

return Timing
