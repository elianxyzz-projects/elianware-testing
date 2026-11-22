# CatVape → AeroV4 experimental modules (integration in progress)

Target category: `Experimental (Ban)`

Requested separate module names:
- `Hitreg Adjuster (CV)`
- `SilentAim (CV)`
- `Hitboxes (CV)`

Source inspected: uploaded CatVape `src.json`, specifically `src/games/6872274481.lua`. Extracted Lua snippets were prepared separately, but **are not standalone**. Do not paste them directly into the active Aero loader.

## Integration blockers

### Hitreg Adjuster (CV)
Requires CatVape's `vape.Libraries.swordtiming.Calculate`, `bedwars.SyncEvents.SwordSwing` event-priority hooks, sword controller, rate limiter, and state. Need an Aero-compatible implementation of the timing hook before registration.

### SilentAim (CV)
Requires CatVape's target selection helpers, ballistic solver, blacklist, target metadata, and either `vape.Libraries.cheatengine.ProjectileAim.Bind` or an executor-dependent `__namecall` hook. The cheatengine library in the supplied source is Luraph-obfuscated. Requires a separate tested integration. Avoid overriding Aero's existing SilentAim.

### Hitboxes (CV)
Requires entity-added/removed events and CatVape's `canDebug` and BedWars sword controller structures. To coexist with Aero's own `HitBoxes`, use a separate module name and a tracked cleanup lifecycle. Do not alter original Aero HitBoxes or HitFix.

## Preservation and acceptance criteria

- Keep the current 10-second startup delay.
- Keep all existing Aero modules, particularly HitFix, unchanged.
- Register all three under `Experimental (Ban)` with the `(CV)` suffix.
- Defaults must be OFF; enabling one must not auto-enable another.
- Turning a module OFF must restore every hook/connection/changed property.
- The category and toggles should not be published as functional until runtime tested.
- Current `main` branch remains unchanged.

This is an integration staging document, **not** a claim that the modules are installed or functional.
