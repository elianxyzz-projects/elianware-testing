# Recreated cheatengine interface (partial)

File: [`src/libraries/cheatengine_compat.lua`](src/libraries/cheatengine_compat.lua)

## Evidence

Reconstructed from direct calls in the user's uploaded CatVape `src/games/6872274481.lua`; **not** from recovered Luraph source.

| Exposed name | Observed use | Implemented here |
| --- | --- | --- |
| `ProjectileAim.Bind({Solve, Preview?})` | SilentAim / ProjectileAimbot | Validate arguments, delegate to caller-supplied adapter |
| `BlockReach.Bind({Place, Break})` | Reach | Delegate to adapter |
| `CannonBoost.Bind(fn)`, `GetSpeed()` | Cannon speed | Delegate to adapter |
| `DamageIndicator.Bind(fn)` | Damage indicator settings | Delegate to adapter |
| `BlockTarget.GetBlock()` | FastBreak, targeting | Delegate to adapter |
| `HotbarVisual.GetSlot(tool)`, `Select(slot)` | Hotbar switch | Delegate to adapter |
| `GetBlockBreaker()` | FastBreak | Returns nil unless a provider is supplied |
| `RateLimits`, `BowConstantsTable`, `TeamUpgradeMeta` | BedWars metadata fallback | Exposes caller-provided data only |
| `Debug` | Module inspection fallback | Caller-provided only |
| `LastOwnPlace` | Placement timestamp | Defaults to 0 unless provided |
| `[modulePath]:await()` | Unsupported executor module loading | Manually register awaitable modules |

## Example (with a mock backend)

```lua
local createCompat = loadstring(compatSource) -- compatSource = contents of cheatengine_compat.lua
local compat = createCompat()(vape, events, entity, {
    ProjectileAim = {
        Bind = function(settings)
            -- The host implementation must supply its own legitimate event integration.
            return function() end -- disconnect/cleanup
        end
    }
})

local cleanup = compat.ProjectileAim.Bind({
    Solve = function(launchData, origin, speed)
        return nil -- no solution available
    end
})
cleanup()
```

## Limitations

This file cannot reproduce protected functions or game hooks merely by matching their method names. All hook-based methods require external adapters and raise an explicit error if unavailable. It does not implement the Luraph virtual machine, bypass game validation, inspect protected module internals, or install an executor interception mechanism. It is not yet suitable as a drop-in replacement for the original library.

The existing `experimental/cv_swordtiming.lua` is independent of this interface. The Aero main repository remains separate.
